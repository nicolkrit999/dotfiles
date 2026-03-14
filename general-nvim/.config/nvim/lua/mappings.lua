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

-- Workspace: Check WHOLE project
keymap.set("n", "<leader>dw", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Workspace Diagnostics" })

-- Workspace Errors: Check ONLY errors (clean up build)
keymap.set("n", "<leader>dE", function()
  require("telescope.builtin").diagnostics({
    root_dir = true,
    severity = vim.diagnostic.severity.ERROR
  })
end, { desc = "Workspace Errors Only" })

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
    if vim.fn.has("nvim-0.10") == 1 then vim.diagnostic.enable(true) else vim.diagnostic.enable() end
    vim.notify("Diagnostics Enabled")
  else
    if vim.fn.has("nvim-0.10") == 1 then vim.diagnostic.enable(false) else vim.diagnostic.enable(false) end
    vim.notify("Diagnostics Disabled")
  end
end, { desc = "Toggle Diagnostics" })

-- ============================================================================
-- Turn the word under cursor to upper case
keymap.set("i", "<c-u>", "<Esc>viwUea")

-- Turn the current word into title case
keymap.set("i", "<c-t>", "<Esc>b~lea")

keymap.set("n", "<leader>cpc", "<cmd>CopilotChatToggle<cr>", { desc = "Toggle Copilot Chat" })
keymap.set("v", "<leader>cpe", "<cmd>CopilotChatExplain<cr>", { desc = "Copilot Explain Code" })
keymap.set("v", "<leader>cpo", "<cmd>CopilotChatOptimize<cr>", { desc = "Copilot Optimize Code" })

-- Paste non-linewise text above or below current line, see https://stackoverflow.com/a/1346777/6064933
keymap.set("n", "<leader>p", "m`o<ESC>p``", { desc = "paste below current line" })
keymap.set("n", "<leader>P", "m`O<ESC>p``", { desc = "paste above current line" })

-- Shortcut for faster save and quit
keymap.set("n", "<leader>w", "<cmd>update<cr>", { silent = true, desc = "save buffer" })

-- Saves the file if modified and quit
keymap.set("n", "<leader>q", "<cmd>x<cr>", { silent = true, desc = "quit current window" })

-- Auto format --
keymap.set("n", "<space>fm", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format file" })

-- Quit all opened buffers
keymap.set("n", "<leader>Q", "<cmd>qa!<cr>", { silent = true, desc = "quit nvim" })

-- Close location list or quickfix list if they are present, see https://superuser.com/q/355325/736190
keymap.set("n", [[\x]], "<cmd>windo lclose <bar> cclose <cr>", { silent = true, desc = "close qf and location list" })

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

-- Insert a blank line below or above current line (do not move the cursor), see https://stackoverflow.com/a/16136133/6064933
keymap.set("n", "<space>o", "printf('m`%so<ESC>``', v:count1)", { expr = true, desc = "insert line below" })
keymap.set("n", "<space>O", "printf('m`%sO<ESC>``', v:count1)", { expr = true, desc = "insert line above" })

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
keymap.set("n", "<leader>sv", function()
  vim.cmd([[
      update $MYVIMRC
      source $MYVIMRC
    ]])
  vim.notify("Nvim config successfully reloaded!", vim.log.levels.INFO, { title = "nvim-config" })
end, { silent = true, desc = "reload init.lua" })

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
keymap.set("n", "cc", '"_cc')
keymap.set("x", "c", '"_c')

-- Remove trailing whitespace characters
keymap.set("n", "<leader><space>", "<cmd>StripTrailingWhitespace<cr>", { desc = "remove trailing space" })

-- Copy entire buffer.
keymap.set("n", "<leader>y", "<cmd>%yank<cr>", { desc = "yank entire buffer" })

-- Toggle cursor column
keymap.set("n", "<leader>cl", "<cmd>call utils#ToggleCursorCol()<cr>", { desc = "toggle cursor column" })

-- Move lines in normal mode with Option+j/k
keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "move line down" })
keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "move line up" })

-- Move lines in visual mode with Option+j/k (keep selection)
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "move selection down" })
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "move selection up" })



-- Replace visual selection with text in register, but not contaminate the register, see also https://stackoverflow.com/q/10723700/6064933
keymap.set("x", "p", '"_c<Esc>p')

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

-- Surrounding/inside (was is, ib, ab, ai, as) - leader-based, not to clash with plugin/targets:
keymap.set({ "x", "o" }, "<leader>is", "<cmd>echo 'inside sentence (custom)'<cr>", { desc = "inner sentence" })
keymap.set({ "x", "o" }, "<leader>ib", "<cmd>echo 'buffer text object'<cr>", { desc = "buffer text object" })
keymap.set({ "x", "o" }, "<leader>ab", "<cmd>echo 'around block'<cr>", { desc = "around block" })
keymap.set({ "x", "o" }, "<leader>ai", "<cmd>echo 'around inner'<cr>", { desc = "around inner" })
keymap.set({ "x", "o" }, "<leader>as", "<cmd>echo 'around sentence'<cr>", { desc = "around sentence" })


-- Java Build
keymap.set('n', '<leader>jb', '<cmd>JavaBuildBuildWorkspace<cr>', { desc = 'Java: Build Workspace' })
keymap.set('n', '<leader>jc', '<cmd>JavaBuildCleanWorkspace<cr>', { desc = 'Java: Clean Workspace' })

-- Java Runner
keymap.set('n', '<leader>jr', '<cmd>JavaRunnerRunMain<cr>', { desc = 'Java: Run Main' })
keymap.set('n', '<leader>js', '<cmd>JavaRunnerStopMain<cr>', { desc = 'Java: Stop Main' })
keymap.set('n', '<leader>jl', '<cmd>JavaRunnerToggleLogs<cr>', { desc = 'Java: Toggle Runner Logs' })

-- Java DAP
keymap.set('n', '<leader>jd', '<cmd>JavaDapConfig<cr>', { desc = 'Java: DAP Config' })

-- Java Test
keymap.set('n', '<leader>jt', '<cmd>JavaTestRunCurrentClass<cr>', { desc = 'Java: Test Current Class' })
keymap.set('n', '<leader>jT', '<cmd>JavaTestDebugCurrentClass<cr>', { desc = 'Java: Debug Current Class' })
keymap.set('n', '<leader>jm', '<cmd>JavaTestRunCurrentMethod<cr>', { desc = 'Java: Test Current Method' })
keymap.set('n', '<leader>jM', '<cmd>JavaTestDebugCurrentMethod<cr>', { desc = 'Java: Debug Current Method' })
keymap.set('n', '<leader>jp', '<cmd>JavaTestViewLastReport<cr>', { desc = 'Java: View Last Test Report' })

-- Java Profiles
keymap.set('n', '<leader>jf', '<cmd>JavaProfile<cr>', { desc = 'Java: Profiles UI' })

-- Java Refactor
keymap.set('n', '<leader>jv', '<cmd>JavaRefactorExtractVariable<cr>', { desc = 'Java: Extract Variable' })
keymap.set('n', '<leader>jo', '<cmd>JavaRefactorExtractVariableAllOccurrence<cr>',
  { desc = 'Java: Extract Variable (All Occurrences)' })
keymap.set('n', '<leader>jc', '<cmd>JavaRefactorExtractConstant<cr>', { desc = 'Java: Extract Constant' })
keymap.set('n', '<leader>jm', '<cmd>JavaRefactorExtractMethod<cr>', { desc = 'Java: Extract Method' })
keymap.set('n', '<leader>jf', '<cmd>JavaRefactorExtractField<cr>', { desc = 'Java: Extract Field' })

-- Java Settings
keymap.set('n', '<leader>jj', '<cmd>JavaSettingsChangeRuntime<cr>', { desc = 'Java: Change Runtime' })

-- Previews
keymap.set("n", "<A-m>", "<cmd>MarkdownPreviewToggle<cr>", { silent = true, desc = "Markdown Preview" })
keymap.set("n", "]]", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Next Markdown Header" })
keymap.set("n", "[[", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Previous Markdown Header" })

-- ============================================================================
-- MARKDOWN FOOTNOTES (normal mode only; insert mode unmapped in after/ftplugin)
-- ============================================================================
keymap.set("n", "<leader>mf", "<Plug>AddVimFootnote", { desc = "Add Footnote" })
keymap.set("n", "<leader>mr", "<Plug>ReturnFromFootnote", { desc = "Return from Footnote" })

-- General code runner
-- Universal run command that detects file type
vim.keymap.set('n', '<leader>rr', function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%')
  local filename_no_ext = vim.fn.expand('%:r')
  local cmd = ''

  if filetype == 'python' then
    cmd = 'python3 ' .. filename
  elseif filetype == 'java' then
    -- Use nvim-java command instead of terminal
    vim.cmd('JavaRunnerRunMain')
    return -- Exit early since we're not using terminal
  elseif filetype == 'c' then
    cmd = 'gcc -Wall -Wextra -std=c11 ' .. filename .. ' -o ' .. filename_no_ext .. ' && ./' .. filename_no_ext
  elseif filetype == 'cpp' then
    cmd = 'g++ -Wall -Wextra -std=c++17 ' .. filename .. ' -o ' .. filename_no_ext .. ' && ./' .. filename_no_ext
  elseif filetype == 'cs' then
    cmd = 'dotnet run'
  elseif filetype == 'javascript' then
    cmd = 'node ' .. filename
  elseif filetype == 'typescript' then
    cmd = 'ts-node ' .. filename
  elseif filetype == 'go' then
    cmd = 'go run ' .. filename
  elseif filetype == 'rust' then
    cmd = 'cargo run || rustc ' .. filename .. ' && ./' .. filename_no_ext
  elseif filetype == 'sh' or filetype == 'bash' then
    cmd = 'bash ' .. filename
  elseif filetype == 'lua' then
    cmd = 'lua ' .. filename
  elseif filetype == 'ruby' then
    cmd = 'ruby ' .. filename
  elseif filetype == 'php' then
    cmd = 'php ' .. filename
  else
    print('No run command configured for filetype: ' .. filetype)
    return
  end

  vim.cmd('vsplit | terminal ' .. cmd)
end, { noremap = true, desc = "Run current file" })

-- Do not move my cursor when joining lines.
keymap.set("n", "J", function()
  vim.cmd([[
      normal! mzJ`z
      delmarks z
    ]])
end, { desc = "join lines without moving cursor" })

keymap.set("n", "gJ", function()
  vim.cmd([[
      normal! mzgJ`z
      delmarks z
    ]])
end, { desc = "join lines without moving cursor" })

-- Break inserted text into smaller undo units when we insert some punctuation chars.
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
  keymap.set("i", ch, ch .. "<c-g>u")
end

-- insert semicolon in the end
keymap.set("i", "<A-;>", "<Esc>miA;<Esc>`ii")

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


-- ============================================================================
-- MACRO & ESCAPE FIXES
-- ============================================================================
keymap.set("n", "Q", "q", { desc = "Record macro" })

keymap.set("n", "<Esc>", function()
  vim.cmd("fclose!")
end, { desc = "close floating win" })


-- ============================================================================
-- SMART COMMENTING (Context-Aware, Multi-line Support, No Extra Plugins)
-- ============================================================================

local function smart_comment(action)
  local ft = vim.bo.filetype

  -- Base delimiters (Written safely so chat UI doesn't hide them!)
  local line_delims = {
    python = "#",
    lua = "--",
    javascript = "//",
    typescript = "//",
    java = "//",
    c = "//",
    cpp = "//",
    rust = "//",
    go = "//",
    ruby = "#",
    sh = "#",
    bash = "#",
    vim = '"',
    sql = "--",
    yaml = "#",
    toml = "#",
    tex = "%",
    cs = "//",
    nix = "#",
    html = "<" .. "!--"
  }

  local block_delims = {
    javascript = { s = "/*", e = "*/" },
    typescript = { s = "/*", e = "*/" },
    java = { s = "/*", e = "*/" },
    c = { s = "/*", e = "*/" },
    cpp = { s = "/*", e = "*/" },
    rust = { s = "/*", e = "*/" },
    go = { s = "/*", e = "*/" },
    css = { s = "/*", e = "*/" },
    php = { s = "/*", e = "*/" },
    nix = { s = "/*", e = "*/" },
    html = { s = "<" .. "!--", e = "--" .. ">" },
    xml = { s = "<" .. "!--", e = "--" .. ">" },
    markdown = { s = "<" .. "!--", e = "--" .. ">" },
  }

  local l_delim = line_delims[ft]
  local b_delim = block_delims[ft]

  if not l_delim and not b_delim then
    vim.notify("No comment pattern defined for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  -- Helper function: Escapes magic characters so lua doesn't break
  local function escape_magic(str)
    return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
  end

  if action == "uncomment" then
    for line_num = start_line, end_line do
      local line = vim.fn.getline(line_num)
      local new_line = line

      -- Remove Block Comments
      if b_delim then
        new_line = new_line:gsub(escape_magic(b_delim.s) .. "%s?", "")
        new_line = new_line:gsub("%s?" .. escape_magic(b_delim.e), "")
      end

      -- Remove Line Comments
      if l_delim then
        new_line = new_line:gsub(escape_magic(l_delim) .. "%s?", "")
      end

      if new_line ~= line then vim.fn.setline(line_num, new_line) end
    end
  elseif action == "comment" then
    local num_lines = end_line - start_line + 1

    if num_lines > 1 and b_delim then
      -- Multi-line selection: Wrap the whole block
      local first_line = vim.fn.getline(start_line)
      local last_line = vim.fn.getline(end_line)
      vim.fn.setline(start_line, b_delim.s .. " " .. first_line)
      vim.fn.setline(end_line, last_line .. " " .. b_delim.e)
    else
      -- Single line: Prepend line delimiter after indentation
      local delim = l_delim or b_delim.s
      for line_num = start_line, end_line do
        local line = vim.fn.getline(line_num)
        if line:match("%S") then -- Skip purely empty lines
          local indent, rest = line:match("^(%s*)(.*)")
          vim.fn.setline(line_num, indent .. delim .. " " .. rest)
        end
      end
    end
  end
end

-- Keybindings for Visual Mode (Selected lines)
keymap.set('x', 'gcr', function() smart_comment("uncomment") end, { desc = 'Smart Uncomment' })
keymap.set('x', 'gcs', function() smart_comment("comment") end, { desc = 'Smart Comment' })

-- Keybindings for Normal Mode (Current line)
keymap.set('n', 'gcr', function()
  vim.fn.setpos("'<", { 0, vim.fn.line("."), 1, 0 })
  vim.fn.setpos("'>", { 0, vim.fn.line("."), vim.fn.col("$"), 0 })
  smart_comment("uncomment")
end, { desc = 'Smart Uncomment' })

keymap.set('n', 'gcs', function()
  vim.fn.setpos("'<", { 0, vim.fn.line("."), 1, 0 })
  vim.fn.setpos("'>", { 0, vim.fn.line("."), vim.fn.col("$"), 0 })
  smart_comment("comment")
end, { desc = 'Smart Comment' })
