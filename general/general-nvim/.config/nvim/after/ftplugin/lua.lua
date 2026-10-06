-- Disable inserting comment leader after hitting o/O/<Enter>
vim.opt_local.formatoptions:remove { "o", "r" }

for _, lhs in ipairs({ "<F9>", "<leader>rf" }) do -- <leader>rf: the same without function keys
  vim.keymap.set("n", lhs, "<cmd>luafile %<CR>", { buffer = true, silent = true, desc = "run lua file" })
end
