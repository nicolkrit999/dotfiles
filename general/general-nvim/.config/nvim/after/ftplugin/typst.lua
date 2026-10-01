-- Typst filetype settings and keymaps.
-- Loaded automatically for *.typ buffers by Neovim's after/ftplugin mechanism.

-- Reasonable defaults for prose-heavy markup files.
vim.opt_local.textwidth = 100
vim.opt_local.wrap      = true

-- <leader>tw  - launch typst watch (recompile + open PDF) in background.
-- TypstWatch is provided by kaarmu/typst.vim, which is only enabled when `typst` is on PATH
-- (e.g. inside the typst devShell): same check here. Without typst the key shows ONE warning
-- (an unmapped key would fall through to <Space>t (aerial) + w).
if vim.fn.executable("typst") == 1 then
  vim.keymap.set("n", "<leader>tw", "<cmd>TypstWatch<cr>",
    { buffer = true, desc = "Typst: watch & recompile" })
else
  vim.keymap.set("n", "<leader>tw", function()
    vim.notify("Typst: typst not found on PATH (open nvim inside the typst devShell)", vim.log.levels.WARN)
  end, { buffer = true, desc = "Typst: watch & recompile (needs typst)" })
end
