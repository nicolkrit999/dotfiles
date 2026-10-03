local diagnostic = vim.diagnostic
local api = vim.api

-- global config for diagnostic
diagnostic.config {
  underline = false,
  virtual_text = false,
  virtual_lines = false,
  signs = {
    -- nerd-font glyphs (Material Design set, nf-md), all four the same width
    text = {
      [diagnostic.severity.ERROR] = "\u{F015A}", -- nf-md-close_circle_outline
      [diagnostic.severity.WARN] = "\u{F002A}", -- nf-md-alert_outline
      [diagnostic.severity.INFO] = "\u{F02FD}", -- nf-md-information_outline
      [diagnostic.severity.HINT] = "\u{F0336}", -- nf-md-lightbulb_outline
    },
  },
  severity_sort = true,
  float = {
    source = true,
    header = "Diagnostics:",
    prefix = " ",
    border = "single",
    max_height = 10,
    max_width = 130,
    close_events = { "CursorMoved", "BufLeave", "WinLeave", "InsertEnter" },
  },
}

-- set quickfix list from diagnostics in a certain buffer, not the whole workspace
local set_qflist = function(buf_num, severity)
  local diagnostics = diagnostic.get(buf_num, { severity = severity })
  if #diagnostics == 0 then
    vim.notify("No diagnostics in this buffer", vim.log.levels.INFO)
    return
  end

  local qf_items = diagnostic.toqflist(diagnostics)
  vim.fn.setqflist({}, " ", { title = "Diagnostics", items = qf_items })

  -- open quickfix by default
  vim.cmd([[copen]])
end

-- this puts diagnostics from opened files to quickfix
vim.keymap.set("n", "<space>qw", diagnostic.setqflist, { desc = "put all diagnostics to qf" })

-- this puts diagnostics from current buffer to quickfix
vim.keymap.set("n", "<space>qb", function()
  set_qflist(0)
end, { desc = "put buffer diagnostics to qf" })

-- automatically show diagnostic in float win for current line
api.nvim_create_autocmd("CursorHold", {
  group = api.nvim_create_augroup("diagnostic_float", { clear = true }),
  pattern = "*",
  callback = function()
    if not vim.diagnostic.is_enabled({ bufnr = 0 }) or #vim.diagnostic.get(0) == 0 then
      return
    end

    if not vim.b.diagnostics_pos then
      vim.b.diagnostics_pos = { nil, nil }
    end

    local cursor_pos = api.nvim_win_get_cursor(0)

    if not vim.deep_equal(cursor_pos, vim.b.diagnostics_pos) then
      diagnostic.open_float {}
    end

    vim.b.diagnostics_pos = cursor_pos
  end,
})
