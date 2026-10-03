require("illuminate").configure {
  providers = {
    "lsp",
    "treesitter",
  },
  filetypes_allowlist = {
    "bash",
    "c",
    "cpp",
    "go",
    "java",
    "javascript",
    "javascriptreact",
    "json",
    "lua",
    "markdown",
    "nix",
    "plaintex",
    "python",
    "rust",
    "sh",
    "tex",
    "toml",
    "typescript",
    "typescriptreact",
    "typst",
    "yaml",
  },
  min_count_to_highlight = 2,
  -- nixd answers documentHighlight with every package of a `with pkgs; [ ... ]`
  -- list, so in nix buffers skip the LSP and use tree-sitter, then plain text
  -- matching (only the identical word is highlighted)
  filetype_overrides = {
    nix = { providers = { "treesitter", "regex" } },
  },
}
