-- Only non-trivial options are kept; everything else equals the plugin defaults
-- (verified against nvim-devdocs lua/nvim-devdocs/config.lua).
require("nvim-devdocs").setup({
  dir_path = vim.fn.stdpath("data") .. "/devdocs",
  float_win = {
    relative = "editor",
    height = 25,
    width = 100,
    border = "rounded",
  },
  wrap = false,
  mappings = {
    open_in_browser = "",
  },
})
