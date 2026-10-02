-- LanguageTool grammar/spell checking via ltex-ls-plus (installed globally by nix).
---@type vim.lsp.Config
return {
  filetypes = { "markdown", "tex", "plaintex", "typst", "gitcommit", "text" },
  ---@type lspconfig.settings.ltex
  settings = {
    ltex = {
      -- user's spelllang is en,it,de,fr; LanguageTool checks ONE language per document.
      -- Alternative: language = "auto" (LanguageTool detects the language per document;
      -- less reliable on short texts such as commit messages).
      language = "en-US",
      -- language ids (after get_language_id): this list REPLACES lspconfig's default list
      enabled = { "markdown", "latex", "tex", "plaintex", "typst", "gitcommit", "git-commit", "plaintext", "text" },
      -- setting ltex.ltex-ls.logLevel: the default ("fine") writes whole documents to stderr,
      -- i.e. into lsp.log, on every check
      ["ltex-ls"] = { logLevel = "warning" },
    },
  },
}
