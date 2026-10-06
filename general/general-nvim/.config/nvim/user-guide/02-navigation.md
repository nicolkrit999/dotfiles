<!-- chapter: Navigation -->
[Back to the guide index](README.md)

# 3. Core navigation (moving without the mouse)

All navigation happens in **Normal mode**. Press `<Esc>` first if you are in Insert mode.

## Basic cursor movement

| Keymap | Description |
| --- | --- |
| `h` | Move cursor one character **left** |
| `l` | Move cursor one character **right** |
| `j` | Move cursor one line **down** (follows visual/wrapped lines when no count is given) |
| `k` | Move cursor one line **up** (follows visual/wrapped lines when no count is given) |
| `5j` | Move 5 lines down (with a count, moves by actual lines, not wrapped lines) |
| `12k` | Move 12 lines up |
| `3l` | Move 3 characters right (same as pressing `l` three times) |
| `4h` | Move 4 characters left (same as pressing `h` four times) |

**General rule**: a number typed before `h`, `j`, `k` or `l` repeats that key that many times. `Nh` moves N characters left, `Nl` N characters right, `Nj` N lines down, `Nk` N lines up.
- It works the same in Visual mode (`v3l` extends the selection by 3 characters, `V3j` selects the current line plus 3 below) and after an operator (`d3l` deletes 3 characters, `d3j` deletes the current line and the 3 below).
- With relative line numbers on, the number shown next to a line is exactly the `N` to use with `Nj` / `Nk` to reach it.

## Moving within a line

| Keymap | Description |
| --- | --- |
| `H` | Jump to **first non-whitespace character** of the line (custom, mapped to `^`) |
| `L` | Jump to **last non-whitespace character** of the line (custom, mapped to `g_`) |
| `0` | Jump to the **very first column** (column 0) of the line |
| `^` | Jump to **first non-whitespace** character (same as `H` in this config) |
| `$` | Jump to the **end of the line** |
| `g_` | Jump to the last non-blank character of the line |

Where the cursor lands, on the line `    return foo(bar);  ` (4 leading spaces, 2 trailing spaces, cursor on `foo`):

| Keys | Cursor lands on |
| --- | --- |
| `H` (or `^`) | the `r` of `return` (first non-blank) |
| `L` (or `g_`) | the `;` (last non-blank, NOT the trailing spaces) |
| `$` | the last trailing space |
| `0` | column 1 (a leading space) |

With an operator, `dg_` on `foo` deletes up to and including the `;` and leaves `    return   `.

## Moving by word

| Keymap | Description |
| --- | --- |
| `w` | Move **forward** to the start of the next word |
| `b` | Move **backward** to the start of the previous word |
| `e` | Move **forward** to the end of the current/next word |
| `ge` | Move **backward** to the end of the previous word |
| `W` | Move forward to the next WORD (separated by whitespace only, ignores punctuation) |
| `B` | Move backward to the previous WORD |
| `E` | Move forward to the end of the current/next WORD |

**word vs WORD**: A "word" stops at punctuation (e.g., `foo.bar` is 3 words: `foo`, `.`, `bar`). A "WORD" only stops at whitespace (e.g., `foo.bar` is 1 WORD).

Example on `foo.bar baz` with the cursor on the first `f`:

| Keys | Cursor lands on |
| --- | --- |
| `w` | the `.` (the next word is the punctuation) |
| `ww` | the `b` of `bar` |
| `W` | the `b` of `baz` (the whole `foo.bar` is one WORD) |
| `e` | the second `o` of `foo` (end of the word) |
| `E` | the `r` of `bar` (end of the WORD `foo.bar`) |

## Moving by line/screen

| Keymap | Description |
| --- | --- |
| `gg` | Jump to the **first line** of the file |
| `G` | Jump to the **last line** of the file |
| `42G` or `:42` | Jump to **line 42** |
| `<Ctrl-d>` | Scroll **half a screen down** |
| `<Ctrl-u>` | Scroll **half a screen up** |
| `<Ctrl-f>` | Scroll **one full screen down** (forward) |
| `<Ctrl-b>` | Scroll **one full screen up** (backward) |
| `<Ctrl-e>` | Scroll screen down by one line (cursor stays) |
| `<Ctrl-y>` | Scroll screen up by one line (cursor stays) |
| `zz` | Center the current line on screen |
| `zt` | Move current line to the **top** of the screen |
| `zb` | Move current line to the **bottom** of the screen |
| `{` | Jump to the previous **blank line** (previous paragraph) |
| `}` | Jump to the next **blank line** (next paragraph) |
| `(` | Jump to the beginning of the previous sentence |
| `)` | Jump to the beginning of the next sentence |

Where the cursor line ends up on the screen (a window 21 lines high; `scrolloff` is 5 here, so `zt` and `zb` leave 5 lines of context instead of putting the line on the very edge):

```
      zt                 zz                 zb
+--------------+   +--------------+   +--------------+
| 5 lines of   |   |              |   |              |
|  context     |   |              |   |              |
| > cursor <   |   |              |   |              |
|              |   |              |   |              |
|              |   | > cursor <   |   |              |
|              |   |              |   |              |
|              |   |              |   | > cursor <   |
|              |   |              |   |  5 lines of  |
|              |   |              |   |   context    |
+--------------+   +--------------+   +--------------+
 row 6 of 21        row 11 of 21       row 16 of 21
```

## Jumping to matching brackets/parentheses

| Keymap | Description |
| --- | --- |
| `%` | Jump to the **matching bracket/parenthesis/brace**. If your cursor is on `(`, pressing `%` jumps to the matching `)`, and vice versa. Works with `()`, `[]`, `{}`, and also language keywords like `if`/`endif` (via vim-matchup plugin). |

The `matchpairs` option also includes: `<>`, and several CJK bracket pairs.

Examples: on `if (a && (b || c)) {` with the cursor on the first `(`, `%` jumps to the last `)` of the outer pair (the one before ` {`). With an operator, `d%` on `x(a, b)y` with the cursor on the `(` gives `xy`.

## Jumping to specific characters

**Note**: The built-in `f` motion has been replaced by the hop.nvim plugin (see [Jump Navigation section](#22-jump-navigation-hopnvim)). The following built-in motions still work:

| Keymap | Description |
| --- | --- |
| `t<char>` | Jump forward **to just before** the next occurrence of `<char>` on the current line |
| `T<char>` | Jump backward **to just after** the previous occurrence of `<char>` |

`;` is the command key in this config, so it does **not** repeat `t`/`T`. `,` still repeats the last `t`/`T` in the opposite direction.

## Jump navigation with hop.nvim (plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `f` | n, x, o | Press `f`, then type 2 characters. All matches on screen get labeled. Press the label letter to jump there instantly. Case insensitive. Press `<Esc>` to cancel. |

Example (in a real terminal): the visible text is `the first foo and the second foo end` and the cursor is on the `t` of `the`.

```
visible text:         the first foo and the second foo end
press f, type fo ->   the first aoo and the second soo end     (a label replaces the first letter of each match)
press s          ->   the cursor jumps to the second foo
```

The label letters depend on the screen (here `a` and `s`), so read them from the screen. After an operator the jump is the range: `d` + `f` + `fo` + `s` on the same text deletes everything from the cursor up to and including the `f` of the second `foo` and leaves `oo end`; the range is not limited to the line (see the note on `f` after an operator in [the editing chapter](03-editing.md#t-and-t-stop-just-before-a-character)).

## Jump history

| Keymap | Description |
| --- | --- |
| `<Ctrl-o>` | Jump **back** to the previous location in the jump list |
| `<Ctrl-i>` | Jump **forward** to the next location in the jump list |

Every time you use a jump command (like `gg`, `G`, `/search`, `gd`, etc.), your position is saved. You can then go back and forth through your history with these keys.

Example: on line 10 of a 12-line file, press `gg` (line 1), then `G` (last line), then `<Ctrl-o>`: you are back on line 1. `<Ctrl-o>` again: back on line 10, where you started. `<Ctrl-i>`: line 1 again.

## Word references (vim-illuminate)

Other uses of the word under the cursor are highlighted when there are at least 2 (from the LSP server, else from Treesitter). It only runs in these file types: bash, c, cpp, go, java, javascript, json, lua, markdown, nix, python, rust, sh, tex (also plain TeX), toml, typescript, typst, yaml (and the React variants of javascript and typescript). In `.nix` files only the identical word is highlighted (text matching): the nix language server would mark every package of a `with pkgs; [...]` list.

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Alt-n>` | n | Jump to the next reference of the word under the cursor |
| `<Alt-p>` | n | Jump to the previous reference |
| `<Alt-i>` | x, o | Text object: the reference under the cursor (e.g. `d<Alt-i>`) |

Example (`<Alt-n>` in a Lua file): with `local Config = {}` on line 6 and `function Config.get(key)` on line 8, put the cursor on `Config` in line 8 and press `<Alt-n>`: the cursor jumps to the `Config` on line 6. Pressed again it goes back to line 8 (it wraps around at the end). Both `Config` words carry the plugin's highlight (read from its extmarks: `IlluminatedWordWrite` on the line 6 one, `IlluminatedWordRead` on the line 8 one).

These three keys are plugin defaults of vim-illuminate: the plugin sets them only when nothing else uses the key, and the config does not define them itself.

Commands: `:IlluminateToggle`, `:IlluminatePause`, `:IlluminateResume`.

## Marks (bookmarks)

| Keymap | Description |
| --- | --- |
| `ma` | Set mark `a` at current cursor position |
| `` `a `` | Jump to the exact position of mark `a` |
| `'a` | Jump to the line of mark `a` (first non-whitespace) |
| `` `" `` | Jump to position where you last edited the file |
| `` `. `` | Jump to position of last change |
| `:marks` | List all marks |

Marks `a-z` are local to the file. Marks `A-Z` are global (across files).

Example: the file has the lines `a`, `  b c d`, `c`, `d`, `e` and the cursor is on the `c` of line 2 (column 5). Press `ma`, then `5G` (last line). `` `a `` returns to line 2, column 5 (the exact spot); `'a` returns to line 2 but on the first non-blank, the `b` (column 3). Marks also work with an operator: on the lines `a`, `b`, `c` with the cursor on `a`, `ma`, `jj`, then ``d`a`` deletes from the mark to the cursor and leaves `c`.

---

# 22. Jump navigation (`hop.nvim`)

| Keymap | Mode | Description |
| --- | --- | --- |
| `f` | n, x, o | Type `f` then 2 characters: all matches highlight with jump labels. Press the label letter to jump. Case insensitive. `<Esc>` to cancel. |

**Note**: Replaces Vim's built-in `f` motion (`F` is unchanged). `t{char}` jumps forward to just before a character on the current line, `T{char}` backward to just after it. `;` is mapped to `:`, so it does not repeat these motions; use `,` (opposite direction).

---

# 23. Search lens (`nvim-hlslens`)

| Keymap | Description |
| --- | --- |
| `n` | Next match with `[x/y]` count overlay |
| `N` | Previous match with count overlay |
| `*` | Search the word under the cursor forward as a whole word (the cursor stays on the word; with a count, e.g. `3*`, it jumps 3 matches forward from the cursor, like `3n`) |
| `#` | Same, backward |

Example (in a real terminal): after `/count<Enter>` and `n` in a file where `count` appears 4 times, the line with the second match ends with a small virtual text:

```
local count = 0
count = count + 1  [2/4]        <- the match you are on is the 2nd of 4
return count
```

---

# 37. Symbol outline (`aerial.nvim`)

The outline comes from Treesitter or the LSP server (no ctags needed).

| Keymap | Description |
| --- | --- |
| `<Space>t` | Toggle the symbol outline sidebar (functions, classes, methods; the cursor stays in your code) |
| `[t` / `]t` | Previous / next symbol (only in buffers where aerial is active; there they replace Vim's `:tprevious` / `:tnext` keys) |

Commands: `:AerialToggle`, `:AerialOpen`, `:AerialNavToggle`.

What it looks like (in a real terminal, on a Lua file; the sidebar opens on the right and each symbol has a small icon in front of it that depends on the font):

```
 code window                              Outline sidebar
 local M = {}                           |  (icon) M.load
 function M.load(path)                  |  (icon) Config.get
   return path
 end
 local Config = {}
 function Config.get(key)
   ...
```

---

# 50. Code navigation strategies

This section covers how developers typically navigate code in this setup.

## Finding files

| Method | Keymap | Best for |
| --- | --- | --- |
| Fuzzy file search | `<Space>ff` | When you know part of the filename |
| Recent files | `<Space>fr` | Files you've worked on recently |
| File explorer | `<Space>s` | Browsing project structure visually |
| Buffer search | `<Space>fb` | Switching between already-open files |
| Buffer pick | `<Space>bp` | Quick switch when you can see the buffer tab |
| Buffer cycle | `gb` / `gB` | Cycling through open files linearly (`{N}gb` = buffer number N) |

## Finding code

| Method | Keymap | Best for |
| --- | --- | --- |
| Project-wide grep | `<Space>fg` | Searching for a string/pattern across all files |
| Word under cursor | `*` or `#` | Finding all uses of the current word in the file |
| Go to definition | `gd` | Jumping to where something is defined |
| Peek definition | `<Space>gd` | Checking a definition without leaving context |
| Peek references | `<Space>gr` | Seeing everywhere something is used |
| Buffer tags | `<Space>ft` | Jumping to a function/class in the current file (uses ctags) |
| Symbol outline | `<Space>t` | Sidebar (aerial) with all symbols in the file; focus stays in the code |

## Understanding code

| Method | Keymap | What you learn |
| --- | --- | --- |
| Hover docs | `K` | Function signature, parameters, return type, docstring |
| Peek references | `<Space>gr` | How and where this symbol is used |
| Git blame | `<Space>hb` | Who wrote this line, when, and why (commit message) |
| Diagnostics | `<Space>dd` | What's wrong with this line and where the error comes from |
| Code outline | `<Space>t` | The structure of the file (classes, functions, methods) |
| Breadcrumb bar | (automatic) | Current location in the code shown at the top (dropbar) |

## Refactoring code

| Method | Keymap | What it does |
| --- | --- | --- |
| Rename | `<Space>rn` | Rename a symbol across the entire project |
| Code action | `<Space>ca` | Auto-import, extract variable, fix lint issue, etc. |
| Format | `<Space>fm` | Auto-format the file (LSP formatting; stylua in Lua buffers, prettier in Markdown buffers) |
| Comment/uncomment | `gcc` / `gc` (toggle), `gcs` / `gcr` (comment / uncomment explicitly; `gcss` / `gcrr` for the current line) | Toggle or set comments |
| Surround | `sa` / `sd` / `sr` | Add/delete/replace quotes, brackets, etc. |
| Change inside | `ci(` / `ci"` / `ci{` | Change text inside delimiters |
| Multiple replace | `*` then `ciw` then `n` `.` | Find-and-replace one at a time with control |

---
