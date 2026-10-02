local win_width = vim.api.nvim_win_get_width(0)

-- do not change layout if the screen is not wide enough
if win_width < 200 then
  return
end

-- H = leftmost, full height (`:h CTRL-W_H`); keeps the right side for the claude-code.nvim panel
vim.cmd.wincmd([[H]])
