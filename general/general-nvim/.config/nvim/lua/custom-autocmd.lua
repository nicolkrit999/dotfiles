local fn = vim.fn
local api = vim.api

local utils = require("utils")

-- Display a message when the current file is not in utf-8 format.
-- Note that we need to use `unsilent` command here because of this issue:
-- https://github.com/vim/vim/issues/4379
api.nvim_create_autocmd({ "BufRead" }, {
  pattern = "*",
  group = api.nvim_create_augroup("non_utf8_file", { clear = true }),
  callback = function()
    if vim.bo.fileencoding ~= "utf-8" then
      vim.notify("File not in UTF-8 format!", vim.log.levels.WARN, { title = "nvim-config" })
    end
  end,
})

-- highlight yanked region, see `:h lua-highlight`
local yank_group = api.nvim_create_augroup("highlight_yank", { clear = true })
api.nvim_create_autocmd({ "TextYankPost" }, {
  pattern = "*",
  group = yank_group,
  callback = function()
    vim.hl.on_yank { higroup = "YankColor", timeout = 300 }
  end,
})

api.nvim_create_autocmd({ "CursorMoved" }, {
  pattern = "*",
  group = yank_group,
  callback = function()
    vim.g.current_cursor_pos = vim.fn.getcurpos()
  end,
})

api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  group = yank_group,
  ---@diagnostic disable-next-line: unused-local
  callback = function(context)
    if vim.v.event.operator == "y" then
      vim.fn.setpos(".", vim.g.current_cursor_pos)
    end
  end,
})

-- Auto-create dir when saving a file, in case some intermediate directory does not exist
api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*",
  group = api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(ctx)
    local dir = fn.fnamemodify(ctx.file, ":p:h")
    utils.may_create_dir(dir)
  end,
})

-- Automatically reload the file if it is changed outside of Nvim, see https://unix.stackexchange.com/a/383044/221410.
-- It seems that `checktime` does not work in command line. We need to check if we are in command
-- line before executing this command, see also https://vi.stackexchange.com/a/20397/15292 .
api.nvim_create_augroup("auto_read", { clear = true })

-- The only notification for this (claude-code's own refresh notification is off, plugin_specs.lua).
-- v:fcs_reason is not reliable in the Post event (empty for a normal change), so a deleted file is
-- detected on disk. Never add a FileChangedShell autocmd: it would replace Nvim's builtin reload.
api.nvim_create_autocmd({ "FileChangedShellPost" }, {
  pattern = "*",
  group = "auto_read",
  callback = function(ev)
    if ev.file ~= "" and vim.uv.fs_stat(ev.file) == nil then
      vim.notify("File deleted on disk (buffer kept)", vim.log.levels.WARN, { title = "nvim-config" })
    else
      vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.WARN, { title = "nvim-config" })
    end
  end,
})

api.nvim_create_autocmd({ "FocusGained", "CursorHold" }, {
  pattern = "*",
  group = "auto_read",
  callback = function()
    if fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})


-- Resize all windows when we resize the terminal
api.nvim_create_autocmd("VimResized", {
  group = api.nvim_create_augroup("win_autoresize", { clear = true }),
  desc = "autoresize windows on resizing operation",
  command = "wincmd =",
})

-- `nvim <dir>`: cd into the directory, then show the tree there
local function open_nvim_tree(data)
  -- check if buffer is a directory
  local directory = vim.fn.isdirectory(data.file) == 1

  if not directory then
    return
  end

  -- cwd = the given directory (fires DirChanged -> git repo check of that directory)
  vim.cmd.cd(vim.fn.fnameescape(data.file))

  -- create a new, empty buffer
  vim.cmd.enew()

  -- wipe the directory buffer
  vim.cmd.bw(data.buf)

  -- open the tree (rooted at the new cwd)
  require("nvim-tree.api").tree.open()
end

api.nvim_create_autocmd({ "VimEnter" }, {
  group = api.nvim_create_augroup("open_tree_on_dir", { clear = true }),
  desc = "nvim <dir>: cd into it and open nvim-tree",
  callback = open_nvim_tree,
})

-- Do not use smart case in command line mode, extracted from https://vi.stackexchange.com/a/16511/15292.
-- :s / :g ignore case completely (like their live preview); / and ? keep smartcase.
api.nvim_create_augroup("dynamic_smartcase", { clear = true })
api.nvim_create_autocmd("CmdlineEnter", {
  group = "dynamic_smartcase",
  pattern = ":",
  callback = function()
    vim.o.smartcase = false
  end,
})

api.nvim_create_autocmd("CmdlineLeave", {
  group = "dynamic_smartcase",
  pattern = ":",
  callback = function()
    -- CmdlineLeave fires BEFORE the command runs: restore smartcase only after it has executed
    vim.schedule(function()
      vim.o.smartcase = true
    end)
  end,
})

api.nvim_create_autocmd("TermOpen", {
  group = api.nvim_create_augroup("term_start", { clear = true }),
  pattern = "*",
  callback = function(args)
    -- for the ansi preview buffer (:TermHL), insert is not possible
    if vim.b[args.buf].ansi_preview then
      return
    end

    -- Do not use number and relative number for terminal inside nvim: window-local for this
    -- buffer only (like :setlocal), so a file opened later in the same window gets its numbers back
    local win = fn.bufwinid(args.buf)
    if win ~= -1 then
      vim.wo[win][0].relativenumber = false
      vim.wo[win][0].number = false
    end

    -- Go to insert mode by default to start typing command, but only when the terminal is in the
    -- current window. Checked after the event: a terminal started from nvim_win_call() in another
    -- window looks current here, and startinsert would then apply to the real current window.
    vim.schedule(function()
      if api.nvim_get_current_buf() == args.buf and api.nvim_get_mode().mode == "nt" then
        vim.cmd("startinsert")
      end
    end)
  end,
})

local number_toggle_group = api.nvim_create_augroup("numbertoggle", { clear = true })
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  pattern = "*",
  group = number_toggle_group,
  desc = "togger line number",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
    end
  end,
})

api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = number_toggle_group,
  desc = "togger line number",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
})

api.nvim_create_autocmd("ColorScheme", {
  group = api.nvim_create_augroup("custom_highlight", { clear = true }),
  pattern = "*",
  desc = "Define or overrride some highlight groups",
  callback = function()
    -- For yank highlight
    vim.api.nvim_set_hl(0, "YankColor", { fg = "#34495E", bg = "#2ECC71", ctermfg = 59, ctermbg = 41 })

    -- For cursor colors, see option guicursor for more info
    vim.api.nvim_set_hl(0, "Cursor", { fg = "black", bg = "#00c918", bold = true, update = true })
    vim.api.nvim_set_hl(0, "Cursor2", { fg = "red", bg = "red", update = true }) -- user decision: keep red (upstream: fg None, bg yellow)

    -- For floating windows border highlight
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "LightGreen", bg = "None", bold = true, update = true })

    -- change the background color of floating window to None, so it blenders better
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "None", update = true })

    -- transparent popup menu (from upstream; user decision: yes)
    vim.api.nvim_set_hl(0, "Pmenu", { bg = "None", update = true })

    -- highlight for matching parentheses
    vim.api.nvim_set_hl(0, "MatchParen", { bold = true, underline = true, update = true })

    -- vim-illuminate (F2)
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { reverse = true, update = true })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { reverse = true, update = true })
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { reverse = true, update = true })
  end,
})

api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  group = api.nvim_create_augroup("auto_close_win", { clear = true }),
  desc = "Quit Nvim if we have only one window, and its filetype match our pattern",
  ---@diagnostic disable-next-line: unused-local
  callback = function(context)
    local quit_filetypes = { "qf", "aerial", "NvimTree" }

    local should_quit = true
    local tabwins = api.nvim_tabpage_list_wins(0)

    for _, win in pairs(tabwins) do
      local buf = api.nvim_win_get_buf(win)
      local buf_type = vim.api.nvim_get_option_value("filetype", { buf = buf })

      if not vim.tbl_contains(quit_filetypes, buf_type) then
        should_quit = false
      end
    end

    if should_quit then
      vim.cmd("qall")
    end
  end,
})

api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  group = api.nvim_create_augroup("git_repo_check", { clear = true }),
  pattern = "*",
  desc = "check if we are inside Git repo",
  callback = function()
    utils.inside_git_repo()
  end,
})


-- check if current file is formatted (upstream bc2c11e/8e4bf54, adapted: async + silent executable guard)
local ft_to_command = {
  python = { "black", "--check", "--quiet" },
  lua = { "stylua", "--check" },
}

api.nvim_create_autocmd("BufWritePost", {
  group = api.nvim_create_augroup("format_check", { clear = true }),
  pattern = "*",
  desc = "Check if file needs reformat",
  callback = function(ev)
    local ft = api.nvim_get_option_value("filetype", { buf = ev.buf })
    local base = ft_to_command[ft]
    if not base or vim.fn.executable(base[1]) == 0 then
      return
    end
    local cmd = vim.deepcopy(base)
    table.insert(cmd, ev.file)
    vim.system(cmd, { text = true }, function(result)
      if result.code ~= 0 then
        vim.schedule(function()
          vim.notify(string.format("%s: file is not formatted (%s)", vim.fs.basename(ev.file), base[1]), vim.log.levels.WARN)
        end)
      end
    end)
  end,
})
