<!-- chapter: Markdown -->
[Back to the guide index](../README.md)

# 81. Markdown (writing, preview, footnotes, PDF)

This section covers everything your config does that is specific to `.md` files: what each tool is for, how it works, the exact keys, and what to do when it fails. Global things (diagnostics keys, code actions, the spell keys, `gc` comments) are only mentioned briefly with a pointer. Section 27 is the short key list; this one is the full story.

Most results below were checked in a real Neovim session today (marked "tested"). The few things that could not be tested say so where they appear.

## The tools and why they exist

| Tool | Why it is in your setup | What it gives you |
| --- | --- | --- |
| marksman (LSP) | Markdown has links and headings that point to each other | Link and heading completion, jump to a heading, symbols. Only for plain `markdown` files |
| ltex_plus (LSP, LanguageTool) | Prose needs grammar checking, not only spelling | Grammar and spelling problems as diagnostics. Language fixed to `en-US` |
| typos_lsp | Catches common typos in every file type | Diagnostics like `recieve` to `receive` |
| render-markdown.nvim | Raw Markdown is hard to read | Headings, lists, code blocks, tables, checkboxes drawn nicely inside the buffer |
| markdown-preview.nvim | See the final look in a browser | Live preview, `<Alt-m>` toggles it |
| vim-markdownfootnotes | Footnotes need numbering and a jump back | `^^` / `<Space>mf` create a footnote, `@@` / `<Space>mr` return |
| `:AddRef` (your own command) | Reference-style links keep the text readable | Adds `[label]: url` at the end of the file |
| prettier (via `<Space>fm`) | marksman cannot format | Tidies lists, tables, spacing |
| tabular | Align table columns | `:Tabularize /\|` |
| `ic` / `ac` (your own text objects) | Work on fenced code blocks quickly | `dic`, `yac`, `vic` ... |
| `+` (your own operator) | Make a list from plain lines | `+ip` |
| `<Space>mb` (your own operator) | Hard line breaks in Markdown | Adds a trailing `\` |
| `:ToPDF` (your own command) | Share a document as PDF | pandoc plus xelatex, PDF next to the file |
| smart_comment | Comments in Markdown are HTML comments | `gc` writes `<!-- ... -->` (the filetype's comment string); `gcs` / `gcr` (smart comment) use the language of the fence inside a fenced block |

Settings for the Markdown filetype (`after/ftplugin/markdown.vim`):

```vim
setlocal concealcursor=c
setlocal synmaxcol=3000  " For long Chinese paragraphs
setlocal wrap
```

Tested in a Markdown buffer: `wrap` is on (the global default is off), `textwidth` is 0, `colorcolumn` is 100, `synmaxcol` is 3000, `conceallevel` is 3. `concealcursor` shows as empty: render-markdown.nvim sets its own conceal options on the window after the ftplugin, so the `concealcursor=c` line in the file has no visible effect. Facts that follow from this:

- Long lines wrap at word boundaries (`linebreak` is on globally). Neovim never hard-wraps while you type (no `textwidth`), and prettier keeps your line breaks.
- Syntax colours stop after column 3000 of a very long line.

## Quick start

1. Open a file, for example `nvim "my notes.md"`. In normal mode headings, lists, code blocks and tables are drawn nicely. While you type in insert mode the drawing pauses (`render_modes`), and returns after about half a second in normal mode.
2. Press `<Alt-m>`. The browser opens with a live preview. Press `<Alt-m>` again to stop it.
3. Press `<Space>fm`. Prettier tidies the file as one undo step (`u` undoes it). The file is not saved to disk.
4. Footnote: put the cursor on the last letter of a sentence, press `<Space>mf`. A `[^1]` appears and the cursor jumps to the new `[^1]: ` line at the end of the file (in normal mode: press `A` to type the note). Press `@@` to jump back.
5. PDF: save (`:w`) and run `:ToPDF` from a Neovim that was started inside the latex dev shell. Wait 30 seconds or more the first time. `my notes.pdf` appears next to the file.

## Requirements

| Tool | Where it comes from | Needed for |
| --- | --- | --- |
| marksman, prettier, ltex-ls-plus, typos-lsp | Global nix profile (`~/nix/users/krit/common/programs/cli-programs/neovim.nix`) | LSP features, `<Space>fm`, grammar, typos |
| node and npm | Needed once by lazy.nvim to build the preview server (`cd app && npm install`) | `<Alt-m>` |
| A web browser | Your system default | `<Alt-m>` |
| pandoc, xelatex | Only in the latex dev shell (`~/nix/templates/krit/dev-environments/language-specific/latex/flake.nix`: `pandoc` and `texlive.combined.scheme-full`) | `:ToPDF` |

Tested: inside the latex dev shell `prettier`, `pandoc`, `xelatex` and `marksman` are all found by Neovim, and the attached LSP clients on a `.md` file are `ltex_plus`, `marksman`, `typos_lsp`. Note that `pandoc` is also found on this system outside the dev shell (it is on the system PATH), but `xelatex` and `prettier` are not found by a plain shell: Neovim must be started from a shell where they are on PATH (the dev shell, or the nix profile that provides them).

If a tool is missing, nothing falls back to a plain Vim key:

- No prettier: `<Space>fm` shows one warning `Markdown: prettier not found on PATH`.
- No pandoc: `:ToPDF` shows the error `pandoc not found`.
- No xelatex: pandoc runs and fails, one warning `ToPDF: pandoc failed (exit N)`.
- No marksman or ltex-ls-plus: that LSP simply does not start (check with `:checkhealth vim.lsp`).

## Try the keys: an example file

Create a scratch file and paste this text. All the examples below refer to it.

````markdown
# Title

Some text here.

```python
x = 1
y = 2
```

* item a
* item b


plain one
plain two

| a | b |
|---|---|
| longer cell | x |

A sentence.
````

## Keys

All keys work only in Markdown buffers unless stated. `<Space>` is the leader key.

| Keymap | Mode | What it does |
| --- | --- | --- |
| `<Alt-m>` | n | Toggle the browser preview. In another file type: one warning `Markdown preview: only in markdown buffers` |
| `<Space>mf` | n | Add a footnote after the character under the cursor (see Footnotes). Elsewhere: one warning |
| `<Space>mr` | n | Return from the footnote to the text. Elsewhere: one warning |
| `^^` | n, i | Add a footnote before the character under the cursor (see the off-by-one note below) |
| `@@` | n, i | Return from the footnote (replaces the macro replay `@@` in Markdown) |
| `<Space>fm` | n | Format the file with prettier |
| `<Space>mb` + motion | n | Add a trailing `\` (hard line break) to the lines of the motion, e.g. `<Space>mbip` |
| `<Space>mb` | x | Same on a Visual selection |
| `+` + motion | n | Put `+ ` in front of the lines of the motion: `+ip` |
| `+` | x | Same on a Visual selection |
| `ic`, `ac` | o, x | Fenced code block, without or with the fence lines: `vic`, `dic`, `yac`, `cic` |
| `]]` / `[[` | n, x | Next / previous heading (levels 1 to 5) |
| `gO` | n | Outline: opens a location list window with one line per heading, indented by level (tested: `Heading One`, `  Heading Two`, `    Heading Three`). `<CR>` jumps to the heading, `:lclose` closes it |
| `<Space>t` | n | Aerial symbol outline panel; `]t` / `[t` next / previous symbol |
| `<Space>cz` | n | Toggle spell checking (global key, see Writing quality) |
| `<Space><Space>` | n | Trailing-space remover, but in Markdown it only warns `markdown: trailing spaces are hard line breaks, not stripped` (tested) |
| `:AddRef <label> <url>` | cmd | Add a reference link at the end of the file |
| `:Tabularize /\|` | cmd | Align table columns |
| `:ToPDF` | cmd | Export a PDF |
| `:RenderMarkdown toggle` | cmd | Turn the rendering off / on |

Global keys that also work here: `<Space>ca` (code action, for example a ltex_plus fix), `<Space>dd`, `]d`, `[d` (diagnostics), `<Space>rn` renames through marksman (headings and links; tested: marksman advertises rename).

Accepted effects of the footnote maps:

- A single `^` or `@` typed in insert mode appears after 500 ms, because Neovim waits for a possible second key. `^` followed by any other key comes out at once.
- In normal mode `@@` is not "repeat last macro" in Markdown (tested: it is `<Plug>ReturnFromFootnote`). Use `@a` with the register name instead.

## Text objects and operators

These live in `after/ftplugin/markdown.vim`. Tested on the example file:

| You do (cursor on a line inside the code block) | Result |
| --- | --- |
| `dic` | The two code lines are deleted, the lines with the fences stay (an empty block) |
| `dac` | The whole block with both fences is deleted |
| `yac` then `p` | The block, fences included, is copied and pasted |
| `dic` then `u` | Everything is back (one undo step) |

| You do | Result |
| --- | --- |
| `+ip` on `plain one` | Both lines become `+ plain one` and `+ plain two` |
| `V`, `j`, `+` | The same on the Visual selection |
| `<Space>mbip` on `plain one` | The lines become `plain one\` and `plain two\` |

Notes: `+` keeps existing indentation (`  + text`). `<Space>mb` skips blank lines and lines that already end in `\`. `+` is also a normal Vim key (next line start) that is replaced here in Markdown buffers.

The `+` map is built so a count works (`3+j`): the file explains that a plain `:set` style map would turn the count into a range and give error E481.

## Footnotes

Why: you write the sentence, press a key, write the note, jump back, without scrolling to the end and counting numbers.

How it works: vim-markdownfootnotes inserts `[^N]` in the text and a line `[^N]: ` at the end of the file, numbering them in order. Your config adds the keys `^^` and `@@` and removes the plugin's own `<Space>f` and `<Space>r` maps in Markdown, because with Space as leader they swallowed `<Space>f...` typed quickly.

Tested flow (normal mode):

1. Cursor on the last letter of `Some text here.` (`$` puts it on the period).
2. `<Space>mf`. The line becomes `Some text here.[^1]` (the mark is inserted after the character under the cursor) and the cursor sits on the new last line `[^1]: ` in normal mode.
3. Press `A`, type `My note`, press `<Esc>`.
4. Press `@@` (or `<Space>mr`). The cursor is back at the `[^1]` in the sentence.

Tested flow (insert mode, the `^^` variant):

```text
Mid word done.   (cursor before "word", in insert mode, type ^^)
```

The result is `Mid [^1]word done.` and you are still in insert mode on the note line: type the note, then `<Esc>`, then `@@` to go back. A second footnote becomes `[^2]` and its note is added under `[^1]: ...`.

The off-by-one at the end of a line (tested): in insert mode with the cursor at the very end of a line, `^^` puts the mark one character too early (`Neovim is fas[^1]t`). The reason is that the `<C-O>` command inside the map first moves the cursor onto the last character, and `^^` inserts before that character. Typing `^^` in the middle of a line is exact. At the end of a line, end the sentence in normal mode instead: `<Esc>`, `<Space>mf` (inserts after the last character). In normal mode `^^` inserts before the character under the cursor, `<Space>mf` after it.

## Reference links and tables

```text
:AddRef docs https://neovim.io/doc
```

Tested result at the end of the buffer (a blank line, a comment line once, then the definition):

```markdown
<!-- Reference links -->
[docs]: https://neovim.io/doc
```

A second `:AddRef two https://a.b` adds only `[two]: https://a.b` under it (the comment line is not repeated). In the text you write `[the docs][docs]`. The first argument completes from labels already used as `[text][label]` in the file. Label and URL cannot contain spaces; there is no title argument.

Tables (tested): select the table lines and run `:'<,'>Tabularize /|`:

```markdown
| a           | b   |
| ---         | --- |
| longer cell | x   |
```

Tabularize pads the separator row with spaces. `<Space>fm` is the better table aligner: prettier makes the separator row `| ----------- | --- |` (tested).

Checkboxes (`- [ ]`): render-markdown draws them; no key toggles them.

## Preview (markdown-preview.nvim)

Why: render-markdown shows structure in the editor, the browser preview shows the final look (fonts, images, math, diagrams).

How: the plugin starts a small node server and opens your default browser. The server follows the text and the cursor while you edit.

Config (from `lua/plugin_specs.lua`):

```lua
{
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install && git restore .",
  ft = { "markdown" },
  init = function()
    -- Do not close the preview tab when switching to other buffers (all platforms)
    vim.g.mkdp_auto_close = 0
  end,
},
```

| Command | What it does |
| --- | --- |
| `:MarkdownPreview` | Start the preview and open the browser |
| `:MarkdownPreviewStop` | Stop it |
| `:MarkdownPreviewToggle` | Start or stop (what `<Alt-m>` runs) |

- Tested: the three commands exist in a Markdown buffer and `vim.g.mkdp_auto_close` is `0`.
- Tested server life cycle (browser launch replaced by a no-op function, port fixed to 18765): before `<Alt-m>` nothing listens; after `<Alt-m>` a server listens on `127.0.0.1:18765` and the plugin reports `Preview page: http://localhost:18765/page/1`; after the second `<Alt-m>` the port is closed. By default the port is random and only the local machine can connect (`mkdp_open_to_the_world = 0`).
- To try this yourself without a browser tab: `:let g:mkdp_browserfunc = 'NoBrowser'` after defining `function! NoBrowser(url)` that does nothing, and `:let g:mkdp_echo_preview_url = 1` to see the address.
- `mkdp_auto_close = 0`: the browser tab stays open when you switch to another buffer. It ends when you press `<Alt-m>` again or leave Neovim.
- No browser, port or theme is set, so the plugin defaults and your system default browser are used.
- Outside Markdown buffers `<Alt-m>` shows one warning (the real map is buffer-local in `after/ftplugin/markdown.lua`).
- After a fresh install the server may not be built: `:Lazy build markdown-preview.nvim` (needs `npm`).

## Rendering inside the buffer (render-markdown.nvim)

Why: you read Markdown all day; rendered headings and tables are easier on the eyes, and the raw text is one `<Esc>`-then-`i` away.

Config (from `lua/plugin_specs.lua`):

```lua
opts = {
  debounce = 500,
  render_modes = { "n", "c" },
  max_file_size = 1.5,
  anti_conceal = { enabled = true },
},
```

| Setting | Meaning |
| --- | --- |
| `render_modes = n, c` | Rendered only in normal and command mode; insert mode shows the raw text |
| `debounce = 500` | Waits 0.5 s after typing stops before redrawing |
| `max_file_size = 1.5` | Files over 1.5 MB are not rendered (and the big-file mode takes over, see below) |
| `anti_conceal` | The line under the cursor shows raw text so you can edit it |

Commands (all tested to run without error; the global state changed `true`, `false`, `true` with two `toggle` calls):

| Command | Effect |
| --- | --- |
| `:RenderMarkdown toggle` | Rendering off / on in all buffers |
| `:RenderMarkdown buf_toggle` | Same, this buffer only |
| `:RenderMarkdown enable` / `disable` | Explicit on / off |
| `:RenderMarkdown buf_enable` / `buf_disable` | Explicit on / off, this buffer only |

An unknown name (for example `:RenderMarkdown bogus`) gives the plugin's error `invalid command - bogus`. `:checkhealth render-markdown` shows the setup.

Big files: above 1.5 MB (or lines averaging over 5000 characters) the file gets the filetype `bigfile`: no tree-sitter, no ftplugin keys (so no `<Alt-m>`, `<Space>fm`, `^^`), and ltex_plus and typos_lsp are not attached. `:set ft=markdown` brings the full mode back (can be slow on huge files).

## Formatting with prettier

Why: marksman has no formatting. Without this key `<Space>fm` (the global format key) would do nothing in Markdown.

How: the key runs `prettier --parser markdown --stdin-filepath <file>` on the buffer text (so a project `.prettierrc` is honoured) and writes back only the changed hunks. Tested result on the example file:

```text
* item a            ->  - item a
* item b                - item b
(two blank lines)   ->  (one blank line)
| a | b |           ->  | a           | b   |
|---|---|               | ----------- | --- |
```

The code block and the `plain one` / `plain two` lines (two lines, no blank between) stayed as they were. Also `*emphasis*` becomes `_emphasis_` and a final newline is added (prettier defaults, not shown in the test).

Why not `:%!prettier --parser markdown`? It would replace the whole buffer: one giant change, all marks lost, and the cursor jumps. The key changes only the differing lines, in one undo step (tested: `u` restores everything), keeps marks and puts the cursor back on the same text. Nothing is written to disk. If you type while prettier runs, the result is discarded with a warning (`prettier: buffer changed while formatting, result discarded`): press the key again. A prettier error appears as `prettier failed: ...`.

Trailing spaces: two spaces at the end of a line are a Markdown hard line break, so they are never stripped here. The whitespace plugin excludes `markdown` (`trailing_whitespace_exclude_filetypes`), and `<Space><Space>` only warns. The other hard-break form is a trailing backslash; `<Space>mb` adds it. For rewrapping long paragraphs use `gq` after `:set textwidth=80` yourself.

## PDF export (`:ToPDF`)

Why: a Markdown note you can send to someone.

How: `plugin/command.vim` starts pandoc as a background job:

```text
pandoc --pdf-engine=xelatex --highlight-style=zenburn --table-of-content
  --include-in-header=<config>/resources/head.tex -V fontsize=10pt -V colorlinks
  ... -s "<file>.md" -o "<file>.pdf"
```

- The output is `<same name>.pdf` next to the file; an old PDF is overwritten.
- You get a table of contents, coloured links, zenburn code colours, and your LaTeX header `resources/head.tex`.
- Spaces and special characters in the file name are safe (an argument list, no shell). Tested on `my notes.md`: a valid PDF, no error.
- Save first. An unnamed buffer gives `ToPDF: save the buffer to a file first`, and unsaved edits are not in the PDF.
- The first run took more than 25 seconds. Neovim stays usable. There is no message when it finishes.
- Success is silent and on Linux no viewer opens (a viewer is started only on macOS and Windows): open the PDF yourself.
- Failure: one warning `ToPDF: pandoc failed (exit N)`. The usual reason is that xelatex is missing because Neovim was not started in the latex dev shell. To see the real LaTeX error, run the pandoc command in a terminal.

To use it: `cd` into a folder with the latex shell (direnv), run `nvim "my notes.md"`, then `:ToPDF`.

## Writing quality

### ltex_plus (grammar, LanguageTool)

Why: spell checkers do not see "their" vs "there". ltex_plus checks grammar in prose files: `markdown`, `tex`, `plaintex`, `typst`, `gitcommit`, `text`.

How: it is a Java language server that sends problems as diagnostics.

Config (`after/lsp/ltex_plus.lua`):

```lua
settings = { ltex = {
  language = "en-US",
  enabled = { "markdown", "latex", "tex", "plaintex", "typst", "gitcommit", "git-commit", "plaintext", "text" },
  ["ltex-ls"] = { logLevel = "warning" },
} },
```

- The language is fixed to `en-US`: LanguageTool checks one language per file. Italian, German or French text is flagged; change `language` in that file (`"auto"` detects the language, less reliable on short texts) or run `:lsp stop` for the buffer.
- Tested: the status line shows `Completed Checking document` and `ltex_plus` after opening a file. The first start is slow.
- Use the diagnostics: `]d` / `[d`, `<Space>dd` (message), `<Space>ca` (fixes).
- No personal dictionary or disabled-rule list is configured in the repo.
- Tested code actions on an unknown word (`Zorblat`, `<Space>ca`): `Use 'Format'`, `Use 'Combat'`, `Use 'Orbit'`, `Use 'Cobalt'`, `Use 'Oblast'`, `Add 'Zorblat' to dictionary`, `Hide false positive`, `Disable rule`, and `Create a Table of Contents` (from marksman). Choosing a replacement works: the word changes and `u` undoes it.
- `Add ... to dictionary`, `Hide false positive` and `Disable rule` do NOT work in this setup (tested). They are client-side commands (`_ltex.addToDictionary` ...) that Neovim must implement, and your config has no handler; the server answers `Unknown command '_ltex.addToDictionary', ignoring`, nothing is saved, the warning stays. To silence a word use Vim's `zg` (see below), which only affects the Vim spell checker, not ltex_plus; to silence ltex_plus for a word, add it to the `ltex.dictionary` setting in `after/lsp/ltex_plus.lua` yourself.

### Vim spell checking

| Key | What it does |
| --- | --- |
| `<Space>cz` | Toggle `spell` |
| `]s` / `[s` | Next / previous misspelled word |
| `z=` | Up to 9 suggestions |
| `zg` | Add the word to the allowed list |
| `zw` | Mark the word as wrong |

`spelllang` is `en,it,de,fr` together, so a word correct in any of them is fine. `zg` writes to the first list `spell/en.utf-8.add`; `2zg` writes to the second (`it`), `3zg` to `de`, `4zg` to `fr`. The `spell/` folder is in a public repo: do not add private words (see `spell/README.md`).

### typos_lsp

Checks common typos in every normal buffer (not help, terminal, quickfix, or start screens). Diagnostics and fixes work as for ltex_plus.

## Troubleshooting

| Problem | Cause and fix |
| --- | --- |
| No rendering, raw `#` and `**` visible | Insert mode (press `<Esc>`), file over 1.5 MB, or rendering toggled off: `:RenderMarkdown enable`. Check `:set ft?` is `markdown` |
| `<Alt-m>` says "only in markdown buffers" | The buffer is not `markdown`: `:set ft=markdown` |
| Preview does not open | Server not built or no browser: `:Lazy build markdown-preview.nvim` (needs `node` and `npm`) |
| Preview tab stays open after I left the file | Intended (`mkdp_auto_close = 0`). Stop it with `<Alt-m>` in the Markdown buffer |
| `<Space>fm` warns "prettier not found on PATH" | Start Neovim from a shell that has prettier (nix profile or dev shell) |
| `<Space>fm`: "buffer changed while formatting" | You typed during the run. Press the key again |
| `:ToPDF`: "pandoc not found" / "pandoc failed (exit N)" | Start Neovim inside the latex dev shell. Run the pandoc command in a terminal to see the error |
| `:ToPDF` does nothing visible | Normal: silent, 30 s or more the first time, no viewer on Linux. Look for the PDF next to the file |
| `@@` does not replay my macro | In Markdown it means "return from footnote". Use `@a` (register name) |
| Typing `^` or `@` has a delay | The `^^` / `@@` insert maps wait 500 ms for a second key. Accepted |
| `^^` puts the mark one letter early | At the end of a line in insert mode (see Footnotes). Use `<Space>mf` in normal mode |
| `<Space><Space>` does not remove trailing spaces | Intended in Markdown (hard line breaks) |
| Grammar warnings on Italian or German text | ltex_plus is `en-US` only |
| `^^` does nothing | The footnote plugin is not loaded: `:echo exists(':FootnoteNumber')` must give `2` (tested) |
| Maps do nothing in a huge file | Big-file mode: `:set ft=markdown` |

## Related sections

Section 16 (Code Commenting: `gc` in Markdown writes `<!-- -->`; `gcs` / `gcr` use the comment style of the fence language inside a fenced block), section 27 (short Markdown key list), section 28 (LaTeX and Typst: same latex dev shell and ltex_plus), and the sections on spelling, LSP diagnostics and big-file mode.


---
