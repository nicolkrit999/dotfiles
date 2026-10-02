-- :z / :Z {keywords}  ->  :cd to the best zoxide match (e.g. ":z nix nixos-laptop").
-- Without arguments it opens the fzf-lua zoxide picker. zoxide is optional: without the binary the
-- command warns once per call and does nothing. Neovim user commands must start uppercase, so `:z`
-- is a command-line abbreviation that only expands when typed as the whole command.
vim.api.nvim_create_user_command("Z", function(opts)
  if vim.fn.executable("zoxide") ~= 1 then
    vim.notify("zoxide is not installed", vim.log.levels.WARN)
    return
  end
  if opts.args == "" then
    vim.cmd("FzfLua zoxide")
    return
  end
  local res = vim.system(vim.list_extend({ "zoxide", "query", "--" }, opts.fargs), { text = true }):wait()
  local dir = vim.trim(res.stdout or "")
  if res.code ~= 0 or dir == "" then
    vim.notify("zoxide: no match for '" .. opts.args .. "'", vim.log.levels.WARN)
    return
  end
  vim.cmd.cd(vim.fn.fnameescape(dir))
  vim.notify("cd " .. dir)
end, { nargs = "*", desc = "zoxide: cd to the best match" })

vim.cmd([[cnoreabbrev <expr> z (getcmdtype() ==# ':' && getcmdline() ==# 'z') ? 'Z' : 'z']])
