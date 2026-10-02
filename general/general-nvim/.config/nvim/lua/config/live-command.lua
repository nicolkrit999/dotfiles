require("live-command").setup {
  enable_highlighting = true,
  inline_highlighting = true,
  commands = {
    Norm = { cmd = "norm" },
  },
}

-- True when `prefix` (the command line before the typed word) ends where an Ex command name
-- may start: empty, after a range, after `|`, or after `:g/pat/` / `:v/pat/` (so the
-- `:g/x/norm` preview keeps working), or after command modifiers (`:silent! norm`,
-- `:keeppatterns %norm`, `:3verbose norm`). Text such as `let g:x='a ` is not a command position.
-- modifier -> shortest abbreviation
local modifiers = {
  silent = 3, unsilent = 3, keepjumps = 5, keeppatterns = 5, keepmarks = 3, keepalt = 5,
  lockmarks = 3, noautocmd = 3, verbose = 4, vertical = 4, horizontal = 3, aboveleft = 3,
  belowright = 3, botright = 2, topleft = 2, leftabove = 5, rightbelow = 6, tab = 3,
  hide = 3, confirm = 4, browse = 3, sandbox = 3, noswapfile = 3,
}

---@param s string
---@return string? rest of `s` after one leading modifier word (with optional `!`)
local function strip_modifier(s)
  local word, bang, rest = s:match("^%s*(%a+)(!?)(.*)$")
  if not word or (bang == "" and not rest:match("^%s")) then
    return nil
  end
  for name, min in pairs(modifiers) do
    if #word >= min and name:sub(1, #word) == word then
      return rest
    end
  end
  return nil
end

local function in_command_position(prefix)
  local seg = prefix:match("[^|]*$"):gsub("^[%s:]+", "")
  while true do
    -- ranges / counts: numbers, . $ % , ; + - < > and 'x marks
    local rest = seg:gsub("^%s*[%d,;%.%$%%<>%+%-]+", ""):gsub("^%s*'.", "")
    rest = strip_modifier(rest) or rest
    if rest ~= seg then
      seg = rest
    else
      local delim = seg:match("^%s*[gv]!?%s*([^%w%s\"|])")
      if not delim then
        break
      end
      local after = seg:gsub("^%s*[gv]!?%s*", "")
      local close = after:find(delim, 2, true)
      while close and after:sub(close - 1, close - 1) == "\\" do
        close = after:find(delim, close + 1, true)
      end
      if not close then
        return false
      end
      seg = after:sub(close + 1)
    end
  end
  return seg:match("^%s*$") ~= nil
end

-- `norm` -> `Norm` (live preview) only when typed as a command, never inside strings/patterns
vim.keymap.set("ca", "norm", function()
  if vim.fn.getcmdtype() ~= ":" then
    return "norm"
  end
  -- the typed word itself is already in the line: drop it to get the text before it
  local before = vim.fn.getcmdline():sub(1, vim.fn.getcmdpos() - 1):sub(1, -5)
  return in_command_position(before) and "Norm" or "norm"
end, { expr = true, desc = "Command-line: norm -> Norm (live preview)" })
