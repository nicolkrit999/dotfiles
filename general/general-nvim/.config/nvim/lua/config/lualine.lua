local fn = vim.fn
local utils = require("utils")

-- cache for git states
local git_status_cache = {
  fetch_success = false,
  behind_count = 0,
  ahead_count = 0,
}

local on_exit_fetch = function(result)
  if result.code == 0 then
    git_status_cache.fetch_success = true
  end
end

local function handle_numeric_result(cache_key)
  return function(result)
    if result.code == 0 then
      git_status_cache[cache_key] = tonumber(result.stdout:match("(%d+)")) or 0
    else
      -- git rev-list fails e.g. when the current branch has no upstream;
      -- reset the count so the previous branch's numbers do not linger
      git_status_cache[cache_key] = 0
    end
  end
end

local async_cmd = function(cmd_str, on_exit)
  local cmd = vim.tbl_filter(function(element)
    return element ~= ""
  end, vim.split(cmd_str, " "))

  vim.system(cmd, { text = true }, on_exit)
end

local async_git_status_update = function()
  -- Fetch the latest changes from the remote repository (replace 'origin' if needed)
  async_cmd("git fetch origin", on_exit_fetch)
  if not git_status_cache.fetch_success then
    return
  end

  -- Get the number of commits behind
  -- the @{upstream} notation is inspired by post: https://www.reddit.com/r/neovim/comments/t48x5i/git_branch_aheadbehind_info_status_line_component/
  -- note that here we should use double dots instead of triple dots
  local behind_cmd_str = "git rev-list --count HEAD..@{upstream}"
  async_cmd(behind_cmd_str, handle_numeric_result("behind_count"))

  -- Get the number of commits ahead
  local ahead_cmd_str = "git rev-list --count @{upstream}..HEAD"
  async_cmd(ahead_cmd_str, handle_numeric_result("ahead_count"))
end

local function get_git_ahead_behind_info()
  async_git_status_update()

  local status = git_status_cache
  if not status then
    return ""
  end

  local msg = ""

  if type(status.ahead_count) == "number" and status.ahead_count > 0 then
    local ahead_str = string.format("↑[%d] ", status.ahead_count)
    msg = msg .. ahead_str
  end

  if type(status.behind_count) == "number" and status.behind_count > 0 then
    local behind_str = string.format("↓[%d] ", status.behind_count)
    msg = msg .. behind_str
  end

  return msg
end

local function spell()
  if vim.o.spell then
    return string.format("[SPELL]")
  end

  return ""
end

--- show indicator for Chinese IME
local function ime_state()
  if vim.g.is_mac then
    -- ref: https://github.com/vim-airline/vim-airline/blob/master/autoload/airline/extensions/xkblayout.vim#L11
    local layout = fn.libcall(vim.g.XkbSwitchLib, "Xkb_Switch_getXkbLayout", "")

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

local function trailing_space()
  -- do not warn while typing (insert mode, incl. ic/ix completion sub-modes)
  if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
    return ""
  end

  if not vim.o.modifiable then
    return ""
  end

  local line_num = nil

  for i = 1, fn.line("$") do
    local linetext = fn.getline(i)
    -- To prevent invalid escape error, we wrap the regex string with `[[]]`.
    local idx = fn.match(linetext, [[\v\s+$]])

    if idx ~= -1 then
      line_num = i
      break
    end
  end

  local msg = ""
  if line_num ~= nil then
    msg = string.format("[%d]trailing", line_num)
  end

  return msg
end

local function mixed_indent()
  if not vim.o.modifiable then
    return ""
  end

  local space_pat = [[\v^ +]]
  local tab_pat = [[\v^\t+]]
  local space_indent = fn.search(space_pat, "nwc")
  local tab_indent = fn.search(tab_pat, "nwc")
  local mixed = (space_indent > 0 and tab_indent > 0)
  local mixed_same_line
  if not mixed then
    mixed_same_line = fn.search([[\v^(\t+ | +\t)]], "nwc")
    mixed = mixed_same_line > 0
  end
  if not mixed then
    return ""
  end
  if mixed_same_line ~= nil and mixed_same_line > 0 then
    return "MI:" .. mixed_same_line
  end
  local space_indent_cnt = fn.searchcount({ pattern = space_pat, max_count = 1e3 }).total
  local tab_indent_cnt = fn.searchcount({ pattern = tab_pat, max_count = 1e3 }).total
  if space_indent_cnt > tab_indent_cnt then
    return "MI:" .. tab_indent
  else
    return "MI:" .. space_indent
  end
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

  local info = { added = add_num, modified = modify_num, removed = remove_num }
  -- vim.print(info)
  return info
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

-- statusline click handlers (upstream 7b30596, adapted: vim.ui.select / snacks picker for branches)
local show_branch_menu = function()
  local info = utils.get_git_branches()
  local items = {}
  for _, b in ipairs(info["local"]) do
    table.insert(items, { name = b, is_local = true })
  end
  for _, b in ipairs(info.remote) do
    table.insert(items, { name = b, is_local = false })
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
    local cmd = item.is_local and { "git", "checkout", item.name } or { "git", "checkout", "--track", item.name }
    local r = vim.system(cmd, { text = true }):wait()
    if r.code ~= 0 then
      vim.notify("failed to switch branch:\n" .. (r.stderr or ""), vim.log.levels.ERROR)
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
    disabled_filetypes = {},
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
        color = { fg = "#E0C479" },
      },
      {
        "diff",
        source = diff,
      },
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        color = { gui = "bold" },
        symbols = { error = "🆇 ", warn = "⚠️ ", info = "ℹ️ ", hint = " " },
      },
      {
        virtual_env,
        color = { fg = "black", bg = "#F1CA81" },
      },
    },
    lualine_c = {
      {
        "%S",
        color = { gui = "bold", fg = "cyan" },
      },
      {
        spell,
        color = { fg = "black", bg = "#a7c080" },
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
        color = { fg = "black", bg = "#f46868" },
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
