-- Use pcall to prevent the red error screen if the plugin isn't loaded yet
local status, configs = pcall(require, "nvim-treesitter.configs")
if not status then
  return
end

configs.setup {
  -- NixOS users often prefer installing grammars via Nix, but for portability,
  -- we keep this list for non-Nix systems.
  ensure_installed = { "python", "cpp", "lua", "vim", "json", "toml", "html" },

  -- On NixOS, auto_install can fail because of the read-only filesystem.
  -- We disable it if we detect a Nix environment, otherwise keep it true.
  auto_install = not vim.uv.fs_stat("/etc/nixos"),

  highlight = {
    enable = true,
    disable = { "help" },
  },
}
