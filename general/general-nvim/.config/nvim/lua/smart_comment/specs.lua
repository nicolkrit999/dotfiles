-- Per-language comment syntax used by the smart_comment lexer.
--
-- Fields:
--   line          line-comment markers; line[1] is the one gcs inserts
--   line_extra    pattern of chars that may repeat right after a line marker (doc variants: ///, //!, ---, ##)
--   block         block comments { open, close, nest?, decor?, bol?, extra? }; block[1] is used by gcs when there
--                 is no line marker. extra is a pattern of decoration chars swallowed right after the opener
--                 (analogous to line_extra), e.g. the extra `*` in `/**` or the `!` in Rust's `/*!`
--   strings       string literals { open, close, esc?, dbl?, ml?, nix?, not_after_word? }
--   specials      extra tokenizers, see lexer.lua (lua_long, rust_raw, rust_char, cpp_raw, heredoc_sh, ...)
--   line_boundary char class that must precede a line marker (sh: `a#b` is not a comment)
--   bol_only      line marker only counts as the first non-blank char; on the outer buffer scan (not the
--                 inner scan clean_body uses to drop redundant markers) it also counts elsewhere on the line
--                 when preceded by whitespace with no later occurrence to close it as a string (vimscript
--                 fallback: a bare `"` mid-line is a trailing comment, but one buried in comment text isn't
--                 a redundant marker worth stripping)
--   escape_char   a marker preceded by an odd number of these is escaped (tex `\%`)
--   not_followed  { [marker] = pattern } that must not follow the marker (php `#[` is an attribute)
--   line_end      tokens that terminate a line comment early (php `?>`)
--   line_splice   a trailing `\` continues a line comment on the next line (C)
--   close_prefix  pattern removed together with a block closer (lua `--]]`)
--   stray_close   remove unmatched block closers found in code
--   shebang       protect a `#!` first line ("rust": not when followed by `[`)
--   regions       embedded languages (html <script>/<style>, markdown fences)
--   backend       "lexer" to never use tree-sitter for this language
local M = {}

local c_strings = {
  { '"', '"', esc = "\\" },
  { "'", "'", esc = "\\" },
}

local specs = {}

specs.c = {
  line = { "//" },
  line_extra = "[/!]*",
  block = { { "/*", "*/", decor = "*", extra = "%**" } },
  strings = c_strings,
  line_splice = true,
  stray_close = true,
}

specs.cpp = {
  inherits = "c",
  strings = { { '"', '"', esc = "\\" }, { "'", "'", esc = "\\", not_after_word = true } },
  specials = { "cpp_raw" },
}

specs.java = {
  inherits = "c",
  line_splice = false,
  strings = { { '"""', '"""', esc = "\\", ml = true }, { '"', '"', esc = "\\" }, { "'", "'", esc = "\\" } },
}

specs.cs = {
  inherits = "c",
  line_splice = false,
  strings = {
    { '"""', '"""', ml = true },
    { '@"', '"', dbl = true, ml = true },
    { '"', '"', esc = "\\" },
    { "'", "'", esc = "\\" },
  },
}

specs.javascript = {
  inherits = "c",
  line_splice = false,
  strings = { { '"', '"', esc = "\\" }, { "'", "'", esc = "\\" }, { "`", "`", esc = "\\", ml = true } },
  specials = { "regex" },
  shebang = true,
}
specs.typescript = { inherits = "javascript" }

specs.go = {
  inherits = "c",
  line_splice = false,
  strings = { { '"', '"', esc = "\\" }, { "`", "`", ml = true }, { "'", "'", esc = "\\" } },
}

specs.rust = {
  inherits = "c",
  line_splice = false,
  block = { { "/*", "*/", nest = true, decor = "*", extra = "[*!]*" } },
  strings = { { '"', '"', esc = "\\", ml = true } },
  specials = { "rust_raw", "rust_char" },
  shebang = "rust",
}

specs.php = {
  inherits = "c",
  line_splice = false,
  line = { "//", "#" },
  line_extra = "[/#]*",
  not_followed = { ["#"] = "^%[" },
  line_end = { "?>" },
  strings = { { '"', '"', esc = "\\", ml = true }, { "'", "'", esc = "\\", ml = true }, { "`", "`", esc = "\\", ml = true } },
  specials = { "heredoc_php" },
}

specs.css = {
  block = { { "/*", "*/", decor = "*" } },
  strings = c_strings,
  stray_close = true,
}

specs.python = {
  line = { "#" },
  line_extra = "#*",
  strings = {
    { '"""', '"""', esc = "\\", ml = true },
    { "'''", "'''", esc = "\\", ml = true },
    { '"', '"', esc = "\\" },
    { "'", "'", esc = "\\" },
  },
  shebang = true,
}

specs.ruby = {
  line = { "#" },
  line_extra = "#*",
  block = { { "=begin", "=end", bol = true } },
  strings = { { '"', '"', esc = "\\", ml = true }, { "'", "'", esc = "\\", ml = true }, { "`", "`", esc = "\\", ml = true } },
  specials = { "heredoc_ruby", "ruby_percent", "ruby_char", "regex" },
  shebang = true,
}

specs.sh = {
  line = { "#" },
  line_extra = "#*",
  line_boundary = "[%s;|&()]",
  strings = { { "$'", "'", esc = "\\", ml = true }, { '"', '"', esc = "\\", ml = true }, { "'", "'", ml = true }, { "`", "`", esc = "\\", ml = true } },
  specials = { "heredoc_sh" },
  shebang = true,
}
specs.bash = { inherits = "sh" }
specs.zsh = { inherits = "sh" }

specs.lua = {
  line = { "--" },
  line_extra = "%-*",
  strings = { { '"', '"', esc = "\\" }, { "'", "'", esc = "\\" } },
  specials = { "lua_long" },
  close_prefix = "%-%-",
  shebang = true,
}

specs.vim = {
  line = { '"' },
  line_extra = '"*',
  bol_only = true,
  strings = { { "'", "'", dbl = true }, { '"', '"', esc = "\\" } },
}

specs.sql = {
  line = { "--" },
  line_extra = "%-*",
  block = { { "/*", "*/", decor = "*" } },
  strings = {
    -- MySQL executable comments / optimizer hints are code, not comments
    { "/*!", "*/", ml = true },
    { "/*+", "*/", ml = true },
    { "'", "'", dbl = true, ml = true },
    { '"', '"', dbl = true },
    { "`", "`", dbl = true },
  },
  specials = { "pg_dollar" },
  stray_close = true,
}

specs.yaml = {
  line = { "#" },
  line_extra = "#*",
  line_boundary = "%s",
  strings = { { "'", "'", dbl = true }, { '"', '"', esc = "\\" } },
}

specs.toml = {
  line = { "#" },
  line_extra = "#*",
  strings = {
    { '"""', '"""', esc = "\\", ml = true },
    { "'''", "'''", ml = true },
    { '"', '"', esc = "\\" },
    { "'", "'" },
  },
}

specs.tex = {
  line = { "%" },
  line_extra = "%%*",
  escape_char = "\\",
  strings = {
    { "\\begin{verbatim}", "\\end{verbatim}", ml = true },
    { "\\begin{lstlisting}", "\\end{lstlisting}", ml = true },
    { "\\begin{minted}", "\\end{minted}", ml = true },
  },
  specials = { "tex_verb" },
}

specs.nix = {
  line = { "#" },
  line_extra = "#*",
  line_boundary = "[%s;{}()%[%]=:,]",
  block = { { "/*", "*/", decor = "*" } },
  strings = { { "''", "''", nix = true, ml = true }, { '"', '"', esc = "\\", ml = true } },
  stray_close = true,
}

specs.html = {
  block = { { "<!--", "-->" } },
  stray_close = true,
  regions = {
    { open = "<[sS][cC][rR][iI][pP][tT][^>]*>", close = "</[sS][cC][rR][iI][pP][tT]%s*>", lang = "javascript" },
    { open = "<[sS][tT][yY][lL][eE][^>]*>", close = "</[sS][tT][yY][lL][eE]%s*>", lang = "css" },
  },
}

specs.xml = {
  -- lexer-only: tree-sitter-xml misparses a stray extra "<!--" inside an (already invalid, since
  -- real XML comments can't contain "--") comment as a broken tag rather than as comment content,
  -- so it leaves it unchanged instead of cleaning it up. XML has no embedded-language regions like
  -- html's <script>/<style>, so the lexer loses nothing by always handling it.
  backend = "lexer",
  block = { { "<!--", "-->" } },
  strings = { { "<![CDATA[", "]]>", ml = true }, { "<?", "?>", ml = true } },
  stray_close = true,
}

specs.markdown = {
  backend = "lexer",
  block = { { "<!--", "-->" } },
  strings = { { "``", "``" }, { "`", "`" } },
  regions = { { fence = true } },
}

-- tree-sitter language name -> spec key
local ts_alias = {
  c_sharp = "cs",
  latex = "tex",
  tsx = "typescript",
  php_only = "php",
  markdown_inline = "markdown",
}

-- markdown fence info string -> spec key
local fence_alias = {
  js = "javascript",
  jsx = "javascript",
  ts = "typescript",
  tsx = "typescript",
  py = "python",
  python3 = "python",
  shell = "sh",
  console = "sh",
  rb = "ruby",
  rs = "rust",
  yml = "yaml",
  csharp = "cs",
  ["c#"] = "cs",
  ["c++"] = "cpp",
  latex = "tex",
  md = "markdown",
  vimscript = "vim",
  viml = "vim",
  golang = "go",
}

local resolved = {}

local function resolve(key)
  if resolved[key] ~= nil then
    return resolved[key] or nil
  end
  local s = specs[key]
  if not s then
    resolved[key] = false
    return nil
  end
  local out = {}
  if s.inherits then
    for k, v in pairs(resolve(s.inherits)) do
      out[k] = v
    end
  end
  for k, v in pairs(s) do
    out[k] = v
  end
  out.inherits = nil
  out.name = key
  resolved[key] = out
  return out
end

--- Spec for a filetype or tree-sitter language name, or nil.
function M.get(name)
  if not name or name == "" then
    return nil
  end
  return resolve(ts_alias[name] or name)
end

--- Spec for a markdown fence info string; an empty spec (no comments) when unknown.
function M.fence(info)
  info = (info or ""):lower()
  local s = M.get(fence_alias[info] or info)
  if s then
    return s
  end
  local ft = info ~= "" and vim.filetype.match({ filename = "x." .. info }) or nil
  return M.get(ft) or { name = "text" }
end

--- Spec built from 'commentstring' for filetypes without an entry.
function M.from_commentstring(cs)
  if not cs or not cs:find("%%s") then
    return nil
  end
  local left, right = cs:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
  if not left or left == "" then
    return nil
  end
  if right == "" then
    return { name = "commentstring", line = { left } }
  end
  return { name = "commentstring", block = { { left, right } } }
end

--- Spec for a buffer: filetype table, then tree-sitter language, then 'commentstring'.
function M.for_buf(buf)
  local ft = vim.bo[buf].filetype
  local s = M.get(ft)
  if s then
    return s
  end
  local ok, lang = pcall(vim.treesitter.language.get_lang, ft)
  s = ok and M.get(lang) or nil
  return s or M.from_commentstring(vim.bo[buf].commentstring)
end

return M
