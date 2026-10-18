-- LanguageTool grammar/spell checking via ltex-ls-plus (installed globally by nix).
---@type vim.lsp.Config
return {
  filetypes = { "markdown", "tex", "plaintex", "typst", "gitcommit", "text" },
  ---@type lspconfig.settings.ltex
  settings = {
    ltex = {
      -- user's spelllang is en,it,de,fr; LanguageTool checks ONE language per document.
      -- "auto": LanguageTool detects the language of each document (so every subfile of an Italian
      -- Typst project is its own document and gets checked as Italian). Tested: detection is correct
      -- even on one-line English/Italian commit messages. Weak spot: mixed-language or very short
      -- text may be detected wrongly; pin a file with a magic comment (LaTeX: % LTeX: language=it-IT)
      -- or set language = "en-US" here to go back to English-only.
      language = "auto",
      -- language ids (after get_language_id): this list REPLACES lspconfig's default list
      enabled = { "markdown", "latex", "tex", "plaintex", "typst", "gitcommit", "git-commit", "plaintext", "text" },
      -- setting ltex.ltex-ls.logLevel: the default ("fine") writes whole documents to stderr,
      -- i.e. into lsp.log, on every check
      ["ltex-ls"] = { logLevel = "warning" },
    },
  },
}
