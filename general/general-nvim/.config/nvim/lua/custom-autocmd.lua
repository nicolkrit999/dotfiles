local fn = vim.fn
local api = vim.api

local utils = require("utils")

-- Display a message when the current file is not in utf-8 format.
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

-- keep the cursor where it was after a yank (e.g. `yip` does not jump to the paragraph start)
local yank_cursor_group = api.nvim_create_augroup("yank_keep_cursor", { clear = true })
api.nvim_create_autocmd({ "CursorMoved" }, {
  pattern = "*",
  group = yank_cursor_group,
  desc = "remember the cursor position (restored after a yank)",
  callback = function()
    vim.g.current_cursor_pos = vim.fn.getcurpos()
  end,
})

api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  group = yank_cursor_group,
  desc = "restore the cursor position after a yank",
  callback = function()
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
-- A deletion is reported once per buffer (claude-code's refresh timer runs :checktime every second
-- while its panel is open); the flag is cleared when the file exists again.
api.nvim_create_autocmd({ "FileChangedShellPost" }, {
  pattern = "*",
  group = "auto_read",
  callback = function(ev)
    if ev.file ~= "" and vim.uv.fs_stat(ev.file) == nil then
      if not vim.b[ev.buf].deleted_notified then
        vim.b[ev.buf].deleted_notified = true
        vim.notify("File deleted on disk (buffer kept)", vim.log.levels.WARN, { title = "nvim-config" })
      end
      return
    end
    vim.b[ev.buf].deleted_notified = nil
    if vim.bo[ev.buf].modified then
      -- W12 conflict answered with [O]K: the buffer was NOT reloaded
      vim.notify("File changed on disk and in the buffer (buffer kept)", vim.log.levels.WARN, { title = "nvim-config" })
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


-- Resize all windows when we resize the terminal; the Claude Code panel goes back to its
-- configured width (claude-code's window.split_ratio, set in plugin_specs.lua) instead of an equal share
api.nvim_create_autocmd("VimResized", {
  group = api.nvim_create_augroup("win_autoresize", { clear = true }),
  desc = "autoresize windows on resizing operation (Claude Code panel back to 30%)",
  callback = function()
    vim.cmd("wincmd =")

    local ok, cc = pcall(require, "claude-code")
    if not ok or type(cc) ~= "table" or not cc.claude_code then
      return
    end
    local claude_bufs = {}
    for _, b in pairs(cc.claude_code.instances or {}) do
      claude_bufs[b] = true
    end
    if next(claude_bufs) == nil then
      return
    end
    local ratio = (cc.config and cc.config.window and cc.config.window.split_ratio) or 0.3
    local width = math.floor(vim.o.columns * ratio)
    local pinned = {}
    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
      if claude_bufs[api.nvim_win_get_buf(win)] and api.nvim_win_get_config(win).relative == "" then
        pcall(api.nvim_win_set_width, win, width)
        pinned[win] = vim.wo[win].winfixwidth
        vim.wo[win].winfixwidth = true
      end
    end
    -- equalise the other windows around the pinned Claude panel (they share what is left exactly)
    vim.cmd("wincmd =")
    for win, was_fixed in pairs(pinned) do
      if api.nvim_win_is_valid(win) then
        vim.wo[win].winfixwidth = was_fixed
      end
    end
  end,
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
  callback = function(data)
    -- scheduled, outside VimEnter: wiping the dir buffer inside the event skipped the remaining
    -- VimEnter autocmds, and the cd's DirChanged (git repo check) would not fire (not nested)
    vim.schedule(function()
      if api.nvim_buf_is_valid(data.buf) then
        open_nvim_tree(data)
      end
    end)
  end,
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
  desc = "relative line numbers on (focused window)",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
    end
  end,
})

api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = number_toggle_group,
  desc = "relative line numbers off (unfocused window / insert mode)",
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
})

api.nvim_create_autocmd("ColorScheme", {
  group = api.nvim_create_augroup("custom_highlight", { clear = true }),
  pattern = "*",
  desc = "Define or override some highlight groups",
  callback = function()
    -- Yank flash, cursor and float border: colours come from the ACTIVE colorscheme's own
    -- groups (no fixed hex). A theme lacking the source group gets a link to an existing group.
    local function get(name)
      local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
      return ok and hl or {}
    end

    -- For yank highlight: the theme's search highlight (IncSearch, else Search), else Visual.
    -- A group drawn with `reverse` (elflord, torte, ...) has its fg/bg swapped here: copying the
    -- raw values without the attribute would give black-on-black or the wrong colours.
    local normal = get("Normal")
    local function effective(hl)
      local fg, bg = hl.fg or normal.fg, hl.bg or normal.bg
      if hl.reverse then
        fg, bg = bg, fg
      end
      return fg, bg
    end
    local yank_fg, yank_bg
    for _, group in ipairs { "IncSearch", "Search" } do
      yank_fg, yank_bg = effective(get(group))
      if yank_bg then
        break
      end
    end
    if yank_bg then
      vim.api.nvim_set_hl(0, "YankColor", { fg = yank_fg or normal.bg, bg = yank_bg })
    else
      vim.api.nvim_set_hl(0, "YankColor", { link = "Visual" })
    end

    -- For cursor colors, see option guicursor for more info: inverse of the theme's Normal
    -- (bold). Without both Normal colours (transparent theme) only bold is added and the
    -- theme's own Cursor colours stay.
    if normal.fg and normal.bg then
      vim.api.nvim_set_hl(0, "Cursor", { fg = normal.bg, bg = normal.fg, bold = true, update = true })
    else
      vim.api.nvim_set_hl(0, "Cursor", { bold = true, update = true })
    end
    vim.api.nvim_set_hl(0, "Cursor2", { fg = "red", bg = "red", update = true }) -- user decision: keep red (upstream: fg None, bg yellow)

    -- For floating windows border highlight: the theme's Function colour (bold, no bg);
    -- a theme without it links to WinSeparator
    local border = get("Function")
    if border.fg then
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = border.fg, bg = "None", bold = true, update = true })
    else
      vim.api.nvim_set_hl(0, "FloatBorder", { link = "WinSeparator" })
    end

    -- change the background color of floating window to None, so it blends better
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
  desc = "Close the tab (quit Nvim on the last tab) when only qf/aerial/NvimTree windows are left in it",
  callback = function()
    local quit_filetypes = { qf = true, aerial = true, NvimTree = true }

    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
      -- floating windows (notifications, popups) do not keep the tab alive
      if api.nvim_win_get_config(win).relative == "" then
        local buf = api.nvim_win_get_buf(win)
        if not quit_filetypes[vim.bo[buf].filetype] then
          return
        end
      end
    end

    if #api.nvim_list_tabpages() == 1 then
      -- scheduled: a :qall run inside this autocmd would skip the (non-nested) VimLeavePre
      -- autocmds, e.g. persistence.nvim's session save
      vim.schedule(function()
        vim.cmd("qall")
      end)
      return
    end

    -- other tabs exist: close only this one
    local tab = api.nvim_get_current_tabpage()
    local ok = pcall(vim.cmd.tabclose)
    if not ok then
      -- e.g. E1312 (window layout locked during this autocmd): retry once the event is done
      vim.schedule(function()
        if api.nvim_tabpage_is_valid(tab) and #api.nvim_list_tabpages() > 1 then
          vim.cmd.tabclose(api.nvim_tabpage_get_number(tab))
        end
      end)
    end
  end,
})

-- Git plugins (fugitive, neogit, gitlinker) load on `User InGitRepo`. It fires when the cwd is in a
-- repo (VimEnter / DirChanged) or when an opened file is in a repo (async check below, cwd may be
-- outside any repo).
local git_group = api.nvim_create_augroup("git_repo_check", { clear = true })
local git_fired = false -- User InGitRepo has fired at least once

api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  group = git_group,
  pattern = "*",
  desc = "check if we are inside Git repo",
  callback = function()
    if utils.inside_git_repo() then
      git_fired = true
    end
  end,
})

local git_checked_dirs = {} -- dirs already checked (or being checked) by the file check: one job per dir
local git_file_au
git_file_au = api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = git_group,
  desc = "check if the opened file is inside a Git repo (non-blocking, until it fires once)",
  callback = function(ev)
    if git_fired then
      return true -- delete this autocmd
    end
    if vim.bo[ev.buf].buftype ~= "" or fn.executable("git") == 0 then
      return
    end
    local name = api.nvim_buf_get_name(ev.buf)
    if name == "" or name:match("^%a[%w+.-]*://") then
      return
    end
    -- directory of the file; for a new file in a directory that does not exist yet, the nearest
    -- existing parent
    local dir = vim.fs.dirname(vim.fs.normalize(fn.fnamemodify(name, ":p")))
    while not vim.uv.fs_stat(dir) do
      local parent = vim.fs.dirname(dir)
      if parent == dir then
        return
      end
      dir = parent
    end
    if git_checked_dirs[dir] then
      return
    end
    git_checked_dirs[dir] = true
    local ok = pcall(vim.system, { "git", "-C", dir, "rev-parse", "--is-inside-work-tree" }, { text = true }, function(res)
      if res.code == 0 then
        vim.schedule(function()
          if git_fired then
            return
          end
          git_fired = true
          vim.cmd("doautocmd <nomodeline> User InGitRepo")
          pcall(api.nvim_del_autocmd, git_file_au)
        end)
      end
    end)
    if not ok then
      git_checked_dirs[dir] = nil -- the job did not start: check this dir again next time
    end
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
      if result.code == 0 then
        return
      end
      local name = vim.fs.basename(ev.file)
      local msg
      if result.code == 1 then
        -- exit 1 = the check ran and found formatting differences (stylua and black)
        msg = string.format("%s: file is not formatted (%s)", name, base[1])
      else
        -- other codes = the tool could not check the file (syntax error, crash, ...)
        local first = vim.split(vim.trim(result.stderr or ""), "\n", { plain = true })[1] or ""
        msg = string.format("%s: %s could not check the file (syntax error?)", name, base[1])
        if first ~= "" then
          msg = msg .. "\n" .. first
        end
      end
      vim.schedule(function()
        vim.notify(msg, vim.log.levels.WARN)
      end)
    end)
  end,
})

-- Spell: the *.add word lists are tracked, their compiled *.add.spl are not (gitignored). Vim only
-- compiles an .add file when you `zg` a word, so on a fresh checkout (or after a `git pull` that
-- changed a list) the words would be flagged until then. At VimEnter, silently run :mkspell! for
-- every list in 'spellfile' whose .spl is missing or older. Never errors: a read-only spell dir
-- (nix store, other user) or a failing :mkspell just leaves things as they are.
api.nvim_create_autocmd("VimEnter", {
  group = api.nvim_create_augroup("spell_rebuild", { clear = true }),
  desc = "Rebuild stale spell/*.add.spl word-list binaries",
  callback = function()
    vim.schedule(function()
      -- 'spellfile' is a comma list of the per-language .add files (see lua/options.lua)
      for _, add in ipairs(vim.split(vim.o.spellfile, ",", { plain = true, trimempty = true })) do
        local spl = add .. ".spl"
        local add_time = vim.fn.getftime(add)
        -- getftime() is -1 for a missing file: no .add, nothing to compile
        if add_time > 0 and vim.fn.filewritable(vim.fs.dirname(add)) == 2 and add_time > vim.fn.getftime(spl) then
          pcall(vim.cmd, "silent mkspell! " .. vim.fn.fnameescape(add))
        end
      end
    end)
  end,
})

-- lazy.nvim's dimming float (filetype `lazy_backdrop`) is opened without a border, so it inherits
-- the global 'winborder' and :Lazy shows a second, full-screen frame around the editor. lazy sets
-- the filetype right after opening the window: strip the border there. Lazy's own window keeps
-- its rounded frame (`ui.border`).
api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("lazy_backdrop_noborder", { clear = true }),
  pattern = "lazy_backdrop",
  desc = "No 'winborder' frame on lazy.nvim's backdrop window",
  callback = function(ev)
    for _, win in ipairs(fn.win_findbuf(ev.buf)) do
      if api.nvim_win_get_config(win).relative ~= "" then
        pcall(api.nvim_win_set_config, win, { border = "none" })
      end
    end
  end,
})
