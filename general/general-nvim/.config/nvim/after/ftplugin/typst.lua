-- Typst filetype settings and keymaps.
-- Loaded automatically for *.typ buffers by Neovim's after/ftplugin mechanism.

-- Reasonable defaults for prose-heavy markup files.
vim.o.textwidth = 100
vim.o.wrap      = true

-- <leader>tw  — launch typst watch (recompile + open PDF) in background.
-- TypstWatch is provided by kaarmu/typst.vim.
vim.keymap.set("n", "<leader>tw", "<cmd>TypstWatch<cr>",
  { buffer = true, desc = "Typst: watch & recompile" })
