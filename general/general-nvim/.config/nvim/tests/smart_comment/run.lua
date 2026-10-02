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
local function mkbuf(ft, lines, cs)
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].undolevels = -1
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = ft
  if cs then
    vim.bo[buf].commentstring = cs
  end
  vim.bo[buf].undolevels = 1000
  return buf
end

local function lines_of(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

local function run(ft, lines, s, e, act, backend, cs)
  local buf = mkbuf(ft, lines, cs)
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
      local got, buf, err = run(c.ft, c.lines, c.s, c.e, c.act, be, c.cs)
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

      -- the one-go write used for large ranges in heavily injected buffers gives the same result
      if bi == 1 then
        local budget = sc.bulk_budget
        sc.bulk_budget = -1
        local gb, bb, errb = run(c.ft, c.lines, c.s, c.e, c.act, be, c.cs)
        sc.bulk_budget = budget
        record(gb and vim.deep_equal(gb, c.exp), c.name, c, be, "bulk write", c.lines, c.s, c.e, c.act, c.exp, gb or errb)
        cleanup(bb)
      end

      -- idempotence: applying the same action to the expected output changes nothing
      if not c.noidem then
        local e2 = c.e + (#c.exp - #c.lines)
        if e2 >= c.s then
          local g2, b2, err2 = run(c.ft, c.exp, c.s, e2, c.act, be, c.cs)
          record(g2 and vim.deep_equal(g2, c.exp), c.name, c, be, "idempotent", c.exp, c.s, e2, c.act, c.exp, g2 or err2)
          cleanup(b2)
        end
      end

      -- gcr(gcs(x)) == x for marker-free code
      if c.rt and c.act == "c" then
        local e2 = c.e + (#c.exp - #c.lines)
        local g3, b3, err3 = run(c.ft, c.exp, c.s, e2, "u", be, c.cs)
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
  -- Q45: only the marker bytes change, so marks, extmarks, '< '> and gv behave like builtin gc
  {
    name = "Q45 lowercase mark kept by gcs",
    lines = { "a();", "  bb();", "c();" },
    keys = { "2G4|", "ma", "gcs" },
    exp = { "a();", "  // bb();", "c();" },
    check = function()
      local m = vim.api.nvim_buf_get_mark(0, "a")
      return m[1] == 2, "mark a=" .. vim.inspect(m)
    end,
  },
  {
    name = "Q45 lowercase mark kept by gcr",
    lines = { "// a();", "// b();" },
    keys = { "2G4|", "ma", "gg", "Vj", "gcr" },
    exp = { "a();", "b();" },
    check = function()
      local m = vim.api.nvim_buf_get_mark(0, "a")
      return m[1] == 2, "mark a=" .. vim.inspect(m)
    end,
  },
  {
    name = "Q45 extmark follows its text on gcs",
    lines = { "a();", "  bb();", "c();" },
    setup = function(buf)
      local ns = vim.api.nvim_create_namespace("sc_test")
      vim.b[buf].sc_mark = vim.api.nvim_buf_set_extmark(buf, ns, 1, 3, {})
    end,
    keys = { "2G", "gcs" },
    exp = { "a();", "  // bb();", "c();" },
    check = function(buf)
      local ns = vim.api.nvim_create_namespace("sc_test")
      local p = vim.api.nvim_buf_get_extmark_by_id(buf, ns, vim.b[buf].sc_mark, {})
      return p[1] == 1 and p[2] == 6, "extmark=" .. vim.inspect(p)
    end,
  },
  {
    name = "Q45 gv after visual gcs reselects all rows",
    lines = { "a();", "b();", "c();", "d();", "e();" },
    keys = { "2GVjj", "gcs", "gv" },
    exp = { "a();", "// b();", "// c();", "// d();", "e();" },
    check = function()
      local s, e = vim.fn.line("v"), vim.fn.line(".")
      return vim.api.nvim_get_mode().mode == "V" and math.min(s, e) == 2 and math.max(s, e) == 4,
        string.format("visual %d-%d mode=%s", s, e, vim.api.nvim_get_mode().mode)
    end,
  },
  {
    name = "Q45 cursor stays on its text when gcr deletes a row above",
    lines = { "x();", "/*", "a();", "b();", "*/", "y();" },
    keys = { "3GVj", "gcr" },
    exp = { "x();", "a();", "b();", "y();" },
    check = function()
      return vim.fn.line(".") == 3, "cursor row " .. vim.fn.line(".")
    end,
  },
  {
    name = "Q45 one-go write (large range) keeps lowercase marks and gv",
    lines = { "a();", "  bb();", "c();", "d();" },
    setup = function()
      sc.bulk_budget = -1
    end,
    teardown = function()
      sc.bulk_budget = 50000
    end,
    keys = { "2G4|", "ma", "2GVj", "gcs", "gv" },
    exp = { "a();", "//   bb();", "// c();", "d();" },
    check = function()
      local m = vim.api.nvim_buf_get_mark(0, "a")
      local s, e = vim.fn.line("v"), vim.fn.line(".")
      return m[1] == 2 and math.min(s, e) == 2 and math.max(s, e) == 3,
        string.format("mark a=%s visual %d-%d", vim.inspect(m), s, e)
    end,
  },
  {
    name = "Q45 single undo after gcr deleting delimiter rows",
    lines = { "x();", "/*", "a();", "b();", "*/", "y();" },
    keys = { "3GVj", "gcr", "u" },
    exp = { "x();", "/*", "a();", "b();", "*/", "y();" },
  },
}
for _, t in ipairs(keymap_tests) do
  if not fft or fft == "c" then
    local buf = mkbuf("c", t.lines)
    if t.setup then
      t.setup(buf)
    end
    local okk, err = pcall(function()
      for _, k in ipairs(t.keys) do
        keys(k)
      end
    end)
    local got = lines_of(buf)
    local mode = vim.api.nvim_get_mode().mode
    local ok = okk and vim.deep_equal(got, t.exp) and (not t.mode or mode == t.mode)
    local note
    if ok and t.check then
      local okc, cok, cmsg = pcall(t.check, buf)
      ok = okc and cok
      note = okc and cmsg or ("check ERROR: " .. tostring(cok))
    end
    if t.teardown then
      t.teardown(buf)
    end
    record(ok, t.name, { ft = "c" }, "keys", "keymap", t.lines, 0, 0, "c", t.exp,
      okk and ((t.mode and (show(got) .. " mode=" .. mode) or show(got)) .. (note and ("  " .. note) or ""))
      or ("ERROR: " .. tostring(err)))
    keys("<Esc>")
    cleanup(buf)
  end
end

--------------------------------------------------------------------------------------------------
-- Q46 perf sanity: 3000 python rows with trailing comments (3000 injected `comment` trees), parsed
-- and highlighted like a real buffer. Was ~4.6 s (gcs) / ~2.6 s (gcr); now ~0.2 s. The limit is
-- generous so a busy machine does not fail it; the result must match the lexer's.
--------------------------------------------------------------------------------------------------
if (not fft or fft == "python") and not fname and ts_available("python") then
  local function perf(label, gen, act)
    local lines = {}
    for i = 1, 3000 do
      lines[i] = gen(i)
    end
    local buf = mkbuf("python", lines)
    pcall(vim.treesitter.start, buf)
    vim.treesitter.get_parser(buf):parse(true)
    local t0 = vim.uv.hrtime()
    local okp, err = pcall(sc.apply, buf, 1, #lines, act)
    local ms = (vim.uv.hrtime() - t0) / 1e6
    local got = lines_of(buf)
    cleanup(buf)
    local lb = mkbuf("python", lines)
    sc.apply(lb, 1, #lines, act, { backend = "lexer" })
    local want = lines_of(lb)
    cleanup(lb)
    record(okp and ms < 2000 and vim.deep_equal(got, want), label, { ft = "python" }, "ts", "perf < 2 s", { "(3000 rows)" },
      1, #lines, act == "comment" and "c" or "u", { "same as lexer, < 2000 ms" },
      okp and string.format("%.0f ms, same as lexer: %s", ms, tostring(vim.deep_equal(got, want))) or ("ERROR: " .. tostring(err)))
  end
  perf("Q46 gcs-all 3000 rows with trailing comments", function(i)
    return "x" .. i .. " = 'a # b'  # c"
  end, "comment")
  perf("Q46 gcr-all 3000 comment rows", function(i)
    return "# x" .. i .. " = 1"
  end, "uncomment")
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
