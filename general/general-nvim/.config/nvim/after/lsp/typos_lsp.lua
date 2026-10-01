local root_markers = { "typos.toml", "_typos.toml", ".typos.toml", "pyproject.toml", "Cargo.toml", ".gitignore" }

---@type vim.lsp.Config
return {
  root_markers = root_markers,
  -- typos_lsp has no filetype list, so it would also start on Snacks.bigfile buffers
  -- (filetype "bigfile") and receive the whole file: skip those (see lua/config/bigfile.lua)
  root_dir = function(bufnr, on_dir)
    if vim.bo[bufnr].filetype == "bigfile" then
      return
    end
    on_dir(vim.fs.root(bufnr, root_markers))
  end,
}
