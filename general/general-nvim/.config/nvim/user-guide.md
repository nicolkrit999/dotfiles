# Neovim User Guide

Leader key: `<Space>`

This guide is written for people who are new to Neovim. It covers everything you need to navigate, edit, and manage files without ever touching the mouse.

---

# 1. Understanding Modes

Neovim is a modal editor. You are always in one of these modes:

| Mode | How to enter | What it does |
| --- | --- | --- |
| **Normal** | `<Esc>` from any mode | Navigate, delete, copy, paste, run commands. This is your "home base". |
| **Insert** | `i`, `a`, `o`, `O`, `c`, `s` from Normal | Type text into the file. |
| **Visual** | `v`, `V`, `<Ctrl-v>` from Normal | Select text (character, line, or block). |
| **Command** | `;` or `:` from Normal | Type commands at the bottom of the screen (e.g., `:w` to save). |
| **Terminal** | When inside a terminal buffer | Interact with a shell. Press `<Esc>` to go to Normal mode. |

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
| `H` | Go to start of line |
| `L` | Go to end of line |
| `gg` / `G` | Go to start / end of file |
| `f` | Hop: jump to any 2-char match on screen |
| `<Space>w` | Save buffer |
| `<Space>q` | Quit current window |
| `<Space>Q` | Quit all / close Neovim |
| `<Space>s` | Toggle file explorer (nvim-tree) |
| `<Space>ff` | Fuzzy find files |
| `<Space>fg` | Project-wide text search (live grep) |
| `<Space>fr` | Recently opened files |
| `<Space>bp` | Pick buffer from list |
| `gb` / `gB` | Next / previous buffer |
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<Space>rn` | Rename symbol |
| `<Space>ca` | Code actions |
| `<Space>fm` | Format file |
| `gcc` | Toggle comment on current line |
| `gc` | Toggle comment on selection |
| `<Alt-j>` / `<Alt-k>` | Move line(s) down / up |
| `<Space>o` / `<Space>O` | Insert blank line below / above |
| `<Space>rr` | Run current file |
| `<Space>gs` | Git status |
| `<Space>cc` | Toggle Claude Code |
| `<Space>cpc` | Toggle Copilot Chat |
| `u` / `<Ctrl-r>` | Undo / redo |
| `n` / `N` | Next / previous search match (with count) |

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

## Jump Navigation with hop.nvim (Plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `f` | n, v, o | Press `f`, then type 2 characters. All matches on screen get labeled. Press the label letter to jump there instantly. Case insensitive. Press `<Esc>` to cancel. |

## Jump History

| Keymap | Description |
| --- | --- |
| `<Ctrl-o>` | Jump **back** to the previous location in the jump list |
| `<Ctrl-i>` | Jump **forward** to the next location in the jump list |

Every time you use a jump command (like `gg`, `G`, `/search`, `gd`, etc.), your position is saved. You can then go back and forth through your history with these keys.

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

All delete operations also **cut** (yank) the text into a register, so you can paste it with `p`. Exception: `c`, `C`, `cc` in this config send to the black hole register (they do NOT save to paste register).

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

**Note**: The clipboard is set to `unnamedplus`, so yanking automatically copies to the system clipboard.

## Pasting Text

| Keymap | Mode | Description |
| --- | --- | --- |
| `p` | n, x | Paste after cursor (with 300ms highlight, via yanky.nvim) |
| `P` | n, x | Paste before cursor (with 300ms highlight, via yanky.nvim) |
| `<Space>p` | n | Paste on a new line below (custom) |
| `<Space>P` | n | Paste on a new line above (custom) |
| `[y` | n | After pasting, cycle to previous yank history entry |
| `]y` | n | After pasting, cycle to next yank history entry |

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
| `<Space>u` | Open the undo tree (vim-mundo plugin) for visual undo history |

**Undo breakpoints**: Typing `,` `.` `!` `?` `;` `:` in insert mode creates undo checkpoints. This means pressing `u` after a long insert session will undo in smaller chunks instead of reverting everything at once.

## Repeating Actions

| Keymap | Description |
| --- | --- |
| `.` | Repeat the last change. Works with most editing commands. Extremely powerful: e.g., `ciw` + type new word + `<Esc>`, then move to another word and press `.` to repeat. |

## Line Operations

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Alt-j>` | n | Move current line down one position |
| `<Alt-k>` | n | Move current line up one position |
| `<Alt-j>` | v | Move selected lines down |
| `<Alt-k>` | v | Move selected lines up |
| `<Space>o` | n | Insert a blank line below (cursor stays in place) |
| `<Space>O` | n | Insert a blank line above (cursor stays in place) |
| `J` | n | Join the current line with the next line (cursor stays in place) |
| `gJ` | n | Join lines without inserting a space (cursor stays in place) |

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
| `<Ctrl-u>` | Convert the current word to UPPERCASE |
| `<Ctrl-t>` | Convert the current word to Title Case |
| `<Alt-;>` | Insert a semicolon at the end of the line (without moving cursor) |
| `<Ctrl-a>` | Jump to the beginning of the line |
| `<Ctrl-e>` | Jump to the end of the line |
| `<Ctrl-d>` | Delete the character to the right of the cursor |
| `<Ctrl-w>` | Delete the word before the cursor |
| `<Ctrl-h>` | Delete the character before the cursor (like backspace) |

## Miscellaneous Editing

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space><Space>` | n | Remove all trailing whitespace from the file |
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
| `vi(` or `vib` | Select everything **inside** `(...)` |
| `va(` or `vab` | Select everything **including** `(...)` (the parentheses themselves) |
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
| `vis` | Select the sentence under cursor |
| `vas` | Select the sentence + surrounding whitespace |
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

### Treesitter Text Objects (Plugin)

These select code structures intelligently:

| Keymap | Mode | Description |
| --- | --- | --- |
| `vaf` | x | Select around the entire function |
| `vif` | x | Select inside the function body |
| `vac` | x | Select around the entire class |
| `vic` | x | Select inside the class body |
| `daf` | n | Delete the entire function |
| `cif` | n | Change the function body |

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
- **`f` after an operator (`df,`, `cf,`) is hop, not the built-in `f`** (tested): `df,` deleted from the cursor through a comma several lines below (it was the only comma in the visible text), so it is **not limited to the current line** and the target character is **deleted too**. `cf,` deleted the same kind of range (as `c` does, it should also leave you in Insert mode; not checked). With several matches on screen, hop shows labels and you choose the target, so the deleted range depends on the label you press; check what you typed before pressing `d`/`c` on a big range (`u` undoes it).

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
- `va(` / `vi(` select the whole group / its inside, but always starting from the opening `(`, never from the cursor.

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
- `ignorecase smartcase` is on, so a lowercase pattern (`foo`) also matches `Foo`. Type a capital letter to make it case-sensitive.
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
3. `?foo<Enter>` searches **backward** from the end of the line, which should find the **last** `foo` on that line (**not confirmed**: in one real test of steps 1 to 4 on a line with several matches the user reported that the **first** match was selected, cause not found yet; re-test step by step before relying on it). (Searching forward from the middle of the line could hit an earlier, unwanted match or a capitalised one.)
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
- `gI` and the `0` + `i` combination were not tested yet in this config.

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
- **Relative addresses**: `.` is the current line and `+N` / `-N` are N lines after/before it, so they match the relative numbers in the gutter. Tested: `;.t.` duplicated the current line and left the cursor on the new copy. Standard Vim but **not tested yet**: `;.m+2` (moves the current line to below the line 2 lines down) and `;.,+3d` (deletes the current line and the next 3).
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
| Parentheses `()` | `vi(` or `vib` | `va(` or `vab` |
| Braces `{}` | `vi{` or `viB` | `va{` or `vaB` |
| Brackets `[]` | `vi[` | `va[` |
| Angle brackets `<>` | `vi<` | `va<` |
| Double quotes `""` | `vi"` | `va"` |
| Single quotes `''` | `vi'` | `va'` |
| Backticks ` `` ` | `` vi` `` | `` va` `` |
| HTML/XML tags | `vit` | `vat` |

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
| `sd(` or `sdb` | Delete surrounding parentheses | `(hello)` becomes `hello` |
| `sd{` or `sdB` | Delete surrounding curly braces | `{hello}` becomes `hello` |
| `sd[` | Delete surrounding square brackets | `[hello]` becomes `hello` |

## Replacing Surrounding Pairs (vim-sandwich Plugin)

| Keymap | Description | Example |
| --- | --- | --- |
| `sr"'` | Replace `"` with `'` | `"hello"` becomes `'hello'` |
| `sr({` | Replace `()` with `{}` | `(hello)` becomes `{hello}` |
| `sr{[` | Replace `{}` with `[]` | `{hello}` becomes `[hello]` |
| `sr'(` | Replace `'` with `()` | `'hello'` becomes `(hello)` |

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

## Creating Splits

| Keymap / Command | Description |
| --- | --- |
| `<Ctrl-w>s` or `:sp` | Split the current window **horizontally** (new window appears below) |
| `<Ctrl-w>v` or `:vs` | Split the current window **vertically** (new window appears to the right) |
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

**Auto-resize**: When you resize your terminal, all windows automatically resize equally.

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
| `<Space>q` | Close the current window (saves if modified) |
| `<Space>Q` | Close ALL windows (quit Neovim, no confirmation) |
| `:q` | Close current window |
| `:q!` | Close current window discarding unsaved changes |
| `:only` or `<Ctrl-w>o` | Close ALL other windows, keep only the current one |
| `\x` | Close the quickfix and location list windows |

## Buffer Management

| Keymap / Command | Description |
| --- | --- |
| `gb` | Go to the **next** buffer |
| `gB` | Go to the **previous** buffer |
| `<Space>bp` | **Pick** a buffer: each open buffer shows a letter, press it to switch |
| `\d` | Close/delete the current buffer (window stays open, shows previous buffer) |
| `\D` | Close all buffers **except** the current one |
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
| `:tabclose` | Close the current tab |
| `:tabonly` | Close all other tabs |

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
| `<Space>rr` | Run code (opens terminal in vertical split automatically) |

The terminal automatically starts in insert mode (you can type immediately) and hides line numbers.

## Navigating In and Out of Terminal

| Keymap | Context | Description |
| --- | --- | --- |
| `<Esc>` | In terminal | **Exit terminal mode** and enter Normal mode. Now you can navigate away from the terminal window using `<Ctrl-w>h/j/k/l` or arrow keys. |
| `i` or `a` | In terminal (Normal mode) | Re-enter terminal mode (start typing commands again) |
| `<Ctrl-w>h/j/k/l` | In terminal (Normal mode) | Move to another window |
| `<Left>/<Right>/<Up>/<Down>` | In terminal (Normal mode) | Move to another window (arrow key shortcuts) |

**Workflow example**: You run code with `<Space>rr`. A terminal opens showing output. To go back to your code: press `<Esc>` to exit terminal mode, then `<Ctrl-w>h` (or `<Left>`) to move to the code window. To close the terminal: `<Space>q` while in the terminal window.

## Closing a Terminal

| Method | Description |
| --- | --- |
| `<Space>q` | While the terminal window is focused, quit it |
| Type `exit` | In the terminal, type `exit` to end the shell process, then the window closes |
| `\d` | Delete the terminal buffer |

---

# 9. AI Assistant Windows (Copilot Chat & Claude Code)

## Copilot Chat

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>cpc` | n | **Toggle** Copilot Chat window (opens/closes it) |
| `<Space>cpe` | v | Send selected code to Copilot with "Explain" prompt |
| `<Space>cpo` | v | Send selected code to Copilot with "Optimize" prompt |

The Copilot Chat window opens as a split. Navigate to/from it with `<Ctrl-w>h/j/k/l` or arrow keys. Close it with `<Space>cpc` (toggle) or `<Space>q`.

### Copilot Inline Suggestions

Ghost text (grey text) appears as you type in insert mode:

| Keymap | Description |
| --- | --- |
| `<Tab>` | Accept the suggestion (when completion menu is NOT open) |
| `<Alt-]>` | Cycle to the next suggestion |
| `<Alt-[>` | Cycle to the previous suggestion |
| `<Ctrl-]>` | Dismiss the current suggestion |

## Claude Code

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>cc` | n | **Toggle** Claude Code terminal (opens/closes it) |
| `<Space>ct` | t | Toggle Claude Code while in terminal mode |
| `<Space>cR` | n | Resume/continue the last Claude conversation |
| `<Space>cV` | n | Start Claude in verbose mode |

Claude Code opens as a **bottom-right split** at 30% height. It is a terminal buffer. To navigate:

1. **Move to Claude window**: `<Ctrl-w>j` or `<Down>` (since it opens below)
2. **Move back to code**: `<Esc>` to exit terminal mode, then `<Ctrl-w>k` or `<Up>`
3. **Close Claude**: `<Space>cc` to toggle it closed, or `<Space>q` while focused on it
4. **Type in Claude**: If in Normal mode inside the Claude terminal, press `i` to re-enter terminal mode

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
| `*` | Search **forward** for the exact word under cursor (cursor stays on current match) |
| `#` | Search **backward** for the exact word under cursor |
| `;noh<Enter>` (`;` is `:` here) | Clear the yellow search highlight (tested). The search itself is kept, so `n` / `N` still work; the highlight comes back on the next search or `*`. |

### Search Modifiers

| Modifier | Where to put it | What it does | Example |
| --- | --- | --- | --- |
| `\c` | Anywhere in pattern | Force **case-insensitive** | `/\chello` finds `Hello`, `HELLO`, `hello` |
| `\C` | Anywhere in pattern | Force **case-sensitive** | `/\Chello` only finds `hello` |
| `\v` | At start of pattern | **Very magic**: regex works like Perl/Python (no need to escape `()`, `|`, `+`, etc.) | `/\vfunction\(.*\)` |
| `\<` and `\>` | Around pattern | **Whole word** match only | `/\<count\>` finds `count` but not `counter` |

By default, search is case-insensitive but becomes case-sensitive if you type any uppercase letter (smart case).

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
| `I` | Case-**sensitive** matching (overrides smart case) |
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
| `/gcc` | **not a listed flag combination**: `g` and `c` are valid, a second `c` adds nothing documented. Its behaviour is **not tested** (try it on a spare buffer and note whether it errors, or behaves like `/gc`) | unknown |

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
4. The cursor stays on the current match (custom behavior in this config)

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

Plugin: nvim-tree.lua. A sidebar file tree.

| Keymap | Context | Description |
| --- | --- | --- |
| `<Space>s` | global | Toggle the file explorer on/off |
| `<Enter>` | in tree | Open file (cursor moves to file) / expand directory |
| `<Tab>` | in tree | Open file but **keep cursor in the tree** (great for opening multiple files) |
| `<BS>` | in tree | Collapse / close the parent directory |
| `a` | in tree | Create a new file. Type the name and press Enter. Add `/` at the end for a directory. |
| `d` | in tree | Delete file/directory (asks for confirmation) |
| `r` | in tree | Rename file/directory |
| `c` | in tree | Copy file to clipboard |
| `x` | in tree | Cut file to clipboard |
| `p` | in tree | Paste from clipboard |
| `q` | in tree | Close the file explorer |

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
| `<Space>ft` | Search tags (functions, classes) in the current buffer |
| `<Space>fb` | Search currently open buffers |
| `<Space>fr` | Search recently opened files |

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
- Type `.env` to find environment files
- Type `test` to see all test files

## The Difference Between Search Methods

| Method | Keymap | What it searches | Best for |
| --- | --- | --- | --- |
| **Live grep** | `<Space>fg` | Text **inside** files across the entire project | Finding where code/text is used |
| **Find files** | `<Space>ff` | **File names** in the project | Opening a file by name |
| **Buffer search** | `<Space>fb` | Names of **currently open** files | Switching between open files |
| **Recent files** | `<Space>fr` | Files you **recently edited** | Returning to a file you had open earlier |
| **Buffer tags** | `<Space>ft` | Functions/classes in **current file** | Jumping to a function in the current file |
| **In-file search** | `/pattern` | Text in **current file only** | Finding something in the file you're editing |
| **Word under cursor** | `*` | Current word in **current file** | Quick highlight and jump to next occurrence |

---

# 13. LSP: Language Server Protocol

Plugin: nvim-lspconfig. Provides IDE features. Keymaps are active when an LSP server is attached.

### Configured Language Servers

| Server | Language |
| --- | --- |
| `pyright` + `ruff` | Python |
| `lua_ls` | Lua |
| `bashls` | Bash |
| `yamlls` | YAML |
| `marksman` | Markdown |
| `nixd` | Nix |
| `jdtls` | Java (via nvim-java) |
| `clangd` | C/C++ |

### LSP Keymaps

| Keymap | Description |
| --- | --- |
| `gd` | **Go to definition**: jump to where the symbol is defined |
| `K` | **Hover**: show documentation in a floating window |
| `<Space>rn` | **Rename**: rename the symbol everywhere it's used |
| `<Space>ca` | **Code action**: show available fixes/refactors |
| `<Space>fm` | **Format**: auto-format the file |

### Glance: Peek Without Jumping

Plugin: glance.nvim. Preview definitions/references in a popup, without leaving your current file.

| Keymap | Description |
| --- | --- |
| `<Space>gd` | Peek at definitions |
| `<Space>gr` | Peek at all references |
| `<Space>gi` | Peek at implementations |

### Diagnostics (Errors, Warnings)

Emoji signs in the gutter: 🆇 (error), ⚠️ (warning), ℹ️ (info). Diagnostics auto-show in a floating window when the cursor rests on a line.

| Keymap | Description |
| --- | --- |
| `<Space>db` | Show buffer diagnostics (current file) |
| `<Space>dw` | Show workspace diagnostics (all files) |
| `<Space>de` | Jump to next error |
| `<Space>dE` | Jump to previous error / show workspace errors only |
| `<Space>dd` | Show diagnostic detail in floating window |
| `<Space>dt` | Toggle diagnostics on/off |
| `<Space>qw` | Send workspace diagnostics to quickfix list |
| `<Space>qb` | Send buffer diagnostics to quickfix list |

---

# 14. Autocompletion (`nvim-cmp`)

Plugin: nvim-cmp. Sources: LSP, UltiSnips snippets, file paths, buffer words.

| Keymap | Description |
| --- | --- |
| `<Tab>` | If menu is open: select next item. If Copilot ghost text visible: accept it. Otherwise: normal tab. |
| `<CR>` (Enter) | Confirm the selected completion |
| `<Ctrl-e>` | Dismiss / close the completion menu |
| `<Esc>` | Close the completion menu |
| `<Ctrl-d>` | Scroll documentation popup down |
| `<Ctrl-f>` | Scroll documentation popup up |

---

# 15. Snippets (`UltiSnips`)

Plugin: UltiSnips + vim-snippets. Custom snippets in `my_snippets/` directory.

| Keymap | Description |
| --- | --- |
| `<Ctrl-j>` | Expand snippet / jump to next placeholder |
| `<Ctrl-k>` | Jump to previous placeholder |

Available snippet files: `all`, `cpp`, `java`, `markdown`, `nix`, `python`, `tex`, `vim`

### Java Snippets

| Trigger | Expansion |
| --- | --- |
| `startscanner` | Java Scanner input template |
| `jarr` / `jarrlit` | Array / array with literal values |
| `jdict` / `jdictfull` | HashMap / HashMap with import |
| `jfor` / `jforeach` | For loop / enhanced for loop |
| `jwhile` / `jdowhile` | While / do-while loop |
| `jif` / `jifelse` / `jifelif` | If / if-else / if-else if-else |
| `jswitchtraditional` / `jswitcharrow` / `jswitchyield` | Switch variants |
| `jtrycatch` / `jtryfinally` | Try-catch / try-catch-finally |

---

# 16. Code Commenting

## vim-commentary (Plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `gcc` | n | Toggle comment on current line |
| `gc` + motion | n | Toggle comment on a motion (e.g., `gcip` comments a paragraph) |
| `gc` | v | Toggle comment on selected lines |

## Smart Commenting (Custom)

String-aware, multi-line-capable comment add/remove (`lua/smart_comment/`).

| Keymap | Mode | Description |
| --- | --- | --- |
| `gcs` | n, x | Smart comment |
| `gcr` | n, x | Smart uncomment |

Fully supported languages: asm, bash, c, cpp, cs, css, dockerfile, fish, go,
haskell, html, java, javascript, julia, kotlin, lisp (Emacs Lisp / Common
Lisp), lua, make, markdown, nix, perl, php, ps1 (PowerShell), python, r,
ruby, rust, scala, sh, sql, swift, tex (LaTeX), toml, typescript, typst,
vim, xml, yaml, zig, zsh.

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

Plugin: nvim-ufo. Folds code blocks using LSP/Treesitter.

| Keymap | Description |
| --- | --- |
| `za` | Toggle fold at cursor |
| `zA` | Toggle all folds under cursor recursively |
| `zc` / `zo` | Close / open fold at cursor |
| `zC` / `zO` | Close / open all folds recursively |
| `zR` | Open **all** folds in the file |
| `zM` | Close **all** folds in the file |
| `zr` | Reduce folding by one level |
| `<Space>K` | Preview folded lines in a popup |
| `zi` | Toggle folding feature on/off |

---

# 19. Code Running

Custom function in `lua/mappings.lua`. Opens output in a vertical split terminal.

| Keymap | Description |
| --- | --- |
| `<Space>rr` | Run current file (auto-detects language) |

Supported: Python, Java, C, C++, C#, JavaScript, TypeScript, Go, Rust, Bash, Lua, Ruby, PHP.

After running, the terminal output appears in a split. See [Terminal Integration](#8-terminal-integration) for how to navigate to/from it and close it.

### Filetype-Specific

| Keymap | Filetype | Description |
| --- | --- | --- |
| `<F9>` | Python | Run with `python -u` |
| `<F9>` | C++ | Compile and run |
| `<F9>` | LaTeX | Compile with vimtex |

---

# 20. Git Integration

## vim-fugitive (Plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>gs` | n | Git status window |
| `<Space>gw` | n | Git add current file |
| `<Space>gc` | n | Git commit |
| `<Space>gpl` | n | Git pull |
| `<Space>gpu` | n | Git push (opens terminal split) |
| `<Space>gb` | v | Git blame selected lines |
| `<Space>gbn` | n | Create new branch (prompts for name) |
| `<Space>gbd` | n | Delete a branch |
| `<Space>gf` | n | Git fetch |

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
| `<Space>gl` | n, v | Copy permalink for current line(s) |
| `<Space>gbr` | n | Open repository in browser |

## Other Git Tools

| Plugin | Command / Trigger | Description |
| --- | --- | --- |
| neogit | `:Neogit` | Full git UI (magit-like) |
| git-conflict.nvim | Automatic | Highlights and resolves merge conflicts |
| diffview.nvim | `:DiffviewOpen` | Side-by-side diff viewer |
| vim-flog | `:Flog` | Visual git log graph |

---

# 21. Treesitter & Text Objects

## Treesitter (Plugin)

Provides improved syntax highlighting and code understanding. Auto-installs parsers for Python, C++, Lua, Vim, JSON, TOML, HTML.

## Treesitter Text Objects (Plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `af` / `if` | x, o | Select around / inside function (linewise) |
| `ac` / `ic` | x, o | Select around / inside class (linewise) |

## targets.vim (Plugin)

Adds many additional text objects for quotes, brackets, arguments, separators. Works automatically with `d`, `c`, `y`, `v`.

## vim-matchup (Plugin)

Enhanced `%` matching for language keywords (`if`/`else`/`end`, `do`/`while`, etc.). Shows offscreen match in popup.

---

# 22. Jump Navigation (`hop.nvim`)

| Keymap | Mode | Description |
| --- | --- | --- |
| `f` | n, v, o | Type `f` then 2 characters: all matches highlight with jump labels. Press the label letter to jump. Case insensitive. `<Esc>` to cancel. |

**Note**: Replaces Vim's built-in `f` motion. Use `t`/`T` for jumping to before/after a character on the current line.

---

# 23. Search Lens (`nvim-hlslens`)

| Keymap | Description |
| --- | --- |
| `n` | Next match with `[x/y]` count overlay |
| `N` | Previous match with count overlay |
| `*` | Search word under cursor forward (cursor stays) |
| `#` | Search word under cursor backward (cursor stays) |

---

# 24. Yank History (`yanky.nvim`)

| Keymap | Mode | Description |
| --- | --- | --- |
| `p` / `P` | n, x | Paste after / before (with 300ms highlight) |
| `[y` | n | After pasting, cycle to previous yank entry |
| `]y` | n | After pasting, cycle to next yank entry |

Command: `:YankyRingHistory` to browse all yank history.

---

# 25. Undo History (`vim-mundo`)

| Keymap | Description |
| --- | --- |
| `<Space>u` | Toggle undo tree panel |

Inside the panel: `j`/`k` to navigate, `<Enter>` to revert, `p` to diff, `q` to quit.

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
| `<Alt-m>` | Toggle markdown preview in browser |
| `<Shift-Alt-m>` | Stop markdown preview (macOS/Windows) |

## Footnotes

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>mf` | n | Add footnote |
| `<Space>mr` | n | Return from footnote |
| `^^` | n, i | Insert footnote number (markdown files only) |
| `@@` | n, i | Return from footnote (markdown files only) |

## Text Objects & Operators (Markdown Only)

| Keymap | Description |
| --- | --- |
| `vic` / `vac` | Select inside / around code block |
| `+` | Convert lines to unordered list (operator: `+ip` for paragraph) |
| `\` | Add hard line break to lines |
| `:AddRef <label> <url>` | Add reference link at end of buffer |

## Other Markdown Plugins

- **render-markdown.nvim**: In-editor rendering (pauses in insert mode). Max file: 1.5MB.
- **tabular**: Table alignment. Command: `:Tabularize`
- **vim-grammarous**: Grammar check (macOS only). `<Ctrl-n>`/`<Ctrl-p>` for next/prev error.

---

# 28. LaTeX Support (`vimtex`)

Only available if `latex` is installed.

| Keymap | Description |
| --- | --- |
| `<F9>` | Compile |
| `\\ll` | Compile/build |
| `\\lv` | View PDF |

---

# 29. Registers & Macros

## Registers

| Keymap | Description |
| --- | --- |
| `"3y` | Yank to register 3 |
| `"3p` | Paste from register 3 |
| `"*y` / `"+y` | Yank to system clipboard |
| `:reg` | View all registers |

**Note**: Clipboard is set to `unnamedplus`, so `y`/`p` already use the system clipboard by default.

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
| `zg` | Add word to spell dictionary |
| `zw` | Mark word as wrong |

---

# 32. Statusline (`lualine.nvim`)

| Section | Position | Contents |
| --- | --- | --- |
| A | Leftmost | Filename + readonly indicator (🔒) |
| B | Left | Git branch, ahead/behind (↑/↓), diff stats (+~-), Python venv |
| C | Center-left | Command input, spell indicator (`[SPELL]`) |
| X | Center-right | Active LSP (📡), diagnostics (🆇 ⚠️ ℹ️), trailing whitespace, mixed indent |
| Y | Right | Encoding, file format, filetype |
| Z | Rightmost | Cursor position (line:col), progress (%) |

---

# 33. UI Features

| Feature | Description |
| --- | --- |
| **which-key.nvim** | Press `<Space>` and wait: a popup shows all available leader keybindings |
| **Dashboard** | Start screen with shortcuts: Find File, Recent Files, Grep, Config, Explorer |
| **Dashboard: reopen / replace the current buffer** | `\h` opens the start screen in the current window (the previous buffer stays open in the background; inside the dashboard it only says "already in the dashboard"). `\H` closes the dashboard and returns to the previous buffer (the dashboard buffer is deleted so it does not pile up); outside the dashboard it only warns "not in the dashboard", and with no previous buffer it warns "no previous buffer to resume". Without the keys: `:Dashboard` does the same as `\h`. To close the current buffer and get the dashboard instead: `:Dashboard | bdelete #` (a buffer with unsaved changes refuses with E89). `\d` deletes the buffer but shows the previous one, not the dashboard |
| **nvim-notify** | Animated notification popups (fade + slide, 1500ms) |
| **Colorschemes** | 20+ themes, randomly selected on startup |
| **dropbar.nvim** | Breadcrumb bar at top showing file > class > function |
| **nvim-colorizer** | Color codes (hex, rgb) are highlighted with their actual color |
| **mini.indentscope** | Visual `▏` guide for current indent scope |
| **fidget.nvim** | LSP progress messages in bottom-right corner |
| **nvim-lightbulb** | Lightbulb icon when code actions are available |

---

# 34. Custom Commands

| Command | Description |
| --- | --- |
| `:CopyPath nameonly` | Copy filename to clipboard |
| `:CopyPath relative` | Copy path relative to project root |
| `:CopyPath absolute` | Copy absolute path |
| `:JSONFormat` | Format JSON (whole file or visual range) |
| `:Redir <cmd>` | Capture command output to register `@m` (paste with `"mp`) |
| `:Edit <files>` | Open multiple files |
| `:Datetime` | Show date and time |
| `:ToPDF` | Convert markdown to PDF (requires pandoc) |

### Plugin Manager Shortcuts

Type these in command mode, then press space to expand:

| Shortcut | Expands to |
| --- | --- |
| `pi` | `:Lazy install` |
| `pud` | `:Lazy update` |
| `pc` | `:Lazy clean` |
| `ps` | `:Lazy sync` |

---

# 35. Java Development (`nvim-java`)

### Build & Run

| Keymap | Description |
| --- | --- |
| `<Space>jb` | Build workspace |
| `<Space>jc` | Clean workspace |
| `<Space>jr` | Run main class |
| `<Space>js` | Stop running main |
| `<Space>jl` | Toggle runner log window |

### Testing

| Keymap | Description |
| --- | --- |
| `<Space>jt` | Run all tests in current class |
| `<Space>jT` | Debug all tests in current class |
| `<Space>jm` | Run test method under cursor |
| `<Space>jM` | Debug test method under cursor |
| `<Space>jp` | View last test report |

### Refactoring

| Keymap | Description |
| --- | --- |
| `<Space>jv` | Extract variable |
| `<Space>jo` | Extract variable (all occurrences) |
| `<Space>jj` | Change JDK runtime |
| `<Space>jd` | Configure debugger (DAP) |
| `<Space>jf` | Profiles UI |

---

# 36. Debugging

| Plugin | Keymap / Command | Description |
| --- | --- | --- |
| nvim-dap | (lazy-loaded) | Debug Adapter Protocol client. Java debugging auto-configured via nvim-java. |
| nvim-gdb | `<Space>dp` | Start PDB debugger for Python file (Linux/Windows only) |

---

# 37. Tags Navigation (`vista.vim`)

Only available if `ctags` is installed.

| Keymap | Description |
| --- | --- |
| `<Space>t` | Toggle tag outline sidebar (shows functions, classes, methods) |

---

# 38. URL & Unicode

| Keymap | Mode | Description |
| --- | --- | --- |
| `gx` | n, x | Open URL or file under cursor in browser |
| `ga` | n | Show Unicode info for character under cursor |

URLs in buffers are automatically highlighted (vim-highlighturl plugin).

---

# 39. Other Plugins

| Plugin | Trigger | Description |
| --- | --- | --- |
| `auto-save.nvim` | Automatic | Saves on `FocusLost` / `BufLeave` |
| `better-escape.vim` | `jk` (insert) | Fast escape from insert mode (200ms window) |
| `vim-repeat` | `.` | Makes plugin actions repeatable with `.` |
| `vim-swap` | Automatic | Swap function arguments |
| `vim-eunuch` | `:Rename`, `:Delete` | Unix file operations |
| `vim-obsession` | `:Obsession` | Session save/restore |
| `instant.nvim` | Automatic | Collaborative editing (localhost:8081) |
| `firenvim` | Browser | Neovim in browser text areas |
| `vlime` | Lisp files | Common Lisp REPL (requires `sbcl`) |

---

# 40. Configuration Management

| Keymap / Command | Description |
| --- | --- |
| `<Space>ev` | Open `init.lua` in a new tab |
| `<Space>sv` | Save and reload Neovim config |
| `:Lazy` | Open plugin manager UI |
| `:Lazy update` | Update all plugins |

---

# 41. Filetype-Specific Settings

| Filetype | Settings |
| --- | --- |
| Python | 4-space indent, `<F9>` to run, `<Space>f` to format with Black |
| Lua | `<F9>` to execute, `<Space>f` to format with Stylua |
| C++ | `<F9>` to compile and run |
| Markdown | Word wrap enabled, extended syntax highlight column |

---

# 42. Automatic Behaviors

These happen without any keypress:

| Behavior | Description |
| --- | --- |
| Auto-create directories | Missing parent directories are created on save |
| Auto-resize windows | Windows resize equally when terminal is resized |
| Relative line numbers | Relative in normal mode, absolute in insert mode |
| Non-UTF-8 warning | Warns if file encoding is not UTF-8 |
| Yank highlight | Yanked text highlighted for 300ms |
| Cursor restore | Cursor returns to original position after yank |
| Auto-quit | Neovim exits if only utility windows remain (quickfix, Vista, nvim-tree) |
| Diagnostic float | Diagnostics auto-show when cursor rests on a line |
| Smart case | Case-insensitive search unless uppercase is used |
| Random colorscheme | Different theme on each startup |
| Auto-save | Files save automatically on focus lost / buffer leave |

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
Treesitter parses the syntax tree --> accurate highlighting, indentation, text objects (af, if, ac, ic)
  |
  v
LSP server starts (e.g., pyright for Python) --> diagnostics, go-to-definition, hover, rename, code actions
  |
  v
Completion engine (nvim-cmp) connects to LSP --> autocomplete suggestions as you type
  |
  v
Copilot connects --> AI ghost text suggestions
  |
  v
Gitsigns reads git status --> change markers in gutter
  |
  v
Lightbulb watches LSP --> shows icon when code actions are available
  |
  v
Diagnostics config --> errors/warnings appear as emoji signs, float on CursorHold
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

Three plugins work together:

| Plugin | What it does |
| --- | --- |
| **mason.nvim** | Downloads and installs LSP servers, linters, and formatters. Open with `:Mason`. |
| **mason-lspconfig.nvim** | Bridges Mason with nvim-lspconfig. Auto-installs servers when needed. |
| **nvim-lspconfig** | Configures how Neovim talks to each LSP server. |

On NixOS, servers are managed by the system package manager instead of Mason.

## Configured Servers and What They Provide

| Server | Language | What it provides |
| --- | --- | --- |
| **pyright** | Python | Type checking, import resolution, diagnostics. Disables import sorting (ruff handles that). |
| **ruff** | Python | Fast linting and formatting. Complementary to pyright. |
| **lua_ls** | Lua | Full Lua analysis with `vim` global recognized. Format with `:lua_ls`. |
| **bashls** | Bash/Shell | Shell script analysis and diagnostics. |
| **yamlls** | YAML | Schema validation and formatting for YAML files. |
| **marksman** | Markdown | Link validation, heading completion. Formatter: Prettier. |
| **nixd** | Nix | Nix language analysis. Formatter: nixpkgs-fmt. |
| **jdtls** | Java | Full Java IDE features via nvim-java (see Java section). Auto-configured. |
| **clangd** | C/C++ | Compilation, diagnostics, code completion for C/C++. |

## LSP Keymaps (All Languages)

These keymaps become active whenever an LSP server attaches to the current buffer:

| Keymap | What it does | When to use |
| --- | --- | --- |
| `gd` | **Go to definition**. If there's only one definition, jumps directly. If multiple, opens a location list so you can pick. Deduplicates results. | When you want to see where a function/class/variable is defined. |
| `K` | **Hover documentation**. Shows docs in a floating window with a border. | When you need to check what a function does, its parameters, return type, etc. |
| `<Space>rn` | **Rename symbol**. Renames the symbol under cursor everywhere it appears in the project. | When refactoring: changing a function name, variable name, etc. |
| `<Space>ca` | **Code action**. Shows a menu of available fixes and refactorings. | When the lightbulb icon appears, or when you want to auto-import, extract a variable, fix a lint warning, etc. |
| `<Space>fm` | **Format file**. Runs the LSP formatter asynchronously. | Before committing, or whenever you want clean formatting. |

## Peeking Without Jumping (Glance)

Plugin: **glance.nvim**. Instead of jumping away to a definition (which changes your context), you can peek at it in an inline popup:

| Keymap | What it does |
| --- | --- |
| `<Space>gd` | Peek at definitions in a popup. You see the code without leaving your current file. Press `<Esc>` to close. |
| `<Space>gr` | Peek at all references. See every place in the project that uses this symbol. |
| `<Space>gi` | Peek at implementations. See how interfaces/abstract methods are implemented. |

**When to use Glance vs `gd`**: Use Glance when you want to quickly check something and come back. Use `gd` when you want to actually navigate to the definition and work there.

## Diagnostics In Depth

Diagnostics are the errors, warnings, and hints that the LSP server reports about your code.

**How they appear**:
- Emoji signs in the gutter: 🆇 (error), ⚠️ (warning), ℹ️ (info)
- A floating window automatically appears after ~500ms when your cursor rests on a line with diagnostics
- The statusline shows diagnostic counts: `🆇 1 ⚠️ 3`

**Navigation**:

| Keymap | What it does |
| --- | --- |
| `<Space>de` | Jump to the next **error** (skips warnings/hints) |
| `<Space>dE` | Jump to the previous **error** |
| `<Space>dd` | Manually open the diagnostic float for the current line |
| `<Space>db` | Open a Telescope picker showing all diagnostics in the current file |
| `<Space>dw` | Open Trouble showing all diagnostics across the workspace |
| `<Space>dt` | Toggle diagnostics on/off (useful when they're distracting during prototyping) |

**Sending diagnostics to quickfix**:

| Keymap | What it does |
| --- | --- |
| `<Space>qw` | Put all workspace diagnostics into the quickfix list |
| `<Space>qb` | Put current buffer diagnostics into the quickfix list |

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

For LaTeX files, there's also an **omni** source for BibTeX and citation completion.

## The Smart Tab Behavior

`<Tab>` has three behaviors depending on context:

1. **Completion menu is visible**: Selects the next item in the menu
2. **Copilot ghost text is visible** (but no completion menu): Accepts the Copilot suggestion
3. **Neither**: Inserts a normal tab character

This means you can use Tab for both autocompletion and Copilot without conflicts.

## Completion Keymaps

| Keymap | In completion menu | Outside menu |
| --- | --- | --- |
| `<Tab>` | Select next item | Accept Copilot / insert tab |
| `<CR>` (Enter) | Confirm selection | Insert newline |
| `<Ctrl-e>` | Close menu | (nothing) |
| `<Esc>` | Close menu | Exit insert mode |
| `<Ctrl-d>` | Scroll docs down | (nothing) |
| `<Ctrl-f>` | Scroll docs up | (nothing) |

## Visual Indicators

- Each completion item shows an icon indicating its kind (function, variable, method, keyword, etc.) via mini.icons
- Deprecated items appear with strikethrough
- The completion menu is semi-transparent (5% blend)

---

# 46. Treesitter In Depth

## What Treesitter Is

Plugin: **nvim-treesitter**. It parses your code into a syntax tree (like an AST) and uses that for:

- **Syntax highlighting**: More accurate than regex-based highlighting. Understands the actual structure of the code.
- **Indentation**: Smarter auto-indentation that understands code structure.
- **Text objects**: Code-aware selections like "select this function" or "select this class".
- **Folding**: nvim-ufo uses Treesitter to know where to fold code.

## Installed Parsers

Auto-installed: Python, C++, Lua, Vim, JSON, TOML, HTML. Additional parsers install automatically when you open a file of that type (on non-NixOS systems).

## Treesitter Text Objects

Plugin: **nvim-treesitter-textobjects**. These let you select code structures intelligently:

| Text Object | What it selects | Example use |
| --- | --- | --- |
| `af` | Around function (entire function including signature) | `daf` deletes the entire function |
| `if` | Inside function (body only) | `vif` selects only the function body |
| `ac` | Around class (entire class) | `yac` yanks the whole class |
| `ic` | Inside class (body only) | `cic` changes the class body |

These are linewise (V mode), so they select entire lines.

**Examples**:
- Delete a function: Place cursor anywhere inside it, press `daf`
- Copy a class: Place cursor anywhere inside it, press `yac`
- Change a function body: `cif` deletes the body and puts you in insert mode
- Select a function to move it: `vaf` then cut with `d`, navigate, paste with `p`

---

# 47. Code Folding In Depth

## What It Is

Plugin: **nvim-ufo** + **promise-async**. Code folding collapses blocks of code (functions, classes, if-blocks, etc.) into a single line to help you see the big picture.

## How It Works

nvim-ufo uses the LSP server's folding ranges (or Treesitter as fallback) to determine what can be folded. This means folds match actual code structure, not just indentation.

Folded lines show a preview: the first line of the fold + a count like `󰁂 42` showing how many lines are hidden.

## Folding Keymaps

| Keymap | What it does | When to use |
| --- | --- | --- |
| `za` | Toggle the fold under cursor | Quick open/close of a single fold |
| `zR` | Open ALL folds in the file | When you want to see everything |
| `zM` | Close ALL folds in the file | When you want the bird's-eye view |
| `zr` | Open folds one level at a time | Gradually reveal more detail |
| `zo` / `zc` | Open / close fold at cursor | Precise control |
| `zO` / `zC` | Open / close all nested folds at cursor | Deep open/close |
| `<Space>K` | Preview folded lines in popup | See what's inside without unfolding |
| `zi` | Toggle folding on/off globally | Temporarily disable all folding |

**Workflow tip**: Press `zM` to close all folds when you open a large file. This gives you an outline view. Then use `za` to open only the sections you care about. Use `<Space>K` to peek inside folds without opening them.

---

# 48. Git Workflow In Depth

## The Git Plugin Ecosystem

This config includes 7 git-related plugins that each handle a different aspect:

| Plugin | What it does | How to use |
| --- | --- | --- |
| **vim-fugitive** | Run git commands from inside Neovim. The core git plugin. | `<Space>gs` for status, `<Space>gc` for commit, etc. |
| **gitsigns.nvim** | Shows which lines changed in the gutter. Navigate between changes. | `]c` / `[c` to jump between hunks, `<Space>hp` to preview. |
| **gitlinker.nvim** | Generate shareable URLs to specific lines of code. | `<Space>gl` to copy a permalink. |
| **neogit** | A full git UI inside Neovim (like Magit for Emacs). | `:Neogit` to open. |
| **git-conflict.nvim** | Highlights merge conflict markers and provides resolution commands. | Activates automatically when conflicts exist. |
| **diffview.nvim** | Side-by-side diff viewer for comparing branches, commits, etc. | `:DiffviewOpen` to open. |
| **vim-flog** | Visual git log/graph showing branch history. | `:Flog` to open. |

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

## GitHub Copilot

Plugin: **copilot.lua** + **copilot-cmp** + **CopilotChat.nvim**

### How Copilot Suggestions Work

As you type in insert mode, Copilot generates "ghost text" (grey, transparent text) showing a suggestion for what you might type next. This is NOT the completion menu -- it's an overlay.

| Keymap | What it does |
| --- | --- |
| `<Tab>` | Accept the suggestion (only when the completion menu is closed) |
| `<Alt-]>` | See the next alternative suggestion |
| `<Alt-[>` | See the previous alternative suggestion |
| `<Ctrl-]>` | Dismiss the current suggestion |

**How Tab priority works**: The completion menu (nvim-cmp) takes priority over Copilot. So:
1. If the autocomplete menu is showing: Tab selects the next menu item
2. If no menu but Copilot ghost text is visible: Tab accepts the Copilot suggestion
3. If neither: Tab inserts a tab character

### Copilot Chat

A separate window where you can have conversations with Copilot about your code:

| Keymap | Mode | What it does |
| --- | --- | --- |
| `<Space>cpc` | n | Toggle the chat window open/closed |
| `<Space>cpe` | v | Select code in visual mode, then this sends it to Copilot with "Explain this code" |
| `<Space>cpo` | v | Select code in visual mode, then this sends it to Copilot with "Optimize this code" |

The chat window opens as a split. Navigate to/from it with `<Ctrl-w>` movements.

## Claude Code

Plugin: **claude-code.nvim**

Claude Code is an AI coding assistant that runs in a terminal inside Neovim.

| Keymap | Mode | What it does |
| --- | --- | --- |
| `<Space>cc` | n | Toggle Claude Code terminal. Opens at the bottom (30% height). |
| `<Space>ct` | t | Toggle while already in terminal mode |
| `<Space>cR` | n | Resume/continue the last Claude conversation |
| `<Space>cV` | n | Start Claude in verbose mode |

**Using Claude Code**:
1. Press `<Space>cc` to open
2. It opens as a terminal buffer at the bottom of the screen
3. Type your request and press Enter
4. Claude can read and edit your files directly
5. Press `<Space>cc` again to close, or `<Esc>` then `<Space>q`

Claude Code uses your project's git root as the working directory.

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
| Buffer cycle | `gb` / `gB` | Cycling through open files linearly |

## Finding Code

| Method | Keymap | Best for |
| --- | --- | --- |
| Project-wide grep | `<Space>fg` | Searching for a string/pattern across all files |
| Word under cursor | `*` or `#` | Finding all uses of the current word in the file |
| Go to definition | `gd` | Jumping to where something is defined |
| Peek definition | `<Space>gd` | Checking a definition without leaving context |
| Peek references | `<Space>gr` | Seeing everywhere something is used |
| Buffer tags | `<Space>ft` | Jumping to a function/class in the current file |
| Vista outline | `<Space>t` | Sidebar with all symbols in the file |

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
| Format | `<Space>fm` | Auto-format the file |
| Comment/uncomment | `gcc` / `gc` | Toggle comments |
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
| LSP diagnostics | `<Space>qw` | All errors/warnings from the language server |
| Buffer diagnostics | `<Space>qb` | Errors/warnings in current file only |
| Build errors | `:make` | Compiler output |
| Grep | `:grep pattern` | Uses ripgrep (configured in this setup) |

## Navigating the Quickfix List

| Command / Keymap | What it does |
| --- | --- |
| `:copen` | Open the quickfix window at the bottom |
| `:cclose` or `\x` | Close the quickfix window |
| `:cnext` | Jump to the next item |
| `:cprev` | Jump to the previous item |
| `:cfirst` / `:clast` | Jump to the first / last item |
| `:cc 5` | Jump to item number 5 |
| `:colder` / `:cnewer` | Go to the previous / next quickfix list (history) |

## Batch Operations on Quickfix Items

| Command | What it does |
| --- | --- |
| `:cdo s/old/new/g` | Run a substitution on every file in the quickfix list |
| `:cdo update` | Save all modified files after a batch operation |

**Example workflow**: Rename a string across the project:
1. `:grep "oldName"` to populate quickfix with all occurrences
2. `:cdo s/oldName/newName/g` to replace in all files
3. `:cdo update` to save all files

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
| `:DevdocsOpen` | Open documentation browser in a floating window |
| `:DevdocsOpenFloat` | Open in floating window (25 lines tall, 100 chars wide) |
| `:DevdocsInstall` | Install documentation for a language (e.g., `:DevdocsInstall python`) |
| `:DevdocsUninstall` | Remove installed docs |

## Hover Documentation (LSP)

Press `K` on any symbol to see its documentation in a floating window. This pulls from:
- Function signatures and return types
- Docstrings / JSDoc / Javadoc
- Type information

---

# 54. REPL Integration

Plugin: **iron.nvim**. Send code to an interactive REPL (Read-Eval-Print Loop).

**Configuration**: Uses `ipython` for Python. Opens in a vertical split (120 columns wide).

| Command | What it does |
| --- | --- |
| `:IronRepl` | Start a REPL for the current filetype |
| `:IronSend` | Send the current line or selection to the REPL |
| `:IronFocus` | Focus the REPL window |

This is useful for interactive development where you want to test code snippets without running the entire file.

---

# 55. Java Development In Depth

Plugin: **nvim-java** (with nvim-java-core, nvim-java-test, nvim-java-dap).

This is the most feature-rich language setup in this config. It provides a full Java IDE experience.

## How It Works

nvim-java wraps the Eclipse JDT Language Server (jdtls) and adds:
- Build system integration
- Test runner and debugger
- Spring Boot tools
- Refactoring commands
- DAP (Debug Adapter Protocol) for step-through debugging

On NixOS, JDK is managed by the system. On other systems, nvim-java auto-installs it.

## Build & Run

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jb` | `:JavaBuildBuildWorkspace` | Compile the entire workspace |
| `<Space>jc` | `:JavaBuildCleanWorkspace` | Clean build artifacts (restart Neovim after) |
| `<Space>jr` | `:JavaRunnerRunMain` | Run the main class |
| `<Space>js` | `:JavaRunnerStopMain` | Stop the running program |
| `<Space>jl` | `:JavaRunnerToggleLogs` | Show/hide the runner log window at the bottom |

## Testing

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jt` | `:JavaTestRunCurrentClass` | Run all `@Test` methods in the current class |
| `<Space>jT` | `:JavaTestDebugCurrentClass` | Debug all tests (with breakpoints) |
| `<Space>jm` | `:JavaTestRunCurrentMethod` | Run only the test method under cursor |
| `<Space>jM` | `:JavaTestDebugCurrentMethod` | Debug only the test under cursor |
| `<Space>jp` | `:JavaTestViewLastReport` | Show pass/fail results from the last test run |

## Debugging

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jd` | `:JavaDapConfig` | Configure the debug adapter (auto-runs on Java file open, but can be re-triggered) |

DAP is auto-configured when you open a Java file (with a 1-second delay). It enables breakpoint debugging with step-in, step-over, step-out, continue, etc.

## Refactoring

| Keymap | Command | What it does | Before | After |
| --- | --- | --- | --- | --- |
| `<Space>jv` | `ExtractVariable` | Extract expression to a local variable | `int area = 3.14 * r * r;` | `double temp = 3.14 * r * r; int area = temp;` |
| `<Space>jo` | `ExtractVariableAllOccurrence` | Extract and replace ALL occurrences | Multiple `data * 100` | Single `int factor = data * 100;` |
| `<Space>jj` | `ChangeRuntime` | Switch JDK version | | |
| `<Space>jf` | `JavaProfile` | Profiles UI | | |

**Note on overlapping keymaps**: Some Java keymaps share keys (`<Space>jc` is both clean workspace and extract constant; `<Space>jm` is both test method and extract method). The last definition in mappings.lua wins. In practice, the test commands take priority.

---

# 56. Code Running In Depth

## The Universal Runner

The `<Space>rr` keymap detects the current filetype and runs the appropriate command in a **vertical split terminal**.

**How it works**:
1. Detects the filetype of the current buffer
2. Builds the correct command (e.g., `python3 file.py`, `go run file.go`)
3. Opens a vertical split
4. Starts a terminal in that split running the command
5. Output appears in real-time

**After running**:
- The terminal window shows on the right side
- Press `<Esc>` in the terminal to enter Normal mode
- Navigate back to your code with `<Ctrl-w>h` or `<Left>`
- Close the terminal with `<Space>q` or `\d`
- Run again with `<Space>rr` (it opens a new terminal each time)

## Language-Specific Details

| Language | Command used | Notes |
| --- | --- | --- |
| Python | `python3 <file>` | |
| Java | `:JavaRunnerRunMain` | Uses nvim-java, not terminal |
| C | `gcc -Wall -Wextra -std=c11 <file> -o <output> && ./<output>` | Compiles and runs |
| C++ | `g++ -Wall -Wextra -std=c++17 <file> -o <output> && ./<output>` | Compiles and runs |
| C# | `dotnet run` | |
| JavaScript | `node <file>` | |
| TypeScript | `ts-node <file>` | |
| Go | `go run <file>` | |
| Rust | `cargo run` (falls back to `rustc <file>`) | |
| Bash | `bash <file>` | |
| Lua | `lua <file>` | |
| Ruby | `ruby <file>` | |
| PHP | `php <file>` | |

## Filetype-Specific Runners

Some filetypes have an additional `<F9>` runner:

| Filetype | What `<F9>` does |
| --- | --- |
| Python | Runs with `python -u <file>` via AsyncRun (unbuffered output) |
| C++ | Compiles with `clang++` or `g++` with warnings, opens in horizontal split |
| LaTeX | Compiles with vimtex |

---

# 57. Debugging In Depth

## Debug Adapter Protocol (DAP)

Plugin: **nvim-dap**. DAP is a standardized protocol (created by Microsoft) for communication between an editor and a debugger. It's the same protocol used by VS Code.

**Java**: Debugging is fully auto-configured via nvim-java. Just open a Java file, set breakpoints, and use `<Space>jT` or `<Space>jM` to debug tests.

**Python**: Use `<Space>dp` to start PDB (Python Debugger) for the current file. Only available on Linux/Windows.

## GDB Integration

Plugin: **nvim-gdb**. For C/C++ debugging with GDB. Available on Linux and Windows only.

---

# 58. File Management for Developers

## File Operations

| Plugin / Feature | What it does |
| --- | --- |
| **nvim-tree** (`<Space>s`) | Visual file browser. Create (`a`), delete (`d`), rename (`r`), copy (`c`), cut (`x`), paste (`p`). |
| **vim-eunuch** | Unix file commands: `:Rename <newname>`, `:Delete` (deletes current file and buffer), `:Move`, `:Mkdir`. |
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
| `<Space>cd` | Change working directory to current file's location |
| `<Space>t` | Open symbol outline (Vista) for current file |

---

# 59. Session and Productivity

## Auto-Save

Plugin: **auto-save.nvim**. Files are automatically saved when you:
- Switch to another application (`FocusLost`)
- Leave the current buffer (`BufLeave`)

It respects LSP formatting locks (won't save while the formatter is running).

## Session Management

Plugin: **vim-obsession**. Save and restore your entire Neovim session (open files, window layout, etc.).

| Command | What it does |
| --- | --- |
| `:Obsession` | Start recording the session (saves to `Session.vim`) |
| `:Obsession!` | Stop recording |
| `nvim -S Session.vim` | Restore the session from the command line |

## Collaborative Editing

Plugin: **instant.nvim**. Real-time collaborative editing.

- Default server: `localhost:8081`
- Uses your system username automatically

---

# 60. Useful Developer Commands

| Command | What it does |
| --- | --- |
| `:Mason` | Open Mason package manager to install/manage LSP servers, linters, formatters |
| `:LspInfo` | Show which LSP servers are attached to the current buffer |
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
| `:IronRepl` | Start an interactive REPL |
| `:Vista!!` | Toggle code outline |
| `:MundoToggle` | Toggle undo tree |
| `:YankyRingHistory` | Browse yank history |

---
---

# Part III: Everyday Scenarios & Recipes

Practical, step-by-step walkthroughs for common tasks.

---

# 61. Macros In Depth

Macros record a sequence of keystrokes and replay them. They are one of the most powerful features in Vim for repetitive editing.

**Key mapping**: In this config `Q` is mapped to `q`, so `Q` and `q` both start recording (tested: plain `q` works too). Stopping is always `q`.

## Recording a Macro

1. Press `Q` followed by a register letter (e.g., `Qa` to record into register `a`)
2. The statusline shows `recording @a` -- everything you do now is being recorded
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
- **Where the cursor ends**: one line **below** the last processed line (the final `j` of the last run). If that line is blank, the cursor is on the blank line.
- **Count**: use `number of lines - 1`, because the recording already did the first line. A count that goes past the last line stops early with an error, which is harmless.
- **Undo**: one `u` undid all the edits from the replay (tested). It was not checked whether the line edited by hand during recording was also undone.

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
3. `Iself.<Esc>` -- prepend `self.`
4. `A = <Esc>` -- append ` = `
5. `yiw` -- yank the original word (it's the last word now)
6. `A<Esc>p` -- go to end, exit insert, paste the word
7. ... actually simpler: `0yiw` `Iself.<Esc>` `A = <Esc>p` `j`
8. `q` then `2@a`

## Scenario: Turn CSV into SQL VALUES

Starting with `John,30,john@email.com`:

1. `Qa` -- start recording
2. `I('<Esc>` -- prepend `('`
3. `:%s/,/','/g<CR>` -- would change all lines; for single-line use `:s/,/','/g<CR>`
4. `A'),<Esc>` -- append `'),`
5. `j` -- next line
6. `q` then replay

## Tips for Writing Macros

- **Start from a consistent position**: Begin each macro from the start of a line (`0` or `H`) or from a search result. This makes the macro repeatable.
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

# 62. The Dot Command (`.`) -- Repeating Actions

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

# 63. Visual Block Editing (Multi-Cursor-Like)

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

# 64. Working with Multiple Files

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
2. `:cdo s/TODO/DONE/g` -- replace in every match
3. `:cdo update` -- save all modified files

## Closing Files You're Done With

| Keymap | What it does |
| --- | --- |
| `\d` | Close current buffer, keep window |
| `\D` | Close ALL other buffers (keep only current) |
| `<Space>q` | Close current window |

---

# 65. Everyday Editing Scenarios

## Swap Two Lines

1. On the first line: `dd` (cut it)
2. Move to where you want it: `j` or `k`
3. `P` (paste above) or `p` (paste below)

Or use `<Alt-j>` / `<Alt-k>` to move lines up/down without cutting.

## Swap Two Words

Plugin: **vim-swap**. Place cursor on a function argument and use `g<` / `g>` to swap it with the previous/next argument. Works with comma-separated items.

For manual word swap:
1. On the first word: `diw` (delete inner word)
2. Move to the second word: `w` or `f`
3. `viwp` -- select the second word and paste (swaps them)

## Duplicate a Line

1. `yy` -- yank the line
2. `p` -- paste below

Or: `Yyp` (same thing).

## Duplicate a Block of Code

1. Select the block with `V` + `j`/`k`
2. `y` -- yank
3. Navigate to destination
4. `p` -- paste

## Delete Everything Inside a Function

1. Place cursor anywhere inside the function
2. `dif` -- delete inside function (treesitter text object)

## Select and Replace a Function Body

1. `cif` -- change inside function (deletes body, enters insert mode)
2. Type the new body
3. `<Esc>`

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

# 66. Swapping Function Arguments (`vim-swap`)

Plugin: **vim-swap**. Swap delimited items (function arguments, list elements, etc.) without cutting and pasting.

Place your cursor on one of the arguments inside parentheses:

| Keymap | What it does |
| --- | --- |
| `g<` | Swap current item with the **previous** one |
| `g>` | Swap current item with the **next** one |
| `gs` | Enter interactive swap mode (shows labels, press to pick target) |

**Example**: Given `func(a, b, c)` with cursor on `b`:
- `g<` produces `func(b, a, c)`
- `g>` produces `func(a, c, b)`

Works with any comma-separated list: function arguments, array literals, dictionary entries, etc.

---

# 67. Shell Commands from Inside Neovim

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
| `:%!python -m json.tool` | Format the entire buffer as JSON (same as `:JSONFormat`) |

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

# 68. Multi-File Search and Replace (Complete Guide)

This is the section you need when you want to find or replace text across your entire project -- not just the current file.

## Quick Decision Guide: Which Method to Use

| Scenario | Best method |
| --- | --- |
| Rename a function/variable/class (code-aware) | **LSP Rename** (`<Space>rn`) |
| Replace a plain string in many files | **`:grep` + `:cdo`** |
| Replace only in certain file types (e.g., only `.py`) | **`:vimgrep` + `:cdo`** |
| Just find where something is used (no replace) | **`<Space>fg`** (live grep) |
| Replace with confirmation for each occurrence | **`:cdo` with `gc` flag** |

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

## Method 2: `:grep` + `:cdo` (Best for Plain Text)

This is the most versatile method. It uses ripgrep (very fast) to search the entire project, puts results in the quickfix list, then runs a command on each result.

### Step-by-Step: Replace All Without Confirmation

```
:grep "oldFunction"                       -- search entire project
:cdo s/oldFunction/newFunction/g          -- replace in every matching file
:cdo update                               -- save all modified files
```

### Step-by-Step: Replace with Confirmation for Each File

```
:grep "oldFunction"                       -- search entire project
:cdo s/oldFunction/newFunction/gc         -- 'c' flag asks y/n for EACH occurrence
:cdo update                               -- save all modified files
```

When the `c` flag is active, for each match you see it highlighted and can press:
- `y` to replace this one
- `n` to skip this one
- `a` to replace all remaining in this file (then moves to next file)
- `q` to stop entirely

### Step-by-Step: Review Results Before Replacing

```
:grep "oldFunction"                       -- search entire project
:copen                                    -- open the quickfix window to review all results
```

Now you can see every file and line that matches. Use `:cnext`/`:cprev` (or `j`/`k` in the quickfix window then `<Enter>`) to jump through them. Once satisfied:

```
:cdo s/oldFunction/newFunction/g          -- replace
:cdo update                               -- save
```

### Using Regex with `:grep`

`:grep` passes the pattern directly to ripgrep, so you can use ripgrep regex:

| Command | What it finds |
| --- | --- |
| `:grep "TODO"` | All lines containing `TODO` |
| `:grep "TODO\|FIXME"` | Lines with `TODO` or `FIXME` |
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

## Method 3: `:vimgrep` + `:cdo` (Built-in, Slower but Portable)

`:vimgrep` is Vim's built-in search (doesn't require ripgrep). It's slower but lets you use Vim regex and file glob patterns:

| Command | What it does |
| --- | --- |
| `:vimgrep /pattern/ **/*` | Search all files recursively |
| `:vimgrep /pattern/ **/*.py` | Search only Python files |
| `:vimgrep /pattern/ **/*.{js,ts}` | Search JS and TS files |
| `:vimgrep /pattern/ src/**/*` | Search only in `src/` directory |

Then use `:cdo` as before:

```
:vimgrep /oldName/ **/*.java
:cdo s/oldName/newName/g
:cdo update
```

---

## Method 4: `<Space>fg` for Finding (No Replace)

`<Space>fg` (live grep via fzf-lua) is the fastest way to **find** where something is used, but it doesn't directly support replace. Use it for:

- Exploring: "Where is this function called?"
- Investigating: "Which files reference this config key?"
- Planning: "How many places use this pattern?" before deciding on a replace strategy

After reviewing results in fzf, you can then use `:grep` + `:cdo` for the actual replacement.

---

## Complete Examples

### Example 1: Rename an API Endpoint Across the Project

You renamed `/api/users` to `/api/v2/users`:

```
:grep "/api/users"                        -- find all references
:copen                                    -- review: make sure you're not catching wrong things
:cdo s|/api/users|/api/v2/users|g         -- replace (using | as delimiter since / is in the text)
:cdo update                               -- save all files
```

### Example 2: Replace a Deprecated Function Name (with Confirmation)

```
:grep "getUser"
:cdo s/getUser/fetchUser/gc               -- confirm each one ('y' to replace, 'n' to skip)
:cdo update
```

### Example 3: Delete All Console.log Statements in JavaScript Files

```
:grep "console\.log" --type js            -- find them
:cdo g/console\.log/d                     -- delete the entire line containing the match
:cdo update
```

### Example 4: Add a Comment Before Every TODO

```
:grep "TODO"
:cdo s/TODO/NOTE: was TODO/g
:cdo update
```

### Example 5: Replace Only in Python Files in the src/ Directory

```
:grep "old_function" --type py src/
:cdo s/old_function/new_function/g
:cdo update
```

### Example 6: Case-Insensitive Project-Wide Replace

```
:grep -i "oldname"                        -- ripgrep's -i flag for case-insensitive
:cdo s/\coldname/newname/gi               -- \c forces case-insensitive in the substitute too
:cdo update
```

---

## Understanding `:cdo` vs `:cfdo` vs `:bufdo`

| Command | What it does |
| --- | --- |
| `:cdo {cmd}` | Run `{cmd}` on every **line** in the quickfix list (may visit the same file multiple times) |
| `:cfdo {cmd}` | Run `{cmd}` once per **file** in the quickfix list (visits each file only once) |
| `:bufdo {cmd}` | Run `{cmd}` on every **open buffer** (not just quickfix results) |

For search-and-replace, `:cdo` is usually what you want. Use `:cfdo` if your command operates on the whole file (e.g., formatting).

---

## Undoing a Multi-File Replace

If the replace went wrong, each file has its own undo history:

1. `:cdo undo` -- undo the last change in every affected file
2. `:cdo update` -- save the reverted files

Or use `:cdo earlier 1f` to go back one save-state in each file.

---

# 69. Useful Vim Tricks

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

**Important**: `g<Ctrl-a>` doesn't "know" what you want incremented -- it purely acts on whatever number the highlighted column(s) overlap on each line, ignoring every other number on the line. Wherever you place the block is what gets incremented.

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

Put the cursor anywhere on the `001` (block only needs to touch it, not cover all 3 digits), `<Ctrl-v>`, `G`, `g<Ctrl-a>`:

```
photo_002.jpg
photo_003.jpg
photo_004.jpg
```

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

`<Ctrl-a>`/`<Ctrl-x>` wrap `z`→`a` (or `Z`→`A`) at the alphabet boundary, and respect case (`a` increments to `b`, `Z` increments to `A`).

## Open the File Under Cursor

| Keymap | What it does |
| --- | --- |
| `gf` | Open the file path under cursor (if it exists) |
| `<Ctrl-w>f` | Open file under cursor in a split |
| `gx` | Open URL under cursor in a browser |

## Change Case

| Keymap | What it does |
| --- | --- |
| `~` | Toggle case of character(s). Since `tildeop` is set, use with a motion: `~w` toggles case of a word, `~e` to end of word. |
| `gUiw` | Uppercase the entire word |
| `guiw` | Lowercase the entire word |
| `gUU` | Uppercase the entire line |
| `guu` | Lowercase the entire line |
| (in insert mode) `<Ctrl-u>` | Uppercase the current word (custom) |
| (in insert mode) `<Ctrl-t>` | Title case the current word (custom) |

## Align Text

Plugin: **tabular**. Aligns text around a character.

| Command | What it does |
| --- | --- |
| `:Tabularize /=` | Align all `=` signs in a selection or file |
| `:Tabularize /\|` | Align table pipes |
| `:Tabularize /:` | Align colons (for JSON/YAML-like structures) |

## Command Abbreviations

This config sets some command abbreviations (type the short form, press space):

| Short | Expands to |
| --- | --- |
| `git` | `Git` (fugitive) |
| `man` | `Man` (manual pages) |
| `edit` | `Edit` (multi-file edit) |
| `pi` | `Lazy install` |
| `pud` | `Lazy update` |
| `pc` | `Lazy clean` |
| `ps` | `Lazy sync` |

---

# 70. Tips for Vim Beginners

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
| Screen looks weird / frozen | You pressed `<Ctrl-s>` (terminal freeze) | Press `<Ctrl-q>` to unfreeze |
| Can't exit Neovim | | Type `<Space>Q` or `;qa!<Enter>` |
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

# 71. The Verb + Noun System (How Vim Commands Work)

This is the single most important mental model for understanding Vim. Almost every command follows this pattern:

**`[count] operator motion`** or **`[count] operator text-object`**

- **Operator** (verb): What you want to do (`d` delete, `c` change, `y` yank, `>` indent, `gU` uppercase, etc.)
- **Motion** (noun): Where to do it (`w` word, `$` end of line, `gg` top of file, `}` next paragraph, etc.)
- **Text object** (noun): A structural unit to act on (`iw` inner word, `i(` inside parentheses, `af` around function, etc.)
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
| `is` / `as` | Inner sentence / a sentence |
| `ip` / `ap` | Inner paragraph / a paragraph |
| `i(` / `a(` | Inside / around parentheses |
| `i{` / `a{` | Inside / around braces |
| `i[` / `a[` | Inside / around brackets |
| `i"` / `a"` | Inside / around double quotes |
| `i'` / `a'` | Inside / around single quotes |
| `it` / `at` | Inside / around HTML tags |
| `if` / `af` | Inside / around function (treesitter) |
| `ic` / `ac` | Inside / around class (treesitter) |

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

# 72. The Global Command (`:g`)

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

# 73. Saving, Quitting, and File State

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
| `<Space>Q` | Quit all windows immediately (`:qa!`) -- no confirmation! |
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
| `\D` | Close all other buffers (keep only current one) |

---

# 74. Recovering from Mistakes

## Undo and Redo

| Keymap | What it does |
| --- | --- |
| `u` | Undo the last change |
| `<Ctrl-r>` | Redo (undo the undo) |
| `U` | Undo all changes on the current line (rarely used) |

## Undo Tree (vim-mundo)

Vim's undo history is a tree, not a linear stack. If you undo several times and then make a new edit, the old states aren't lost -- they become branches. vim-mundo lets you visualize and navigate this tree.

| Keymap | What it does |
| --- | --- |
| `<Space>u` | Open the undo tree panel |

Inside the panel: `j`/`k` to move, `<Enter>` to restore a state, `p` to preview diff, `q` to close.

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

The `auto-save.nvim` plugin saves frequently, and Neovim creates backups in `~/.local/share/nvim/backup/`. You may be able to recover from there.

---

# 75. Discovering Keymaps and Getting Help

## Which-Key: See Available Keybindings

Press **`<Space>`** (the leader key) and **wait about 500ms**. A popup appears showing every available `<Space>+...` keybinding organized by category.

You can also press any partial key sequence and wait:
- `g` then wait -- shows all `g...` keybindings
- `z` then wait -- shows all `z...` keybindings (folding, spelling, etc.)
- `<Ctrl-w>` then wait -- shows all window management keybindings
- `"` then wait -- shows all registers

## Browse All Keymaps

| Command | What it does |
| --- | --- |
| `:Telescope keymaps` | Searchable list of all defined keymaps |
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
| `:LspInfo` | Show which LSP servers are attached to the current buffer |
| `:Mason` | Open the package manager to see installed/available LSP servers |
| `:Lazy` | Open the plugin manager |
| `:messages` | Show recent notification messages |

---

# 76. Real-World Developer Workflows

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
4. `:cdo s/oldText/newText/gc` -- replace with confirmation (`y`/`n` each)
5. `:cdo update` -- save all files

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
4. If it's the Neovim config: `<Space>sv` to reload it immediately

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
3. `yaf` in file A -- copy a function
4. `<Ctrl-w>l` -- switch to file B
5. `p` -- paste the function
6. `<Ctrl-w>=` -- equalize window sizes if they got uneven
7. `<Ctrl-w>o` -- when done, close all splits except current

---

# 77. Common Editing Power Combos

Quick-reference card of the most powerful editing combinations for daily use.

## Changing Text

| Combo | What it does | Example |
| --- | --- | --- |
| `ciw` | Change the word under cursor | `foo` -> type `bar` -> `bar` |
| `ci"` | Change text in double quotes | `"old"` -> type `new` -> `"new"` |
| `ci(` | Change text in parentheses | `func(old)` -> type `new` -> `func(new)` |
| `ci{` | Change text in braces | `{old}` -> type `new` -> `{new}` |
| `cit` | Change text in HTML tag | `<p>old</p>` -> type `new` -> `<p>new</p>` |
| `cif` | Change function body | Empties the function, puts you in insert mode |
| `cc` | Change entire line | Clears line, insert mode |
| `C` | Change from cursor to end of line | Deletes rest of line, insert mode |
| `c$` | Same as `C` | |
| `ct)` | Change from cursor to before `)` | Useful inside function arguments |
| `cf,` | Change from cursor through a `,` picked with hop (may be several lines away; see "Precision Selection") | `f` is hop.nvim here, not the built-in |

## Deleting Text

| Combo | What it does |
| --- | --- |
| `diw` | Delete word under cursor |
| `daw` | Delete word + surrounding spaces |
| `di"` | Empty out double-quoted string |
| `da"` | Delete the entire quoted string including quotes |
| `di(` | Empty out parentheses |
| `da(` | Delete parentheses and their contents |
| `dif` | Delete function body |
| `daf` | Delete entire function |
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
| `yaf` | Copy entire function |
| `yap` | Copy paragraph |
| `yy` | Copy line |
| `y$` | Copy from cursor to end of line |

## Selecting Text

| Combo | What it does |
| --- | --- |
| `viw` | Select word |
| `vi"` | Select inside quotes |
| `vi(` | Select inside parentheses |
| `vaf` | Select entire function |
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
| `:grep "text"` then `:cdo s/old/new/g` then `:cdo update` | Project-wide search and replace |
| `<Space>rn` | Intelligent rename across project |
| `qf` list + `:cnext`/`:cprev` | Jump through search results or errors |
| `.` | Repeat last change (combine with `n` for find-and-repeat) |
