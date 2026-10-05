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

## Footnotes (vim-markdownfootnotes)

Why: you write the sentence, press a key, write the note, jump back, without scrolling to the end and counting numbers.

How it works: vim-markdownfootnotes inserts `[^N]` in the text and a line `[^N]: ` at the end of the file, numbering them in order. Your config adds the keys `^^` and `@@` and removes the plugin's own `<Space>f` and `<Space>r` maps in Markdown, because with Space as leader they swallowed `<Space>f...` typed quickly.

The real code (`after/ftplugin/markdown.vim`, verbatim):

```vim
" Fix minor issue with footnote, see https://github.com/vim-pandoc/vim-markdownfootnotes/issues/22
" Also remove the plugin's default <Leader>f insert-mode mapping which
" hijacks Space+f when typed quickly (since leader = space).
if exists(':FootnoteNumber')
  for [s:mode, s:lhs] in [['i', '<Leader>f'], ['n', '<Leader>f'], ['i', '<Leader>r'], ['n', '<Leader>r']]
    if get(maparg(s:lhs, s:mode, 0, 1), 'buffer', 0)
      execute 'silent! ' . s:mode . 'unmap <buffer> ' . s:lhs
    endif
  endfor

  lua vim.keymap.set("n", "^^", ":<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", { buffer = true, silent = true, desc = "markdown: insert footnote" })
  lua vim.keymap.set("i", "^^", "<C-O>:<C-U>call markdownfootnotes#VimFootnotes('i')<CR>", { buffer = true, silent = true, desc = "markdown: insert footnote" })
  lua vim.keymap.set("i", "@@", "<Plug>ReturnFromFootnote", { buffer = true, silent = true, remap = true, desc = "markdown: return from footnote" })
  lua vim.keymap.set("n", "@@", "<Plug>ReturnFromFootnote", { buffer = true, silent = true, remap = true, desc = "markdown: return from footnote" })
endif
```

In plain words:

- `exists(':FootnoteNumber')`: everything here runs only when the vim-markdownfootnotes plugin is loaded.
- The loop removes the plugin's buffer-local `<Leader>f` and `<Leader>r` maps (insert and normal mode). With Space as leader they would swallow the start of `<Space>f...` and `<Space>r...` keys typed quickly. The `get(maparg(...), 'buffer', 0)` check makes it unmap only the plugin's buffer-local map, never a global one.
- `^^` (normal and insert) inserts a footnote; `@@` returns from the footnote. They are set from Lua so they get a `desc` for which-key; `remap = true` on `@@` is needed because the right side is a `<Plug>` map.

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

In plain words:

- `build = "cd app && npm install && git restore ."`: lazy.nvim runs this when the plugin is installed or updated. It installs the node dependencies of the preview server (so `npm` must be on PATH), then `git restore .` throws away the lockfile change that `npm install` makes, so the plugin's git checkout stays clean and updates do not conflict.
- `ft = { "markdown" }`: the plugin loads only for Markdown files.
- `init` runs at startup (before the plugin loads) and sets the one option, `mkdp_auto_close = 0`.
- The key `<Alt-m>` is not in this spec. It is one line in `after/ftplugin/markdown.lua` (`vim.keymap.set("n", "<A-m>", "<cmd>MarkdownPreviewToggle<cr>", { buffer = true, ... })`), buffer-local because the plugin defines `:MarkdownPreviewToggle` only for Markdown buffers.

## Rendering inside the buffer (render-markdown.nvim)

Why: you read Markdown all day; rendered headings and tables are easier on the eyes, and the raw text is one `<Esc>`-then-`i` away.

The real spec (`lua/plugin_specs.lua`, verbatim, comments included):

```lua
{
  "MeanderingProgrammer/render-markdown.nvim",
  main = "render-markdown",
  ft = { "markdown" },
  opts = {
    -- 1. Increase update delay (Default is 100ms).
    -- Waits half a second after you stop typing before recalculating graphics.
    debounce = 500,

    -- 2. Strict Mode Limits.
    -- Ensures it ONLY renders in Normal ('n') and Command ('c') mode.
    -- When you enter Insert ('i') mode to type, rendering pauses completely.
    render_modes = { "n", "c" },

    -- 3. Limit processing on huge files.
    -- Stops trying to render if a markdown file is over 1.5MB.
    max_file_size = 1.5,

    -- 4. Anti-conceal tuning.
    -- Anti-conceal hides graphical elements on the exact line your cursor is on.
    -- If the UI still feels slow when moving the cursor up/down, change enabled to `false`.
    anti_conceal = {
      enabled = true,
    },
  },
},
```

In plain words:

- `ft = { "markdown" }`: loaded only when a Markdown file is opened; `main = "render-markdown"` tells lazy.nvim which module to call `setup(opts)` on.
- Only four options are changed from the plugin defaults; everything else (heading icons, table borders, checkbox icons) is the plugin's default. The table below explains each of the four.

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

The core of the real code (`after/ftplugin/markdown.lua`, abridged: the cursor-restoring helpers `fm_cursor`, `squash` and `remap_col` above it, lines 15-90, and the two places marked `-- ...` that save and restore the cursors are left out; read the file for them):

```lua
if vim.fn.executable("prettier") == 1 then
  vim.keymap.set("n", "<Space>fm", function()
    local buf = vim.api.nvim_get_current_buf()
    local tick = vim.b[buf].changedtick
    local old = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local cmd = { "prettier", "--parser", "markdown" }
    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= "" then
      -- lets prettier find the project's .prettierrc / .prettierignore
      vim.list_extend(cmd, { "--stdin-filepath", name })
    end
    vim.system(cmd, { stdin = table.concat(old, "\n") .. "\n", text = true }, function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          vim.notify("prettier failed: " .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
          return
        end
        if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].changedtick ~= tick then
          vim.notify("prettier: buffer changed while formatting, result discarded", vim.log.levels.WARN)
          return
        end
        local new = vim.split(res.stdout:gsub("\n$", ""), "\n", { plain = true })
        local diff = (vim.text and vim.text.diff) or vim.diff
        local hunks = diff(table.concat(old, "\n") .. "\n", table.concat(new, "\n") .. "\n", { result_type = "indices" })
        -- ... (cursors of all windows are saved here)
        -- apply bottom-up so the earlier line numbers stay valid
        for i = #hunks, 1, -1 do
          local a_start, a_count, b_start, b_count = unpack(hunks[i])
          local first = a_count == 0 and a_start or a_start - 1
          vim.api.nvim_buf_set_lines(buf, first, first + a_count, false, vim.list_slice(new, b_start, b_start + b_count - 1))
        end
        -- ... (cursors of all windows are restored here)
      end)
    end)
  end, { buffer = true, desc = "Format file (prettier)" })
else
  vim.keymap.set("n", "<Space>fm", function()
    vim.notify("Markdown: prettier not found on PATH", vim.log.levels.WARN)
  end, { buffer = true, desc = "Format file (needs prettier)" })
end
```

In plain words:

- The whole map exists in two versions, chosen when the Markdown file is opened: with `prettier` on PATH it formats; without it the key shows ONE warning (`Markdown: prettier not found on PATH`) instead of falling through to plain `<Space>` + `f` + `m`.
- The buffer text goes to prettier through stdin (`vim.system` with `stdin = ...`), so the file on disk is never touched and unsaved text is formatted too. `--stdin-filepath` is added only for a named buffer; it is what lets prettier find `.prettierrc` and `.prettierignore`.
- `changedtick` is remembered before the job starts and compared when it ends: if you typed in between, the result is thrown away with a warning.
- `vim.text.diff` with `result_type = "indices"` compares old and new text and returns the changed hunks. They are applied from the bottom up so the line numbers of the hunks still to do stay valid. Only changed lines are replaced, which is why marks survive and `u` undoes it in one step.
- The `fm_cursor` helpers (not quoted) move the cursor of every window showing the buffer back to the same text, even when lines above it changed.
- The same hunk-applying idea is used for Lua in `after/ftplugin/lua.lua` (stylua), see "Lua: lua_ls and stylua" in the LSP chapter.

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

The real code (`plugin/command.vim`, verbatim):

```vim
" Convert Markdown file to PDF
command! ToPDF call s:md_to_pdf()

function! s:md_to_pdf() abort
  " check if pandoc is installed
  if executable('pandoc') != 1
    echoerr "pandoc not found"
    return
  endif

  let l:md_path = expand("%:p")
  if l:md_path ==# ''
    echohl WarningMsg | echomsg 'ToPDF: save the buffer to a file first' | echohl None
    return
  endif
  let l:pdf_path = fnamemodify(l:md_path, ":r") .. ".pdf"

  let l:header_path = stdpath('config') . '/resources/head.tex'

  " argv list: no shell, so spaces, $ and ; in paths are safe
  let l:cmd = ['pandoc', '--pdf-engine=xelatex', '--highlight-style=zenburn', '--table-of-content',
        \ '--include-in-header=' . l:header_path, '-V', 'fontsize=10pt', '-V', 'colorlinks',
        \ '-V', 'toccolor=NavyBlue', '-V', 'linkcolor=red', '-V', 'urlcolor=teal',
        \ '-V', 'filecolor=magenta', '-s', l:md_path, '-o', l:pdf_path]

  let l:id = jobstart(l:cmd, {'on_exit': function('s:md_to_pdf_done', [l:pdf_path])})

  if l:id == 0 || l:id == -1
    echoerr "Error running command"
  endif
endfunction

" open the PDF after a successful run (mac / windows only, as before)
function! s:md_to_pdf_done(pdf_path, job_id, code, event) abort
  if a:code != 0
    echohl WarningMsg | echomsg 'ToPDF: pandoc failed (exit ' . a:code . ')' | echohl None
    return
  endif
  if g:is_mac
    call jobstart(['open', a:pdf_path])
  elseif g:is_win
    call jobstart(['cmd', '/c', 'start', '', a:pdf_path])
  endif
endfunction
```

In plain words:

- `:ToPDF` is a global command (not Markdown-only), but it works on the current file whatever its type, so use it in Markdown buffers.
- It checks the two things that can be missing (pandoc, a saved file) and shows one message each.
- The command is a list passed to `jobstart`, not a shell string: no quoting problems with spaces or `$` in file names.
- The header file is found through `stdpath('config')`, i.e. `resources/head.tex` inside the Neovim config, so it works wherever the config is deployed.
- `on_exit` runs `s:md_to_pdf_done`: a non-zero exit gives the warning, a zero exit is silent except on macOS (`open`) and Windows (`start`) where the PDF is opened.

## Snippets

Source: `my_snippets/markdown.snippets` (17 snippets, UltiSnips). Type the trigger in insert mode in a Markdown buffer and expand it with `<Ctrl-j>` (section 15); `<Ctrl-j>` / `<Ctrl-k>` jump to the next / previous placeholder. The text in quotes after each trigger is its description as the completion menu shows it. Placeholders are shown in tab-stop order; after the last one the cursor leaves the block (`$0`).

Things to know first:

- `img`, `link` and `detail` have the same trigger as entries of the shared vim-snippets collection. The personal ones have priority 0 and the vim-snippets ones -50, so the versions below win.
- The blog-style snippets (`meta`, `more`, `font`, `detail`, `td`) come from a Hexo / Jekyll blog setup. They write plain text or HTML that a static-site generator understands; they do nothing special in a normal Markdown file.
- Several snippets write raw HTML (`<kbd>`, `<p>`, `<font>`, `<details>`, the message boxes). That HTML shows when the Markdown is rendered by a tool that allows HTML (a browser preview, GitHub, a blog); a plain-text reader shows the tags.

**Group: Keys**

**`k1` or `kbd`**: "HTML <kbd> tag for one key (type k1 or kbd)". This trigger is a regular expression (`(k1|kbd)`), so both words expand the same way.

```html
<kbd>KEY</kbd>
```

**`k2`**: "Two keys joined by + as <kbd> tags". **`k3`**: "Three keys joined by + as <kbd> tags".

```html
<kbd>KEY</kbd> + <kbd>KEY</kbd>
<kbd>KEY</kbd> + <kbd>KEY</kbd> + <kbd>KEY</kbd>
```

Example (`k2`): `Ctrl`, `s` gives `<kbd>Ctrl</kbd> + <kbd>s</kbd>`.

**Group: Headings and structure**

**`h1` ... `h6`**: "Heading of level 1 to 6: type h1 ... h6 at the start of a line". The trigger is the regular expression `h([1-6])`, only at the start of a line. After the expansion a small helper replaces the line with that many `#` characters and the placeholder `Section Name`; the cursor goes to the next line afterwards.

```markdown
## Section Name
```

(that is the result for `h2`; `h1` gives one `#`, `h3` three, and so on). Example: `h2`, then `Installation` gives `## Installation`.

**`detail`**: "Collapsible details block with a clickable summary (start of line; overrides the vim-snippets detail)". The summary text is red and clickable; the content is hidden until the reader clicks it.

```html
<details>
<summary><font size="2" color="red">Click to show the code.</font></summary>

content
</details>
```

**`meta`**: "YAML front matter with title, current date and time, tags and categories (start of line)". The date is filled in by the snippet (current local time with time zone) when it expands.

```yaml
---
title: "title"
date: 2026-01-31 12:00:00+0100
tags: [tag1, tag2]
categories: [category]
---
```

(the date line shows an example value). Example: `title` = `My first post`, `tags` = `vim, notes`.

**`more`**: "Blog read-more marker <!--more-->". No placeholder: inserts the marker that Hexo and Jekyll use to cut a post's excerpt.

```html
<!--more-->
```

**`td`**: "tl;dr line (start of line)". A summary line.

```markdown
tl;dr: summary
```

**Group: Links, images and text**

**`link`**: "Markdown link `[text](url)` (overrides the vim-snippets link)".

```markdown
[text](url)
```

**`rlink`**: "Markdown reference link `[text][label]`". The matching definition `[label]: url` is written by hand elsewhere in the file (see "Reference links and tables").

```markdown
[link_text][label]
```

**`img`**: "Centered image with a width in pixels, written as HTML (overrides the vim-snippets img)". The width `800` is a pixel value you can overwrite.

```html
<p align="center">
<img src="URL" width="800">
</p>
```

**`font`**: "HTML font tag with a color (obsolete in HTML5)". It works in most renderers but is no longer valid HTML.

```html
<font color="blue">TEXT</font>
```

**`yh`**: "Corner brackets for quoting (CJK style)". Inserts the Japanese / Chinese quotation marks and puts the cursor between them.

```markdown
「」
```

**Group: Message boxes**

**`info`**, **`warn`**, **`error`**, **`success`**: "Info message box (embeds its own style block; needs network for the Font Awesome 4.2.0 icons from a remote CDN)" (the same words for the other three with their own name). Each snippet writes a `<style>` block with the colours of the box, followed by a `<div>` with an icon, a label and your text. Two honest limits:

- Every one of the four embeds its own copy of the style block, so a page with all four has four `<style>` blocks. They are not shared.
- The style block imports Font Awesome 4.2.0 from a remote address (`maxcdn.bootstrapcdn.com`). The icon only shows when the reader is online and that address still answers; if it does not load, the box still shows its colours and text, but without the icon. Not verified here.

The `info` expansion in full:

```html
<style type="text/css">
@import url('//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css');

.info-msg {
	color: #059;
	background-color: #BEF;
	margin: 5px 0;
	margin-bottom: 20px;
	padding: 10px;
	border-radius: 5px 5px 5px 5px;
	border: 2px solid transparent;
	border-color: transparent;
}
</style>

<div class="info-msg">
	<i class="fa fa-info-circle"> Info</i><br>
	info text
</div>
```

The other three have the same layout and differ only in these values:

| Trigger | CSS class | Text colour | Background | Icon class and label | Placeholder |
| --- | --- | --- | --- | --- | --- |
| `info` | `info-msg` | `#059` | `#BEF` | `fa-info-circle`, Info | `info text` |
| `warn` | `warning-msg` | `#9F6000` | `#FEEFB3` | `fa-warning`, Warning | `warning text` |
| `error` | `error-msg` | `#D8000C` | `#FFBABA` | `fa-times-circle`, Error | `error text` |
| `success` | `success-msg` | `#270` | `#DFF2BF` | `fa-check`, Success | `success text` |

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

Section 15 and 52 (snippets), section 16 (Code commenting: `gc` in Markdown writes `<!-- -->`; `gcs` / `gcr` use the comment style of the fence language inside a fenced block), section 27 (short Markdown key list), section 28 (LaTeX and Typst: same latex dev shell and ltex_plus), and the sections on spelling, LSP diagnostics and big-file mode.


---
