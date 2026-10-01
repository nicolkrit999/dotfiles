-- Snacks.bigfile "LSP-light" setup (used as `bigfile.setup` in the snacks.nvim spec).
--
-- A big file gets filetype `bigfile` (no treesitter, no ftplugin maps). On top of the Snacks
-- defaults this keeps the LSP for the REAL filetype, but cheaper:
--   * typos_lsp / ltex_plus (spell/grammar over the whole text) and lua_ls are never attached,
--   * the other enabled LSP configs for the real filetype start ~500 ms after opening,
--     with semantic tokens and nvim-cmp completion disabled for this buffer,
--   * vim syntax is only turned on when the longest line is short enough (a megabyte-long
--     minified line makes the regex engine hit 'redrawtime').
-- Escape hatches: `:lsp stop` (detach everything), `:set ft=<real ft>` (full mode: semantic
-- tokens, completion and paren matching come back for this buffer).
local M = {}

-- LSPs that are skipped in big files. lua_ls: every bigfile is over its
-- Lua.workspace.preloadFileSize (500 KB); on a 2 MB file it gave no answers (documentSymbol
-- timed out after 15 s) while still burning CPU, so it is no help there.
M.skip = { typos_lsp = true, ltex_plus = true, lua_ls = true }
-- syntax highlighting only if every line is shorter than this
M.max_syntax_line = 3000
M.lsp_delay = 500

local function longest_line(buf)
  local max = 0
  for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if #l > max then
      max = #l
      if max >= M.max_syntax_line then break end
    end
  end
  return max
end

-- the buffer's filetype is "bigfile": make clients use the real filetype as languageId
local function patch_language_id(get_language_id)
  local orig = get_language_id or function(_, ft) return ft end
  return function(bufnr, ft)
    if ft == "bigfile" and vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].bigfile_ft then
      ft = vim.b[bufnr].bigfile_ft
    end
    return orig(bufnr, ft)
  end
end

local function start_lsp(buf, ft)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "bigfile" then return end
  vim.lsp.semantic_tokens.enable(false, { bufnr = buf })
  for _, config in ipairs(vim.lsp.get_configs({ enabled = true, filetype = ft })) do
    if not M.skip[config.name] then
      config = vim.deepcopy(config)
      config.get_language_id = patch_language_id(config.get_language_id)
      -- a reused client keeps its own get_language_id: patch the running ones too
      for _, client in ipairs(vim.lsp.get_clients({ name = config.name })) do
        if not client._bigfile_patched then
          client.get_language_id = patch_language_id(client.get_language_id)
          client._bigfile_patched = true
        end
      end
      local function start()
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "bigfile" then
          vim.lsp.start(config, { bufnr = buf, reuse_client = config.reuse_client, _root_markers = config.root_markers })
        end
      end
      if type(config.root_dir) == "function" then
        config.root_dir(buf, function(root_dir)
          config.root_dir = root_dir
          vim.schedule(start)
        end)
      else
        start()
      end
    end
  end
end

---@param ctx {buf: integer, ft: string}
function M.setup(ctx)
  local buf = ctx.buf
  -- Snacks defaults, but paren matching off for THIS buffer only (the Snacks default
  -- :NoMatchParen is vim-matchup's global switch and would stay off in every buffer)
  vim.b[buf].matchup_matchparen_enabled = 0
  vim.b[buf].matchup_matchparen_fallback = 0
  Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
  vim.b[buf].completion = false -- read by the nvim-cmp `enabled` function
  vim.b[buf].minianimate_disable = true
  vim.b[buf].minihipatterns_disable = true

  vim.b[buf].bigfile_ft = ctx.ft
  local group = vim.api.nvim_create_augroup("bigfile_lsp_" .. buf, { clear = true })

  -- `:set ft=<lang>` leaves bigfile mode: undo the buffer-local restrictions
  vim.api.nvim_create_autocmd("FileType", {
    buffer = buf,
    group = group,
    callback = function(ev)
      if vim.bo[ev.buf].filetype == "bigfile" then return end
      for _, var in ipairs({ "completion", "minianimate_disable", "minihipatterns_disable",
        "matchup_matchparen_enabled", "matchup_matchparen_fallback", "bigfile_ft" }) do
        vim.b[ev.buf][var] = nil
      end
      vim.lsp.semantic_tokens.enable(true, { bufnr = ev.buf })
      pcall(vim.api.nvim_del_augroup_by_id, group)
    end,
  })

  -- filetype-less LSPs (typos_lsp attaches to every filetype, so also to "bigfile"): detach them
  vim.api.nvim_create_autocmd("LspAttach", {
    buffer = buf,
    group = group,
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and M.skip[client.name] and vim.bo[ev.buf].filetype == "bigfile" then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then vim.lsp.buf_detach_client(ev.buf, client.id) end
        end)
      end
    end,
  })
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    if M.skip[client.name] then vim.lsp.buf_detach_client(buf, client.id) end
  end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    if ctx.ft ~= "" and longest_line(buf) < M.max_syntax_line then
      vim.bo[buf].syntax = ctx.ft
    end
  end)

  if ctx.ft ~= "" then
    vim.defer_fn(function() start_lsp(buf, ctx.ft) end, M.lsp_delay)
  end
end

return M
