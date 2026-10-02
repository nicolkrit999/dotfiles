local api = vim.api
local keymap = vim.keymap

local hlslens = require("hlslens")

hlslens.setup {
  calm_down = true,
  nearest_only = true,
}

local activate_hlslens = function(direction)
  local cmd = string.format("normal! %s%szzzv", vim.v.count1, direction)
  local status, msg = pcall(vim.cmd, cmd)

  -- Deal with the case that there is no such pattern in current buffer.
  if not status then
    -- Strip the "Vim(normal):" prefix; covers E486, E35 (no previous pattern)
    -- and E384/E385 (search hit TOP/BOTTOM with nowrapscan).
    local msg_part = msg:match("E%d+:.*") or msg
    api.nvim_echo({ { msg_part } }, true, { err = true })
    return
  end

  hlslens.start()
end

keymap.set("n", "n", "", {
  desc = "Search: next match (with lens)",
  callback = function()
    activate_hlslens("n")
  end,
})

keymap.set("n", "N", "", {
  desc = "Search: previous match (with lens)",
  callback = function()
    activate_hlslens("N")
  end,
})

local check_cursor_word = function()
  local cursor_word = vim.fn.expand("<cword>")
  local result = cursor_word == ""
  if result then
    local msg = "E348: No string under cursor"
    api.nvim_echo({ { msg } }, true, { err = true })
  end

  return result, cursor_word
end

-- Search the word under the cursor as a literal whole word (\V\<word\>), so
-- keyword chars like `?`, `$`, `/` or `\` cannot break the pattern.
-- count 1: keep the cursor in place (N after the jump); count > 1: jump to the count-th match.
local function star_search(dir_char)
  local cursor_word_empty, cursor_word = check_cursor_word()
  if cursor_word_empty then
    return
  end

  local count = vim.v.count1
  local pattern = [[\V\<]] .. vim.fn.escape(cursor_word, "\\" .. dir_char) .. [[\>]]
  -- special notation must be replaced by its internal representation to act as a real Enter
  local enter = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
  local cmd = string.format("normal! %s%s%s%s", count > 1 and count or "", dir_char, pattern, enter)

  local ok, err = pcall(vim.fn.execute, cmd)
  if not ok then
    -- e.g. E384/E385 with 'nowrapscan': stay put like the builtin `*`
    api.nvim_echo({ { tostring(err):match("E%d+:.*") or tostring(err) } }, true, { err = true })
    return
  end
  if count == 1 then
    -- N keeps the cursor where it was (only after a successful search)
    pcall(vim.fn.execute, "normal! N")
  end
  hlslens.start()
end

keymap.set("n", "*", function()
  star_search("/")
end, { desc = "Search: word under cursor forward (with lens)" })

keymap.set("n", "#", function()
  star_search("?")
end, { desc = "Search: word under cursor backward (with lens)" })
