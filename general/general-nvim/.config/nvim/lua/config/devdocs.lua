require("nvim-devdocs").setup({
  dir_path = vim.fn.stdpath("data") .. "/devdocs",
  telescope = {},
  filetypes = {},                  -- leave empty for basic usage
  float_win = {
    relative = "editor",
    height = 25,
    width = 100,
    border = "rounded",
  },
  wrap = false,
  previewer_cmd = nil,
  cmd_args = {},
  cmd_ignore = {},
  picker_cmd = false,
  picker_cmd_args = {},
  mappings = {
    open_in_browser = ""
  },
  ensure_installed = {},           -- install docs via :DevdocsInstall
  after_open = function(bufnr) end,
})
