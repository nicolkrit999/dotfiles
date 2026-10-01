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

--- Show a nui menu listing LSP clients attached to the current buffer.
--- @param size {width: integer, height: integer}
--- @param position {row: integer, col: integer} relative to current window
M.show_lsp_menu = function(size, position)
  local Menu = require("nui.menu")
  local NuiLine = require("nui.line")

  local lsp_names = M.get_attached_lsp()
  if vim.tbl_isempty(lsp_names) then
    vim.notify("No LSP attached to current buffer", vim.log.levels.INFO)
    return
  end

  local menu_items = {}
  for _, name in ipairs(lsp_names) do
    local line = NuiLine()
    line:append(string.format(" %s %s", "\u{f013}", name))
    table.insert(menu_items, Menu.item(line))
  end

  local menu = Menu({
    relative = "win",
    position = { row = position.row, col = position.col },
    size = { width = size.width, height = size.height },
    border = { style = "single", text = { top = "[LSP attached]", top_align = "center" } },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:Normal" },
  }, {
    lines = menu_items,
    max_width = 30,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>", "q" },
      submit = { "<CR>", "<Space>" },
    },
  })
  menu:mount()
end

return M
