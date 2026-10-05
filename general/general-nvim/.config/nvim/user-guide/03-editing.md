<!-- chapter: Editing, text objects, macros and tricks -->
[Back to the guide index](README.md)

# 4. Editing

## Entering insert mode for editing

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

## Deleting text

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

Example on `The quick brown fox` with the cursor on the `u` of `quick`:

| Keys | Result |
| --- | --- |
| `x` | `The qick brown fox` |
| `X` | `The uick brown fox` |
| `dw` | `The qbrown fox` (from the cursor to the start of the next word) |
| `db` | `The uick brown fox` (from the start of the word to just before the cursor) |
| `diw` | `The  brown fox` (both spaces stay) |
| `daw` | `The brown fox` (the space after the word goes too) |
| `d$` or `D` | `The q` |
| `d0` | `uick brown fox` |

## Copying (yanking) text

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

## Pasting text

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

**Example: the Visual `p` swaps** (text `one two`):

1. `yiw` on `one` copies `one`.
2. `w`, `viw`, `p` replaces `two` with `one`: the text is now `one one`, and the register now holds `two` (the replaced word).
3. `$p` pastes it: `one onetwo`.

**Example: `<Space>p` and `<Space>y`.** With the cursor on `foo` in `foo bar`, `yiw` then `<Space>p` puts `foo` on a new line below (the text is now two lines, `foo bar` and `foo`; the cursor stays on line 1). `<Space>y` copies the whole buffer, so on a two-line buffer `<Space>y` then `G` `p` pastes both lines again below the last one (4 lines).

## Changing (delete + enter insert)

`c` (change) deletes text and puts you into insert mode. In this config, `c`/`C`/`cc` do NOT save the deleted text to the paste register (they use the black hole register).

| Keymap | Description | Example |
| --- | --- | --- |
| `cw` | Change from cursor to end of word | `foo bar` with the cursor on `f` -> `cw`, type `x` -> `x bar` |
| `ciw` | Change the entire word under cursor | `foo bar` with the cursor on `f` -> `ciw`, type `x` -> `x bar` |
| `caw` | Change the word + surrounding whitespace | `foo bar baz` with the cursor on `b` of `bar` -> `caw`, type `x` -> `foo xbaz` (the space after `bar` is gone too) |
| `cc` | Change the entire line | `old line` -> `cc`, type `new` -> `new` |
| `C` | Change from cursor to end of line | `foo bar` with the cursor on `b` -> `C`, type `baz` -> `foo baz` |
| `c$` | Same as `C` | `foo bar` with the cursor on `b` -> `c$`, type `baz` -> `foo baz` |
| `c0` | Change from cursor to beginning of line | `foo bar` with the cursor on `b` -> `c0`, type `baz` -> `bazbar` |

**Example: what `p` pastes after a change.** Text `alpha beta`: `yiw` copies `alpha`, then `w`, `ciw`, type `gamma`, `<Esc>`, `$p` gives `alpha gammaalpha`. The `ciw` did not touch the register, so `p` pastes the yanked `alpha`, not the `beta` that was removed. With `dw` instead of `ciw`, the register would hold `beta` and `p` would paste that.

## Replacing text

| Keymap | Description | Example |
| --- | --- | --- |
| `r<char>` | Replace the single character under cursor with `<char>` | `cat` with the cursor on `c` -> `rx` -> `xat` |
| `R` | Enter **Replace mode** (overtype mode): every character you type replaces the existing one | `cat` with the cursor on `c` -> `R`, type `ab`, `<Esc>` -> `abt` |

## Undo / redo

| Keymap | Description |
| --- | --- |
| `u` | Undo the last change |
| `<Ctrl-r>` | Redo (undo the undo) |
| `<Space>u` | Toggle Neovim's builtin undo tree in a 30-column panel on the left |

**Undo breakpoints**: Typing `,` `.` `!` `?` `;` `:` in insert mode creates undo checkpoints. This means pressing `u` after a long insert session will undo in smaller chunks instead of reverting everything at once.

## Repeating actions

| Keymap | Description |
| --- | --- |
| `.` | Repeat the last change. Works with most editing commands. Extremely powerful: e.g., `ciw` + type new word + `<Esc>`, then move to another word and press `.` to repeat. |

Example: `foo x foo`: `ciw`, type `bar`, `<Esc>`, `ww` (to the second `foo`), `.` -> `bar x bar`. More scenarios are in [section 61](#61-the-dot-command-----repeating-actions) (the dot command).

## Line operations

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

Examples:

| Before | Keys | After |
| --- | --- | --- |
| lines `one`, `two`, `three`, cursor on `one` | `<Alt-j>` | `two`, `one`, `three` (the cursor follows the moved line) |
| lines `1` to `5`, cursor on `1` | `3<Alt-j>` | `2`, `3`, `4`, `1`, `5` |
| lines `1` to `4`, `Vj` on `1` and `2` | `<Alt-j>` | `3`, `1`, `2`, `4` (the selection stays) |
| lines `a`, `b`, cursor on `a` | `]<Space>` | `a`, an empty line, `b` (the cursor stays on `a`) |
| lines `a`, `b`, cursor on `b` | `3]<Space>` | `a`, `b`, then three empty lines |
| `hello` / `  world` | `J` | `hello world` |
| `hello` / `  world` | `gJ` | `hello  world` (the indent is kept, no space is inserted) |
| lines `a`, `b`, `c`, `d` | `3J` | `a b c` and `d` |

### Split and join code (treesj)

Plugin: **treesj**. Put the cursor inside a list, the arguments of a call, a table, a dict or a block and press `gS`. If the construct is on one line it is split with one item per line; if it is already split over several lines it is joined back to one line (one key toggles both ways). A normal `u` undoes either change.

| Key | Mode | Effect | Example |
| --- | --- | --- | --- |
| `gS` | n | Toggle split / join of the construct under the cursor | Lua `foo(a, b, c)` with the cursor on `a`: `gS` -> `foo(` / `  a,` / `  b,` / `  c` / `)` (one item per line); `gS` again joins it back to `foo(a, b, c)` (tested) |

```
foo(a, b, c)   --gS-->   foo(
                           a,
                           b,
                           c
                         )          (the cursor lands on line 2)
```

Join it back with `gS` from any of the lines between the brackets or from the closing `)`; it does not join when the cursor is on the opening `foo(` line (tested).

- It works from the Treesitter syntax tree, so it needs a parser for the file type, and treesj needs a rule ("preset") for that language: it ships rules for many languages (for example Lua, Python, Java, JavaScript / TypeScript, JSON, Nix, Rust, C / C++, YAML, TOML), not for every file type.
- The plugin's own default keys are switched off in `lua/config/treesj.lua`; `gS` is the only one.
- Capital `gS` is treesj; lowercase `gs` is vim-swap's interactive swap ([section 65](#65-swapping-function-arguments-vim-swap)). It loads the first time `gS` is pressed.

## Indentation

| Keymap | Mode | Description | Example |
| --- | --- | --- | --- |
| `>>` | n | Indent the current line to the right | `foo` -> `>>` -> `  foo` (2 spaces: shiftwidth is 2) |
| `<<` | n | Indent the current line to the left | `    foo` -> `<<` -> `  foo` |
| `>` | x | Indent selection right (stays in visual mode so you can press `>` again) | lines `a` and `b`: `Vj>` -> `  a` / `  b`, still selected |
| `<` | x | Indent selection left (stays in visual mode) | `    a`: `V<` -> `  a`, still selected |
| `=` | n, x | Auto-indent: fix indentation of the current line or selection | Lua `if a then` / `x` / `end` with the cursor on `x`: `==` -> `x` becomes `  x` |
| `gg=G` | n | Auto-indent the entire file | the same three Lua lines: `gg=G` -> `x` becomes `  x` |

## Insert mode shortcuts

| Keymap | Description |
| --- | --- |
| `<Ctrl-u>` | Convert the current word to UPPERCASE (the word under or right before the cursor; if only spaces separate the cursor from the previous word, that word). You stay in Insert mode. |
| `<Ctrl-t>` | TOGGLE the case of the FIRST letter of that same word (`foo` -> `Foo`, press again -> `foo`); letters whose case does not round-trip (`ß`, `ı`) and non-letters are left alone; the cursor keeps its place |
| `<Alt-;>` | Insert a semicolon at the end of the line (without moving cursor) |
| `<Ctrl-a>` | Jump to the beginning of the line |
| `<Ctrl-a>` on the `:` command line | Jump to the start of the command line (the same key as in insert mode) |
| `<Ctrl-e>` | Jump to the end of the line (while the completion menu is open it closes the menu instead) |
| `<Ctrl-d>` | Delete the character to the right of the cursor |
| `<Ctrl-w>` | Delete the word before the cursor |
| `<Ctrl-h>` | Delete the character before the cursor (like backspace) |
| `<Ctrl-s>` | Show the LSP signature help of the function call you are typing |

Examples (all in Insert mode):

| Text, cursor position | Keys | After |
| --- | --- | --- |
| `say hello`, cursor at the end | `<Ctrl-u>` | `say HELLO` (you stay in Insert mode) |
| `foo bar`, cursor at the end | `<Ctrl-t>` | `foo Bar` |
| `foo bar`, cursor right after `foo` | `<Ctrl-t>` | `Foo bar` (the cursor keeps its place) |
| `x = 1`, cursor anywhere | `<Alt-;>` | `x = 1;` (the semicolon goes to the end of the line; the cursor stays where it was) |

## Miscellaneous editing

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space><Space>` | n | Remove all trailing whitespace from the file (not in Markdown: there it only shows the warning "markdown: trailing spaces are hard line breaks, not stripped") |
| `<Space>v` | n | Reselect the text that was just pasted |
| `<Space>cl` | n | Toggle a vertical cursor column highlight |
| `<Space>cb` | n | Blink the cursor (helps find it on screen) |
| `~` | n | Toggle case of character(s) (tilde is set as operator, so use `~w` for word, `~e`, etc.) |

Example: `<Space><Space>` on the lines `a` plus three trailing spaces and `b` plus a trailing Tab gives `a` and `b`. `~w` on `Hello World` gives `hELLO World`.

---

# 5. Selection (visual mode)

Press `v`, `V`, or `<Ctrl-v>` to enter visual mode, then use any motion to extend the selection. Once selected, you can act on the selection with `d` (delete), `y` (yank), `c` (change), `>` (indent), `<` (deindent), etc.

## Selecting characters

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

Example: cursor on the `b` of `beta`, then `v` `e` selects the rest of the word (the selection is shown in brackets):

```
alpha beta gamma      alpha [beta] gamma
```

## Selecting lines

| Keymap | Description |
| --- | --- |
| `V` | Start line-wise visual (selects the entire current line) |
| `V` + `j` / `k` | Extend selection down / up by lines |
| `V` + `5j` | Select current line + 5 lines below |
| `ggVG` | Select the entire file |

Example: `V` `j` with the cursor anywhere on the first line selects both whole lines:

```
[alpha beta gamma]
[delta zeta omega]
```

## Selecting blocks (columns)

| Keymap | Description |
| --- | --- |
| `<Ctrl-v>` | Start block visual (rectangular selection) |
| `<Ctrl-v>` + `j` / `k` / `h` / `l` | Extend the block in any direction |
| `<Ctrl-v>` + `I` | Insert text at the start of every selected line (press `<Esc>` to apply) |
| `<Ctrl-v>` + `A` | Append text at the end of every selected line |
| `<Ctrl-v>` + `d` | Delete the selected block |
| `<Ctrl-v>` + `c` | Change the selected block |

This is extremely useful for editing columns of text, adding prefixes to multiple lines, etc.

Example: cursor on the `b` of `beta`, then `<Ctrl-v>` `j` `l` selects a 2x2 rectangle (two characters on each of two lines):

```
alpha [be]ta gamma
delta [ze]ta omega
```

## Selecting inside/around delimiters (text objects)

These are the most powerful selection commands. They work with `v` (select), `d` (delete), `c` (change), `y` (yank), and any other operator.

### Parentheses, brackets, braces

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

### Words, lines, paragraphs

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

### Example for the text objects above

One sample line, `call(foo, "bar baz", [1, 2])`, and what is selected (and so what `y` would copy):

| Cursor on | Keys | Selected text |
| --- | --- | --- |
| `foo` | `vi(` | `foo, "bar baz", [1, 2]` |
| `foo` | `va(` | `(foo, "bar baz", [1, 2])` |
| `bar` | `vi"` | `bar baz` |
| `bar` | `va"` | `"bar baz"` |
| `1` | `vi[` | `1, 2` |
| `1` | `vab` | `[1, 2]` (the nearest bracket pair of any kind) |

### Using with operators (d, c, y)

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

On the sample line `call(foo, "bar baz", [1, 2])`:

| Cursor on | Keys | Result |
| --- | --- | --- |
| `foo` | `di(` | `call()` |
| `foo` | `da(` | `call` |
| `bar` | `ci"` + type `X` + `<Esc>` | `call(foo, "X", [1, 2])` |
| lines `if x {` / `  y` / `}`, cursor on line 1 | `yi{`, then `G` `p` | `  y` is copied and pasted below the last line |
| `old` in `<p>old</p>` | `dit` | `<p></p>` |

### Select a whole block, from its first line to the closing brace (method, function, if, class)

Cursor anywhere on the line that ends with the opening `{` (for example `int foo(int a, int b) {`):

| Keys | Mode | What happens |
| --- | --- | --- |
| `$` | Normal | Jump to the last character of the line, the `{` |
| `V` | Normal | Start line-wise Visual mode |
| `%` | Visual | Jump to the matching `}` (vim-matchup): every line from the signature line to the closing `}` is selected |

Tested (headless, a Java class, block of 4 lines on lines 10 to 13, cursor at column 0 of the signature line):

| Keys | Selected |
| --- | --- |
| `$V%` | lines 10 to 13: the whole method, signature line included |
| `V%` | only line 10: without `$`, `%` finds the first `(` on the line and jumps to its `)` on the same line |
| `va{` | lines 3 to 27, the WHOLE CLASS: the cursor is before the method's own `{`, so the nearest `{ }` pair around it is the outer one |
| `$va{` | lines 10 to 13, but character-wise from the `{`: the signature text before the `{` is not selected |
| `$V%ok` | lines 9 to 13: `o` jumps to the other end of the selection, `k` extends it one line up (use it to include an annotation line such as `@Test`; a doc comment needs several `k`) |

Notes:

- In Normal mode `$` is the normal end-of-line. Only in Visual mode `$` is remapped to `g_` (last non-blank character); here `$` is pressed before `V`, so it is the Normal one. `%` is provided by vim-matchup.
- Works for any `{ }` block (function, class, `if`, `for`, a JSON or CSS block). For a `( )` or `[ ]` block that opens at the end of a line, the same idea works with that bracket (assumption, not tested).
- If the line has trailing spaces after the `{`, `$` lands on a space and `%` may not find the bracket (assumption, not tested): remove the spaces or use `g_` instead of `$`.
- Without braces (Python): use the indent objects `ii` / `ai` in [More text objects](#more-text-objects). `V%` on `if` ... `end` keywords should work through vim-matchup (assumption, not tested).
- Cursor INSIDE the block: `va{` / `vaB` selects the braces of that level only (character-wise, not the signature line). `[{` jumps to the enclosing opening `{`; from there continue with `V%` because you are already on the `{` (assumption, not tested).

What to do with the selected block (the selection from `$V%` stays active until you press one of these):

| Keys | Effect | Status |
| --- | --- | --- |
| `y` | Copy the block; move the cursor, then `p` pastes it BELOW the cursor line (after `$V%y<Esc>`, `G`, `k`, `p` the 4 lines appeared a second time, 27 to 31 lines) | tested |
| `d` | Delete the block (27 to 23 lines) | tested |
| `<Alt-j>` / `<Alt-k>` | Move the whole block down / up ONE line per press; the selection stays, so press again | tested |
| `5<Alt-j>` | Move the block 5 lines: type the count BEFORE the key, see [Line operations](#line-operations) | documented elsewhere (not tested with a block) |
| `>` / `<` | Indent / outdent the block (the line count is unchanged) | tested (the command runs) |
| `gc` | Comment the whole block out, see [vim-commentary](#vim-commentary-plugin) | documented elsewhere (not re-tested; headless runs do not load VeryLazy plugins) |
| `=` | Re-indent the block | assumption, not tested |
| `J` | JOINS all lines of the block into ONE line (4 lines to 1, 27 to 24): usually not what you want, a trap while the selection is still active | tested |
| `<Esc>` | Cancel the selection | tested |

### Treesitter node selection (builtin)

Neovim 0.12 can grow and shrink a selection along the syntax tree (needs a Treesitter parser; otherwise it uses the LSP selection range):

| Keymap | Mode | Description |
| --- | --- | --- |
| `an` | x, o | Select the parent (outer) node: press `v`, then `an` repeatedly to grow the selection |
| `in` | x, o | Select the child (inner) node: shrinks the selection again |
| `]n` / `[n` | x | Select the next / previous node |
| `]N` / `[N` | x | Select the next / previous sibling node |

Example: Lua line `local x = foo(a, b)`, cursor on `a`, then `v` and `an` pressed repeatedly (tested; the selection after each press):

| Keys | Selected |
| --- | --- |
| `v` | `a` |
| `an` | `(a, b)` |
| `an` | `foo(a, b)` |
| `an` | `x = foo(a, b)` |
| `an` | `local x = foo(a, b)` |

`in` goes back one step (after three `an` presses, `in` shows `foo(a, b)` again).

### More text objects

| Keymap | Mode | Description |
| --- | --- | --- |
| `ii` / `ai` | x, o | The current indent scope (mini.indentscope); `ai` includes its border lines. `[i` / `]i` jump to the top / bottom of the scope |
| `i%` / `a%` | x, o | Inside / around a matching pair, also keywords like `if` ... `end` (vim-matchup) |
| `ia` / `aa` | x, o | Inside / around a function argument (targets.vim: on `b` in `f(a, b, c)`, `daa` gives `f(a, c)`) |
| `iq` / `aq` | x, o | Inside / around the nearest quotes of any kind (targets.vim) |
| `i,` / `a,` | x, o | Between separators such as `,` `;` `:` `+` `-` `=` `/` `\|` `&` (targets.vim) |
| `<Space>iB` | x, o | The whole buffer (`y<Space>iB` copies everything) |
| `<Space>iu` | x, o | The URL under the cursor (`d<Space>iu`) |
| `<Alt-i>` | x, o | The LSP/Treesitter reference under the cursor (vim-illuminate; the key is the plugin's default, not set in this config) |

Examples (all tested):

| Before | Keys | After |
| --- | --- | --- |
| `f(a, bb, c)`, cursor on `bb` | `daa` | `f(a, c)` |
| `say 'hi there' now`, cursor on `say` | `ciq` + type `X` + `<Esc>` | `say 'X' now` |
| `x(a, b, c)`, cursor on `b` | `di,` | `x(a,, c)` (the item between the separators goes, with the space before it) |
| lines `x`, `y` | `y<Space>iB`, then `G` `p` | the whole buffer is pasted again below (4 lines) |
| `see https://x.org/a now`, cursor on the URL | `d<Space>iu` | `see  now` |
| Python `def f():` / `    a = 1` / `    b = 2` / `x = 3`, cursor on `a = 1` | `dii` | `def f():` / `x = 3` (only the indented body goes) |
| the same lines | `dai` | the buffer is empty: the border lines count, so the `def f():` line and the first line below the block (`x = 3`) go too |

Careful with `cia`: it also takes the space in front of the argument (`f(a, bb, c)` with the cursor on `bb`: `ciaX` gives `f(a,X, c)`), so type the space again or use `ciw` for a plain word.

### Markdown code block text objects

In markdown files only:

| Keymap | Description |
| --- | --- |
| `vic` | Select inside a fenced code block (the object is `ic`, so `dic`, `yic` and `cic` work too) |
| `vac` | Select the code block including the fences (the object is `ac`: `dac`, `yac`, `cac`) |

Worked examples: [Text objects and operators](languages/markdown.md#text-objects-and-operators) in the Markdown chapter.

## Precision selection: from the cursor to an exact spot

How to select (or delete/copy/change) from the cursor to a specific character, word, or place, including on another line.

**Golden rules**
- The character **under the cursor is always included** in a visual selection, both at the start and at the end.
- Everything below works after `v`. Most of it also works after an operator (`d`, `y`, `c`) in place of `v`: for example `vt)` -> `dt)`, `yt)`, `ct)`. Exceptions are noted below.
- A *selection* can only be one continuous area. You cannot select two separate places at once (see "[Non-contiguous lines](#non-contiguous-lines-for-example-line-3-and-line-10-together)" below).

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
- Example: `a, b, c` with the cursor on `a`: `dt,` -> `, b, c` (everything up to, not including, the first comma).
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
- `ignorecase smartcase` is on, so a lowercase pattern (`foo`) also matches `Foo`. Type a capital letter to make it case-sensitive. (This is for `/` and `?`; `:s` and `:g` always ignore case here, see the [Substitution](05-search-and-files.md#substitution-find--replace-in-current-file) section.)
- `/` is not remapped in this config.
- With operators, `d/foo<Enter>` deletes up to (not including) the match; `d/foo/e<Enter>` includes the last letter of the match (tested: with the cursor on the start of `two words`, `d/words/e<Enter>` deleted everything up to and including the last letter of `words`).

### hop.nvim: select to something you can see (no counting)

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

```
  3   foo
  2   bar
  1   baz
 12   the cursor line shows its absolute number
  1   target
```

Here `1j` (or just `j`) moves onto `target`, and `3k` would move onto `foo`.

1. `Nj` moves down `N` lines, where `N` is the number shown next to the target line (with a count, `j` moves real lines, not wrapped ones). Use `Nk` to go up.
2. `L` goes to the end of that line.
3. `?foo<Enter>` searches **backward** from the end of the line, which finds the **last** `foo` on that line (tested in a real terminal). In general `?foo` goes to the start of the `foo` the cursor is inside; from the first letter of a `foo` it goes to the previous `foo`. (Searching forward from the middle of the line could hit an earlier, unwanted match or a capitalised one.)
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
- **Same spot on adjacent lines**: `<Ctrl-v>` block mode, but only for adjacent lines (see the [Visual Block Editing](#62-visual-block-editing-multi-cursor-like) section).
- **Matching by content instead of number**: the `:g` command (see [its section](#71-the-global-command-g)).

---

## Line range yanking (command mode)

| Command | Description |
| --- | --- |
| `:-5,+10yank` | Yank from 5 lines before to 10 lines after cursor |
| `:2,10yank` | Yank from line 2 to line 10 (absolute) |

---

# 6. Working with parentheses, quotes, and brackets

This section covers everything about matching, jumping to, selecting inside, changing, adding, and removing surrounding characters.

## Jumping to matching pair

| Keymap | Description |
| --- | --- |
| `%` | Jump between matching `()`, `[]`, `{}`, `<>`, and language keywords. The vim-matchup plugin extends this to work with `if`/`else`/`end`, `do`/`while`, `try`/`catch`, etc. If the match is offscreen, a popup shows the matching line. |

## Selecting inside/around pairs

See the full table in the [Selection section](#5-selection-visual-mode) above (with a sample line and the selected text for each key, under "[Example for the text objects above](#example-for-the-text-objects-above)"). Quick summary:

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

## Changing text inside pairs

| Keymap | Description | Example |
| --- | --- | --- |
| `ci(` | Delete everything inside `()` and enter insert mode to type replacement | `f(old)` with the cursor in `old` -> `ci(`, type `new` -> `f(new)` |
| `ci"` | Delete everything inside `""` and enter insert mode | `a "old" b` with the cursor in `old` -> `ci"`, type `new` -> `a "new" b` |
| `ci{` | Delete everything inside `{}` and enter insert mode | `{old}` -> `ci{`, type `new` -> `{new}` |
| `ci[` | Delete everything inside `[]` and enter insert mode | `[old]` -> `ci[`, type `new` -> `[new]` |
| `ci'` | Delete everything inside `''` and enter insert mode | `a 'old' b` with the cursor in `old` -> `ci'`, type `new` -> `a 'new' b` |
| `cit` | Delete everything inside an HTML tag and enter insert mode | `<p>old</p>` with the cursor in `old` -> `cit`, type `new` -> `<p>new</p>` |

## Deleting text inside pairs

| Keymap | Description | Example |
| --- | --- | --- |
| `di(` | Delete everything inside `()` (parentheses remain empty) | `f(old)` with the cursor in `old` -> `f()` |
| `di"` | Delete everything inside `""` | `x "y" z` with the cursor on `y` -> `x "" z` |
| `di{` | Delete everything inside `{}` | `{old}` -> `{}` |
| `da(` | Delete everything including the `()` themselves | `f(old) x` with the cursor in `old` -> `f x` |
| `da"` | Delete everything including the `""` themselves | `x "y" z` with the cursor on `y` -> `x  z` |

## Adding surrounding pairs (vim-sandwich plugin)

The `sa` command adds surrounding characters. `s` key alone is disabled (use `cl` instead).

| Keymap | Description | Example |
| --- | --- | --- |
| `saiw"` | Add double quotes around the current word | `hello` becomes `"hello"` |
| `saiw(` | Add parentheses around the current word | `hello` becomes `(hello)` |
| `saiw{` | Add curly braces around the current word | `hello` becomes `{hello}` |
| `saiw[` | Add square brackets around the current word | `hello` becomes `[hello]` |
| `saiw'` | Add single quotes around the current word | `hello` becomes `'hello'` |
| `sa$"` | Add quotes from cursor to end of line | `hello world` with the cursor on `w` becomes `hello "world"` (tested) |
| (visual) `sa"` | First select text with `v`, then `sa"` adds quotes around selection | `foo bar`: `vee` selects both words, then `sa"` gives `"foo bar"` (tested) |

## Removing surrounding pairs (vim-sandwich plugin)

| Keymap | Description | Example |
| --- | --- | --- |
| `sd"` | Delete surrounding double quotes | `"hello"` becomes `hello` |
| `sd'` | Delete surrounding single quotes | `'hello'` becomes `hello` |
| `sd(` | Delete surrounding parentheses | `(hello)` becomes `hello` |
| `sd{` | Delete surrounding curly braces | `{hello}` becomes `hello` |
| `sdb` | Delete the surrounding pair without naming it (`()`, `[]`, `{}` or quotes). With the cursor on a letter it takes the INNERMOST pair; with the cursor ON a bracket or quote character it can pick the outer pair (see the note below) | `[hello]` becomes `hello` (tested headless) |
| `sd[` | Delete surrounding square brackets | `[hello]` becomes `hello` |

## Replacing surrounding pairs (vim-sandwich plugin)

| Keymap | Description | Example |
| --- | --- | --- |
| `sr"'` | Replace `"` with `'` | `"hello"` becomes `'hello'` |
| `sr({` | Replace `()` with `{}` | `(hello)` becomes `{hello}` |
| `sr{[` | Replace `{}` with `[]` | `{hello}` becomes `[hello]` |
| `sr'(` | Replace `'` with `()` | `'hello'` becomes `(hello)` |
| `srb'` | Replace the surrounding pair without naming it (same pair choice as `sdb`) | `"hello"` becomes `'hello'` |

**Nested pairs, `b` and exactness** (tested headless in a scratch copy of the config, Java buffer, line `names.add("apple");`):

- Cursor on a letter of `apple`: `sd"` gives `names.add(apple);`, `sd(` gives `names.add"apple";`, `sdb` gives `names.add(apple);` (the innermost pair, the quotes), `srb[` gives `names.add([apple]);` (the quotes became brackets).
- Cursor ON a quote character or on a parenthesis: `sdb` gave `names.add"apple";` (the PARENTHESES were removed, not the quotes). The same happens with the cursor on the closing `)`.
- A hands-on session reported the parentheses removed with the cursor "on `apple`". That was not reproduced with the cursor on a letter of `apple` (every column of `apple` removed the quotes), so check the exact cursor column first.
- With nested pairs `b` is therefore not a safe guess: name the pair (`sd"`, `sd(`, `sr"'`, `sr({`) when it matters. `b` is fine for a single pair.

More tested round trips on `names.add("apple");` with the cursor on `apple`: `sd"` then `saiw"` restores `"apple"`; `sr"'` gives `'apple'` and `sr'"` goes back; `sr({` gives `names.add{"apple"};` and `sr{(` goes back.

### Wrap a whole list or part of it (tested headless in a scratch copy)

Line `String.join(", ", "second", "first", "third")` with the cursor on `second`:

| Keys | Result |
| --- | --- |
| `vi(` then `sa(` | `String.join((", ", "second", "first", "third"))`: the whole argument list is wrapped in a second pair of parentheses |
| `sai((` | the same result in one go |
| Select exactly `"second", "first"` in Visual mode (`v` on the first quote, move to the last quote of `"first"`), then `sa(` | `String.join(", ", ("second", "first"), "third")` |

Check that the Visual highlight covers the LAST character you want inside the pair: a selection that stops one character short (before the comma) gave `("second", "first",) "third"`, and one that also takes the space after the last comma gave `("second", "first", )"third"`.

## Auto-pairing (nvim-autopairs plugin)

When typing in insert mode, opening characters automatically insert their closing pair:
- Type `(` and `)` appears: `(|)` (cursor between them)
- Type `"` and closing `"` appears: `"|"`
- Type `{` and `}` appears: `{|}`
- Type `[` and `]` appears: `[|]`
- Pressing `<BS>` right after typing `(` removes both brackets (tested: `(` `<BS>` `x` gives `x`).

---

# 16. Code commenting

## vim-commentary (plugin)

| Keymap | Mode | Description | Example |
| --- | --- | --- | --- |
| `gcc` | n | Toggle comment on current line | Lua `x = 1` -> `gcc` -> `-- x = 1`; `gcc` again removes the marker |
| `gc` + motion | n | Toggle comment on a motion (e.g., `gcip` comments a paragraph) | Lua lines `a` / `b` with the cursor on `a`: `gcip` -> `-- a` / `-- b` |
| `gc` | v | Toggle comment on selected lines | Lua lines `a`, `b`, `c`: `Vjgc` -> `-- a`, `-- b`, `c` |
| `gc` | o | Comment text object: `dgc` deletes the comment block under the cursor, `ygc` yanks it | Lua lines `-- a`, `-- b`, `c` with the cursor on `-- a`: `dgc` -> `c`; `ygc` copies the two comment lines |
| `gcu` | n | Uncomment the adjacent commented lines | Lua lines `-- a`, `-- b`, `c` with the cursor on `-- a`: `gcu` -> `a`, `b`, `c` |
| `:[range]Commentary` | cmd | Toggle comment on a range (`:2,3Commentary`) | Lua lines `a`, `b`, `c`: `:2,3Commentary` -> `a`, `-- b`, `-- c` |

vim-commentary loads right after the first screen (VeryLazy), so these commands and the `gc` text object exist from then on.

More examples (Python buffers; `gcc` and `gc` are plain vim-commentary: they use the filetype's comment marker and do not look inside embedded languages, so use the smart `gcs` / `gcr` below there):

| Before | Keys | After |
| --- | --- | --- |
| `a = 1` / `b = 2` | `gcc` on line 1 | `# a = 1` / `b = 2` |
| `a = 1` / `b = 2` / blank / `c = 3` | `gcip` | `# a = 1` / `# b = 2` / blank / `c = 3` |
| `# a = 1` / `# b = 2` / blank / `c = 3`, cursor on line 1 | `gcu` | `a = 1` / `b = 2` / blank / `c = 3` |
| the same | `dgc` | `c = 3` only (the comment block is deleted; the blank line goes with it) |

Java example (tested in a Java buffer; the Java marker is `//`):

| Keys | Result |
| --- | --- |
| `gcc` | the current line becomes `// ...`; `gcc` again removes it |
| `Vjjjgc` (`V`, then `3j`, then `gc`) | 4 lines are toggled to `// ...` and Visual mode ends |
| `gcu` with the cursor on the first commented line | the adjacent commented lines are uncommented |
| `:22,25Commentary` | lines 22 to 25 are toggled; the same command again toggles them back |

These keys only toggle. A range that mixes commented and uncommented lines was not tried here and may surprise you, so check the lines afterwards (or use `gcs` / `gcr` below, which add and remove explicitly).

## Smart commenting (custom)

String-aware, multi-line-capable comment add/remove (`lua/smart_comment/`).

| Keymap | Mode | Description | Example |
| --- | --- | --- | --- |
| `gcs` + motion | n | Comment the rows a motion covers (`gcsip`, `gcs3j`, `gcsG`); `.` repeats | Lua lines `a`, `b`, `c`, `d`, `e`: `gcs3j` -> `-- a`, `-- b`, `-- c`, `-- d`, `e` |
| `{count}gcs` | n | Comment count rows from the cursor down (`200gcs`) | Lua lines `a`, `b`, `c`: `2gcs` -> `-- a`, `-- b`, `c` |
| `gcss` | n | Comment current line(s) (`3gcss` = 3 rows); `.` repeats | Lua lines `a`, `b`: `gcss` -> `-- a`, `b` |
| `gcs` | x | Comment the selected rows | Lua lines `a`, `b`, `c`: `Vjgcs` -> `-- a`, `-- b`, `c` |
| `gcr` + motion | n | Uncomment the rows a motion covers (`gcrip`, `gcr200j`); `.` repeats | Lua lines `-- a`, `-- b`: `gcrip` -> `a`, `b` |
| `{count}gcr` | n | Uncomment count rows from the cursor down (`200gcr`) | Lua lines `-- a`, `-- b`, `-- c`: `2gcr` -> `a`, `b`, `-- c` |
| `gcrr` | n | Uncomment current line(s) (`3gcrr` = 3 rows); `.` repeats | Lua lines `-- a`, `b`: `gcrr` -> `a`, `b` |
| `gcr` | x | Uncomment the selected rows | Lua lines `-- a`, `-- b`, `-- c`: `Vjgcr` -> `a`, `b`, `-- c` |

`gcc` against `gcs` on the same lines:

| Before | Keys | After |
| --- | --- | --- |
| Python `# # a` | `gcrr` | `a` (every marker level is removed) |
| Python `color = "#ff0000"` / `x = 1  # keep` | `gcss` on line 1 | `# color = "#ff0000"` (the `#` inside the string is not mistaken for a comment; line 2 is untouched) |
| HTML: `<script>` / `let a = 1` / `</script>`, cursor on the middle line | `gcc` | `<!-- let a = 1 -->` (vim-commentary only knows the HTML marker) |
| the same | `gcss` | `// let a = 1` (smart comment finds the JavaScript inside `<script>`; inside `<style>` it writes `/* ... */`) |

Where smart comment does not follow the embedded language: in a `.tsx` file a JSX line gets `//` (not `{/* */}`), and in a `.vue` file `<!-- -->` is used everywhere (no Treesitter parser attached).

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

# 17. Surrounding pairs (`vim-sandwich` + `nvim-autopairs`)

See [Section 6: Working with parentheses, quotes, and brackets](#6-working-with-parentheses-quotes-and-brackets) for the complete guide.

Quick reference:

| Keymap | Description |
| --- | --- |
| `saiw"` | Add `"` around word |
| `sd"` | Delete surrounding `"` |
| `sr"'` | Replace `"` with `'` |
| `%` | Jump to matching bracket |

Nested pairs, the `b` shortcut and wrapping a whole argument list: see "Nested pairs, `b` and exactness" and "Wrap a whole list or part of it" in section 6.

---

# 24. Yank history (`yanky.nvim`)

| Keymap | Mode | Description |
| --- | --- | --- |
| `p` / `P` | n, x | Paste after / before (with 300ms highlight) |
| `[y` | n | After pasting, cycle to previous yank entry |
| `]y` | n | After pasting, cycle to next yank entry |

Command: `:YankyRingHistory` to browse all yank history. yanky.nvim loads right after the first screen (VeryLazy), so the yank history contains every yank of the session. In Visual mode `p` is yanky's: it overwrites the unnamed register with the replaced text (there is no separate keep-register map any more).

---

# 25. Undo history

| Keymap | Description |
| --- | --- |
| `<Space>u` | Toggle Neovim's builtin undo tree (`nvim.undotree`) in a 30-column panel on the far left |

Inside the panel there are no extra keys: moving the cursor onto an entry switches the buffer to that undo state (documented in `:h undotree.open()`). Close it with `<Space>u` again or `:q`.

---

# 29. Registers & macros

## Registers

| Keymap | Description |
| --- | --- |
| `"3y` | Yank to register 3 |
| `"3p` | Paste from register 3 |
| `"*y` / `"+y` | Yank to system clipboard |
| `:reg` | View all registers |

**Note**: When a clipboard tool (wl-clipboard, xclip, ...) is installed, `clipboard` is `unnamedplus`, so `y`/`p` already use the system clipboard by default.

**Example: two things at once** (text `foo bar`):

1. `"ayiw` copies `foo` into register `a`.
2. `w"byiw` copies `bar` into register `b`.
3. `$"ap"bp` pastes both after the end of the line: `foo barfoobar`.

`:reg` shows `a` and `b`. Naming a register with `"a` does not touch the default yank register.

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

# 60. Macros in depth

Macros record a sequence of keystrokes and replay them. They are one of the most powerful features in Vim for repetitive editing.

**Key mapping**: In this config `Q` is mapped to `q`, so `Q` and `q` both start recording (tested: plain `q` works too). Stopping is always `q`.

## Recording a macro

1. Press `Q` followed by a register letter (e.g., `Qa` to record into register `a`)
2. The command line (bottom line) shows `recording @a` (tested in a real terminal) -- everything you do now is being recorded
3. Perform the editing actions you want to repeat
4. Press `q` to stop recording

## Playing a macro

| Keymap | What it does |
| --- | --- |
| `@a` | Play macro from register `a` once |
| `5@a` | Play macro 5 times |
| `@@` | Replay the last played macro |
| `100@a` | Play 100 times (stops early if it hits an error, e.g., end of file) |

## Scenario: add semicolons to the end of 20 lines

1. Place cursor on the first line
2. `Qa` -- start recording to register `a`
3. `A;<Esc>` -- go to end of line, add semicolon, back to normal mode
4. `j` -- move down one line
5. `q` -- stop recording
6. `19@a` -- replay 19 more times (20 lines total)

Small version (tested): lines `a`, `b`, `c`, `d`; do steps 2 to 5 on `a`, then `3@a` (4 lines: 1 recorded + 3 replays) gives `a;`, `b;`, `c;`, `d;`. With only `2@a` the last line `d` stays as it is.

## Scenario: wrap each line in double quotes

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

## Scenario: append the same text to a block of lines (tested)

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

## Scenario: turn `// name` lines into `names.add("name");` calls (confirmed by the user)

Starting with 7 lines, indented 8 spaces, each `// apple`, `// banana`, ..., `// orange`. Result: `names.add("apple");` and so on, same indent.

1. Put the cursor on the first line, at any column.
2. `Qa` -- start recording to register `a` (`Q` is `q`)
3. `^` -- go to the first non-blank character (the `//`)
4. `3x` -- delete `// ` (the two slashes and the space)
5. `i` + `names.add("` + `<Esc>` -- insert the start of the call before the word
6. `A` + `");` + `<Esc>` -- append the end of the call
7. `j` -- move down one line
8. `q` -- stop recording. Only line 1 has changed so far.
9. `6@a` -- replay 6 more times (7 lines - 1)

- **Why it repeats well**: same reasoning as in the semicolon scenario above. The macro starts from a fixed place (`^`, the first non-blank, whatever the column was) and ends on `j`, so every replay starts on the next line at the right spot.
- **What is stored**: the register holds the raw keys; `:reg a` shows them.
- **Dead-key keyboard layouts (for example US International)**: the keys `^` and `"` need a following `<Space>` while you type them (and while recording); see [Keyboard layouts with dead keys](01-basics.md#keyboard-layouts-with-dead-keys-for-example-us-international).

## Scenario: convert a list of variables to assignments

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

## Scenario: turn CSV into SQL VALUES

Starting with `John,30,john@email.com`:

1. `Qa` -- start recording
2. `I('<Esc>` -- prepend `('`
3. `:s/,/','/g<CR>` -- replace the commas on this line only (use `:s`, not `:%s`)
4. `A'),<Esc>` -- append `'),`
5. `j` -- next line
6. `q` then replay

Result on the first line: `John,30,john@email.com` becomes `('John','30','john@email.com'),`. With two lines (`John,30,john@email.com` and `Amy,25,amy@email.com`), recording on line 1 and then `@a` once gives:

```
('John','30','john@email.com'),
('Amy','25','amy@email.com'),
```

## Tips for writing macros

- **Start from a consistent position**: Begin each macro from a fixed position in the line (`0` start of the line, `H` first non-blank) or from a search result. This makes the macro repeatable.
- **Use word motions, not character motions**: `w`, `e`, `b` work regardless of word length. `3l` only works for a specific column.
- **End on the next line**: If processing line-by-line, end the macro with `j` (move down) so replaying it processes subsequent lines.
- **Test with `@a` once**: Play the macro once to verify before running `100@a`.
- **Check existing registers**: `:reg` shows what's stored in each register. Macros and yanks share registers, so recording to `a` overwrites whatever was yanked to `a`.
- **Use a high count**: `999@a` will replay until it fails (e.g., end of file). Vim stops automatically on error.

## Visual mode macros

You can apply a macro to every line in a visual selection:

1. Select lines with `V` + `j`/`k`
2. Type `:normal @a` and press Enter
3. The macro runs on each selected line

Example: lines `a`, `b`, `c` and a macro `a` that does `A;<Esc>` (without the `j`: the Ex command already moves from line to line). `ggVG`, then `:normal @a` (the command line shows `:'<,'>normal @a`) gives `a;`, `b;`, `c;`. Selecting only `b` and `c` (`jVj`) leaves `a` untouched. The macro-free form `:%norm A;` gives the same result.

---

# 61. The dot command (`.`) -- repeating actions

The `.` key repeats the last change. This is arguably the most important efficiency tool in Vim.

## What counts as a "change"

- Any editing in insert mode between `i`...`<Esc>` (typed text, deletions, etc.)
- Any operator command: `dd`, `dw`, `ciw`, `>>`, `gcc`, etc.
- Surroundings: `saiw"`, `sd"`, `sr"'`
- Operator-style plugin actions: surroundings (sandwich) and `gc` comments are repeated by Vim's own `.` machinery (they set an operator function); they do not call vim-repeat in the installed copies
- Other plugin mappings, only if the plugin registers with vim-repeat (see below)

**vim-repeat** is a small helper plugin with no keys or commands of its own. It tells `.` how to repeat the last action of a plugin mapping, which Vim alone would repeat only as its last built-in command. In the installed copies of this config's plugins, targets.vim, vim-matchup (its `ds%` / `cs%` surround actions) and gitsigns (its stage-hunk and reset-hunk actions) call it, so pressing `.` after them repeats the whole action. Whether `.` really repeats a given plugin key was not tried here; if a plugin does not register with vim-repeat, `.` repeats only the last built-in step. vim-repeat loads right after the first screen (VeryLazy).

## Scenario: change a variable name one-by-one

1. Place cursor on the word `oldName`
2. `*` -- search for it (highlights all occurrences)
3. `ciw` -- change inner word, type `newName`, press `<Esc>`
4. `n` -- jump to next occurrence
5. `.` -- repeat the change (replaces `oldName` with `newName`)
6. `n` -- next occurrence
7. `.` -- repeat again
8. Skip an occurrence? Just press `n` without `.`

This gives you manual control over each replacement, unlike `:%s` which replaces all at once.

Example (tested; here `*` only highlights the word and leaves the cursor in place): `foo a foo b foo` with the cursor on the first `foo`:

| Keys | Result |
| --- | --- |
| `*ciwbar<Esc>n.` | `bar a bar b foo` (first and second changed) |
| `*ciwbar<Esc>nn.` | `bar a foo b bar` (the second is skipped with an extra `n`) |

## Scenario: add a prefix to multiple lines

1. On the first line: `I// <Esc>` (insert `// ` at start)
2. `j` -- move down
3. `.` -- repeat (adds `// ` to this line too)
4. `j.j.j.` -- keep going

Example: lines `a`, `b`, `c` -> `I// <Esc>`, `j.`, `j.` -> `// a`, `// b`, `// c`.

## Scenario: delete the first word on several lines

1. On the first line: `0dw` (go to start, delete word)
2. `j` -- move down
3. `.` -- repeat
4. Continue `j.` as needed

Example: lines `one x`, `two y` -> `0dw`, `j.` -> `x`, `y`.

## Scenario: indent multiple blocks

1. On a line: `>>` (indent right)
2. `.` -- indent again (double indent)
3. Move to another line, `.` -- indent that line too

## Combining `.` with counts

- `3.` repeats the last change 3 times (more exactly: the count replaces the one the change had). Example (tested): `a b c d e f`, `ciw` + `X` + `<Esc>`, `w`, `3.` -> `X X d e f`: the repeat is `c3iw`, and `3iw` covers `b`, the space and `c`.
- `5>>` then `.` repeats the 5-line indent

---

# 62. Visual block editing (multi-cursor-like)

Visual block mode (`<Ctrl-v>`) lets you edit rectangular columns of text. This is the closest thing to multi-cursor editing.

## Scenario: add a prefix to multiple lines at once

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

## Scenario: append text to multiple lines

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

## Scenario: delete a column

If you have aligned text and want to remove a column:

1. `<Ctrl-v>` -- block visual
2. Move to select the rectangular region (e.g., `3j10l`)
3. `d` -- delete the block

Example (tested): with the cursor on the `n` of `name`, `<Ctrl-v>jj4ld` removes the first 5 columns of all three lines:

| Before | After |
| --- | --- |
| `name  age` | ` age` |
| `bob   30` | ` 30` |
| `amy   25` | ` 25` |

## Scenario: replace a column

1. `<Ctrl-v>` -- select the column
2. `c` -- change (deletes the block and enters insert mode)
3. Type the replacement
4. `<Esc>` -- applied to all lines

Example (tested): lines `a1 b`, `a2 b`, `a3 b`, cursor on the first `a`: `<Ctrl-v>jjlcXY<Esc>` gives `XY b` on all three lines.

---

# 64. Everyday editing scenarios

## Swap two lines

1. On the first line: `dd` (cut it)
2. Move to where you want it: `j` or `k`
3. `P` (paste above) or `p` (paste below)

Or use `<Alt-j>` / `<Alt-k>` to move lines up/down without cutting.

Example (tested): lines `a`, `b`, `c`, cursor on `a`: `dd` then `p` gives `b`, `a`, `c`.

## Swap two words (vim-swap)

Plugin: **vim-swap**. Put the cursor on an item of a comma-separated list (function arguments) and press `gs`: this starts "swap mode". There `h`/`l` move the current item left/right (swap with its neighbour), `j`/`k` choose another item, `1`-`9` choose the nth item, `s`/`S` sort ascending/descending, `r` reverses, `u`/`<Ctrl-r>` undo/redo, `<Esc>` leaves swap mode. The digits only choose an item, they do not move it: to move an item several places press `h`/`l` once per step (see [section 65](#65-swapping-function-arguments-vim-swap)).

For manual word swap:
1. On the first word: `diw` (delete inner word)
2. Move to the second word: `w` or `f`
3. `viwp` -- select the second word and paste (swaps them)
4. `0P` -- go to the start of the line and paste the word that `viwp` put in the register (before the first character)

Tested on `one two` with the cursor on `one`: `diw` leaves ` two`; `w` jumps to `two`; `viwp` replaces it with `one` (the line is now ` one` and the register holds `two`); `0P` puts `two` in front: `two one`. Without step 4 the second word is lost. For function arguments or list items, `gs` above is simpler.

## Duplicate a line

1. `yy` -- yank the line
2. `p` -- paste below

Or: `yyp` (same thing). Example: lines `a`, `b`, cursor on `a`: `yyp` gives `a`, `a`, `b`.

## Duplicate a block of code

1. Select the block with `V` + `j`/`k`
2. `y` -- yank
3. Navigate to destination
4. `p` -- paste

Example (tested): lines `a`, `b`, `c`, cursor on `a`: `Vjy` copies `a` and `b`, `j` `p` pastes them below `b`: `a`, `b`, `a`, `b`, `c`.

## Fix indentation of entire file

1. `gg=G` -- go to top, auto-indent everything to bottom

Example: in a Lua buffer the lines `if x then` / `print(1)` / `end` become `if x then` / `  print(1)` / `end` (2 spaces: shiftwidth is 2).

## Remove all blank lines

1. `:%g/^$/d` -- globally delete lines matching "empty"

Careful: `^$` only matches truly empty lines. On `a`, empty, `b`, a line with two spaces, `c` it leaves the whitespace-only line (`a`, `b`, `  `, `c`). To remove those too use `:g/^\s*$/d` (see [section 71](#71-the-global-command-g)), which gives `a`, `b`, `c`.

## Sort lines

1. Select lines with `V` + movement
2. `:sort` -- sort alphabetically
3. `:sort!` -- reverse sort
4. `:sort n` -- numeric sort
5. `:sort u` -- sort and remove duplicates

| Before | Command | After |
| --- | --- | --- |
| `pear` / `apple` / `fig` | `:sort` | `apple` / `fig` / `pear` |
| `pear` / `apple` / `fig` | `:sort!` | `pear` / `fig` / `apple` |
| `item 10` / `item 9` / `item 100` | `:sort n` | `item 9` / `item 10` / `item 100` (numbers by value) |
| `b` / `a` / `b` | `:sort u` | `a` / `b` |
| `c` / `b` / `a` / `z` / `y`, `Vjj` on the first three | `:sort` | `a` / `b` / `c` / `z` / `y` (only the selection is sorted) |

## Convert tabs to spaces (or vice versa)

1. `:set expandtab` (already set by default)
2. `:retab` -- convert all tabs to spaces in the file
3. Or `:set noexpandtab` then `:retab!` for spaces-to-tabs

Example: lines `<Tab>a` and `<Tab><Tab>b` become `  a` and `    b` (tabstop is 2 here).

## Wrap a selection in a tag/function

1. Select text with `v` or `V`
2. `sa` + the surrounding character (vim-sandwich)
3. For example: select `myVar`, then `sa"` wraps it as `"myVar"`
4. For function: type `sa`, then `f`, then the function name at the prompt that appears, then `<Enter>` -- wraps as `funcName(myVar)`

Tested on `myVar`: `saiwf`, type `fn`, `<Enter>` gives `fn(myVar)`.

---

# 65. Swapping function arguments (`vim-swap`)

Plugin: **vim-swap**. Swap delimited items (function arguments, list elements, etc.) without cutting and pasting.

Place your cursor on one of the arguments inside parentheses:

| Keymap | What it does |
| --- | --- |
| `gs` | Start swap mode (then `h`/`l` swap with the neighbour, `j`/`k` choose an item, `1`-`9` pick an item, `<Esc>` exit) |

The keys inside swap mode (`h` `l` `j` `k` `1`-`9` `s` `S` `r` `u` `<Ctrl-r>`, plus `g` / `G` to group / ungroup items) are vim-swap's own defaults per its help (`:help swap.txt`), not set in this config; only the `gs` start key is defined here (`lua/plugin_specs.lua`), and the plugin's other default keys (`g<`, `g>`) are switched off so the builtin `g<` stays.

**Example**: Given `func(a, b, c)` with the cursor on `b`, press `gs`, then `l`: `b` moves one place right, giving `func(a, c, b)`. Press `<Esc>` to leave swap mode (tested).

**Moving an item several places** (tested): there is no key that sends an item straight to position N. Inside swap mode the digits `1`-`9` only CHOOSE which item is current, they do not move it. To move an item two places, stay in one swap-mode session and press one key per step: `gs`, then `h` twice, then `<Esc>`. Example: given `f(a, c, b)` with the cursor on `b`, press `gs`, `h`, `h`, `<Esc>`: `b` moves two places left, giving `f(b, a, c)`.

- Inside swap mode `u` / `<Ctrl-r>` undo/redo a step, handy when you overshoot.
- Counts inside swap mode (`2h`) have not been tried here, so the guide makes no claim about them.
- Per `:help swap.txt` (not tried here): vim-swap's own `g<` / `g>` accept a count (`2g<` would move the item two places left in one command), but this config switches those mappings off on purpose, so they are not available.

Works with any comma-separated list: function arguments, array literals, dictionary entries, etc.

---

# 68. Useful Vim tricks

## Run a normal-mode command on every line

`:g/pattern/normal @a` -- run macro `a` on every line matching `pattern`
`:g/pattern/normal dd` -- delete every line matching `pattern`
`:v/pattern/normal dd` -- delete every line NOT matching `pattern` (inverse)

Examples (tested):

| Before | Command | After |
| --- | --- | --- |
| `x` / `import a` / `y` / `import b` | `:g/^import/normal A;` | `x` / `import a;` / `y` / `import b;` |
| the same | `:g/^import/normal >>` | both `import` lines indented by 2 spaces |
| `TODO a` / `b` / `TODO c` | `:g/TODO/normal I[URGENT] ` | `[URGENT] TODO a` / `b` / `[URGENT] TODO c` |

## Execute a command on a range

`:10,20normal A;` -- append semicolons to lines 10-20
`:10,20normal I// ` -- comment out lines 10-20
`:'<,'>normal @a` -- run macro `a` on visually selected lines

Example (tested): lines `a`, `b`, `c`: `:2,3normal I// ` gives `a`, `// b`, `// c`.

## Increment/decrement numbers

| Keymap | What it does | Example |
| --- | --- | --- |
| `<Ctrl-a>` | Increment the number under cursor | `x = 7` with the cursor on the line: `<Ctrl-a>` -> `x = 8` |
| `<Ctrl-x>` | Decrement the number under cursor | `x = 7`: `<Ctrl-x>` -> `x = 6` |
| `10<Ctrl-a>` | Add 10 to the number | `x = 7`: `10<Ctrl-a>` -> `x = 17` |
| `g<Ctrl-a>` (visual block) | Sequential increment: line 1 gets +1, line 2 gets +2, line 3 gets +3... | three lines `0.`, select the column with `<Ctrl-v>2j`, `g<Ctrl-a>` -> `1.`, `2.`, `3.` |
| `g<Ctrl-x>` (visual block) | Sequential decrement (same idea, subtracting) | three lines `9`, select the column with `<Ctrl-v>2j`, `g<Ctrl-x>` -> `8`, `7`, `6` |

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

## Letter sequences (a, b, c...) instead of numbers

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

## Open the file under cursor

| Keymap | What it does |
| --- | --- |
| `gf` | Open the file path under cursor (if it exists) |
| `<Ctrl-w>f` | Open file under cursor in a split |
| `gx` | Open the URL **or file** under the cursor (gx.nvim; also on a Visual selection) |

For `gf`, put the cursor on a path such as `lua/mappings.lua` inside a string: if the file exists it opens in the current window. The path is looked up only from the current working directory ('path' is just that directory here, not the folder of the open file; in a Lua file `gf` on `lua.mappings` inside `require(...)` works too, because `.lua` is added and the dots become `/`) (tested: started in the folder that contains `lua/` it opens; started in another folder, with the file open from the first, it finds nothing).

## Change case

| Keymap | What it does | Example |
| --- | --- | --- |
| `~` | Toggle case of character(s). Since `tildeop` is set, use with a motion: `~w` toggles case of a word, `~e` to end of word. | `foo bar`: `~w` -> `FOO bar`; `Foo bar`: `~e` -> `fOO bar` |
| `gUiw` | Uppercase the entire word | `hello world` -> `gUiw` -> `HELLO world` |
| `guiw` | Lowercase the entire word | `HELLO world` -> `guiw` -> `hello world` |
| `gUU` | Uppercase the entire line | `foo bar` -> `gUU` -> `FOO BAR` |
| `guu` | Lowercase the entire line | `FOO BAR` -> `guu` -> `foo bar` |
| (in insert mode) `<Ctrl-u>` | Uppercase the current word (custom; the word touching the cursor, or the previous word if only spaces are before the cursor) | `foo` with Insert mode at its end: `<Ctrl-u>` -> `FOO` |
| (in insert mode) `<Ctrl-t>` | Toggle the case of the first letter of the current word (custom; `foo` <-> `Foo`) | `foo bar` with Insert mode inside `foo`: `<Ctrl-t>` -> `Foo bar` |

## Align text with tabular

Plugin: **tabular**. Aligns text around a character. `:Tabularize` works in every filetype from a fresh start (it loads on the first `:Tabularize`, and with the first Markdown file).

| Command | What it does | Example |
| --- | --- | --- |
| `:Tabularize /=` | Align all `=` signs in a selection or file | lines `a = 1` / `bb = 22` -> `a  = 1` / `bb = 22` |
| `:Tabularize /:` | Align colons (for JSON/YAML-like structures) | lines `a: 1` / `bbb: 22` -> `a   : 1` / `bbb : 22` (the colon column is aligned, with a space before each colon) |

Full example with `VG:Tabularize /=` on three lines (tested):

```
x = 1                x         = 1
long_name = 22  -->  long_name = 22
yy = 333             yy        = 333
```

To align the pipes of a Markdown table, type `:Tabularize /|` (shown outside the table because a pipe breaks a table row).

## Command abbreviations

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

# 71. The global command (`:g`)

The global command runs an Ex command on every line matching a pattern. It's one of the most powerful built-in features.

**Syntax**: `:g/pattern/command`

The inverse (`:v`) runs on lines that do NOT match: `:v/pattern/command`

## Common uses

| Command | What it does | Result |
| --- | --- | --- |
| `:g/TODO/d` | Delete every line containing `TODO` | lines `a TODO`, `b`, `c` -> `b`, `c` |
| `:v/TODO/d` | Delete every line that does NOT contain `TODO` (keep only TODO lines) | lines `a TODO`, `b`, `c TODO` -> `a TODO`, `c TODO` |
| `:g/^$/d` | Delete all blank lines | lines `a`, blank, `b` -> `a`, `b` |
| `:g/^\s*$/d` | Delete all blank lines (including whitespace-only) | lines `a`, a line with only spaces, `b` -> `a`, `b` |
| `:g/console\.log/d` | Delete all console.log lines | JavaScript lines `a()`, `console.log(1)`, `b()` -> `a()`, `b()` |
| `:g/pattern/normal @a` | Run macro `a` on every matching line | lines `a x`, `b`, `c x` with macro `a` = `A!<Esc>` (pattern `x`) -> `a x!`, `b`, `c x!` |
| `:g/pattern/normal A;` | Append semicolon to every matching line | lines `a x`, `b`, `c x` (pattern `x`) -> `a x;`, `b`, `c x;` |
| `:g/pattern/normal I// ` | Comment out every matching line | lines `a x`, `b`, `c x` (pattern `x`) -> `// a x`, `b`, `// c x` |
| `:g/pattern/t $` | Copy every matching line to the end of file | lines `a x`, `b` (pattern `x`) -> `a x`, `b`, `a x` |
| `:g/pattern/m 0` | Move every matching line to the top of file | lines `a`, `b x`, `c` (pattern `x`) -> `b x`, `a`, `c` |
| `:g/^import/normal >>` | Indent all import lines | lines `import a`, `b`, `import c` -> `  import a`, `b`, `  import c` |

## Everyday scenarios

Sample for the commands below: lines `a`, `TODO b`, `c`, `TODO d` (tested).

| Command | Result |
| --- | --- |
| `:g/TODO/d` | `a` / `c` |
| `:v/TODO/d` | `TODO b` / `TODO d` |
| `:g/TODO/t $` | `a` / `TODO b` / `c` / `TODO d` / `TODO b` / `TODO d` (copies of the matches at the end) |
| `:g/TODO/m 0` | `TODO d` / `TODO b` / `a` / `c` |

### Delete all print/debug statements

```
:g/print(/d                     -- Python: delete all print() lines
:g/console\.log/d               -- JS: delete all console.log lines
:g/System\.out\.print/d         -- Java: delete all System.out.println lines
:g/fmt\.Print/d                 -- Go: delete all fmt.Print lines
```

### Keep only lines matching a pattern

```
:v/error/d                      -- keep only lines containing "error"
:v/\v(import|from)/d            -- keep only import statements
```

### Extract all function signatures

```
:v/\vdef \w+\(/d                -- Python: keep only function definitions
:v/\v(public|private|protected)/d  -- Java: keep only method/field declarations
```

### Add prefix/suffix to matching lines

```
:g/TODO/normal I[URGENT] 	     -- add "[URGENT] " before every TODO line
:g/^#/normal A <!---->          -- add comment marker after every markdown heading
```

### Move lines matching a pattern to the top

```
:g/import/m 0                   -- move all import lines to the top of the file
```

This does not sort: each match is moved to line 0 in turn, so several matches end up in REVERSE order (tested). Lines `a`, `TODO b`, `c`, `TODO d` with `:g/TODO/m 0` give `TODO d`, `TODO b`, `a`, `c`. To sort lines, use `:sort` (see "[Sort lines](#sort-lines)" in [section 64](#64-everyday-editing-scenarios)).

---

# 76. Common editing power combos

Quick-reference card of the most powerful editing combinations for daily use.

## Changing text

| Combo | What it does | Example |
| --- | --- | --- |
| `ciw` | Change the word under cursor | `foo` -> type `bar` -> `bar` |
| `ci"` | Change text in double quotes | `"old"` -> type `new` -> `"new"` |
| `ci(` | Change text in parentheses | `func(old)` -> type `new` -> `func(new)` |
| `ci{` | Change text in braces | `{old}` -> type `new` -> `{new}` |
| `cit` | Change text in HTML tag | `<p>old</p>` -> type `new` -> `<p>new</p>` |
| `cc` | Change entire line | Clears the line and enters insert mode: `old line` -> type `new` -> `new` |
| `C` | Change from cursor to end of line | Deletes the rest of the line and enters insert mode: `foo bar` with the cursor on `b` -> type `baz` -> `foo baz` |
| `c$` | Same as `C` | `foo bar` with the cursor on `b` -> type `baz` -> `foo baz` |
| `ct)` | Change from cursor to before `)` (useful inside function arguments) | `f(old, x)` with the cursor on `o` -> type `new` -> `f(new)` (`old, x` is replaced) |
| `cf,` + char + label | Change from the cursor through a `,` picked with hop: `f` is hop's 2-character jump, so type `,` and the character after it, then the label (may be several lines away; see "[Precision Selection](#precision-selection-from-the-cursor-to-an-exact-spot)") | `f` is hop.nvim here, not the built-in |

## Deleting text

| Combo | What it does | Example |
| --- | --- | --- |
| `diw` | Delete word under cursor | `foo bar` with the cursor in `foo` -> ` bar` |
| `daw` | Delete word + surrounding spaces | `foo bar baz` with the cursor on `bar` -> `foo baz` |
| `di"` | Empty out double-quoted string | `x "y" z` with the cursor on `y` -> `x "" z` |
| `da"` | Delete the entire quoted string including quotes | `x "y" z` with the cursor on `y` -> `x  z` |
| `di(` | Empty out parentheses | `f(old)` with the cursor in `old` -> `f()` |
| `da(` | Delete parentheses and their contents | `f(old) x` with the cursor in `old` -> `f x` |
| `dip` | Delete paragraph | lines `a`, `b`, (blank), `c` with the cursor on `a` -> (blank), `c` |
| `dd` | Delete line | lines `a`, `b` with the cursor on `a` -> `b` |
| `D` | Delete from cursor to end of line | `foo bar` with the cursor on `b` -> `foo ` |
| `dt)` | Delete from cursor to before `)` | `f(old, x)` with the cursor on `o` -> `f()` |

## Copying text

| Combo | What it does | Register `0` afterwards holds |
| --- | --- | --- |
| `yiw` | Copy word under cursor | `foo` (for `foo bar`, cursor in `foo`) |
| `yi"` | Copy text inside double quotes | `foo` (for `x "foo" y`, cursor in `foo`) |
| `yi(` | Copy text inside parentheses | `a, b` (for `f(a, b)`, cursor inside) |
| `yap` | Copy paragraph | `a`, `b` and the blank line (for the lines `a`, `b`, (blank), `c`) |
| `yy` | Copy line | the whole line `a` (for the lines `a`, `b`) |
| `y$` | Copy from cursor to end of line | `bar` (for `foo bar`, cursor on `b`) |

## Selecting text

| Combo | What it does | Selected text |
| --- | --- | --- |
| `viw` | Select word | `foo` (for `foo bar`, cursor in `foo`) |
| `vi"` | Select inside quotes | `foo` (for `x "foo" y`, cursor in `foo`) |
| `vi(` | Select inside parentheses | `a, b` (for `f(a, b)`, cursor inside) |
| `vip` | Select paragraph | `a`, `b` (for the lines `a`, `b`, (blank), `c`; the blank line is not included) |
| `V5j` | Select 5 lines down | the current line and the 5 lines below it (6 lines) |
| `ggVG` | Select entire file | every line of the file |

## Quick transformations

| Combo | What it does | Example |
| --- | --- | --- |
| `gUiw` | Uppercase word | `hello world` -> `HELLO world` |
| `guiw` | Lowercase word | `HELLO world` -> `hello world` |
| `~w` | Toggle case of word | `foo bar` -> `FOO bar` |
| `>>` | Indent line | `foo` -> `  foo` |
| `<<` | Deindent line | `    foo` -> `  foo` |
| `==` | Auto-indent line | Lua `if a then` / `x` / `end` with the cursor on `x` -> `x` becomes `  x` |
| `gg=G` | Auto-indent entire file | the same three Lua lines -> `x` becomes `  x` |
| `gcc` | Comment/uncomment line | Lua `x = 1` -> `-- x = 1` |
| `gcip` | Comment/uncomment paragraph | Lua lines `a`, `b`, (blank), `c` with the cursor on `a` -> `-- a`, `-- b`, (blank), `c` |
| `saiw"` | Surround word with `"` | `hello` -> `"hello"` |
| `sd"` | Remove surrounding `"` | `"foo"` with the cursor on `foo` -> `foo` |
| `sr"'` | Replace `"` with `'` around current text | `"foo"` with the cursor on `foo` -> `'foo'` |
| `J` | Join current line with next | lines `foo`, `bar` -> `foo bar` |

## The most powerful patterns

| Pattern | How it works | Example |
| --- | --- | --- |
| `*` then `ciw` then `n.n.n.` | Find-and-replace one at a time with full control | `foo a foo b foo`: `*ciwbar<Esc>n.` -> `bar a bar b foo` ([section 61](#61-the-dot-command-----repeating-actions)) |
| `Qa` ... `q` then `@a` | Record and replay any sequence of actions | `a`, `b`, `c`, `d`: record `A;<Esc>j` on `a`, then `3@a` -> `a;`, `b;`, `c;`, `d;` ([section 60](#60-macros-in-depth)) |
| `V` select then `:norm @a` | Run a macro on selected lines | `a`, `b`, `c` with the macro `A;<Esc>`: `ggVG` `:normal @a` -> `a;`, `b;`, `c;` ([section 60](#60-macros-in-depth)) |
| `:g/pattern/command` | Run a command on every matching line | `:g/TODO/d` on `a`, `TODO b`, `c` -> `a`, `c` |
| `:grep "text"` then `:cfdo ...` | Project-wide search and replace; `:cfdo` only walks a quickfix list you filled first (the other do-commands `:ldo`, `:bufdo`, `:argdo`, `:windo`, `:tabdo` are in [section 67](05-search-and-files.md#understanding-cdo-vs-cfdo-vs-bufdo)); (the substitute + `\| update` recipe is in [section 67](05-search-and-files.md#67-multi-file-search-and-replace-complete-guide)) | see [section 67](05-search-and-files.md#67-multi-file-search-and-replace-complete-guide) |
| `<Space>rn` | Intelligent rename across project | N/A (an LSP rename: the symbol is renamed in every file that uses it) |
| `qf` list + `:cnext`/`:cprev` | Jump through search results or errors | N/A (moves the cursor to the next / previous entry of the quickfix list) |
| `.` | Repeat last change (combine with `n` for find-and-repeat) | `foo x foo`: `ciw` + `bar` + `<Esc>`, `ww`, `.` -> `bar x bar` |

---
