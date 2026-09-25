-- String-aware comment lexer used by smart_comment.
--
-- scan(lines, spec, opts) walks the lines as source code of `spec` and returns
--   comments  list of comment objects { kind = "line"|"block", spec, open, close, sr, sc, er, ec, rows }
--   pieces    pieces[row] = ordered list of
--               { k = "comment", c = comment, s, e, open, close, dstart, dend }  (part of a comment on that row)
--               { k = "stray", s, e }                                           (unmatched block closer in code)
--   row_spec  row_spec[row] = spec of the language at the row's first non-blank char (embedded regions)
-- Columns are 1-based byte indices, `e` inclusive. `open`/`close` tell whether the opener/closer is on that row.
--
-- opts.inner: re-lex a single line of comment text: markers only count when surrounded by whitespace,
--             strings must close on the same line, no regions / heredocs / shebang.
-- opts.stop:  last row to scan.
local M = {}

local function is_ws(ch)
  return ch == "" or ch:find("^%s") ~= nil
end

local function is_word(ch)
  return ch ~= "" and ch:find("^[%w_]") ~= nil
end

-- previous non-blank char before column j (or nil at line start)
local function prev_sig(line, j)
  return line:sub(1, j - 1):match("(%S)%s*$")
end

local regex_prev_words = {
  ["return"] = true, ["typeof"] = true, ["case"] = true, ["in"] = true, ["of"] = true,
  ["delete"] = true, ["void"] = true, ["throw"] = true, ["new"] = true, ["yield"] = true,
  ["await"] = true, ["when"] = true, ["if"] = true, ["unless"] = true, ["and"] = true,
  ["or"] = true, ["not"] = true, ["elsif"] = true, ["while"] = true, ["until"] = true,
}

-- Special tokenizers. match(line, j, ctx) returns a candidate { len, k, ... } or nil.
local specials = {}

specials.lua_long = {
  trig = "-[",
  match = function(line, j)
    local eq = line:match("^%-%-%[(=*)%[", j)
    if eq then
      return { len = 4 + #eq, k = "block", open = "--[" .. eq .. "[", close = "]" .. eq .. "]" }
    end
    eq = line:match("^%[(=*)%[", j)
    if eq then
      return { len = 2 + #eq, k = "string", close = "]" .. eq .. "]", ml = true }
    end
  end,
}

specials.rust_raw = {
  trig = "rbc",
  match = function(line, j)
    if is_word(line:sub(j - 1, j - 1)) then
      return nil
    end
    local s, e, hashes = line:find('^[bc]?r(#*)"', j)
    if s then
      return { len = e - j + 1, k = "string", close = '"' .. hashes, ml = true }
    end
  end,
}

specials.rust_char = {
  trig = "'",
  match = function(line, j)
    local m = line:match("^'\\.[^']*'", j) or line:match("^'[^'\\][\128-\191]*'", j)
    if m then
      return { len = #m, k = "skip" }
    end
    return { len = 1, k = "skip" } -- lifetime / label: 'a
  end,
}

specials.cpp_raw = {
  trig = "uULR",
  match = function(line, j)
    if is_word(line:sub(j - 1, j - 1)) then
      return nil
    end
    local s, e, delim = line:find('^[uUL8]*R"([^()\\%s]*)%(', j)
    if s then
      return { len = e - j + 1, k = "string", close = ")" .. delim .. '"', ml = true }
    end
  end,
}

specials.heredoc_sh = {
  trig = "<",
  match = function(line, j, ctx)
    if ctx.inner or line:sub(j - 1, j - 1) == "<" then
      return nil
    end
    local s, e, dash, _, id = line:find("^<<(%-?)%s*(['\"]?)([%w_]+)%2", j)
    if s then
      return { len = e - j + 1, k = "heredoc", delim = id, strip = dash == "-" and "^\t*" or nil }
    end
  end,
}

specials.heredoc_ruby = {
  trig = "<",
  match = function(line, j, ctx)
    if ctx.inner then
      return nil
    end
    local s, e, mode, q, id = line:find("^<<([~-]?)(['\"`]?)([%a_][%w_]*)%2", j)
    if not s or (q == "" and mode == "" and not id:find("^[%u_]")) then
      return nil
    end
    return { len = e - j + 1, k = "heredoc", delim = id, strip = mode ~= "" and "^%s*" or nil }
  end,
}

specials.heredoc_php = {
  trig = "<",
  match = function(line, j, ctx)
    if ctx.inner then
      return nil
    end
    local s, e, _, id = line:find("^<<<%s*(['\"]?)([%a_][%w_]*)%1", j)
    if s then
      return { len = e - j + 1, k = "heredoc", delim = id, strip = "^%s*", loose = true }
    end
  end,
}

local brackets = { ["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">" }

specials.ruby_percent = {
  trig = "%",
  match = function(line, j)
    local p = prev_sig(line, j)
    if p and p:find("[%w_%)%]}]") then
      return nil -- modulo operator
    end
    local s, e, t, d = line:find("^%%([qQwWiIrsx]?)([^%w%s])", j)
    if not s or (t == "" and not brackets[d]) then
      return nil
    end
    return { len = e - j + 1, k = "string", close = brackets[d] or d, esc = "\\", ml = true }
  end,
}

specials.ruby_char = {
  trig = "?",
  match = function(line, j)
    if is_word(line:sub(j - 1, j - 1)) or line:sub(j - 1, j - 1) == ")" then
      return nil
    end
    if line:find("^%?[^%s%w]", j) and not is_word(line:sub(j + 2, j + 2)) then
      return { len = 2, k = "skip" }
    end
  end,
}

specials.regex = {
  trig = "/",
  match = function(line, j)
    local nx = line:sub(j + 1, j + 1)
    if nx == "/" or nx == "*" or nx == "" then
      return nil
    end
    local before = line:sub(1, j - 1)
    local p = before:match("(%S)%s*$")
    local ok = p == nil or p:find("[%(,=:%[!&|?{};+%-*%%<>~^]") ~= nil
    if not ok then
      local w = before:match("([%a_]+)%s*$")
      ok = w ~= nil and regex_prev_words[w] == true and not before:find("[%.]%s*" .. w .. "%s*$")
    end
    if not ok then
      return nil
    end
    local k, in_class = j + 1, false
    while k <= #line do
      local ch = line:sub(k, k)
      if ch == "\\" then
        k = k + 1
      elseif ch == "[" then
        in_class = true
      elseif ch == "]" then
        in_class = false
      elseif ch == "/" and not in_class then
        return { len = k - j + 1, k = "skip" }
      end
      k = k + 1
    end
  end,
}

specials.tex_verb = {
  trig = "\\",
  match = function(line, j)
    local s, e, d = line:find("^\\verb%*?([^%a%s*])", j)
    if not s then
      return nil
    end
    local c = line:find(d, e + 1, true)
    return { len = (c or #line) - j + 1, k = "skip" }
  end,
}

specials.pg_dollar = {
  trig = "$",
  match = function(line, j, ctx)
    if is_word(line:sub(j - 1, j - 1)) then
      return nil
    end
    local s, e, tag = line:find("^%$([%a_]?[%w_]*)%$", j)
    if s and not ctx.inner then
      return { len = e - j + 1, k = "string", close = "$" .. tag .. "$", ml = true }
    end
  end,
}

local function class_escape(ch)
  return ch:find("[%^%]%-%%]") and "%" .. ch or ch
end

local prepared = setmetatable({}, { __mode = "k" })

local function prepare(spec)
  local p = prepared[spec]
  if p then
    return p
  end
  p = { tokens = {}, closers = {}, specials = {} }
  local first = {}
  local function trig(s)
    if s and s ~= "" then
      first[s:sub(1, 1)] = true
    end
  end
  for _, m in ipairs(spec.line or {}) do
    table.insert(p.tokens, { k = "line", open = m })
    trig(m)
  end
  for _, b in ipairs(spec.block or {}) do
    table.insert(p.tokens, { k = "block", open = b[1], close = b[2], nest = b.nest, decor = b.decor, bol = b.bol, extra = b.extra })
    trig(b[1])
    if spec.stray_close and not b.bol then
      table.insert(p.closers, b[2])
      trig(b[2])
    end
  end
  for _, s in ipairs(spec.strings or {}) do
    table.insert(p.tokens, {
      k = "string", open = s[1], close = s[2], esc = s.esc, dbl = s.dbl, ml = s.ml, nix = s.nix,
      not_after_word = s.not_after_word,
    })
    trig(s[1])
  end
  for _, name in ipairs(spec.specials or {}) do
    local sp = assert(specials[name], "smart_comment: unknown special " .. name)
    table.insert(p.specials, sp)
    for ch in sp.trig:gmatch(".") do
      first[ch] = true
    end
  end
  for _, rg in ipairs(spec.regions or {}) do
    if rg.open then
      p.has_tag_regions = true
      first["<"] = true
    elseif rg.fence then
      p.fence = true
    end
  end
  local cls = {}
  for ch in pairs(first) do
    table.insert(cls, class_escape(ch))
  end
  p.trig = #cls > 0 and "[" .. table.concat(cls) .. "]" or nil
  prepared[spec] = p
  return p
end

-- number of consecutive `ch` right before column j
local function count_before(line, j, ch)
  local n, k = 0, j - 1
  while k >= 1 and line:sub(k, k) == ch do
    n, k = n + 1, k - 1
  end
  return n
end

-- best token starting at column j (longest opener wins; comments win ties)
local function candidate(line, j, spec, p, ctx, fnb)
  local best
  local function offer(c)
    if c and (not best or c.len > best.len) then
      best = c
    end
  end
  local inner = ctx.inner
  local before = line:sub(j - 1, j - 1)
  for _, t in ipairs(p.tokens) do
    local n = #t.open
    if line:sub(j, j + n - 1) == t.open then
      local ok = true
      if t.k == "line" then
        local extra = spec.line_extra and line:match("^" .. spec.line_extra, j + n) or ""
        if spec.bol_only and j ~= fnb then
          if inner then
            -- clean_body only drops a marker that opens the (trimmed) text, never one buried
            -- inside it: an off-bol `"` there is comment text, not a redundant marker
            ok = false
          else
            -- vimscript: a `"` off the first column is still a trailing comment when it is
            -- preceded by whitespace and can't be a string opener (no later `"` to close it)
            ok = is_ws(before) and not line:find(t.open, j + n, true)
          end
        end
        if ok and spec.line_boundary and j > 1 and not before:find(spec.line_boundary) then
          ok = false
        elseif ok and spec.escape_char and count_before(line, j, spec.escape_char) % 2 == 1 then
          ok = false
        elseif ok and spec.not_followed and spec.not_followed[t.open] and line:find(spec.not_followed[t.open], j + n) then
          ok = false
        elseif ok and inner and not (is_ws(before) and is_ws(line:sub(j + n + #extra, j + n + #extra))) then
          ok = false
        end
        if ok then
          offer({ len = n, k = "line", open = t.open })
        end
      elseif t.k == "block" then
        if t.bol and not (j == 1 and is_ws(line:sub(j + n, j + n))) then
          ok = false
        elseif inner and not (is_ws(before) and is_ws(line:sub(j + n, j + n))) then
          ok = false
        end
        if ok then
          offer({
            len = n, k = "block", open = t.open, close = t.close, nest = t.nest, decor = t.decor, bol = t.bol,
            extra = t.extra,
          })
        end
      else
        if t.not_after_word and is_word(before) then
          ok = false
        elseif inner and not line:find(t.close, j + n, true) then
          ok = false
        end
        if ok then
          offer({ len = n, k = "string", close = t.close, esc = t.esc, dbl = t.dbl, ml = t.ml, nix = t.nix })
        end
      end
    end
  end
  for _, sp in ipairs(p.specials) do
    if sp.trig:find(line:sub(j, j), 1, true) then
      local c = sp.match(line, j, ctx)
      if c and inner and c.k == "string" and not line:find(c.close, j + c.len, true) then
        c = nil
      end
      if c and inner and c.k == "block" and not (is_ws(before) and is_ws(line:sub(j + c.len, j + c.len))) then
        c = nil
      end
      offer(c)
    end
  end
  for _, cl in ipairs(p.closers) do
    if line:sub(j, j + #cl - 1) == cl then
      if not inner or (is_ws(before) and is_ws(line:sub(j + #cl, j + #cl))) then
        offer({ len = #cl, k = "stray" })
      end
    end
  end
  if p.has_tag_regions and not inner then
    for _, rg in ipairs(spec.regions) do
      if rg.open then
        local s, e = line:find("^" .. rg.open, j)
        if s then
          offer({ len = e - j + 1, k = "region", region = rg })
        end
      end
    end
  end
  return best
end

function M.scan(lines, root, opts)
  opts = opts or {}
  local ctx = { inner = opts.inner }
  local specs = opts.inner and nil or require("smart_comment.specs")
  local res = { comments = {}, pieces = {}, row_spec = {} }
  local stack = { { spec = root } }
  local st = { mode = "code" }
  local last = math.min(opts.stop or #lines, #lines)

  local function finish(r, e, closed)
    local c = st.cm
    local piece = {
      k = "comment", c = c, s = st.pstart, e = e, open = r == c.sr, close = closed,
      dstart = st.dstart, dend = closed and 0 or st.depth,
    }
    table.insert(res.pieces[r], piece)
    c.rows[r] = piece
    c.er, c.ec = r, e
    c.closed = closed
    st.mode, st.cm = "code", nil
  end

  local function start_comment(r, j, kind, cand, spec)
    local c = {
      kind = kind, spec = spec, open = cand.open, close = cand.close, nest = cand.nest,
      decor = cand.decor, bol = cand.bol, extra = cand.extra, sr = r, sc = j, rows = {},
    }
    table.insert(res.comments, c)
    st.cm, st.pstart, st.dstart, st.depth = c, j, 0, 1
    st.mode = kind
    return c
  end

  -- process line[i..lim] in the current region; returns the next column
  local function scan_range(line, r, i, lim, spec, fnb)
    local p = prepare(spec)
    while i <= lim do
      if st.mode == "block" then
        local c = st.cm
        if c.bol then
          if i == 1 and line:find("^" .. vim.pesc(c.close)) then
            finish(r, #line, true)
          end
          i = lim + 1
        else
          local cs, ce = line:find(c.close, i, true)
          if cs and ce > lim then
            cs = nil
          end
          local os_ = c.nest and line:find(c.open, i, true) or nil
          if os_ and os_ + #c.open - 1 > lim then
            os_ = nil
          end
          if os_ and (not cs or os_ < cs) then
            st.depth = st.depth + 1
            i = os_ + #c.open
          elseif cs then
            st.depth = st.depth - 1
            i = ce + 1
            if st.depth == 0 then
              finish(r, ce, true)
            end
          else
            i = lim + 1
          end
        end
      elseif st.mode == "string" then
        local s = st.str
        local k, closed = i, nil
        while k <= lim do
          local ch = line:sub(k, k)
          if s.esc and ch == s.esc then
            k = k + 2
          elseif s.nix and line:sub(k, k + 1) == "''" then
            local nx = line:sub(k + 2, k + 2)
            if nx == "'" or nx == "$" then
              k = k + 3
            elseif nx == "\\" then
              k = k + 4
            else
              closed = k + 1
              break
            end
          elseif line:sub(k, k + #s.close - 1) == s.close then
            if s.dbl and line:sub(k + #s.close, k + 2 * #s.close - 1) == s.close then
              k = k + 2 * #s.close
            else
              closed = k + #s.close - 1
              break
            end
          else
            k = k + 1
          end
        end
        if closed then
          st.mode, st.str = "code", nil
          i = closed + 1
        else
          i = lim + 1
        end
      elseif st.mode == "line" then
        i = lim + 1
      else -- code
        local j = p.trig and line:find(p.trig, i)
        if not j or j > lim then
          break
        end
        local cand = candidate(line, j, spec, p, ctx, fnb)
        if not cand then
          i = j + 1
        elseif cand.k == "line" then
          start_comment(r, j, "line", cand, spec)
          local stop
          for _, t in ipairs(spec.line_end or {}) do
            local q = line:find(t, j + cand.len, true)
            if q and q <= lim and (not stop or q < stop) then
              stop = q
            end
          end
          if stop then
            finish(r, stop - 1, true)
            i = stop
          else
            i = lim + 1
          end
        elseif cand.k == "block" then
          start_comment(r, j, "block", cand, spec)
          i = cand.bol and lim + 1 or j + cand.len
        elseif cand.k == "string" then
          st.mode, st.str = "string", cand
          i = j + cand.len
        elseif cand.k == "heredoc" then
          st.pending_hd = cand
          i = j + cand.len
        elseif cand.k == "stray" then
          table.insert(res.pieces[r], { k = "stray", s = j, e = j + cand.len - 1 })
          i = j + cand.len
        elseif cand.k == "region" then
          local rg = cand.region
          table.insert(stack, { spec = specs.get(rg.lang) or { name = "text" }, close = rg.close })
          return j + cand.len, true
        else -- skip
          i = j + cand.len
        end
      end
    end
    return math.max(i, lim + 1)
  end

  local pending_region
  for r = 1, last do
    local line = lines[r]
    res.pieces[r] = {}
    if pending_region then
      table.insert(stack, pending_region)
      pending_region = nil
    end
    local fnb = line:find("%S") or (#line + 1)
    res.row_spec[r] = stack[#stack].spec
    if st.mode == "block" or st.mode == "line" then
      st.pstart, st.dstart = 1, st.depth
    end

    if st.mode == "heredoc" then
      local hd = st.hd
      local body = hd.strip and line:gsub(hd.strip, "", 1) or line
      if body == hd.delim or (hd.loose and body:find("^" .. hd.delim .. "[^%w_]")) then
        st.mode, st.hd = "code", nil
      end
      goto next_row
    end

    if r == 1 and not opts.inner and not opts.no_shebang and root.shebang and line:find("^#!")
        and not (root.shebang == "rust" and line:find("^#!%[")) then
      goto next_row
    end

    do
      local top = stack[#stack]
      local tp = prepare(top.spec)
      if st.mode == "code" and tp.fence and not opts.inner then
        local fence, info = line:match("^%s*([`~][`~][`~]+)%s*([^%s`{]*)")
        local ch = fence and fence:sub(1, 1)
        if fence and fence == ch:rep(#fence) then
          pending_region = {
            spec = specs.fence(info),
            close = "^%s*" .. ch:rep(#fence) .. ch .. "*%s*$",
            fence = true,
          }
          goto next_row
        end
      end
    end

    do
      local i = 1
      while true do
        local top = stack[#stack]
        local lim, rc_s, rc_e = #line, nil, nil
        if top.close then
          if top.fence then
            if i == 1 and line:find(top.close) then
              rc_s, rc_e = 1, #line
            end
          else
            rc_s, rc_e = line:find(top.close, i)
          end
          if rc_s then
            lim = rc_s - 1
          end
        end
        local pushed
        i, pushed = scan_range(line, r, i, lim, top.spec, fnb)
        if not pushed then
          if not rc_s then
            break
          end
          if st.mode == "block" or st.mode == "line" then
            finish(r, lim, false)
          end
          st.mode, st.str = "code", nil
          table.remove(stack)
          if rc_s <= fnb then
            res.row_spec[r] = stack[#stack].spec
          end
          i = rc_e + 1
        end
      end
    end

    if st.mode == "line" then
      if st.cm.spec.line_splice and line:sub(-1) == "\\" and not opts.inner then
        local piece = { k = "comment", c = st.cm, s = st.pstart, e = #line, open = r == st.cm.sr, close = false, dstart = 0, dend = 1 }
        table.insert(res.pieces[r], piece)
        st.cm.rows[r] = piece
      else
        finish(r, #line, true)
      end
    elseif st.mode == "block" then
      local c = st.cm
      local piece = { k = "comment", c = c, s = st.pstart, e = #line, open = r == c.sr, close = false, dstart = st.dstart, dend = st.depth }
      table.insert(res.pieces[r], piece)
      c.rows[r] = piece
      c.er, c.ec = r, #line
    elseif st.mode == "string" and (not st.str.ml or opts.inner) then
      st.mode, st.str = "code", nil
    end
    if st.pending_hd then
      st.mode, st.hd, st.pending_hd = "heredoc", st.pending_hd, nil
    end

    ::next_row::
  end
  return res
end

return M
