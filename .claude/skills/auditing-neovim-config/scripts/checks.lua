-- Health/behaviour checks. INV_OUT=<dir> INV_SAMPLES=<dir> nvim --headless "+lua dofile('<path>/checks.lua')"
-- Writes: startup_messages.txt, loadall.txt, filetypes.txt, checkhealth.txt, keymap_dupes.txt
local out = assert(vim.env.INV_OUT)
local samples = assert(vim.env.INV_SAMPLES, "set INV_SAMPLES to the samples dir")
vim.fn.mkdir(out, "p")
local function write(name, lines)
  local f = assert(io.open(out .. "/" .. name .. ".txt", "w"))
  f:write(table.concat(lines, "\n"), "\n")
  f:close()
end
local function msgs()
  return vim.split(vim.api.nvim_exec2("messages", { output = true }).output, "\n", { trimempty = true })
end

-- notify history (nvim-notify swallows vim.notify, so :messages misses plugin warnings)
local function notify_lines(tag)
  local res = {}
  local ok, notify = pcall(require, "notify")
  if not ok then return res end
  for _, n in ipairs(notify.history()) do
    if n.level ~= "DEBUG" and n.level ~= "TRACE" then
      table.insert(res, tag .. "\t" .. n.level .. "\t" .. table.concat(n.message, " "):gsub("\n", " "))
    end
  end
  pcall(notify.clear_history)
  return res
end
local notified = {}

local function main()
vim.wait(3000, function() return false end)
write("startup_messages", msgs())
vim.list_extend(notified, notify_lines("startup"))
vim.cmd("messages clear")

-- 1) force-load every lazy plugin so config errors that only show on first use surface now
local res = {}
local ok, lazy = pcall(require, "lazy")
if ok then
  for _, p in ipairs(lazy.plugins()) do
    local lok, err = pcall(function() require("lazy.core.loader").load(p, { cmd = "verify" }) end)
    if not lok then table.insert(res, "LOADERR\t" .. p.name .. "\t" .. tostring(err):gsub("\n", " ")) end
  end
end
vim.wait(1500, function() return false end)
for _, m in ipairs(msgs()) do
  if m:match("[Ee]rror") or m:match("E%d+:") or m:match("[Ww]arn") or m:match("[Ff]ailed") or m:match("ENOENT") then
    table.insert(res, "MSG\t" .. m)
  end
end
vim.list_extend(notified, notify_lines("loadall"))
write("loadall", res)
vim.cmd("messages clear")

-- 2) filetype smoke test: ft, treesitter highlighter, ALL LSP clients, errors
-- Waits until every enabled LSP config that applies to the filetype is attached + initialized
-- (or 20 s), then settles before wiping (avoids the lua_ls root_dir / %bwipeout race).
local ft = {}
local files = {}
for _, f in ipairs(vim.fn.glob(samples .. "/*", false, true)) do
  if vim.fn.isdirectory(f) == 1 then
    vim.list_extend(files, vim.fn.glob(f .. "/*", false, true)) -- project samples (e.g. java-project/)
  else
    table.insert(files, f)
  end
end
for _, f in ipairs(files) do
  vim.v.errmsg = ""
  local eok, eerr = pcall(vim.cmd.edit, f)
  local buf = vim.api.nvim_get_current_buf()
  local bft = vim.bo[buf].filetype
  local expected = {}
  for _, c in ipairs(vim.lsp.get_configs({ enabled = true })) do
    if c.filetypes == nil or vim.list_contains(c.filetypes, bft) then expected[c.name] = true end
  end
  local function attached()
    local got = {}
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      if c.initialized then got[c.name] = true end
    end
    return got
  end
  vim.wait(20000, function()
    local got = attached()
    for name in pairs(expected) do
      if not got[name] then return false end
    end
    return true
  end, 200)
  vim.wait(1500, function() return false end)
  local names, missing, got = {}, {}, attached()
  for name in pairs(got) do table.insert(names, name) end
  for name in pairs(expected) do if not got[name] then table.insert(missing, name) end end
  table.sort(names)
  table.sort(missing)
  local ts = vim.treesitter.highlighter.active[buf] ~= nil
  table.insert(ft, string.format("%s\tft=%s\tts=%s\tlsp=%s\tmissing=%s\terr=%s",
    f:sub(#samples + 2), bft, tostring(ts), table.concat(names, ","), table.concat(missing, ","),
    eok and vim.v.errmsg or tostring(eerr)))
  vim.cmd("silent! %bwipeout!")
  vim.wait(300, function() return false end)
end
for _, m in ipairs(msgs()) do
  if m:match("[Ee]rror") or m:match("E%d+:") or m:match("[Ff]ailed") or m:match("ENOENT") or m:match("[Ww]arn") then
    table.insert(ft, "MSG\t" .. m)
  end
end
vim.list_extend(notified, notify_lines("filetypes"))
write("filetypes", ft)

-- 3) duplicate keymaps defined by different sources (same mode+lhs is impossible globally, so check buffer-local vs global shadowing on a lua buffer)
local dup = {}
vim.cmd.edit(samples .. "/a.lua")
vim.wait(3000, function() return false end)
for _, mode in ipairs({ "n", "x", "i", "o" }) do
  local g = {}
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do g[m.lhs] = m.desc or m.rhs or "<fn>" end
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
    if g[m.lhs] then
      table.insert(dup, string.format("%s\t%s\tbuf=%s\tglobal=%s", mode, m.lhs:gsub(" ", "<Space>"), m.desc or m.rhs or "<fn>", g[m.lhs]))
    end
  end
end
table.sort(dup)
write("keymap_shadowing", dup)

-- 4) checkhealth, keep only ERROR/WARNING lines with their section
-- snacks (and others) apply vim.ui.* overrides on UIEnter, which never fires headless
pcall(vim.cmd, "doautocmd UIEnter")
vim.cmd("silent! checkhealth")
vim.wait(8000, function() return false end)
local lines, section, h = vim.api.nvim_buf_get_lines(0, 0, -1, false), "", {}
for _, l in ipairs(lines) do
  if l:match("^%S.*~$") or l:match("^=+") == nil and l:match("^[%w_.%-]+:") then section = l end
  if l:match("ERROR") or l:match("WARNING") then table.insert(h, section .. " | " .. vim.trim(l)) end
end
write("checkhealth", h)

-- Split known noise / false positives (EDIT this list for your config; format "<section> | <line>") from new lines -> checkhealth_unexpected.txt
local ignore = {
  "Configured `hg_cmd` is not executable: 'hg'", -- diffview: no mercurial
  "found existing packages at `.*/site/pack/hm`", -- lazy.nvim: nix home-manager pack dir (intended)
  "Nvim %d+%.%d+%.%d+ is available", -- informational
  "^mason%.nvim", -- mason removed (W3); kept so older nix-less runs stay comparable
  "tree%-sitter%-cli not found", -- parsers come from nix
  "^GDB backend ~ |.*ERROR failed", -- nvim-gdb: gdb only in c-cpp/rust devShells
  "^LLDB backend ~ |.*ERROR failed",
  "^RR executable ~ |.*ERROR failed",
  "^BashDB backend ~ |.*ERROR failed",
  "'viu' not found", -- fzf-lua optional media previewer
  "^Snacks%.%w+ ~ |.*setup {disabled}", -- unused snacks modules
  "^Snacks%.image ~ |", -- image module disabled; headless terminal / optional tools
  "^Snacks%.notifier ~ |.*is not ready", -- notifier module disabled
  "`SQLite3` is not available", -- snacks picker frecency falls back to a file
  "vim%.validate{<table>} is deprecated", -- nvim-dbee, accepted (upstream inactive)
  "WARNINGS should be treated as a warning", -- which-key info line, not a warning
  -- which-key overlaps = KNOWN prefix waits; a NEW overlap still shows
  "In mode `n`, <c> overlaps with <cc>:",
  "In mode `n`, <<Space>f> overlaps with <<Space>f%a>", -- buffer-local lua/python/json <Space>f (accepted)
  "In mode `n`, <<Space>q> overlaps with <<Space>q%a>",
  "In mode `n`, <<Space>s> overlaps with <<Space>sv>:",
  "In mode `n`, <s[rd]> overlaps with <s[rd]b>:", -- vim-sandwich
  "In mode `n`, <g!> overlaps with <g!!>", -- vim-scriptease own defaults (accepted noise)
  "In mode `n`, <g=> overlaps with <g==>", -- vim-scriptease own defaults (accepted noise)
  "In mode `[nx]`, <gc> overlaps with <gc", -- commentary / smart_comment
  "In mode `n`, <gc([sr])> overlaps with <gc%1%1>:", -- smart_comment gcs/gcss, gcr/gcrr (accepted prefix wait)
  "In mode `x`, <@> overlaps with <@%(targets%)>:",
  "In mode `[xo]`, <[ai]> overlaps with <[ai][%%isancS]>", -- targets / matchup / mini.indentscope (order varies per run)
}
local unexpected = {}
for _, l in ipairs(h) do
  local known = false
  for _, pat in ipairs(ignore) do
    if l:find(pat) then
      known = true
      break
    end
  end
  if not known then table.insert(unexpected, l) end
end
write("checkhealth_unexpected", unexpected)
local f = assert(io.open(out .. "/checkhealth_full.txt", "w"))
f:write(table.concat(lines, "\n"))
f:close()
write("notify_history", notified)
vim.cmd("qa!")
end

-- run after VimEnter so VeryLazy plugins (which-key, ...) are loaded like in a real session
if vim.v.vim_did_enter == 1 then
  main()
else
  vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = function() vim.schedule(main) end })
end
