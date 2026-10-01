local utils = require("utils")
local opt = vim.opt_local

-- Do not wrap Python source code.
opt.wrap = false
opt.sidescroll = 5 -- global-only option
opt.sidescrolloff = 2
opt.colorcolumn = "100"

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- `:compiler ruff` + `:make`: don't pass `--preview`
vim.g.ruff_makeprg_params = ""

-- in a uv project (uv.lock at the project root) without an activated venv, run tools through `uv run`
local py_env = utils.get_py_env()

if vim.fn.exists(":AsyncRun") == 2 then
  local py_cmd = (py_env == "uv") and "uv run python" or "python"
  vim.keymap.set("n", "<F9>", string.format(':<C-U>AsyncRun %s -u "%%"<CR>', py_cmd), { buffer = true, silent = true, desc = "run python file" })
end

-- <Space>f black: only when the formatter can run (black e.g. from the python devShell;
-- in a uv project black comes from the project env through `uv run`)
local py_fmt_bin = (py_env == "uv") and "uv" or "black"
if vim.fn.executable(py_fmt_bin) == 1 then
  local py_fmt_cmd = (py_env == "uv") and "!uv run black" or "!black"
  vim.keymap.set("n", "<Space>f", string.format("<cmd>silent %s %%<CR>", py_fmt_cmd), { buffer = true, silent = true, desc = "format file" })
end
