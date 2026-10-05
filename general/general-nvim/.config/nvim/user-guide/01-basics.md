<!-- chapter: Basics: modes, saving, recovering, getting help -->
[Back to the guide index](README.md)

# 1. Understanding modes

Neovim is a modal editor. You are always in one of these modes:

| Mode | How to enter | What it does |
| --- | --- | --- |
| **Normal** | `<Esc>` from any mode | Navigate, delete, copy, paste, run commands. This is your "home base". |
| **Insert** | `i`, `a`, `o`, `O`, `c` from Normal (`s` is disabled here: it is the vim-sandwich prefix) | Type text into the file. |
| **Visual** | `v`, `V`, `<Ctrl-v>` from Normal | Select text (character, line, or block). |
| **Command** | `;` or `:` from Normal | Type commands at the bottom of the screen (e.g., `:w` to save). |
| **Terminal** | When inside a terminal buffer | Interact with a shell. Press `<Esc>` to go to Normal mode (in a Claude terminal `<Esc>` goes to Claude: `<Ctrl-w>h/j/k/l` still move to another window, `<Ctrl-\><Ctrl-n>` leaves terminal mode). |

### Entering insert mode

| Keymap | Description |
| --- | --- |
| `i` | Insert before cursor |
| `I` | Insert at beginning of line |
| `a` | Insert after cursor |
| `A` | Insert at end of line |
| `o` | Open new line below and insert |
| `O` | Open new line above and insert |

### Leaving insert mode

| Keymap | Description |
| --- | --- |
| `<Esc>` | Return to Normal mode |
| `jk` (typed quickly) | Return to Normal mode (via better-escape.vim plugin, 200ms window) |

### Visual mode variants

| Keymap | Description |
| --- | --- |
| `v` | Character-wise visual (select individual characters) |
| `V` | Line-wise visual (select entire lines) |
| `<Ctrl-v>` | Block visual (select a rectangular block of text) |

What each one selects, on `alpha beta gamma` with the cursor on the `b` of `beta` (the selection is shown in `[ ]`):

```
alpha beta gamma        cursor on the b of beta
v e         ->  alpha [beta] gamma         characters from the cursor to the end of the word
V           ->  [alpha beta gamma]         the whole line
<Ctrl-v> j  ->  a rectangle: the same columns on this line and on the next one
```

---

# 69. Tips for Vim beginners

## The most important habits

1. **Stay in Normal mode**. Only enter Insert mode to type, then immediately `<Esc>` back. Normal mode is where all the power lives.
2. **Think in verbs + nouns**. `d` (delete) + `iw` (inner word) = delete word. `c` (change) + `i"` (inside quotes) = change quoted text. `y` (yank) + `ap` (around paragraph) = copy paragraph.
3. **Use `.` aggressively**. Make one change, then `.` to repeat it everywhere.
4. **Use `*` and `n`**. Search for a word with `*`, jump through occurrences with `n`.
5. **Use text objects**. `ciw`, `di(`, `va"` are faster than selecting character-by-character.
6. **Press `<Space>` and wait**. The which-key popup shows you all available keybindings.

Example for habit 2: on `x = compute("old", 5)` with the cursor anywhere inside `"old"`, press `ci"`, type `new` and press `<Esc>`: the line becomes `x = compute("new", 5)` (tested).

## Common mistakes and how to fix them

| Problem | Cause | Fix |
| --- | --- | --- |
| Typing random commands instead of text | You're in Normal mode | Press `i` to enter Insert mode first |
| Text won't stop appearing | You're in Insert mode | Press `<Esc>` to go back to Normal |
| Screen looks weird / frozen | You pressed `<Ctrl-s>` (terminal freeze) | Press `<Ctrl-q>` to unfreeze. (In kitty + tmux with this config `<Ctrl-s>` did not freeze the screen: tested. In Insert/Select mode `<Ctrl-s>` is LSP signature help.) |
| Can't exit Neovim | `:q` only closes the current window, and with unsaved changes it asks "Save changes?" instead of quitting (the `confirm` option is on) | Type `<Space>Q` and answer `y` to the confirmation, or `;qa!<Enter>` (no confirmation) |
| Pasted text looks wrong | Paste from outside with `<Ctrl-v>` in terminal mode | Use `"+p` in Normal mode, or the terminal paste key |
| Search highlight won't go away | Yellow boxes left over from a search or `*` | Type `;noh<Enter>` (tested). `<Esc>` does **not** clear it in this config |
| Accidentally opened a macro | Pressed `Q` | Press `q` to stop recording |
| A key like `"` does nothing until you press another key, or an accented letter appears (`ë`, `è`) | Your keyboard layout uses **dead keys** (see below) | Press `<Space>` right after the key |

## Keyboard layouts with dead keys (for example US International)

Some layouts (for example US International, used on the main machine) treat certain keys as **dead keys**: the key does not type anything by itself, it waits for the next key to decide. `"` followed by `e` gives `ë`; `"` followed by `<Space>` gives a plain `"`. Neovim only receives the character after that decision, so commands that need `"` look like they do nothing.

- **Symptom (tested with `"`)**: `vt"l` selected nothing, because `t` kept waiting for its character. `vt"<Space>l` works. In a search, `v/"<Enter>` worked because `<Enter>` also ends the wait.
- **The rule**: after a dead key, press `<Space>` before continuing (`vt"<Space>l`).
- **Keys that may be affected** (not confirmed, depends on the layout; `"` is the only one tested): `'` and `` ` `` (marks such as `` `a `` and `'a`), `"` (registers such as `"ay`, text objects such as `ci"`), `~` (toggle case) and `^` (start of line). Without the space, a dead key followed by a letter can become an accented letter (`"a` -> `ä`, `` `a `` -> `à`) and the Vim command never runs.
- **This is not Neovim**: it happens in any application with that layout. A different PC may have a different layout, so if a key does nothing or types a strange character, check the layout before suspecting the config.
- **Quick test in Insert mode**: type the key, then a letter (`"e`); if you get an accented letter, it is a dead key on your layout.

## Learning path

1. First week: `h j k l`, `i`, `<Esc>`, `:w`, `:q`, `dd`, `yy`, `p`, `u`
2. Second week: `w`, `b`, `e`, `0`, `$`, `gg`, `G`, `/search`, `n`, `N`
3. Third week: `ciw`, `di(`, `vi"`, `V`, `>`, `<`, `.`
4. Fourth week: `<Space>ff`, `<Space>fg`, `gd`, `K`, `<Space>ca`, `gcc`
5. After that: Macros, quickfix, text objects, splits, registers

---

# 70. The verb + noun system (how Vim commands work)

This is the single most important mental model for understanding Vim. Almost every command follows this pattern:

**`[count] operator motion`** or **`[count] operator text-object`**

- **Operator** (verb): What you want to do (`d` delete, `c` change, `y` yank, `>` indent, `gU` uppercase, etc.)
- **Motion** (noun): Where to do it (`w` word, `$` end of line, `gg` top of file, `}` next paragraph, etc.)
- **Text object** (noun): A structural unit to act on (`iw` inner word, `i(` inside parentheses, `at` around an HTML tag, etc.)
- **Count**: How many times (optional)

## Operators (verbs)

| Operator | What it does | Example |
| --- | --- | --- |
| `d` | **Delete** (and cut to register) | `dw` on `foo bar` -> `bar` |
| `c` | **Change** (delete and enter insert mode) | `cw`, type `x` on `foo bar` -> `x bar` |
| `y` | **Yank** (copy) | `yw` on `foo bar` copies `foo `; `p` pastes it |
| `>` | **Indent** right | `>>` on `foo` -> `  foo` (2 spaces: this config's shiftwidth) |
| `<` | **Indent** left | `<<` on `    foo` -> `  foo` |
| `=` | **Auto-indent** (fix indentation) | `=ip` on the Lua lines `if a then` / `x` / `end` -> the `x` line gets 2 spaces |
| `gU` | Convert to **UPPERCASE** | `gUw` on `foo bar` -> `FOO bar` |
| `gu` | Convert to **lowercase** | `guw` on `FOO BAR` -> `foo BAR` |
| `~` | **Toggle case** (in this config `~` is an operator because `tildeop` is set) | `~w` on `foo bar` -> `FOO bar` |
| `gc` | **Toggle comment** (vim-commentary) | `gcc` on `x = 1` in a Lua file -> `-- x = 1` |
| `gcs` / `gcr` | **Comment** / **uncomment** whole rows (smart commenting) | `gcsip` on the Lua lines `a = 1` / `b = 2` -> `-- a = 1` / `-- b = 2`; `gcrip` removes the markers again |
| `gq` | **Format/wrap** text | `gqq` on one very long line re-wraps it into several lines of at most 79 columns |

## Motions (nouns)

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

Where the cursor ends up, on the line `  total = price * 3;` (two leading spaces) with the cursor on the `t` of `total` (tested):

| Keys | Cursor lands on |
| --- | --- |
| `w` | the `=` (start of the next word) |
| `e` | the last `l` of `total` (end of the word) |
| `$` | the `;` (end of the line) |
| `0` | the first space (column 1) |
| `^` | the `t` of `total` (first non-blank character) |

## Text objects (structured nouns)

| Text Object | What it selects | Example (with `d`) |
| --- | --- | --- |
| `iw` / `aw` | Inner word / a word (with whitespace) | `diw` on `foo bar` (cursor in `foo`) -> ` bar`; `daw` -> `bar` |
| `iW` / `aW` | Inner WORD / a WORD | `diW` on `a.b c` (cursor on `a`) -> ` c`; plain `diw` would only delete `a` |
| `is` / `as` | Inner sentence / a sentence (with trailing whitespace) | `das` on `One. Two. Three.` (cursor in `Two.`) -> `One. Three.`; `dis` -> `One.  Three.` |
| `iS` / `aS` | vim-sandwich "query" object: type the surrounding character after it, e.g. `diS(`, `caS"`, `viS[` (inside / around that surrounding pair) | `diS(` on `f(old)` (cursor in `old`) -> `f()` |
| `ip` / `ap` | Inner paragraph / a paragraph | `dip` on the lines `a` / `b` / (blank) / `c` -> (blank) / `c`; `dap` -> `c` |
| `i(` / `a(` | Inside / around parentheses | `di(` on `f(old)` -> `f()`; `da(` on `f(old) x` -> `f x` |
| `i{` / `a{` | Inside / around braces | `di{` on `{old}` -> `{}`; `da{` on `x {old} y` -> `x  y` |
| `i[` / `a[` | Inside / around brackets | `di[` on `x [old] y` -> `x [] y` |
| `i"` / `a"` | Inside / around double quotes | `di"` on `x "y" z` -> `x "" z`; `da"` -> `x  z` |
| `i'` / `a'` | Inside / around single quotes | `di'` on `x 'old' y` -> `x '' y` |
| `it` / `at` | Inside / around HTML tags | `dit` on `<p>old</p>` -> `<p></p>`; `dat` on `a <b>old</b> c` -> `a  c` |

## Combining verbs and nouns

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

Worked example (tested) on the line `call(foo, "bar baz", [1, 2])`; the cursor is on the word named in the first column:

| Cursor | Keys | After |
| --- | --- | --- |
| on `foo` | `di(` | `call()` |
| on `foo` | `da(` | `call` |
| on `bar` | `di"` | `call(foo, "", [1, 2])` |
| on `bar` | `da"` | `call(foo, , [1, 2])` |
| on `bar` | `ci"` + `X` + `<Esc>` | `call(foo, "X", [1, 2])` |
| on `foo` | `dt,` | `call(, "bar baz", [1, 2])` |
| `<p>old</p>`, on `old` | `cit` + `new` + `<Esc>` | `<p>new</p>` |
| `<p>old</p>`, on `old` | `dit` | `<p></p>` |
| `a` / `b` / (blank) / `c`, on `a` | `>ip` | `  a` / `  b` / (blank) / `c` |
| `a` / `b` / `c` / `d` in a Lua file, on `a` | `gc2j` | `-- a` / `-- b` / `-- c` / `d` |

## Using counts

Counts multiply the action:

| Command | What it does | Example |
| --- | --- | --- |
| `3dw` | Delete 3 words | `3dw` on `a b c d e` -> `d e` |
| `5dd` | Delete 5 lines | `5dd` on 7 lines deletes the first 5; lines 6 and 7 remain |
| `2yy` | Yank 2 lines | `2yy` on the lines `1`, `2`, `3` copies `1` and `2` |
| `3>>` | Indent 3 lines | `3>>` on the lines `a`, `b`, `c`, `d` indents `a`, `b`, `c`; `d` is unchanged |
| `10j` | Move down 10 lines | `10j` from line 1 puts the cursor on line 11 |

## Why this matters

Once you learn a few operators and a few motions/text-objects, you can combine them freely. Learning one new operator (e.g., `gU` for uppercase) instantly gives you dozens of new commands (`gUiw`, `gUi"`, `gU$`, `gUap`, etc.) without memorizing anything extra.

---

# 72. Saving, quitting, and file state

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

## Closing buffers (without quitting Neovim)

| Keymap | What it does |
| --- | --- |
| `\d` | Close current buffer, keep the window (shows previous buffer) |
| `\D` | Close all other buffers; buffers with unsaved changes and running terminals (Claude panel, `:terminal`) are kept, with one warning |

---

# 73. Recovering from mistakes

## Undo and redo

| Keymap | What it does |
| --- | --- |
| `u` | Undo the last change |
| `<Ctrl-r>` | Redo (undo the undo) |
| `U` | Undo all changes on the current line (rarely used) |

Example (tested): on the line `one two three`, `ciw` + `A` + `<Esc>`, `w`, `ciw` + `B` + `<Esc>` give `A B three`. Then:

| Keys | Result |
| --- | --- |
| `u` | `A two three` (only the last change is undone) |
| `uu` | `one two three` |
| `uu` then `<Ctrl-r>` | `A two three` (the first change is redone) |
| `U` | `one two three` (the whole line is back in one step) |
| `U` then `u` | `A B three` (`U` is itself a change, so `u` undoes the `U`) |

## Undo tree (builtin)

Vim's undo history is a tree, not a linear stack. If you undo several times and then make a new edit, the old states aren't lost -- they become branches. Neovim's builtin undo tree (`nvim.undotree`) shows this tree.

| Keymap | What it does |
| --- | --- |
| `<Space>u` | Toggle a 30-column undo tree panel on the far left |

Inside the panel just move the cursor (`j`/`k`): the buffer switches to that undo state. Close it with `<Space>u` again or `:q`.

Example of a branch (tested, including the panel, in a real terminal):

1. In an empty buffer press `ione<Esc>`, then `ccTWO<Esc>`: the buffer is `TWO`.
2. Press `u`: the buffer is `one` again.
3. Now `ccTHREE<Esc>`: the buffer is `THREE`. `TWO` is not on the undo path any more (`u` from here goes back to `one`), but it is not lost: it is a side branch of the tree.
4. `g-` (go back in time, builtin) shows `TWO` again. In the panel the fork is drawn like this, and the buffer text follows the row the cursor is on (cursor on the `| *` row: `TWO`; one row up: `one`; on the last row: `THREE`):

```
 *    0    (origin)
 *    1    (9 seconds ago)
 |\
 | *    2    (7 seconds ago)      <- TWO, the side branch
 *    3    (3 seconds ago)        <- THREE, where you are
```

## Time-based undo

| Command | What it does |
| --- | --- |
| `:earlier 5m` | Restore the file to how it was **5 minutes ago** |
| `:earlier 1h` | Restore to **1 hour ago** |
| `:earlier 10` | Undo 10 changes |
| `:later 5m` | Go forward 5 minutes (redo) |
| `:earlier 1f` | Go back to the state before the last file save |

This works because Neovim stores persistent undo history (the `undofile` option is enabled). Even if you close and reopen a file, you can still undo.

## If you accidentally deleted a file

The `auto-save.nvim` plugin saves when you leave a buffer or Neovim loses focus, and Neovim creates backups in `~/.local/share/nvim/backup/`. You may be able to recover from there.

---

# 74. Discovering keymaps and getting help

## See available keybindings with which-key.nvim

Press **`<Space>`** (the leader key) and **wait about 200ms**. A popup appears showing every available `<Space>+...` keybinding organized by category. A single key is shown with its description, a key that starts several keymaps is shown as `+` and a count. Below is a simplified sketch (the real popup lists many more keys, draws a small arrow glyph instead of `->` and its counts change whenever keymaps are added):

```
 w -> save buffer
 u -> toggle undo tree
 f -> +N keymaps
 g -> +N keymaps
 j -> +Java
```

You can also press any partial key sequence and wait:
- `g` then wait -- shows all `g...` keybindings
- `z` then wait -- shows all `z...` keybindings (folding, spelling, etc.)
- `<Ctrl-w>` then wait -- shows all window management keybindings
- `"` then wait -- shows all registers

## Browse all keymaps

| Command | What it does |
| --- | --- |
| `:Telescope keymaps` | Searchable list of all defined keymaps |
| `m` on the dashboard | Search keymaps (fzf-lua) |
| `:map` | Show all mappings (raw output) |
| `:nmap` | Show normal-mode mappings |
| `:imap` | Show insert-mode mappings |
| `:vmap` | Show visual-mode mappings |
| `:verbose nmap <Space>fg` | Show exactly where a specific mapping was defined (the file; for a mapping written in Lua there is no line number unless Neovim runs with `-V1`) |

Real output of `:verbose nmap <Space>fg` (tested):

```
n  <Space>fg   * <Cmd>FzfLua live_grep<CR>
                 Fuzzy grep files
        Last set from .../nvim/init.lua (run Nvim with -V1 for more details)
```

The first line is the mode and the key with what it runs, the second line is its description, the last line is the file that defined it.

## Getting help

| Command | What it does |
| --- | --- |
| `:help keyword` | Open Neovim's built-in help for any topic |
| `:help ciw` | Help on the `ciw` motion |
| `:help :substitute` | Help on the substitute command |
| `<Space>fh` | Fuzzy search help tags |
| `<Space>?` | Open this user guide as a PDF next to Neovim |
| `<Space>a` | Ask Claude how to do something in Neovim (vertical split with the skill loaded, always Sonnet) |
| `K` (on a symbol) | LSP hover documentation |

## Checking system health

| Command | What it does |
| --- | --- |
| `:checkhealth` | Diagnose installation issues (LSP servers, providers, etc.) |
| `:LspInfo` | LSP status: opens `:checkhealth vim.lsp` (clients and configuration) |
| `:LspAttached` | Popup with the LSP servers attached to this buffer |
| `:Lazy` | Open the plugin manager |
| `:messages` | Show recent notification messages |

---
