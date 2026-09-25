-- Table-driven cases for smart_comment (gcs = "comment", gcr = "uncomment").
--
-- A case: { ft, lines = {...}, s, e, act = "c"|"u", exp = {...}, name, rt? }
--   lines/exp are the WHOLE buffer; s/e the selected rows (default: all rows).
--   rt = true: code-only gcs case, also checks gcr(gcs(x)) == x.
-- Expectations follow the written specification, not the implementation.
local M = {}
local cases = {}

local function add(ft, name, lines, act, exp, opts)
  opts = opts or {}
  table.insert(cases, {
    ft = ft,
    name = name,
    lines = lines,
    act = act,
    exp = exp,
    s = opts.s or 1,
    e = opts.e or #lines,
    rt = opts.rt,
    noidem = opts.noidem,
  })
end

-- Both actions on the same input.
local function both(ft, name, lines, exp_c, exp_u, opts)
  add(ft, name, lines, "c", exp_c, opts)
  add(ft, name, lines, "u", exp_u, opts and { s = opts.s, e = opts.e, noidem = opts.noidem } or nil)
end

--------------------------------------------------------------------------------------------------
-- Generic spec cases 1-6 for every language in scope
--------------------------------------------------------------------------------------------------
-- lm: line marker gcs inserts; wrap: {open, close} for languages without line comments;
-- block: an inline block comment {open, close}; code/code2: marker-free code; pre: rows the buffer
-- must start with (php `<?php`), never selected.
local langs = {
  { "python", lm = "#", code = "x = 1", code2 = "y = foo(x)" },
  { "lua", lm = "--", block = { "--[[", "]]" }, code = "local x = 1", code2 = "print(x)" },
  { "javascript", lm = "//", block = { "/*", "*/" }, code = "let x = 1;", code2 = "foo(x);" },
  { "typescript", lm = "//", block = { "/*", "*/" }, code = "let x: number = 1;", code2 = "foo(x);" },
  { "java", lm = "//", block = { "/*", "*/" }, code = "int x = 1;", code2 = "foo(x);" },
  { "c", lm = "//", block = { "/*", "*/" }, code = "int x = 1;", code2 = "foo(x);" },
  { "cpp", lm = "//", block = { "/*", "*/" }, code = "int x = 1;", code2 = "foo(x);" },
  { "rust", lm = "//", block = { "/*", "*/" }, code = "let x = 1;", code2 = "foo(x);" },
  { "go", lm = "//", block = { "/*", "*/" }, code = "x := 1", code2 = "foo(x)" },
  { "ruby", lm = "#", code = "x = 1", code2 = "foo(x)" },
  { "sh", lm = "#", code = "x=1", code2 = "echo \"$x\"" },
  { "bash", lm = "#", code = "x=1", code2 = "echo \"$x\"" },
  { "zsh", lm = "#", code = "x=1", code2 = "echo \"$x\"" },
  { "vim", lm = '"', code = "let x = 1", code2 = "call Foo(x)", bol_only = true, bol_heuristic = true },
  { "sql", lm = "--", block = { "/*", "*/" }, code = "SELECT a FROM t;", code2 = "DELETE FROM t;" },
  { "yaml", lm = "#", code = "a: 1", code2 = "b: [1, 2]" },
  { "toml", lm = "#", code = "a = 1", code2 = "b = [1, 2]" },
  { "tex", lm = "%", code = "\\section{A}", code2 = "\\textbf{x}" },
  { "cs", lm = "//", block = { "/*", "*/" }, code = "int x = 1;", code2 = "Foo(x);" },
  { "nix", lm = "#", block = { "/*", "*/" }, code = "x = 1;", code2 = "y = f x;" },
  { "php", lm = "//", block = { "/*", "*/" }, code = "$x = 1;", code2 = "foo($x);", pre = { "<?php" } },
  { "html", wrap = { "<!--", "-->" }, code = "<p>a</p>", code2 = "<div>b</div>" },
  { "css", wrap = { "/*", "*/" }, code = "a { color: red; }", code2 = "b { margin: 0; }" },
  { "xml", wrap = { "<!--", "-->" }, code = "<a>1</a>", code2 = "<b>2</b>" },
  { "markdown", wrap = { "<!--", "-->" }, code = "some text", code2 = "- item" },
  { "typst", lm = "//", block = { "/*", "*/" }, code = "let x = 1", code2 = "foo(x)" },
  { "lisp", lm = ";", block = { "#|", "|#" }, code = "(setq x 1)", code2 = "(foo x)" },
  { "haskell", lm = "--", block = { "{-", "-}" }, code = "x = 1", code2 = "foo x" },
  { "kotlin", lm = "//", block = { "/*", "*/" }, code = "val x = 1", code2 = "foo(x)" },
  { "swift", lm = "//", block = { "/*", "*/" }, code = "let x = 1", code2 = "foo(x)" },
  { "scala", lm = "//", block = { "/*", "*/" }, code = "val x = 1", code2 = "foo(x)" },
  { "r", lm = "#", code = "x <- 1", code2 = "foo(x)" },
  { "julia", lm = "#", block = { "#=", "=#" }, code = "x = 1", code2 = "foo(x)" },
  { "ps1", lm = "#", block = { "<#", "#>" }, code = "$x = 1", code2 = "Foo($x)" },
  { "perl", lm = "#", code = "my $x = 1;", code2 = "foo($x);" },
  { "zig", lm = "//", code = "const x = 1;", code2 = "foo(x);" },
  { "asm", lm = ";", block = { "/*", "*/" }, code = "mov ax, 1", code2 = "call foo" },
  { "fish", lm = "#", code = "set x 1", code2 = "foo $x" },
  { "make", lm = "#", code = "x = 1", code2 = "all: x" },
  { "dockerfile", lm = "#", code = "ENV X=1", code2 = "RUN foo", bol_only = true },
}

local function prefixed(L, rows)
  local out = vim.list_extend(vim.deepcopy(L.pre or {}), rows)
  return out
end

for _, L in ipairs(langs) do
  local ft = L[1]
  local P = #(L.pre or {})
  local function sel(n)
    return { s = P + 1, e = P + n }
  end
  local function selrt(n)
    return { s = P + 1, e = P + n, rt = true }
  end
  -- com(text): a commented row with `text` after the marker (text may start with spaces)
  local function com(text, indent)
    indent = indent or ""
    if L.lm then
      return indent .. L.lm .. " " .. text
    end
    return indent .. L.wrap[1] .. " " .. text .. " " .. L.wrap[2]
  end
  local C, C2 = L.code, L.code2
  local function B(rows)
    return prefixed(L, rows)
  end

  -- 1. only code
  add(ft, "1 code gcs", B({ C }), "c", B({ com(C) }), selrt(1))
  add(ft, "1 code gcr", B({ C }), "u", B({ C }), sel(1))
  add(ft, "1 indented code gcs", B({ "    " .. C }), "c", B({ com(C, "    ") }), selrt(1))
  add(ft, "1 trailing spaces trimmed gcs", B({ C .. "   " }), "c", B({ com(C) }), sel(1))

  -- 2. only comment
  add(ft, "2 comment gcs no-op", B({ com("hello world") }), "c", B({ com("hello world") }), sel(1))
  add(ft, "2 comment gcr", B({ com("hello world") }), "u", B({ "hello world" }), sel(1))
  add(ft, "2 indented comment gcr", B({ com("hello", "  ") }), "u", B({ "  hello" }), sel(1))
  if L.lm then
    local m = L.lm
    add(ft, "2 double marker gcs", B({ m .. " " .. m .. " a" }), "c", B({ m .. " a" }), sel(1))
    -- vim: `"` inside comment text is usually a quote, so it is never a redundant marker (ruling).
    -- bol_only languages (vim, dockerfile): the marker only means "comment" at column 1, so one
    -- occurring later in the line is just literal text, never a redundant marker to clean up.
    local inner_exp = L.bol_only and (m .. " a " .. m .. " b") or (m .. " a b")
    add(ft, "2 inner redundant marker gcs", B({ m .. " a " .. m .. " b" }), "c", B({ inner_exp }), sel(1))
    add(ft, "2 double marker gcr", B({ m .. " " .. m .. " a" }), "u", B({ "a" }), sel(1))
    add(ft, "2 no space after marker gcr", B({ m .. "a" }), "u", B({ "a" }), sel(1))
  else
    local o, c = L.wrap[1], L.wrap[2]
    add(ft, "2 wrapped comment, extra inner opener gcs", B({ o .. " " .. o .. " a " .. c }), "c",
      B({ o .. " a " .. c }), sel(1))
  end
  if L.block and L.lm then
    local o, c = L.block[1], L.block[2]
    add(ft, "2 block comment line gcs no-op", B({ o .. " note " .. c }), "c", B({ o .. " note " .. c }), sel(1))
    add(ft, "2 block comment line gcr", B({ o .. " note " .. c }), "u", B({ "note" }), sel(1))
  end

  -- 3. mixed on one line
  -- A strict bol_only marker (dockerfile) can never trail on the same row as code, so this generic
  -- "code + trailing comment" case doesn't apply; see the language's own hand-written cases instead.
  local trailing_ok = not L.bol_only or L.bol_heuristic
  if L.lm and trailing_ok then
    local m = L.lm
    both(ft, "3 code + trailing line comment", B({ C .. " " .. m .. " note" }), B({ m .. " " .. C .. " note" }),
      B({ C .. " note" }), sel(1))
  elseif not L.lm then
    local o, c = L.wrap[1], L.wrap[2]
    both(ft, "3 code + trailing comment", B({ C .. " " .. o .. " note " .. c }), B({ o .. " " .. C .. " note " .. c }),
      B({ C .. " note" }), sel(1))
  end
  if L.block and L.lm then
    local o, c = L.block[1], L.block[2]
    both(ft, "3 code + trailing block comment", B({ C .. " " .. o .. " note " .. c }), B({ L.lm .. " " .. C .. " note" }),
      B({ C .. " note" }), sel(1))
  end

  -- 4. multi-line code
  add(ft, "4 multi code, relative indent kept", B({ "  " .. C, "      " .. C2 }), "c",
    B({ com(C, "  "), com("    " .. C2, "  ") }), selrt(2))
  add(ft, "4 multi code gcr no-op", B({ "  " .. C, "      " .. C2 }), "u", B({ "  " .. C, "      " .. C2 }), sel(2))
  add(ft, "4 blank row skipped", B({ C, "", C2 }), "c", B({ com(C), "", com(C2) }), selrt(3))
  add(ft, "4 marker at min indent (deeper first)", B({ "    " .. C, "  " .. C2 }), "c",
    B({ com("  " .. C, "  "), com(C2, "  ") }), selrt(2))

  -- 5. multi-line only comments
  add(ft, "5 multi comment gcs no-op", B({ com("a"), com("b") }), "c", B({ com("a"), com("b") }), sel(2))
  add(ft, "5 multi comment gcr", B({ com("a"), com("  b") }), "u", B({ "a", "  b" }), sel(2))
  if L.lm then
    local m = L.lm
    add(ft, "5 multi comment redundant cleaned", B({ m .. " " .. m .. " a", m .. " b" }), "c", B({ m .. " a", m .. " b" }),
      sel(2))
  end

  -- 6. mixed multi-line
  both(ft, "6 comment row + code row", B({ com("a"), C }), B({ com("a"), com(C) }), B({ "a", C }), sel(2))
  if L.lm and trailing_ok then
    local m = L.lm
    both(ft, "6 code with trailing comment + comment + code", B({ C .. " " .. m .. " x", m .. " y", C2 }),
      B({ m .. " " .. C .. " x", m .. " y", m .. " " .. C2 }), B({ C .. " x", "y", C2 }), sel(3))
  end
  if L.block and L.lm then
    local o, c, m = L.block[1], L.block[2], L.lm
    both(ft, "6 multi-line block comment + code", B({ o .. " a", "b " .. c, C }), B({ m .. " a", m .. " b", m .. " " .. C }),
      B({ "a", "b", C }), sel(3))
    add(ft, "6 delimiter-only rows deleted on gcr", B({ o, "a", "b", c, C }), "u", B({ "a", "b", C }), sel(4))
    add(ft, "6 gcr middle of block closes above", B({ o .. " a", "   b", "   c " .. c, C }), "u",
      B({ o .. " a " .. c, "   b", "   c", C }), { s = P + 2, e = P + 3 })
    add(ft, "6 gcr top of block reopens below", B({ o .. " a", "   b", "   c " .. c, C }), "u",
      B({ "a", "   b", "   " .. o .. " c " .. c, C }), { s = P + 1, e = P + 2 })
  end
  if L.wrap then
    local o, c = L.wrap[1], L.wrap[2]
    add(ft, "6 delimiter-only rows deleted on gcr", B({ o, "a", "b", c, C }), "u", B({ "a", "b", C }), sel(4))
    add(ft, "6 gcr middle of block closes above", B({ o .. " a", "   b", "   c " .. c, C }), "u",
      B({ o .. " a " .. c, "   b", "   c", C }), { s = P + 2, e = P + 3 })
  end
end

--------------------------------------------------------------------------------------------------
-- Language-specific edge cases
--------------------------------------------------------------------------------------------------
-- C family
both("c", "spec example mixed", { "int a = 1; // set a" }, { "// int a = 1; set a" }, { "int a = 1; set a" })
both("c", "inline block both sides", { "a /* b */ c" }, { "// a b c" }, { "a b c" })
add("c", "`// a // b`", { "// a // b" }, "c", { "// a b" })
add("c", "`// // a`", { "// // a" }, "c", { "// a" })
add("c", "`// end */` stray closer", { "// end */" }, "c", { "// end" })
add("c", "`// end */` gcr", { "// end */" }, "u", { "end" })
add("c", "url in comment untouched", { "// see http://x" }, "c", { "// see http://x" })
-- (gcr output contains `//x`, which is a real comment in code, so gcr is not idempotent here)
add("c", "url in comment gcr", { "// see http://x" }, "u", { "see http://x" }, { noidem = true })
both("c", "url in string", { 'printf("http://x");' }, { '// printf("http://x");' }, { 'printf("http://x");' })
both("c", "block opener in string", { 's = "/* no */";' }, { '// s = "/* no */";' }, { 's = "/* no */";' })
both("c", "#include is code", { "#include <stdio.h>" }, { "// #include <stdio.h>" }, { "#include <stdio.h>" })
both("c", "#define is code", { "#define X 1" }, { "// #define X 1" }, { "#define X 1" })
add("c", "char literal slash", { "c = '/'; // c" }, "u", { "c = '/'; c" })
both("c", "stray closer in code", { "x(); */" }, { "// x();" }, { "x();" })
both("c", "two block comments", { "/* a */ /* b */ x();" }, { "// a b x();" }, { "a b x();" })
add("c", "tab indentation kept", { "\tif (x) {", "\t\ty();" }, "c", { "\t// if (x) {", "\t// \ty();" }, { rt = true })
add("c", "spec alignment example", { "  if (x) {", "      y();" }, "c", { "  // if (x) {", "  //     y();" }, { rt = true })
add("c", "mixed multi", { "int a; // x", "// y", "b();" }, "c", { "// int a; x", "// y", "// b();" })
add("c", "gcr on middle rows, delimiters alone outside", { "/*", "a", "b", "*/" }, "u", { "a", "b" }, { s = 2, e = 3 })
-- (ruling: `/* b` + `*/` is accepted, not `/* b */`)
add("c", "gcr top rows, delimiter-only opener", { "/*", "a", "b", "*/" }, "u", { "a", "/* b", "*/" }, { s = 1, e = 2 })
add("c", "javadoc gcr", { "  /**", "   * Hello", "   * world", "   */", "  void f();" }, "u",
  { "  Hello", "  world", "  void f();" }, { s = 1, e = 4 })
add("c", "multi-line block only gcs no-op", { "/* a", "b */" }, "c", { "/* a", "b */" })
add("c", "gcs from inside block closes it above", { "/* a", "b", "c */", "x();" }, "c",
  { "/* a", "b */", "// c", "// x();" }, { s = 3, e = 4 })
add("c", "gcs twice with block", { "x(); /* a */", "y();" }, "c", { "// x(); a", "// y();" })
add("c", "gcr bottom rows reopen/close", { "/* a", "b", "c */" }, "u", { "/* a */", "b", "c" }, { s = 2, e = 3 })

both("cpp", "raw string", { 'auto s = R"(// x)";' }, { '// auto s = R"(// x)";' }, { 'auto s = R"(// x)";' })
both("cpp", "raw string with delimiter", { 'auto s = R"d()" // x)d";' }, { '// auto s = R"d()" // x)d";' },
  { 'auto s = R"d()" // x)d";' })
add("cpp", "raw string then real comment", { 'auto s = R"(// x)"; // y' }, "u", { 'auto s = R"(// x)"; y' })

add("java", "single block comment gcs no-op", { "/* note */" }, "c", { "/* note */" })
add("java", "javadoc gcr", { "  /**", "   * Hello", "   * world", "   */", "  void f();" }, "u",
  { "  Hello", "  world", "  void f();" }, { s = 1, e = 4 })
both("java", "string with marker", { 'String s = "// no";' }, { '// String s = "// no";' }, { 'String s = "// no";' })
add("java", "text block", { 's = """', "  // not", '  """;' }, "u", { 's = """', "  // not", '  """;' }, { s = 2, e = 2 })

both("rust", "raw string", { 'let s = r#"// x"#;' }, { '// let s = r#"// x"#;' }, { 'let s = r#"// x"#;' })
add("rust", "nested block gcr", { "/* a /* b */ c */" }, "u", { "a b c" })
add("rust", "nested block after code gcs", { "x(); /* a /* b */ c */" }, "c", { "// x(); a b c" })
both("rust", "attribute is code", { "#[derive(Debug)]" }, { "// #[derive(Debug)]" }, { "#[derive(Debug)]" })
add("rust", "doc comment gcr", { "/// doc" }, "u", { "doc" })
add("rust", "inner doc gcr", { "//! doc" }, "u", { "doc" })
add("rust", "lifetime is not a char", { "fn f<'a>(x: &'a str) {} // c" }, "u", { "fn f<'a>(x: &'a str) {} c" })

both("javascript", "template literal", { "let s = `// x ${y}`;" }, { "// let s = `// x ${y}`;" }, { "let s = `// x ${y}`;" })
both("javascript", "regex with slashes", { "let r = /a\\/\\/b/;" }, { "// let r = /a\\/\\/b/;" }, { "let r = /a\\/\\/b/;" })
add("javascript", "division then comment", { "a = b / c; // d" }, "u", { "a = b / c; d" })
both("javascript", "single-quote string", { "s = '// no';" }, { "// s = '// no';" }, { "s = '// no';" })
add("javascript", "multi-line template", { "s = `", "// not", "`;" }, "u", { "s = `", "// not", "`;" }, { s = 2, e = 2 })
add("javascript", "shebang untouched", { "#!/usr/bin/env node", "x();" }, "c", { "#!/usr/bin/env node", "// x();" })
both("typescript", "string with marker", { 'let s: string = "// no";' }, { '// let s: string = "// no";' },
  { 'let s: string = "// no";' })

both("go", "backtick raw string", { "s := `// x`" }, { "// s := `// x`" }, { "s := `// x`" })
add("go", "multi-line raw string", { "s := `", "// not", "`" }, "u", { "s := `", "// not", "`" }, { s = 2, e = 2 })

add("cs", "verbatim string backslash", { 'var s = @"c:\\"; // yes' }, "u", { 'var s = @"c:\\"; yes' })
both("cs", "verbatim string marker", { 'var s = @"// no";' }, { '// var s = @"// no";' }, { 'var s = @"// no";' })
both("cs", "#define is code", { "#define DEBUG" }, { "// #define DEBUG" }, { "#define DEBUG" })

-- Lua
both("lua", "long string with marker", { "local s = [[ -- ]]" }, { "-- local s = [[ -- ]]" }, { "local s = [[ -- ]]" })
both("lua", "string with marker", { 'local s = "-- no"' }, { '-- local s = "-- no"' }, { 'local s = "-- no"' })
add("lua", "level-2 long comment gcr", { "--[==[ a ]==]" }, "u", { "a" })
add("lua", "multi-line --[[ --]] gcr", { "--[[", "a", "--]]" }, "u", { "a" })
add("lua", "multi-line --[==[ ]==] gcr", { "--[==[", "a ]] b", "]==]" }, "u", { "a ]] b" })
add("lua", "single long comment gcs no-op", { "--[[ a ]]" }, "c", { "--[[ a ]]" })
both("lua", "trailing comment", { "x = 1 -- c" }, { "-- x = 1 c" }, { "x = 1 c" })
add("lua", "gcr middle of long comment", { "--[[ a", "   b", "   c ]]", "x()" }, "u",
  { "--[[ a ]]", "   b", "   c", "x()" }, { s = 2, e = 3 })
add("lua", "multi-line long string not a comment", { "s = [[", "-- not", "]]" }, "u", { "s = [[", "-- not", "]]" },
  { s = 2, e = 2 })

-- Python
both("python", "string with #", { "s = '# no'" }, { "# s = '# no'" }, { "s = '# no'" })
both("python", "trailing comment", { "x = 1 # c" }, { "# x = 1 c" }, { "x = 1 c" })
add("python", "issue #12 kept", { "# issue #12" }, "c", { "# issue #12" })
add("python", "issue #12 gcr", { "# issue #12" }, "u", { "issue #12" }, { noidem = true })
add("python", "# a # b", { "# a # b" }, "c", { "# a b" })
add("python", "shebang untouched gcs", { "#!/usr/bin/env python3", "x = 1" }, "c", { "#!/usr/bin/env python3", "# x = 1" })
add("python", "shebang untouched gcr", { "#!/usr/bin/env python3", "x = 1" }, "u", { "#!/usr/bin/env python3", "x = 1" },
  { s = 1, e = 1 })
add("python", "# inside triple-quoted string", { 's = """', "# not", '"""' }, "u", { 's = """', "# not", '"""' },
  { s = 2, e = 2 })
both("python", "f-string", { 'f"{x}#no"' }, { '# f"{x}#no"' }, { 'f"{x}#no"' })

-- sh / bash
for _, ft in ipairs({ "sh", "bash" }) do
  both(ft, "$# is not a comment", { "echo $#" }, { "# echo $#" }, { "echo $#" })
  both(ft, "${#a} is not a comment", { "echo ${#a}" }, { "# echo ${#a}" }, { "echo ${#a}" })
  both(ft, "a#b is not a comment", { "echo a#b" }, { "# echo a#b" }, { "echo a#b" })
  add(ft, "a #b is a comment", { "echo a #b" }, "u", { "echo a b" })
  both(ft, "string with #", { 'echo "# no"' }, { '# echo "# no"' }, { 'echo "# no"' })
  both(ft, "single-quote string with #", { "echo '# no'" }, { "# echo '# no'" }, { "echo '# no'" })
  add(ft, "shebang untouched", { "#!/bin/sh", "x=1" }, "c", { "#!/bin/sh", "# x=1" })
  add(ft, "heredoc body not a comment", { "cat <<EOF", "# not", "EOF" }, "u", { "cat <<EOF", "# not", "EOF" },
    { s = 2, e = 2 })
  add(ft, "shebang untouched gcr", { "#!/bin/sh", "# x=1" }, "u", { "#!/bin/sh", "x=1" })
end

-- YAML / TOML
both("yaml", "a#b is not a comment", { "a: b#c" }, { "# a: b#c" }, { "a: b#c" })
both("yaml", "trailing comment", { "a: b # c" }, { "# a: b c" }, { "a: b c" })
both("yaml", "quoted #", { 'a: "# no"' }, { '# a: "# no"' }, { 'a: "# no"' })
both("toml", "quoted #", { 'a = "# no"' }, { '# a = "# no"' }, { 'a = "# no"' })
both("toml", "trailing comment", { "a = 1 # c" }, { "# a = 1 c" }, { "a = 1 c" })

-- TeX
both("tex", "escaped percent", { "50\\% done" }, { "% 50\\% done" }, { "50\\% done" })
both("tex", "trailing comment", { "a % b" }, { "% a b" }, { "a b" })
add("tex", "escaped then real comment", { "5\\% % c" }, "u", { "5\\% c" })

-- Vim
add("vim", "comment gcr", { '" hello' }, "u", { "hello" })
both("vim", "string is not a comment", { 'let s = "x"' }, { '" let s = "x"' }, { 'let s = "x"' })
add("vim", "indented comment gcr", { '  " a' }, "u", { "  a" })

-- Ruby
add("ruby", "=begin/=end gcr", { "=begin", "a", "=end", "x = 1" }, "u", { "a", "x = 1" }, { s = 1, e = 3 })
both("ruby", "interpolation #{} not a comment", { 's = "#{x}"' }, { '# s = "#{x}"' }, { 's = "#{x}"' })
both("ruby", "trailing comment", { "x = 1 # c" }, { "# x = 1 c" }, { "x = 1 c" })
both("ruby", "single-quote string", { "puts '# no'" }, { "# puts '# no'" }, { "puts '# no'" })

-- Nix
both("nix", "indented string", { "s = ''a # b'';" }, { "# s = ''a # b'';" }, { "s = ''a # b'';" })
both("nix", "trailing comment", { "x = 1; # c" }, { "# x = 1; c" }, { "x = 1; c" })
add("nix", "block then code gcr", { "/* a */ x" }, "u", { "a x" })
add("nix", "multi-line indented string", { "s = ''", "  # not", "'';" }, "u", { "s = ''", "  # not", "'';" },
  { s = 2, e = 2 })

-- SQL
both("sql", "doubled quote string", { "SELECT 'it''s -- x';" }, { "-- SELECT 'it''s -- x';" }, { "SELECT 'it''s -- x';" })
both("sql", "trailing comment", { "SELECT 1; -- c" }, { "-- SELECT 1; c" }, { "SELECT 1; c" })

-- PHP
both("php", "#[Attr] is code", { "<?php", "#[Attr]" }, { "<?php", "// #[Attr]" }, { "<?php", "#[Attr]" }, { s = 2, e = 2 })
add("php", "# comment gcr", { "<?php", "$x = 1; # c" }, "u", { "<?php", "$x = 1; c" }, { s = 2, e = 2 })
add("php", "# comment gcs", { "<?php", "$x = 1; # c" }, "c", { "<?php", "// $x = 1; c" }, { s = 2, e = 2 })
both("php", "string with //", { "<?php", '$s = "// no";' }, { "<?php", '// $s = "// no";' }, { "<?php", '$s = "// no";' },
  { s = 2, e = 2 })

-- HTML
both("html", "code + comment", { "<p>a</p> <!-- c -->" }, { "<!-- <p>a</p> c -->" }, { "<p>a</p> c" })
add("html", "comment gcs no-op", { "<!-- a -->" }, "c", { "<!-- a -->" })
add("html", "multi-line comment gcr", { "<!--", "a", "-->" }, "u", { "a" })
add("html", "<script> rows use //", { "<script>", "  let x = 1;", "</script>" }, "c",
  { "<script>", "  // let x = 1;", "</script>" }, { s = 2, e = 2, rt = true })
add("html", "<script> gcr", { "<script>", "  // let x = 1;", "</script>" }, "u",
  { "<script>", "  let x = 1;", "</script>" }, { s = 2, e = 2 })
add("html", "<style> rows use /* */", { "<style>", "  p { color: red; }", "</style>" }, "c",
  { "<style>", "  /* p { color: red; } */", "</style>" }, { s = 2, e = 2, rt = true })
add("html", "<script> string not a comment", { "<script>", '  s = "<!-- x -->";', "</script>" }, "u",
  { "<script>", '  s = "<!-- x -->";', "</script>" }, { s = 2, e = 2 })

-- CSS / XML
both("css", "code + trailing comment", { "a { } /* c */" }, { "/* a { } c */" }, { "a { } c" })
both("css", "string with //", { 'a::after { content: "//"; }' }, { '/* a::after { content: "//"; } */' },
  { 'a::after { content: "//"; }' })
add("css", "gcr middle of block", { "/* a", "   b", "   c */", "p {}" }, "u", { "/* a */", "   b", "   c", "p {}" },
  { s = 2, e = 3 })
both("xml", "code + comment", { "<a/> <!-- c -->" }, { "<!-- <a/> c -->" }, { "<a/> c" })

-- Markdown
both("markdown", "heading is not a comment", { "# Heading" }, { "<!-- # Heading -->" }, { "# Heading" })
add("markdown", "html comment gcr", { "<!-- a -->" }, "u", { "a" })
add("markdown", "python fence uses #", { "```python", "x = 1", "```" }, "c", { "```python", "# x = 1", "```" },
  { s = 2, e = 2, rt = true })
add("markdown", "lua fence uses --", { "```lua", "x = 1", "```" }, "c", { "```lua", "-- x = 1", "```" },
  { s = 2, e = 2, rt = true })
add("markdown", "c fence gcr", { "```c", "int x; // y", "```" }, "u", { "```c", "int x; y", "```" }, { s = 2, e = 2 })

-- gcs with code in the selection: delimiter-only rows are DELETED (ruling), like gcr
add("java", "gcs deletes delimiter-only rows", { "/*", "a", "*/", "x();" }, "c", { "// a", "// x();" })
add("java", "gcs deletes javadoc delimiter rows", { "/**", " * a", " */", "x();" }, "c", { "// a", "// x();" })
add("java", "gcs deletes delimiter rows (code first)", { "x();", "/*", "a", "*/" }, "c", { "// x();", "// a" })
add("lua", "gcs deletes --[[ ]] rows", { "--[[", "a", "]]", "x()" }, "c", { "-- a", "-- x()" })
add("lua", "gcs deletes --[[ --]] rows", { "--[[", "a", "--]]", "x()" }, "c", { "-- a", "-- x()" })
add("nix", "gcs deletes delimiter-only rows", { "/*", "a", "*/", "x = 1;" }, "c", { "# a", "# x = 1;" })
add("html", "gcs deletes <!-- --> rows", { "<!--", "a", "-->", "<p>b</p>" }, "c", { "<!-- a -->", "<!-- <p>b</p> -->" })
add("css", "gcs deletes /* */ rows", { "/*", "a", "*/", "p {}" }, "c", { "/* a */", "/* p {} */" })

-- a selection that is entirely one block comment is a gcs no-op (rule 5 wins over the deletion ruling)
add("java", "gcs on whole block comment is no-op", { "/*", "a();", "*/" }, "c", { "/*", "a();", "*/" })
add("c", "gcs on whole block comment is no-op", { "/*", "a();", "*/" }, "c", { "/*", "a();", "*/" })

--------------------------------------------------------------------------------------------------
-- New-language edge cases (typst, lisp, haskell, kotlin, swift, scala, r, julia, ps1, perl, zig,
-- asm, fish, make, dockerfile)
--------------------------------------------------------------------------------------------------
both("typst", "nested block", { "/* a /* b */ c */ d()" }, { "// a b c d()" }, { "a b c d()" })

add("lisp", "char literal not a comment start", { "(f ?\\; x) ; c" }, "u", { "(f ?\\; x) c" })
add("lisp", "predicate name with ? untouched", { "(foo? x) ; c" }, "u", { "(foo? x) c" })
both("lisp", "double semicolon convention", { ";; a" }, { ";; a" }, { "a" })

-- "--" only starts a comment when not immediately followed by another symbol char (else it's an
-- operator like "-->"); a pragma "{-# ... #-}" is opaque code, not a strippable comment.
add("haskell", "arrow operator is not a comment", { "f x --> y" }, "c", { "-- f x --> y" })
add("haskell", "pragma is code", { "{-# LANGUAGE OverloadedStrings #-}" }, "c",
  { "-- {-# LANGUAGE OverloadedStrings #-}" })
add("haskell", "nested block comment", { "{- a {- b -} c -} d" }, "c", { "-- a b c d" })

both("kotlin", "nested block comment", { "/* a /* b */ c */ d()" }, { "// a b c d()" }, { "a b c d()" })
add("kotlin", "triple-quote string not a comment", { 'val s = """// no"""' }, "u", { 'val s = """// no"""' })

add("swift", "extended raw string not a comment", { 'let s = #"// no"#' }, "u", { 'let s = #"// no"#' })
add("swift", "doc comment marker", { "/// doc" }, "u", { "doc" })
both("swift", "nested block comment", { "/* a /* b */ c */ d()" }, { "// a b c d()" }, { "a b c d()" })

add("scala", "triple-quote interpolated string not a comment",
  { 'val s = s"""// no ${1}"""' }, "u", { 'val s = s"""// no ${1}"""' })
both("scala", "nested block comment", { "/* a /* b */ c */ d()" }, { "// a b c d()" }, { "a b c d()" })

add("r", "raw string not a comment", { 'x <- r"(# no)"' }, "u", { 'x <- r"(# no)"' })
both("r", "roxygen prefix stays as-is", { "#' a" }, { "#' a" }, { "' a" })

add("julia", "nested block comment", { "#= a #= b =# c =#" }, "c", { "#= a b c =#" }, { s = 1, e = 1 })
add("julia", "raw string not a comment", { 'x = raw"# no"' }, "u", { 'x = raw"# no"' })
add("julia", "backtick command literal not a comment", { "x = `echo # no`" }, "u", { "x = `echo # no`" })

-- non-nesting: the FIRST "#>" closes the block, so "c" after it is real code, not comment; the
-- spurious inner "<#" (unterminated within the comment body) is cleaned up like a redundant marker
add("ps1", "block comment does not nest", { "<# a <# b #> c" }, "u", { "a b c" })
add("ps1", "double-quote backtick escape", { 'Write-Host "a `" b" # c' }, "u", { 'Write-Host "a `" b" c' })

add("perl", "delimited q() not a comment", { "my $s = q(# no);" }, "u", { "my $s = q(# no);" })
add("perl", "regex m// not a comment", { "if ($x =~ m/#/) { }" }, "u", { "if ($x =~ m/#/) { }" })
add("perl", "substitution s/// not a comment", { "$x =~ s/#/x/;" }, "u", { "$x =~ s/#/x/;" })

add("zig", "doc comment markers", { "/// doc", "//! module doc" }, "u", { "doc", "module doc" })

-- Neovim's single "asm" filetype recognizes both NASM ";" and GAS "#"; gcs prefers ";".
add("asm", "GAS style comment recognized", { "mov eax, 1 # c" }, "u", { "mov eax, 1 c" })
both("asm", "code becomes NASM style", { "mov eax, 1" }, { "; mov eax, 1" }, { "mov eax, 1" })

both("fish", "code + trailing comment", { "set -x X 1 # c" }, { "# set -x X 1 c" }, { "set -x X 1 c" })

-- "#" comments almost everywhere in Make, including recipe lines, unless escaped as "\#".
add("make", "recipe line comment", { "all:", "\techo hi # c" }, "u", { "all:", "\techo hi c" }, { s = 2, e = 2 })
add("make", "escaped hash is literal", { "x = a \\# b" }, "u", { "x = a \\# b" })

-- "#" is only a Dockerfile comment as the first non-blank char of the line.
add("dockerfile", "# after instruction is not a comment", { "RUN echo hi # not a comment" }, "u",
  { "RUN echo hi # not a comment" })
add("dockerfile", "leading # is a comment", { "# real comment", "FROM alpine" }, "u",
  { "real comment", "FROM alpine" }, { s = 1, e = 1 })

--------------------------------------------------------------------------------------------------
-- Partial block selections: boundary repair (close above / reopen below / both), gcr and gcs
--------------------------------------------------------------------------------------------------
-- o/c: block delimiters; x/y: code rows; lm: gcs line marker (nil = wrap each row in o .. c)
local boundary = {
  { "java", o = "/*", c = "*/", x = "x();", y = "y();", lm = "//" },
  { "c", o = "/*", c = "*/", x = "x();", y = "y();", lm = "//" },
  { "rust", o = "/*", c = "*/", x = "x();", y = "y();", lm = "//" },
  { "lua", o = "--[[", c = "]]", x = "x()", y = "y()", lm = "--" },
  { "lua", o = "--[==[", c = "]==]", x = "x()", y = "y()", lm = "--", tag = " (level 2)" },
  { "nix", o = "/*", c = "*/", x = "x = 1;", y = "y = 2;", lm = "#" },
  { "css", o = "/*", c = "*/", x = "p {}", y = "q {}" },
  { "html", o = "<!--", c = "-->", x = "<p>x</p>", y = "<p>y</p>" },
}
for _, b in ipairs(boundary) do
  local ft, o, c, x, y = b[1], b.o, b.c, b.x, b.y
  local t = b.tag or ""
  local function M(text)
    return b.lm and (b.lm .. " " .. text) or (o .. " " .. text .. " " .. c)
  end
  local sel = function(s, e) return { s = s, e = e } end

  -- gcr
  add(ft, "boundary gcr END closes above" .. t, { o .. " a", "b", "c " .. c, x }, "u",
    { o .. " a " .. c, "b", "c", x }, sel(2, 3))
  add(ft, "boundary gcr START reopens below" .. t, { o .. " a", "b", "c " .. c, x }, "u",
    { "a", "b", o .. " c " .. c, x }, sel(1, 2))
  add(ft, "boundary gcr START, closer on own row" .. t, { o .. " a", "b", "c", c }, "u",
    { "a", "b", o .. " c", c }, sel(1, 2))
  add(ft, "boundary gcr MIDDLE closes and reopens" .. t, { o .. " a", "b", "c", "d", "e " .. c }, "u",
    { o .. " a", "b " .. c, "c", o .. " d", "e " .. c }, sel(3, 3))
  add(ft, "boundary gcr MIDDLE two rows" .. t, { o .. " a", "b", "c", "d", "e " .. c }, "u",
    { o .. " a " .. c, "b", "c", o .. " d", "e " .. c }, sel(2, 3))
  add(ft, "boundary gcr remnant opener removed" .. t, { o, "a", "b " .. c }, "u", { "a", "b" }, sel(2, 3))
  add(ft, "boundary gcr remnant closer removed" .. t, { o .. " a", "b", c }, "u", { "a", "b" }, sel(1, 2))
  add(ft, "boundary gcr remnants both sides removed" .. t, { o, "a", c }, "u", { "a" }, sel(2, 2))
  add(ft, "boundary gcr middle, remnant above only" .. t, { o, "a", "b", "c " .. c }, "u",
    { "a", o .. " b", "c " .. c }, sel(2, 2))

  -- gcs with a code row in the selection
  add(ft, "boundary gcs END + code closes above" .. t, { o .. " a", "b", "c " .. c, x }, "c",
    { o .. " a", "b " .. c, M("c"), M(x) }, sel(3, 4))
  add(ft, "boundary gcs code + START reopens below" .. t, { x, o .. " a", "b", "c " .. c }, "c",
    { M(x), M("a"), o .. " b", "c " .. c }, sel(1, 2))
  add(ft, "boundary gcs remnant opener removed" .. t, { o, "a", "b " .. c, x }, "c", { M("a"), M("b"), M(x) }, sel(2, 4))
  add(ft, "boundary gcs remnant closer removed" .. t, { x, o .. " a", "b", c }, "c", { M(x), M("a"), M("b") }, sel(1, 3))
  -- code sharing a row with the block delimiter
  add(ft, "boundary gcs code+opener row reopens below" .. t, { x .. " " .. o .. " a", "b " .. c, y }, "c",
    { M(x .. " a"), o .. " b " .. c, y }, sel(1, 1))
  add(ft, "boundary gcs closer+code row closes above" .. t, { o .. " a", "b " .. c .. " " .. y }, "c",
    { o .. " a " .. c, M("b " .. y) }, sel(2, 2))
end

-- Rust nested blocks: depth is kept when repairing boundaries
add("rust", "boundary gcr END of nested block", { "/* a /* n */", "b", "c */", "x();" }, "u",
  { "/* a /* n */ */", "b", "c", "x();" }, { s = 2, e = 3 })
add("rust", "boundary gcr START of nested block", { "/* a", "/* n */ b", "c */", "x();" }, "u",
  { "a", "n b", "/* c */", "x();" }, { s = 1, e = 2 })

M.cases = cases
return M
