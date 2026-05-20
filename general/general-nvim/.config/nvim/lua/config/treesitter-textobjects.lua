-- Use pcall to prevent the red error screen if the plugin isn't loaded yet
local status, configs = pcall(require, "nvim-treesitter.configs")
if not status then
  return
end

configs.setup {
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      },
      selection_modes = {
        ["@function.inner"] = "V",
        ["@function.outer"] = "V",
        ["@class.outer"] = "V",
        ["@class.inner"] = "V",
        ["@parameter.outer"] = "v",
      },
      include_surrounding_whitespace = false,
    },
  },
}
