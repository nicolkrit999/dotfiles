local keymap = vim.keymap
local uv = vim.uv

-- Save key strokes (now we do not need to press shift to enter command mode).
keymap.set({ "n", "x" }, ";", ":", { desc = "Enter command mode without Shift" })

-- ============================================================================
-- DIAGNOSTICS & NAV (Leader d...)
-- ============================================================================

-- 1. Lists (Using Telescope to see 'unused locals')
-- Buffer: Check current file
keymap.set("n", "<leader>db", function()
  require("telescope.builtin").diagnostics({ bufnr = 0 })
end, { desc = "Buffer Diagnostics" })

-- <leader>dp: pdb on the current file, python buffer-local (after/ftplugin/python.lua).
-- Elsewhere ONE warning (an unmapped <Space>dp would fall through to l + dp = diffput, E99).
keymap.set("n", "<leader>dp", function()
  vim.notify("<leader>dp (pdb): only in python buffers", vim.log.levels.WARN)
end, { desc = "start pdb (python only)" })

-- Workspace: Check WHOLE project
keymap.set("n", "<leader>dw", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Workspace Diagnostics" })

-- 2. Navigation

-- Next/Prev ERROR only (Skip warnings/hints)
-- Jump to next ERROR (Forward)
vim.keymap.set("n", "<leader>de", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next Error" })

-- Optional: Jump to previous ERROR (Backward)
vim.keymap.set("n", "<leader>dE", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Prev Error" })
-- 3. Inspection & Control
-- Show the message in a floating window (Detail)
keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show Diagnostic Detail" })

-- Toggle Diagnostics (globally; follows the real state, also after :lua vim.diagnostic.enable(...))
keymap.set("n", "<leader>dt", function()
  local on = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(on)
  vim.notify(on and "Diagnostics Enabled" or "Diagnostics Disabled")
end, { desc = "Toggle Diagnostics" })

-- ============================================================================
-- The "current word" for the insert-mode case keys <C-u> and <C-t>: the word under the cursor or
-- ending right before it; when only whitespace separates the cursor from the previous word on the
-- same line ("foo |"), that word. Returns row, col (cursor, 0-based byte col), word, s, e (0-based
-- byte range [s, e) of the word), touching (false in the whitespace case); nil if there is no word.
local function insert_current_word()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  -- leftmost run of keyword chars that touches the cursor column (byte col + 1)
  local word, s, e = unpack(vim.fn.matchstrpos(line, [[\k*\%]] .. (col + 1) .. [[c\k*]]))
  local touching = word ~= ""
  if not touching then
    -- fallback: the word before the cursor, separated from it only by whitespace
    word, s, e = unpack(vim.fn.matchstrpos(line, [[\k\+\ze\s\+\%]] .. (col + 1) .. "c"))
  end
  if word == "" then
    return nil
  end
  return row, col, word, s, e, touching
end

-- Upper-case the current word (see insert_current_word). Stays in insert mode; the cursor goes
-- after the word's end when the word touches the cursor, else it keeps its place in the text.
keymap.set("i", "<c-u>", function()
  local row, col, word, s, e, touching = insert_current_word()
  if not row then
    return
  end
  local up = vim.fn.toupper(word)
  vim.api.nvim_buf_set_text(0, row - 1, s, row - 1, e, { up })
  if touching then
    col = s + #up
  else -- the word lies before the cursor: shift by the byte-length change
    col = col + #up - #word
  end
  vim.api.nvim_win_set_cursor(0, { row, col })
end, { desc = "upper-case the current word" })

-- Toggle the case of the first letter of the current word (Foo <-> foo), see insert_current_word.
-- A non-letter first char, or a letter whose case change does not round-trip, is left alone.
-- Stays in insert mode, the cursor keeps its place in the text.
keymap.set("i", "<c-t>", function()
  local row, col, word, s = insert_current_word()
  if not row then
    return
  end
  local first = vim.fn.strcharpart(word, 0, 1)
  local upper, lower = vim.fn.toupper(first), vim.fn.tolower(first)
  local toggled = first ~= upper and upper or (first ~= lower and lower or nil)
  -- only toggle when the change round-trips, so a second <C-t> restores the word (not for i-dotless, long s, ...)
  if not toggled or (toggled == upper and vim.fn.tolower(toggled) or vim.fn.toupper(toggled)) ~= first then
    return
  end
  vim.api.nvim_buf_set_text(0, row - 1, s, row - 1, s + #first, { toggled })
  if col > s then
    col = col + #toggled - #first
  end
  vim.api.nvim_win_set_cursor(0, { row, col })
end, { desc = "toggle case of the word's first letter" })

-- Paste non-linewise text above or below current line, see https://stackoverflow.com/a/1346777/6064933
keymap.set("n", "<leader>p", "m`o<ESC>p``", { desc = "paste below current line" })
keymap.set("n", "<leader>P", "m`O<ESC>p``", { desc = "paste above current line" })

-- Shortcut for faster save and quit
keymap.set("n", "<leader>w", "<cmd>update<cr>", { silent = true, desc = "save buffer" })

-- Split the window (the new window shows the same buffer; below / to the right, see splitbelow, splitright)
keymap.set("n", "<leader>-", "<cmd>split<cr>", { silent = true, desc = "split window horizontally" })
keymap.set("n", "<leader>|", "<cmd>vsplit<cr>", { silent = true, desc = "split window vertically" })

-- <Space>rf: run the current file the editor's own way (Lua: luafile, Vim script: source, Python: AsyncRun,
-- C++: compile and run, LaTeX: vimtex compile). Those file types define it buffer-locally; elsewhere ONE
-- warning (an unmapped key would fall through to <Space> + r + f)
keymap.set("n", "<leader>rf", function()
  vim.notify("<Space>rf: no editor-run for this file type (use <Space>rr for a terminal run)", vim.log.levels.WARN)
end, { silent = true, desc = "run file the editor's own way (needs lua, vim, python, c++ or tex)" })

-- Saves the file if modified and quit
keymap.set("n", "<leader>q", "<cmd>x<cr>", { silent = true, desc = "save if modified and quit window" })

-- Auto format --
keymap.set("n", "<space>fm", function() vim.lsp.buf.format({ async = true }) end, { desc = "LSP: format file" })

-- Force quit nvim, discarding unsaved changes, but only after an explicit confirmation (default = No)
keymap.set("n", "<leader>Q", function()
  -- only real, listed file buffers count (plugin scratch buffers such as fidget's are flagged modified)
  local modified = #vim.tbl_filter(function(b)
    return b.listed == 1 and vim.bo[b.bufnr].buftype == ""
  end, vim.fn.getbufinfo({ bufmodified = 1 }))
  local msg = modified > 0
      and ("Discard %d unsaved buffer(s) and quit nvim?"):format(modified)
      or "Quit nvim?"
  if vim.fn.confirm(msg, "&Yes\n&No", 2) == 1 then
    vim.cmd("qa!")
  end
end, { silent = true, desc = "force quit nvim (asks confirmation, discards unsaved changes)" })

-- Close location list or quickfix list if they are present, see https://superuser.com/q/355325/736190
-- (loclists of every window in this tab via nvim_win_call, so the current window stays current)
keymap.set("n", [[\x]], function()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_call(win, function() vim.cmd.lclose() end)
    end
  end
  vim.cmd.cclose()
end, { silent = true, desc = "close qf and location list" })

-- Delete a buffer, without closing the window, see https://stackoverflow.com/q/4465095/6064933
-- On the only listed buffer there is no previous one: open an empty buffer first (no E516).
keymap.set("n", [[\d]], function()
  local listed = vim.fn.getbufinfo({ buflisted = 1 })
  local only = #listed == 1 and listed[1].bufnr == vim.api.nvim_get_current_buf()
  if only and vim.api.nvim_buf_get_name(0) == "" and not vim.bo.modified then
    return -- already the empty start buffer: nothing to delete (`:enew` would reuse it -> E516)
  end
  local ok, err = pcall(vim.cmd, (only and "enew" or "bprevious") .. " | bdelete #")
  if not ok then -- e.g. E89 unsaved changes: show the plain Vim error, not a Lua traceback
    vim.notify((tostring(err):gsub("^.-Vim%(%a+%):", "")), vim.log.levels.ERROR)
  end
end, { silent = true, desc = "delete current buffer" })

-- Delete all other listed buffers. Buffers with unsaved changes and terminal buffers whose job is
-- still running (Claude panel, :terminal, <Space>rr) are kept (one message "kept N buffer(s)
-- (unsaved or running terminal)"); a delete that fails for another reason also counts as kept.
keymap.set("n", [[\D]], function()
  local cur_buf = vim.api.nvim_get_current_buf()
  local kept = 0
  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if buf_id ~= cur_buf and vim.api.nvim_buf_is_valid(buf_id) and vim.bo[buf_id].buflisted then
      local b = vim.bo[buf_id]
      local running_term = b.buftype == "terminal" and vim.fn.jobwait({ b.channel }, 0)[1] == -1
      if b.modified or running_term or not pcall(vim.api.nvim_buf_delete, buf_id, {}) then
        kept = kept + 1
      end
    end
  end
  if kept > 0 then
    vim.notify(string.format("kept %d buffer(s) (unsaved or running terminal)", kept), vim.log.levels.WARN)
  end
end, { desc = "delete other buffers (keeps unsaved and running terminals)" })

-- Dashboard "home": \h opens the start screen in the current window (the buffer you were in
-- stays open in the background), \H leaves it and goes back. Both always give feedback: they
-- never fall through to a plain Vim key. Keys: free `\` pair next to \d / \D ("h" = home;
-- <Space>h* is taken by the gitsigns hunk keys).
keymap.set("n", [[\h]], function()
  if vim.bo.filetype == "dashboard" then
    vim.notify("already in the dashboard", vim.log.levels.INFO)
    return
  end
  local ok, err = pcall(vim.cmd, "Dashboard") -- lazy-loads dashboard-nvim via its command
  if not ok then
    vim.notify("dashboard unavailable: " .. (tostring(err):gsub("^.-Vim%(%a+%):", "")), vim.log.levels.WARN)
  end
end, { silent = true, desc = "Dashboard: open (keep current buffer)" })

keymap.set("n", [[\H]], function()
  local dash = vim.api.nvim_get_current_buf()
  if vim.bo[dash].filetype ~= "dashboard" then
    vim.notify("not in the dashboard", vim.log.levels.WARN)
    return
  end
  -- target: the alternate buffer, else the most recently used other listed buffer
  local target = vim.fn.bufnr("#")
  if target < 1 or target == dash or not vim.api.nvim_buf_is_valid(target) or not vim.bo[target].buflisted then
    target = nil
    local best = -1
    for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
      if b.bufnr ~= dash and b.lastused > best then
        target, best = b.bufnr, b.lastused
      end
    end
  end
  if not target then
    vim.notify("no previous buffer to resume", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_win_set_buf(0, target)
  -- the dashboard buffer is bufhidden=wipe on some versions: ignore "already gone"
  pcall(vim.api.nvim_buf_delete, dash, { force = true })
end, { silent = true, desc = "Dashboard: close and resume previous buffer" })

-- Close the current tab / all other tabs
keymap.set("n", [[\t]], "<cmd>tabclose<cr>", { silent = true, desc = "close current tab" })
keymap.set("n", [[\T]], "<cmd>tabonly<cr>", { silent = true, desc = "close other tabs" })

-- Move the cursor based on physical lines, not the actual lines.
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move down by display line" })
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move up by display line" })
keymap.set("n", "^", "g^", { desc = "First non-blank of display line" })
keymap.set("n", "0", "g0", { desc = "Start of display line" })

-- Do not include white space characters when using $ in visual mode, see https://vi.stackexchange.com/q/12607/15292
keymap.set("x", "$", "g_", { desc = "Last non-blank char of line" })

-- Go to start or end of line easier
keymap.set({ "n", "x" }, "H", "^", { desc = "Go to first non-blank char of line" })
keymap.set({ "n", "x" }, "L", "g_", { desc = "Go to last non-blank char of line" })

-- Continuous visual shifting (does not exit Visual mode), `gv` means to reselect previous visual area, see https://superuser.com/q/310417/736190
keymap.set("x", "<", "<gv", { desc = "Shift left, keep selection" })
keymap.set("x", ">", ">gv", { desc = "Shift right, keep selection" })

-- Edit and reload nvim config file quickly
keymap.set("n", "<leader>ev", "<cmd>tabnew $MYVIMRC <bar> tcd %:h<cr>", { silent = true, desc = "open init.lua" })
-- Restart nvim (0.12 `:restart`) after writing all buffers. `:restart` saves a session and
-- restores it in the new instance, so windows/tabs/files come back by themselves. 'terminal' is
-- removed from 'sessionoptions' first (only in this dying instance), so terminals such as the
-- Claude panel are NOT re-launched. Re-sourcing $MYVIMRC is not supported with lazy.nvim.
-- The builtin `ZR` also restarts, but does not write the buffers.
keymap.set("n", "<leader>sv", function()
  vim.cmd("silent! wall")
  local ssop = vim.o.sessionoptions
  vim.opt.sessionoptions:remove("terminal")
  local ok, err = pcall(vim.cmd, "restart")
  if not ok then -- e.g. no UI attached: this instance lives on, so put the option back
    vim.o.sessionoptions = ssop
    vim.notify(tostring(err), vim.log.levels.ERROR)
  end
end, { silent = true, desc = "restart nvim (write all, restore windows, no terminals)" })

-- Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933
keymap.set("n", "<leader>v", "printf('`[%s`]', getregtype()[0])", { expr = true, desc = "reselect last pasted area" })

-- Change current working directory locally and print cwd after that, see https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file
keymap.set("n", "<leader>cd", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", { desc = "cd to file dir (this window)" })

-- Use Esc to quit builtin terminal
keymap.set("t", "<Esc>", [[<c-\><c-n>]], { desc = "Leave terminal mode" })

-- Toggle spell checking
keymap.set("n", "<leader>cz", "<cmd>set spell!<cr>", { desc = "toggle spell" })

-- Change text without putting it into the vim register, see https://stackoverflow.com/q/54255/6064933
keymap.set("n", "c", '"_c', { desc = "Change without yanking" })
keymap.set("n", "C", '"_C', { desc = "Change to end of line without yanking" })
keymap.set("x", "c", '"_c', { desc = "Change selection without yanking" })

-- Remove trailing whitespace characters
keymap.set("n", "<leader><space>", function()
  if vim.bo.filetype == "markdown" then
    vim.notify("markdown: trailing spaces are hard line breaks, not stripped", vim.log.levels.WARN)
    return
  end
  vim.cmd.StripTrailingWhitespace()
end, { desc = "remove trailing space (not markdown)" })

-- Copy entire buffer.
keymap.set("n", "<leader>y", "<cmd>%yank<cr>", { desc = "yank entire buffer" })

-- Toggle cursor column
keymap.set("n", "<leader>cl", "<cmd>call utils#ToggleCursorCol()<cr>", { desc = "toggle cursor column" })

-- Move lines with Option+j/k ({count} lines at a time, re-indented). At the first/last line the
-- move is clamped silently (no E16); in visual mode the selection is kept, also at the edges.
-- dir = 1 (down) or -1 (up); s..e = the line range to move; n = how many lines; returns true if moved
local function move_lines(s, e, dir, n)
  local target
  if dir > 0 then
    target = math.min(e + n, vim.fn.line("$"))
    if target == e then
      return false
    end
  else
    target = math.max(s - n - 1, 0)
    if target == s - 1 then
      return false
    end
  end
  vim.cmd(string.format("silent %d,%dmove %d", s, e, target))
  return true
end

for _, m in ipairs({ { "<A-j>", 1, "down" }, { "<A-k>", -1, "up" } }) do
  local lhs, dir, word = m[1], m[2], m[3]
  keymap.set("n", lhs, function()
    local l = vim.fn.line(".")
    if move_lines(l, l, dir, vim.v.count1) then
      vim.cmd("normal! ==")
    end
  end, { silent = true, desc = "move line " .. word })
  keymap.set("x", lhs, function()
    local s, e = vim.fn.line("v"), vim.fn.line(".")
    if s > e then
      s, e = e, s
    end
    local n = vim.v.count1 -- read before leaving visual mode
    vim.cmd("normal! \27") -- leave visual mode: sets '< '> (adjusted by :move, so gv follows)
    if move_lines(s, e, dir, n) then
      vim.cmd("normal! gv=")
    end
    vim.cmd("normal! gv")
  end, { silent = true, desc = "move selection " .. word })
end

-- Go to a certain buffer
keymap.set("n", "gb", '<cmd>call buf_utils#GoToBuffer(v:count, "forward")<cr>', { desc = "go to next buffer ({N}gb: buffer N)" })
keymap.set("n", "gB", '<cmd>call buf_utils#GoToBuffer(v:count, "backward")<cr>', { desc = "go to previous buffer (no count; use {N}gb)" })

-- Switch windows
keymap.set("n", "<left>", "<c-w>h", { desc = "Go to left window" })
keymap.set("n", "<Right>", "<C-W>l", { desc = "Go to right window" })
keymap.set("n", "<Up>", "<C-W>k", { desc = "Go to upper window" })
keymap.set("n", "<Down>", "<C-W>j", { desc = "Go to lower window" })

-- ---- TEXT OBJECTS [Conflict-free] ----

-- Buffer (was iB in both o/x) - leader-based:
keymap.set({ "x", "o" }, "<leader>iB", ":<C-U>call text_obj#Buffer()<cr>", { desc = "buffer text object" })

-- URL (was iu) - leader-based:
keymap.set({ "x", "o" }, "<leader>iu", "<cmd>call text_obj#URL()<cr>", { desc = "URL text object" })


-- Java (nvim-java). The Java* commands only work once jdtls is attached (jdtls needs `java`,
-- e.g. from the Java devShell), so the real maps are buffer-local and created on LspAttach of
-- jdtls. Everywhere else the same keys are global FALLBACK maps that show ONE warning (an
-- unmapped key would fall through to plain Vim keys, e.g. <Space>jrr = l, j, rr). Groups:
-- <leader>jb build, <leader>jr runner, <leader>jt test, <leader>je extract/refactor
-- (which-key group names in lua/config/which-key.lua; because of the fallback maps the groups
-- show in every buffer)
local java_maps = {
  -- Java Build
  { "<leader>jbb", "JavaBuildBuildWorkspace", "Java: Build Workspace" },
  { "<leader>jbc", "JavaBuildCleanWorkspace", "Java: Clean Workspace" },
  -- Java Runner
  { "<leader>jrr", "JavaRunnerRunMain", "Java: Run Main" },
  { "<leader>jrs", "JavaRunnerStopMain", "Java: Stop Main" },
  { "<leader>jrl", "JavaRunnerToggleLogs", "Java: Toggle Runner Logs" },
  { "<leader>jrp", "JavaProfile", "Java: Profiles UI" },
  -- Java Test
  { "<leader>jtc", "JavaTestRunCurrentClass", "Java: Test Current Class" },
  { "<leader>jtC", "JavaTestDebugCurrentClass", "Java: Debug Current Class" },
  { "<leader>jtm", "JavaTestRunCurrentMethod", "Java: Test Current Method" },
  { "<leader>jtM", "JavaTestDebugCurrentMethod", "Java: Debug Current Method" },
  { "<leader>jtr", "JavaTestViewLastReport", "Java: View Last Test Report" },
  -- Java Refactor (extract)
  { "<leader>jev", "JavaRefactorExtractVariable", "Java: Extract Variable" },
  { "<leader>jeo", "JavaRefactorExtractVariableAllOccurrence", "Java: Extract Variable (All Occurrences)" },
  { "<leader>jec", "JavaRefactorExtractConstant", "Java: Extract Constant" },
  { "<leader>jem", "JavaRefactorExtractMethod", "Java: Extract Method" },
  { "<leader>jef", "JavaRefactorExtractField", "Java: Extract Field" },
  -- Java DAP / Settings
  { "<leader>jd", "JavaDapConfig", "Java: DAP Config" },
  { "<leader>jj", "JavaSettingsChangeRuntime", "Java: Change Runtime" },
}

-- global fallbacks: one warning, no fall-through; the jdtls buffer-local maps below override them
local function java_not_attached()
  vim.notify("Java: jdtls not attached (open nvim inside the Java devShell)", vim.log.levels.WARN)
end
for _, m in ipairs(java_maps) do
  keymap.set("n", m[1], java_not_attached, { desc = m[3] .. " (needs jdtls)" })
end

local java_group = vim.api.nvim_create_augroup("java_keymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = java_group,
  desc = "buffer-local Java keymaps when jdtls attaches",
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "jdtls" then
      return
    end
    local bufnr = ev.buf
    for _, m in ipairs(java_maps) do
      keymap.set("n", m[1], "<cmd>" .. m[2] .. "<cr>", { buffer = bufnr, desc = m[3] })
    end
  end,
})
-- jdtls detached (stopped/crashed): remove the buffer-local maps, the global fallbacks apply again
vim.api.nvim_create_autocmd("LspDetach", {
  group = java_group,
  desc = "remove buffer-local Java keymaps when jdtls detaches",
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "jdtls" then
      return
    end
    for _, m in ipairs(java_maps) do
      pcall(keymap.del, "n", m[1], { buffer = ev.buf })
    end
  end,
})

-- Previews
-- <A-m> markdown preview: the real map is buffer-local in after/ftplugin/markdown.lua
-- (:MarkdownPreviewToggle only exists in markdown buffers). Elsewhere: ONE warning instead of
-- E492 (an unmapped <A-m> would act as <Esc> m, i.e. wait for a mark name).
keymap.set("n", "<A-m>", function()
  vim.notify("Markdown preview: only in markdown buffers", vim.log.levels.WARN)
end, { desc = "Markdown Preview (markdown only)" })
-- User guide and Claude help, same keys as the dashboard items (lua/config/user-guide-tools.lua)
keymap.set("n", "<leader>?", function() require("config.user-guide-tools").open_guide() end,
  { desc = "User guide: open the PDF" })
keymap.set("n", "<leader>a", function() require("config.user-guide-tools").ask_claude() end,
  { desc = "Claude: ask how to do something in Neovim (split)" })
-- ]] / [[ are NOT mapped globally: nvim's runtime defaults apply (markdown headers, python
-- class/def, help sections, plain-buffer section motions). LSP definition = gd.

-- ============================================================================
-- MARKDOWN FOOTNOTES (normal mode only; insert mode unmapped in after/ftplugin)
-- ============================================================================
-- The real maps are buffer-local in after/ftplugin/markdown.lua (vim-markdownfootnotes only
-- loads for markdown). Elsewhere: ONE warning (like <A-m>).
keymap.set("n", "<leader>mf", function()
  vim.notify("Footnotes: only in markdown buffers", vim.log.levels.WARN)
end, { desc = "Add Footnote (markdown only)" })
keymap.set("n", "<leader>mr", function()
  vim.notify("Footnotes: only in markdown buffers", vim.log.levels.WARN)
end, { desc = "Return from Footnote (markdown only)" })

-- General code runner
-- Universal run command that detects file type.
-- Each branch names the binary it needs (`need`, any one is enough) and where it usually
-- comes from (`where`). The binary is checked with executable() when the key is pressed: if it
-- is missing, show ONE warning instead of opening a terminal that fails.
vim.keymap.set('n', '<leader>rr', function()
  local filetype = vim.bo.filetype
  -- the file name is shell-escaped for every branch (spaces, quotes, $ ; in a name reach the
  -- program as one argument); c/cpp/rust single files build the binary next to the source and
  -- run it by its full, shell-escaped path (works for absolute buffer names, files outside
  -- the cwd, paths with spaces and paths with % # ! - see the jobstart below)
  local file = vim.fn.shellescape(vim.fn.expand('%'))
  local binary = vim.fn.shellescape(vim.fn.expand('%:p:r'))
  local cmd = ''
  local need, where = nil, nil
  -- false for the project branches (cargo, dotnet) that do not pass the file name
  local uses_file = true

  if filetype == 'python' then
    cmd = 'python3 ' .. file
  elseif filetype == 'java' then
    -- jdtls attached (nvim-java) -> its runner; else plain `java <file>` (single-file source launch)
    if #vim.lsp.get_clients({ bufnr = 0, name = 'jdtls' }) > 0 then
      vim.cmd('JavaRunnerRunMain')
      return -- Exit early since we're not using terminal
    end
    cmd = 'java ' .. file
    need, where = { 'java' }, 'the java devShell'
  elseif filetype == 'c' then
    cmd = 'gcc -Wall -Wextra -std=c11 ' .. file .. ' -o ' .. binary .. ' && ' .. binary
    need, where = { 'gcc' }, 'the c-cpp devShell'
  elseif filetype == 'cpp' then
    cmd = 'g++ -Wall -Wextra -std=c++20 ' .. file .. ' -o ' .. binary .. ' && ' .. binary
    need, where = { 'g++' }, 'the c-cpp devShell'
  elseif filetype == 'cs' then
    -- nearest *.csproj above the file: run that project; else the single file (.NET 10 file-based app)
    local proj_dir = vim.fs.root(0, function(name) return name:match('%.csproj$') ~= nil end)
    local csproj
    if proj_dir then
      local found = {}
      for name, type in vim.fs.dir(proj_dir) do
        if name:match('%.csproj$') and type ~= 'directory' then
          table.insert(found, name)
        end
      end
      table.sort(found)
      csproj = found[1] and vim.fs.joinpath(proj_dir, found[1])
    end
    if csproj then
      cmd = 'dotnet run --project ' .. vim.fn.shellescape(csproj)
      uses_file = false
    else
      cmd = 'dotnet run ' .. file
    end
    need = { 'dotnet' }
  elseif filetype == 'javascript' then
    cmd = 'node ' .. file
    need = { 'node' }
  elseif filetype == 'typescript' then
    -- node runs .ts files directly (type stripping, Node >= 23.6; nodejs_latest from neovim.nix)
    cmd = 'node ' .. file
    need = { 'node' }
  elseif filetype == 'go' then
    -- the whole package in the file's directory (works for multi-file packages)
    cmd = 'cd ' .. vim.fn.shellescape(vim.fn.expand('%:p:h')) .. ' && go run .'
    need, where = { 'go' }, 'the go devShell'
  elseif filetype == 'rust' then
    -- inside a cargo project (Cargo.toml above the file): cargo run; else compile the single file
    local cargo_root = vim.fs.root(0, 'Cargo.toml')
    if cargo_root then
      cmd = 'cargo run --manifest-path ' .. vim.fn.shellescape(cargo_root .. '/Cargo.toml')
      need = { 'cargo' }
      uses_file = false
    else
      cmd = 'rustc ' .. file .. ' -o ' .. binary .. ' && ' .. binary
      need = { 'rustc' }
    end
    where = 'the rust devShell'
  elseif filetype == 'sh' then
    cmd = 'bash ' .. file
  elseif filetype == 'lua' then
    -- nvim's own LuaJIT as a script runner (no separate lua interpreter needed)
    cmd = 'nvim -l ' .. file
  elseif filetype == 'ruby' then
    cmd = 'ruby ' .. file
    need = { 'ruby' }
  elseif filetype == 'php' then
    cmd = 'php ' .. file
    need, where = { 'php' }, 'the php devShell'
  else
    vim.notify('<leader>rr: no run command for filetype "' .. filetype .. '"', vim.log.levels.WARN)
    return
  end

  if uses_file and vim.fn.expand('%') == '' then
    vim.notify('<leader>rr: save the file first', vim.log.levels.WARN)
    return
  end

  if need then
    local found = vim.iter(need):any(function(bin) return vim.fn.executable(bin) == 1 end)
    if not found then
      local msg = string.format('<leader>rr: %s not found on PATH', table.concat(need, '/'))
      if where then
        msg = msg .. ' (open nvim inside ' .. where .. ')'
      end
      vim.notify(msg, vim.log.levels.WARN)
      return
    end
  end

  -- new empty vsplit + jobstart(term): unlike `:terminal <cmd>`, the command is NOT a cmdline,
  -- so `%`, `#` and `!` in a path are not expanded by vim (only the shell sees the string).
  -- Opened on the LEFT (layout convention: short single-task panels left, persistent panels right).
  vim.cmd("leftabove vnew")
  vim.fn.jobstart(cmd, { term = true })
end, { noremap = true, desc = "Run current file" })

-- Do not move my cursor when joining lines. Honours a count (3J joins 3 lines, like the
-- builtin) and keeps the cursor with winsaveview instead of a mark, so mark z is left alone.
local function join_keep_cursor(cmd)
  return function()
    local count = vim.v.count > 1 and vim.v.count or ""
    local view = vim.fn.winsaveview()
    vim.cmd("normal! " .. count .. cmd)
    vim.fn.winrestview(view)
  end
end

keymap.set("n", "J", join_keep_cursor("J"), { desc = "join lines without moving cursor" })

keymap.set("n", "gJ", join_keep_cursor("gJ"), { desc = "join lines without spaces (keep cursor)" })

-- Break inserted text into smaller undo units when we insert some punctuation chars.
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
  keymap.set("i", ch, ch .. "<c-g>u", { desc = "Insert " .. ch .. " (start new undo unit)" })
end

-- insert semicolon in the end (cursor stays where it is, no marks touched)
keymap.set("i", "<A-;>", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local len = #vim.api.nvim_get_current_line()
  vim.api.nvim_buf_set_text(0, row - 1, len, row - 1, len, { ";" })
end, { desc = "append ; at line end" })

-- Go to the beginning and end of current line in insert mode quickly
keymap.set("i", "<C-A>", "<HOME>", { desc = "Go to start of line" })
keymap.set("i", "<C-E>", "<END>", { desc = "Go to end of line" })

-- Go to beginning of command in command-line mode
keymap.set("c", "<C-A>", "<HOME>", { desc = "Go to start of command line" })

-- Delete the character to the right of the cursor
keymap.set("i", "<C-D>", "<DEL>", { desc = "Delete char to the right" })

-- Blink cursorline/cursorcolumn in the window where the key was pressed (also when another
-- window becomes current meanwhile); the original values come back at the end. A press while
-- that window is still blinking is ignored (it would save the half-blinked state as original).
keymap.set("n", "<leader>cb", function()
  local win = vim.api.nvim_get_current_win()
  if vim.w[win].cb_blinking then return end
  vim.w[win].cb_blinking = true
  local orig_cul, orig_cuc = vim.wo[win].cursorline, vim.wo[win].cursorcolumn
  local cnt = 0
  local blink_times = 7
  local timer = uv.new_timer()
  if timer == nil then
    vim.w[win].cb_blinking = nil
    return
  end
  local function stop()
    if vim.api.nvim_win_is_valid(win) then vim.w[win].cb_blinking = nil end
    timer:stop()
    if not timer:is_closing() then timer:close() end
  end
  timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      if timer:is_closing() then return end
      if not vim.api.nvim_win_is_valid(win) then
        return stop()
      end
      if cnt >= blink_times then
        vim.wo[win].cursorline, vim.wo[win].cursorcolumn = orig_cul, orig_cuc
        return stop()
      end
      vim.wo[win].cursorline = not vim.wo[win].cursorline
      vim.wo[win].cursorcolumn = not vim.wo[win].cursorcolumn
      cnt = cnt + 1
    end)
  )
end, { desc = "show cursor" })


-- builtin undo tree (nvim 0.12 optional package nvim.undotree). open() toggles the panel.
-- Opened on the far LEFT (layout convention: short single-task panels left, persistent
-- interactive panels such as claude-code right); `:Undotree` alone would follow splitright.
keymap.set("n", "<space>u", function()
  vim.cmd.packadd("nvim.undotree") -- no-op after the first call
  require("undotree").open({ command = "topleft 30vnew" })
end, { silent = true, desc = "toggle undo tree" })

-- ============================================================================
-- MACRO & ESCAPE FIXES
-- ============================================================================
keymap.set("n", "Q", "q", { desc = "Record macro" })

keymap.set("n", "<Esc>", function()
  vim.cmd("fclose!")
end, { desc = "close floating win" })


-- ============================================================================
-- SMART COMMENTING (gcs = comment, gcr = uncomment; logic in lua/smart_comment/)
-- ============================================================================
local smart_comment = require("smart_comment")
-- operators: gcs{motion} (gcsip, gcr200j), {count}gcs = count rows from the cursor, Visual; `.` repeats
keymap.set({ "n", "x" }, "gcs", function() return smart_comment.operator("comment") end,
  { expr = true, desc = "Comment lines (motion/count)" })
keymap.set({ "n", "x" }, "gcr", function() return smart_comment.operator("uncomment") end,
  { expr = true, desc = "Uncomment lines (motion/count)" })
-- current row(s): gcss / gcrr, {count}gcss = count rows. (They make `gcs` / `gcr` a prefix in Normal
-- mode: after a PAUSE following `gcs` Vim waits 'timeoutlen' for an `s`; `gcsip` typed in one go is
-- not affected, the same as builtin `gc` / `gcc`.)
keymap.set("n", "gcss", function() return smart_comment.operator("comment", true) end,
  { expr = true, desc = "Comment current line(s)" })
keymap.set("n", "gcrr", function() return smart_comment.operator("uncomment", true) end,
  { expr = true, desc = "Uncomment current line(s)" })
