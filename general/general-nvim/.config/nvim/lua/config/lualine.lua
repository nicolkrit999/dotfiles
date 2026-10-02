local fn = vim.fn
local utils = require("utils")

--- git repo root of the current buffer (unnamed / special buffers: of the cwd), nil outside a repo
local function buf_repo_root()
  return vim.fs.root(0, ".git")
end

-- ahead/behind state for ONE repo (the current buffer's); reset when the repo changes
local FETCH_INTERVAL_MS = 60 * 1000 -- at most one `git fetch origin` per repo per minute
local COUNT_INTERVAL_MS = 5 * 1000 -- local ahead/behind recount (cheap, no network)
local git_state = { root = nil, ahead = 0, behind = 0, running = false }
local last_fetch = {} -- root -> vim.uv.now() of the last fetch start
local last_count = {} -- root -> vim.uv.now() of the last recount start
local fetch_ok = {} -- root -> true once `git fetch origin` succeeded there

--- vim.system that never throws and never asks anywhere (GIT_TERMINAL_PROMPT=0, GIT_ASKPASS/SSH_ASKPASS=true);
--- on_exit always runs (code -1 on spawn failure)
local function git_async(root, args, on_exit)
  -- background-only: never pop up a prompt (terminal, askpass GUI or credential helper dialog)
  local cmd = vim.list_extend({ "git", "-c", "credential.interactive=never" }, args)
  local ok = pcall(vim.system, cmd, {
    cwd = root,
    text = true,
    timeout = 30000,
    env = { GIT_TERMINAL_PROMPT = "0", GIT_ASKPASS = "true", SSH_ASKPASS = "true" },
  }, on_exit)
  if not ok then
    on_exit { code = -1, stdout = "", stderr = "" }
  end
end

local function update_ahead_behind(root)
  local now = vim.uv.now()
  local want_fetch = not last_fetch[root] or now - last_fetch[root] >= FETCH_INTERVAL_MS
  local want_count = want_fetch or not last_count[root] or now - last_count[root] >= COUNT_INTERVAL_MS
  if git_state.running or not want_count then
    return
  end
  git_state.running = true
  last_count[root] = now
  if want_fetch then
    last_fetch[root] = now
  end

  local function count()
    -- the @{upstream} notation is inspired by post: https://www.reddit.com/r/neovim/comments/t48x5i/git_branch_aheadbehind_info_status_line_component/
    -- --left-right with three dots: "<only in upstream>\t<only in HEAD>" = behind, ahead
    git_async(root, { "rev-list", "--left-right", "--count", "@{upstream}...HEAD" }, function(r)
      git_state.running = false
      if git_state.root ~= root then
        return -- the buffer switched to another repo meanwhile
      end
      local behind, ahead = (r.stdout or ""):match("(%d+)%s+(%d+)")
      -- fails e.g. when the branch has no upstream: show nothing instead of old numbers
      git_state.behind = r.code == 0 and tonumber(behind) or 0
      git_state.ahead = r.code == 0 and tonumber(ahead) or 0
    end)
  end

  -- as before: numbers only for a repo whose `origin` could be fetched (at least once)
  local function count_if_fetched()
    if fetch_ok[root] then
      return count()
    end
    git_state.running = false
  end

  if not want_fetch then
    return count_if_fetched()
  end
  -- fetch only from an existing `origin` remote
  git_async(root, { "remote" }, function(r)
    local has_origin = r.code == 0 and vim.list_contains(vim.split(r.stdout or "", "\n", { trimempty = true }), "origin")
    if not has_origin then
      fetch_ok[root] = nil
      return count_if_fetched()
    end
    git_async(root, { "fetch", "--quiet", "origin" }, function(f)
      if f.code == 0 then
        fetch_ok[root] = true
      end
      count_if_fetched()
    end)
  end)
end

local function get_git_ahead_behind_info()
  if fn.executable("git") == 0 then
    return ""
  end
  local root = buf_repo_root()
  if root ~= git_state.root then
    -- another repo (or none): forget the previous repo's numbers
    git_state.root, git_state.ahead, git_state.behind = root, 0, 0
  end
  if not root then
    return ""
  end
  update_ahead_behind(root)

  local msg = ""
  if git_state.ahead > 0 then
    msg = msg .. string.format("↑[%d] ", git_state.ahead)
  end
  if git_state.behind > 0 then
    msg = msg .. string.format("↓[%d] ", git_state.behind)
  end
  return msg
end

local function spell()
  if vim.o.spell then
    return "[SPELL]"
  end

  return ""
end

--- show indicator for Chinese IME
local function ime_state()
  -- needs the xkbswitch library path (vim-xkbswitch's g:XkbSwitchLib); without it there is nothing to ask
  if vim.g.is_mac and vim.g.XkbSwitchLib then
    -- ref: https://github.com/vim-airline/vim-airline/blob/master/autoload/airline/extensions/xkblayout.vim#L11
    local ok, layout = pcall(fn.libcall, vim.g.XkbSwitchLib, "Xkb_Switch_getXkbLayout", "")
    if not ok or type(layout) ~= "string" then
      return ""
    end

    -- We can use `xkbswitch -g` on the command line to get current mode.
    -- mode for macOS builtin pinyin IME: com.apple.inputmethod.SCIM.ITABC
    -- mode for Rime: im.rime.inputmethod.Squirrel.Rime
    local res = fn.match(layout, [[\v(Squirrel\.Rime|SCIM.ITABC)]])
    if res ~= -1 then
      return "[CN]"
    end
  end

  return ""
end

--- One pass over the buffer for both white-space checks (Lua string.find runs in C; measured about
--- 2x faster than a regex search() on a 200k-line buffer). Results are 1-based line numbers or nil.
local function scan_whitespace(buf)
  local n = vim.api.nvim_buf_line_count(buf)
  local r = { space_cnt = 0, tab_cnt = 0 }
  local CHUNK = 5000
  for s = 0, n - 1, CHUNK do
    local lines = vim.api.nvim_buf_get_lines(buf, s, math.min(s + CHUNK, n), false)
    for i, l in ipairs(lines) do
      local lnum = s + i
      -- trailing white space = Vim's \s (space or tab) at the end of the line
      if not r.trailing and l:find("[ \t]$") then
        r.trailing = lnum
      end
      local c = l:byte(1)
      if c == 32 then -- indented with spaces
        r.space_cnt = r.space_cnt + 1
        r.first_space = r.first_space or lnum
        if not r.first_same and l:find("^ +\t") then
          r.first_same = lnum
        end
      elseif c == 9 then -- indented with tabs
        r.tab_cnt = r.tab_cnt + 1
        r.first_tab = r.first_tab or lnum
        if not r.first_same and l:find("^\t+ ") then
          r.first_same = lnum
        end
      end
    end
  end
  return r
end

-- the scan runs at most once per buffer change (b:changedtick), not on every redraw
local ws_cache = {} -- bufnr -> { tick = changedtick, result = scan_whitespace() }

local function whitespace_info()
  local buf = vim.api.nvim_get_current_buf()
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local c = ws_cache[buf]
  -- every typed key is a change: while in insert mode keep the last result, rescan after leaving it
  if c and vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
    return c.result
  end
  if not c or c.tick ~= tick then
    c = { tick = tick, result = scan_whitespace(buf) }
    ws_cache[buf] = c
  end
  return c.result
end

vim.api.nvim_create_autocmd("BufWipeout", {
  group = vim.api.nvim_create_augroup("lualine_ws_cache", { clear = true }),
  callback = function(ev)
    ws_cache[ev.buf] = nil
  end,
  desc = "lualine: drop the whitespace-check cache of a wiped buffer",
})

local function trailing_space()
  -- do not warn while typing (insert mode, incl. ic/ix completion sub-modes)
  if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
    return ""
  end

  if not vim.o.modifiable then
    return ""
  end

  -- FIRST line with trailing white space
  local line_num = whitespace_info().trailing
  return line_num and string.format("[%d]trailing", line_num) or ""
end

local function mixed_indent()
  if not vim.o.modifiable then
    return ""
  end

  local w = whitespace_info()
  if w.first_space and w.first_tab then
    -- both kinds of indent in the buffer: the FIRST line of the less used kind is the offender
    return "MI:" .. (w.space_cnt > w.tab_cnt and w.first_tab or w.first_space)
  end
  if w.first_same then
    -- tabs and spaces mixed inside one line's indent: the FIRST such line
    return "MI:" .. w.first_same
  end
  return ""
end

-- show encoding only when it is not UTF-8
local function show_encoding()
  local fileencoding = vim.api.nvim_get_option_value("fileencoding", { buf = 0 })
  fileencoding = string.upper(fileencoding)
  if fileencoding ~= "UTF-8" and fileencoding ~= "" then
    return fileencoding
  end
  return ""
end

-- show fileformat only when it is not unix
local function show_fileformat()
  local fileformat = vim.api.nvim_get_option_value("fileformat", { buf = 0 })
  -- unix is the common case, do not show it
  if fileformat == "unix" then
    return ""
  end
  local symbols = { dos = "win", mac = "mac" }
  return symbols[fileformat] or fileformat
end

local diff = function()
  local git_status = vim.b.gitsigns_status_dict
  if git_status == nil then
    return
  end

  local modify_num = git_status.changed
  local remove_num = git_status.removed
  local add_num = git_status.added

  return { added = add_num, modified = modify_num, removed = remove_num }
end

local virtual_env = function()
  -- only show virtual env for Python
  if vim.bo.filetype ~= "python" then
    return ""
  end

  local venv_name, kind = utils.get_virtual_env()
  if kind == nil then
    return ""
  end
  return string.format("  %s (%s)", venv_name, kind)
end

local get_active_lsp = function()
  local msg = "🚫"
  local names = require("lsp_utils").get_attached_lsp()
  if next(names) == nil then
    return msg
  end

  local buf_ft = vim.bo.filetype
  local main_lsp = require("lsp_utils").main_lsp_by_filetype[buf_ft]
  if main_lsp == nil or not vim.list_contains(names, main_lsp) then
    -- fallback (user's original logic): first client whose filetypes include buf_ft
    for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
      ---@diagnostic disable-next-line: undefined-field
      local fts = client.config.filetypes
      if fts and vim.list_contains(fts, buf_ft) then
        main_lsp = client.name
        break
      end
    end
  end
  names = require("utils").reorder_list_element(names, main_lsp)

  if #names == 1 then
    return names[1]
  end
  return string.format("%s (+%d)", names[1], #names - 1)
end

--- "#rrggbb" of a highlight attribute ("fg"/"bg") of the ACTIVE colorscheme, nil when the theme leaves it unset
local function theme_hex(group, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  local v = ok and hl[attr]
  return v and string.format("#%06x", v) or nil
end

-- component colours are FUNCTIONS: lualine re-evaluates them, so they follow :colorscheme (no fixed hex)
local colors = {
  -- text in the theme's warning colour
  warn_text = function()
    return { fg = theme_hex("DiagnosticWarn", "fg") }
  end,
  -- "badge": editor background colour as text on a theme accent
  badge = function(accent_group)
    return function()
      return { fg = theme_hex("Normal", "bg"), bg = theme_hex(accent_group, "fg") }
    end
  end,
  special_bold = function()
    return { fg = theme_hex("Special", "fg") or theme_hex("DiagnosticInfo", "fg"), gui = "bold" }
  end,
}

-- statusline click handlers (upstream 7b30596, adapted: vim.ui.select / snacks picker for branches)
--- run git synchronously in `root`; returns the output lines, or nil + error text
local function git_lines(root, args)
  local ok, r = pcall(function()
    return vim.system(vim.list_extend({ "git" }, args), {
      cwd = root,
      text = true,
      env = { GIT_TERMINAL_PROMPT = "0", GIT_ASKPASS = "true", SSH_ASKPASS = "true" },
    }):wait()
  end)
  if not ok then
    return nil, tostring(r)
  end
  if r.code ~= 0 then
    return nil, r.stderr or ""
  end
  return vim.split(r.stdout or "", "\n", { trimempty = true })
end

local show_branch_menu = function()
  if fn.executable("git") == 0 then
    vim.notify("git not found", vim.log.levels.WARN)
    return
  end
  -- the repo of the current buffer, not nvim's cwd
  local root = buf_repo_root()
  if not root then
    vim.notify("not in a git repository", vim.log.levels.WARN)
    return
  end
  local locals = git_lines(root, { "for-each-ref", "--format=%(refname:short)", "refs/heads/" })
  -- "<remote>/<branch>\t<branch>" (lstrip=3 drops refs/remotes/<remote>/, keeps slashes in the branch)
  local remotes = git_lines(root, {
    "for-each-ref",
    "--format=%(refname:short)%09%(refname:lstrip=3)",
    "refs/remotes/",
  })
  if not locals or not remotes then
    vim.notify("error fetching git branch", vim.log.levels.WARN)
    return
  end
  local is_local_branch = {}
  local items = {}
  for _, b in ipairs(locals) do
    is_local_branch[b] = true
    table.insert(items, { name = b, is_local = true })
  end
  for _, line in ipairs(remotes) do
    local name, branch = line:match("^(.-)\t(.*)$")
    -- skip the symbolic refs/remotes/<remote>/HEAD (no `--exclude`: that needs git >= 2.42)
    if name and branch ~= "HEAD" then
      table.insert(items, { name = name, is_local = false, branch = branch })
    end
  end
  if #items == 0 then
    return
  end
  vim.ui.select(items, {
    prompt = "Git branches",
    format_item = function(item)
      return (item.is_local and "\u{f47f} " or "\u{f0c2} ") .. item.name
    end,
  }, function(item)
    if not item then
      return
    end
    local args
    if item.is_local then
      args = { "checkout", item.name }
    elseif is_local_branch[item.branch] then
      -- remote branch that already exists locally (origin/main -> main): switch to the local one
      args = { "checkout", item.branch }
    else
      args = { "checkout", "--track", item.name }
    end
    local out, err = git_lines(root, args)
    if not out then
      vim.notify("failed to switch branch:\n" .. (err or ""), vim.log.levels.ERROR)
    else
      vim.cmd("checktime")
    end
  end)
end

-- same popup as :LspAttached
local show_lsp_menu = function()
  vim.cmd("LspAttached")
end

require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = "auto",
    component_separators = { left = "\\", right = "/" },
    section_separators = { left = "\u{e0b8}", right = "\u{e0ba}" },
    always_divide_middle = false,
    refresh = {
      statusline = 1000,
    },
  },
  sections = {
    lualine_a = {
      {
        "filename",
        symbols = {
          readonly = "\u{f0221}",
        },
      },
    },
    lualine_b = {
      {
        "branch",
        icon = "\u{f47f}",
        on_click = show_branch_menu,
        fmt = function(name, _)
          -- truncate branch name in case the name is too long
          return string.sub(name, 1, 20)
        end,
        color = { gui = "italic,bold" },
      },
      {
        get_git_ahead_behind_info,
        color = colors.warn_text,
      },
      {
        "diff",
        source = diff,
      },
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        color = { gui = "bold" },
        -- same glyphs as the sign column (lua/diagnostic-conf.lua)
        symbols = { error = "\u{F015A} ", warn = "\u{F002A} ", info = "\u{F02FD} ", hint = "\u{F0336} " },
      },
      {
        virtual_env,
        color = colors.badge("DiagnosticWarn"),
      },
    },
    lualine_c = {
      {
        "%S",
        color = colors.special_bold,
      },
      {
        spell,
        color = colors.badge("String"),
      },
    },
    lualine_x = {
      {
        get_active_lsp,
        icon = "\u{f013}",
        on_click = show_lsp_menu,
      },
      {
        trailing_space,
        color = "WarningMsg",
      },
      {
        mixed_indent,
        color = "WarningMsg",
      },
    },
    lualine_y = {
      {
        show_encoding,
        color = "ErrorMsg",
      },
      {
        show_fileformat,
        color = "ErrorMsg",
      },
      {
        ime_state,
        color = colors.badge("DiagnosticError"),
      },
    },
    lualine_z = {
      "progress",
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = { "quickfix", "fugitive", "nvim-tree" },
}
