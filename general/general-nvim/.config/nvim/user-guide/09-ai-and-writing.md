<!-- chapter: Claude, Markdown, LaTeX/Typst, spelling, URLs -->
[Back to the guide index](README.md)

# 9. AI assistant window (Claude Code, `claude-code.nvim`)

## Claude Code keys (claude-code.nvim)

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>cc` | n | **Toggle** Claude Code terminal (opens/closes it) |
| `<Space>a` | n | Fresh Claude session for a quick "how do I do X in Neovim" question: vertical split on the right, started in the nvim config folder with the `answering-neovim-usage-questions` skill loaded, always on the Sonnet model (`--model sonnet`) and permissions bypassed (no prompts); `/exit` closes it (on the dashboard it opens in its own tab). See [section 33](06-windows-terminal-sessions.md#33-ui-features) "[Help keys](06-windows-terminal-sessions.md#help-keys-the-user-guide-and-claude-any-buffer-and-the-dashboard)" |
| `<Space>cR` | n | Resume/continue the last Claude conversation (`claude --continue`) |
| `<Space>cV` | n | Start Claude in verbose mode |
| `:ClaudeCodeResume` | cmd | Start `claude --resume` (pick an older conversation; command only, no key) |
| `<Ctrl-h/j/k/l>` | t, n (Claude panel) | Move to the window left / below / above / right |
| `<Ctrl-w>h/j/k/l` | t (any Claude terminal, including the `<Space>a` split) | Move to the window left / below / above / right. Works even after you typed and pressed `<Esc>` (which goes to Claude). Press `<Ctrl-w>` (hold Ctrl, press `w`, release both), then `h`, `j`, `k` or `l` |
| `<Ctrl-f>` / `<Ctrl-b>` | t (Claude panel) | Scroll a page down / up |

Claude Code opens as a **vertical split on the right**, 30% of the screen width. It is a terminal buffer. There is no toggle key in terminal mode. To navigate:

1. **Move to the Claude window**: `<Ctrl-w>l` or `<Right>` (it opens on the right). Focusing it puts you in terminal (insert) mode by itself.
2. **Move back to code**: `<Ctrl-h>` or `<Ctrl-w>h` (both work directly in the Claude terminal; no need for `<Ctrl-\><Ctrl-n>` first). `<Ctrl-w>j/k/l` move to the other neighbours the same way. Afterwards you are in Normal mode in the target window. `<Esc>` is sent to Claude (for example to interrupt it) and does **not** leave terminal mode.
3. **Close Claude**: from the code window `<Space>cc` toggles it closed. Inside the Claude terminal press `<Ctrl-\><Ctrl-n>` first, then `<Space>cc` or `<Space>q`.
4. **Type in Claude**: If in Normal mode inside the Claude terminal, press `i` to re-enter terminal mode

Example for `<Space>a`: press it, then type a plain question such as `how do I delete everything inside quotes` and press `<Enter>`. The skill it loads answers as numbered steps that name the exact keys. `/exit` ends the session and closes the split.

Claude runs in the git root of the current file. Files Claude changes are reloaded in their buffers (checked every second while the panel is open). The panel is left out of saved sessions, and `\D` never deletes it while it runs.

---

# 49. AI-assisted development in depth

## Claude Code in depth (claude-code.nvim)

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
5. To go back to your code press `<Ctrl-w>h` (or `<Ctrl-h>`); a plain `<Esc>` goes to Claude (e.g. to interrupt it) and does not leave terminal mode. To close the panel, press `<Ctrl-\><Ctrl-n>` (leaves terminal mode), then `<Space>cc`

Claude Code uses your project's git root as the working directory. `:ClaudeCodeResume` starts `claude --resume`. Inside the panel `<Ctrl-h/j/k/l>` and `<Ctrl-w>h/j/k/l` move to the neighbour windows (the `<Ctrl-w>` forms also work in the `<Space>a` split and after typing and pressing `<Esc>`) and `<Ctrl-f>` / `<Ctrl-b>` scroll.

---

# 27. Markdown support

## Preview (markdown-preview.nvim)

| Keymap | Description |
| --- | --- |
| `<Alt-m>` | Toggle markdown preview in browser (markdown buffers only) |

## Footnotes (vim-markdownfootnotes)

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>mf` | n | Add footnote (markdown buffers only; elsewhere one warning) |
| `<Space>mr` | n | Return from footnote (markdown buffers only) |
| `^^` | n, i | Insert footnote number (markdown files only). Because of this map, a single `^` or `@` typed in insert mode appears after a short pause (500 ms), since Neovim waits for a possible second key |
| `@@` | n, i | Return from footnote (markdown files only; it shadows the macro replay `@@` in Markdown buffers) |

## Text objects & operators (Markdown only)

| Keymap | Description |
| --- | --- |
| `vic` / `vac` | Select inside / around code block |
| `+` | Convert lines to unordered list (operator: `+ip` for paragraph) |
| `<Space>mb{motion}` (or `<Space>mb` on a Visual selection) | Add a hard line break (a trailing `\`) to each line, e.g. `<Space>mbip`; blank lines and lines already ending in `\` are skipped |
| `:AddRef <label> <url>` | Add reference link at end of buffer |

Examples (all tested in a Markdown buffer):

| Keys | Before | After |
| --- | --- | --- |
| `+ip` | `plain one` / `plain two` | `+ plain one` / `+ plain two` |
| `<Space>mbip` | `plain one` / `plain two` | `plain one\` / `plain two\` |
| `<Space>mf` (cursor at the end of the line; the mark goes in at the cursor) | `Some text here.` | `Some text here.[^1]` and a new last line `[^1]: ` with the cursor behind it, ready for the note |
| `:AddRef s https://example.com` | `See [site][s].` | the same line, then a blank line, `<!-- Reference links -->` and `[s]: https://example.com` at the end of the buffer |
| `vic` (cursor inside a fenced block) | `` ```lua `` / `a = 1` / `b = 2` / `` ``` `` | the two lines `a = 1` and `b = 2` are selected, without the fences |

## Other Markdown plugins

- **render-markdown.nvim**: In-editor rendering (pauses in insert mode). Max file: 1.5MB.
- **tabular**: Table alignment. Command: `:Tabularize`
- **ltex-ls-plus (LSP)**: grammar and spell checking (LanguageTool) for markdown, tex, typst, gitcommit and text files, when `ltex-ls-plus` is installed. Problems are diagnostics: `]d` / `[d`, `<Space>dd`; fixes via `<Space>ca`.
- **marksman (LSP)**: link and heading navigation, completion, symbols.

---

# 28. LaTeX and Typst support

## LaTeX (`vimtex`)

Only available if `latex` is installed (vimtex also needs `latexmk` to compile).

| Keymap | Description |
| --- | --- |
| `<Space>rf` / `<F9>` | Start / stop continuous compilation |
| `\ll` | Start / stop continuous compilation (same as `<Space>rf` / `<F9>`) |
| `\lv` | View PDF |

The texlab language server adds diagnostics, hover, symbols and rename when `texlab` is on PATH (LaTeX devShell). Auto-save never saves LaTeX files.

## Typst (`typst.vim`, tinymist)

| Keymap | Description |
| --- | --- |
| `<Space>tw` | Typst buffers: `:TypstWatch`, recompile on save and open the PDF |

Needs the `typst` program (typst devShell): without it `<Space>tw` shows one warning and the Typst plugin does not load. Errors go to the quickfix list. The PDF viewer is `$TYPST_PDF_VIEWER` if set, else `zathura` if installed. LSP: `tinymist`. Typst buffers use `textwidth=100` and wrap. Auto-save never saves Typst files.

---

# 31. Spell checking

Languages: English, Italian, German, French.

| Keymap | Description |
| --- | --- |
| `<Space>cz` | Toggle spell checking on/off |
| `]s` / `[s` | Next / previous misspelled word |
| `z=` | Show spelling suggestions (the popup lists up to 19: keys `1`-`9`, `0`, `a`-`j`; press the key, no `<Enter>`) |
| `zg` | Add the word to the English word list (`spell/en.utf-8.add`) |
| `2zg` / `3zg` / `4zg` | Add the word to the Italian / German / French list |
| `zw` | Mark word as wrong (same counts) |
| `zug` | Undo the last `zg` |
| `:e ~/.config/nvim/spell/en.utf-8.add` | Show the allowed words of a language (`it`, `de`, `fr` in the other files); delete a line to remove a word |

`spellfile` has one word list per language, in the order of `spelllang` (en, it, de, fr): `zg` adds to the first, a count picks another. The lists are `spell/*.utf-8.add` inside the config, which is tracked in a PUBLIC repository: `spell/README.md` says these words are public, so review new words before committing. At startup Neovim silently recompiles any list whose compiled `.add.spl` file is missing or older, so the words of the tracked lists are accepted on a fresh checkout.

Example (tested): in a text file with the line `The recieve button`, `<Space>cz` switches spell checking on, `recieve` is marked, and with the cursor on it `z=` opens a popup titled "Spelling suggestions" that lists the suggestions, each with a key (`1 ➜ receive`, `2 ➜ relieve`, ...; this config's popup lists the keys `1`-`9`, `0` and `a`-`j`). Press `1` (no `<Enter>`): the line is now `The receive button`. `zg` on `recieve` instead adds the word to `spell/en.utf-8.add`, so it is no longer marked.

Besides the builtin spell checker two language servers report problems as diagnostics: `ltex_plus` (grammar and spelling in prose files) and `typos_lsp` (typos in identifiers and comments of source files). The statusline shows `[SPELL]` while spell checking is on.

---

# 38. URL & Unicode (`gx.nvim`, `vim-highlighturl`, `unicode.vim`)

| Keymap | Mode | Description |
| --- | --- | --- |
| `gx` | n, x | Open the URL or file under the cursor (gx.nvim) |
| `ga` | n | Show Unicode info for character under cursor |
| `<Ctrl-x><Ctrl-z>` | i | Complete a Unicode character by name or `U+code` |
| `<Ctrl-x><Ctrl-g>` | i | Complete a digraph |
| `<Space>cu` | n | Swap `<Ctrl-x><Ctrl-z>` between completing the character and completing its name |
| `<F4>` + motion (needs a function key; alternatives below) | n, x | Turn 2-character digraph pairs in the text into their characters |

Commands: `:UnicodeSearch {name or U+hex}`, `:UnicodeName`, `:UnicodeTable`. The plugin loads on the first `ga`, `<Space>cu` or `:UnicodeSearch`; the insert keys, `<F4>` and `:UnicodeName` / `:UnicodeTable` exist only after that. Without function keys use `<Ctrl-k>` + two letters in Insert mode (built-in Vim digraph input, outside a snippet; `<Ctrl-k>` `a` `:` gives `ä`) or `<Ctrl-x><Ctrl-g>`. Example: `<F4>$` on `a:e:o:u:` gives the umlauts (per the plugin doc).

Examples (tested): in Insert mode `<Ctrl-k>` `a` `:` types `ä`. `ga` with the cursor on that `ä` prints `'ä' U+00E4 Dec:228 LATIN SMALL LETTER A WITH DIAERESIS (a: a") &auml; /\%ue4 "\u00e4"`: the character, its code point and decimal value, its name, its digraph and its HTML entity.

URLs in buffers are automatically highlighted (vim-highlighturl plugin).

---
