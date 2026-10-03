require("aerial").setup {
  layout = {
    -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
    max_width = { 40, 0.2 },
    width = nil,
    min_width = 20,
  },
  on_attach = function(bufnr)
    vim.keymap.set("n", "[t", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Previous symbol (aerial)" })
    vim.keymap.set("n", "]t", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next symbol (aerial)" })
  end,
}
