-- Snippet gallery: fuzzy-pick one of MY OWN UltiSnips snippets (my_snippets/*.snippets) and
-- insert it at the cursor, without having to remember or type its trigger.
--
-- Why a gallery: UltiSnips also loads honza/vim-snippets, which floods any completion menu or
-- `:UltiSnipsEdit` list with hundreds of built-in snippets. This picker keeps only the snippets
-- defined in `<stdpath("config")>/my_snippets`, for the filetype of the current buffer (plus
-- `all.snippets` and any `extends`), and shows the snippet body in a preview.
--
-- Usage (keys are defined at the bottom of this file; loaded from lua/config/fzf-lua.lua):
--   normal mode  <leader>fs  open the gallery; the snippet is inserted AFTER the cursor (like `a`)
--   insert mode  <C-s>       open the gallery; the snippet is inserted AT the cursor
--
-- Notes / limits:
--   * Needs fzf-lua and UltiSnips (loaded at VeryLazy); nothing is done at require time.
--   * Insertion uses UltiSnips#Anon (the same call nvim-cmp uses to expand), so the snippet is
--     expanded from its BODY: a regex trigger such as "(?<!\w)ltx" works too.
--   * Anon has no access to the file's `global !p` helpers, to `post_jump` actions or to the
--     regex `match` of a trigger. Snippets that need them are marked "(type trigger)" in the list
--     and are not inserted from the gallery (a warning explains it); type their trigger instead.
--   * The hand-off from insert mode needs a real terminal that delivers <C-s> to Neovim
--     (many terminals use <C-s> as XOFF/flow control). If it does nothing, use <leader>fs.
local M = {}

local SNIPPET_DIR = "my_snippets"

-- Resolve a path to its real location (the config dir is a nix symlink into the dotfiles repo).
---@param path string
---@return string
local function real(path)
  path = vim.fs.normalize(path)
  return vim.uv.fs_realpath(path) or path
end

-- True when `file` lives under `<config>/my_snippets` (both sides compared via realpath).
---@param file string
---@param root string  realpath of the my_snippets dir, no trailing slash
---@return boolean
local function is_mine(file, root)
  return vim.startswith(real(file), root .. "/")
end

-- `~/.config/nvim/my_snippets/java.snippets` -> "java" (also "java_extra.snippets" -> "java")
---@param file string
---@return string
local function filetype_of(file)
  local name = vim.fs.basename(file):gsub("%.snippets$", "")
  return name:match("^([^_]+)") or name
end

-- Read the snippet whose definition starts at (or just below, if `lnum` points at a modifier
-- line) `lnum` in `file`. Returns the header line, the body lines and the lines that were
-- scanned before the header (to detect a `post_jump` action), or nil when it cannot be found.
---@param file string
---@param lnum integer
---@return { header: string, body: string[], pre: string?, file_lines: string[] }?
local function read_snippet(file, lnum)
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok then return nil end
  -- UltiSnips reports the line of the `snippet` header; be tolerant of off-by-one.
  local start
  for i = lnum, math.min(lnum + 3, #lines) do
    if lines[i] and lines[i]:match("^snippet%s") then
      start = i
      break
    end
  end
  if not start then return nil end
  local body = {}
  for i = start + 1, #lines do
    if lines[i]:match("^endsnippet%s*$") then
      return { header = lines[start], body = body, pre = lines[start - 1], file_lines = lines }
    end
    body[#body + 1] = lines[i]
  end
  return nil -- unterminated snippet
end

-- Anon cannot give the snippet its file-level helpers, its `post_jump` or its trigger `match`.
---@param snip { body: string[], pre: string?, file_lines: string[] }
---@return boolean
local function needs_trigger(snip)
  local text = table.concat(snip.body, "\n")
  if snip.pre and snip.pre:match("^post_jump") then return true end
  if text:find("match%.") or text:find("match%[") then return true end
  if text:find("`!p", 1, true) or text:find("`!v", 1, true) then
    -- python blocks may call helpers from a `global !p` block of the same file
    for _, l in ipairs(snip.file_lines) do
      if l:match("^global%s+!p") then return true end
    end
  end
  return false
end

-- Parse a snippet header (`snippet <trigger> ["description"] [options]`).
-- Returns trigger, description, options; nil if it is not a header.
---@param header string
---@return string? trigger, string? desc, string? opts
local function parse_header(header)
  local rest = header:match("^snippet%s+(.-)%s*$")
  if not rest then return nil end
  local trigger
  local first = rest:sub(1, 1)
  if first:match("[%w_]") then
    trigger, rest = rest:match("^(%S+)%s*(.*)$")
  else
    -- trigger delimited by any non-word character, e.g. "(?<!\w)ltx" or !x!
    local close = rest:find(first, 2, true)
    if not close then return nil end
    -- UltiSnips lets the trigger end at the LAST delimiter before whitespace + description
    trigger, rest = rest:sub(2, close - 1), rest:sub(close + 1):match("^%s*(.*)$")
  end
  local desc = rest:match('^"(.*)"') or ""
  local opts = rest:gsub('^".*"%s*', ""):match("^(%a*)$") or ""
  return trigger, desc, opts
end

-- UltiSnips#SnippetLocations() lists only snippets that can match an EMPTY line prefix, so it
-- silently drops regex-trigger snippets (option `r`, e.g. all.snippets "(?<!\w)ltx"). Add those by
-- scanning my own snippet files for the filetypes in scope for the current buffer.
---@param root string  realpath of my_snippets
---@param known table<string, any>  triggers already found
---@return { trigger: string, desc: string, file: string, lnum: integer }[]
local function collect_regex(root, known)
  local found = {}
  local fts = vim.fn.py3eval("UltiSnips_Manager.get_buffer_filetypes()")
  for _, ft in ipairs(fts) do
    local files = vim.fn.globpath(root, ft .. ".snippets", false, true)
    vim.list_extend(files, vim.fn.globpath(root, ft .. "_*.snippets", false, true))
    vim.list_extend(files, vim.fn.globpath(root, ft .. "/*.snippets", false, true))
    for _, file in ipairs(files) do
      for lnum, l in ipairs(vim.fn.readfile(file)) do
        local trigger, desc, opts = parse_header(l)
        if trigger and opts:find("r", 1, true) and not known[trigger] then
          found[#found + 1] = { trigger = trigger, desc = desc, file = file, lnum = lnum }
        end
      end
    end
  end
  return found
end

-- Collect my snippets for the current buffer's filetype.
---@return { line: string, file: string, lnum: integer, trigger: string }[]
local function collect()
  local root = real(vim.fn.stdpath("config") .. "/" .. SNIPPET_DIR)
  -- SnippetLocations() refreshes g:current_ulti_dict_info (trigger -> description/location)
  vim.fn["UltiSnips#SnippetLocations"]()
  local info = vim.g.current_ulti_dict_info or {}
  local raw = {}
  for trigger, i in pairs(info) do
    local file, lnum = tostring(i.location or ""):match("^(.*):(%d+)$")
    if file and is_mine(file, root) then
      raw[#raw + 1] = { trigger = trigger, desc = i.description, file = file, lnum = tonumber(lnum) }
    end
  end
  vim.list_extend(raw, collect_regex(root, info))

  local items = {}
  for _, r in ipairs(raw) do
    local snip = read_snippet(r.file, r.lnum)
    local desc = r.desc ~= "" and r.desc or "(no description)"
    local line = ("%s  %s  [%s]"):format(r.trigger, desc, filetype_of(r.file))
    if snip and needs_trigger(snip) then line = line .. "  (type trigger)" end
    items[#items + 1] = { line = line, file = r.file, lnum = r.lnum, trigger = r.trigger }
  end
  table.sort(items, function(a, b) return a.trigger < b.trigger end)
  return items
end

-- Insert `body` at the remembered origin position, from the remembered mode.
---@param origin { win: integer, buf: integer, mode: string, pos: integer[] }
---@param body string
local function insert_at_origin(origin, body)
  if not (vim.api.nvim_win_is_valid(origin.win) and vim.api.nvim_buf_is_valid(origin.buf)) then
    return
  end
  vim.api.nvim_set_current_win(origin.win)
  if vim.api.nvim_win_get_buf(origin.win) ~= origin.buf then
    vim.api.nvim_win_set_buf(origin.win, origin.buf)
  end
  if not vim.bo[origin.buf].modifiable then
    vim.notify("Snippet gallery: buffer is not modifiable", vim.log.levels.WARN)
    return
  end
  local row, col = origin.pos[1], origin.pos[2]
  local line = vim.api.nvim_buf_get_lines(origin.buf, row - 1, row, false)[1] or ""
  if origin.mode ~= "i" and line ~= "" then
    -- from normal mode insert after the character under the cursor (like `a`)
    col = col + #vim.fn.matchstr(line, "\\%" .. (col + 1) .. "c.")
  end
  col = math.min(col, #line)
  vim.api.nvim_win_set_cursor(origin.win, { row, col })
  -- UltiSnips#Anon must run in insert mode; `startinsert` only takes effect once the current
  -- callback returns, so expand on the next loop iteration.
  vim.cmd(col >= #line and "startinsert!" or "startinsert")
  vim.schedule(function()
    if vim.api.nvim_get_current_buf() ~= origin.buf then return end
    local ok, err = pcall(vim.fn["UltiSnips#Anon"], body)
    if not ok then vim.notify("Snippet gallery: " .. tostring(err), vim.log.levels.ERROR) end
  end)
end

-- Custom fzf-lua builtin previewer: shows the snippet body (filetype `snippets` highlighting).
local function make_previewer(by_line)
  local builtin = require("fzf-lua.previewer.builtin")
  local Previewer = builtin.base:extend()

  function Previewer:new(o, opts, fzf_win)
    Previewer.super.new(self, o, opts, fzf_win)
    setmetatable(self, Previewer)
    return self
  end

  function Previewer:populate_preview_buf(entry_str)
    local item = by_line[entry_str]
    local snip = item and read_snippet(item.file, item.lnum)
    local lines = snip and vim.list_extend({ snip.header }, snip.body) or { "(snippet not found)" }
    local tmpbuf = self:get_tmp_buffer()
    vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, lines)
    vim.bo[tmpbuf].filetype = "snippets"
    self:set_preview_buf(tmpbuf)
    self.win:update_preview_title(" " .. (item and vim.fn.fnamemodify(item.file, ":t") or "") .. " ")
  end

  return { _ctor = function() return Previewer end }
end

--- Open the gallery for the current buffer's filetype.
function M.open()
  local ok_fzf, fzf = pcall(require, "fzf-lua")
  if not ok_fzf then
    vim.notify("Snippet gallery: fzf-lua is not available", vim.log.levels.WARN)
    return
  end
  -- UltiSnips loads at VeryLazy; force it if the key is pressed earlier. (Its autoload
  -- functions only exist once called, so test for the :UltiSnipsEdit command instead.)
  if vim.fn.exists(":UltiSnipsEdit") == 0 then
    pcall(function() require("lazy").load { plugins = { "ultisnips" } } end)
    if vim.fn.exists(":UltiSnipsEdit") == 0 then
      vim.notify("Snippet gallery: UltiSnips is not available", vim.log.levels.WARN)
      return
    end
  end

  local origin = {
    win = vim.api.nvim_get_current_win(),
    buf = vim.api.nvim_get_current_buf(),
    mode = vim.fn.mode():sub(1, 1), -- "i" or "n" (anything else is treated like normal)
    pos = vim.api.nvim_win_get_cursor(0),
  }
  -- close a visible nvim-cmp menu so it does not linger over the picker
  local ok_cmp, cmp = pcall(require, "cmp")
  if ok_cmp and cmp.visible() then cmp.close() end

  local ok_collect, items = pcall(collect)
  if not ok_collect then
    vim.notify("Snippet gallery: " .. tostring(items), vim.log.levels.ERROR)
    return
  end
  if #items == 0 then
    vim.notify(
      ("No custom snippets for filetype '%s'"):format(vim.bo[origin.buf].filetype),
      vim.log.levels.INFO
    )
    return
  end
  local by_line, lines = {}, {}
  for _, it in ipairs(items) do
    by_line[it.line] = it
    lines[#lines + 1] = it.line
  end

  fzf.fzf_exec(lines, {
    prompt = "Snippets> ",
    previewer = make_previewer(by_line),
    winopts = { title = " My snippets (" .. vim.bo[origin.buf].filetype .. ") " },
    actions = {
      ["default"] = function(selected)
        local item = selected and by_line[selected[1]]
        if not item then return end
        local snip = read_snippet(item.file, item.lnum)
        if not snip then
          vim.notify("Snippet gallery: cannot read " .. item.trigger, vim.log.levels.ERROR)
        elseif needs_trigger(snip) then
          vim.notify(
            ("Snippet '%s' needs its trigger typed (regex match / global helpers); not inserted"):format(
              item.trigger
            ),
            vim.log.levels.WARN
          )
        else
          insert_at_origin(origin, table.concat(snip.body, "\n"))
        end
      end,
    },
  })
end

-- Keymaps (style as in lua/config/fzf-lua.lua)
vim.keymap.set("n", "<leader>fs", M.open, { desc = "Fuzzy search my custom snippets" })
-- UNVERIFIED in a real terminal: <C-s> may be swallowed as XOFF (flow control) before it
-- reaches Neovim; `stty -ixon` in the shell rc frees it. <leader>fs always works.
vim.keymap.set("i", "<C-s>", M.open, { desc = "Fuzzy search my custom snippets" })

return M
