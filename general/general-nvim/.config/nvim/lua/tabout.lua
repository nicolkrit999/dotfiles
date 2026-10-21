-- Insert mode: <Tab> jumps out past the closing bracket / quote of the pair the cursor is in,
-- <S-Tab> jumps back to before its opening one. Plain text scan of the current line (no parser
-- needed): every opener is pushed on a stack, a closer pops to its opener, so nesting, several
-- closers on one line and multi-character delimiters ([[ ]], '' '', $(( )), \( \), **) work.
-- With nothing to jump out of, <Tab> is a normal tab (nvim-cmp's <Tab> falls back to this map).

local M = {}

local WORD = "[%w_\128-\255]"

local function is_word(ch)
  return ch ~= "" and ch:match(WORD) ~= nil
end

local function at(line, i)
  return line:sub(i, i)
end

-- pair fields: open, close, str (contents are opaque text: only interp pairs open inside),
-- interp (may open inside a str pair), ok_open/ok_close(line, i, token) to refuse a lookalike
local function pair(open, close, extra)
  return vim.tbl_extend("force", { open = open, close = close }, extra or {})
end

-- an apostrophe inside a word (don't) is not a quote
local function quote_open(line, i)
  return not is_word(at(line, i - 1))
end
local function quote_close(line, i, tok)
  return not is_word(at(line, i + #tok))
end
-- emphasis markers (* _ **): open before text, close after text
local function emph_open(line, i, tok)
  local nxt = at(line, i + #tok)
  return nxt ~= "" and not nxt:match("%s") and (tok:sub(1, 1) ~= "_" or not is_word(at(line, i - 1)))
end
local function emph_close(line, i, tok)
  local prv = at(line, i - 1)
  return prv ~= "" and not prv:match("%s") and (tok:sub(1, 1) ~= "_" or not is_word(at(line, i + #tok)))
end
-- template / generic brackets: Name<T>, std::vector<int>, #include <x.h> (not "a < b")
local function angle_open(line, i)
  return is_word(at(line, i - 1)) or line:sub(1, i - 1):match("^%s*#%s*include%s*$") ~= nil
end

local base = {
  pair("(", ")"),
  pair("[", "]"),
  pair("{", "}"),
  pair('"', '"', { str = true }),
  pair("'", "'", { str = true, ok_open = quote_open, ok_close = quote_close }),
  pair("`", "`", { str = true }),
}

local function with(extra)
  local t = vim.list_extend({}, base)
  return vim.list_extend(t, extra)
end

local sh = with {
  pair("$((", "))"),
  pair("$(", ")", { interp = true }),
  pair("${", "}", { interp = true }),
  pair("[[", "]]"),
}
local tex = with {
  pair("$$", "$$"),
  pair("$", "$"),
  pair("\\(", "\\)"),
  pair("\\[", "\\]"),
  pair("\\left(", "\\right)"),
  pair("\\left[", "\\right]"),
}
local markup = with {
  pair("**", "**", { ok_open = emph_open, ok_close = emph_close }),
  pair("~~", "~~", { ok_open = emph_open, ok_close = emph_close }),
  pair("*", "*", { ok_open = emph_open, ok_close = emph_close }),
  pair("_", "_", { ok_open = emph_open, ok_close = emph_close }),
}
local angle = with { pair("<", ">", { ok_open = angle_open }) }

local specs = {
  lua = with { pair("[[", "]]", { str = true }), pair("[=[", "]=]", { str = true }) },
  python = with {
    pair('"""', '"""', { str = true }),
    pair("'''", "'''", { str = true }),
    -- f-string replacement fields
    pair("{", "}", { interp = true }),
  },
  nix = with {
    pair("''", "''", { str = true }),
    pair("${", "}", { interp = true }),
  },
  sh = sh,
  bash = sh,
  zsh = sh,
  fish = with { pair("$(", ")", { interp = true }) },
  tex = tex,
  plaintex = tex,
  bib = tex,
  markdown = markup,
  typst = vim.list_extend(vim.list_extend({}, markup), { pair("$", "$") }),
  cpp = angle,
  c = base,
  java = angle,
}

local compiled = {}

-- longest token first, so "**" is tried before "*" and "$((" before "$("
local function compile(ft)
  if compiled[ft] then
    return compiled[ft]
  end
  local pairs_ = specs[ft] or base
  local tokens = {}
  for _, p in ipairs(pairs_) do
    tokens[#tokens + 1] = { tok = p.open, pair = p, is_open = true }
    if p.close ~= p.open then
      tokens[#tokens + 1] = { tok = p.close, pair = p, is_open = false }
    end
  end
  table.sort(tokens, function(a, b)
    return #a.tok > #b.tok
  end)
  compiled[ft] = { tokens = tokens, tex = specs[ft] == tex }
  return compiled[ft]
end

-- every pair that is closed on this line: { s, os, cs, ce } (1-based byte indices:
-- opener start, first byte after the opener, closer start, first byte after the closer)
local function scan(line, ft)
  local spec = compile(ft)
  local stack, closed = {}, {}
  local i, n = 1, #line
  while i <= n do
    local top = stack[#stack]
    local hit
    for _, t in ipairs(spec.tokens) do
      if line:sub(i, i + #t.tok - 1) == t.tok then
        local p = t.pair
        -- a closer: nearest stack entry of that pair (only the top one while inside a string)
        local depth
        for d = #stack, 1, -1 do
          if stack[d].pair == p then
            depth = d
            break
          end
          if stack[d].pair.str then
            break
          end
        end
        local is_closer = not t.is_open or p.open == p.close
        -- a string only closes at the top of the stack (a quote inside "$( ... )" opens a new string)
        if depth and p.str and depth ~= #stack then
          depth = nil
        end
        if depth and is_closer and (p.ok_close == nil or p.ok_close(line, i, t.tok)) then
          for d = #stack, depth + 1, -1 do
            stack[d] = nil
          end
          local entry = table.remove(stack)
          closed[#closed + 1] = { s = entry.s, os = entry.os, cs = i, ce = i + #t.tok }
          hit = #t.tok
          break
        end
        -- an opener (inside a string only interpolation pairs open)
        if t.is_open and (not (top and top.pair.str) or p.interp) and (p.ok_open == nil or p.ok_open(line, i, t.tok)) then
          stack[#stack + 1] = { pair = p, s = i, os = i + #t.tok }
          hit = #t.tok
          break
        end
      end
    end
    if hit then
      i = i + hit
    elseif at(line, i) == "\\" and (not spec.tex or not at(line, i + 1):match("%a")) then
      i = i + 2 -- escaped character
    else
      i = i + 1
    end
  end
  return closed
end

-- target column (0-based byte index) for the cursor, or nil
local function target(forward)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
  local p = col + 1
  local best
  for _, c in ipairs(scan(line, vim.bo.filetype)) do
    local inside = c.os <= p and p <= (forward and c.cs or c.ce)
    if inside and (not best or c.os > best.os) then
      best = c
    end
  end
  if not best then
    return nil
  end
  return row, forward and best.ce - 1 or best.s - 1
end

function M.forward()
  local row, col = target(true)
  if row then
    vim.api.nvim_win_set_cursor(0, { row, col })
  else
    vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "ni", false)
  end
end

function M.backward()
  local row, col = target(false)
  if row then
    vim.api.nvim_win_set_cursor(0, { row, col })
  end
end

-- exposed for the test driver
M._scan = scan

vim.keymap.set("i", "<Tab>", "<Cmd>lua require('tabout').forward()<CR>", { desc = "Tabout: jump past the closing bracket or quote" })
vim.keymap.set("i", "<S-Tab>", "<Cmd>lua require('tabout').backward()<CR>", { desc = "Tabout: jump back before the opening bracket or quote" })

return M
