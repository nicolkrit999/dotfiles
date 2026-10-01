-- <A-m> markdown preview (markdown-preview.nvim defines :MarkdownPreviewToggle only for
-- markdown buffers); overrides the global "markdown only" warning map in lua/mappings.lua
vim.keymap.set("n", "<A-m>", "<cmd>MarkdownPreviewToggle<cr>", { buffer = true, silent = true, desc = "Markdown Preview" })

-- footnotes (vim-markdownfootnotes); override the global "markdown only" warning maps
vim.keymap.set("n", "<leader>mf", "<Plug>AddVimFootnote", { buffer = true, desc = "Add Footnote" })
vim.keymap.set("n", "<leader>mr", "<Plug>ReturnFromFootnote", { buffer = true, desc = "Return from Footnote" })

-- <Space>fm: format with prettier (marksman has no formatting provider, so the global LSP
-- <Space>fm map would do nothing here). The buffer contents go through stdin and only the
-- changed hunks are written back: one undo step, unchanged lines and their marks kept, nothing
-- written to disk. Afterwards the cursor goes back to the same text (see fm_cursor below).
-- Without prettier on PATH the key shows ONE warning.

-- squash runs of whitespace (prettier mostly changes spacing) for a "same text" comparison
local function squash(s)
  return (s:gsub("%s+", " "):gsub("^ ", ""):gsub(" $", ""))
end

-- byte column in `new_text` of the character that was at byte `col` (0-based) in `old_text`,
-- counted in non-blank characters (so a squashed run of spaces does not shift the cursor)
local function remap_col(old_text, new_text, col)
  local _, n = old_text:sub(1, col):gsub("%S", "")
  local seen = 0
  for i = 1, #new_text do
    if new_text:sub(i, i):match("%S") then
      if seen == n then
        return i - 1
      end
      seen = seen + 1
    end
  end
  return math.max(#new_text - 1, 0)
end

-- new {row, col} for a cursor at {row, col} of `old` after the hunks turned `old` into `new`:
-- a line outside the hunks keeps its text and column (shifted by the line-count changes above
-- it); a changed line is looked up in its hunk (same text, else same text with squashed
-- whitespace, nearest to its old offset); no match -> the same offset in the hunk, clamped.
local function fm_cursor(old, new, hunks, row, col)
  local delta = 0
  for _, h in ipairs(hunks) do
    local a_start, a_count, b_start, b_count = unpack(h)
    if a_count > 0 and row >= a_start and row < a_start + a_count then
      local text, want = old[row], b_start + (row - a_start)
      for pass = 1, 2 do
        local best
        for l = b_start, b_start + b_count - 1 do
          local same = new[l] == text
          if pass == 2 then
            same = squash(text) ~= "" and squash(new[l]) == squash(text)
          end
          if same and (not best or math.abs(l - want) < math.abs(best - want)) then
            best = l
          end
        end
        if best then
          return best, pass == 1 and col or remap_col(text, new[best], col)
        end
      end
      if b_count == 0 then
        return b_start + 1, col
      end
      return math.min(want, b_start + b_count - 1), col
    elseif (a_count > 0 and a_start + a_count - 1 < row) or (a_count == 0 and a_start < row) then
      delta = delta + b_count - a_count
    end
  end
  return row + delta, col
end

if vim.fn.executable("prettier") == 1 then
  vim.keymap.set("n", "<Space>fm", function()
    local buf = vim.api.nvim_get_current_buf()
    local tick = vim.b[buf].changedtick
    local old = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local cmd = { "prettier", "--parser", "markdown" }
    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= "" then
      -- lets prettier find the project's .prettierrc / .prettierignore
      vim.list_extend(cmd, { "--stdin-filepath", name })
    end
    vim.system(cmd, { stdin = table.concat(old, "\n") .. "\n", text = true }, function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          vim.notify("prettier failed: " .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
          return
        end
        if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].changedtick ~= tick then
          vim.notify("prettier: buffer changed while formatting, result discarded", vim.log.levels.WARN)
          return
        end
        local new = vim.split(res.stdout:gsub("\n$", ""), "\n", { plain = true })
        local diff = (vim.text and vim.text.diff) or vim.diff
        local hunks = diff(table.concat(old, "\n") .. "\n", table.concat(new, "\n") .. "\n", { result_type = "indices" })
        -- cursors of every window showing the buffer, restored to the same text afterwards
        local cursors = {}
        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
          cursors[win] = vim.api.nvim_win_get_cursor(win)
        end
        -- apply bottom-up so the earlier line numbers stay valid
        for i = #hunks, 1, -1 do
          local a_start, a_count, b_start, b_count = unpack(hunks[i])
          local first = a_count == 0 and a_start or a_start - 1
          vim.api.nvim_buf_set_lines(buf, first, first + a_count, false, vim.list_slice(new, b_start, b_start + b_count - 1))
        end
        local last = vim.api.nvim_buf_line_count(buf)
        for win, pos in pairs(cursors) do
          if vim.api.nvim_win_is_valid(win) then
            local row, col = fm_cursor(old, new, hunks, pos[1], pos[2])
            row = math.max(1, math.min(row, last))
            local len = #vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
            vim.api.nvim_win_set_cursor(win, { row, math.max(0, math.min(col, len - 1)) })
          end
        end
      end)
    end)
  end, { buffer = true, desc = "Format file (prettier)" })
else
  vim.keymap.set("n", "<Space>fm", function()
    vim.notify("Markdown: prettier not found on PATH", vim.log.levels.WARN)
  end, { buffer = true, desc = "Format file (needs prettier)" })
end

local function add_reference_at_end(label, url, title)
  vim.schedule(function()
    local bufnr = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    -- Prepare reference definition
    local ref_def = "[" .. label .. "]: " .. url
    if title and title ~= "" then
      ref_def = ref_def .. ' "' .. title .. '"'
    end

    -- Check if references section exists
    local buffer_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    local has_ref_section = false
    for _, line in ipairs(buffer_lines) do
      if line:match("^%s*<!%-%-.*[Rr]eferences?.*%-%->[%s]*$") then
        has_ref_section = true
        break
      end
    end

    local lines_to_add = {}
    -- Add references header if it doesn't exist
    if not has_ref_section then
      if #lines_to_add == 0 then
        table.insert(lines_to_add, "")
      end
      table.insert(lines_to_add, "<!-- Reference links -->")
    end

    table.insert(lines_to_add, ref_def)

    -- Insert at buffer end
    vim.api.nvim_buf_set_lines(bufnr, line_count, line_count, false, lines_to_add)
  end)
end

local function get_ref_link_labels()
  local labels = {}
  local seen = {} -- To avoid duplicates
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for _, line in ipairs(lines) do
    -- Pattern explanation:
    -- %[.-%] matches [link text] (non-greedy)
    -- %[(.-)%] matches [label] and captures the label content
    local start_pos = 1
    while start_pos <= #line do
      local match_start, match_end, label = string.find(line, "%[.-%]%[(.-)%]", start_pos)
      if not match_start then
        break
      end

      -- Only add unique labels
      if label and label ~= "" and not seen[label] then
        table.insert(labels, label)
        seen[label] = true
      end

      start_pos = match_end + 1
    end
  end

  return labels
end

local function count_consecutive_spaces(str)
  -- Remove leading spaces first
  local trimmed = str:match("^%s*(.*)")
  local count = 0

  -- Count each sequence of one or more consecutive spaces
  for spaces in trimmed:gmatch("%s+") do
    count = count + 1
  end
  return count
end

vim.api.nvim_buf_create_user_command(0, "AddRef", function(opts)
  local args = vim.split(opts.args, " ", { trimempty = true })

  if #args < 2 then
    vim.print("Usage: :AddRef <label> <url>")
    return
  end

  local label = args[1]
  local url = args[2]

  add_reference_at_end(label, url, "")
end, {
  desc = "Add reference link at buffer end",
  nargs = "+",
  complete = function(arg_lead, cmdline, curpos)
    -- vim.print(string.format("arg_lead: '%s', cmdline: '%s', curpos: %d", arg_lead, cmdline, curpos))

    -- only complete the first argument
    if count_consecutive_spaces(cmdline) > 1 then
      -- we are now starting the second argument, so no completion anymore
      return {}
    end

    local ref_link_labels = get_ref_link_labels()
    return ref_link_labels
  end,
})
