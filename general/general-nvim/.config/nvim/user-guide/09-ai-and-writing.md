<!-- chapter: Claude, Markdown, LaTeX/Typst, spelling, URLs -->
[Back to the guide index](README.md)

# 9. AI Assistant Window (Claude Code)

## Claude Code

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>cc` | n | **Toggle** Claude Code terminal (opens/closes it) |
| `<Space>a` | n | Fresh Claude session for a quick "how do I do X in Neovim" question: vertical split on the right, started in the nvim config folder with the `answering-neovim-usage-questions` skill loaded, always on the Sonnet model (`--model sonnet`) and permissions bypassed (no prompts); `/exit` closes it (on the dashboard it opens in its own tab). See section 33 "Help keys" |
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
| `^^` | n, i | Insert footnote number (markdown files only). Because of this map, a single `^` or `@` typed in insert mode appears after a short pause (500 ms), since Neovim waits for a possible second key |
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
| `<Space>rf` / `<F9>` | Start / stop continuous compilation |
| `\ll` | Start / stop continuous compilation (same as `<Space>rf` / `<F9>`) |
| `\lv` | View PDF |

The texlab language server adds diagnostics, hover, symbols and rename when `texlab` is on PATH (LaTeX devShell). Auto-save never saves LaTeX files.

## Typst

| Keymap | Description |
| --- | --- |
| `<Space>tw` | Typst buffers: `:TypstWatch`, recompile on save and open the PDF |

Needs the `typst` program (typst devShell): without it `<Space>tw` shows one warning and the Typst plugin does not load. Errors go to the quickfix list. The PDF viewer is `$TYPST_PDF_VIEWER` if set, else `zathura` if installed. LSP: `tinymist`. Typst buffers use `textwidth=100` and wrap. Auto-save never saves Typst files.

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
| `zug` | Undo the last `zg` |
| `:e ~/.config/nvim/spell/en.utf-8.add` | Show the allowed words of a language (`it`, `de`, `fr` in the other files); delete a line to remove a word |

`spellfile` has one word list per language, in the order of `spelllang` (en, it, de, fr): `zg` adds to the first, a count picks another. The lists are `spell/*.utf-8.add` inside the config, which is tracked in a PUBLIC repository: `spell/README.md` says these words are public, so review new words before committing. At startup Neovim silently recompiles any list whose compiled `.add.spl` file is missing or older, so the words of the tracked lists are accepted on a fresh checkout.

Besides the builtin spell checker two language servers report problems as diagnostics: `ltex_plus` (grammar and spelling in prose files) and `typos_lsp` (typos in identifiers and comments of source files). The statusline shows `[SPELL]` while spell checking is on.

---

# 38. URL & Unicode

| Keymap | Mode | Description |
| --- | --- | --- |
| `gx` | n, x | Open the URL or file under the cursor (gx.nvim) |
| `ga` | n | Show Unicode info for character under cursor |
| `<Ctrl-x><Ctrl-z>` | i | Complete a Unicode character by name or `U+code` |
| `<Ctrl-x><Ctrl-g>` | i | Complete a digraph |
| `<Space>cu` | n | Swap `<Ctrl-x><Ctrl-z>` between completing the character and completing its name |
| `<F4>` + motion (needs a function key; alternatives below) | n, x | Turn 2-character digraph pairs in the text into their characters |

Commands: `:UnicodeSearch {name or U+hex}`, `:UnicodeName`, `:UnicodeTable`. The plugin loads on the first `ga`, `<Space>cu` or `:UnicodeSearch`; the insert keys, `<F4>` and `:UnicodeName` / `:UnicodeTable` exist only after that. Without function keys use `<Ctrl-k>` + two letters in Insert mode (built-in Vim digraph input, outside a snippet; `<Ctrl-k>` `a` `:` gives `ä`) or `<Ctrl-x><Ctrl-g>`. Example: `<F4>$` on `a:e:o:u:` gives the umlauts (per the plugin doc).

URLs in buffers are automatically highlighted (vim-highlighturl plugin).

---
