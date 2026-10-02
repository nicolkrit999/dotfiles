local opt = vim.opt_local

-- Do not wrap Python source code.
opt.wrap = false
opt.sidescroll = 5 -- global-only option
opt.sidescrolloff = 2
opt.colorcolumn = "100"

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

if vim.fn.exists(":AsyncRun") == 2 then
  vim.keymap.set("n", "<F9>", [[:<C-U>AsyncRun python -u "%"<CR>]], { buffer = true, silent = true, desc = "run python file" })
end

vim.keymap.set("n", "<Space>f", "<cmd>silent !black %<CR>", { buffer = true, silent = true, desc = "format file" })
