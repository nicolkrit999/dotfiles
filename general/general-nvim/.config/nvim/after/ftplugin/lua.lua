-- Disable inserting comment leader after hitting o/O/<Enter>
vim.opt_local.formatoptions:remove { "o", "r" }

for _, lhs in ipairs({ "<F9>", "<leader>rf" }) do -- <leader>rf: the same without function keys
  vim.keymap.set("n", lhs, "<cmd>luafile %<CR>", { buffer = true, silent = true, desc = "run lua file" })
end

--- New cursor row for an old row after the hunks (vim.text.diff indices) were applied.
---@param hunks integer[][] { a_start, a_count, b_start, b_count }
---@param row integer
---@return integer
local function new_row(hunks, row)
  local delta = 0
  for _, h in ipairs(hunks) do
    local a_start, a_count, b_start, b_count = unpack(h)
    if a_count > 0 and row >= a_start and row < a_start + a_count then
      -- inside a changed block: same offset into the new block, clamped to it
      return b_count == 0 and b_start + 1 or math.min(b_start + (row - a_start), b_start + b_count - 1)
    elseif (a_count > 0 and a_start + a_count - 1 < row) or (a_count == 0 and a_start < row) then
      delta = delta + b_count - a_count
    end
  end
  return row + delta
end

--- Format the BUFFER (not the file on disk) with stylua through stdin; only the changed lines are
--- replaced (one undo step), and every window showing the buffer keeps its cursor and view.
--- Missing stylua or a stylua error (e.g. a syntax error) -> ONE warning, buffer untouched.
local function stylua_format()
  if vim.fn.executable("stylua") == 0 then
    vim.notify("stylua not found on PATH", vim.log.levels.WARN)
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    -- stylua uses the path to find stylua.toml / .stylua.toml / .styluaignore
    name = vim.fs.joinpath(vim.fn.getcwd(), "stdin.lua")
  end
  local old = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local res = vim
    .system({ "stylua", "--search-parent-directories", "--stdin-filepath", name, "-" }, {
      stdin = table.concat(old, "\n") .. "\n",
      text = true,
    })
    :wait(10000)
  if res.code ~= 0 then
    local err_lines = vim.split(vim.trim(res.stderr or ""), "\n", { plain = true })
    local first = vim.trim(err_lines[1])
    -- a parse error's first line ends in "error parsing:"; the reason is on the next line
    if first:sub(-1) == ":" and err_lines[2] then
      first = first .. " " .. vim.trim(err_lines[2]):gsub("^%- ", "")
    end
    vim.notify("stylua failed: " .. (first ~= "" and first or ("exit code " .. res.code)), vim.log.levels.WARN)
    return
  end
  local new = vim.split((res.stdout or ""):gsub("\n$", ""), "\n", { plain = true })
  local diff = (vim.text and vim.text.diff) or vim.diff
  local hunks = diff(table.concat(old, "\n") .. "\n", table.concat(new, "\n") .. "\n", { result_type = "indices" })
  ---@cast hunks integer[][]
  if #hunks == 0 then
    return
  end
  local views = {}
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    views[win] = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  end
  -- bottom-up so the earlier line numbers stay valid; all in one callback = one undo step
  for i = #hunks, 1, -1 do
    local a_start, a_count, b_start, b_count = unpack(hunks[i])
    local first = a_count == 0 and a_start or a_start - 1
    vim.api.nvim_buf_set_lines(buf, first, first + a_count, false, vim.list_slice(new, b_start, b_start + b_count - 1))
  end
  local last = vim.api.nvim_buf_line_count(buf)
  for win, view in pairs(views) do
    if vim.api.nvim_win_is_valid(win) then
      view.lnum = math.max(1, math.min(new_row(hunks, view.lnum), last))
      view.topline = math.max(1, math.min(new_row(hunks, view.topline), last))
      local len = #(vim.api.nvim_buf_get_lines(buf, view.lnum - 1, view.lnum, false)[1] or "")
      view.col = math.max(0, math.min(view.col, len - 1))
      vim.api.nvim_win_call(win, function()
        vim.fn.winrestview(view)
      end)
    end
  end
end

vim.keymap.set("n", "<Space>f", stylua_format, { buffer = true, silent = true, desc = "Format file (stylua)" })
-- one Lua formatter: <Space>fm (global: LSP format) runs stylua too; lua_ls formatting is off
vim.keymap.set("n", "<Space>fm", stylua_format, { buffer = true, silent = true, desc = "Format file (stylua)" })
