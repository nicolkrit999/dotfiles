vim.loader.enable()

-- some global settings
require("globals")
-- setting options in nvim
require("options")
-- various autocommands
require("custom-autocmd")
-- all the user-defined mappings
require("mappings")
-- :z / :Z zoxide jump
require("zoxide")
-- :DevEnv <lang> enters a language devShell from the running session
require("devenv")
-- all the plugins installed and their configurations
require("plugin_specs")

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
