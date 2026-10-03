-- Copy file path to clipboard
local copy_path_choices = { "nameonly", "relative", "absolute" }
vim.api.nvim_create_user_command("CopyPath", function(context)
  local kind = context["args"]
  if not vim.tbl_contains(copy_path_choices, kind) then
    vim.notify("CopyPath: argument must be one of " .. table.concat(copy_path_choices, ", "), vim.log.levels.WARN)
    return
  end

  local full_path = vim.api.nvim_buf_get_name(0)
  if full_path == "" then
    vim.notify("CopyPath: the buffer has no file path", vim.log.levels.WARN)
    return
  end
  full_path = vim.fn.fnamemodify(full_path, ":p")

  local file_path
  if kind == "nameonly" then
    file_path = vim.fn.fnamemodify(full_path, ":t")
  elseif kind == "absolute" then
    file_path = full_path
  else
    -- the file path relative to the project root (plain string handling, no regex)
    local project_root = vim.fs.root(0, { ".git", "pyproject.toml" })
    if project_root == nil then
      vim.notify("CopyPath: can not find project root", vim.log.levels.WARN)
      return
    end
    local rel = vim.fs.relpath(project_root, full_path)
    if rel == nil then
      vim.notify("CopyPath: file is not inside the project root", vim.log.levels.WARN)
      return
    end
    file_path = "<project-root>/" .. rel
  end

  if file_path == nil or file_path == "" then
    vim.notify("CopyPath: empty path, nothing copied", vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(vim.fn.setreg, "+", file_path)
  if not ok then
    vim.notify("CopyPath: could not set the clipboard: " .. tostring(err), vim.log.levels.WARN)
    return
  end
  vim.print("Filepath copied to clipboard!")
end, {
  bang = false,
  nargs = 1,
  force = true,
  desc = "Copy current file path to clipboard",
  complete = function()
    return copy_path_choices
  end,
})

-- JSON format part of or the whole file
vim.api.nvim_create_user_command("JSONFormat", function(context)
  local range = context["range"]
  local line1 = context["line1"]
  local line2 = context["line2"]

  local executable = require("utils").executable
  local python_cmd = nil
  if executable("python3") then
    python_cmd = "python3"
  elseif executable("python") then
    python_cmd = "python"
  else
    vim.notify("JSONFormat: no python executable found", vim.log.levels.ERROR)
    return
  end

  if range == 0 or range == 1 or range == 2 then
    -- range is only passed when invoked as `:JSONFormat`, not via `<cmd>JSONFormat`;
    -- range 1 (`:2JSONFormat`) has line1 == line2
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)
    local res = vim.system({ python_cmd, "-m", "json.tool", "--indent", "2" }, {
      stdin = table.concat(lines, "\n") .. "\n",
      text = true,
    }):wait()
    if res.code ~= 0 then
      -- invalid JSON: leave the buffer alone
      -- python's last stderr line is the error ("Expecting value: line 1 column 1 (char 0)")
      local errlines = vim.split(vim.trim(res.stderr or ""), "\n", { plain = true })
      local msg = errlines[#errlines]
      if msg == "" then
        msg = "failed (exit " .. res.code .. ")"
      end
      vim.notify("JSONFormat: " .. msg, vim.log.levels.ERROR)
      return
    end
    local out = vim.split((res.stdout or ""):gsub("\n$", ""), "\n", { plain = true })
    vim.api.nvim_buf_set_lines(buf, line1 - 1, line2, false, out)
  else
    vim.api.nvim_echo({ { string.format("unsupported range: %s", range) } }, true, { err = true })
  end
end, {
  desc = "Format JSON string",
  range = "%",
})

-- modified from https://github.com/neovim/neovim/issues/30415#issuecomment-2368519968
vim.api.nvim_create_user_command("TermHL", function()
  local buf_cur = vim.api.nvim_get_current_buf()
  local buf_new = vim.api.nvim_create_buf(false, true)
  if buf_new == 0 then
    vim.notify("TermHL: can not create new buffer!", vim.log.levels.ERROR)
    return
  end
  vim.b[buf_new].ansi_preview = true
  -- create a "virtual" terminal: it can not accept user input
  local chan = vim.api.nvim_open_term(buf_new, {})
  if chan == 0 then
    vim.notify("TermHL: can not create new channel", vim.log.levels.ERROR)
    return
  end
  local data = table.concat(vim.api.nvim_buf_get_lines(buf_cur, 0, -1, false), "\n")
  vim.api.nvim_chan_send(chan, data)
  vim.api.nvim_win_set_buf(0, buf_new)
end, { desc = "Highlight buffer with ANSI color" })
