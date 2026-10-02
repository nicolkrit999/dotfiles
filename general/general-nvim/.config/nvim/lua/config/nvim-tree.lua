local keymap = vim.keymap
local nvim_tree = require("nvim-tree")

-- Custom logic to remap our keys
local function my_on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- 1. Load the default mappings first
  api.config.mappings.default_on_attach(bufnr)

  -- 2. Create custom "Open and Stay" action
  local function open_and_keep_focus()
    local node = api.tree.get_node_under_cursor()
    if node and (node.type == "file" or (node.type == "link" and not node.nodes)) then
      -- Open the file in the main window (adds to your bufferline tabs)
      api.node.open.edit()
      -- Instantly snap the cursor back to the tree
      api.tree.focus()
    else
      -- If it's a folder, just open/close it normally
      api.node.open.edit()
    end
  end

  -- 3. Bind custom action to the <Tab> key
  vim.keymap.set('n', '<Tab>', open_and_keep_focus, opts('Open & Keep Focus'))
end


-- Window picker for <Enter> on a file when several editor windows are open. Same behaviour as
-- nvim-tree's own picker (a letter in the middle of each window's status line, press the letter,
-- anything else cancels), but vimade is switched off while the letters are shown and switched on
-- again afterwards: vimade dims the status lines of inactive windows, which made the letters
-- almost invisible. Nothing here depends on timing: `:VimadeDisable` un-dims synchronously (it
-- sets g:vimade_running = 0, stops the timer and removes the highlights), the picker then blocks
-- on the key press, and the `finally`-style restore below always runs.
local picker_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
local picker_exclude = {
  filetype = { "notify", "qf", "diff", "fugitive", "fugitiveblame" },
  buftype = { "nofile", "terminal", "help" },
}

local function pick_window()
  local chars = picker_chars
  local excluded_ft = vim.iter(picker_exclude.filetype):fold({}, function(t, v) t[v] = true return t end)
  local excluded_bt = vim.iter(picker_exclude.buftype):fold({}, function(t, v) t[v] = true return t end)
  local ok_view, tree_win = pcall(function()
    return require("nvim-tree.view").get_winnr()
  end)
  if not ok_view or not tree_win then
    tree_win = vim.api.nvim_get_current_win()
  end

  local selectable = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local cfg = vim.api.nvim_win_get_config(win)
    if win ~= tree_win and cfg.focusable and not cfg.hide and not cfg.external
        and not excluded_ft[vim.bo[buf].filetype] and not excluded_bt[vim.bo[buf].buftype] then
      selectable[#selectable + 1] = win
    end
  end
  if #selectable == 0 then
    return -1 -- nvim-tree falls back to its default target window
  end
  if #selectable == 1 then
    return selectable[1]
  end
  if #selectable > #chars then
    vim.notify("nvim-tree: more windows than window picker letters", vim.log.levels.WARN)
    return nil
  end

  local saved, win_of = {}, {}
  local laststatus = vim.o.laststatus
  local fillchars = vim.o.fillchars
  local vimade_was_on = vim.fn.exists(":VimadeDisable") == 2 and vim.g.vimade_running == 1

  local function restore()
    for win, o in pairs(saved) do
      if vim.api.nvim_win_is_valid(win) then
        vim.wo[win].statusline = o.statusline
        vim.wo[win].winhl = o.winhl
      end
    end
    vim.o.fillchars = fillchars
    vim.o.laststatus = laststatus
    if vimade_was_on then
      pcall(vim.cmd, "VimadeEnable")
    end
  end

  local ok, resp = pcall(function()
    if vimade_was_on then
      vim.cmd("VimadeDisable")
    end
    vim.o.laststatus = 2
    -- stl/stlnc fill characters would draw the status line background with '^' / '='
    vim.opt.fillchars:remove({ "stl", "stlnc" })
    for i, win in ipairs(selectable) do
      local char = chars:sub(i, i)
      saved[win] = { statusline = vim.wo[win].statusline, winhl = vim.wo[win].winhl }
      win_of[char] = win
      vim.wo[win].statusline = "%=" .. char .. "%="
      vim.wo[win].winhl = "StatusLine:NvimTreeWindowPicker,StatusLineNC:NvimTreeWindowPicker"
    end
    vim.cmd("redraw")
    if vim.o.cmdheight ~= 0 then
      print("Pick window: ")
    end
    local c = vim.fn.getchar()
    while type(c) ~= "number" do
      c = vim.fn.getchar()
    end
    return vim.fn.nr2char(c):upper()
  end)
  restore()
  vim.cmd("redraw | echo ''")

  if not ok then
    if not tostring(resp):find("Keyboard interrupt", 1, true) then -- Ctrl-C cancels silently
      vim.notify("nvim-tree window picker failed: " .. tostring(resp), vim.log.levels.WARN)
    end
    return nil
  end
  return win_of[resp] -- nil (cancel) for any other key
end

nvim_tree.setup {
  on_attach = my_on_attach,
  auto_reload_on_write = true,
  disable_netrw = false,
  hijack_netrw = true,
  hijack_cursor = false,
  hijack_unnamed_buffer_when_opening = false,
  tab = { sync = { open = false, close = false } },
  sort = { sorter = "name" },
  -- the tree root follows :cd / :tcd / :Z / :z (it keeps its folder until the working folder changes)
  sync_root_with_cwd = true,
  view = {
    width = {
      min = 30,
      max = "50%",
      padding = 4,
    },
    side = "left",
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
  },
  renderer = {
    indent_markers = {
      enable = false,
      icons = {
        corner = "└ ",
        edge = "│ ",
        none = "  ",
      },
    },
    icons = {
      web_devicons = { file = { color = true } },
    },
  },
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  update_focused_file = {
    enable = false,
    update_root = {
      enable = false,
      ignore_list = {},
    },
  },
  diagnostics = {
    enable = false,
    show_on_dirs = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  filters = {
    dotfiles = false,
    git_ignored = true,
    custom = {},
    exclude = {},
  },
  git = {
    enable = true,
    timeout = 10000,
  },
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,
      global = false,
      restrict_above_cwd = false,
    },
    open_file = {
      quit_on_open = false,
      resize_window = false,
      window_picker = {
        enable = true,
        picker = pick_window,
        chars = picker_chars,
        exclude = picker_exclude,
      },
    },
  },
  trash = {
    cmd = "trash",
  },
  ui = { confirm = { trash = true } },
  log = {
    enable = false,
    truncate = false,
    types = {
      all = false,
      config = false,
      copy_paste = false,
      diagnostics = false,
      git = false,
      profile = false,
    },
  },
}

keymap.set("n", "<space>s", require("nvim-tree.api").tree.toggle, {
  silent = true,
  desc = "toggle nvim-tree",
})
