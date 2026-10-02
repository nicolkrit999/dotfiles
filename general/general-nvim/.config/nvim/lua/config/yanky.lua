require("yanky").setup {
  preserve_cursor_position = {
    enabled = false,
  },
  highlight = {
    on_put = true,
    on_yank = false,
    timer = 300,
  },
}

vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Paste after (yanky)" })
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Paste before (yanky)" })

-- cycle through the yank history, only work after paste
vim.keymap.set("n", "[y", "<Plug>(YankyPreviousEntry)", { desc = "Yank history: previous entry (after paste)" })
vim.keymap.set("n", "]y", "<Plug>(YankyNextEntry)", { desc = "Yank history: next entry (after paste)" })
