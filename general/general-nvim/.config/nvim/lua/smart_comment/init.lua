-- Smart comment / uncomment (gcs / gcr), no plugins.
--
-- gcs: rows with code become comments (one marker per row, aligned at the minimum indent); misplaced
--      or redundant markers are removed first. Rows that are already comments are left as they are,
--      apart from dropping redundant inner markers.
-- gcr: every comment marker in the rows is removed, turning them back into code.
--
-- Comments are located with tree-sitter when a parser for the buffer is available, otherwise with a
-- string-aware lexer (lexer.lua, per-language syntax in specs.lua). The rewrite itself is transform.lua.
local specs = require("smart_comment.specs")
local lexer = require("smart_comment.lexer")
local transform = require("smart_comment.transform")

local M = {}

-- Comments via tree-sitter: nodes locate the comments, the lexer re-reads each node's text to find
-- its delimiters (and validates that the node really is a comment of that language).
local function ts_collect(buf, lines, lo, hi, root)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, nil, { error = false })
  if not ok or not parser or not specs.get(parser:lang()) then
    return nil
  end
  if not pcall(parser.parse, parser, { lo - 1, hi }) then
    return nil
  end
  local res = { pieces = {}, row_spec = {} }
  for r = lo, hi do
    res.pieces[r] = {}
  end
  local seen = {}

  local function add(node, spec)
    local sr, sc, er, ec = node:range()
    if ec == 0 and er > sr then
      er = er - 1
      ec = #lines[er + 1]
    end
    local key = sr .. ":" .. sc
    if seen[key] then
      return
    end
    seen[key] = true
    local ok_text, text = pcall(vim.api.nvim_buf_get_text, buf, sr, sc, er, ec, {})
    if not ok_text or #text == 0 then
      return
    end
    local scan = lexer.scan(text, spec, { no_shebang = true })
    -- Usually the node is exactly one comment. Some grammars (tree-sitter-haskell) merge several
    -- adjacent single-line comments into one node; accept that too, as long as `scan` fully
    -- explains the node's text (comments + whitespace only, no real code slipped in).
    if #scan.comments == 0 then
      return
    end
    local last = scan.comments[#scan.comments]
    if scan.comments[1].sr ~= 1 or scan.comments[1].sc ~= 1 or last.er ~= #text or last.ec ~= #text[#text] then
      return
    end
    local prev_er = 0
    for _, cm in ipairs(scan.comments) do
      if cm.sr ~= prev_er + 1 then
        return -- a gap between comments means real code between them: bail, don't guess
      end
      prev_er = cm.er
    end
    for _, c in ipairs(scan.comments) do
      local rows = {}
      for k, p in pairs(c.rows) do
        local r = sr + k
        if k == 1 then
          p.s, p.e = p.s + sc, p.e + sc
        end
        rows[r] = p
        if res.pieces[r] then
          table.insert(res.pieces[r], p)
        end
      end
      c.rows, c.sr, c.er = rows, sr + c.sr, sr + c.er
    end
  end

  -- Node type names that are comments but don't spell "comment" (sql's tree-sitter grammar calls
  -- its /* */ block comment "marginalia").
  local extra_comment_types = { marginalia = true }

  -- Only follow an injected-language subtree (e.g. bash inside a shell heredoc, javascript inside
  -- html's <script>) when the host spec explicitly opted into it via `regions`. Otherwise a language
  -- injected purely for syntax highlighting inside what the host spec treats as an opaque STRING
  -- (e.g. julia's backtick command literals inject bash, but julia's own spec already lists
  -- backtick-strings as opaque) would incorrectly surface that child language's own comment rules.
  local ok_host, host_parser = pcall(vim.treesitter.get_parser, buf, nil, { error = false })
  local host_lang = ok_host and host_parser and host_parser:lang() or nil
  local host_spec = host_lang and specs.get(host_lang) or root
  local allowed_injections = { [host_lang] = true }
  for _, rg in ipairs(host_spec.regions or {}) do
    if rg.lang then
      allowed_injections[rg.lang] = true
    end
  end

  parser:for_each_tree(function(tree, ltree)
    local lang = ltree:lang()
    if not allowed_injections[lang] then
      return
    end
    local spec = specs.get(lang)
    if not spec then
      return
    end
    local function visit(node)
      for child in node:iter_children() do
        local sr, _, er = child:range()
        if er + 1 >= lo and sr + 1 <= hi then
          local ty = child:type():lower()
          if ty:find("comment", 1, true) or extra_comment_types[ty] then
            add(child, spec)
          elseif child:child_count() > 0 then
            visit(child)
          end
        end
      end
    end
    visit(tree:root())
  end)

  for r = lo, hi do
    local line = lines[r]
    local fnb = (line:find("%S") or 1) - 1
    local ok_l, lt = pcall(parser.language_for_range, parser, { r - 1, fnb, r - 1, fnb + 1 })
    local sp
    -- injected helper languages (comment, jsdoc, regex...) have no spec: use the host language
    while ok_l and lt and not sp do
      sp = specs.get(lt:lang())
      lt = lt:parent()
    end
    res.row_spec[r] = sp or root
    table.sort(res.pieces[r], function(a, b)
      return a.s < b.s
    end)
    -- stray block closers in the code between comments
    sp = res.row_spec[r]
    if sp.stray_close then
      local gaps, pos = {}, 1
      for _, p in ipairs(res.pieces[r]) do
        table.insert(gaps, { pos, p.s - 1 })
        pos = p.e + 1
      end
      table.insert(gaps, { pos, #line })
      for _, g in ipairs(gaps) do
        if g[2] >= g[1] then
          local sub = lexer.scan({ line:sub(g[1], g[2]) }, sp, { inner = true })
          for _, p in ipairs(sub.pieces[1]) do
            if p.k == "stray" then
              table.insert(res.pieces[r], { k = "stray", s = p.s + g[1] - 1, e = p.e + g[1] - 1 })
            end
          end
        end
      end
      table.sort(res.pieces[r], function(a, b)
        return a.s < b.s
      end)
    end
  end
  return res
end

local function is_shebang(spec, line)
  return spec.shebang and line and line:find("^#!") and not (spec.shebang == "rust" and line:find("^#!%["))
end

--- Apply "comment" or "uncomment" to rows s..e (1-based, inclusive) of buf.
--- opts.backend: "ts" | "lexer" to force a backend (tests).
function M.apply(buf, s, e, action, opts)
  opts = opts or {}
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local root = specs.for_buf(buf)
  if not root then
    vim.notify("smart_comment: no comment syntax for filetype '" .. vim.bo[buf].filetype .. "'", vim.log.levels.WARN)
    return false
  end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if s > e then
    s, e = e, s
  end
  s, e = math.max(s, 1), math.min(e, #lines)
  local lo, hi = math.max(s - 1, 1), math.min(e + 1, #lines)

  local info
  if opts.backend ~= "lexer" and root.backend ~= "lexer" then
    info = ts_collect(buf, lines, lo, hi, root)
    if not info and opts.backend == "ts" then
      error("smart_comment: no tree-sitter parser for " .. vim.bo[buf].filetype)
    end
  end
  info = info or lexer.scan(lines, root, { stop = hi })

  local out = transform.run({
    lines = lines,
    s = s,
    e = e,
    action = action,
    pieces = info.pieces,
    row_spec = info.row_spec,
    root = root,
    protected = function(r)
      return r == 1 and is_shebang(root, lines[1]) or false
    end,
    width = function(str)
      return vim.api.nvim_buf_call(buf, function()
        return vim.fn.strdisplaywidth(str)
      end)
    end,
  })
  if not out then
    return false
  end

  local first, last
  local function touch(r)
    first = math.min(first or r, r)
    last = math.max(last or r, r)
  end
  for r in pairs(out.new) do
    touch(r)
  end
  for r in pairs(out.before) do
    touch(r)
  end
  for r in pairs(out.after) do
    touch(r)
  end
  if not first then
    return false
  end
  local repl = {}
  for r = first, last do
    vim.list_extend(repl, out.before[r] or {})
    local t = out.new[r]
    if t == nil then
      table.insert(repl, lines[r])
    elseif t then
      table.insert(repl, t)
    end
    vim.list_extend(repl, out.after[r] or {})
  end
  vim.api.nvim_buf_set_lines(buf, first - 1, last, false, repl)
  return true
end

--- Run on the current line(s) (normal mode, with count) or the visual selection.
function M.run(action)
  local mode = vim.fn.mode()
  local s, e
  if mode == "v" or mode == "V" or mode == "\22" then
    s, e = vim.fn.line("v"), vim.fn.line(".")
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  else
    s = vim.fn.line(".")
    e = s + vim.v.count1 - 1
  end
  if s > e then
    s, e = e, s
  end
  local cur = vim.api.nvim_win_get_cursor(0)
  M.apply(0, s, e, action)
  local n = vim.api.nvim_buf_line_count(0)
  local row = math.min(math.max(s, math.min(cur[1], e)), n)
  pcall(vim.api.nvim_win_set_cursor, 0, { row, 0 })
  vim.cmd("normal! ^")
end

return M
