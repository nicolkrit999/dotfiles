-- nvim-treesitter `main` branch API (the old `nvim-treesitter.configs` module no longer exists).
local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
  return
end

ts.setup({})

-- On Nix systems grammars come from the nix store (neovim.nix, nvim-treesitter.withPlugins)
-- and the filesystem is read-only, so only install parsers on non-Nix systems.
local is_nix = vim.uv.fs_stat("/etc/nixos") or vim.uv.fs_stat("/etc/nix")
if not is_nix then
  ts.install({ "python", "cpp", "lua", "vim", "json", "toml", "html" })
end

-- Highlighting is no longer a module option: start it per buffer when a parser exists.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype == "help" then
      return
    end
    pcall(vim.treesitter.start, args.buf)
  end,
})
