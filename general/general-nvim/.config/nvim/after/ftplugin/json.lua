vim.keymap.set({ "n", "v" }, "<space>f", ":JSONFormat<cr>", {
  buffer = true,
  silent = true,
  desc = "format file (JSON, whole buffer or selection)",
})
