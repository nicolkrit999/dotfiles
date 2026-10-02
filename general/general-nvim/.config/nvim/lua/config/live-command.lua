require("live-command").setup {
  enable_highlighting = true,
  inline_highlighting = true,
  commands = {
    Norm = { cmd = "norm" },
  },
}

-- True when `prefix` (the command line before the typed word) ends where an Ex command name
-- may start: empty, after a range, after `|`, or after `:g/pat/` / `:v/pat/` (so the
-- `:g/x/norm` preview keeps working). Text such as `let g:x='a ` is not a command position.
local function in_command_position(prefix)
  local seg = prefix:match("[^|]*$"):gsub("^[%s:]+", "")
  while true do
    -- ranges: numbers, . $ % , ; + - < > and 'x marks
    local rest = seg:gsub("^%s*[%d,;%.%$%%<>%+%-]+", ""):gsub("^%s*'.", "")
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
