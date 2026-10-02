local keymap = vim.keymap
local uv = vim.uv

-- Save key strokes (now we do not need to press shift to enter command mode).
keymap.set({ "n", "x" }, ";", ":")

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

-- Toggle Diagnostics (Version Safe)
local diagnostics_active = true
keymap.set("n", "<leader>dt", function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable(true)
    vim.notify("Diagnostics Enabled")
  else
    vim.diagnostic.enable(false)
    vim.notify("Diagnostics Disabled")
  end
end, { desc = "Toggle Diagnostics" })

-- ============================================================================
-- Turn the word under cursor to upper case
keymap.set("i", "<c-u>", "<Esc>viwUea")

-- Toggle the case of the first letter of the current word (Foo <-> foo). The word is the one under
-- the cursor or ending right before it; when only whitespace separates the cursor from the previous
-- word on the same line ("foo |"), that word. A non-letter first char, or a letter whose case change does not round-trip, is left alone.
-- Stays in insert mode, the cursor keeps its place in the text.
keymap.set("i", "<c-t>", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  -- leftmost run of keyword chars that touches the cursor column (byte col + 1)
  local word, s, e = unpack(vim.fn.matchstrpos(line, [[\k*\%]] .. (col + 1) .. [[c\k*]]))
  if word == "" then
    -- fallback: the word before the cursor, separated from it only by whitespace
    word, s, e = unpack(vim.fn.matchstrpos(line, [[\k\+\ze\s\+\%]] .. (col + 1) .. "c"))
  end
  if word == "" then
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

-- Saves the file if modified and quit
keymap.set("n", "<leader>q", "<cmd>x<cr>", { silent = true, desc = "save if modified and quit window" })

-- Auto format --
keymap.set("n", "<space>fm", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format file" })

-- Quit all opened buffers
keymap.set("n", "<leader>Q", "<cmd>qa!<cr>", { silent = true, desc = "quit nvim (discard unsaved changes)" })

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
keymap.set("n", [[\d]], "<cmd>bprevious <bar> bdelete #<cr>", { silent = true, desc = "delete current buffer" })

keymap.set("n", [[\D]], function()
  local buf_ids = vim.api.nvim_list_bufs()
  local cur_buf = vim.api.nvim_win_get_buf(0)
  for _, buf_id in pairs(buf_ids) do
    if vim.api.nvim_get_option_value("buflisted", { buf = buf_id }) and buf_id ~= cur_buf then
      vim.api.nvim_buf_delete(buf_id, { force = true })
    end
  end
end, { desc = "delete other buffers" })

-- Close the current tab / all other tabs
keymap.set("n", [[\t]], "<cmd>tabclose<cr>", { silent = true, desc = "close current tab" })
keymap.set("n", [[\T]], "<cmd>tabonly<cr>", { silent = true, desc = "close other tabs" })

-- Move the cursor based on physical lines, not the actual lines.
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap.set("n", "^", "g^")
keymap.set("n", "0", "g0")

-- Do not include white space characters when using $ in visual mode, see https://vi.stackexchange.com/q/12607/15292
keymap.set("x", "$", "g_")

-- Go to start or end of line easier
keymap.set({ "n", "x" }, "H", "^")
keymap.set({ "n", "x" }, "L", "g_")

-- Continuous visual shifting (does not exit Visual mode), `gv` means to reselect previous visual area, see https://superuser.com/q/310417/736190
keymap.set("x", "<", "<gv")
keymap.set("x", ">", ">gv")

-- Edit and reload nvim config file quickly
keymap.set("n", "<leader>ev", "<cmd>tabnew $MYVIMRC <bar> tcd %:h<cr>", { silent = true, desc = "open init.lua" })
-- Restart nvim (0.12 `:restart`) after writing all buffers, and reopen the current file.
-- Re-sourcing $MYVIMRC is not supported with lazy.nvim. The builtin `ZR` also restarts,
-- but does not write all buffers nor reopen the current file.
keymap.set("n", "<leader>sv", function()
  local cur = vim.fn.expand("%:p")
  vim.cmd("silent! wall")
  if cur ~= "" then
    vim.cmd("restart edit " .. vim.fn.fnameescape(cur))
  else
    vim.cmd("restart")
  end
end, { silent = true, desc = "restart nvim (write all, reopen current file)" })

-- Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933
keymap.set("n", "<leader>v", "printf('`[%s`]', getregtype()[0])", { expr = true, desc = "reselect last pasted area" })

-- Change current working directory locally and print cwd after that, see https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file
keymap.set("n", "<leader>cd", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", { desc = "change cwd" })

-- Use Esc to quit builtin terminal
keymap.set("t", "<Esc>", [[<c-\><c-n>]])

-- Toggle spell checking
keymap.set("n", "<leader>cz", "<cmd>set spell!<cr>", { desc = "toggle spell" })

-- Change text without putting it into the vim register, see https://stackoverflow.com/q/54255/6064933
keymap.set("n", "c", '"_c')
keymap.set("n", "C", '"_C')
keymap.set("x", "c", '"_c')

-- Remove trailing whitespace characters
keymap.set("n", "<leader><space>", "<cmd>StripTrailingWhitespace<cr>", { desc = "remove trailing space" })

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



-- Replace visual selection with text in register, but not contaminate the register: builtin `P`
-- keeps the register, honours "a and keeps the line intact when the selection starts at col 0.
-- NOT dead: yanky.nvim (which remaps x p) only loads on :YankyRingHistory, so this is the effective
-- visual p in every session until then.
keymap.set("x", "p", "P")

-- Go to a certain buffer
keymap.set("n", "gb", '<cmd>call buf_utils#GoToBuffer(v:count, "forward")<cr>', { desc = "go to buffer (forward)" })
keymap.set("n", "gB", '<cmd>call buf_utils#GoToBuffer(v:count, "backward")<cr>', { desc = "go to buffer (backward)" })

-- Switch windows
keymap.set("n", "<left>", "<c-w>h")
keymap.set("n", "<Right>", "<C-W>l")
keymap.set("n", "<Up>", "<C-W>k")
keymap.set("n", "<Down>", "<C-W>j")

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

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("java_keymaps", { clear = true }),
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

-- Previews
-- <A-m> markdown preview: the real map is buffer-local in after/ftplugin/markdown.lua
-- (:MarkdownPreviewToggle only exists in markdown buffers). Elsewhere: ONE warning instead of
-- E492 (an unmapped <A-m> would act as <Esc> m, i.e. wait for a mark name).
keymap.set("n", "<A-m>", function()
  vim.notify("Markdown preview: only in markdown buffers", vim.log.levels.WARN)
end, { desc = "Markdown Preview (markdown only)" })
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
    cmd = 'dotnet run'
    need = { 'dotnet' }
    uses_file = false
  elseif filetype == 'javascript' then
    cmd = 'node ' .. file
    need = { 'node' }
  elseif filetype == 'typescript' then
    -- node runs .ts files directly (type stripping, Node >= 23.6; nodejs_latest from neovim.nix)
    cmd = 'node ' .. file
    need = { 'node' }
  elseif filetype == 'go' then
    cmd = 'go run ' .. file
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
  keymap.set("i", ch, ch .. "<c-g>u")
end

-- insert semicolon in the end (cursor stays where it is, no marks touched)
keymap.set("i", "<A-;>", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local len = #vim.api.nvim_get_current_line()
  vim.api.nvim_buf_set_text(0, row - 1, len, row - 1, len, { ";" })
end, { desc = "append ; at line end" })

-- Go to the beginning and end of current line in insert mode quickly
keymap.set("i", "<C-A>", "<HOME>")
keymap.set("i", "<C-E>", "<END>")

-- Go to beginning of command in command-line mode
keymap.set("c", "<C-A>", "<HOME>")

-- Delete the character to the right of the cursor
keymap.set("i", "<C-D>", "<DEL>")

keymap.set("n", "<leader>cb", function()
  local cnt = 0
  local blink_times = 7
  local timer = uv.new_timer()
  if timer == nil then return end
  timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      vim.cmd([[
      set cursorcolumn!
      set cursorline!
    ]])
      if cnt == blink_times then
        timer:close()
      end
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
keymap.set({ "n", "x" }, "gcs", function() smart_comment.run("comment") end, { desc = "Smart Comment" })
keymap.set({ "n", "x" }, "gcr", function() smart_comment.run("uncomment") end, { desc = "Smart Uncomment" })
