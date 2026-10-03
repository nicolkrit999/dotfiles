<!-- chapter: Navigation -->
[Back to the guide index](README.md)

# 3. Core Navigation (Moving Without the Mouse)

All navigation happens in **Normal mode**. Press `<Esc>` first if you are in Insert mode.

## Basic Cursor Movement

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

## Moving Within a Line

| Keymap | Description |
| --- | --- |
| `H` | Jump to **first non-whitespace character** of the line (custom, mapped to `^`) |
| `L` | Jump to **last non-whitespace character** of the line (custom, mapped to `g_`) |
| `0` | Jump to the **very first column** (column 0) of the line |
| `^` | Jump to **first non-whitespace** character (same as `H` in this config) |
| `$` | Jump to the **end of the line** |
| `g_` | Jump to the last non-blank character of the line |

## Moving by Word

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

## Moving by Line/Screen

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

## Jumping to Matching Brackets/Parentheses

| Keymap | Description |
| --- | --- |
| `%` | Jump to the **matching bracket/parenthesis/brace**. If your cursor is on `(`, pressing `%` jumps to the matching `)`, and vice versa. Works with `()`, `[]`, `{}`, and also language keywords like `if`/`endif` (via vim-matchup plugin). |

The `matchpairs` option also includes: `<>`, and several CJK bracket pairs.

## Jumping to Specific Characters

**Note**: The built-in `f` motion has been replaced by the hop.nvim plugin (see Jump Navigation section). The following built-in motions still work:

| Keymap | Description |
| --- | --- |
| `t<char>` | Jump forward **to just before** the next occurrence of `<char>` on the current line |
| `T<char>` | Jump backward **to just after** the previous occurrence of `<char>` |

`;` is the command key in this config, so it does **not** repeat `t`/`T`. `,` still repeats the last `t`/`T` in the opposite direction.

## Jump Navigation with hop.nvim (Plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `f` | n, x, o | Press `f`, then type 2 characters. All matches on screen get labeled. Press the label letter to jump there instantly. Case insensitive. Press `<Esc>` to cancel. |

## Jump History

| Keymap | Description |
| --- | --- |
| `<Ctrl-o>` | Jump **back** to the previous location in the jump list |
| `<Ctrl-i>` | Jump **forward** to the next location in the jump list |

Every time you use a jump command (like `gg`, `G`, `/search`, `gd`, etc.), your position is saved. You can then go back and forth through your history with these keys.

## Word References (vim-illuminate)

Other uses of the word under the cursor are highlighted when there are at least 2 (from the LSP server, else from Treesitter). It only runs in these file types: bash, c, cpp, go, java, javascript, json, lua, markdown, nix, python, rust, sh, tex (also plain TeX), toml, typescript, typst, yaml (and the React variants of javascript and typescript). In `.nix` files only the identical word is highlighted (text matching): the nix language server would mark every package of a `with pkgs; [...]` list.

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Alt-n>` | n | Jump to the next reference of the word under the cursor |
| `<Alt-p>` | n | Jump to the previous reference |
| `<Alt-i>` | x, o | Text object: the reference under the cursor (e.g. `d<Alt-i>`) |

Commands: `:IlluminateToggle`, `:IlluminatePause`, `:IlluminateResume`.

## Marks (Bookmarks)

| Keymap | Description |
| --- | --- |
| `ma` | Set mark `a` at current cursor position |
| `` `a `` | Jump to the exact position of mark `a` |
| `'a` | Jump to the line of mark `a` (first non-whitespace) |
| `` `" `` | Jump to position where you last edited the file |
| `` `. `` | Jump to position of last change |
| `:marks` | List all marks |

Marks `a-z` are local to the file. Marks `A-Z` are global (across files).

---

# 22. Jump Navigation (`hop.nvim`)

| Keymap | Mode | Description |
| --- | --- | --- |
| `f` | n, x, o | Type `f` then 2 characters: all matches highlight with jump labels. Press the label letter to jump. Case insensitive. `<Esc>` to cancel. |

**Note**: Replaces Vim's built-in `f` motion (`F` is unchanged). `t{char}` jumps forward to just before a character on the current line, `T{char}` backward to just after it. `;` is mapped to `:`, so it does not repeat these motions; use `,` (opposite direction).

---

# 23. Search Lens (`nvim-hlslens`)

| Keymap | Description |
| --- | --- |
| `n` | Next match with `[x/y]` count overlay |
| `N` | Previous match with count overlay |
| `*` | Search the word under the cursor forward as a whole word (the cursor stays on the word; with a count, e.g. `3*`, it jumps 3 matches forward from the cursor, like `3n`) |
| `#` | Same, backward |

---

# 37. Symbol Outline (`aerial.nvim`)

The outline comes from Treesitter or the LSP server (no ctags needed).

| Keymap | Description |
| --- | --- |
| `<Space>t` | Toggle the symbol outline sidebar (functions, classes, methods; the cursor stays in your code) |
| `[t` / `]t` | Previous / next symbol (only in buffers where aerial is active; there they replace Vim's `:tprevious` / `:tnext` keys) |

Commands: `:AerialToggle`, `:AerialOpen`, `:AerialNavToggle`.

---

# 50. Code Navigation Strategies

This section covers how developers typically navigate code in this setup.

## Finding Files

| Method | Keymap | Best for |
| --- | --- | --- |
| Fuzzy file search | `<Space>ff` | When you know part of the filename |
| Recent files | `<Space>fr` | Files you've worked on recently |
| File explorer | `<Space>s` | Browsing project structure visually |
| Buffer search | `<Space>fb` | Switching between already-open files |
| Buffer pick | `<Space>bp` | Quick switch when you can see the buffer tab |
| Buffer cycle | `gb` / `gB` | Cycling through open files linearly (`{N}gb` = buffer number N) |

## Finding Code

| Method | Keymap | Best for |
| --- | --- | --- |
| Project-wide grep | `<Space>fg` | Searching for a string/pattern across all files |
| Word under cursor | `*` or `#` | Finding all uses of the current word in the file |
| Go to definition | `gd` | Jumping to where something is defined |
| Peek definition | `<Space>gd` | Checking a definition without leaving context |
| Peek references | `<Space>gr` | Seeing everywhere something is used |
| Buffer tags | `<Space>ft` | Jumping to a function/class in the current file (uses ctags) |
| Symbol outline | `<Space>t` | Sidebar (aerial) with all symbols in the file; focus stays in the code |

## Understanding Code

| Method | Keymap | What you learn |
| --- | --- | --- |
| Hover docs | `K` | Function signature, parameters, return type, docstring |
| Peek references | `<Space>gr` | How and where this symbol is used |
| Git blame | `<Space>hb` | Who wrote this line, when, and why (commit message) |
| Diagnostics | `<Space>dd` | What's wrong with this line and where the error comes from |
| Code outline | `<Space>t` | The structure of the file (classes, functions, methods) |
| Breadcrumb bar | (automatic) | Current location in the code shown at the top (dropbar) |

## Refactoring Code

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
