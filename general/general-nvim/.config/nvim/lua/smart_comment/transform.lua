-- Pure line transformation for smart_comment (no buffer access).
local lexer = require("smart_comment.lexer")

local M = {}

local function rtrim(s)
  return (s:gsub("%s+$", ""))
end

local function rep(s, n, sep)
  local t = {}
  for i = 1, n do
    t[i] = s
  end
  return table.concat(t, sep or "")
end

local clean_body

-- Column right after an opener's marker and any decoration chars that follow it (line_extra for
-- line markers, or a block's `extra` for block markers, e.g. the extra `*` in `/**`).
local function after_open(line, pos, c)
  local b = pos + #c.open
  if c.kind == "line" and c.spec.line_extra then
    b = b + #(line:match("^" .. c.spec.line_extra, b) or "")
  elseif c.kind == "block" and c.extra then
    b = b + #(line:match("^" .. c.extra, b) or "")
  end
  return b
end

-- Remove all comment markers and stray closers described by `pcs` from `line`.
-- `decor` strips the leading ` * ` decoration of block-comment continuation rows.
local function strip_pieces(line, pcs, depth, decor)
  local out, pos = {}, 1
  for _, p in ipairs(pcs) do
    local code = line:sub(pos, p.s - 1)
    if p.k == "stray" then
      if code:find("^%s*$") then
        table.insert(out, code)
        pos = p.e + 1
        if line:sub(pos, pos) == " " then
          pos = pos + 1
        end
      else
        table.insert(out, (code:gsub(" $", "", 1)))
        pos = p.e + 1
      end
    else
      local c = p.c
      local b_s, b_e = p.s, p.e
      if p.open then
        b_s = after_open(line, p.s, c)
        if line:sub(b_s, b_s) == " " then
          b_s = b_s + 1
        end
      end
      if p.close and c.kind == "block" then
        b_e = p.e - #c.close
        if c.spec.close_prefix then
          local pre = line:sub(b_s, b_e):match("(" .. c.spec.close_prefix .. ")$")
          if pre then
            b_e = b_e - #pre
          end
        end
        if b_e >= b_s and line:sub(b_e, b_e) == " " then
          b_e = b_e - 1
        end
      end
      local body = line:sub(b_s, b_e)
      if decor and not p.open and c.decor then
        local ws, rest = body:match("^(%s*)(.*)$")
        if rest:sub(1, 1) == c.decor and rest:sub(2, 2) ~= "/" then
          rest = rest:sub(2):gsub("^ ", "", 1)
          if #ws > 0 and #ws == (c.open_indent or 0) + 1 then
            ws = ws:sub(2)
          end
          body = ws .. rest
        end
      end
      table.insert(out, code)
      table.insert(out, clean_body(body, c.spec, depth))
      pos = p.e + 1
    end
  end
  table.insert(out, line:sub(pos))
  return table.concat(out)
end

-- Remove redundant markers inside comment text (`a // b` -> `a b`), string-aware.
function clean_body(text, spec, depth)
  depth = depth or 0
  if depth > 8 or not text:find("%S") then
    return text
  end
  local lead = text:match("^%s*")
  local res = lexer.scan({ text:sub(#lead + 1) }, spec, { inner = true })
  local pcs = res.pieces[1] or {}
  if #pcs == 0 then
    return text
  end
  return lead .. strip_pieces(text:sub(#lead + 1), pcs, depth + 1, false)
end

M.clean_body = clean_body
M.strip_pieces = strip_pieces

local function code_outside(line, pcs)
  local out, pos = {}, 1
  for _, p in ipairs(pcs) do
    table.insert(out, line:sub(pos, p.s - 1))
    pos = p.e + 1
  end
  table.insert(out, line:sub(pos))
  return table.concat(out)
end

-- gcs on a row that is only comment: keep the delimiters, drop redundant inner markers / strays.
local function normalize_row(line, pcs)
  local out, pos, changed = {}, 1, false
  for _, p in ipairs(pcs) do
    table.insert(out, line:sub(pos, p.s - 1))
    if p.k == "stray" then
      out[#out] = out[#out]:gsub(" $", "", 1)
      changed = true
      pos = p.e + 1
    else
      local c = p.c
      local b_s, b_e = p.s, p.e
      if p.open then
        b_s = after_open(line, p.s, c)
      end
      if p.close and c.kind == "block" then
        b_e = p.e - #c.close
      end
      local body = line:sub(b_s, b_e)
      local lead, trail = body:match("^%s*"), body:match("%s*$")
      if #lead < #body then
        local mid = body:sub(#lead + 1, #body - #trail)
        local new = clean_body(mid, c.spec, 0)
        if new ~= mid then
          changed = true
          if new == "" then
            trail = p.close and trail or ""
          end
          body = lead .. new .. trail
        end
      end
      table.insert(out, line:sub(p.s, b_s - 1) .. body .. line:sub(b_e + 1, p.e))
      pos = p.e + 1
    end
  end
  table.insert(out, line:sub(pos))
  if not changed then
    return nil
  end
  return rtrim(table.concat(out))
end

-- byte offset after the leading whitespace whose display width is <= col
local function insert_at(text, col, width)
  local k = 0
  local ws = text:match("^%s*")
  for n = 1, #ws do
    if width(ws:sub(1, n)) > col then
      break
    end
    k = n
  end
  return k
end

local function add_marker(text, k, spec)
  if spec.line then
    return text:sub(1, k) .. spec.line[1] .. " " .. text:sub(k + 1)
  end
  local b = spec.block[1]
  return text:sub(1, k) .. b[1] .. " " .. text:sub(k + 1) .. " " .. b[2]
end

local function has_syntax(spec)
  return spec and (spec.line or spec.block) and true or false
end

--- ctx: {
---   lines      all buffer lines (1-based)
---   s, e       selected rows
---   action     "comment" | "uncomment"
---   pieces     pieces[row] (rows s-1 .. e+1 at least)
---   row_spec   row_spec[row]
---   root       spec of the buffer
---   protected  fun(row): boolean
---   width      fun(str): display width
--- }
--- Returns { new = {[row] = string|false}, before = {[row] = {...}}, after = {[row] = {...}} } or nil.
function M.run(ctx)
  local L, s, e = ctx.lines, ctx.s, ctx.e
  local width = ctx.width or function(str)
    return #str
  end
  local new, before, after = {}, {}, {}
  local function pieces(r)
    return ctx.pieces[r] or {}
  end
  local function comment_pieces(r)
    local t = {}
    for _, p in ipairs(pieces(r)) do
      if p.k == "comment" then
        table.insert(t, p)
      end
    end
    return t
  end
  local function row_spec(r)
    local sp = ctx.row_spec[r]
    if has_syntax(sp) then
      return sp
    end
    return ctx.root
  end
  -- remember the indentation of every block opener (used to strip ` * ` decoration)
  for r = math.max(1, s - 1), math.min(#L, e + 1) do
    for _, p in ipairs(pieces(r)) do
      if p.k == "comment" and not p.c.open_indent and L[p.c.sr] then
        p.c.open_indent = #L[p.c.sr]:match("^%s*")
      end
    end
  end

  local sel = {}
  for r = s, e do
    if not ctx.protected(r) and L[r]:find("%S") then
      table.insert(sel, r)
    end
  end
  if #sel == 0 then
    return nil
  end

  local mode = "strip"
  if ctx.action == "comment" then
    mode = "normalize"
    for _, r in ipairs(sel) do
      if code_outside(L[r], pieces(r)):find("%S") then
        mode = "rebuild"
        break
      end
    end
  end

  if mode == "normalize" then
    for _, r in ipairs(sel) do
      local pcs = pieces(r)
      local cps = comment_pieces(r)
      local self_contained = #cps >= 2
      for _, p in ipairs(cps) do
        if not (p.open and (p.close or p.c.kind == "line") and p.c.closed ~= false) then
          self_contained = false
        end
      end
      if self_contained then
        local txt = rtrim(strip_pieces(L[r], pcs, 0, false))
        local k = #txt:match("^%s*")
        local out = add_marker(txt, k, row_spec(r))
        if out ~= L[r] then
          new[r] = out
        end
      else
        new[r] = normalize_row(L[r], pcs)
      end
    end
    return { new = new, before = before, after = after }
  end

  -- strip (gcr) / rebuild (gcs on rows containing code)
  for _, r in ipairs(sel) do
    local pcs = pieces(r)
    if mode == "rebuild" or #pcs > 0 then
      local out = rtrim(strip_pieces(L[r], pcs, 0, true))
      if out == "" then
        new[r] = false
      elseif out ~= L[r] then
        new[r] = out
      end
    end
  end

  -- block comments crossing the selection edges: close them above / reopen them below
  local first, last = sel[1], sel[#sel]
  local function text(r)
    local t = new[r]
    if t == nil then
      return L[r]
    end
    return t or ""
  end
  local top_done, bottom_done = {}, {}
  for _, p in ipairs(comment_pieces(first)) do
    local c = p.c
    local a = first - 1
    local pa = c.rows[a]
    if c.kind == "block" and c.sr < first and pa and not top_done[c] and not ctx.protected(a) then
      top_done[c] = true
      local txt = text(a)
      local depth = math.max(pa.dend, 1)
      local rest = pa.open and txt:sub(after_open(txt, pa.s, c)) or txt:sub(pa.s)
      if c.bol then
        if pa.open and not rest:find("%S") then
          new[a] = false
        else
          after[a] = { c.close }
        end
      elseif pa.open and depth == 1 and not rest:find("%S") then
        local out = rtrim(txt:sub(1, pa.s - 1))
        new[a] = out ~= "" and out or false
      elseif not pa.open and c.decor and rest:find("^%s*%" .. c.decor .. "?%s*$") then
        new[a] = txt:match("^%s*") .. rep(c.close, depth, " ")
      else
        new[a] = rtrim(txt) .. " " .. rep(c.close, depth, " ")
      end
    end
  end
  for _, p in ipairs(comment_pieces(last)) do
    local c = p.c
    local b = last + 1
    local pb = c.rows[b]
    if c.kind == "block" and pb and not bottom_done[c] then
      bottom_done[c] = true
      local txt = L[b]
      local depth = math.max(pb.dstart, 1)
      local inner_txt = pb.close and txt:sub(pb.s, pb.e - #c.close) or nil
      if inner_txt and c.spec.close_prefix then
        inner_txt = inner_txt:gsub(c.spec.close_prefix .. "$", "")
      end
      local marker_only = inner_txt and depth == 1
        and (inner_txt:find("^%s*$") or (c.decor and inner_txt:find("^%s*%" .. c.decor .. "%s*$")))
      if c.bol then
        if pb.close and not txt:find("%S", #c.close + 1) then
          new[b] = false
        else
          before[b] = { c.open }
        end
      elseif marker_only then
        local indent = txt:match("^%s*")
        local rest = txt:sub(pb.e + 1):gsub("^%s+", "")
        new[b] = rest ~= "" and indent .. rest or false
      else
        local ws, rest = txt:match("^(%s*)(.*)$")
        if c.decor and rest:sub(1, 1) == c.decor and rest:sub(2, 2) ~= "/" then
          rest = rest:sub(2):gsub("^ ", "", 1)
        end
        new[b] = ws .. rep(c.open, depth, " ") .. " " .. rest
      end
    end
  end

  if mode == "rebuild" then
    local rows, col = {}, math.huge
    for _, r in ipairs(sel) do
      local t = text(r)
      if new[r] ~= false and t:find("%S") then
        table.insert(rows, r)
        col = math.min(col, width(t:match("^%s*")))
      end
    end
    for _, r in ipairs(rows) do
      local t = text(r)
      local out = add_marker(t, insert_at(t, col, width), row_spec(r))
      new[r] = out ~= L[r] and out or nil
    end
  end
  return { new = new, before = before, after = after }
end

return M
