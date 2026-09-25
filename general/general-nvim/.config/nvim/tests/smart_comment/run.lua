-- Runner for the smart_comment suite. From the nvim config dir:
--   nvim --headless -c 'luafile tests/smart_comment/run.lua' -c 'qa!'
-- Optional filters (env): SC_FT=lua (filetype), SC_NAME=pattern (case name), SC_VERBOSE=1 (list passes).
local dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local cases = dofile(dir .. "/cases.lua").cases
local sc = require("smart_comment")

-- Keep FileType autocmds (ftplugins) but never start language servers.
vim.lsp.start = function() end
vim.lsp.enable = function() end

local out = {}
local function say(s)
  table.insert(out, s)
  io.stdout:write(s .. "\n")
end

local pass, fail, results = 0, 0, {}
local function show(t)
  local parts = {}
  for _, l in ipairs(t) do
    table.insert(parts, vim.inspect(l))
  end
  return "{ " .. table.concat(parts, ", ") .. " }"
end
local function record(ok, label, c, backend, check, input, s, e, act, exp, got)
  local r = {
    ok = ok,
    text = string.format("[%s] %-10s %-6s %-4s %-22s %s  sel=%d-%d\n      input:    %s\n      expected: %s\n      got:      %s",
      ok and "PASS" or "FAIL", c.ft, backend, act == "c" and "gcs" or "gcr", check, label, s, e, show(input), show(exp),
      type(got) == "string" and got or show(got)),
  }
  if ok then
    pass = pass + 1
  else
    fail = fail + 1
  end
  table.insert(results, r)
end

local has_ts = {}
local function ts_available(ft)
  if has_ts[ft] == nil then
    local lang = vim.treesitter.language.get_lang(ft) or ft
    local ok, res = pcall(vim.treesitter.language.add, lang)
    has_ts[ft] = ok and res == true
  end
  return has_ts[ft]
end

-- Fresh buffer in the current window with `lines` and filetype `ft`, and an empty undo history.
local function mkbuf(ft, lines)
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].undolevels = -1
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = ft
  vim.bo[buf].undolevels = 1000
  return buf
end

local function lines_of(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

local function run(ft, lines, s, e, act, backend)
  local buf = mkbuf(ft, lines)
  local ok, err = pcall(sc.apply, buf, s, e, act == "c" and "comment" or "uncomment", { backend = backend })
  if not ok then
    return nil, buf, "ERROR: " .. tostring(err)
  end
  return lines_of(buf), buf
end

local function cleanup(buf)
  pcall(vim.api.nvim_buf_delete, buf, { force = true })
end

local fft, fname = os.getenv("SC_FT"), os.getenv("SC_NAME")

for _, c in ipairs(cases) do
  if (not fft or fft == c.ft) and (not fname or c.name:find(fname)) then
    local backends = { "lexer" }
    if ts_available(c.ft) then
      table.insert(backends, 1, "ts")
    end
    for bi, be in ipairs(backends) do
      local got, buf, err = run(c.ft, c.lines, c.s, c.e, c.act, be)
      local ok = got and vim.deep_equal(got, c.exp)
      record(ok, c.name, c, be, "result", c.lines, c.s, c.e, c.act, c.exp, got or err)

      -- undo restores the original (once per case)
      if bi == 1 and got and not vim.deep_equal(got, c.lines) then
        vim.api.nvim_set_current_buf(buf)
        pcall(vim.cmd, "silent undo")
        local u = lines_of(buf)
        record(vim.deep_equal(u, c.lines), c.name, c, be, "undo restores", c.lines, c.s, c.e, c.act, c.lines, u)
      end
      cleanup(buf)

      -- idempotence: applying the same action to the expected output changes nothing
      if not c.noidem then
        local e2 = c.e + (#c.exp - #c.lines)
        if e2 >= c.s then
          local g2, b2, err2 = run(c.ft, c.exp, c.s, e2, c.act, be)
          record(g2 and vim.deep_equal(g2, c.exp), c.name, c, be, "idempotent", c.exp, c.s, e2, c.act, c.exp, g2 or err2)
          cleanup(b2)
        end
      end

      -- gcr(gcs(x)) == x for marker-free code
      if c.rt and c.act == "c" then
        local e2 = c.e + (#c.exp - #c.lines)
        local g3, b3, err3 = run(c.ft, c.exp, c.s, e2, "u", be)
        record(g3 and vim.deep_equal(g3, c.lines), c.name, c, be, "gcr(gcs(x)) == x", c.exp, c.s, e2, "u", c.lines,
          g3 or err3)
        cleanup(b3)
      end
    end
  end
end

--------------------------------------------------------------------------------------------------
-- Keymap tests (real keys through feedkeys)
--------------------------------------------------------------------------------------------------
local function keys(k)
  vim.api.nvim_feedkeys(vim.keycode(k), "mx", false)
end
local keymap_tests = {
  {
    name = "normal gcs on current line",
    lines = { "a();", "b();", "c();" },
    keys = { "2G", "gcs" },
    exp = { "a();", "// b();", "c();" },
  },
  {
    name = "normal 3gcr (count)",
    lines = { "// a();", "// b();", "// c();", "// d();" },
    keys = { "gg", "3gcr" },
    exp = { "a();", "b();", "c();", "// d();" },
  },
  {
    name = "normal 2gcs (count) from row 2",
    lines = { "a();", "b();", "c();", "d();" },
    keys = { "2G", "2gcs" },
    exp = { "a();", "// b();", "// c();", "d();" },
  },
  {
    name = "V j gcs acts on CURRENT selection, not previous",
    lines = { "a();", "b();", "c();", "d();", "e();" },
    keys = { "ggVj<Esc>", "4GVj", "gcs" },
    exp = { "a();", "b();", "c();", "// d();", "// e();" },
  },
  {
    name = "V k gcs (reversed selection) after a previous selection",
    lines = { "a();", "b();", "c();", "d();", "e();" },
    keys = { "4GVj<Esc>", "2GVk", "gcs" },
    exp = { "// a();", "// b();", "c();", "d();", "e();" },
  },
  {
    name = "charwise v gcr acts on whole lines of current selection",
    lines = { "// a();", "// b();", "// c();", "// d();" },
    keys = { "ggvj<Esc>", "3Glvj", "gcr" },
    exp = { "// a();", "// b();", "c();", "d();" },
  },
  {
    name = "blockwise <C-v> gcs",
    lines = { "a();", "b();", "c();" },
    keys = { "gg<C-v>j", "gcs" },
    exp = { "// a();", "// b();", "c();" },
  },
  {
    name = "after visual gcs, normal gcs acts on the cursor line only",
    lines = { "a();", "b();", "c();", "d();" },
    keys = { "ggVj", "gcs", "4G", "gcs" },
    exp = { "// a();", "// b();", "c();", "// d();" },
  },
  {
    name = "visual gcs leaves visual mode",
    lines = { "a();", "b();" },
    keys = { "ggVj", "gcs" },
    exp = { "// a();", "// b();" },
    mode = "n",
  },
  {
    name = "single undo after visual gcs",
    lines = { "a();", "b();", "c();" },
    keys = { "ggVjj", "gcs", "u" },
    exp = { "a();", "b();", "c();" },
  },
}
for _, t in ipairs(keymap_tests) do
  if not fft or fft == "c" then
    local buf = mkbuf("c", t.lines)
    local okk, err = pcall(function()
      for _, k in ipairs(t.keys) do
        keys(k)
      end
    end)
    local got = lines_of(buf)
    local mode = vim.api.nvim_get_mode().mode
    local ok = okk and vim.deep_equal(got, t.exp) and (not t.mode or mode == t.mode)
    record(ok, t.name, { ft = "c" }, "keys", "keymap", t.lines, 0, 0, "c", t.exp,
      okk and (t.mode and (show(got) .. " mode=" .. mode) or got) or ("ERROR: " .. tostring(err)))
    keys("<Esc>")
    cleanup(buf)
  end
end

--------------------------------------------------------------------------------------------------
say("")
for _, r in ipairs(results) do
  if not r.ok or os.getenv("SC_VERBOSE") then
    say(r.text)
  end
end
say(string.format("\nsmart_comment: %d passed, %d failed, %d total", pass, fail, pass + fail))
local f = io.open(dir .. "/last_run.txt", "w")
if f then
  f:write(table.concat(out, "\n") .. "\n")
  f:close()
end
if fail > 0 then
  vim.cmd("cquit 1")
end
