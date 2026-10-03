local utils = require("utils")
local opt = vim.opt_local

-- Do not wrap Python source code.
opt.wrap = false
opt.sidescroll = 5 -- global-only option
opt.sidescrolloff = 2

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
  for _, lhs in ipairs({ "<F9>", "<leader>rf" }) do -- <leader>rf: the same without function keys
    vim.keymap.set("n", lhs, string.format(':<C-U>AsyncRun %s -u "%%"<CR>', py_cmd), { buffer = true, silent = true, desc = "run python file" })
  end
end

-- <Space>f black: only when the formatter can run (black e.g. from the python devShell;
-- in a uv project black comes from the project env through `uv run`). Without it the key shows
-- ONE warning (an unmapped key would fall through to <Space> + f).
local py_fmt_bin = (py_env == "uv") and "uv" or "black"
if vim.fn.executable(py_fmt_bin) == 1 then
  local py_fmt_cmd = (py_env == "uv") and "!uv run black" or "!black"
  vim.keymap.set("n", "<Space>f", string.format("<cmd>silent %s %%<CR>", py_fmt_cmd), { buffer = true, silent = true, desc = "format file" })
else
  vim.keymap.set("n", "<Space>f", function()
    vim.notify("Python: black not found on PATH (open nvim inside the python devShell)", vim.log.levels.WARN)
  end, { buffer = true, desc = "format file (needs black)" })
end

-- <leader>dp: start pdb on the current file (nvim-gdb, lazy-loaded on :GdbStart*; pdb is the
-- python stdlib module). nvim-gdb is disabled on macOS -> one warning instead.
if vim.fn.exists(":GdbStartPDB") == 2 then
  vim.keymap.set("n", "<leader>dp", [[:<C-U>GdbStartPDB python -m pdb %<CR>]], { buffer = true, desc = "start pdb on current file (nvim-gdb)" })
  -- debug-session keys without function keys (nvim-gdb's own keys are F4 until, F5 continue, F8 breakpoint,
  -- F10 next, F11 step, F12 finish; they keep working). <leader>dv (eval) is nvim-gdb's key_eval, see plugin_specs.lua.
  local function gdb(cmd)
    return function()
      local ok = pcall(vim.cmd, cmd)
      if not ok then
        vim.notify("pdb: no debug session here (start one with <Space>dp)", vim.log.levels.WARN)
      end
    end
  end
  for lhs, spec in pairs({
    ["<leader>dc"] = { "GdbContinue", "pdb: continue" },
    ["<leader>dn"] = { "GdbNext", "pdb: next line (step over)" },
    ["<leader>ds"] = { "GdbStep", "pdb: step into" },
    ["<leader>df"] = { "GdbFinish", "pdb: finish (run until the function returns)" },
    ["<leader>dB"] = { "GdbBreakpointToggle", "pdb: toggle breakpoint on this line" },
    ["<leader>du"] = { "GdbUntil", "pdb: run until this line" },
  }) do
    vim.keymap.set("n", lhs, gdb(spec[1]), { buffer = true, desc = spec[2] })
  end
else
  vim.keymap.set("n", "<leader>dp", function()
    vim.notify("<leader>dp: nvim-gdb is not available on this platform", vim.log.levels.WARN)
  end, { buffer = true, desc = "start pdb (needs nvim-gdb)" })
end
