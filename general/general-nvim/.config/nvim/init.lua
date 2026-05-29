vim.loader.enable()


local config_dir = vim.fn.stdpath("config")
---@cast config_dir string

-- some global settings
require("globals")
-- setting options in nvim
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/options.vim"))
-- various autocommands
require("custom-autocmd")
-- all the user-defined mappings
require("mappings")
-- all the plugins installed and their configurations
vim.cmd("source " .. vim.fs.joinpath(config_dir, "viml_conf/plugins.vim"))

-- diagnostic related config
require("diagnostic-conf")

-- colorscheme settings
local color_scheme = require("colorschemes")

local is_nix = vim.uv.fs_stat("/etc/nixos") or vim.uv.fs_stat("/etc/nix")
if is_nix then
  color_scheme.nix_colorscheme()
else
  color_scheme.rand_colorscheme()
end
