local M = {}

M.get_default_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- required by nvim-ufo
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  return capabilities
end

--- Get the names of the LSP clients attached to the current buffer (sorted)
---@return string[]
M.get_attached_lsp = function()
  local client_names = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    table.insert(client_names, client.name)
  end
  table.sort(client_names)
  return client_names
end

--- main LSP per filetype; it is shown first in the statusline
M.main_lsp_by_filetype = {
  python = "pyright",
  lua = "lua_ls",
  nix = "nixd",
  java = "jdtls",
  markdown = "marksman",
  typst = "tinymist",
  sh = "bashls",
  yaml = "yamlls",
}

return M
