# Neovim User Guide

Leader key: `<Space>`

This guide is written for people who are new to Neovim. It covers everything you need to navigate, edit, and manage files without ever touching the mouse.

---

# 1. Understanding Modes

Neovim is a modal editor. You are always in one of these modes:

| Mode | How to enter | What it does |
| --- | --- | --- |
| **Normal** | `<Esc>` from any mode | Navigate, delete, copy, paste, run commands. This is your "home base". |
| **Insert** | `i`, `a`, `o`, `O`, `c` from Normal (`s` is disabled here: it is the vim-sandwich prefix) | Type text into the file. |
| **Visual** | `v`, `V`, `<Ctrl-v>` from Normal | Select text (character, line, or block). |
| **Command** | `;` or `:` from Normal | Type commands at the bottom of the screen (e.g., `:w` to save). |
| **Terminal** | When inside a terminal buffer | Interact with a shell. Press `<Esc>` to go to Normal mode (in the Claude Code panel `<Esc>` goes to Claude: use `<Ctrl-\><Ctrl-n>` there). |

### Entering Insert Mode

| Keymap | Description |
| --- | --- |
| `i` | Insert before cursor |
| `I` | Insert at beginning of line |
| `a` | Insert after cursor |
| `A` | Insert at end of line |
| `o` | Open new line below and insert |
| `O` | Open new line above and insert |

### Leaving Insert Mode

| Keymap | Description |
| --- | --- |
| `<Esc>` | Return to Normal mode |
| `jk` (typed quickly) | Return to Normal mode (via better-escape.vim plugin, 200ms window) |

### Visual Mode Variants

| Keymap | Description |
| --- | --- |
| `v` | Character-wise visual (select individual characters) |
| `V` | Line-wise visual (select entire lines) |
| `<Ctrl-v>` | Block visual (select a rectangular block of text) |

---

# 2. Quick Reference

Most-used keybinds at a glance. Every keymap here is explained in detail later.

| Keymap | Action |
| --- | --- |
| `;` | Enter command mode (replaces `:`) |
| `j` / `k` | Move down / up |
| `h` / `l` | Move left / right |
| `w` / `b` | Move forward / backward by word |
| `H` | Go to the first non-blank character of the line |
| `L` | Go to the last non-blank character of the line |
| `gg` / `G` | Go to start / end of file |
| `f` | Hop: jump to any 2-char match on screen |
| `<Space>w` | Save buffer |
| `<Space>q` | Save the buffer if modified and close the window (`:x`) |
| `<Space>Q` | Force quit Neovim and DISCARD unsaved changes, after a Yes/No confirmation (`:qa!`) |
| `<Space>s` | Toggle file explorer (nvim-tree) |
| `<Space>ff` | Fuzzy find files |
| `<Space>fg` | Project-wide text search (live grep) |
| `<Space>fr` | Recently opened files |
| `<Space>bp` | Pick buffer from list |
| `gb` / `gB` | Next / previous buffer |
| `gd` | Go to definition (LSP; without a capable server it is Vim's own `gd`) |
| `K` | Hover documentation (LSP; without a capable server it is Vim's own `K`) |
| `<Space>rn` | Rename symbol (LSP) |
| `<Space>ca` | Code actions (LSP) |
| `<Space>fm` | Format file (LSP formatter; stylua in Lua, prettier in Markdown) |
| `gcc` | Toggle comment on current line |
| `gc` | Toggle comment on selection |
| `<Alt-j>` / `<Alt-k>` | Move line(s) down / up (a count moves N lines) |
| `]<Space>` / `[<Space>` | Insert a blank line below / above (cursor stays; `3]<Space>` inserts 3) |
| `<Space>rr` | Run current file |
| `<Space>gs` | Git status (only inside a git repository) |
| `<Space>cc` | Toggle Claude Code |
| `u` / `<Ctrl-r>` | Undo / redo |
| `<Space>u` | Toggle the undo tree |
| `<Space>t` | Toggle the symbol outline (aerial) |
| `gS` | Split / join the list, arguments or block under the cursor (treesj) |
| `\h` / `\H` | Open the dashboard / leave it and return to the previous buffer |
| `<Space>sv` | Restart Neovim (writes all files first) |
| `n` / `N` | Next / previous search match (count works; the match is centred and folds opened) |

---

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

Other uses of the word under the cursor are highlighted when there are at least 2 (from the LSP server, else from Treesitter).

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

# 4. Editing

## Entering Insert Mode for Editing

| Keymap | Description |
| --- | --- |
| `i` | Insert before cursor |
| `I` | Insert at beginning of line (first non-whitespace) |
| `a` | Insert after cursor |
| `A` | Insert at end of line |
| `o` | Open new line below and enter insert mode |
| `O` | Open new line above and enter insert mode |
| `s` | **Note**: `s` is disabled (used by vim-sandwich). Use `cl` instead (delete char + insert). |
| `S` | Delete entire line content and enter insert mode |
| `C` | Delete from cursor to end of line and enter insert mode (without polluting register) |
| `cc` | Delete entire line and enter insert mode (without polluting register) |

## Deleting Text

All delete operations also **cut** (yank) the text into a register, so you can paste it with `p`. Exception: `c`, `C`, `cc` (also `c` on a selection) in this config send to the black hole register (they do NOT save to paste register). `S` is NOT redirected: it fills the paste register.

| Keymap | Mode | Description |
| --- | --- | --- |
| `x` | n | Delete the character under the cursor |
| `X` | n | Delete the character before the cursor (like backspace) |
| `dd` | n | Delete (cut) the entire current line |
| `D` | n | Delete from cursor to end of line |
| `dw` | n | Delete from cursor to the start of the next word |
| `db` | n | Delete backward to the start of the previous word |
| `diw` | n | Delete the word under the cursor (inner word) |
| `daw` | n | Delete the word under the cursor + surrounding whitespace |
| `d$` | n | Delete from cursor to end of line |
| `d0` | n | Delete from cursor to beginning of line |
| `dG` | n | Delete from current line to end of file |
| `dgg` | n | Delete from current line to start of file |
| `5dd` | n | Delete 5 lines starting from current |

## Copying (Yanking) Text

| Keymap | Mode | Description |
| --- | --- | --- |
| `yy` | n | Yank (copy) the current line |
| `yw` | n | Yank from cursor to start of next word |
| `yiw` | n | Yank the word under cursor |
| `y$` | n | Yank from cursor to end of line |
| `y0` | n | Yank from cursor to beginning of line |
| `5yy` | n | Yank 5 lines |
| `<Space>y` | n | Yank the entire buffer (custom) |

**Note**: The clipboard is set to `unnamedplus` whenever a clipboard tool (wl-clipboard, xclip, ...) is installed, so yanking also copies to the system clipboard.

## Pasting Text

| Keymap | Mode | Description |
| --- | --- | --- |
| `p` | n | Paste after the cursor |
| `P` | n | Paste before the cursor |
| `p` | x | Replace the selection with the register (yanky's paste: the replaced text goes into the register, so a second `p` pastes what was replaced; use `"0p` to paste the last yank again) |
| `<Space>p` | n | Paste on a new line below (custom) |
| `<Space>P` | n | Paste on a new line above (custom) |
| `[y` | n | After pasting, cycle to previous yank history entry (needs a paste first) |
| `]y` | n | After pasting, cycle to next yank history entry (needs a paste first) |

yanky.nvim loads right after the first screen (VeryLazy), so every yank of the session is recorded in its history. `p`/`P` (Normal and Visual) are then yanky's paste with a 300 ms highlight of the pasted text, and `[y`/`]y` exist (after a paste).

## Changing (Delete + Enter Insert)

`c` (change) deletes text and puts you into insert mode. In this config, `c`/`C`/`cc` do NOT save the deleted text to the paste register (they use the black hole register).

| Keymap | Description |
| --- | --- |
| `cw` | Change from cursor to end of word |
| `ciw` | Change the entire word under cursor |
| `caw` | Change the word + surrounding whitespace |
| `cc` | Change the entire line |
| `C` | Change from cursor to end of line |
| `c$` | Same as `C` |
| `c0` | Change from cursor to beginning of line |

## Replacing Text

| Keymap | Description |
| --- | --- |
| `r<char>` | Replace the single character under cursor with `<char>` |
| `R` | Enter **Replace mode** (overtype mode): every character you type replaces the existing one |

## Undo / Redo

| Keymap | Description |
| --- | --- |
| `u` | Undo the last change |
| `<Ctrl-r>` | Redo (undo the undo) |
| `<Space>u` | Toggle Neovim's builtin undo tree in a 30-column panel on the left |

**Undo breakpoints**: Typing `,` `.` `!` `?` `;` `:` in insert mode creates undo checkpoints. This means pressing `u` after a long insert session will undo in smaller chunks instead of reverting everything at once.

## Repeating Actions

| Keymap | Description |
| --- | --- |
| `.` | Repeat the last change. Works with most editing commands. Extremely powerful: e.g., `ciw` + type new word + `<Esc>`, then move to another word and press `.` to repeat. |

## Line Operations

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Alt-j>` | n | Move current line down one position (`3<Alt-j>` moves it 3 lines; re-indented; nothing happens at the last line) |
| `<Alt-k>` | n | Move current line up one position (count works the same) |
| `<Alt-j>` | x | Move selected lines down (count works; re-indented; the selection stays) |
| `<Alt-k>` | x | Move selected lines up |
| `]<Space>` | n | Insert a blank line below (cursor stays in place; `3]<Space>` inserts 3) |
| `[<Space>` | n | Insert a blank line above (cursor stays in place) |
| `J` | n | Join the current line with the next line (cursor stays in place; `3J` joins 3 lines) |
| `gJ` | n | Join lines without inserting a space (cursor stays in place) |
| `gS` | n | Toggle split / join of the list, argument list, table, dict or block under the cursor (treesj, Treesitter based) |

## Indentation

| Keymap | Mode | Description |
| --- | --- | --- |
| `>>` | n | Indent the current line to the right |
| `<<` | n | Indent the current line to the left |
| `>` | x | Indent selection right (stays in visual mode so you can press `>` again) |
| `<` | x | Indent selection left (stays in visual mode) |
| `=` | n, x | Auto-indent: fix indentation of the current line or selection |
| `gg=G` | n | Auto-indent the entire file |

## Insert Mode Shortcuts

| Keymap | Description |
| --- | --- |
| `<Ctrl-u>` | Convert the current word to UPPERCASE (the word under or right before the cursor; if only spaces separate the cursor from the previous word, that word). You stay in Insert mode. |
| `<Ctrl-t>` | TOGGLE the case of the FIRST letter of that same word (`foo` -> `Foo`, press again -> `foo`); letters whose case does not round-trip (`ß`, `ı`) and non-letters are left alone; the cursor keeps its place |
| `<Alt-;>` | Insert a semicolon at the end of the line (without moving cursor) |
| `<Ctrl-a>` | Jump to the beginning of the line |
| `<Ctrl-e>` | Jump to the end of the line (while the completion menu is open it closes the menu instead) |
| `<Ctrl-d>` | Delete the character to the right of the cursor |
| `<Ctrl-w>` | Delete the word before the cursor |
| `<Ctrl-h>` | Delete the character before the cursor (like backspace) |
| `<Ctrl-s>` | Show the LSP signature help of the function call you are typing |

## Miscellaneous Editing

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space><Space>` | n | Remove all trailing whitespace from the file (not in Markdown: there it only shows the warning "markdown: trailing spaces are hard line breaks, not stripped") |
| `<Space>v` | n | Reselect the text that was just pasted |
| `<Space>cl` | n | Toggle a vertical cursor column highlight |
| `<Space>cb` | n | Blink the cursor (helps find it on screen) |
| `~` | n | Toggle case of character(s) (tilde is set as operator, so use `~w` for word, `~e`, etc.) |

---

# 5. Selection (Visual Mode)

Press `v`, `V`, or `<Ctrl-v>` to enter visual mode, then use any motion to extend the selection. Once selected, you can act on the selection with `d` (delete), `y` (yank), `c` (change), `>` (indent), `<` (deindent), etc.

## Selecting Characters

| Keymap | Description |
| --- | --- |
| `v` | Start character-wise visual selection at cursor |
| `v` + `h` / `l` | Extend selection left / right by character |
| `v` + `w` | Extend selection to the next word |
| `v` + `b` | Extend selection backward to previous word |
| `v` + `e` | Extend selection to end of current word |
| `v` + `$` | Extend selection to end of line |
| `v` + `0` | Extend selection to beginning of line |
| `v` + `G` | Extend selection to end of file |
| `v` + `gg` | Extend selection to start of file |
| `v` + `}` | Extend selection to next blank line |

## Selecting Lines

| Keymap | Description |
| --- | --- |
| `V` | Start line-wise visual (selects the entire current line) |
| `V` + `j` / `k` | Extend selection down / up by lines |
| `V` + `5j` | Select current line + 5 lines below |
| `ggVG` | Select the entire file |

## Selecting Blocks (Columns)

| Keymap | Description |
| --- | --- |
| `<Ctrl-v>` | Start block visual (rectangular selection) |
| `<Ctrl-v>` + `j` / `k` / `h` / `l` | Extend the block in any direction |
| `<Ctrl-v>` + `I` | Insert text at the start of every selected line (press `<Esc>` to apply) |
| `<Ctrl-v>` + `A` | Append text at the end of every selected line |
| `<Ctrl-v>` + `d` | Delete the selected block |
| `<Ctrl-v>` + `c` | Change the selected block |

This is extremely useful for editing columns of text, adding prefixes to multiple lines, etc.

## Selecting Inside/Around Delimiters (Text Objects)

These are the most powerful selection commands. They work with `v` (select), `d` (delete), `c` (change), `y` (yank), and any other operator.

### Parentheses, Brackets, Braces

| Keymap | Description |
| --- | --- |
| `vi(` | Select everything **inside** `(...)` |
| `va(` | Select everything **including** `(...)` (the parentheses themselves) |
| `vib` / `vab` | Select inside / around the nearest enclosing pair of **any** of `()`, `[]`, `{}` (targets.vim; on `{ [ x ] }` with the cursor on `x`, `vib` selects ` x `) |
| `vi[` | Select everything inside `[...]` |
| `va[` | Select everything including `[...]` |
| `vi{` or `viB` | Select everything inside `{...}` |
| `va{` or `vaB` | Select everything including `{...}` |
| `vi<` | Select everything inside `<...>` |
| `va<` | Select everything including `<...>` |

### Quotes

| Keymap | Description |
| --- | --- |
| `vi"` | Select everything inside `"..."` |
| `va"` | Select everything including the `"` characters |
| `vi'` | Select everything inside `'...'` |
| `va'` | Select everything including the `'` characters |
| `` vi` `` | Select everything inside `` `...` `` |
| `` va` `` | Select everything including the `` ` `` characters |

### Words, Lines, Paragraphs

| Keymap | Description |
| --- | --- |
| `viw` | Select the word under cursor |
| `vaw` | Select the word + surrounding whitespace |
| `viW` | Select the WORD under cursor (delimited by whitespace only) |
| `vaW` | Select the WORD + surrounding whitespace |
| `vis` | Select the sentence (inner: without the trailing whitespace) |
| `vas` | Select the sentence + trailing whitespace (`das`, `dis`, `cis` work the same; the sentence motions are `(` / `)`) |
| `viS(` / `vaS(` | vim-sandwich "query" objects: type the surrounding character after them (`viS(` selects inside the nearest `(...)`, `vaS"` around the nearest `"..."`; `viS` alone just waits for that character; `diS(`, `daS"`, `ciS[` work in the same way). `ib` / `ab` stay targets.vim's any-bracket objects |
| `vip` | Select the paragraph (block of non-empty lines) |
| `vap` | Select the paragraph + surrounding blank lines |

### Tags (HTML/XML)

| Keymap | Description |
| --- | --- |
| `vit` | Select everything inside the nearest HTML/XML tag pair |
| `vat` | Select the entire tag pair including the tags |

### Using with Operators (d, c, y)

All the `vi` and `va` patterns above work with any operator, not just `v`:

| Keymap | Description |
| --- | --- |
| `di(` | **Delete** everything inside parentheses |
| `da(` | Delete everything including the parentheses |
| `ci"` | **Change** text inside double quotes (deletes it and enters insert mode) |
| `ca"` | Change including the quotes themselves |
| `yi{` | **Yank** (copy) everything inside curly braces |
| `ya{` | Yank including the braces |
| `di[` | Delete everything inside square brackets |
| `dit` | Delete everything inside HTML tags |
| `ci'` | Change text inside single quotes |
| `dip` | Delete the entire paragraph |

### Treesitter Node Selection (builtin)

Neovim 0.12 can grow and shrink a selection along the syntax tree (needs a Treesitter parser; otherwise it uses the LSP selection range):

| Keymap | Mode | Description |
| --- | --- | --- |
| `an` | x, o | Select the parent (outer) node: press `v`, then `an` repeatedly to grow the selection |
| `in` | x, o | Select the child (inner) node: shrinks the selection again |
| `]n` / `[n` | x | Select the next / previous node |
| `]N` / `[N` | x | Select the next / previous sibling node |

### More Text Objects

| Keymap | Mode | Description |
| --- | --- | --- |
| `ii` / `ai` | x, o | The current indent scope (mini.indentscope); `ai` includes its border lines. `[i` / `]i` jump to the top / bottom of the scope |
| `i%` / `a%` | x, o | Inside / around a matching pair, also keywords like `if` ... `end` (vim-matchup) |
| `ia` / `aa` | x, o | Inside / around a function argument (targets.vim: on `b` in `f(a, b, c)`, `daa` gives `f(a, c)`) |
| `iq` / `aq` | x, o | Inside / around the nearest quotes of any kind (targets.vim) |
| `i,` / `a,` | x, o | Between separators such as `,` `;` `:` `+` `-` `=` `/` `\|` `&` (targets.vim) |
| `<Space>iB` | x, o | The whole buffer (`y<Space>iB` copies everything) |
| `<Space>iu` | x, o | The URL under the cursor (`d<Space>iu`) |
| `<Alt-i>` | x, o | The LSP/Treesitter reference under the cursor (vim-illuminate) |

### Markdown Code Block Text Objects

In markdown files only:

| Keymap | Description |
| --- | --- |
| `vic` | Select inside a fenced code block |
| `vac` | Select the code block including the fences |

## Precision Selection: From the Cursor to an Exact Spot

How to select (or delete/copy/change) from the cursor to a specific character, word, or place, including on another line.

**Golden rules**
- The character **under the cursor is always included** in a visual selection, both at the start and at the end.
- Everything below works after `v`. Most of it also works after an operator (`d`, `y`, `c`) in place of `v`: for example `vt)` -> `dt)`, `yt)`, `ct)`. Exceptions are noted below.
- A *selection* can only be one continuous area. You cannot select two separate places at once (see "Non-contiguous lines" below).

### Quick lookup

| I want to select from the cursor to... | Keys |
| --- | --- |
| the end of the line | `vL` (or `v$`) |
| just **before** the next `X` on this line | `vtX` |
| **including** the next `X` on this line | `vtXl` |
| just before the 2nd `X` on this line | `v2tX` |
| the next `X` anywhere (crosses lines) | `v/X<Enter>` (lands on the start of the match) |
| the **end** of the next word/text `foo` | `v/foo/e<Enter>` |
| the 2nd `foo` after the cursor, anywhere in the file | `v2/foo/e<Enter>` |
| something visible on screen, no counting | `v` `f` `xx` `<label>`, then adjust with `l`/`h`/`e` |
| a target N lines below, count unknown | `Nj`, `L`, `?foo<Enter>`, `viw` |

### End of line: `L`

- `L` is mapped to `g_` (last **non-blank** character of the line) in normal and visual mode; `H` is the first non-blank.
- `vL` selects from the cursor through the last character of the line (for example a trailing `;`). `v$` does the same (`$` is remapped to `g_` in visual mode only, so the newline is not selected).
- The mapping covers normal and visual mode only, **not operator-pending**. After an operator, `L` is the built-in "bottom of the screen" motion and works on whole lines. **Do not use `dL` / `yL` / `cL`**: `dL` was tested and deleted whole lines from the current one to the bottom of the window. Use `dg_` / `yg_` / `cg_` (tested: `dg_` deletes from the cursor through the last non-blank character), or `vL` then `d` / `y`.
- With a count, `2L` goes to the end of the line below.

### `t` and `T`: stop just before a character

- `t<char>` jumps forward to the character **just before** the next `<char>`. `T<char>` does the same backward and stops just **after** it.
- It only searches the **current line**. If `<char>` is not on the line, nothing happens.
- It finds the next occurrence, not the last. The character under the cursor is not counted as a match.
- To **include** the target, add `l` after it: `vt:l` (up to and including the next `:`).
- `f` cannot be used for this, because `f` is hop.nvim here (it asks for 2 characters and shows labels). `vf:` does not do what you expect. After an operator `f` is still hop, but it is **not limited to the current line**: see the `df,` note below.
- Works with operators: `dt)` deletes up to before `)`, `yt"` copies up to before `"`, `ct)` changes up to before `)`. To include the target character with an operator, use `v` first: `vt)l` then `d`.
- **`f` after an operator (`df,`, `cf,`) is hop, not the built-in `f`** (tested): `df,` deleted from the cursor through a comma several lines below (it was the only comma in the visible text), so it is **not limited to the current line** and the target character is **deleted too**. `cf,` deleted the same kind of range (tested with one match on screen: `cf,` deleted the same range as `df,` and left you in Insert mode; with several matches you pick the label first). With several matches on screen, hop shows labels and you choose the target, so the deleted range depends on the label you press; check what you typed before pressing `d`/`c` on a big range (`u` undoes it).

### Counting: `v2tX` is not `2vtX`

- Put the count **after** `v`, directly before `t`: `v2to` stops just before the 2nd `o` on the line. `v3t,` stops before the 3rd `,`.
- `2vt` is a **different** thing: a count typed before `v` reselects a region of that size, it does not mean "2nd occurrence".
- Counts also work with operators: `d2to`, `y2t)`, `c3t,`.
- `T` counts backward: `v2T"`.
- If the line has fewer occurrences than the count, nothing is selected or moved.

### `)` and `(` are sentence motions, not parentheses

- `)` jumps to the **start of the next sentence**, and `(` to the start of the current/previous one. They do **not** mean "closing parenthesis". The search is not limited to the current line, so they can cross many lines.

**What counts as the end of a sentence** (standard Vim rules):
- A `.`, `!` or `?` that is followed by a **space, a tab or the end of the line**. Closing characters `)`, `]`, `"` or `'` may sit between the `.`/`!`/`?` and that space (for example `done.") Next` still ends a sentence).
- A **blank line** also separates sentences (it is a paragraph boundary).
- A `.` with **no space after it does not count**: `obj.method()` or `file.txt` do not end a sentence. In code, only a `.`/`!`/`?` followed by a space or at the end of a line counts (for example inside a string or a comment).

**Where the cursor lands**: on the **first non-blank character of the next sentence**, which is the first character after the terminator and the spaces that follow it.

**Where a selection ends**: in Visual mode the character under the cursor is included, so `v)` selects from the cursor **through that first letter of the next sentence** (the spaces before it are selected too). With an operator (`d)`, `y)`) the motion stops just before that letter and does not include it (tested with `d)`: with the cursor on the `t` of `there`, it deleted `there. ` and the cursor ended on the `H` of `How`; `y)` was not tested).

Concrete example. Text on one line, cursor on the `t` of `there`:

```
Hello there. How are you? Fine!
```

| Keys | What is selected / where the cursor ends |
| --- | --- |
| `v)` | `there. H`: ends on the `H` of `How`, the first letter of the next sentence (the `. ` after `there` is the boundary) |
| `v))` | `there. How are you? F`: ends on the `F` of `Fine` |
| `v(` | from the start of `Hello` up to the `t`, because `(` goes back to the start of the current sentence |

Tested once on real code: starting inside a line of code, `v)` ran across several lines and stopped on the first letter after a `. ` that was inside a string literal (`"... text. Next ..."`, it stopped on the `N`), because that `. ` counts as a sentence boundary even in code. All three rows of the table above were tested with the example text and gave exactly the results listed. Also tested: on a line like `see file.txt now. Next one.` with the cursor on `see`, `v)` selected `see file.txt now. N`, so the `.` in `file.txt` (no space after it) did not stop it.

Tip when testing these: type the sequence in one go (`v))`, not `v` and then `)` as separate steps). Pressing `v` again while already in Visual mode leaves Visual mode, and the which-key popup that appears after `v` is only a help list.

- To reach a closing parenthesis: `vt)l` (up to and including it), or `v/)<Enter>`.
- `%` jumps between a bracket and its match; it will not take you to a closing bracket from a plain character (it first finds the next bracket on the line and jumps to its partner, which can be backward).
- `va(` / `vi(` select the whole group / its inside, but always starting from the opening `(`, never from the cursor. Thanks to targets.vim the cursor may also be in front of the pair on the same line (tested: `vi(` on `foo (bar) baz` with the cursor on `f` selects `bar`).

### Search as a selection motion (crosses lines)

Searching with `/` (forward) or `?` (backward) works as a motion after `v`:

| Keys | The selection ends at |
| --- | --- |
| `v/foo<Enter>` | the **first** character of the next `foo` (included) |
| `v/foo/e<Enter>` | the **last** character of `foo` (included) |
| `v/foo/e-1<Enter>` | one character before the end of `foo` |
| `v/foo/e+1<Enter>` | one character after the end of `foo` |
| `v2/foo<Enter>` | the start of the 2nd `foo` after the cursor |
| `v2/foo/e<Enter>` | the end of the 2nd `foo` after the cursor |

- The text after the second `/` (`e`, `e-1`, `e+1`) is a search **offset**; `e` means "end of the match".
- **The count counts matches, not lines.** `2/foo` means "the 2nd `foo` after the cursor, wherever it is". It does not care on which line a match is. If a line you expected has no `foo`, the count simply moves on to the next match.
- Because it counts matches, it also works **inside a single line**: if a line contains `foo` twice, `v2/foo/e<Enter>` selects up to the end of the second `foo` on that same line (tested: on a line with `Nome` and `nome`, the selection ended on the last letter of the second match, `nome`). (Unlike `t`, which also works on one line, search lets you target a whole word or phrase, not just one character.)
- If there are fewer matches than the count, the search **wraps** to the top of the file (`wrapscan` is on by default and this config does not change it) and keeps counting, so you can end up before the cursor. Check the hlslens `[n/total]` overlay.
- `ignorecase smartcase` is on, so a lowercase pattern (`foo`) also matches `Foo`. Type a capital letter to make it case-sensitive. (This is for `/` and `?`; `:s` and `:g` always ignore case here, see the Substitution section.)
- `/` is not remapped in this config.
- With operators, `d/foo<Enter>` deletes up to (not including) the match; `d/foo/e<Enter>` includes the last letter of the match (tested: with the cursor on the start of `two words`, `d/words/e<Enter>` deleted everything up to and including the last letter of `words`).

### Hop: select to something you can see (no counting)

1. `v` starts the selection at the cursor.
2. `f` then type **2 characters**. Every matching place on screen gets a label (case insensitive).
3. Press the label letter. The cursor jumps there, and the selection now ends **on the first character of that match**, included.
4. Extend or trim with a normal motion:

| Key | Effect |
| --- | --- |
| `l` | extend the selection one character **to the right** (`3l` = three characters) |
| `h` | move the end one character **to the left**: use it to pull back if you went one too far, or to extend leftward if the target is before the start |
| `e` | extend to the end of the word (no need to count its letters) |
| `b` | move back to the start of the word |

Example: to select from the cursor to the end of a 4-letter word you can see: `v`, `f`, the word's first 2 letters, the label, then `lll` (first letter + 3 more) or simply `e`.

- Hop only reaches text that is **visible on screen**.
- Two-letter patterns match many places (for example `no` in `non`, `nome`, `Nome`), so look at the labels and pick the right one.

### Target on another line, count unknown: use the relative numbers

With relative line numbers the gutter shows how far each line is from the cursor (the current line shows its absolute number).

1. `Nj` moves down `N` lines, where `N` is the number shown next to the target line (with a count, `j` moves real lines, not wrapped ones). Use `Nk` to go up.
2. `L` goes to the end of that line.
3. `?foo<Enter>` searches **backward** from the end of the line, which should find the **last** `foo` on that line (retested headless in 3 variants and the LAST match was selected every time; an earlier user report of the first match is not reproduced, so watch for it). <!-- CHECK-USER: ?foo after L: does it select the last or the first match on the line? --> (Searching forward from the middle of the line could hit an earlier, unwanted match or a capitalised one.)
4. `viw` selects the word, or `ve` selects from the match start to the word end.

Related: `V3j` selects the current line and 3 below; `d3j` deletes 4 lines; `10G` or `;10` (Enter) jumps to absolute line 10.

### Typing before or after: `i` `a` `I` `A`

| Key | Where the typed text goes |
| --- | --- |
| `i` | **before** the character under the cursor |
| `a` | **after** the character under the cursor |
| `I` | before the **first non-whitespace** character of the line (not column 0: on an indented line it goes after the indentation; for the true start use `0` then `i`) |
| `A` | after the **last character** of the line (the real end, even past trailing spaces) |

**Typing at the absolute start of an indented line** (before the indentation):

| Keys | Where you start typing |
| --- | --- |
| `I` | after the indentation, before the first non-blank character |
| `0` then `i` | at column 0, before the indentation (**preferred**) |
| `gI` | the same as `0` then `i`, in one key (standard Vim; not remapped in this config) |

- `0` is remapped to `g0` (start of the *screen* line), but `set nowrap` is on, so lines never wrap and it is the same as the real column 0.
- Tested: `gI` and `0` then `i` both start typing at column 0, before the indentation.

- These only insert from **Normal mode**. In Visual mode `i` and `a` do not insert: they start a text object (`iw`, `i(`, `aw`...). Press `<Esc>` first.
- **Typing after a selection that ends at the end of the line** (for example after `v$` or `vL`): press `<Esc>` (the cursor stays on the last character), then `a`. Using `i` would put the text *before* that last character (for example before a final `;`).
- **Shortest way to type at the end of the line**: `A`, from anywhere on the line, with no selection needed.
- `L` and `g_` stop on the last **non-blank** character, so `<Esc>` + `a` after `vL` types right after the last visible character, before any trailing spaces. `A` goes after the trailing spaces.

### Non-contiguous lines (for example line 3 and line 10 together)

Not possible. Vim has no selection of separate pieces, and this config has no multi-cursor plugin (`vim-visual-multi` is commented out in `lua/plugin_specs.lua`). Do it in steps:

- **Repeat with `.`**: do the edit on one line, jump to the other, press `.`. Mind that deleting a line shifts the numbers below it.
- **Ex commands with line numbers**: `;3d` then `;9d`, or `;3,10d` for the whole range 3 to 10 (tested: `;3,10d` deleted lines 3 to 10 **inclusive**, 8 lines).
- **Bring them together**: `;3m10` moves line 3 **below** line 10, `;3t10` copies line 3 below line 10. Then select both with `V`. Tested: `;4m11` moved line 4 (an `import` line) to just below line 11, and `;4t11` copied line 4 below line 11 and kept the original in place. The line numbers refer to the file **before** the move, and afterwards the cursor sits on the moved/copied line.
- **The numbers are absolute file line numbers**, not relative to the cursor, and it does not matter where the cursor is. With relative numbers on, only the cursor line shows its absolute number in the gutter; move onto a line to read it. Line 1 counts even if it is blank (a file that starts with an empty line has its first real line at number 2).
- **Relative addresses**: `.` is the current line and `+N` / `-N` are N lines after/before it, so they match the relative numbers in the gutter. Tested: `;.t.` duplicated the current line and left the cursor on the new copy. Also tested: `;.m+2` moves the current line to below the line 2 lines further down, and `;.,+3d` deletes the current line and the next 3 (4 lines in total).
- **Blank lines hide the effect**: moving or copying a blank line next to another blank line changes nothing you can see. Use a line with text to check `m` and `t`.
- **Same spot on adjacent lines**: `<Ctrl-v>` block mode, but only for adjacent lines (see the Visual Block Editing section).
- **Matching by content instead of number**: the `:g` command (see its section).

---

## Line Range Yanking (Command Mode)

| Command | Description |
| --- | --- |
| `:-5,+10yank` | Yank from 5 lines before to 10 lines after cursor |
| `:2,10yank` | Yank from line 2 to line 10 (absolute) |

---

# 6. Working with Parentheses, Quotes, and Brackets

This section covers everything about matching, jumping to, selecting inside, changing, adding, and removing surrounding characters.

## Jumping to Matching Pair

| Keymap | Description |
| --- | --- |
| `%` | Jump between matching `()`, `[]`, `{}`, `<>`, and language keywords. The vim-matchup plugin extends this to work with `if`/`else`/`end`, `do`/`while`, `try`/`catch`, etc. If the match is offscreen, a popup shows the matching line. |

## Selecting Inside/Around Pairs

See the full table in the Selection section above. Quick summary:

| Pattern | Inside | Around (including delimiters) |
| --- | --- | --- |
| Parentheses `()` | `vi(` | `va(` |
| Braces `{}` | `vi{` or `viB` | `va{` or `vaB` |
| Brackets `[]` | `vi[` | `va[` |
| Angle brackets `<>` | `vi<` | `va<` |
| Double quotes `""` | `vi"` | `va"` |
| Single quotes `''` | `vi'` | `va'` |
| Backticks ` `` ` | `` vi` `` | `` va` `` |
| HTML/XML tags | `vit` | `vat` |
| Nearest of `()` `[]` `{}` (targets.vim) | `vib` | `vab` |

## Changing Text Inside Pairs

| Keymap | Description |
| --- | --- |
| `ci(` | Delete everything inside `()` and enter insert mode to type replacement |
| `ci"` | Delete everything inside `""` and enter insert mode |
| `ci{` | Delete everything inside `{}` and enter insert mode |
| `ci[` | Delete everything inside `[]` and enter insert mode |
| `ci'` | Delete everything inside `''` and enter insert mode |
| `cit` | Delete everything inside an HTML tag and enter insert mode |

## Deleting Text Inside Pairs

| Keymap | Description |
| --- | --- |
| `di(` | Delete everything inside `()` (parentheses remain empty) |
| `di"` | Delete everything inside `""` |
| `di{` | Delete everything inside `{}` |
| `da(` | Delete everything including the `()` themselves |
| `da"` | Delete everything including the `""` themselves |

## Adding Surrounding Pairs (vim-sandwich Plugin)

The `sa` command adds surrounding characters. `s` key alone is disabled (use `cl` instead).

| Keymap | Description | Example |
| --- | --- | --- |
| `saiw"` | Add double quotes around the current word | `hello` becomes `"hello"` |
| `saiw(` | Add parentheses around the current word | `hello` becomes `(hello)` |
| `saiw{` | Add curly braces around the current word | `hello` becomes `{hello}` |
| `saiw[` | Add square brackets around the current word | `hello` becomes `[hello]` |
| `saiw'` | Add single quotes around the current word | `hello` becomes `'hello'` |
| `sa$"` | Add quotes from cursor to end of line | |
| (visual) `sa"` | First select text with `v`, then `sa"` adds quotes around selection | |

## Removing Surrounding Pairs (vim-sandwich Plugin)

| Keymap | Description | Example |
| --- | --- | --- |
| `sd"` | Delete surrounding double quotes | `"hello"` becomes `hello` |
| `sd'` | Delete surrounding single quotes | `'hello'` becomes `hello` |
| `sd(` | Delete surrounding parentheses | `(hello)` becomes `hello` |
| `sd{` | Delete surrounding curly braces | `{hello}` becomes `hello` |
| `sdb` | Delete the nearest surrounding pair, whatever it is (`()`, `[]`, `{}` or quotes) | `[hello]` becomes `hello` |
| `sd[` | Delete surrounding square brackets | `[hello]` becomes `hello` |

## Replacing Surrounding Pairs (vim-sandwich Plugin)

| Keymap | Description | Example |
| --- | --- | --- |
| `sr"'` | Replace `"` with `'` | `"hello"` becomes `'hello'` |
| `sr({` | Replace `()` with `{}` | `(hello)` becomes `{hello}` |
| `sr{[` | Replace `{}` with `[]` | `{hello}` becomes `[hello]` |
| `sr'(` | Replace `'` with `()` | `'hello'` becomes `(hello)` |
| `srb'` | Replace the nearest surrounding pair, whatever it is | `"hello"` becomes `'hello'` |

## Auto-Pairing (nvim-autopairs Plugin)

When typing in insert mode, opening characters automatically insert their closing pair:
- Type `(` and `)` appears: `(|)` (cursor between them)
- Type `"` and closing `"` appears: `"|"`
- Type `{` and `}` appears: `{|}`
- Type `[` and `]` appears: `[|]`

---

# 7. Windows, Splits, and Buffers

This section explains how to open, navigate, resize, and close split windows entirely with the keyboard.

## Key Concepts

- **Buffer**: A file loaded into memory. You can have many buffers open but only see some of them.
- **Window**: A visible area showing a buffer. You can split your screen into multiple windows.
- **Tab**: A collection of windows. Think of it as a different workspace layout.

**Panel layout**: short single-task panels open on the LEFT (undo tree `<Space>u`, `<Space>rr` output, `:help` on a screen of at least 200 columns, which then opens as a full-height split on the far left), persistent panels on the RIGHT (Claude Code). Inactive windows are dimmed (vimade); the current window is always full colour.

## Creating Splits

| Keymap / Command | Description |
| --- | --- |
| `<Ctrl-w>s` or `:sp` | Split the current window **horizontally** (new window appears below) |
| `<Ctrl-w>v` or `:vs` | Split the current window **vertically** (new window appears to the right) |
| `<Space>-` | Split the current window **horizontally** (new window below, same buffer) |
| `<Space>\|` | Split the current window **vertically** (new window to the right, same buffer) |
| `:sp <file>` | Open `<file>` in a new horizontal split |
| `:vs <file>` | Open `<file>` in a new vertical split |

**Config note**: `splitbelow` and `splitright` are set, so new splits always open below/right.

## Navigating Between Windows

| Keymap | Description |
| --- | --- |
| `<Ctrl-w>h` or `<Left>` | Move to the window on the **left** |
| `<Ctrl-w>j` or `<Down>` | Move to the window **below** |
| `<Ctrl-w>k` or `<Up>` | Move to the window **above** |
| `<Ctrl-w>l` or `<Right>` | Move to the window on the **right** |
| `<Ctrl-w>w` | Cycle to the **next** window |
| `<Ctrl-w>W` | Cycle to the **previous** window |
| `<Ctrl-w>p` | Jump to the **previously active** window |

## Resizing Windows

| Keymap | Description |
| --- | --- |
| `<Ctrl-w>=` | Make all windows **equal size** |
| `<Ctrl-w>+` | Increase current window height by 1 line |
| `<Ctrl-w>-` | Decrease current window height by 1 line |
| `<Ctrl-w>>` | Increase current window width by 1 column |
| `<Ctrl-w><` | Decrease current window width by 1 column |
| `10<Ctrl-w>+` | Increase height by 10 lines |
| `10<Ctrl-w>>` | Increase width by 10 columns |
| `<Ctrl-w>_` | Maximize current window height (make it as tall as possible) |
| `<Ctrl-w>\|` | Maximize current window width (make it as wide as possible) |
| `:resize 20` | Set window height to 20 lines |
| `:vertical resize 80` | Set window width to 80 columns |

**Auto-resize**: When you resize your terminal, all windows resize equally, except the Claude Code panel, which goes back to 30% of the screen width.

## Moving Windows Around

| Keymap | Description |
| --- | --- |
| `<Ctrl-w>H` | Move current window to the **far left** (becomes full height) |
| `<Ctrl-w>J` | Move current window to the **very bottom** (becomes full width) |
| `<Ctrl-w>K` | Move current window to the **very top** (becomes full width) |
| `<Ctrl-w>L` | Move current window to the **far right** (becomes full height) |
| `<Ctrl-w>r` | **Rotate** windows in the current row/column |
| `<Ctrl-w>R` | Rotate windows in reverse |
| `<Ctrl-w>x` | **Swap** current window with the next one |
| `<Ctrl-w>T` | Move current window to a **new tab** |

## Closing Windows

| Keymap / Command | Description |
| --- | --- |
| `<Space>q` | Close the current window (saves if modified, `:x`). It fires after a short pause because `<Space>qb` / `<Space>qw` also exist |
| `<Space>Q` | Force quit Neovim, **discarding unsaved changes**, after a Yes/No confirmation (default No) |
| `:q` | Close current window |
| `:q!` | Close current window discarding unsaved changes |
| `:only` or `<Ctrl-w>o` | Close ALL other windows, keep only the current one |
| `\x` | Close the quickfix window and all location lists of the tab (the cursor stays in the current window) |

## Buffer Management

| Keymap / Command | Description |
| --- | --- |
| `gb` | Go to the **next** buffer; `{N}gb` (e.g. `3gb`) goes to buffer number N (an invalid number warns "Invalid bufnr") |
| `gB` | Go to the **previous** buffer. Do not give it a count: `{N}gB` does nothing (an invalid number warns "Invalid bufnr"); use `{N}gb` to jump to buffer N |
| `<Space>bp` | **Pick** a buffer: each open buffer shows a letter, press it to switch |
| `\d` | Close/delete the current buffer (window stays open, shows previous buffer). On the last buffer an empty buffer is left. A named file with changes is saved first by auto-save (BufLeave); a buffer auto-save does not save (unnamed, read-only, Typst/LaTeX) is not deleted: you land in the previous buffer and the unsaved one stays loaded. <!-- CHECK-USER: \d on an unsaved unnamed buffer: with 'confirm' on, do you get a Save changes? dialog or an E89 message? (headless shows neither) --> |
| `\D` | Close all other buffers, but **keep** buffers with unsaved changes and terminals that are still running (one message "kept N buffer(s) (unsaved or running terminal)") |
| `:ls` or `:buffers` | List all open buffers |
| `:b <name>` | Switch to a buffer by (partial) name |
| `:b 3` | Switch to buffer number 3 |

## Tabs

| Command | Description |
| --- | --- |
| `:tabnew` | Open a new empty tab |
| `:tabe <file>` | Open `<file>` in a new tab |
| `gt` | Go to the next tab |
| `gT` | Go to the previous tab |
| `:tabclose` or `\t` | Close the current tab |
| `:tabonly` or `\T` | Close all other tabs |

## Closing Floating Windows

Some plugins open floating windows (diagnostics, hover docs, etc.):

| Keymap | Description |
| --- | --- |
| `<Esc>` | Close any floating window (custom mapping) |

---

# 8. Terminal Integration

## Opening a Terminal

| Command / Keymap | Description |
| --- | --- |
| `:term` or `:terminal` | Open terminal in the current window |
| `:sp \| term` | Open terminal in a horizontal split below |
| `:vs \| term` | Open terminal in a vertical split to the right |
| `<Space>rr` | Run code (opens a terminal in a vertical split on the **left** of the code window) |

The terminal automatically starts in insert mode (you can type immediately) and hides line numbers. <!-- CHECK-USER: confirm :term and <Space>rr start in insert mode (not observable headless) -->

## Navigating In and Out of Terminal

| Keymap | Context | Description |
| --- | --- | --- |
| `<Esc>` | In terminal | **Exit terminal mode** and enter Normal mode. Now you can navigate away from the terminal window using `<Ctrl-w>h/j/k/l` or arrow keys. Exception: in the Claude Code panel `<Esc>` goes to Claude; use `<Ctrl-\><Ctrl-n>` there (see section 9). |
| `i` or `a` | In terminal (Normal mode) | Re-enter terminal mode (start typing commands again) |
| `<Ctrl-w>h/j/k/l` | In terminal (Normal mode) | Move to another window |
| `<Left>/<Right>/<Up>/<Down>` | In terminal (Normal mode) | Move to another window (arrow key shortcuts) |

**Workflow example**: You run code with `<Space>rr`. A terminal opens showing output. To go back to your code: press `<Esc>` to exit terminal mode, then `<Ctrl-w>l` (or `<Right>`) to move to the code window (the output is on the left). To close the terminal: `<Space>q` while in the terminal window.

## Closing a Terminal

| Method | Description |
| --- | --- |
| `<Space>q` | While the terminal window is focused (press `<Esc>` first), close the window. A program that is still running keeps running in a hidden buffer (`\D` keeps such buffers) |
| Type `exit` | In an interactive shell terminal (`:term`), `exit` ends the shell and the window closes. A `<Space>rr` run does NOT close its window when the program ends: the output stays (tested, no exit-code line is shown) until you close it with `<Space>q` |
| `\d` | Delete the terminal buffer <!-- CHECK-USER: does \d on a terminal whose program is still running ask "Close ...?" first? (headless deleted it silently; with 'confirm' on a real UI may ask first) --> |

---

# 9. AI Assistant Window (Claude Code)

## Claude Code

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>cc` | n | **Toggle** Claude Code terminal (opens/closes it) |
| `<Space>cR` | n | Resume/continue the last Claude conversation (`claude --continue`) |
| `<Space>cV` | n | Start Claude in verbose mode |
| `:ClaudeCodeResume` | | Start `claude --resume` (pick an older conversation; command only, no key) |
| `<Ctrl-h/j/k/l>` | t, n (Claude panel) | Move to the window left / below / above / right |
| `<Ctrl-f>` / `<Ctrl-b>` | t (Claude panel) | Scroll a page down / up |

Claude Code opens as a **vertical split on the right**, 30% of the screen width. It is a terminal buffer. There is no toggle key in terminal mode. To navigate:

1. **Move to the Claude window**: `<Ctrl-w>l` or `<Right>` (it opens on the right). Focusing it puts you in terminal (insert) mode by itself.
2. **Move back to code**: `<Ctrl-h>` (works directly in the Claude terminal), or `<Ctrl-\><Ctrl-n>` and then `<Ctrl-w>h` / `<Left>`. `<Esc>` is sent to Claude (for example to interrupt it) and does **not** leave terminal mode.
3. **Close Claude**: from the code window `<Space>cc` toggles it closed. Inside the Claude terminal press `<Ctrl-\><Ctrl-n>` first, then `<Space>cc` or `<Space>q`.
4. **Type in Claude**: If in Normal mode inside the Claude terminal, press `i` to re-enter terminal mode

Claude runs in the git root of the current file. Files Claude changes are reloaded in their buffers (checked every second while the panel is open). The panel is left out of saved sessions, and `\D` never deletes it while it runs.

---

# 10. Searching, Replacing, and Refactoring Text

This is one of the most important sections in the guide. It covers searching within a file, replacing text with various levels of control, and doing all of this across the entire project.

## Searching in the Current File

| Keymap | Description |
| --- | --- |
| `/pattern` | Search **forward** for `pattern`. Press `<Enter>` to start the search. |
| `?pattern` | Search **backward** for `pattern` |
| `n` | Jump to the **next** match (with hlslens showing `[x/y]` count) |
| `N` | Jump to the **previous** match |
| `*` | Search **forward** for the exact word under cursor (whole word, literal; the cursor stays on the word, `3*` jumps to the 3rd match after the cursor) |
| `#` | Search **backward** for the exact word under cursor |
| `;noh<Enter>` (`;` is `:` here) | Clear the yellow search highlight (tested). The search itself is kept, so `n` / `N` still work; the highlight comes back on the next search or `*`. |

### Search Modifiers

| Modifier | Where to put it | What it does | Example |
| --- | --- | --- | --- |
| `\c` | Anywhere in pattern | Force **case-insensitive** | `/\chello` finds `Hello`, `HELLO`, `hello` |
| `\C` | Anywhere in pattern | Force **case-sensitive** | `/\Chello` only finds `hello` |
| `\v` | At start of pattern | **Very magic**: regex works like Perl/Python (no need to escape `()`, `|`, `+`, etc.) | `/\vfunction\(.*\)` |
| `\<` and `\>` | Around pattern | **Whole word** match only | `/\<count\>` finds `count` but not `counter` |

By default, search is case-insensitive but becomes case-sensitive if you type any uppercase letter (smart case). This is for `/` and `?` only: while you type a `:` command, smart case is off, so `:s` and `:g` ignore case completely (use `\C` or the `I` flag of `:s` for an exact match).

### Search Examples

| Search | What it finds |
| --- | --- |
| `/hello` | `hello`, `Hello`, `HELLO` (smart case: all lowercase = case-insensitive) |
| `/Hello` | Only `Hello` (smart case: has uppercase = case-sensitive) |
| `/\vdef \w+\(` | All Python function definitions (very magic regex) |
| `/\v(TODO\|FIXME\|HACK)` | Any of these three words (very magic `|` for alternation) |
| `/\<user\>` | Only the word `user`, not `username` or `superuser` |
| `/error\c` | `error`, `Error`, `ERROR` (forced case-insensitive) |

---

## Substitution (Find & Replace in Current File)

The substitute command has this structure: `:[range]s/old/new/[flags]`

### Understanding the Range (Where to Replace)

The range tells Vim which lines to search. If omitted, only the current line is affected.

| Range | Meaning | Example |
| --- | --- | --- |
| (none) | Current line only | `:s/old/new/` |
| `%` | **Entire file** (all lines) | `:%s/old/new/g` |
| `.` | Current line (same as no range) | `:.s/old/new/g` |
| `$` | Last line of file | |
| `.,$` | From current line to end of file | `:.,$s/old/new/g` |
| `1,.` | From first line to current line | `:1,.s/old/new/g` |
| `20,30` | From line 20 to line 30 (absolute) | `:20,30s/old/new/g` |
| `-3,+3` | From 3 lines above to 3 lines below cursor (relative) | `:-3,+3s/old/new/g` |
| `'<,'>` | Current visual selection (auto-filled when you press `:` in visual mode) | `:'<,'>s/old/new/g` |

### Understanding the Flags (How to Replace)

Flags go at the very end, after the last `/`.

| Flag | What it does |
| --- | --- |
| (none) | Replace only the **first occurrence** on each line in range |
| `g` | **Global**: replace **all occurrences** on each line (not just the first) |
| `c` | **Confirm**: ask `y/n` for **each** replacement. You see the match highlighted and choose. |
| `i` | Case-**insensitive** matching |
| `I` | Case-**sensitive** matching. Needed here: `:s` ignores case completely, even with capitals in the pattern (tested: `:%s/Old/X/g` on `old Old OLD` gave `X X X`, with `gI` only `Old` changed) |
| `n` | **Count only**: show how many matches there are without replacing anything |
| `e` | Suppress "pattern not found" error |

### Flag Combinations

| Command | What happens |
| --- | --- |
| `:%s/old/new/` | Replace the first `old` on each line in the file |
| `:%s/old/new/g` | Replace **every** `old` in the entire file |
| `:%s/old/new/gc` | Replace every `old`, but **ask confirmation** for each one |
| `:%s/old/new/gi` | Replace every `old` case-insensitively (`Old`, `OLD`, `old` all match) |
| `:%s/old/new/gn` | **Count** how many `old` exist in the file (no replacement) |
| `:%s/old/new/gce` | Confirm each, and don't error if not found |

**Quick difference between the three common endings** (same `:%s/old/new` start, only the end changes):

| Ending | Replaces | Asks you? |
| --- | --- | --- |
| `/` (no flag) | only the **first** `old` on each line | no |
| `/gc` | **every** `old` on each line | yes, `y/n` for each one |
| `/gcc` | **every** `old` on each line (tested: the second `c` switches confirmation off again, so `/gcc` behaves like `/g`; `/gccc` asks again) | no |

Do not confuse `/gcc` with the normal-mode `gcc` (toggle comment on the current line): inside `:s/…/…/` the letters are flags, outside it `gcc` is a command.

### Confirmation Mode (`c` Flag) Controls

When you use the `c` flag, Vim highlights each match and asks what to do:

| Key | Action |
| --- | --- |
| `y` | **Yes**, replace this one and move to next |
| `n` | **No**, skip this one and move to next |
| `a` | **All**: replace this one and all remaining (stop asking) |
| `q` | **Quit**: stop replacing now |
| `l` | **Last**: replace this one and then stop |
| `<Ctrl-e>` | Scroll down to see more context |
| `<Ctrl-y>` | Scroll up to see more context |

### Changing the Delimiter

If your search/replace text contains `/`, use a different delimiter to avoid confusion:

| Command | What it does |
| --- | --- |
| `:%s#/usr/local/bin#/opt/bin#g` | Replace path using `#` as delimiter |
| `:%s\|old\|new\|g` | Use `\|` as delimiter |

You can use almost any character as a delimiter. Just use the same character for all three separators.

### Special Replacement Patterns

| Pattern in replacement | What it means |
| --- | --- |
| `&` | The entire matched text |
| `\1`, `\2`, etc. | Capture group 1, 2, etc. from `\( \)` in the search |
| `\u` | Uppercase the next character |
| `\U` | Uppercase everything after this |
| `\l` | Lowercase the next character |
| `\L` | Lowercase everything after this |
| `\r` | Newline (line break) |

### Substitution Examples

| Command | What it does |
| --- | --- |
| `:%s/foo/bar/g` | Replace all `foo` with `bar` |
| `:%s/\<foo\>/bar/g` | Replace only whole-word `foo` (not `foobar`) |
| `:%s/foo/bar/gc` | Replace all, confirming each one |
| `:%s/foo//g` | Delete all occurrences of `foo` |
| `:%s/\v(\w+), (\w+)/\2, \1/g` | Swap two comma-separated words: `last, first` becomes `first, last` |
| `:%s/\<\(\w\)/\u\1/g` | Capitalize the first letter of every word |
| `:%s/$/;/` | Add a semicolon at the end of every line |
| `:%s/^\s*$\n//g` | Delete all blank lines |
| `:20,30s/TODO/DONE/g` | Replace only between lines 20-30 |
| `:'<,'>s/old/new/g` | Replace only in the visual selection |

---

## Searching in the Current Buffer with `*` and `#`

These are the fastest ways to search for a word:

1. Place cursor on any word
2. Press `*` -- all occurrences highlight, the hlslens overlay shows `[1/N]`
3. Press `n` to jump forward, `N` to jump backward
4. With no count the cursor stays on the word you pressed `*` on (custom behavior in this config: a whole-word, literal search; `3*` jumps to the 3rd match after the cursor instead)

This is often combined with `ciw` + `.` for selective replacement (see below).

---

## Using `ciw` + `.` for Selective Single-File Replacement

This is the **most practical replacement method** for everyday use. It gives you full control, replacing one occurrence at a time:

1. Place cursor on the word you want to replace (e.g., `oldName`)
2. `*` -- search for it (all occurrences highlight)
3. `ciw` -- delete the word and enter insert mode
4. Type the new word (e.g., `newName`), then press `<Esc>`
5. `n` -- jump to the next occurrence
6. Decide: press `.` to replace this one too, or `n` to skip it
7. Repeat step 5-6 until done

**Why this is great**: Unlike `:%s`, you see each occurrence in context and can decide whether to replace it. Unlike `:%s/old/new/gc`, you stay in normal mode between replacements and can scroll around.

---

# 11. File Explorer (`nvim-tree`)

Plugin: nvim-tree.lua. A sidebar file tree. It loads on the first `<Space>s` or the first `:NvimTreeToggle`, `:NvimTreeOpen`, `:NvimTreeFocus`, `:NvimTreeFindFile` or `:NvimTreeFindFileToggle`; `nvim <dir>` and the dashboard entry open it too.

| Keymap | Context | Description |
| --- | --- | --- |
| `<Space>s` | global | Toggle the file explorer on/off |
| `<Enter>` | in tree | Open file (cursor moves to file) / expand directory <!-- CHECK-USER: with 2+ editor windows open, does <Enter> in the tree ask for a window letter (window picker)? --> |
| `<Tab>` | in tree | Open file but **keep cursor in the tree** (great for opening multiple files) |
| `<BS>` | in tree | Close (collapse) the directory under the cursor; on a file it closes its parent directory |
| `a` | in tree | Create a new file. Type the name and press Enter. Add `/` at the end for a directory. |
| `d` | in tree | Delete file/directory (asks for confirmation) |
| `r` | in tree | Rename file/directory |
| `c` | in tree | Copy file to clipboard |
| `x` | in tree | Cut file to clipboard |
| `p` | in tree | Paste from clipboard |
| `q` | in tree | Close the file explorer |
| `D` | in tree | Move file/directory to the trash (asks for confirmation; needs `trash`) |
| `g?` | in tree | Show the help with every key |
| `<Ctrl-v>` / `<Ctrl-x>` / `<Ctrl-t>` | in tree | Open in a vertical split / horizontal split / new tab |
| `-` / `<Ctrl-]>` | in tree | Make the parent / the folder under the cursor the root |
| `H` / `I` | in tree | Toggle dotfiles / git-ignored files |
| `f` / `F` | in tree | Live filter: start / clear |
| `R` | in tree | Refresh |
| `y` / `Y` / `gy` | in tree | Copy the name / relative path / absolute path |
| `]c` / `[c`, `]e` / `[e` | in tree | Next / previous git item, diagnostic item |
| `E` / `W` | in tree | Expand all / collapse all |

`nvim <dir>` opens the tree on that directory and makes it the working directory.

**Moving between tree and code**: Use `<Ctrl-w>h` / `<Ctrl-w>l` or `<Left>` / `<Right>` arrow keys.

---

# 12. Fuzzy Finding & Project-Wide Search (`fzf-lua`)

Plugin: **fzf-lua**. A powerful popup interface that connects to FZF (a command-line fuzzy finder). It lets you search file names, search text inside files, browse buffers, and more. The popup opens centered on screen at 70% height.

## Keymaps

| Keymap | Description |
| --- | --- |
| `<Space>ff` | **Find files**: search file names in the project |
| `<Space>fg` | **Live grep**: search text content across all files in the project |
| `<Space>fh` | Search Neovim help tags |
| `<Space>ft` | Search tags (functions, classes) in the current buffer (needs `ctags`; the Nix nvim wrapper provides universal-ctags) |
| `<Space>fb` | Search currently open buffers |
| `<Space>fr` | Search recently opened files |
| `<Space>gbl` | Fuzzy-search git branches (`<Enter>` checks the branch out) |

`<Space>ff` has no preview window and shows git status icons next to modified/untracked files; `.gitignore` is respected.

## Inside the FZF Popup

| Key | What it does |
| --- | --- |
| Type text | Filters results in real-time |
| `<Enter>` | Open the selected result |
| `<Esc>` | Cancel and close the popup |
| `<Ctrl-j>` / `<Ctrl-k>` | Move down / up in the results list |
| `<Ctrl-n>` / `<Ctrl-p>` | Move down / up (alternative keys) |

## `<Space>fg` -- Live Grep (Project-Wide Text Search) In Depth

This is one of the most important keymaps for developers. It searches inside every file in your project directory using **ripgrep** (`rg`) under the hood.

### What It Does

1. Press `<Space>fg`
2. A popup appears with a search prompt
3. As you type, ripgrep searches **all files** in the project folder and shows matching lines in real-time
4. Results show: file path, line number, and the matching line
5. Press `<Enter>` to jump directly to that file and line

### Plain Text Search

Just type normal text. For example, typing `getUserById` finds every file and line containing that string.

### Regex Search

Live grep supports **full regex** (ripgrep regex syntax). You don't need to learn all of regex, but here are the most useful patterns:

| Pattern you type | What it finds | Example matches |
| --- | --- | --- |
| `TODO` | Literal text `TODO` | `// TODO: fix this` |
| `TODO\|FIXME` | `TODO` OR `FIXME` | Both `// TODO` and `// FIXME` |
| `def \w+\(` | Python function definitions | `def process_data(`, `def main(` |
| `class \w+` | Class declarations | `class UserService`, `class App` |
| `import.*from` | ES6-style imports | `import { foo } from 'bar'` |
| `console\.log` | `console.log` (dot is escaped) | `console.log("debug")` |
| `function\s+\w+` | JavaScript function declarations | `function handleClick` |
| `\berror\b` | Whole word `error` only | `error` but not `errors` or `errorHandler` |
| `https?://` | URLs (http or https) | `https://example.com` |
| `v[0-9]+\.[0-9]+` | Version strings | `v1.0`, `v2.13` |

### Use Cases for Live Grep

| Scenario | What to search |
| --- | --- |
| Find where a function is called | Type the function name |
| Find all TODOs | Type `TODO` |
| Find a specific error message | Type part of the error string |
| Find all API endpoints | Type `@GetMapping` (Java) or `app.get(` (Express) or `@app.route` (Flask) |
| Find all imports of a module | Type `import.*moduleName` (regex) |
| Find environment variable usage | Type `process.env` or `os.environ` |
| Find hardcoded strings | Type the string in quotes |

## `<Space>ff` -- Find Files (File Name Search)

Searches **file names** (not content). Useful when you know the file you want but not the exact path.

- Type `userserv` to find `UserService.java` (fuzzy matching)
- Type `config.py` to find configuration files
- Type `.env` to find environment files (only if they are not git-ignored: `.gitignore` is respected; a `.ignore` file containing `!.env` makes them visible)
- Type `test` to see all test files

## The Difference Between Search Methods

| Method | Keymap | What it searches | Best for |
| --- | --- | --- | --- |
| **Live grep** | `<Space>fg` | Text **inside** files across the entire project | Finding where code/text is used |
| **Find files** | `<Space>ff` | **File names** in the project | Opening a file by name |
| **Buffer search** | `<Space>fb` | Names of **currently open** files | Switching between open files |
| **Recent files** | `<Space>fr` | Files you **recently edited** | Returning to a file you had open earlier |
| **Buffer tags** | `<Space>ft` | Functions/classes in **current file** (needs `ctags`) | Jumping to a function in the current file |
| **In-file search** | `/pattern` | Text in **current file only** | Finding something in the file you're editing |
| **Word under cursor** | `*` | Current word in **current file** | Quick highlight and jump to next occurrence |

---

# 13. LSP: Language Server Protocol

Plugin: nvim-lspconfig (default server definitions; Neovim's builtin `vim.lsp` does the rest). Provides IDE features. The keys below work per buffer according to what the attached servers support: if no attached server supports it, `K` and `gd` fall back to Vim's builtin versions and `<Space>rn` / `<Space>ca` show one warning.

### Configured Language Servers

| Server | Language | Program(s) that must be on PATH |
| --- | --- | --- |
| `pyright` + `ruff` | Python | `pyright-langserver`, `ruff` |
| `lua_ls` | Lua | `lua-language-server` |
| `bashls` | Bash | `bash-language-server` |
| `yamlls` | YAML | `yaml-language-server` |
| `marksman` | Markdown | `marksman` |
| `nixd` | Nix | `nixd` |
| `jdtls` | Java (via nvim-java) | `java` (Java devShell) |
| `clangd` | C/C++ | `clangd` (c-cpp devShell) |
| `ltex_plus` | Grammar and spelling (LanguageTool) for markdown, tex, typst, gitcommit, text | `ltex-ls-plus` |
| `typos_lsp` | Typos in identifiers and comments, every real file | `typos-lsp` |
| `tinymist` | Typst | `tinymist` |
| `texlab` | LaTeX | `texlab` (LaTeX devShell) |
| `rust_analyzer` | Rust | `rust-analyzer` AND `cargo` |
| `gopls` | Go | `gopls` AND `go` |
| `hls` | Haskell | `haskell-language-server-wrapper` |
| `sourcekit` | Swift, Objective-C | `sourcekit-lsp` |
| `ts_ls` | JavaScript / TypeScript | `typescript-language-server` (the project's `node_modules/.bin` copy is preferred) |
| `phpactor` | PHP | `phpactor` (php devShell) |
| `r_language_server` | R, Rmd, quarto | `R` plus the R package `languageserver`: the first R file runs one silent background check; restart nvim after installing the package |

A server is enabled only when ALL its programs are on PATH; otherwise it is skipped silently (no warning when you open a file of that language outside its devShell). The programs come from the Nix system or the language's devShell; nothing is downloaded by Neovim. `:LspStart <name>` tells you which program is missing.

### LSP Keymaps

| Keymap | Description |
| --- | --- |
| `gd` | **Go to definition**: jump to where the symbol is defined (several different places open the location list) |
| `K` | **Hover**: show documentation in a floating window |
| `<Space>rn` | **Rename**: rename the symbol everywhere it's used |
| `<Space>ca` | **Code action**: show available fixes/refactors |
| `<Space>fm` | **Format** the file on demand (LSP formatter, async). Lua: stylua. Markdown: prettier. Python and JSON have `<Space>f` (black / `:JSONFormat`) |

### Built-in Neovim LSP and Diagnostic Keys

Neovim's own LSP keys also work next to the custom ones (in every buffer with a server that supports them):

| Keymap | Mode | Description |
| --- | --- | --- |
| `grn` | n | Rename (same as `<Space>rn`) |
| `gra` | n, x | Code action (same as `<Space>ca`) |
| `grr` | n | References (quickfix list) |
| `gri` | n | Implementation |
| `grt` | n | Type definition |
| `grx` | n | Run the code lens of the line |
| `gO` | n | Document symbols (outline in the location list) |
| `<Ctrl-s>` | i, s | Signature help |
| `]d` / `[d` | n | Next / previous diagnostic of any severity (`<Space>de` / `<Space>dE` jump to errors only) |
| `]D` / `[D` | n | Last / first diagnostic in the buffer |
| `<Ctrl-w>d` | n | Show the diagnostics under the cursor |

### LSP Commands

| Command | What it does |
| --- | --- |
| `:LspInfo` | LSP status (same as `:checkhealth vim.lsp`) |
| `:LspAttached` | Small popup with the servers attached to this buffer (`q` / `<Esc>` closes; also opens when you click the LSP name in the statusline; with no server attached it only shows a notification) |
| `:LspLog` | Open the LSP log file |
| `:LspRestart [name...]` | Restart the servers of this buffer, or the named ones |
| `:LspStop [name...]` | Stop them |
| `:LspStart [name...]` | Start the enabled servers of this buffer that are not running, or the named ones |
| `:LspInlayHints enable` / `disable` | Switch inlay hints on / off globally (off by default) |

### Glance: Peek Without Jumping

Plugin: glance.nvim. Preview definitions/references in a popup, without leaving your current file.

| Keymap | Description |
| --- | --- |
| `<Space>gd` | Peek at definitions |
| `<Space>gr` | Peek at all references |
| `<Space>gi` | Peek at implementations |

### Diagnostics (Errors, Warnings)

Nerd Font signs in the gutter: 󰅚 (error), 󰀪 (warning), 󰋽 (info), 󰌶 (hint). No underline and no inline text: the message appears in a floating window when the cursor rests on the line (it closes when you move, leave the window or enter Insert mode).

| Keymap | Description |
| --- | --- |
| `<Space>db` | Telescope picker with the diagnostics of the current file |
| `<Space>dw` | Toggle the Trouble diagnostics list (all open buffers) |
| `<Space>de` | Jump to next error |
| `<Space>dE` | Jump to previous error |
| `<Space>dd` | Show diagnostic detail in floating window |
| `<Space>dt` | Toggle diagnostics on/off |
| `<Space>qw` | Send the diagnostics of all open buffers to the quickfix list |
| `<Space>qb` | Send buffer diagnostics to quickfix list |

---

# 14. Autocompletion (`nvim-cmp`)

Plugin: nvim-cmp. Sources: LSP, UltiSnips snippets, file paths, buffer words.

| Keymap | Description |
| --- | --- |
| `<Tab>` | If menu is open: select next item. Otherwise: normal tab. |
| `<CR>` (Enter) | Confirm an item you picked with `<Tab>` / `<Ctrl-n>`; if nothing is selected it is a plain newline |
| `<Ctrl-e>` | Dismiss / close the completion menu |
| `<Esc>` | Close the completion menu |
| `<Ctrl-d>` | Scroll documentation popup up |
| `<Ctrl-f>` | Scroll documentation popup down |
| `<Ctrl-n>` / `<Ctrl-p>` | Open the menu / select the next / previous item (inserts it) |
| `<Ctrl-y>` | Confirm the selected item |
| `<Down>` / `<Up>` | Select the next / previous item without inserting it |
| `<Tab>` / `<S-Tab>` | In the `:` and `/` command line: open / move through the completion menu |

Completion labels are coloured like code (colorful-menu.nvim); match and kind colours follow the active colorscheme.

---

# 15. Snippets (`UltiSnips`)

Plugin: UltiSnips + vim-snippets. Custom snippets in `my_snippets/` directory.

| Keymap | Description |
| --- | --- |
| `<Ctrl-j>` | Expand snippet / jump to next placeholder |
| `<Ctrl-k>` | Jump to previous placeholder |

Available snippet files: `all`, `cpp`, `java`, `markdown`, `nix`, `python`, `snippets`, `tex`, `vim`

### Java Snippets

| Trigger | Expansion |
| --- | --- |
| `fdijscanner` | Java Scanner input template |
| `jarr` / `jarrlit` | Array / array with literal values |
| `jdict` / `jdictfull` | HashMap / HashMap with import |
| `jfor` / `jforeach` | For loop / enhanced for loop |
| `jwhile` / `jdowhile` | While / do-while loop |
| `jif` / `jifelse` / `jifelif` | If / if-else / if-else if-else |
| `jswitchtraditional` / `jswitchmulti` / `jswitcharrow` / `jswitcharrowmulti` / `jswitchyield` / `jswitchyieldblock` | Switch variants |
| `jtrycatch` / `jtryfinally` | Try-catch / try-catch-finally |
| `jwhilescannerbreak` | While loop with Scanner and break condition |

### Other Snippets

| File | Triggers |
| --- | --- |
| all | `arw` (right arrow), `ltx` (LaTeX symbol) |
| cpp | `bare` (barebone template), `icd` (`#include`), `incvec` `incmap` `incset` `incqueue` `incstr` `incstack` (include that header), `vec` `map` `umap` `set` `uset` `queue` `stack` (std containers), `cout`, `plist` (print vector), `pmat` (print list of lists), `pqueue` (print queue), `random` (random list), `sol` (solution), `for`, `if`, `ifelse` |
| markdown | `meta` (YAML front matter), `h1` ... `h6` (header), `link`, `rlink` (reference link), `img`, `font`, `more`, `detail` (clickable details), `k1` / `kbd`, `k2`, `k3` (keyboard keys), `info` `warn` `error` `success` (boxes), `td` (too long, did not read), `yh` (corner quotes) |
| nix | `homepackages`, `systempackages`, `excludepackages`, `delibheaderhome`, `delibheadersystem`, `delibheaderhomealways`, `delibheadersystemalways`, `let`, `mkshell`, `mkderiv`, `flake`, `homefile`, `fetchgit`, `systemd` |
| python | `print`, `impa` (import as), `main` (main boilerplate), `sol` (solution) |
| snippets | `snip` (UltiSnips snippet definition) |
| tex | `use` (`\usepackage{}`), `eqa` (equation environment) |
| vim | `fun` (function), `aug` (augroup) |

---

# 16. Code Commenting

## vim-commentary (Plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `gcc` | n | Toggle comment on current line |
| `gc` + motion | n | Toggle comment on a motion (e.g., `gcip` comments a paragraph) |
| `gc` | v | Toggle comment on selected lines |
| `gc` | o | Comment text object: `dgc` deletes the comment block under the cursor, `ygc` yanks it |
| `gcu` | n | Uncomment the adjacent commented lines |
| `:[range]Commentary` | cmd | Toggle comment on a range (`:2,3Commentary`) |

vim-commentary loads right after the first screen (VeryLazy), so these commands and the `gc` text object exist from then on.

## Smart Commenting (Custom)

String-aware, multi-line-capable comment add/remove (`lua/smart_comment/`).

| Keymap | Mode | Description |
| --- | --- | --- |
| `gcs` + motion | n | Comment the rows a motion covers (`gcsip`, `gcs3j`, `gcsG`); `.` repeats |
| `{count}gcs` | n | Comment count rows from the cursor down (`200gcs`) |
| `gcss` | n | Comment current line(s) (`3gcss` = 3 rows); `.` repeats |
| `gcs` | x | Comment the selected rows |
| `gcr` + motion | n | Uncomment the rows a motion covers (`gcrip`, `gcr200j`); `.` repeats |
| `{count}gcr` | n | Uncomment count rows from the cursor down (`200gcr`) |
| `gcrr` | n | Uncomment current line(s) (`3gcrr` = 3 rows); `.` repeats |
| `gcr` | x | Uncomment the selected rows |

Rule: `gcs` adds one marker per row and never nests (redundant markers already
in the rows are removed); `gcr` removes every marker level (`# # a` -> `a`).
Only real comment markers of the file type count (a `#` in a colour, URL or
one-line string is not a comment).

With a motion, put the count AFTER `gcs` / `gcr` (`gcs3j`, `gcr200j`): a count
before them always means rows, so `3gcsip` comments 3 rows and then `ip` runs as
normal keys. If you pause after `gcs` longer than 'timeoutlen', a following `s`
no longer makes `gcss` (gcs is then waiting for a motion and `s` cancels it);
`gcsip` typed in one go is not affected.

`gcs` / `gcr` always change WHOLE rows (a charwise motion such as `gcse` changes
every row it touches); the cursor stays on its text row; `.` repeats with the
same motion, count or number of Visual rows. In a non-modifiable buffer they
show one warning. Avoid `gcsgcs` (the second `gc` is the comment text
object).

Fully supported languages: asm, bash, c, cmake, conf, cpp, cs, css,
dockerfile, elixir, fish, gitconfig, go, haskell, hcl, html, i3config, java,
javascript, julia, kitty, kotlin, lisp (Emacs Lisp / Common Lisp), lua, make,
markdown, nix, perl, php, ps1 (PowerShell), python, r, ruby, rust, scala, sh,
sql, swift, terraform, tex (LaTeX), tmux, toml, typescript, typst, vim, xml,
yaml, zig, zsh. In gitconfig an UNQUOTED `#ff0000` is a comment for git
itself, so `gcr` removes it: quote colours there.

Other filetypes use their 'commentstring': a marker counts only as the first
non-blank character of the row.

---

# 17. Surrounding Pairs (`vim-sandwich` + `nvim-autopairs`)

See [Section 6: Working with Parentheses, Quotes, and Brackets](#6-working-with-parentheses-quotes-and-brackets) for the complete guide.

Quick reference:

| Keymap | Description |
| --- | --- |
| `saiw"` | Add `"` around word |
| `sd"` | Delete surrounding `"` |
| `sr"'` | Replace `"` with `'` |
| `%` | Jump to matching bracket |

---

# 18. Code Folding (`nvim-ufo`)

Plugin: nvim-ufo. Folds code blocks using the LSP folding ranges, falling back to indentation.

| Keymap | Description |
| --- | --- |
| `za` | Toggle fold at cursor |
| `zA` | Toggle all folds under cursor recursively |
| `zc` / `zo` | Close / open fold at cursor |
| `zC` / `zO` | Close / open all folds recursively |
| `zR` | Open **all** folds in the file |
| `zM` | Close **all** folds in the file |
| `zr` | Open one more fold level (`2zr` = two levels; counted from the folds you see, so it works right after `zM`; in a buffer without ufo folds: one warning) |
| `zm` | Close one more fold level (accepts a count) |
| `<Space>K` | Preview folded lines in a popup |
| `zi` | Toggle folding feature on/off |

---

# 19. Code Running

Custom function in `lua/mappings.lua`. Opens the output in a vertical split terminal on the left. If the file has no name (the buffer was never saved), the filetype has no runner, or the needed program is not on PATH, you get one warning (naming the devShell to start nvim in) instead of a terminal. A named buffer with unsaved changes runs the version on disk, so save first (`:w`).

| Keymap | Description |
| --- | --- |
| `<Space>rr` | Run current file (auto-detects language) |

Supported: Python, Java, C, C++, C#, JavaScript, TypeScript, Go, Rust, Bash, Lua, Ruby, PHP. Special cases: Java with jdtls attached runs `:JavaRunnerRunMain` (no terminal); Rust inside a cargo project runs `cargo run`; C# with a `.csproj` runs `dotnet run --project`; Go runs `go run .` for the whole package.

After running, the terminal output appears in a split. See [Terminal Integration](#8-terminal-integration) for how to navigate to/from it and close it.

### Filetype-Specific

| Keymap | Filetype | Description |
| --- | --- | --- |
| `<F9>` | Python | Run with `python -u` via AsyncRun (`uv run python -u` inside a uv project) |
| `<F9>` | C++ | Compile (clang++, else g++, C++20) and run in a split below; only mapped when a compiler is on PATH |
| `<F9>` | LaTeX | Compile with vimtex |
| `<F9>` | Lua | Run the file inside Neovim (`:luafile %`) |
| `<F9>` | Vim script | Source the file (`:source %`) |

---

# 20. Git Integration

## vim-fugitive (Plugin)

The fugitive keys (and the gitlinker keys below) exist only inside a git repository: nvim started in one, or a file of one opened. Outside a repository these keys are not mapped: `<Space>` just moves the cursor one column right and the next keys run as their normal Vim/plugin meaning (`<Space>gs` becomes `l` plus vim-swap's `gs`). `<Space>gbl` works everywhere (fzf-lua).

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>gs` | n | Git status window |
| `<Space>gw` | n | Git add current file |
| `<Space>gc` | n | Git commit |
| `<Space>gpl` | n | Git pull |
| `<Space>gpu` | n | Git push (opens terminal split) |
| `<Space>gb` | x | Git blame selected lines |
| `<Space>gbn` | n | Create new branch (prompts for name) |
| `<Space>gbd` | n | Puts `:Git branch -D ` on the command line: type the branch name and press Enter (force delete) |
| `<Space>gf` | n | Puts `:Git fetch ` on the command line (add arguments, then Enter) |
| `<Space>gbl` | n | Fuzzy-search git branches and check one out (fzf-lua) |

Clicking the branch name in the statusline also opens a branch picker (`git checkout` of the chosen local or remote branch).

## gitsigns.nvim (Plugin)

Shows `+` `~` `_` signs in the gutter for added/changed/deleted lines.

| Keymap | Description |
| --- | --- |
| `]c` | Jump to next git change (hunk) |
| `[c` | Jump to previous git change |
| `<Space>hp` | Preview the hunk in a floating window |
| `<Space>hb` | Show git blame for current line |

## gitlinker.nvim (Plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>gl` | n, x | Copy permalink for current line(s) |
| `<Space>gbr` | n | Open repository in browser |

## Other Git Tools

| Plugin | Command / Trigger | Description |
| --- | --- | --- |
| neogit | `:Neogit` | Full git UI (magit-like; loads on the first `:Neogit*` command, in any directory; also `:NeogitCommit`, `:NeogitLogCurrent`, `:NeogitResetState`) |
| diffview.nvim | `:DiffviewOpen`, `:DiffviewFileHistory` (`:DiffviewClose` once a view was opened) | Side-by-side diff viewer and 3-way merge tool; file history panel |
| vim-flog | `:Flog` | Visual git log graph |
| diffs.nvim | `:Diff` (and automatic) | Unified diff of the current file against git; also colours the diffs shown by fugitive, neogit and gitsigns, and conflict markers |
| codediff.nvim | `:CodeDiff` | VSCode-style side-by-side diff (downloads a small native library on first use) |

## Resolving Merge Conflicts (diffview.nvim)

During a merge, `:DiffviewOpen` opens the 3-way merge tool. Inside a diffview view:

| Keymap | Description |
| --- | --- |
| `<Space>gCo` / `<Space>gCt` | Choose OURS / THEIRS for the conflict |
| `<Space>gCb` / `<Space>gCa` | Choose BASE / BOTH |
| `]C` / `[C` | Next / previous conflict (capital C; `]c` / `[c` stay the gitsigns hunk keys) |

`<Space>cb` and `<Space>ca` keep their normal meaning inside diffview. fugitive's `:Gvdiffsplit!` is the other way to resolve a conflict.

---

# 21. Treesitter & Text Objects

## Treesitter (Plugin)

Provides tree-sitter syntax highlighting (started automatically per filetype when a parser exists). On Nix systems the parsers come from the nix store and nothing is installed by Neovim; on other systems these parsers are installed automatically: cpp, diff, dockerfile, git_config, git_rebase, gitcommit, html, json, lua, python, toml, vim.

## targets.vim (Plugin)

Adds many additional text objects for quotes, brackets, arguments, separators. Works automatically with `d`, `c`, `y`, `v`. If the cursor is not inside the pair, `i(`, `i"` and friends look forward on the line.

## vim-matchup (Plugin)

Enhanced `%` matching for language keywords (`if`/`else`/`end`, `do`/`while`, etc.). Shows offscreen match in popup. Also: `g%` (backwards `%`), `[%` / `]%` (start / end of the enclosing pair), `z%` (into the next pair), text objects `i%` / `a%`. `g%` and `[%` / `]%` were tested (`g%` from `if` goes backwards to `end`). <!-- CHECK-USER: `z%` was not confirmed: from `if` it moved just inside the keyword; what does it do for you? -->

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

# 24. Yank History (`yanky.nvim`)

| Keymap | Mode | Description |
| --- | --- | --- |
| `p` / `P` | n, x | Paste after / before (with 300ms highlight) |
| `[y` | n | After pasting, cycle to previous yank entry |
| `]y` | n | After pasting, cycle to next yank entry |

Command: `:YankyRingHistory` to browse all yank history. yanky.nvim loads right after the first screen (VeryLazy), so the yank history contains every yank of the session. In Visual mode `p` is yanky's: it overwrites the unnamed register with the replaced text (there is no separate keep-register map any more).

---

# 25. Undo History

| Keymap | Description |
| --- | --- |
| `<Space>u` | Toggle Neovim's builtin undo tree (`nvim.undotree`) in a 30-column panel on the far left |

Inside the panel there are no extra keys: moving the cursor onto an entry switches the buffer to that undo state (documented in `:h undotree.open()`). Close it with `<Space>u` again or `:q`.

---

# 26. Quickfix & Location List

## Commands

| Command | Description |
| --- | --- |
| `:copen` / `:cclose` | Open / close quickfix window |
| `:cnext` / `:cprev` | Next / previous item |
| `:cfirst` / `:clast` | First / last item |
| `:cc [nr]` | Jump to specific entry |
| `:cdo {cmd}` | Run command for each entry |
| `:colder` / `:cnewer` | Navigate quickfix history |
| `:lopen` / `:lclose` | Location list (per-window) |
| `\x` | Close quickfix and location list windows |

## Inside the Quickfix Window (nvim-bqf, quicker.nvim)

quicker.nvim formats the list (grouped by file, file-name column at most 40 characters or half the screen); the list cannot be edited as a buffer. nvim-bqf adds these keys inside the quickfix window (the preview does not start by itself):

| Key | Description |
| --- | --- |
| `p` / `P` | Toggle the preview of the item / toggle auto-preview while moving |
| `zp` | Toggle the preview between normal and maximum size |
| `<Ctrl-f>` / `<Ctrl-b>` | Scroll the preview down / up |
| `<Tab>` / `<S-Tab>` | Mark the item and move down / up; `z<Tab>` clears the marks |
| `zn` / `zN` | New list from the marked / unmarked items |
| `zf` | Fuzzy filter the list (fzf) |
| `<` / `>` | Go to the older / newer quickfix list |
| `o` / `O` | Open the item and close the quickfix window |
| `t` / `T` | Open in a new tab (`T` stays in the quickfix window) |
| `<Ctrl-x>` / `<Ctrl-v>` / `<Ctrl-t>` | Open in a horizontal split / vertical split / new tab |

## Trouble (Plugin)

| Keymap / Command | Description |
| --- | --- |
| `:Trouble` | Open Trouble diagnostics viewer |
| `<Space>dw` | Workspace diagnostics via Trouble |

---

# 27. Markdown Support

## Preview

| Keymap | Description |
| --- | --- |
| `<Alt-m>` | Toggle markdown preview in browser (markdown buffers only) |

## Footnotes

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>mf` | n | Add footnote (markdown buffers only; elsewhere one warning) |
| `<Space>mr` | n | Return from footnote (markdown buffers only) |
| `^^` | n, i | Insert footnote number (markdown files only) |
| `@@` | n, i | Return from footnote (markdown files only; it shadows the macro replay `@@` in Markdown buffers) |

## Text Objects & Operators (Markdown Only)

| Keymap | Description |
| --- | --- |
| `vic` / `vac` | Select inside / around code block |
| `+` | Convert lines to unordered list (operator: `+ip` for paragraph) |
| `<Space>mb{motion}` (or `<Space>mb` on a Visual selection) | Add a hard line break (a trailing `\`) to each line, e.g. `<Space>mbip`; blank lines and lines already ending in `\` are skipped |
| `:AddRef <label> <url>` | Add reference link at end of buffer |

## Other Markdown Plugins

- **render-markdown.nvim**: In-editor rendering (pauses in insert mode). Max file: 1.5MB.
- **tabular**: Table alignment. Command: `:Tabularize`
- **ltex-ls-plus (LSP)**: grammar and spell checking (LanguageTool) for markdown, tex, typst, gitcommit and text files, when `ltex-ls-plus` is installed. Problems are diagnostics: `]d` / `[d`, `<Space>dd`; fixes via `<Space>ca`.
- **marksman (LSP)**: link and heading navigation, completion, symbols.

---

# 28. LaTeX and Typst Support

## LaTeX (`vimtex`)

Only available if `latex` is installed (vimtex also needs `latexmk` to compile).

| Keymap | Description |
| --- | --- |
| `<F9>` | Start / stop continuous compilation |
| `\ll` | Start / stop continuous compilation (same as `<F9>`) |
| `\lv` | View PDF |

The texlab language server adds diagnostics, hover, symbols and rename when `texlab` is on PATH (LaTeX devShell). Auto-save never saves LaTeX files.

## Typst

| Keymap | Description |
| --- | --- |
| `<Space>tw` | Typst buffers: `:TypstWatch`, recompile on save and open the PDF |

Needs the `typst` program (typst devShell): without it `<Space>tw` shows one warning and the Typst plugin does not load. Errors go to the quickfix list. The PDF viewer is `$TYPST_PDF_VIEWER` if set, else `zathura` if installed. LSP: `tinymist`. Typst buffers use `textwidth=100` and wrap. Auto-save never saves Typst files.

---

# 29. Registers & Macros

## Registers

| Keymap | Description |
| --- | --- |
| `"3y` | Yank to register 3 |
| `"3p` | Paste from register 3 |
| `"*y` / `"+y` | Yank to system clipboard |
| `:reg` | View all registers |

**Note**: When a clipboard tool (wl-clipboard, xclip, ...) is installed, `clipboard` is `unnamedplus`, so `y`/`p` already use the system clipboard by default.

## Macros

`Q` is an extra key for recording: `Qa` and `qa` both start recording into register `a` (tested: plain `q` works too, `Q` is mapped to `q`).

| Keymap | Description |
| --- | --- |
| `Qh` | Start recording macro to register `h` |
| `q` | Stop recording |
| `@h` | Play macro from register `h` |
| `5@h` | Play macro 5 times |
| `@@` | Replay the last played macro |

---

# 30. Working with Directories

| Keymap / Command | Description |
| --- | --- |
| `<Space>cd` | Change working directory to current file's directory (window-local) |
| `:cd <path>` | Change directory globally |
| `:lcd <path>` | Change directory for current window only |
| `:tcd <path>` | Change directory for current tab |
| `:pwd` | Print current working directory |
| `:Z {keywords}` (or `:z {keywords}`) | `cd` to the best zoxide match (e.g. `:z nix nixos`) and print `cd <dir>`; without arguments it opens the fuzzy zoxide directory picker; without zoxide installed one warning |

### Path Modifiers (for use in commands)

| Modifier | Meaning | Example |
| --- | --- | --- |
| `%` | Current file path | `/home/user/project/src/main.lua` |
| `%:h` | Directory of current file | `/home/user/project/src` |
| `%:t` | Filename only | `main.lua` |
| `%:p` | Full absolute path | `/home/user/project/src/main.lua` |

---

# 31. Spell Checking

Languages: English, Italian, German, French.

| Keymap | Description |
| --- | --- |
| `<Space>cz` | Toggle spell checking on/off |
| `]s` / `[s` | Next / previous misspelled word |
| `z=` | Show spelling suggestions (up to 9) |
| `zg` | Add the word to the English word list (`spell/en.utf-8.add`) |
| `2zg` / `3zg` / `4zg` | Add the word to the Italian / German / French list |
| `zw` | Mark word as wrong (same counts) |

`spellfile` has one word list per language, in the order of `spelllang` (en, it, de, fr): `zg` adds to the first, a count picks another. The lists are `spell/*.utf-8.add` inside the config, which is tracked in a PUBLIC repository: `spell/README.md` says these words are public, so review new words before committing. At startup Neovim silently recompiles any list whose compiled `.add.spl` file is missing or older, so the words of the tracked lists are accepted on a fresh checkout.

Besides the builtin spell checker two language servers report problems as diagnostics: `ltex_plus` (grammar and spelling in prose files) and `typos_lsp` (typos in identifiers and comments of source files). The statusline shows `[SPELL]` while spell checking is on.

---

# 32. Statusline (`lualine.nvim`)

| Section | Position | Contents |
| --- | --- | --- |
| A | Leftmost | Filename + a lock icon (Nerd Font) when the file is read-only |
| B | Left | Git branch (click: pick a branch and check it out), `↑[n]` / `↓[n]` commits ahead / behind the upstream (the upstream is refreshed with a silent `git fetch origin` at most once a minute; long branch names are cut at 20 characters), diff stats (+~-), diagnostic counts (same icons as the sign column), Python virtualenv (Python buffers only) |
| C | Center-left | Pending command (e.g. `2d`), spell indicator (`[SPELL]`) |
| X | Center-right | Active LSP (gear icon; ` (+N)` = other attached clients; click: popup with the attached clients), `[N]trailing` (first line with trailing whitespace), `MI:N` (mixed tabs and spaces) |
| Y | Right | Encoding (only when not UTF-8) and file format (only when not unix), both in red; `[CN]` input-method badge on macOS |
| Z | Rightmost | Progress through the file (%). The line:column position is shown only in inactive windows |

---

# 33. UI Features

| Feature | Description |
| --- | --- |
| **which-key.nvim** | Press `<Space>` and wait: a popup shows all available leader keybindings |
| **Dashboard** | Start screen for a bare `nvim` (no file, directory or stdin); menu and keys in "Dashboard (Start Screen)" below |
| **nvim-notify** | Animated notification popups (fade + slide, 1500ms) |
| **Colorschemes** | On Nix systems the base16 theme named by `NVIM_BASE16_THEME` (fallback Catppuccin Mocha); on other systems one of 19 themes chosen at random at each start. UI colours (yank flash, hop keys, notifications, float borders) follow the active theme |
| **dropbar.nvim** | Breadcrumb bar at top showing file > class > function |
| **nvim-colorizer** | Color codes (hex, rgb) are highlighted with their actual color |
| **mini.indentscope** | Visual `▏` guide for current indent scope (loads right after the first screen; `ii`/`ai` exist from then on) |
| **fidget.nvim** | LSP progress messages in bottom-right corner |
| **nvim-lightbulb** | Lightbulb icon when code actions are available |
| **vim-illuminate** | Highlights the other uses of the word under the cursor (`<Alt-n>` / `<Alt-p>` jump between them) |
| **vimade** | Dims inactive windows |
| **Borders** | Every floating window and the completion menu have a single-line border |

## Dashboard (Start Screen)

The dashboard opens for a bare `nvim` (no file, no directory, no stdin) or with `:Dashboard`. `<Enter>` runs the item under the cursor. These single-letter keys work only inside the dashboard:

| Key | Item |
| --- | --- |
| `r` | Restore session (this folder) |
| `L` | Restore last session |
| `o` | Recent files here (only files under the current directory) |
| `d` | Recent directories (zoxide picker; the item is shown only when `zoxide` is installed) |
| `m` | Search keymaps |
| `u` | Open this user guide in a new tab |
| `e` | New file |
| `q` | Quit Neovim |

The other items show their normal key: Find File `<Space>ff`, Recently opened files `<Space>fr`, Project grep `<Space>fg`, Open tree view `<Space>s`, Search help `<Space>fh`, Claude Code `<Space>cc`, Open Nvim config `<Space>ev`. With nothing saved, `r` / `L` show one warning ("no saved session for this folder" / "no saved session"). Sessions are never restored automatically.

| Keymap | Description |
| --- | --- |
| `\h` | Open the dashboard in the current window (the previous buffer stays open in the background; inside the dashboard it only says "already in the dashboard") |
| `\H` | Close the dashboard and return to the previous buffer (the dashboard buffer is deleted so it does not pile up); outside the dashboard it only warns "not in the dashboard", with no previous buffer "no previous buffer to resume" |

`:Dashboard` does the same as `\h`. To close the current buffer and get the dashboard instead: `:Dashboard | bdelete #` (a buffer with unsaved changes refuses with E89). `\d` deletes the buffer but shows the previous one, not the dashboard.

---

# 34. Custom Commands

| Command | Description |
| --- | --- |
| `:CopyPath nameonly` | Copy filename to clipboard |
| `:CopyPath relative` | Copy `<project-root>/path/to/file` (root = nearest `.git` or `pyproject.toml`; a warning when there is none) |
| `:CopyPath absolute` | Copy absolute path |
| `:JSONFormat` | Format JSON (whole file or visual range) |
| `:Redir <cmd>` | Run the command and show its output in a new tab (scratch buffer, wiped when closed) |
| `:Edit <pattern>...` | Open every file matching the glob patterns (`:Edit src/*.lua`); `:edit` typed as the first word expands to `:Edit` |
| `:Datetime [format]` | Show date and time (optional format argument) |
| `:ToPDF` | Convert markdown to PDF (requires pandoc) |
| `:Z {keywords}` | zoxide jump (see Working with Directories) |
| `:TermHL` | Show the current buffer (e.g. a log with ANSI colour codes) rendered with its colours in a read-only terminal buffer |
| `:LogAutocmds` | Toggle logging of all autocommand events to `~/.local/state/nvim/log-autocmds.log` (the file is emptied each time logging starts) |
| `:StripTrailingWhitespace` | Remove trailing whitespace (same as `<Space><Space>`) |
| `:Notifications` | Show the notification history (nvim-notify) |
| `:Inspect` / `:InspectTree` | Show the highlight groups / the Treesitter tree at the cursor |

### Plugin Manager Shortcuts

Type these in command mode, then press space (or Enter) to expand:

| Shortcut | Expands to |
| --- | --- |
| `pi` | `:Lazy install` |
| `pud` | `:Lazy update` |
| `pc` | `:Lazy clean` |
| `ps` | `:Lazy sync` |

---

# 35. Java Development (`nvim-java`)

The Java keys work only in a Java buffer with the Java language server (jdtls) attached: open nvim inside the Java devShell (`java` on PATH). Everywhere else the same keys show one warning "Java: jdtls not attached (open nvim inside the Java devShell)". which-key groups: `<Space>j` Java, `jb` build, `jr` runner, `jt` test, `je` extract.

### Build & Run

| Keymap | Description |
| --- | --- |
| `<Space>jbb` | Build workspace |
| `<Space>jbc` | Clean workspace |
| `<Space>jrr` | Run main class |
| `<Space>jrs` | Stop running main |
| `<Space>jrl` | Toggle runner log window |
| `<Space>jrp` | Profiles UI |

### Testing

| Keymap | Description |
| --- | --- |
| `<Space>jtc` | Run all tests in current class |
| `<Space>jtC` | Debug all tests in current class |
| `<Space>jtm` | Run test method under cursor |
| `<Space>jtM` | Debug test method under cursor |
| `<Space>jtr` | View last test report |

### Refactoring

| Keymap | Description |
| --- | --- |
| `<Space>jev` | Extract variable |
| `<Space>jeo` | Extract variable (all occurrences) |
| `<Space>jec` | Extract constant |
| `<Space>jem` | Extract method |
| `<Space>jef` | Extract field |
| `<Space>jj` | Change JDK runtime |
| `<Space>jd` | Configure debugger (DAP) |

---

# 36. Debugging

| Plugin | Keymap / Command | Description |
| --- | --- | --- |
| nvim-dap | (lazy-loaded) | Debug Adapter Protocol client. Java debugging auto-configured via nvim-java. |
| nvim-gdb | `<Space>dp` | Python buffers only: start pdb on the current file (Linux/Windows only; elsewhere one warning). `:GdbStart` (gdb) works inside the c-cpp / rust devShells |

---

# 37. Symbol Outline (`aerial.nvim`)

The outline comes from Treesitter or the LSP server (no ctags needed).

| Keymap | Description |
| --- | --- |
| `<Space>t` | Toggle the symbol outline sidebar (functions, classes, methods; the cursor stays in your code) |
| `[t` / `]t` | Previous / next symbol (only in buffers where aerial is active; there they replace Vim's `:tprevious` / `:tnext` keys) |

Commands: `:AerialToggle`, `:AerialOpen`, `:AerialNavToggle`.

---

# 38. URL & Unicode

| Keymap | Mode | Description |
| --- | --- | --- |
| `gx` | n, x | Open the URL or file under the cursor (gx.nvim) |
| `ga` | n | Show Unicode info for character under cursor |
| `<Ctrl-x><Ctrl-z>` | i | Complete a Unicode character by name or `U+code` |
| `<Ctrl-x><Ctrl-g>` | i | Complete a digraph |
| `<Space>cu` | n | Swap `<Ctrl-x><Ctrl-z>` between completing the character and completing its name |
| `<F4>` + motion | n, x | Turn 2-character digraph pairs in the text into their characters |

Commands: `:UnicodeSearch {name or U+hex}`, `:UnicodeName`, `:UnicodeTable`. The plugin loads on the first `ga`, `<Space>cu` or `:UnicodeSearch`; the insert keys, `<F4>` and `:UnicodeName` / `:UnicodeTable` exist only after that. Example: `<F4>$` on `a:e:o:u:` gives the umlauts (per the plugin doc).

URLs in buffers are automatically highlighted (vim-highlighturl plugin).

---

# 39. Other Plugins

| Plugin | Trigger | Description |
| --- | --- | --- |
| `auto-save.nvim` | Automatic (active from right after the first screen) | Saves on `FocusLost` / `BufLeave` (message "AutoSave: saved at HH:MM:SS"); never saves unnamed, read-only or special buffers, nor Typst and LaTeX files |
| `better-escape.vim` | `jk` (insert) | Fast escape from insert mode (200ms window) |
| `vim-repeat` | `.` | Makes plugin actions repeatable with `.` |
| `vim-swap` | `gs` (n, x) | Interactively swap function arguments / list items |
| `vim-eunuch` | `:Rename`, `:Delete` | Unix file operations |
| `vim-obsession` | `:Obsession` | Session save/restore |
| `instant.nvim` | `:InstantStartServer`, `:InstantStartSession {host} {port}`, `:InstantJoinSession {host} {port}` | Collaborative editing (loads on its first `:Instant...` command) |
| `firenvim` | Browser | Neovim in browser text areas |
| `aerial.nvim` | `<Space>t` | Symbol outline (section 37) |
| `treesj` | `gS` | Split / join code blocks |
| `vim-illuminate` | `<Alt-n>`, `<Alt-p>`, `<Alt-i>` | Word references |
| `vimade` | Automatic | Dims inactive windows |
| `persistence.nvim` | Dashboard `r` / `L` | Saves a session per folder when you quit (see Session Management) |
| `snacks.nvim` | Automatic | Nicer input / select popups; light mode for big files |
| `colorful-menu.nvim` | Automatic | Completion labels coloured like code |
| `live-command.nvim` | `:norm` | Live preview of `:norm` while you type |
| `lazydev.nvim` | Lua files | Neovim API completion when editing the config |
| `vim-oscyank` | `:OSCYank` | Copy to the system clipboard through the terminal (works over SSH; Linux) |
| `vim-scriptease` | `:Messages`, `:Scriptnames` | Vim-script debugging helpers |
| `nvim-dbee`, `vim-dadbod-ui` | `<Space>D...` | SQL clients (see below) |

## SQL Databases (nvim-dbee, vim-dadbod-ui)

Two independent SQL clients. Neither has connections by default: this repo is public, so connections are never stored in the config.

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>Dt` | n | Dbee: toggle the UI |
| `<Space>Do` | n | Dbee: open the UI |
| `<Space>Dc` | n | Dbee: close the UI |
| `<Space>Du` | n | Dadbod: toggle the UI (connections, saved queries, results) |
| `<Space>Da` | n | Dadbod: add a connection |
| `<Space>Df` | n | Dadbod: find the DB buffer |

Commands: `:Dbee`, `:DB <url> <query>` (`:%DB <url>` runs the whole buffer as a query), `:DBUI`, `:DBUIToggle`, `:DBUIAddConnection`, `:DBUIFindBuffer`.

Connections come from the environment (set them in an untracked shell file, direnv or sops, never in the repo):
- nvim-dbee: `$DBEE_CONNECTIONS`, a JSON array such as `[{"name":"local","type":"postgres","url":"postgres://user:pw@localhost:5432/db"}]`. Connections added inside the UI are not saved.
- vim-dadbod-ui: `$DADBOD_CONNECTIONS`, a JSON object `{"name":"url"}`. Saved queries go to `~/.local/share/nvim/db_ui`.

`:checkhealth` shows a known, accepted `vim.validate{}` deprecation warning from nvim-dbee. <!-- CHECK-USER: the keys inside the dbee / dadbod panels were not tested (needs a database) -->

---

# 40. Configuration Management

| Keymap / Command | Description |
| --- | --- |
| `<Space>ev` | Open `init.lua` in a new tab |
| `<Space>sv` | Write all buffers and restart Neovim (windows, tabs and files are restored; terminals such as Claude Code are not restarted). Builtin `ZR` restarts without writing |
| `:Lazy` | Open plugin manager UI |
| `:Lazy update` | Update all plugins |

---

# 41. Filetype-Specific Settings

| Filetype | Settings |
| --- | --- |
| Python | 4-space indent, `<F9>` to run, `<Space>f` to format with Black (needs `black`, python devShell; one warning otherwise; in a uv project both use `uv run`) |
| Lua | `<F9>` to execute (`:luafile %`), `<Space>f` and `<Space>fm` format with Stylua |
| C++ | `<F9>` to compile and run (only when a C++ compiler is on PATH, e.g. the c-cpp devShell) |
| Markdown | Word wrap enabled, syntax highlighting continues up to column 3000 on long lines; `<Space>fm` formats with Prettier (one warning if `prettier` is missing); `<Space><Space>` does not strip trailing spaces |
| JSON | `<Space>f` runs `:JSONFormat` on the buffer (in Visual mode on the selection) |
| Typst | `<Space>tw` TypstWatch, `textwidth=100`, wrap |
| Vim script | `<F9>` sources the file |
| Line-length marker | The coloured column marker (`colorcolumn`) sits at 100 by default and, per language, exactly at that language's convention: 80 for C, C++, shell, YAML, Vim script, Haskell, R, JavaScript and TypeScript (also jsx/tsx); 88 for Python (black); 100 for Java, Rust, Swift, Nix, Typst; 120 for Lua, PHP, TeX; plain `.txt` files show none. A line touching the marker is over that language's limit. Nothing wraps or reflows. |

---

# 42. Automatic Behaviors

These happen without any keypress:

| Behavior | Description |
| --- | --- |
| Auto-create directories | Missing parent directories are created on save |
| Auto-resize windows | Windows resize equally when terminal is resized (the Claude Code panel goes back to 30% width) |
| Relative line numbers | Relative in the focused window in normal mode; absolute in insert mode and in other windows; none in terminals |
| Non-UTF-8 warning | Warns if file encoding is not UTF-8 |
| Yank highlight | Yanked text highlighted for 300ms |
| Cursor restore | Cursor returns to original position after yank |
| Auto-quit | When only utility windows remain in a tab (quickfix, aerial outline, nvim-tree), the tab closes; on the last tab Neovim quits |
| Diagnostic float | Diagnostics auto-show when cursor rests on a line |
| Smart case | Case-insensitive search unless uppercase is used (only `/` and `?`; `:s` and `:g` always ignore case) |
| Colorscheme | Fixed base16 theme on Nix systems (`NVIM_BASE16_THEME`, fallback Catppuccin Mocha); random on other systems |
| Auto-save | Files save automatically on focus lost / buffer leave (not unnamed, read-only or special buffers, not Typst/LaTeX) |
| File changed on disk | Checked when Neovim gets focus and when idle. An unmodified buffer is reloaded ("File changed on disk. Buffer reloaded!"); if the buffer was changed too it is kept ("File changed on disk and in the buffer (buffer kept)"); a deleted file keeps its buffer (one warning) |
| Format check after save | After saving a Python or Lua file, `black --check` / `stylua --check` run in the background; an unformatted file gives the warning `<file>: file is not formatted (black)` (`(stylua)` for Lua); a file the tool cannot check (syntax error) gives `<file>: <tool> could not check the file (syntax error?)` plus the first error line. Nothing is changed |
| `nvim <directory>` | The directory becomes the working directory and the file tree opens there |
| Git plugins | fugitive and gitlinker load when the working directory or an opened file is inside a git repository; neogit loads on its first `:Neogit*` command (with diffview and fzf-lua) |
| Big files | Files over about 1.5 MB (or with very long lines) open in a light mode: no Treesitter, no completion, the language server starts a little later. `:set ft=<language>` gives the full mode back |
| Help window | On a screen of at least 200 columns `:help` opens as a full-height split on the far left |

---
---

# Part II: Developer Guide

Everything below is aimed at developers. It explains the plugins and tools in this config that make Neovim a full development environment, what they do under the hood, why they matter, and how to use them effectively.

---

# 43. How the Development Toolchain Fits Together

When you open a code file in Neovim, several systems activate automatically behind the scenes:

```
You open a file
  |
  v
Treesitter parses the syntax tree --> accurate highlighting (plus symbols for the aerial outline)
  |
  v
LSP server starts (e.g., pyright for Python) --> diagnostics, go-to-definition, hover, rename, code actions
  |
  v
Completion engine (nvim-cmp) connects to LSP --> autocomplete suggestions as you type
  |
  v
Gitsigns reads git status --> change markers in gutter
  |
  v
Lightbulb watches LSP --> shows icon when code actions are available
  |
  v
Diagnostics config --> errors/warnings appear as Nerd Font signs, a float opens on CursorHold
```

You don't need to start any of this manually. It all happens on file open.

---

# 44. Language Server Protocol (LSP) In Depth

## What LSP Is

LSP is a protocol that lets Neovim communicate with language-specific servers (programs that understand your code). The server analyzes your code and provides:

- **Diagnostics**: Errors and warnings shown in the gutter and floating windows
- **Go to definition**: Jump to where a function/class/variable is defined
- **Hover**: Show documentation for the symbol under cursor
- **Rename**: Rename a symbol across the entire project
- **Code actions**: Quick fixes, auto-imports, refactorings
- **Formatting**: Auto-format your code according to language standards
- **Completion**: Suggestions as you type

## How LSP Is Managed

Each server is configured in `lua/config/lsp.lua` (plus `after/lsp/<name>.lua`) with Neovim's builtin `vim.lsp.config` / `vim.lsp.enable`. **nvim-lspconfig** only supplies the default server definitions. A server is enabled only when its program is on PATH: the programs come from the Nix system (`neovim.nix`) or from the language's devShell, nothing is downloaded by Neovim. Java (jdtls) is managed by nvim-java.

## Configured Servers and What They Provide

| Server | Language | What it provides |
| --- | --- | --- |
| **pyright** | Python | Type checking, import resolution, diagnostics. Disables import sorting (ruff handles that). |
| **ruff** | Python | Fast linting and formatting. Complementary to pyright. |
| **lua_ls** | Lua | Full Lua analysis with `vim` global recognized. Its formatting is switched off: Lua is formatted by stylua (`<Space>f` / `<Space>fm`). |
| **bashls** | Bash/Shell | Shell script analysis and diagnostics. |
| **yamlls** | YAML | Schema validation and formatting for YAML files. |
| **marksman** | Markdown | Link validation, heading completion. Formatting is done by `<Space>fm` with Prettier (not by marksman). |
| **nixd** | Nix | Nix language analysis. Formatter: nixpkgs-fmt. |
| **jdtls** | Java | Full Java IDE features via nvim-java (see Java section). Auto-configured. |
| **clangd** | C/C++ | Compilation, diagnostics, code completion for C/C++. |
| **ltex_plus** | Prose (markdown, tex, typst, gitcommit, text) | Grammar and spell checking with LanguageTool; problems are diagnostics. |
| **typos_lsp** | Every real file | Finds typos in identifiers and comments; offers fixes as code actions. |
| **tinymist** | Typst | Diagnostics, completion (PDF export is left to `:TypstWatch`). |
| **texlab** | LaTeX | Diagnostics, hover, symbols, rename. |
| **rust_analyzer** | Rust | Full Rust analysis (needs `cargo` too). |
| **gopls** | Go | Full Go analysis (needs `go` too). |
| **hls** | Haskell | Haskell language server. |
| **sourcekit** | Swift, Objective-C | Swift analysis (C/C++ stay with clangd). |
| **ts_ls** | JavaScript / TypeScript | TypeScript language server. |
| **phpactor** | PHP | PHP analysis and refactoring. |
| **r_language_server** | R | R analysis, after a one-time check that the R package `languageserver` is installed. |

Each server starts only when its program is installed (see the table in section 13); `:LspAttached` (or a click on the LSP name in the statusline) shows what is attached.

## LSP Keymaps (All Languages)

These keys work per buffer according to what the attached servers support: `K` and `gd` fall back to Vim's builtin versions when no attached server supports hover / definition; `<Space>rn` and `<Space>ca` show one warning instead ("rename: no attached language server supports it", or "... no language server attached to this buffer").

| Keymap | What it does | When to use |
| --- | --- | --- |
| `gd` | **Go to definition**. If there's only one definition, jumps directly. If multiple, opens a location list so you can pick. Deduplicates results. | When you want to see where a function/class/variable is defined. |
| `K` | **Hover documentation**. Shows docs in a floating window with a border (at most 100 x 40). | When you need to check what a function does, its parameters, return type, etc. |
| `<Space>rn` | **Rename symbol**. Renames the symbol under cursor everywhere it appears in the project. | When refactoring: changing a function name, variable name, etc. |
| `<Space>ca` | **Code action**. Shows a menu of available fixes and refactorings. | When the lightbulb icon appears, or when you want to auto-import, extract a variable, fix a lint warning, etc. |
| `<Space>fm` | **Format file**. Runs the LSP formatter asynchronously (ruff, nixd, ...); in Markdown buffers Prettier, in Lua buffers stylua. | Before committing, or whenever you want clean formatting. |

## Peeking Without Jumping (Glance)

Plugin: **glance.nvim**. Instead of jumping away to a definition (which changes your context), you can peek at it in an inline popup:

| Keymap | What it does |
| --- | --- |
| `<Space>gd` | Peek at definitions in a popup. You see the code without leaving your current file. Press `<Esc>` to close. |
| `<Space>gr` | Peek at all references. See every place in the project that uses this symbol. |
| `<Space>gi` | Peek at implementations. See how interfaces/abstract methods are implemented. |

Neovim's builtin `grn`, `gra`, `grr`, `gri`, `grt` and `gO` also work (see section 13).

**When to use Glance vs `gd`**: Use Glance when you want to quickly check something and come back. Use `gd` when you want to actually navigate to the definition and work there.

## Diagnostics In Depth

Diagnostics are the errors, warnings, and hints that the LSP server reports about your code.

**How they appear**:
- Nerd Font signs in the gutter: 󰅚 (error), 󰀪 (warning), 󰋽 (info), 󰌶 (hint)
- A floating window automatically appears after ~500ms when your cursor rests on a line with diagnostics; it closes when you move the cursor or enter insert mode
- The statusline (left side) shows the diagnostic counts with the same icons, e.g. `󰅚 1 󰀪 3`

**Navigation**:

| Keymap | What it does |
| --- | --- |
| `<Space>de` | Jump to the next **error** (skips warnings/hints) |
| `<Space>dE` | Jump to the previous **error** |
| `<Space>dd` | Manually open the diagnostic float for the current line |
| `<Space>db` | Open a Telescope picker showing all diagnostics in the current file |
| `<Space>dw` | Open Trouble showing all diagnostics across the workspace |
| `<Space>dt` | Toggle diagnostics on/off globally (a message says which; the automatic float stays off while disabled) |

**Sending diagnostics to quickfix**:

| Keymap | What it does |
| --- | --- |
| `<Space>qw` | Put the diagnostics of all open buffers into the quickfix list |
| `<Space>qb` | Put current buffer diagnostics into the quickfix list (with none you only get "No diagnostics in this buffer") |

Then use `:cnext`/`:cprev` to jump through them one by one.

## The Lightbulb

Plugin: **nvim-lightbulb**. A lightbulb icon appears in the sign column whenever the LSP has code actions available for the current line. This is your cue to press `<Space>ca`.

The lightbulb filters out noisy ruff actions (`source.fixAll.ruff`, `source.organizeImports.ruff`) to avoid false positives.

---

# 45. Autocompletion In Depth

## How It Works

When you type in insert mode, **nvim-cmp** queries multiple sources and shows a popup menu with suggestions:

1. **LSP** (highest priority): Function names, variables, methods, types from the language server
2. **UltiSnips**: Snippet triggers (e.g., type `jfor` in a Java file)
3. **Path**: File paths when you start typing a path
4. **Buffer** (lowest priority, min 2 chars): Words already in the current buffer

For LaTeX files the sources are **omni** (BibTeX/citations), the texlab LSP (only when `texlab` is on PATH, LaTeX devShell), UltiSnips, buffer and path.

## The Smart Tab Behavior

`<Tab>` has two behaviors depending on context:

1. **Completion menu is visible**: Selects the next item in the menu
2. **Otherwise**: Inserts a normal tab character

## Completion Keymaps

| Keymap | In completion menu | Outside menu |
| --- | --- | --- |
| `<Tab>` | Select next item | Insert tab |
| `<CR>` (Enter) | Confirm the item you picked (with nothing picked: newline) | Insert newline |
| `<Ctrl-e>` | Close menu | Go to end of line |
| `<Esc>` | Close menu | Exit insert mode |
| `<Ctrl-d>` | Scroll docs up | Delete the character right of the cursor |
| `<Ctrl-f>` | Scroll docs down | (nothing) |

## Visual Indicators

- Each completion item shows an icon indicating its kind (function, variable, method, keyword, etc.) via mini.icons
- Deprecated items appear with strikethrough
- The completion menu is semi-transparent (5% blend)

---

# 46. Treesitter In Depth

## What Treesitter Is

Plugin: **nvim-treesitter**. It parses your code into a syntax tree (like an AST) and uses that for:

- **Syntax highlighting**: More accurate than regex-based highlighting. Understands the actual structure of the code.
- **Symbols**: the aerial outline (`<Space>t`) can read the symbols from the tree.

## Installed Parsers

On NixOS the parsers come from the nix store (home-manager); Neovim installs nothing. On other systems Neovim installs this fixed set at startup: cpp, diff, dockerfile, git_config, git_rebase, gitcommit, html, json, lua, python, toml, vim. Other languages get no tree-sitter highlighting there until you run `:TSInstall <lang>`. <!-- CHECK-USER: the non-nix install behaviour cannot be tested on this machine -->

---

# 47. Code Folding In Depth

## What It Is

Plugin: **nvim-ufo** + **promise-async**. Code folding collapses blocks of code (functions, classes, if-blocks, etc.) into a single line to help you see the big picture.

## How It Works

nvim-ufo uses the LSP server's folding ranges to determine what can be folded, and falls back to indentation when no server provides folds.

Folded lines show a preview: the first line of the fold + a count like `󰁂 42` showing how many lines are hidden.

## Folding Keymaps

| Keymap | What it does | When to use |
| --- | --- | --- |
| `za` | Toggle the fold under cursor | Quick open/close of a single fold |
| `zR` | Open ALL folds in the file | When you want to see everything |
| `zM` | Close ALL folds in the file | When you want the bird's-eye view |
| `zr` | Open one more fold level (`{N}zr` = N levels; in a buffer without ufo folds: one warning) | Gradually reveal more detail |
| `zm` | Close one more fold level (`{N}zm` = N levels) | Step back to less detail |
| `zo` / `zc` | Open / close fold at cursor | Precise control |
| `zO` / `zC` | Open / close all nested folds at cursor | Deep open/close |
| `<Space>K` | Preview folded lines in popup | See what's inside without unfolding |
| `zi` | Toggle folding on/off globally | Temporarily disable all folding |

**Workflow tip**: Press `zM` to close all folds when you open a large file. This gives you an outline view. Then use `za` to open only the sections you care about. Use `<Space>K` to peek inside folds without opening them.

---

# 48. Git Workflow In Depth

## The Git Plugin Ecosystem

This config includes several git-related plugins that each handle a different aspect:

| Plugin | What it does | How to use |
| --- | --- | --- |
| **vim-fugitive** | Run git commands from inside Neovim. The core git plugin. | `<Space>gs` for status, `<Space>gc` for commit, etc. |
| **gitsigns.nvim** | Shows which lines changed in the gutter. Navigate between changes. | `]c` / `[c` to jump between hunks, `<Space>hp` to preview. |
| **gitlinker.nvim** | Generate shareable URLs to specific lines of code. | `<Space>gl` to copy a permalink. |
| **neogit** | A full git UI inside Neovim (like Magit for Emacs). | `:Neogit` to open (loads on that command; also `:NeogitCommit`, `:NeogitLogCurrent`, `:NeogitResetState`). |
| **diffview.nvim** | Side-by-side diff viewer for comparing branches, commits, etc. | `:DiffviewOpen` to open. |
| **vim-flog** | Visual git log/graph showing branch history. | `:Flog` to open. |
| **diffs.nvim** | Syntax highlighting inside the diffs of fugitive, neogit and gitsigns; conflict markers. `:Diff` shows the file against git. | Automatic, `:Diff`. |
| **codediff.nvim** | VSCode-style side-by-side diff. | `:CodeDiff`. |

Merge conflicts: `:DiffviewOpen` is the merge tool (keys in section 20, "Resolving Merge Conflicts").

## Daily Git Workflow

A typical workflow entirely from within Neovim:

1. **Check status**: `<Space>gs` opens the fugitive status window
2. **Stage a file**: `<Space>gw` stages the current file (or use `s` in the status window)
3. **Review changes**: `<Space>hp` to preview hunks, or `]c`/`[c` to navigate between them
4. **Commit**: `<Space>gc` opens a commit message buffer. Write message, then `:wq`
5. **Push**: `<Space>gpu` pushes (opens a terminal split showing progress)
6. **Pull**: `<Space>gpl` pulls latest changes
7. **Blame**: Select lines in visual mode, then `<Space>gb` to see who wrote them
8. **Create branch**: `<Space>gbn` prompts for a branch name
9. **Share code**: `<Space>gl` copies a permalink to the current line

## Understanding Gitsigns

The gutter signs mean:
- `+` : This line was **added** (new code)
- `~` : This line was **modified** (changed from last commit)
- `_` : A line was **deleted below** this line
- `‾` : A line was **deleted above** this line
- `│` : This line has both additions and deletions (change-delete)

**Hunk navigation**: `]c` jumps to the next changed block (hunk), `[c` jumps to the previous. This is very useful during code review.

---

# 49. AI-Assisted Development In Depth

## Claude Code

Plugin: **claude-code.nvim**

Claude Code is an AI coding assistant that runs in a terminal inside Neovim. The plugin loads right after the first screen is drawn (VeryLazy), so its keys and `:ClaudeCode*` commands exist a fraction of a second after Neovim starts.

| Keymap | Mode | What it does |
| --- | --- | --- |
| `<Space>cc` | n | Toggle the Claude Code terminal. Opens as a vertical split on the right (30% of the width). |
| `<Space>cR` | n | Resume/continue the last Claude conversation (`claude --continue`) |
| `<Space>cV` | n | Start Claude in verbose mode |

**Using Claude Code**:
1. Press `<Space>cc` to open
2. It opens as a terminal buffer in a vertical split on the right
3. Type your request and press Enter
4. Claude can read and edit your files directly
5. Leave terminal mode with `<Ctrl-\><Ctrl-n>` (a plain `<Esc>` goes to Claude, e.g. to interrupt it), then press `<Space>cc` to close the panel

Claude Code uses your project's git root as the working directory. `:ClaudeCodeResume` starts `claude --resume`. Inside the panel `<Ctrl-h/j/k/l>` move to the neighbour windows and `<Ctrl-f>` / `<Ctrl-b>` scroll.

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

# 51. Quickfix Workflows for Developers

The quickfix list is a central tool for developers. It's a list of locations (file + line number) that you can jump through. Many features populate it.

## What Populates the Quickfix List

| Source | How to populate | Description |
| --- | --- | --- |
| Project-wide search | `:vimgrep /pattern/ **/*` | Search results across all files |
| LSP diagnostics | `<Space>qw` | Diagnostics of all open buffers |
| Buffer diagnostics | `<Space>qb` | Errors/warnings in current file only |
| Build errors | `:make` | Compiler output |
| Grep | `:grep pattern` | Uses ripgrep (configured in this setup) |

## Navigating the Quickfix List

| Command / Keymap | What it does |
| --- | --- |
| `:copen` | Open the quickfix window at the bottom |
| `:cclose` or `\x` | Close the quickfix window (`\x` also closes all location lists) |
| `:cnext` | Jump to the next item |
| `:cprev` | Jump to the previous item |
| `:cfirst` / `:clast` | Jump to the first / last item |
| `:cc 5` | Jump to item number 5 |
| `:colder` / `:cnewer` | Go to the previous / next quickfix list (history) |

## Batch Operations on Quickfix Items

| Command | What it does |
| --- | --- |
| `:cfdo %s/old/new/g \| update` | Run a substitution once in every file of the quickfix list, then save it |
| `:cdo s/old/new/ge \| update` | The same per quickfix entry (the `e` flag is needed, see the Multi-File Search and Replace section) |

**Example workflow**: Rename a string across the project:
1. `:grep "oldName"` to populate quickfix with all occurrences
2. `:cfdo %s/oldName/newName/g | update` to replace in all files and save them

## Trouble (Better Quickfix UI)

Plugin: **trouble.nvim**. A nicer interface for browsing diagnostics and quickfix items.

| Keymap / Command | What it does |
| --- | --- |
| `<Space>dw` | Open Trouble with workspace diagnostics |
| `:Trouble` | Open Trouble window |

Trouble shows diagnostics grouped by file with icons and colors, making it easier to triage errors.

---

# 52. Snippets for Developers

## What Snippets Are

Plugin: **UltiSnips** + **vim-snippets**. Snippets are templates that expand into boilerplate code when you type a trigger word.

## How to Use Snippets

1. In insert mode, type a trigger word (e.g., `jfor` in a Java file)
2. The trigger appears in the completion menu as a snippet
3. Press `<Ctrl-j>` to expand it
4. The snippet expands with **placeholders** (highlighted fields you need to fill in)
5. Press `<Ctrl-j>` to jump to the next placeholder
6. Press `<Ctrl-k>` to jump to the previous placeholder
7. Fill in each placeholder, and you're done

## Custom Snippets

Custom snippets live in the `my_snippets/` directory. Each file targets a specific language:

| File | Language | Notable snippets |
| --- | --- | --- |
| `all.snippets` | All filetypes | General-purpose snippets |
| `java.snippets` | Java | Scanner, arrays, loops, conditionals, switch, try-catch (see full list in Snippets section) |
| `python.snippets` | Python | Python-specific patterns |
| `cpp.snippets` | C++ | C++ templates |
| `nix.snippets` | Nix | Nix language patterns |
| `tex.snippets` | LaTeX | LaTeX environments and commands |
| `markdown.snippets` | Markdown | Markdown structures |
| `vim.snippets` | Vimscript | Vim plugin development |
| `snippets.snippets` | Snippet files | `snip`: template for a new snippet definition |

## Creating Your Own Snippets

Edit the appropriate file in `my_snippets/` (e.g., `my_snippets/python.snippets`):

```
snippet trigger "Description" b
def ${1:function_name}(${2:args}):
    ${3:pass}
endsnippet
```

- `trigger` is what you type
- `b` means it only triggers at the beginning of a line
- `${1}`, `${2}`, `${3}` are tab-stop placeholders (jump between them with `<Ctrl-j>`)

---

# 53. Documentation Lookup

## DevDocs (Plugin)

Plugin: **nvim-devdocs**. Browse programming documentation without leaving Neovim.

| Command | What it does |
| --- | --- |
| `:DevdocsOpen` | Open the documentation in a normal buffer (current window) |
| `:DevdocsOpenFloat` | Open in floating window (25 lines tall, 100 chars wide) |
| `:DevdocsInstall` | Install documentation for a language (e.g., `:DevdocsInstall python`) |
| `:DevdocsUninstall` | Remove installed docs |

## Hover Documentation (LSP)

Press `K` on any symbol to see its documentation in a floating window. This pulls from:
- Function signatures and return types
- Docstrings / JSDoc / Javadoc
- Type information

---

# 54. Java Development In Depth

Plugin: **nvim-java**.

This is the most feature-rich language setup in this config. It provides a full Java IDE experience. nvim-java loads when you open the first Java file of the session (not at startup), so opening a Java file takes a moment longer the first time; non-Java sessions do not pay for it.

## How It Works

nvim-java wraps the Eclipse JDT Language Server (jdtls) and adds:
- Build system integration
- Test runner and debugger
- Spring Boot tools
- Refactoring commands
- DAP (Debug Adapter Protocol) for step-through debugging

All of this only starts inside the Java devShell (`java` on PATH). Elsewhere `.java` files open without Java tooling, and the `<Space>j` keys show one warning "Java: jdtls not attached (open nvim inside the Java devShell)".

On Nix systems the JDK comes from the Java devShell (`JAVA_HOME`) and nvim-java never downloads one. On other systems nvim-java auto-installs a JDK.

## Build & Run

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jbb` | `:JavaBuildBuildWorkspace` | Compile the entire workspace |
| `<Space>jbc` | `:JavaBuildCleanWorkspace` | Clear the jdtls workspace cache (close and reopen Neovim afterwards) |
| `<Space>jrr` | `:JavaRunnerRunMain` | Run the main class |
| `<Space>jrs` | `:JavaRunnerStopMain` | Stop the running program |
| `<Space>jrl` | `:JavaRunnerToggleLogs` | Show/hide the runner log window <!-- CHECK-USER: where does the runner log window open (bottom?) --> |
| `<Space>jrp` | `:JavaProfile` | Profiles UI |

## Testing

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jtc` | `:JavaTestRunCurrentClass` | Run all `@Test` methods in the current class |
| `<Space>jtC` | `:JavaTestDebugCurrentClass` | Debug all tests (with breakpoints) |
| `<Space>jtm` | `:JavaTestRunCurrentMethod` | Run only the test method under cursor |
| `<Space>jtM` | `:JavaTestDebugCurrentMethod` | Debug only the test under cursor |
| `<Space>jtr` | `:JavaTestViewLastReport` | Show pass/fail results from the last test run |

## Debugging

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jd` | `:JavaDapConfig` | Configure the debug adapter (auto-runs on Java file open, but can be re-triggered) |

DAP is configured automatically when jdtls starts. Debugging uses the nvim-dap commands (`:DapToggleBreakpoint`, `:DapContinue`, `:DapStepOver`, `:DapStepInto`, `:DapStepOut`, `:DapTerminate`); this config has no keys for them.

## Refactoring

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jev` | `:JavaRefactorExtractVariable` | Extract the expression under the cursor (or selection) to a local variable |
| `<Space>jeo` | `:JavaRefactorExtractVariableAllOccurrence` | Extract and replace ALL occurrences of the expression |
| `<Space>jec` | `:JavaRefactorExtractConstant` | Extract a constant |
| `<Space>jem` | `:JavaRefactorExtractMethod` | Extract a method |
| `<Space>jef` | `:JavaRefactorExtractField` | Extract a field |
| `<Space>jj` | `:JavaSettingsChangeRuntime` | Switch the JDK version |

The `:Java*` commands (except `:JavaRunnerRunMain` and `:JavaProfile`) exist only while jdtls is attached.

---

# 55. Code Running In Depth

## The Universal Runner

The `<Space>rr` keymap detects the current filetype and runs the appropriate command in a **vertical split terminal** on the left. If the file is unsaved, the filetype has no runner, or the compiler/interpreter is not on PATH, you get ONE warning and no terminal opens (the message names the devShell to start nvim in).

**How it works**:
1. Detects the filetype of the current buffer
2. Builds the correct command (e.g., `python3 file.py`, `go run .`)
3. Opens a vertical split
4. Starts a terminal in that split running the command
5. Output appears in real-time

**After running**:
- The terminal window opens on the LEFT of your code
- Press `<Esc>` in the terminal to enter Normal mode
- Navigate back to your code with `<Ctrl-w>l` or `<Right>`
- Close the terminal window with `<Space>q`, or delete its buffer with `\d`
- Run again with `<Space>rr` (it opens a new terminal each time)

## Language-Specific Details

| Language | Command used | Notes |
| --- | --- | --- |
| Python | `python3 <file>` | |
| Java | `:JavaRunnerRunMain` when jdtls (nvim-java) is attached; otherwise `java <file>` | With jdtls no terminal is used |
| C | `gcc -Wall -Wextra -std=c11 <file> -o <binary> && <binary>` | Compiles and runs; the binary sits next to the source; needs gcc (c-cpp devShell) |
| C++ | `g++ -Wall -Wextra -std=c++20 <file> -o <binary> && <binary>` | Compiles and runs; needs g++ (c-cpp devShell) |
| C# | `dotnet run --project <nearest .csproj>` | Without a project file: `dotnet run <file>` |
| JavaScript | `node <file>` | |
| TypeScript | `node <file>` | Node runs `.ts` directly |
| Go | `go run .` in the file's directory | Runs the whole package |
| Rust | `cargo run` when a `Cargo.toml` is above the file | Otherwise `rustc <file>` and runs the binary |
| Bash | `bash <file>` | |
| Lua | `nvim -l <file>` | Neovim's own LuaJIT |
| Ruby | `ruby <file>` | |
| PHP | `php <file>` | |

## Filetype-Specific Runners

Some filetypes have an additional `<F9>` runner:

| Filetype | What `<F9>` does |
| --- | --- |
| Python | Runs with `python -u <file>` via AsyncRun (unbuffered output; `uv run python -u` in a uv project) |
| C++ | Compiles with `clang++` (else `g++`) `-Wall -Wextra -std=c++20 -O2` and runs it in a horizontal split; only mapped when a compiler is on PATH |
| LaTeX | vimtex compile; only when `latex` is on PATH |

---

# 56. Debugging In Depth

## Debug Adapter Protocol (DAP)

Plugin: **nvim-dap**. DAP is a standardized protocol (created by Microsoft) for communication between an editor and a debugger. It's the same protocol used by VS Code.

**Java**: Debugging is auto-configured via nvim-java (only inside the Java devShell, where `java` is on PATH). Open a Java file, set breakpoints, and use `<Space>jtC` (debug the current test class) or `<Space>jtM` (debug the current test method).

**Python**: In Python buffers `<Space>dp` starts `python -m pdb` on the current file through nvim-gdb. Only available on Linux/Windows.

## GDB Integration

Plugin: **nvim-gdb**. For C/C++ debugging with GDB. Available on Linux and Windows only.

---

# 57. File Management for Developers

## File Operations

| Plugin / Feature | What it does |
| --- | --- |
| **nvim-tree** (`<Space>s`) | Visual file browser. Create (`a`), delete (`d`), rename (`r`), copy (`c`), cut (`x`), paste (`p`). |
| **vim-eunuch** | Unix file commands, all available from a fresh start (lazy `cmd` list): `:Rename <newname>`, `:Move <path>` (move the file, creating directories), `:Duplicate <name>`, `:Copy <path>`, `:Delete` / `:Remove` / `:Unlink` (delete the file; `:Delete` also the buffer), `:Mkdir[!] <dir>` (`!` = with parents), `:Chmod <mode>`, `:Cfind` / `:Lfind` / `:Clocate` / `:Llocate` (find / locate into the quickfix / location list), `:SudoEdit`, `:SudoWrite`, `:Wall` (write all) and `:W` (= `:Wall`). |
| **gx.nvim** (`gx`) | Open the URL or file path under cursor in a browser. |
| `:CopyPath absolute` | Copy the full file path to clipboard. |
| `:CopyPath relative` | Copy path relative to project root. |
| `:CopyPath nameonly` | Copy just the filename. |

## Project Structure Navigation

| Keymap | What it does |
| --- | --- |
| `<Space>s` | Toggle file tree sidebar |
| `<Space>ff` | Fuzzy-find any file in the project |
| `<Space>fg` | Search for text across all project files |
| `<Space>cd` | Change the working directory of THIS window only (`:lcd`) to the current file's folder and print it |
| `<Space>t` | Toggle the symbol outline (aerial) for the current file |

---

# 58. Session and Productivity

## Auto-Save

Plugin: **auto-save.nvim**. Files are automatically saved when you:
- Switch to another application (`FocusLost`)
- Leave the current buffer (`BufLeave`)

It never saves unnamed, read-only or special buffers (terminals, help, ...) and never saves Typst and LaTeX files (their watchers would recompile on every save). After each save the message "AutoSave: saved at HH:MM:SS" appears.

## Session Management

Plugin: **persistence.nvim** saves a session for the current folder (and git branch) automatically when you quit, once a real file was opened. It is never restored by itself: restore it from the dashboard (`r` this folder, `L` last session). Windows of Claude Code, terminals, nvim-tree, the outline, help and quickfix are left out of the saved session. `<Space>sv` (restart) brings windows, tabs and files back on its own.

Plugin: **vim-obsession** (manual alternative). Save and restore your entire Neovim session (open files, window layout, etc.). It loads right after the first screen, so a session started with `nvim -S Session.vim` keeps being updated while you work (no need to type `:Obsession` again).

| Command | What it does |
| --- | --- |
| `:Obsession` | Start recording the session (saves to `Session.vim`) |
| `:Obsession!` | Stop recording and delete the session file |
| `nvim -S Session.vim` | Restore the session from the command line |

## Collaborative Editing

Plugin: **instant.nvim**. Real-time collaborative editing.

- The plugin loads on its first `:Instant...` command. Host and port are arguments of `:InstantStartServer` / `:InstantStartSession` / `:InstantJoinSession` (e.g. `:InstantStartSession 127.0.0.1 8081`); the built-in server defaults to port 8080.
- Uses your system username automatically

---

# 59. Useful Developer Commands

| Command | What it does |
| --- | --- |
| `:LspInfo` | LSP status (runs `:checkhealth vim.lsp`) |
| `:Lazy` | Open plugin manager |
| `:Lazy update` | Update all plugins |
| `:JSONFormat` | Format JSON (works on visual selection too) |
| `:ToPDF` | Convert markdown to PDF via pandoc |
| `:Redir <cmd>` | Capture any Neovim command output (e.g., `:Redir messages`) |
| `:Telescope keymaps` | Browse all defined keymaps |
| `:checkhealth` | Diagnose Neovim installation issues |
| `:Flog` | Git log graph |
| `:DiffviewOpen` | Side-by-side diff view |
| `:Neogit` | Full git UI |
| `:DevdocsOpen` | Browse programming documentation |
| `:YankyRingHistory` | Browse yank history |
| `:LspAttached` | Popup with the LSP servers attached to this buffer |
| `:LspLog` | Open the LSP log |
| `<Space>u` | Toggle the undo tree (the `:Undotree` command exists only after the first `<Space>u`) |
| `:AerialToggle!` | Toggle the symbol outline (`<Space>t`) |
| `:Dashboard` | Open the start screen |
| `:CodeDiff` | VSCode-style side-by-side diff |
| `:DBUI` / `:Dbee` | SQL clients |

---
---

# Part III: Everyday Scenarios & Recipes

Practical, step-by-step walkthroughs for common tasks.

---

# 60. Macros In Depth

Macros record a sequence of keystrokes and replay them. They are one of the most powerful features in Vim for repetitive editing.

**Key mapping**: In this config `Q` is mapped to `q`, so `Q` and `q` both start recording (tested: plain `q` works too). Stopping is always `q`.

## Recording a Macro

1. Press `Q` followed by a register letter (e.g., `Qa` to record into register `a`)
2. The command line (bottom line) shows `recording @a` (tested in a real terminal) -- everything you do now is being recorded
3. Perform the editing actions you want to repeat
4. Press `q` to stop recording

## Playing a Macro

| Keymap | What it does |
| --- | --- |
| `@a` | Play macro from register `a` once |
| `5@a` | Play macro 5 times |
| `@@` | Replay the last played macro |
| `100@a` | Play 100 times (stops early if it hits an error, e.g., end of file) |

## Scenario: Add Semicolons to the End of 20 Lines

1. Place cursor on the first line
2. `Qa` -- start recording to register `a`
3. `A;<Esc>` -- go to end of line, add semicolon, back to normal mode
4. `j` -- move down one line
5. `q` -- stop recording
6. `19@a` -- replay 19 more times (20 lines total)

## Scenario: Wrap Each Line in Double Quotes

Starting with:
```
apple
banana
cherry
```

1. Cursor on line 1
2. `Qa` -- start recording
3. `I"<Esc>` -- insert `"` at beginning
4. `A"<Esc>` -- append `"` at end
5. `j` -- move down
6. `q` -- stop recording
7. `2@a` -- replay for remaining lines

Result:
```
"apple"
"banana"
"cherry"
```

## Scenario: Append the Same Text to a Block of Lines (Tested)

Starting with 4 consecutive lines that each end with `;`, add ` // ok` to the end of every one.

1. Put the cursor on the first of the 4 lines, at any column.
2. `Qa` -- start recording to register `a`
3. `A // ok<Esc>` -- jump to the end of the line, type the text, back to Normal mode
4. `j` -- move down one line, ready for the next run
5. `q` -- stop recording. Only line 1 has changed so far (you did the edit while recording).
6. `3@a` -- replay 3 more times for the other 3 lines (total lines - 1)

Result: all 4 lines end with `; // ok`.

- **Why it repeats well**: `A` goes to the end of the line wherever the cursor is, so the column does not matter, and the macro ends on `j`, so the next run starts on the next line.
- **Where the cursor ends**: one line **below** the last processed line (the final `j` of the last run). If that line is blank, the cursor is on the blank line. When the block is the last in the file the final `j` fails and the cursor stays on the last line.
- **Count**: use `number of lines - 1`, because the recording already did the first line. A count that goes past the last line stops early with an error, which is harmless.
- **Undo**: one `u` undoes the whole replay (lines 2-4); the line you edited by hand while recording needs a second `u` (tested).

## Scenario: Convert a List of Variables to Assignments

Starting with:
```
name
age
email
```

Turn each into `self.name = name`:

1. Cursor on `name`
2. `Qa` -- start recording
3. `0yiw` -- yank the word
4. `Iself.<Esc>` -- prepend `self.`
5. `A = <Esc>p` -- append ` = ` and paste the word
6. `j` -- next line
7. `q`, then `2@a` (tested: gives `self.name = name`, `self.age = age`, `self.email = email`)

## Scenario: Turn CSV into SQL VALUES

Starting with `John,30,john@email.com`:

1. `Qa` -- start recording
2. `I('<Esc>` -- prepend `('`
3. `:s/,/','/g<CR>` -- replace the commas on this line only (use `:s`, not `:%s`)
4. `A'),<Esc>` -- append `'),`
5. `j` -- next line
6. `q` then replay

## Tips for Writing Macros

- **Start from a consistent position**: Begin each macro from a fixed position in the line (`0` start of the line, `H` first non-blank) or from a search result. This makes the macro repeatable.
- **Use word motions, not character motions**: `w`, `e`, `b` work regardless of word length. `3l` only works for a specific column.
- **End on the next line**: If processing line-by-line, end the macro with `j` (move down) so replaying it processes subsequent lines.
- **Test with `@a` once**: Play the macro once to verify before running `100@a`.
- **Check existing registers**: `:reg` shows what's stored in each register. Macros and yanks share registers, so recording to `a` overwrites whatever was yanked to `a`.
- **Use a high count**: `999@a` will replay until it fails (e.g., end of file). Vim stops automatically on error.

## Visual Mode Macros

You can apply a macro to every line in a visual selection:

1. Select lines with `V` + `j`/`k`
2. Type `:normal @a` and press Enter
3. The macro runs on each selected line

---

# 61. The Dot Command (`.`) -- Repeating Actions

The `.` key repeats the last change. This is arguably the most important efficiency tool in Vim.

## What Counts as a "Change"

- Any editing in insert mode between `i`...`<Esc>` (typed text, deletions, etc.)
- Any operator command: `dd`, `dw`, `ciw`, `>>`, `gcc`, etc.
- Surroundings: `saiw"`, `sd"`, `sr"'`
- Plugin actions (via vim-repeat): sandwich, commentary, etc.

## Scenario: Change a Variable Name One-by-One

1. Place cursor on the word `oldName`
2. `*` -- search for it (highlights all occurrences)
3. `ciw` -- change inner word, type `newName`, press `<Esc>`
4. `n` -- jump to next occurrence
5. `.` -- repeat the change (replaces `oldName` with `newName`)
6. `n` -- next occurrence
7. `.` -- repeat again
8. Skip an occurrence? Just press `n` without `.`

This gives you manual control over each replacement, unlike `:%s` which replaces all at once.

## Scenario: Add a Prefix to Multiple Lines

1. On the first line: `I// <Esc>` (insert `// ` at start)
2. `j` -- move down
3. `.` -- repeat (adds `// ` to this line too)
4. `j.j.j.` -- keep going

## Scenario: Delete the First Word on Several Lines

1. On the first line: `0dw` (go to start, delete word)
2. `j` -- move down
3. `.` -- repeat
4. Continue `j.` as needed

## Scenario: Indent Multiple Blocks

1. On a line: `>>` (indent right)
2. `.` -- indent again (double indent)
3. Move to another line, `.` -- indent that line too

## Combining `.` with Counts

- `3.` repeats the last change 3 times
- `5>>` then `.` repeats the 5-line indent

---

# 62. Visual Block Editing (Multi-Cursor-Like)

Visual block mode (`<Ctrl-v>`) lets you edit rectangular columns of text. This is the closest thing to multi-cursor editing.

## Scenario: Add a Prefix to Multiple Lines at Once

```
line one
line two
line three
```

1. Place cursor at the start of `line one`
2. `<Ctrl-v>` -- enter block visual mode
3. `2j` -- extend selection down 2 lines (column is now selected on 3 lines)
4. `I` -- enter insert mode (capital I, for block insert)
5. Type `// ` (or any prefix)
6. Press `<Esc>` -- the prefix appears on ALL three lines

Result:
```
// line one
// line two
// line three
```

## Scenario: Append Text to Multiple Lines

```
item1
item2
item3
```

1. `<Ctrl-v>` then `2j` -- select the column
2. `$` -- extend selection to end of each line
3. `A` -- enter append mode (capital A)
4. Type `,` (or any suffix)
5. `<Esc>` -- applied to all lines

Result:
```
item1,
item2,
item3,
```

## Scenario: Delete a Column

If you have aligned text and want to remove a column:

1. `<Ctrl-v>` -- block visual
2. Move to select the rectangular region (e.g., `3j10l`)
3. `d` -- delete the block

## Scenario: Replace a Column

1. `<Ctrl-v>` -- select the column
2. `c` -- change (deletes the block and enters insert mode)
3. Type the replacement
4. `<Esc>` -- applied to all lines

---

# 63. Working with Multiple Files

## Opening Several Files

| Method | How |
| --- | --- |
| From command line | `nvim file1.py file2.py file3.py` (opens all as buffers) |
| From inside Neovim | `<Space>ff` to find and open files one at a time |
| Split open | `:vs file2.py` opens file2 in a vertical split next to current file |
| Tab open | `:tabe file2.py` opens in a new tab |
| From file tree | `<Space>s`, navigate to file, press `<Tab>` to open without leaving the tree |

## Comparing Two Files Side by Side

1. Open the first file
2. `:vs second_file.py` -- open the second file in a vertical split
3. Now both files are visible side-by-side
4. Use `<Ctrl-w>h` / `<Ctrl-w>l` to switch between them
5. Use `:diffthis` in each window to enable diff mode (highlights differences)
6. `:diffoff` to turn diff off

Or use the diffview plugin: `:DiffviewOpen` for git diffs.

## Copying Between Files

1. In file A: select text with `V` or `v`, then `y` to yank
2. Switch to file B: `<Ctrl-w>l` or `gb` or `<Space>bp`
3. Navigate to where you want the text
4. `p` to paste

Since clipboard is `unnamedplus`, yanked text is shared across all buffers and even with external applications.

## Running the Same Edit Across Multiple Files

Use the quickfix list:

1. `:grep "TODO"` -- find all files with "TODO"
2. `:cfdo %s/TODO/DONE/g | update` -- replace in every file of the list and save it

## Closing Files You're Done With

| Keymap | What it does |
| --- | --- |
| `\d` | Close current buffer, keep window |
| `\D` | Close all other buffers EXCEPT those with unsaved changes or a still-running terminal (one message says how many were kept) |
| `<Space>q` | Save the buffer if modified, then close the window (last window: quits nvim) |

---

# 64. Everyday Editing Scenarios

## Swap Two Lines

1. On the first line: `dd` (cut it)
2. Move to where you want it: `j` or `k`
3. `P` (paste above) or `p` (paste below)

Or use `<Alt-j>` / `<Alt-k>` to move lines up/down without cutting.

## Swap Two Words

Plugin: **vim-swap**. Put the cursor on an item of a comma-separated list (function arguments) and press `gs`: this starts "swap mode". There `h`/`l` move the current item left/right (swap with its neighbour), `j`/`k` choose another item, `1`-`9` choose the nth item, `s`/`S` sort ascending/descending, `r` reverses, `u`/`<Ctrl-r>` undo/redo, `<Esc>` leaves swap mode.

For manual word swap:
1. On the first word: `diw` (delete inner word)
2. Move to the second word: `w` or `f`
3. `viwp` -- select the second word and paste (swaps them)

## Duplicate a Line

1. `yy` -- yank the line
2. `p` -- paste below

Or: `yyp` (same thing).

## Duplicate a Block of Code

1. Select the block with `V` + `j`/`k`
2. `y` -- yank
3. Navigate to destination
4. `p` -- paste

## Fix Indentation of Entire File

1. `gg=G` -- go to top, auto-indent everything to bottom

## Remove All Blank Lines

1. `:%g/^$/d` -- globally delete lines matching "empty"

## Sort Lines

1. Select lines with `V` + movement
2. `:sort` -- sort alphabetically
3. `:sort!` -- reverse sort
4. `:sort n` -- numeric sort
5. `:sort u` -- sort and remove duplicates

## Convert Tabs to Spaces (or Vice Versa)

1. `:set expandtab` (already set by default)
2. `:retab` -- convert all tabs to spaces in the file
3. Or `:set noexpandtab` then `:retab!` for spaces-to-tabs

## Wrap a Selection in a Tag/Function

1. Select text with `v` or `V`
2. `sa` + the surrounding character (vim-sandwich)
3. For example: select `myVar`, then `sa"` wraps it as `"myVar"`
4. For function: type `sa` then `f` then the function name -- wraps as `funcName(myVar)`

---

# 65. Swapping Function Arguments (`vim-swap`)

Plugin: **vim-swap**. Swap delimited items (function arguments, list elements, etc.) without cutting and pasting.

Place your cursor on one of the arguments inside parentheses:

| Keymap | What it does |
| --- | --- |
| `gs` | Start swap mode (then `h`/`l` swap with the neighbour, `j`/`k` choose an item, `1`-`9` pick an item, `<Esc>` exit) |

**Example**: Given `func(a, b, c)` with the cursor on `b`, press `gs`, then `l`: `b` moves one place right, giving `func(a, c, b)`. Press `<Esc>` to leave swap mode (tested).

Works with any comma-separated list: function arguments, array literals, dictionary entries, etc.

---

# 66. Shell Commands from Inside Neovim

## Running a Shell Command

| Command | What it does |
| --- | --- |
| `:!ls` | Run `ls` and show the output (press Enter to return) |
| `:!python %` | Run the current file with python (`%` is the current filename) |
| `:!git diff` | Run git diff without leaving Neovim |
| `:!mkdir -p src/utils` | Create directories |

## Inserting Command Output into the Buffer

| Command | What it does |
| --- | --- |
| `:read !date` | Insert the output of `date` below the cursor |
| `:read !ls` | Insert directory listing into the buffer |
| `:read !curl -s <url>` | Insert the contents of a URL |
| `:%!sort` | Replace the entire buffer with its sorted version |
| `:%!python -m json.tool` | Format the entire buffer as JSON with 4-space indent (`:JSONFormat` does the same with 2 spaces and leaves invalid JSON untouched) |

## Filtering a Selection Through a Command

1. Select lines with `V`
2. Type `:!sort` -- the selected lines are replaced with the sorted result
3. Or `:!awk '{print $2}'` -- replace with second column only

## The AsyncRun Plugin

Plugin: **asyncrun.vim**. Runs commands asynchronously (non-blocking) and sends output to the quickfix list.

| Command | What it does |
| --- | --- |
| `:AsyncRun make` | Run make in the background, results go to quickfix |
| `:AsyncRun python %` | Run current file, output in quickfix |

The quickfix window auto-opens (6 lines tall) when AsyncRun starts.

---

# 67. Multi-File Search and Replace (Complete Guide)

This is the section you need when you want to find or replace text across your entire project -- not just the current file.

## Quick Decision Guide: Which Method to Use

| Scenario | Best method |
| --- | --- |
| Rename a function/variable/class (code-aware) | **LSP Rename** (`<Space>rn`) |
| Replace a plain string in many files | **`:grep` + `:cfdo`** |
| Replace only in certain file types (e.g., only `.py`) | **`:grep --type` or `:vimgrep`, then `:cfdo`** |
| Just find where something is used (no replace) | **`<Space>fg`** (live grep) |
| Replace with confirmation for each occurrence | **`:cfdo` with the `gc` flag** |

---

## Method 1: LSP Rename (Best for Code Symbols)

If you're renaming a function, variable, class, or any code symbol, this is the best method because it understands scope and language semantics.

1. Place cursor on the symbol you want to rename
2. Press `<Space>rn`
3. Type the new name
4. Press `<Enter>`

**What happens**: The LSP server finds every reference to that symbol across the entire project and renames them all. It's smart: renaming `count` in one function won't affect `count` in another function.

**Limitations**: Only works for code symbols (not arbitrary text), and requires an LSP server that supports rename.

---

## Method 2: `:grep` + `:cfdo` (Best for Plain Text)

This is the most versatile method. It uses ripgrep (very fast) to search the entire project, puts results in the quickfix list, then runs a command on each file of the list.

**Why `:cfdo` and not `:cdo`**: `:grep` here creates ONE quickfix entry per match. `:cdo s/x/y/g` visits a line once per match; after the first visit replaced every `x` on the line, the next visit finds nothing and stops with `E486: Pattern not found` (tested), so the rest is NOT replaced. `:cfdo %s/x/y/g` runs once per file and avoids this. If you prefer `:cdo`, add the `e` flag: `:cdo s/x/y/ge | update`.

### Step-by-Step: Replace All Without Confirmation

```
:grep "oldFunction"                       -- search entire project
:cfdo %s/oldFunction/newFunction/g | update   -- replace in every matching file and save it
```

### Step-by-Step: Replace with Confirmation for Each Occurrence

```
:grep "oldFunction"                       -- search entire project
:cfdo %s/oldFunction/newFunction/gc | update  -- 'c' flag asks y/n for EACH occurrence
```

When the `c` flag is active, for each match you see it highlighted and can press:
- `y` to replace this one
- `n` to skip this one
- `a` to replace all remaining in this file (then moves to the next file, where you are prompted again; tested)
- `q` to stop entirely

### Step-by-Step: Review Results Before Replacing

```
:grep "oldFunction"                       -- search entire project
:copen                                    -- open the quickfix window to review all results
```

Now you can see every file and line that matches. Use `:cnext`/`:cprev` (or `j`/`k` in the quickfix window then `<Enter>`) to jump through them. Once satisfied:

```
:cfdo %s/oldFunction/newFunction/g | update   -- replace and save
```

### Using Regex with `:grep`

`:grep` passes the pattern directly to ripgrep, so you can use ripgrep regex. It is smart-case: an all-lowercase pattern ignores case, a pattern with a capital is exact (add `-s` to force exact case):

| Command | What it finds |
| --- | --- |
| `:grep "TODO"` | All lines containing `TODO` |
| `:grep "TODO\|FIXME"` | Lines with `TODO` or `FIXME` (type `\|` with the backslash; a rendered table may hide it) |
| `:grep "\buser\b"` | Only the whole word `user` |
| `:grep "def \w+\("` | Python function definitions |
| `:grep "console\.log"` | All `console.log` calls |

### Limiting to Specific File Types

Ripgrep supports file type filters:

| Command | What it searches |
| --- | --- |
| `:grep "pattern" --type py` | Only Python files |
| `:grep "pattern" --type js` | Only JavaScript files |
| `:grep "pattern" --type java` | Only Java files |
| `:grep "pattern" src/` | Only files in the `src/` directory |
| `:grep "pattern" --glob "*.tsx"` | Only `.tsx` files |

---

## Method 3: `:vimgrep` + `:cfdo` (Built-in, Slower but Portable)

`:vimgrep` is Vim's built-in search (doesn't require ripgrep). It's slower but lets you use Vim regex and file glob patterns:

| Command | What it does |
| --- | --- |
| `:vimgrep /pattern/ **/*` | Search all files recursively |
| `:vimgrep /pattern/ **/*.py` | Search only Python files |
| `:vimgrep /pattern/ **/*.{js,ts}` | Search JS and TS files |
| `:vimgrep /pattern/ src/**/*` | Search only in `src/` directory |

Then use `:cfdo` as before:

```
:vimgrep /oldName/ **/*.java
:cfdo %s/oldName/newName/g | update
```

---

## Method 4: `<Space>fg` for Finding (No Replace)

`<Space>fg` (live grep via fzf-lua) is the fastest way to **find** where something is used, but it doesn't directly support replace. Use it for:

- Exploring: "Where is this function called?"
- Investigating: "Which files reference this config key?"
- Planning: "How many places use this pattern?" before deciding on a replace strategy

After reviewing results in fzf, you can then use `:grep` + `:cfdo` for the actual replacement.

---

## Complete Examples

### Example 1: Rename an API Endpoint Across the Project

You renamed `/api/users` to `/api/v2/users`:

```
:grep "/api/users"                        -- find all references
:copen                                    -- review: make sure you're not catching wrong things
:cfdo %s#/api/users#/api/v2/users#g | update   -- replace (using # as delimiter since / is in the text) and save
```

### Example 2: Replace a Deprecated Function Name (with Confirmation)

```
:grep "getUser"
:cfdo %s/getUser/fetchUser/gc | update   -- confirm each one ('y' to replace, 'n' to skip)
```

### Example 3: Delete All Console.log Statements in JavaScript Files

```
:grep "console\.log" --type js            -- find them
:cfdo g/console\.log/d                    -- delete every line containing the match
:cfdo update                              -- save the files
```

### Example 4: Add a Comment Before Every TODO

```
:grep "TODO"
:cfdo %s/TODO/NOTE: was TODO/g | update
```

### Example 5: Replace Only in Python Files in the src/ Directory

```
:grep "old_function" --type py src/
:cfdo %s/old_function/new_function/g | update
```

### Example 6: Case-Insensitive Project-Wide Replace

```
:grep -i "oldname"                        -- ripgrep's -i flag for case-insensitive
:cfdo %s/oldname/newname/g | update       -- :s already ignores case in this config
```

---

## Understanding `:cdo` vs `:cfdo` vs `:bufdo`

| Command | What it does |
| --- | --- |
| `:cdo {cmd}` | Run `{cmd}` on every **line** in the quickfix list (may visit the same file multiple times) |
| `:cfdo {cmd}` | Run `{cmd}` once per **file** in the quickfix list (visits each file only once) |
| `:bufdo {cmd}` | Run `{cmd}` on every **open buffer** (not just quickfix results) |

For search-and-replace use `:cfdo %s/old/new/g` (see Method 2 for why a plain `:cdo s/old/new/g` can stop early). `:cdo` is fine for commands that act on the entry's line once, or with the `e` flag.

---

## Undoing a Multi-File Replace

If the replace went wrong, each file has its own undo history:

1. `:cfdo undo` -- undo the last change in every affected file
2. `:cfdo update` -- save the reverted files

Or use `:cfdo earlier 1f` to go back one save-state in each file (both recipes tested: both files were restored exactly).

---

# 68. Useful Vim Tricks

## Run a Normal-Mode Command on Every Line

`:g/pattern/normal @a` -- run macro `a` on every line matching `pattern`
`:g/pattern/normal dd` -- delete every line matching `pattern`
`:v/pattern/normal dd` -- delete every line NOT matching `pattern` (inverse)

## Execute a Command on a Range

`:10,20normal A;` -- append semicolons to lines 10-20
`:10,20normal I// ` -- comment out lines 10-20
`:'<,'>normal @a` -- run macro `a` on visually selected lines

## Increment/Decrement Numbers

| Keymap | What it does |
| --- | --- |
| `<Ctrl-a>` | Increment the number under cursor |
| `<Ctrl-x>` | Decrement the number under cursor |
| `10<Ctrl-a>` | Add 10 to the number |
| `g<Ctrl-a>` (visual block) | Sequential increment: line 1 gets +1, line 2 gets +2, line 3 gets +3... |
| `g<Ctrl-x>` (visual block) | Sequential decrement (same idea, subtracting) |

**Scenario**: Generate a numbered list. Type `0.` on 5 lines, select them with `<Ctrl-v>`, then `g<Ctrl-a>` turns them into `1. 2. 3. 4. 5.`

**Important**: `g<Ctrl-a>` doesn't "know" what you want incremented -- it purely acts on whatever number the highlighted column(s) overlap on each line, ignoring every other number on the line. Wherever you place the block is what gets incremented. Only the digits inside the block count as the number.

**Gotcha -- starting value**: because it *adds* `1×n` to each line, starting from `1` gives `1+1=2, 1+2=3, 1+3=4...` (starts at 2, not 1). If you want the sequence to start at 1, your placeholder number must start at `0`.

**Example 1 -- single number on the line (increments normally):**

```
imgur_japan_0.jpg
imgur_japan_0.jpg
imgur_japan_0.jpg
```

Put the cursor on the `0`, `<Ctrl-v>`, `G` to extend the block down that same column to the last line, then `g<Ctrl-a>`:

```
imgur_japan_1.jpg
imgur_japan_2.jpg
imgur_japan_3.jpg
```

**Example 2 -- two numbers on the line, only one should change:**

```
0001-photo-0.jpg
0001-photo-0.jpg
0001-photo-0.jpg
```

Here `0001` is a fixed ID that must stay identical on every line, and only the trailing `0` should become sequential. Place the cursor on the trailing `0` (not on `0001`), `<Ctrl-v>`, `G`, `g<Ctrl-a>`:

```
0001-photo-1.jpg
0001-photo-2.jpg
0001-photo-3.jpg
```

The `0001` is left untouched because the visual-block column never overlapped it -- only the number your block touches gets incremented, no matter how many other numbers appear elsewhere on the line.

**Common use case**: renaming a batch of files. Open the filenames in a buffer (e.g. via a bulk-rename tool that spawns `$EDITOR` with one filename per line, in file order), reduce every line to the same placeholder with `:%s/.*/newname_0.jpg/`, then apply the block-select + `g<Ctrl-a>` trick above to turn the shared `0` into a sequence.

**Example 3 -- starting the sequence at 0 instead of 1:**

`g<Ctrl-a>` always adds `1×n`, so it naturally starts at 1. To start at 0, do the sequential increment first, then shift the whole result down by one with a **plain** (non-`g`) `<Ctrl-x>` on the same block -- plain block increment/decrement applies the *same* amount to every line instead of a growing amount:

```
newname_0.jpg          newname_1.jpg          newname_0.jpg
newname_0.jpg   g<C-a>  newname_2.jpg  <C-x>   newname_1.jpg
newname_0.jpg   ----->  newname_3.jpg  ----->  newname_2.jpg
newname_0.jpg           newname_4.jpg          newname_3.jpg
```

Reselect the exact same column block before pressing `<Ctrl-x>` (block selections don't persist across a `g<Ctrl-a>` -- you need `<Ctrl-v>` + `G` again). This same "sequential increment, then uniform shift" combo also works for shifting a sequence to start at any number.

**Example 4 -- multi-digit, zero-padded numbers:**

Vim preserves the digit width/leading zeros automatically as long as you don't overflow it:

```
photo_001.jpg
photo_001.jpg
photo_001.jpg
```

Put the cursor on the first `0` of `001`, widen the block over all three digits (`<Ctrl-v>ll`, then `G`), then `g<Ctrl-a>`:

```
photo_002.jpg
photo_003.jpg
photo_004.jpg
```

Warning: a block that covers only part of the digits increments only those digits (cursor on the first `0` with a 1-column block gives `photo_101.jpg`, `photo_201.jpg`, ...). Leading zeros are kept as long as the number does not outgrow its width (tested).

If you want it to start at `001` instead of `002`, apply the same Example 3 shift: reselect the block, plain `<Ctrl-x>` once.

## Letter Sequences (a, b, c...) Instead of Numbers

`<Ctrl-a>`/`<Ctrl-x>` and their `g`-prefixed block variants also work on **letters**, but only once you opt in, since alphabetic increment isn't in Neovim's default `nrformats`:

```
:set nrformats+=alpha
```

(Add this to your Neovim config if you want it permanently; otherwise it only applies to the current session.)

With that set, bulk-renaming to `a, b, c, d...` works the same way as numbers:

```
a
a          g<C-a>     b
a   ----->  c
a           d
```

Note this starts at `b`, not `a` -- same off-by-one as numbers, fixed the same way (Example 3): reselect the block and press plain `<Ctrl-x>` once to shift down:

```
b          a
c   <C-x>  b
d  ----->  c
e          d
```

`<Ctrl-a>`/`<Ctrl-x>` do NOT wrap at the alphabet boundary: `<Ctrl-a>` on `z` (or `Z`) leaves it unchanged (tested). Case is kept (`a` -> `b`, `A` -> `B`).

## Open the File Under Cursor

| Keymap | What it does |
| --- | --- |
| `gf` | Open the file path under cursor (if it exists) |
| `<Ctrl-w>f` | Open file under cursor in a split |
| `gx` | Open the URL **or file** under the cursor (gx.nvim; also on a Visual selection) |

## Change Case

| Keymap | What it does |
| --- | --- |
| `~` | Toggle case of character(s). Since `tildeop` is set, use with a motion: `~w` toggles case of a word, `~e` to end of word. |
| `gUiw` | Uppercase the entire word |
| `guiw` | Lowercase the entire word |
| `gUU` | Uppercase the entire line |
| `guu` | Lowercase the entire line |
| (in insert mode) `<Ctrl-u>` | Uppercase the current word (custom; the word touching the cursor, or the previous word if only spaces are before the cursor) |
| (in insert mode) `<Ctrl-t>` | Toggle the case of the first letter of the current word (custom; `foo` <-> `Foo`) |

## Align Text

Plugin: **tabular**. Aligns text around a character. `:Tabularize` works in every filetype from a fresh start (it loads on the first `:Tabularize`, and with the first Markdown file).

| Command | What it does |
| --- | --- |
| `:Tabularize /=` | Align all `=` signs in a selection or file |
| `:Tabularize /:` | Align colons (for JSON/YAML-like structures) |

To align the pipes of a Markdown table, type `:Tabularize /|` (shown outside the table because a pipe breaks a table row).

## Command Abbreviations

This config sets some command abbreviations (type the short form as the first word of the command line, then press space or Enter):

| Short | Expands to |
| --- | --- |
| `git` | `Git` (fugitive; only inside a git repository) |
| `man` | `Man` (manual pages) |
| `edit` | `Edit` (multi-file edit) |
| `pi` | `Lazy install` |
| `pud` | `Lazy update` |
| `pc` | `Lazy clean` |
| `ps` | `Lazy sync` |
| `z` | `Z` (zoxide jump; only when it is the whole command so far) |
| `norm` | `Norm` (`:norm` with a live preview while you type) |

Two insert-mode abbreviations fix typos: `reqire` -> `require`, `serveral` -> `several`.

---

# 69. Tips for Vim Beginners

## The Most Important Habits

1. **Stay in Normal mode**. Only enter Insert mode to type, then immediately `<Esc>` back. Normal mode is where all the power lives.
2. **Think in verbs + nouns**. `d` (delete) + `iw` (inner word) = delete word. `c` (change) + `i"` (inside quotes) = change quoted text. `y` (yank) + `ap` (around paragraph) = copy paragraph.
3. **Use `.` aggressively**. Make one change, then `.` to repeat it everywhere.
4. **Use `*` and `n`**. Search for a word with `*`, jump through occurrences with `n`.
5. **Use text objects**. `ciw`, `di(`, `va"` are faster than selecting character-by-character.
6. **Press `<Space>` and wait**. The which-key popup shows you all available keybindings.

## Common Mistakes and How to Fix Them

| Problem | Cause | Fix |
| --- | --- | --- |
| Typing random commands instead of text | You're in Normal mode | Press `i` to enter Insert mode first |
| Text won't stop appearing | You're in Insert mode | Press `<Esc>` to go back to Normal |
| Screen looks weird / frozen | You pressed `<Ctrl-s>` (terminal freeze) | Press `<Ctrl-q>` to unfreeze <!-- CHECK-USER: does Ctrl-s still freeze the screen in your terminal/tmux while nvim runs? In Insert/Select mode Ctrl-s is LSP signature help --> |
| Can't exit Neovim | | Type `<Space>Q` and answer `y` to the confirmation, or `;qa!<Enter>` (no confirmation) |
| Pasted text looks wrong | Paste from outside with `<Ctrl-v>` in terminal mode | Use `"+p` in Normal mode, or the terminal paste key |
| Search highlight won't go away | Yellow boxes left over from a search or `*` | Type `;noh<Enter>` (tested). `<Esc>` does **not** clear it in this config |
| Accidentally opened a macro | Pressed `Q` | Press `q` to stop recording |
| A key like `"` does nothing until you press another key, or an accented letter appears (`ë`, `è`) | Your keyboard layout uses **dead keys** (see below) | Press `<Space>` right after the key |

## Keyboard Layouts With Dead Keys (for example US International)

Some layouts (for example US International, used on the main machine) treat certain keys as **dead keys**: the key does not type anything by itself, it waits for the next key to decide. `"` followed by `e` gives `ë`; `"` followed by `<Space>` gives a plain `"`. Neovim only receives the character after that decision, so commands that need `"` look like they do nothing.

- **Symptom (tested with `"`)**: `vt"l` selected nothing, because `t` kept waiting for its character. `vt"<Space>l` works. In a search, `v/"<Enter>` worked because `<Enter>` also ends the wait.
- **The rule**: after a dead key, press `<Space>` before continuing (`vt"<Space>l`).
- **Keys that may be affected** (not confirmed, depends on the layout; `"` is the only one tested): `'` and `` ` `` (marks such as `` `a `` and `'a`), `"` (registers such as `"ay`, text objects such as `ci"`), `~` (toggle case) and `^` (start of line). Without the space, a dead key followed by a letter can become an accented letter (`"a` -> `ä`, `` `a `` -> `à`) and the Vim command never runs.
- **This is not Neovim**: it happens in any application with that layout. A different PC may have a different layout, so if a key does nothing or types a strange character, check the layout before suspecting the config.
- **Quick test in Insert mode**: type the key, then a letter (`"e`); if you get an accented letter, it is a dead key on your layout.

## Learning Path

1. First week: `h j k l`, `i`, `<Esc>`, `:w`, `:q`, `dd`, `yy`, `p`, `u`
2. Second week: `w`, `b`, `e`, `0`, `$`, `gg`, `G`, `/search`, `n`, `N`
3. Third week: `ciw`, `di(`, `vi"`, `V`, `>`, `<`, `.`
4. Fourth week: `<Space>ff`, `<Space>fg`, `gd`, `K`, `<Space>ca`, `gcc`
5. After that: Macros, quickfix, text objects, splits, registers

---

# 70. The Verb + Noun System (How Vim Commands Work)

This is the single most important mental model for understanding Vim. Almost every command follows this pattern:

**`[count] operator motion`** or **`[count] operator text-object`**

- **Operator** (verb): What you want to do (`d` delete, `c` change, `y` yank, `>` indent, `gU` uppercase, etc.)
- **Motion** (noun): Where to do it (`w` word, `$` end of line, `gg` top of file, `}` next paragraph, etc.)
- **Text object** (noun): A structural unit to act on (`iw` inner word, `i(` inside parentheses, `at` around an HTML tag, etc.)
- **Count**: How many times (optional)

## Operators (Verbs)

| Operator | What it does |
| --- | --- |
| `d` | **Delete** (and cut to register) |
| `c` | **Change** (delete and enter insert mode) |
| `y` | **Yank** (copy) |
| `>` | **Indent** right |
| `<` | **Indent** left |
| `=` | **Auto-indent** (fix indentation) |
| `gU` | Convert to **UPPERCASE** |
| `gu` | Convert to **lowercase** |
| `~` | **Toggle case** (in this config `~` is an operator because `tildeop` is set) |
| `gc` | **Toggle comment** (vim-commentary) |
| `gcs` / `gcr` | **Comment** / **uncomment** whole rows (smart commenting) |
| `gq` | **Format/wrap** text |

## Motions (Nouns)

| Motion | What it means |
| --- | --- |
| `w` | To start of next word |
| `b` | To start of previous word |
| `e` | To end of current/next word |
| `$` | To end of line |
| `0` | To start of line |
| `^` | To first non-whitespace |
| `gg` | To top of file |
| `G` | To bottom of file |
| `}` | To next blank line |
| `{` | To previous blank line |
| `%` | To matching bracket |
| `j` | Down one line |
| `k` | Up one line |

## Text Objects (Structured Nouns)

| Text Object | What it selects |
| --- | --- |
| `iw` / `aw` | Inner word / a word (with whitespace) |
| `iW` / `aW` | Inner WORD / a WORD |
| `is` / `as` | Inner sentence / a sentence (with trailing whitespace) |
| `iS` / `aS` | vim-sandwich "query" object: type the surrounding character after it, e.g. `diS(`, `caS"`, `viS[` (inside / around that surrounding pair) |
| `ip` / `ap` | Inner paragraph / a paragraph |
| `i(` / `a(` | Inside / around parentheses |
| `i{` / `a{` | Inside / around braces |
| `i[` / `a[` | Inside / around brackets |
| `i"` / `a"` | Inside / around double quotes |
| `i'` / `a'` | Inside / around single quotes |
| `it` / `at` | Inside / around HTML tags |

## Combining Verbs and Nouns

Every operator works with every motion and every text object. This creates hundreds of commands from a small set of building blocks:

| Command | Verb | Noun | What it does |
| --- | --- | --- | --- |
| `dw` | delete | word forward | Delete from cursor to next word |
| `diw` | delete | inner word | Delete the word under cursor |
| `daw` | delete | a word | Delete word + surrounding whitespace |
| `di(` | delete | inside parentheses | Delete everything inside `(...)` |
| `da(` | delete | around parentheses | Delete everything including the `(` `)` |
| `di"` | delete | inside quotes | Delete everything inside `"..."` |
| `d$` | delete | to end of line | Delete from cursor to line end |
| `dG` | delete | to end of file | Delete from here to bottom of file |
| `d}` | delete | to next paragraph | Delete to next blank line |
| `ciw` | change | inner word | Delete word, enter insert mode |
| `ci(` | change | inside parens | Delete contents of parens, enter insert |
| `ci"` | change | inside quotes | Delete quoted text, enter insert |
| `cit` | change | inside HTML tag | Delete tag content, enter insert |
| `yiw` | yank | inner word | Copy the word under cursor |
| `yi{` | yank | inside braces | Copy contents of `{...}` |
| `yap` | yank | a paragraph | Copy the paragraph |
| `>ip` | indent | inner paragraph | Indent the current paragraph |
| `=i{` | auto-indent | inside braces | Fix indentation inside `{...}` |
| `gUiw` | uppercase | inner word | Uppercase the entire word |
| `guap` | lowercase | a paragraph | Lowercase the entire paragraph |
| `gcip` | comment | inner paragraph | Comment out the paragraph |
| `gc3j` | comment | 3 lines down | Comment out 3 lines |

## Using Counts

Counts multiply the action:

| Command | What it does |
| --- | --- |
| `3dw` | Delete 3 words |
| `5dd` | Delete 5 lines |
| `2yy` | Yank 2 lines |
| `3>>` | Indent 3 lines |
| `10j` | Move down 10 lines |

## Why This Matters

Once you learn a few operators and a few motions/text-objects, you can combine them freely. Learning one new operator (e.g., `gU` for uppercase) instantly gives you dozens of new commands (`gUiw`, `gUi"`, `gU$`, `gUap`, etc.) without memorizing anything extra.

---

# 71. The Global Command (`:g`)

The global command runs an Ex command on every line matching a pattern. It's one of the most powerful built-in features.

**Syntax**: `:g/pattern/command`

The inverse (`:v`) runs on lines that do NOT match: `:v/pattern/command`

## Common Uses

| Command | What it does |
| --- | --- |
| `:g/TODO/d` | Delete every line containing `TODO` |
| `:v/TODO/d` | Delete every line that does NOT contain `TODO` (keep only TODO lines) |
| `:g/^$/d` | Delete all blank lines |
| `:g/^\s*$/d` | Delete all blank lines (including whitespace-only) |
| `:g/console\.log/d` | Delete all console.log lines |
| `:g/pattern/normal @a` | Run macro `a` on every matching line |
| `:g/pattern/normal A;` | Append semicolon to every matching line |
| `:g/pattern/normal I// ` | Comment out every matching line |
| `:g/pattern/t $` | Copy every matching line to the end of file |
| `:g/pattern/m 0` | Move every matching line to the top of file |
| `:g/^import/normal >>` | Indent all import lines |

## Everyday Scenarios

### Delete All Print/Debug Statements

```
:g/print(/d                     -- Python: delete all print() lines
:g/console\.log/d               -- JS: delete all console.log lines
:g/System\.out\.print/d         -- Java: delete all System.out.println lines
:g/fmt\.Print/d                 -- Go: delete all fmt.Print lines
```

### Keep Only Lines Matching a Pattern

```
:v/error/d                      -- keep only lines containing "error"
:v/\v(import|from)/d            -- keep only import statements
```

### Extract All Function Signatures

```
:v/\vdef \w+\(/d                -- Python: keep only function definitions
:v/\v(public|private|protected)/d  -- Java: keep only method/field declarations
```

### Add Prefix/Suffix to Matching Lines

```
:g/TODO/normal I[URGENT] 	     -- add "[URGENT] " before every TODO line
:g/^#/normal A <!---->          -- add comment marker after every markdown heading
```

### Sort Lines Matching a Pattern to Top

```
:g/import/m 0                   -- move all import lines to the top of the file
```

---

# 72. Saving, Quitting, and File State

All the ways to save and quit, consolidated in one place.

## Saving

| Keymap / Command | What it does |
| --- | --- |
| `<Space>w` | Save the current buffer (`:update` -- only writes if modified) |
| `:w` | Save the current buffer |
| `:w filename.txt` | Save as a new file (original stays open) |
| `:wall` or `:wa` | Save ALL open buffers |
| `:saveas filename.txt` | Save as new file AND switch to it |

Auto-save is also active: files save on `FocusLost` (switching to another app) and `BufLeave` (switching buffers).

## Quitting

| Keymap / Command | What it does |
| --- | --- |
| `<Space>q` | Save and quit the current window (`:x`) |
| `<Space>Q` | Force quit all windows (`:qa!`) after a Yes/No confirmation |
| `:q` | Quit current window (fails if unsaved changes) |
| `:q!` | Quit current window, discard unsaved changes |
| `:qa` | Quit all windows (fails if any unsaved) |
| `:qa!` | Quit all windows, discard all unsaved changes |
| `:wq` | Save and quit current window |
| `:wqa` | Save all and quit all |
| `ZZ` | Save and quit (same as `:wq`) |
| `ZQ` | Quit without saving (same as `:q!`) |

## Closing Buffers (Without Quitting Neovim)

| Keymap | What it does |
| --- | --- |
| `\d` | Close current buffer, keep the window (shows previous buffer) |
| `\D` | Close all other buffers; buffers with unsaved changes and running terminals (Claude panel, `:terminal`) are kept, with one warning |

---

# 73. Recovering from Mistakes

## Undo and Redo

| Keymap | What it does |
| --- | --- |
| `u` | Undo the last change |
| `<Ctrl-r>` | Redo (undo the undo) |
| `U` | Undo all changes on the current line (rarely used) |

## Undo Tree (builtin)

Vim's undo history is a tree, not a linear stack. If you undo several times and then make a new edit, the old states aren't lost -- they become branches. Neovim's builtin undo tree (`nvim.undotree`) shows this tree.

| Keymap | What it does |
| --- | --- |
| `<Space>u` | Toggle a 30-column undo tree panel on the far left |

Inside the panel just move the cursor (`j`/`k`): the buffer switches to that undo state. Close it with `<Space>u` again or `:q`.

## Time-Based Undo

| Command | What it does |
| --- | --- |
| `:earlier 5m` | Restore the file to how it was **5 minutes ago** |
| `:earlier 1h` | Restore to **1 hour ago** |
| `:earlier 10` | Undo 10 changes |
| `:later 5m` | Go forward 5 minutes (redo) |
| `:earlier 1f` | Go back to the state before the last file save |

This works because Neovim stores persistent undo history (the `undofile` option is enabled). Even if you close and reopen a file, you can still undo.

## If You Accidentally Deleted a File

The `auto-save.nvim` plugin saves when you leave a buffer or Neovim loses focus, and Neovim creates backups in `~/.local/share/nvim/backup/`. You may be able to recover from there.

---

# 74. Discovering Keymaps and Getting Help

## Which-Key: See Available Keybindings

Press **`<Space>`** (the leader key) and **wait about 200ms**. A popup appears showing every available `<Space>+...` keybinding organized by category.

You can also press any partial key sequence and wait:
- `g` then wait -- shows all `g...` keybindings
- `z` then wait -- shows all `z...` keybindings (folding, spelling, etc.)
- `<Ctrl-w>` then wait -- shows all window management keybindings
- `"` then wait -- shows all registers

## Browse All Keymaps

| Command | What it does |
| --- | --- |
| `:Telescope keymaps` | Searchable list of all defined keymaps |
| `m` on the dashboard | Search keymaps (fzf-lua) |
| `:map` | Show all mappings (raw output) |
| `:nmap` | Show normal-mode mappings |
| `:imap` | Show insert-mode mappings |
| `:vmap` | Show visual-mode mappings |
| `:verbose nmap <Space>fg` | Show exactly where a specific mapping was defined (file + line) |

## Getting Help

| Command | What it does |
| --- | --- |
| `:help keyword` | Open Neovim's built-in help for any topic |
| `:help ciw` | Help on the `ciw` motion |
| `:help :substitute` | Help on the substitute command |
| `<Space>fh` | Fuzzy search help tags |
| `K` (on a symbol) | LSP hover documentation |

## Checking System Health

| Command | What it does |
| --- | --- |
| `:checkhealth` | Diagnose installation issues (LSP servers, providers, etc.) |
| `:LspInfo` | LSP status: opens `:checkhealth vim.lsp` (clients and configuration) |
| `:LspAttached` | Popup with the LSP servers attached to this buffer |
| `:Lazy` | Open the plugin manager |
| `:messages` | Show recent notification messages |

---

# 75. Real-World Developer Workflows

Step-by-step walkthroughs of common developer tasks entirely within Neovim.

## Workflow: Investigating a Bug

1. `<Space>fg` -- search for the error message text across the project
2. `<Enter>` on the relevant result -- jumps to the file and line
3. `gd` -- go to the definition of the function that causes the error
4. `K` -- read the function's documentation
5. `<Space>gr` -- see everywhere this function is called (glance references)
6. `<Ctrl-o>` -- jump back to where you were
7. `<Space>hb` -- check git blame: who changed this and when
8. `]c` / `[c` -- navigate to nearby git changes (hunks)
9. `<Space>hp` -- preview what the hunk changed
10. Fix the issue, `<Space>w` to save, `<Space>rr` to run and test

## Workflow: Code Review (Reviewing Your Own Changes)

1. `<Space>gs` -- open git status
2. Navigate to a changed file, press `<Enter>` to open it
3. `]c` -- jump to the first changed hunk
4. `<Space>hp` -- preview the change
5. `]c` -- next change, repeat
6. `:DiffviewOpen` -- for a full side-by-side diff of all changes
7. When satisfied: `<Space>gw` to stage, `<Space>gc` to commit

## Workflow: Refactoring a Function Name Across the Project

**If it's a code symbol (function, class, variable):**

1. Place cursor on the name
2. `<Space>rn` -- LSP rename, type new name, Enter
3. Done. All references updated intelligently.

**If it's arbitrary text (e.g., a string, API path, config key):**

1. `<Space>fg` -- search for it first, verify all the places it appears
2. `:grep "oldText"` -- populate the quickfix list
3. `:copen` -- review the matches
4. `:cfdo %s/oldText/newText/gc | update` -- replace with confirmation (`y`/`n` each) and save all files

## Workflow: Adding a Feature in a New Branch

1. `<Space>gbn` -- create a new branch (type name, Enter)
2. `<Space>s` -- open file tree, navigate to where you'll add files
3. `a` in the tree -- create a new file
4. Write code; `<Space>fm` to format; `<Space>rr` to run/test
5. `<Space>de` -- jump through any errors
6. `<Space>ca` -- apply code action fixes
7. `<Space>gw` -- stage the file
8. `<Space>gc` -- commit
9. `<Space>gpu` -- push

## Workflow: Quickly Editing a Config File

1. `<Space>ff` -- fuzzy find the config file by name
2. Make your changes
3. `<Space>w` -- save
4. If it's the Neovim config: `<Space>sv` to restart Neovim (writes all buffers, restores windows/tabs/files; terminals such as Claude Code are not restarted)

## Workflow: Working with JSON

1. Open the JSON file
2. If it's messy: `:JSONFormat` to pretty-print it
3. `<Space>fg` in another terminal to find references to JSON keys
4. `za` to fold/unfold sections for readability
5. `ci"` to change a value inside quotes
6. `<Space>w` to save

## Workflow: Writing Documentation (Markdown)

1. Open the `.md` file
2. `<Alt-m>` -- live preview in browser
3. Write content; wrapping is auto-enabled for markdown
4. `^^` -- add a footnote
5. `+` (operator) -- convert lines to a bulleted list
6. `:Tabularize /|` -- align a markdown table
7. `:AddRef label url` -- add a reference link
8. `<Space>cz` -- toggle spell check
9. `]s` / `[s` -- navigate misspelled words
10. `z=` -- fix spelling

## Workflow: Pair Programming with Split Views

1. `:vs <file>` -- open another file side-by-side
2. `<Ctrl-w>l` / `<Ctrl-w>h` -- switch between the two files
3. `van` in file A -- select the surrounding syntax node; repeat `an` to grow the selection (for example to the whole function), `in` shrinks it again; then `y` to copy
4. `<Ctrl-w>l` -- switch to file B
5. `p` -- paste the function
6. `<Ctrl-w>=` -- equalize window sizes if they got uneven
7. `<Ctrl-w>o` -- when done, close all splits except current

---

# 76. Common Editing Power Combos

Quick-reference card of the most powerful editing combinations for daily use.

## Changing Text

| Combo | What it does | Example |
| --- | --- | --- |
| `ciw` | Change the word under cursor | `foo` -> type `bar` -> `bar` |
| `ci"` | Change text in double quotes | `"old"` -> type `new` -> `"new"` |
| `ci(` | Change text in parentheses | `func(old)` -> type `new` -> `func(new)` |
| `ci{` | Change text in braces | `{old}` -> type `new` -> `{new}` |
| `cit` | Change text in HTML tag | `<p>old</p>` -> type `new` -> `<p>new</p>` |
| `cc` | Change entire line | Clears line, insert mode |
| `C` | Change from cursor to end of line | Deletes rest of line, insert mode |
| `c$` | Same as `C` | |
| `ct)` | Change from cursor to before `)` | Useful inside function arguments |
| `cf,` + char + label | Change from the cursor through a `,` picked with hop: `f` is hop's 2-character jump, so type `,` and the character after it, then the label (may be several lines away; see "Precision Selection") | `f` is hop.nvim here, not the built-in |

## Deleting Text

| Combo | What it does |
| --- | --- |
| `diw` | Delete word under cursor |
| `daw` | Delete word + surrounding spaces |
| `di"` | Empty out double-quoted string |
| `da"` | Delete the entire quoted string including quotes |
| `di(` | Empty out parentheses |
| `da(` | Delete parentheses and their contents |
| `dip` | Delete paragraph |
| `dd` | Delete line |
| `D` | Delete from cursor to end of line |
| `dt)` | Delete from cursor to before `)` |

## Copying Text

| Combo | What it does |
| --- | --- |
| `yiw` | Copy word under cursor |
| `yi"` | Copy text inside double quotes |
| `yi(` | Copy text inside parentheses |
| `yap` | Copy paragraph |
| `yy` | Copy line |
| `y$` | Copy from cursor to end of line |

## Selecting Text

| Combo | What it does |
| --- | --- |
| `viw` | Select word |
| `vi"` | Select inside quotes |
| `vi(` | Select inside parentheses |
| `vip` | Select paragraph |
| `V5j` | Select 5 lines down |
| `ggVG` | Select entire file |

## Quick Transformations

| Combo | What it does |
| --- | --- |
| `gUiw` | Uppercase word |
| `guiw` | Lowercase word |
| `~w` | Toggle case of word |
| `>>` | Indent line |
| `<<` | Deindent line |
| `==` | Auto-indent line |
| `gg=G` | Auto-indent entire file |
| `gcc` | Comment/uncomment line |
| `gcip` | Comment/uncomment paragraph |
| `saiw"` | Surround word with `"` |
| `sd"` | Remove surrounding `"` |
| `sr"'` | Replace `"` with `'` around current text |
| `J` | Join current line with next |

## The Most Powerful Patterns

| Pattern | How it works |
| --- | --- |
| `*` then `ciw` then `n.n.n.` | Find-and-replace one at a time with full control |
| `Qa` ... `q` then `@a` | Record and replay any sequence of actions |
| `V` select then `:norm @a` | Run a macro on selected lines |
| `:g/pattern/command` | Run a command on every matching line |
| `:grep "text"` then `:cfdo ...` | Project-wide search and replace (the substitute + `| update` recipe is in section 67) |
| `<Space>rn` | Intelligent rename across project |
| `qf` list + `:cnext`/`:cprev` | Jump through search results or errors |
| `.` | Repeat last change (combine with `n` for find-and-repeat) |
