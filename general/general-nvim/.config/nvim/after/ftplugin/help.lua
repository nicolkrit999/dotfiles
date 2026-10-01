local win_width = vim.api.nvim_win_get_width(0)

-- do not change layout if the screen is not wide enough
if win_width < 200 then
  return
end

-- L moves the window to the far right, using the full height (`:h CTRL-W_L`)
vim.cmd.wincmd([[L]])
