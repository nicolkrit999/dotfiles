local root_markers = { "typos.toml", "_typos.toml", ".typos.toml", "pyproject.toml", "Cargo.toml", ".gitignore" }

-- filetypes typos_lsp must never attach to
local skip_ft = {
  -- Snacks.bigfile buffers: would receive the whole file (see lua/config/bigfile.lua)
  bigfile = true,
  -- start screens
  dashboard = true,
  alpha = true,
  snacks_dashboard = true,
}

---@type vim.lsp.Config
return {
  root_markers = root_markers,
  -- typos_lsp has no filetype list, so it would start on every buffer that gets a filetype:
  -- skip special buffers (buftype ~= "": help, terminal, quickfix, plugin panels...) and skip_ft
  root_dir = function(bufnr, on_dir)
    if vim.bo[bufnr].buftype ~= "" or skip_ft[vim.bo[bufnr].filetype] then
      return
    end
    on_dir(vim.fs.root(bufnr, root_markers))
  end,
}
