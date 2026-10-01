require("treesj").setup {
  use_default_keymaps = false,
}

vim.keymap.set("n", "gS", require("treesj").toggle, { desc = "Toggle split join" })
