local glance = require("glance")

glance.setup {
  height = 25,
  border = {
    enable = true,
  },
}

vim.keymap.set("n", "<space>gd", "<cmd>Glance definitions<cr>", { desc = "Glance definitions" })
vim.keymap.set("n", "<space>gr", "<cmd>Glance references<cr>", { desc = "Glance references" })
vim.keymap.set("n", "<space>gi", "<cmd>Glance implementations<cr>", { desc = "Glance implementations" })
