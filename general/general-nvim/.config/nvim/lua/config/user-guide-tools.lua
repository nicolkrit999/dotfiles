-- Two helpers behind <Space>? / <Space>a and the matching dashboard items:
--   open_guide() the user guide as a PDF at page 2 (the contents) (zathura window next to Neovim, else the system viewer)
--   ask_claude() a fresh `claude` session in the nvim config dir with the
--                answering-neovim-usage-questions skill (vertical split on the right; its own tab
--                when started from the dashboard)
-- The PDF is built from the markdown by user-guide/build-pdf.py.
local M = {}

function M.open_guide()
  local pdf = vim.fn.stdpath("config") .. "/user-guide/neovim-user-guide.pdf"
  if vim.fn.filereadable(pdf) == 0 then
    vim.notify("user guide PDF missing: run user-guide/build-pdf.py", vim.log.levels.WARN)
    return
  end
  if vim.fn.executable("zathura") == 1 then
    local job = vim.g.user_guide_zathura_job
    if job and vim.fn.jobwait({ job }, 0)[1] == -1 then
      vim.notify("user guide is already open in zathura", vim.log.levels.INFO)
      return
    end
    vim.g.user_guide_zathura_job = vim.fn.jobstart({ "zathura", "--page=2", pdf }, { detach = true })
    return
  end
  local _, err = vim.ui.open(pdf)
  if err then vim.notify("user guide: " .. err, vim.log.levels.WARN) end
end

function M.ask_claude()
  if vim.fn.executable("claude") == 0 then
    vim.notify("claude not found on PATH", vim.log.levels.WARN)
    return
  end
  if vim.bo.filetype == "dashboard" then
    vim.cmd("tabnew")
  else
    vim.cmd("botright vnew")
    vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.4))
  end
  local buf = vim.api.nvim_get_current_buf()
  vim.fn.jobstart({
    "claude",
    "--model", "sonnet", -- always Sonnet for these questions, whatever the default model is
    "--dangerously-skip-permissions", -- a quick question must not stop to ask before reading the guide
    "/answering-neovim-usage-questions Reply with one short line and wait for my question about how to do something in Neovim.",
  }, {
    term = true,
    cwd = vim.fn.stdpath("config"),
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
      end)
    end,
  })
  -- <Esc> goes to Claude (interrupt) instead of leaving terminal mode; <C-\><C-n> still leaves it
  vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = buf, nowait = true, desc = "Esc to Claude Code" })
  -- <Esc> no longer leaves terminal mode, so <C-w>h/j/k/l must work from terminal mode too
  -- (otherwise the keys are typed into Claude and the only way back to the code is the mouse)
  for _, dir in ipairs({ "h", "j", "k", "l" }) do
    vim.keymap.set("t", "<C-w>" .. dir, [[<C-\><C-n><C-w>]] .. dir,
      { buffer = buf, desc = "Claude: move to the window " .. dir })
  end
  vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { buffer = buf, desc = "Claude: leave terminal mode" })
  vim.cmd("startinsert")
end

return M
