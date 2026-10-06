-- conform.nvim: ONE formatter front end for every filetype.
--   * format on EXPLICIT saves (:w, :x, ZZ ...); auto-save.nvim saves never format (see the spec's
--     `init` in lua/plugin_specs.lua, which sets vim.g.autosave_writing around its writes)
--   * <Space>fm formats on demand (lua/mappings.lua), also a visual selection
--   * binaries come from the host (nix); a formatter that is not installed is skipped silently and
--     the buffer falls back to the LSP formatter (lsp_format = "fallback")
local conform = require("conform")

--- Formatters_by_ft entry that keeps only the formatters whose binary is installed (checked on
--- every format, so a tool that appears later is picked up). Nothing left -> {} -> LSP fallback.
---@param ... string formatter names, run in order
local function installed(...)
  local names = { ... }
  return function(bufnr)
    return vim.tbl_filter(function(name)
      return conform.get_formatter_info(name, bufnr).available
    end, names)
  end
end

local prettier = installed("prettier")

conform.setup {
  formatters_by_ft = {
    lua = installed("stylua"), -- lua_ls formatting is off (lua/config/lsp.lua)
    -- prettier: markdown, web, data
    markdown = prettier,
    yaml = prettier,
    json = prettier,
    jsonc = prettier,
    css = prettier,
    scss = prettier,
    html = prettier,
    javascript = prettier,
    typescript = prettier,
    javascriptreact = prettier,
    typescriptreact = prettier,
    -- shells, nix, toml
    sh = installed("shfmt"),
    bash = installed("shfmt"),
    fish = installed("fish_indent"),
    nix = installed("nixfmt"),
    toml = installed("taplo"),
    -- documents
    typst = installed("typstyle"),
    tex = installed("latexindent"),
    plaintex = installed("latexindent"),
    bib = installed("latexindent"),
    -- compiled languages
    c = installed("clang-format"),
    cpp = installed("clang-format"),
    objc = installed("clang-format"),
    objcpp = installed("clang-format"),
    java = installed("google-java-format"),
    rust = installed("rustfmt"),
    go = installed("goimports", "gofumpt"), -- imports first, then gofumpt
    python = installed("ruff_format"),
    xml = installed("xmllint"),
    sql = installed("sql_formatter"),
  },

  -- also used by <Space>fm and :ConformInfo's "will run"; LSP only when no formatter is installed
  default_format_opts = { lsp_format = "fallback" },

  -- called on BufWritePre; returning nil skips formatting
  format_on_save = function(bufnr)
    -- auto-save.nvim (FocusLost/BufLeave) is writing: never reshuffle a file the user may be mid-edit
    if vim.g.autosave_writing then
      return
    end
    -- opt-out: :FormatDisable (all buffers) / :FormatDisable! (this buffer), <Space>fo
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    -- only real files (not terminals, quickfix, help ...)
    if vim.bo[bufnr].buftype ~= "" then
      return
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,

  notify_on_error = true,
  notify_no_formatters = false, -- saving a file type without formatter must stay quiet
}

-- :FormatDisable disables format on save everywhere, :FormatDisable! only in the current buffer
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { bang = true, desc = "Disable format on save (! = this buffer only)" })

-- :FormatEnable undoes both the global and the buffer-local switch
vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = "Enable format on save again (global and this buffer)" })
