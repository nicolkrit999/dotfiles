<!-- chapter: Markdown -->
[Back to the guide index](../README.md)

# 81. Markdown (writing, preview, footnotes, PDF)

This section covers everything your config does that is specific to `.md` files: what each tool is for, how it works, the exact keys, and what to do when it fails. Global things (diagnostics keys, code actions, the spell keys, `gc` comments) are only mentioned briefly with a pointer. Section [27](../09-ai-and-writing.md#27-markdown-support) is the short key list; this one is the full story.

## The tools and why they exist

| Tool | Why it is in your setup | What it gives you |
| --- | --- | --- |
| marksman (LSP) | Markdown has links and headings that point to each other | Link and heading completion, jump to a heading, symbols. Only for plain `markdown` files |
| ltex_plus (LSP, LanguageTool) | Prose needs grammar checking, not only spelling | Grammar and spelling problems as diagnostics. Language detected automatically per file (`auto`, so Italian or German notes are not flagged as English) |
| typos_lsp | Catches common typos in every file type | Diagnostics like `recieve` to `receive` |
| render-markdown.nvim | Raw Markdown is hard to read | Headings, lists, code blocks, tables, checkboxes drawn nicely inside the buffer |
| mdkite.nvim (with kitehost.nvim) | See the final look in a browser | Live preview with Mermaid diagrams and math, `<Alt-m>` toggles it |
| vim-markdownfootnotes | Footnotes need numbering and a jump back | `^^` / `<Space>mf` create a footnote, `@@` / `<Space>mr` return |
| truth-table.nvim | Digital-logic notes need truth tables and Boolean algebra by hand otherwise | `:TruthTable` builds tables, Karnaugh maps and step-by-step rewrites inside the note; `and@` types `∧` (see [Truth tables and Boolean algebra](#truth-tables-and-boolean-algebra-truth-tablenvim)) |
| `:AddRef` (your own command) | Reference-style links keep the text readable | Adds `[label]: url` at the end of the file |
| prettier (via conform.nvim: `:w` and `<Space>fm`) | marksman cannot format | Tidies lists, tables, spacing |
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

In a Markdown buffer: `wrap` is on (the global default is off), `textwidth` is 0, `colorcolumn` is 100, `synmaxcol` is 3000, `conceallevel` is 3. `concealcursor` shows as empty: render-markdown.nvim sets its own conceal options on the window after the ftplugin, so the `concealcursor=c` line in the file has no visible effect. Facts that follow from this:

- Long lines wrap at word boundaries (`linebreak` is on globally). Neovim never hard-wraps while you type (no `textwidth`), and prettier keeps your line breaks.
- Syntax colours stop after column 3000 of a very long line.

## Quick start

1. Open a file, for example `nvim "my notes.md"`. In normal mode headings, lists, code blocks and tables are drawn nicely. While you type in insert mode the drawing pauses (`render_modes`), and returns after about half a second in normal mode.
2. Press `<Alt-m>`. The browser opens with a live preview (it needs an internet connection, see [Preview](#preview-mdkitenvim)). Press `<Alt-m>` again to stop it.
3. Press `<Space>fm`. Prettier tidies the file as one undo step (`u` undoes it). The file is not saved to disk. Saving with `:w` formats the same way.
4. Footnote: put the cursor on the last letter of a sentence, press `<Space>mf`. A `[^1]` appears and the cursor jumps to the new `[^1]: ` line at the end of the file (in normal mode: press `A` to type the note). Press `@@` to jump back.
5. PDF: save (`:w`) and run `:ToPDF` from a Neovim that was started inside the latex dev shell. Wait 30 seconds or more the first time. `my notes.pdf` appears next to the file.

## Requirements

| Tool | Where it comes from | Needed for |
| --- | --- | --- |
| marksman, prettier, ltex-ls-plus, typos-lsp | Global nix profile (`~/nix/users/krit/common/programs/cli-programs/neovim.nix`) | LSP features, formatting (`:w`, `<Space>fm`), grammar, typos |
| A web browser and an internet connection | Your system default browser. The preview page loads its Mermaid, KaTeX, markdown-it and highlight.js libraries from CDNs. The preview server itself is Lua inside Neovim: no node, no npm, no build step | `<Alt-m>` |
| pandoc, xelatex | Only in the latex dev shell (`~/nix/templates/krit/dev-environments/language-specific/latex/flake.nix`: `pandoc` and `texlive.combined.scheme-full`) | `:ToPDF` |

Inside the latex dev shell `prettier`, `pandoc`, `xelatex` and `marksman` are all found by Neovim, and the attached LSP clients on a `.md` file are `ltex_plus`, `marksman`, `typos_lsp`. Note that `pandoc` is also found on this system outside the dev shell (it is on the system PATH), but `xelatex` and `prettier` are not found by a plain shell: Neovim must be started from a shell where they are on PATH (the dev shell, or the nix profile that provides them).

If a tool is missing, nothing falls back to a plain Vim key:

- No prettier: formatting is skipped silently (neither `:w` nor `<Space>fm` shows a message) and the file stays as it is.
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
| `<Alt-m>` | n | Toggle the browser preview (`:MdKite toggle`). In another file type: one warning `Markdown preview: only in markdown buffers` |
| `<Space>mf` | n | Add a footnote after the character under the cursor (see [Footnotes](#footnotes-vim-markdownfootnotes)). Elsewhere: one warning |
| `<Space>mr` | n | Return from the footnote to the text. Elsewhere: one warning |
| `^^` | n, i | Add a footnote before the character under the cursor (see the off-by-one note below) |
| `@@` | n, i | Return from the footnote (replaces the macro replay `@@` in Markdown) |
| `<Space>fm` | n, x | Format the file (Visual mode: the selection) with prettier |
| `<Space>mb` + motion | n | Add a trailing `\` (hard line break) to the lines of the motion, e.g. `<Space>mbip` |
| `<Space>mb` | x | Same on a Visual selection |
| `+` + motion | n | Put `+ ` in front of the lines of the motion: `+ip` |
| `+` | x | Same on a Visual selection |
| `ic`, `ac` | o, x | Fenced code block, without or with the fence lines: `vic`, `dic`, `yac`, `cic` |
| `]]` / `[[` | n, x | Next / previous heading (levels 1 to 5) |
| `gO` | n | Outline: opens a location list window with one line per heading, indented by level (`Heading One`, `  Heading Two`, `    Heading Three`). `<CR>` jumps to the heading, `:lclose` closes it |
| `<Space>t` | n | Aerial symbol outline panel; `]t` / `[t` next / previous symbol |
| `<Space>cz` | n | Toggle spell checking (global key, see [Writing quality](#writing-quality)) |
| `<Space><Space>` | n | Trailing-space remover, but in Markdown it only warns `markdown: trailing spaces are hard line breaks, not stripped` |
| `:AddRef <label> <url>` | cmd | Add a reference link at the end of the file |
| `:Tabularize /\|` | cmd | Align table columns |
| `:ToPDF` | cmd | Export a PDF |
| `:RenderMarkdown toggle` | cmd | Turn the rendering off / on |

Global keys that also work here: `<Space>ca` (code action, for example a ltex_plus fix), `<Space>dd`, `]d`, `[d` (diagnostics), `<Space>rn` renames through marksman (headings and links; marksman advertises rename).

Accepted effects of the footnote maps:

- A single `^` or `@` typed in insert mode appears after 500 ms, because Neovim waits for a possible second key. `^` followed by any other key comes out at once.
- In normal mode `@@` is not "repeat last macro" in Markdown (it is `<Plug>ReturnFromFootnote`). Use `@a` with the register name instead.

## Text objects and operators

These live in `after/ftplugin/markdown.vim`. On the example file:

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

Flow (normal mode):

1. Cursor on the last letter of `Some text here.` (`$` puts it on the period).
2. `<Space>mf`. The line becomes `Some text here.[^1]` (the mark is inserted after the character under the cursor) and the cursor sits on the new last line `[^1]: ` in normal mode.
3. Press `A`, type `My note`, press `<Esc>`.
4. Press `@@` (or `<Space>mr`). The cursor is back at the `[^1]` in the sentence.

Flow (insert mode, the `^^` variant):

```text
Mid word done.   (cursor before "word", in insert mode, type ^^)
```

The result is `Mid [^1]word done.` and you are still in insert mode on the note line: type the note, then `<Esc>`, then `@@` to go back. A second footnote becomes `[^2]` and its note is added under `[^1]: ...`.

The off-by-one at the end of a line: in insert mode with the cursor at the very end of a line, `^^` puts the mark one character too early (`Neovim is fas[^1]t`). The reason is that the `<C-O>` command inside the map first moves the cursor onto the last character, and `^^` inserts before that character. Typing `^^` in the middle of a line is exact. At the end of a line, end the sentence in normal mode instead: `<Esc>`, `<Space>mf` (inserts after the last character). In normal mode `^^` inserts before the character under the cursor, `<Space>mf` after it.

## Reference links and tables

```text
:AddRef docs https://neovim.io/doc
```

Result at the end of the buffer (a blank line, a comment line once, then the definition):

```markdown
<!-- Reference links -->
[docs]: https://neovim.io/doc
```

A second `:AddRef two https://a.b` adds only `[two]: https://a.b` under it (the comment line is not repeated). In the text you write `[the docs][docs]`. The first argument completes from labels already used as `[text][label]` in the file. Label and URL cannot contain spaces; there is no title argument.

Tables: select the table lines and run `:'<,'>Tabularize /|`:

```markdown
| a           | b   |
| ---         | --- |
| longer cell | x   |
```

Tabularize pads the separator row with spaces. `<Space>fm` is the better table aligner: prettier makes the separator row `| ----------- | --- |`.

Checkboxes (`- [ ]`): render-markdown draws them; no key toggles them.

## Preview (mdkite.nvim)

Why: render-markdown shows structure in the editor, the browser preview shows the final look (fonts, images, math, diagrams).

How: mdkite.nvim starts a small web server written in Lua inside Neovim (its dependency kitehost.nvim is the HTTP server) and opens your default browser. The page follows the text and the cursor while you edit (instant updates, scroll sync).

Config (from `lua/plugin_specs.lua`):

```lua
{
  "selimacerbas/mdkite.nvim",
  ft = { "markdown" },
  cmd = { "MdKite" },
  dependencies = { { "selimacerbas/kitehost.nvim", lazy = true } },
  opts = {},
},
```

| Command | What it does |
| --- | --- |
| `:MdKite` or `:MdKite start` | Start the preview of the current buffer and open the browser |
| `:MdKite stop` | Stop it |
| `:MdKite refresh` | Force a refresh of the page |
| `:MdKite toggle` | Start the preview, or stop the one that is running (what `<Alt-m>` runs) |

What the page shows: headings, tables and code with syntax colours, relative images next to the file, Mermaid diagrams (fenced ` ```mermaid `), KaTeX math (`$E = mc^2$` inline, `$$ ... $$` display), and a light/dark switch in the page header.

- `opts = {}` means the plugin defaults: one preview at a time ("takeover" mode) on port 8421, the browser opens when the preview starts, dark theme.
- The commands exist after the first Markdown buffer is opened, or when you type `:MdKite` (the plugin loads on that command).
- Switching to another buffer does not stop the preview and does not close the browser tab. It stays bound to the buffer it was started in. It ends with `:MdKite stop`, with `<Alt-m>` in a Markdown buffer, or when you quit Neovim.
- `:MdKite toggle` is global (there is only one server). If a preview of buffer A is running and you press `<Alt-m>` in a second Markdown buffer B, that STOPS the preview. To move the preview to B, run `:MdKite start` in B.
- Outside Markdown buffers `<Alt-m>` shows one warning (the real map is buffer-local in `after/ftplugin/markdown.lua`: `vim.keymap.set("n", "<A-m>", "<cmd>MdKite toggle<cr>", { buffer = true, ... })`). The plugin sets no keys of its own.
- The preview page loads Mermaid, KaTeX, markdown-it and highlight.js from CDNs, so it needs internet. Raw HTML written in the previewed file runs in the page, so do not preview a file you do not trust.
- No build step: after a fresh install there is nothing to compile. Node stays installed for other reasons (`:run` on `.js`/`.ts` files), the preview does not use it.

In plain words:

- `ft = { "markdown" }` and `cmd = { "MdKite" }`: the plugin loads for Markdown files or on its command.
- `dependencies`: kitehost.nvim is the server library. It is marked `lazy = true` so it does not start with Neovim (without that, lazy.nvim would load it at startup).

## Truth tables and Boolean algebra (truth-table.nvim)

Why: notes on digital logic (computer architecture) are full of truth tables, simplifications such as De Morgan, and Karnaugh maps. truth-table.nvim builds and checks them inside the Markdown note, so you do not draw or verify them by hand.

How: it is loaded shortly after Neovim starts (lazy.nvim `VeryLazy`); its one dependency, cds-lua-fp, comes with it. The tables are GitHub-style pipe tables, so this is for Markdown. The symbols are plain Unicode text, so they can also be pasted into Typst; in LaTeX they need xelatex or lualatex with a font that has them.

Config (from `lua/plugin_specs.lua`, shortened):

```lua
{
  "cds-io/truth-table.nvim",
  main = "truth-table",
  event = "VeryLazy",
  opts = { abbreviations = false },
  config = function(_, opts)
    require("truth-table").setup(opts)
    -- re-creates the plugin's word@ abbreviations as :iabbrev <buffer>
    -- for the filetypes markdown, tex, plaintex and typst
  end,
},
```

### The expression language

Used inside the commands below. Words and symbols both work:

| You type | Meaning | Written in the table |
| --- | --- | --- |
| `not X`, `!X`, `¬X` | negation | `¬` |
| `A and B`, `∧` | and | `∧` |
| `A or B`, `∨` | or | `∨` |
| `A xor B`, `⊕` | exclusive or | `⊕` |
| `A implies B`, `->`, `=>`, `→` | implication | `→` |
| `A iff B`, `=`, `<->`, `⇔` | equivalence | `⇔` |
| `0`, `1`, `true`, `false`, `⊤`, `⊥` | constants | |

There are NO `nand` or `nor` operators (`:TruthTableExpand A nand B` gives a parse error). Write `not (A and B)` and `not (A or B)`. Binary operators group from the left, so use parentheses for `A -> (B -> C)`. A table with N variables has 2^N rows: keep the expressions small.

### Commands

| Command | What it does |
| --- | --- |
| `:TruthTable A B` | Insert a table ABOVE the current line with the variables `A` and `B` (`:TruthTable 3` gives `A B C`) |
| `:TruthTable A and B \| A implies B` | Insert a table from expressions (separated by `\|` or a comma): the variables they use plus one computed column per expression |
| `:.TruthTable` (or a Visual range, `:'<,'>TruthTable`) | Turn the expression on the line (or the selected lines, one expression each) into a table |
| `:TruthTableExpand A xor B, A and B` | With the cursor in a table, append one computed column per comma-separated expression |
| `:TruthTableKarnaugh` | With the cursor in a column of a table, insert a Karnaugh map (2 to 4 inputs) and a minimal sum-of-products formula for that column below the table |
| `:TruthTableDeMorgan` | Preview a De Morgan rewrite of the expression at the cursor (run again to dismiss) |
| `:TruthTableSimplify` | Preview one simplification (complement, identity, domination, idempotence, absorption, reduction, consensus) and name the law |
| `:TruthTableFactor`, `:TruthTableDistribute`, `:TruthTableCommute`, `:TruthTableXor`, `:TruthTableUnfold`, `:TruthTableDNF`, `:TruthTableCNF` | Other rewrite previews (factor, distribute, swap operands, recognise exclusive or, unfold `→ ⊕ ⇔` into and/or/not, disjunctive and conjunctive normal form) |
| `:TruthTableRewrites` | List every rewrite of the expression and write the one you pick as the next step |
| `:TruthTableApply` | Replace the expression by the pending preview |
| `:TruthTableApplyStep` | Keep the line and add the pending preview below it as a derivation step: `≡ expression  \| by <law>` |
| `:TruthTableVerify` | Check that every `≡` step of the derivation under the cursor is a real equivalence |
| `:TruthTableVerify!` | Same, and insert a proof table (one column per step; identical columns mean equivalent) |
| `:TruthTableEquiv a ∧ b \| b ∧ a` | Are these expressions equivalent? (`!` inserts the proof table) |
| `:TruthTableToggle`, `:TruthTableDropRow`, `:TruthTableDropColumn` | Switch cells between `0/1` and `F/T`, drop the row or column under the cursor |
| `:TruthTableTutor` | Open the built-in course (see below) |
| `:TruthTableTutorNext` / `:TruthTableTutorPrev` | Next / previous tutor step |

While a rewrite preview is shown, two transient keys exist in that buffer: `<Space>` applies it in place and `<CR>` writes it as a `≡` step. They disappear when the preview is applied, dismissed, or the buffer is edited.

### Keys

All in normal mode, global, and each key only does something when its context holds (cursor in a table, on an expression, in a derivation, or with a preview pending); otherwise the command says what is missing. which-key shows the keys that are valid at the cursor under the groups `Truth table` and `Logic rewrite` (the per-key description is deliberately hidden). The prefixes are fixed by the plugin.

| Keymap | Context | Same as |
| --- | --- | --- |
| `<Space>Tn` | anywhere (also Visual) | `:TruthTable` on the current line or the selected lines; on an empty line it types `:TruthTable ` for you |
| `<Space>Te` | in a table | types `:TruthTableExpand ` for you |
| `<Space>Tt` | in a table | `:TruthTableToggle` |
| `<Space>Tr` / `<Space>Tc` | in a table | drop row / drop column (`.` repeats) |
| `<Space>Tk` | in a table | `:TruthTableKarnaugh` |
| `<Space>T=` | in a table | switch the `≡` / `≢` marks under equivalent columns on or off |
| `<Space>ld` | on an expression | `:TruthTableDeMorgan` |
| `<Space>lf` / `<Space>lx` | on an expression | factor / distribute |
| `<Space>ls` / `<Space>lS` | on an expression | swap with the next / previous operand |
| `<Space>lo` | on an expression | recognise exclusive or |
| `<Space>lu` | on an expression | unfold `→`, `⊕`, `⇔` |
| `<Space>lm` / `<Space>lM` | on an expression | disjunctive / conjunctive normal form |
| `<Space>lz` | on an expression | `:TruthTableSimplify` |
| `<Space>ll` | on an expression | `:TruthTableRewrites` |
| `<Space>lv` / `<Space>lV` | in a derivation | `:TruthTableVerify` / `:TruthTableVerify!` |
| `<Space>la` / `<Space>lA` | preview pending | `:TruthTableApply` / `:TruthTableApplyStep` |

There was no `<Space>T…` or `<Space>l…` key before, so nothing in the global keys clashes. Inside a Jupyter notebook buffer `<Space>ls` is the notebook's LSP signature help instead (see [Jupyter notebooks](python.md#jupyter-notebooks-nvjup)).

### Typing the symbols

In insert mode, in Markdown, LaTeX, plain TeX and Typst buffers only, a word followed by `@` and then a space (or any character that is not a letter) turns into the symbol:

| Type | Result | Type | Result |
| --- | --- | --- | --- |
| `and@` | `∧` | `or@` | `∨` |
| `not@` | `¬` | `xor@` | `⊕` |
| `implies@` | `→` | `iff@` | `⇔` |
| `forall@` | `∀` | `exists@` | `∃` |
| `true@` | `⊤` | `false@` | `⊥` |
| `equiv@` | `≡` | `nequiv@` | `≢` |

`p and@ q` followed by a space gives `p ∧ q`. The plain word `and` never changes, and `not@a` (a letter right after the `@`) does not expand. The plugin's own version of these abbreviations is global in every buffer; this config switches that off (`abbreviations = false`) and defines them per buffer for the four note filetypes.

### Worked lesson: a half adder and a proof

Open a Markdown note and put the cursor on an empty line.

| # | What you press or type | What happens |
| --- | --- | --- |
| 1 | `:TruthTable A B` then `<Enter>`, move the cursor into the table (`k`), then `:TruthTableExpand A xor B, A and B` | A table with the four input rows appears above the cursor line. The expand adds the columns `A ⊕ B` (the sum) and `A ∧ B` (the carry): that is a half adder |
| 2 | In insert mode type `p and@ q` and a space | The text becomes `p ∧ q` |
| 3 | On its own line type `not (A and B) or A` in insert mode, `<Esc>`, then `:TruthTableDeMorgan` | A preview appears at the end of the line: `⇒ ¬A ∨ ¬B ∨ A \| by De Morgan`. Run `:TruthTableApplyStep` (or press `<CR>` while the preview shows): the line `≡ ¬A ∨ ¬B ∨ A \| by De Morgan` is added below and the cursor moves onto it |
| 4 | `:TruthTableSimplify`, then `:TruthTableApplyStep`. Repeat the pair once more | The first step is `≡ 1 ∨ ¬B \| by complement` (`A ∨ ¬A` is always true), the second `≡ 1 \| by domination`. The whole expression is always true |
| 5 | `:TruthTableVerify!` with the cursor in the derivation | The message `every step holds (3 steps)` and a proof table below it: one column per line of the derivation, all four rows identical |
| 6 | Make a 4-variable table from one expression: on a line with `(A and B) or (A and not C) or (not A and C and D) or (B and C and D)` run `:.TruthTable` (the line becomes a table), put the cursor on a row of the last column, then `:TruthTableKarnaugh` | A Karnaugh map (rows `AB`, columns `CD` in Gray order) appears below the table, followed by the line `<expression> ≡ (¬A ∧ C ∧ D) ∨ (A ∧ B) ∨ (A ∧ ¬C)`: the minimal formula |
| 7 | `:TruthTableTutor` | The built-in course opens in a new tab: lesson on the left, an exercise pane on the right. `:TruthTableTutorNext` (or `]]` inside it) goes on; `:TruthTableTutor!` starts over |

The tutor keeps your place in `~/.local/state/nvim/truth-table/tutor.json` (under `stdpath("state")`), so `:TruthTableTutor` in a new Neovim opens where you stopped. The lesson pane shows plain Markdown (the optional vellum.nvim is not installed).

### Limits and open points

- prettier (conform) runs on every `:w` and reformats the generated tables: the separator row `|:---:|` becomes `| :-: |` (still centred and valid) and the `\| by` marks of a derivation lose their alignment padding. Cosmetic only.
- `:ToPDF` (pandoc and xelatex) with the default font prints `∧` and `∨` as blank (missing glyphs). Adding `-V mainfont='DejaVu Serif'` to the pandoc command fixes it, but `:ToPDF` has not been changed, so tables with those symbols show blanks in the PDF for now.
- The plugin is young and written with a coding agent. It makes no network calls and runs no shell commands; it writes only the tutor progress file above.

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

Commands (all run without error; the global state changed `true`, `false`, `true` with two `toggle` calls):

| Command | Effect |
| --- | --- |
| `:RenderMarkdown toggle` | Rendering off / on in all buffers |
| `:RenderMarkdown buf_toggle` | Same, this buffer only |
| `:RenderMarkdown enable` / `disable` | Explicit on / off |
| `:RenderMarkdown buf_enable` / `buf_disable` | Explicit on / off, this buffer only |

An unknown name (for example `:RenderMarkdown bogus`) gives the plugin's error `invalid command - bogus`. `:checkhealth render-markdown` shows the setup.

Big files: above 1.5 MB (or lines averaging over 5000 characters) the file gets the filetype `bigfile`: no tree-sitter, no ftplugin keys (so no `<Alt-m>`, `^^`), and ltex_plus and typos_lsp are not attached. `:set ft=markdown` brings the full mode back (can be slow on huge files).

## Formatting with prettier

Why: marksman has no formatting. Markdown is formatted by prettier, run by conform.nvim (see [Formatting (conform.nvim)](../07-code.md#formatting-conformnvim)): when you save with `:w`, and on demand with `<Space>fm`.

How: prettier gets the buffer text (so a project `.prettierrc` is honoured), and only the changed lines are written back. Result on an example file:

```text
* item a            ->  - item a
* item b                - item b
(two blank lines)   ->  (one blank line)
| a | b |           ->  | a           | b   |
|---|---|               | ----------- | --- |
```

The code block and the `plain one` / `plain two` lines (two lines, no blank between) stay as they are. Also `*emphasis*` becomes `_emphasis_` and a final newline is added (prettier defaults).

- `<Space>fm` changes the buffer as one undo step (`u` restores everything), keeps marks, and does not write the file. In Visual mode only the selection is formatted.
- Saving with `:w` formats first and then writes. Auto-saves (leaving the buffer, Neovim losing focus) never format.
- `<Space>fo` turns format on save off and on again; `:FormatDisable!` + Enter does it for the current buffer only.
- Without prettier on PATH nothing happens and no message appears. Start Neovim from a shell that has prettier (nix profile or dev shell). `:ConformInfo` shows whether prettier is found.

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
- Spaces and special characters in the file name are safe (an argument list, no shell). On `my notes.md`: a valid PDF, no error.
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

Source: `my_snippets/markdown.snippets` (208 snippets, UltiSnips). Type the trigger in insert mode in a Markdown buffer and expand it with `<Ctrl-j>` (section [15](../04-completion-snippets.md#15-snippets-ultisnips)); `<Ctrl-j>` / `<Ctrl-k>` jump to the next / previous placeholder. The text in quotes after each trigger is its description as the completion menu shows it. Placeholders are shown in tab-stop order; after the last one the cursor leaves the block (`$0`).

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

**`rlink`**: "Markdown reference link `[text][label]`". The matching definition `[label]: url` is written by hand elsewhere in the file (see ["Reference links and tables"](#reference-links-and-tables)).

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
- The style block imports Font Awesome 4.2.0 from a remote address (`maxcdn.bootstrapcdn.com`). The icon only shows when the reader is online and that address still answers; if it does not load, the box still shows its colours and text, but without the icon.

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

### Math symbols

Inside math, a symbol is one typed word: you type its name instead of remembering the LaTeX command. The math snippets use LaTeX syntax, which is what Markdown math (`$...$` and `$$...$$`) renders. This part of the file has 191 snippets: 2 math delimiters and 189 symbols.

How to use them, step by step:

1. Type `mk` for inline math or `dm` for a display math block, then press `<Ctrl-j>` (hold the Ctrl key and press j). `mk` writes `$` `$` on the line and puts the cursor between them; `dm` writes `$$`, an empty line and `$$` on three lines, then one more empty line below them, and puts the cursor on the empty middle line (the last empty line is where the cursor goes after the final `<Ctrl-j>`). Typing the `$` characters yourself works too.
2. Inside the math, type a symbol name such as `leq` and press `<Ctrl-j>` (or accept the name in the completion menu). The name is replaced by the symbol and the cursor ends right after it. The symbol snippets expand only while the cursor is inside math: outside math `<Ctrl-j>` does not expand them and only does what it does without a snippet (it starts a new line); the completion menu may still list the names.
3. A snippet with placeholders (for example `frac`) selects the first placeholder; type over it, then press `<Ctrl-j>` to go to the next one. After the last placeholder, `<Ctrl-j>` moves the cursor to the end of the symbol, still inside the math. One more `<Ctrl-j>` then moves it past the closing `$` (for `dm`: onto the line below the closing `$$`). When the math contains only plain symbols (no placeholders), the first `<Ctrl-j>` after you finish typing already leaves the closing delimiter.

After the expansion the cursor is always after the symbol. Word-like commands (`\leq`, `\alpha`, `\infty`, `\cdot`, ...) get one trailing space so the next letter you type does not stick to the command; the space is not shown in the tables. `sub`, `sup`, `inv`, `transpose`, `degree` and `celsius` attach to what you typed before, so they add no space and also work in the middle of a word (`xsub` gives `x_{i}`). In the Produces column the words in a placeholder show the text you can type over (for example `\frac{a}{b}`).

Worked example: inline math `x \leq y`.

| You type | You get (`<cursor>` marks the cursor) |
| --- | --- |
| `mk`, then `<Ctrl-j>` | `$<cursor>$` |
| `x` | `$x<cursor>$` |
| a space, then `leq`, then `<Ctrl-j>` | `$x \leq <cursor>$` |
| `y` | `$x \leq y<cursor>$` |
| `<Ctrl-j>` | `$x \leq y$<cursor>` (the cursor is after the closing `$`) |

Where they work: the math symbols and the delimiters follow the Markdown structure of the file. These count as math: text between a pair of `$`, text after an opening `$` that is not closed yet on that line, and everything between `$$` and `$$` (also over several lines, also when the closing `$$` is not typed yet). These do not count as math: fenced code blocks (backticks or `~~~`), the YAML block at the top of the file, inline code between backticks, a `\$` with a backslash, and a lone dollar sign in prose such as `it costs $5` or `pay $ now`. `mk` and `dm` expand anywhere except in those code places. Limits: inline math that is split over several lines is not recognised; an indented code block (four spaces) is not recognised as code, so a `$` there still starts math; a `$` in front of a word without backticks (for example `$HOME`) is read as the start of math until the end of the line; a `$` followed directly by a digit is read as a price, so math that starts with a digit right after the `$` (for example `$30degree`) is not recognised until other text follows; an unclosed `$$` makes everything below it count as math.

#### Math delimiters

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `mk` | `$` `$` | Inline math, cursor between the dollar signs |
| `dm` | `$$`, empty line, `$$`, empty line | Display math on its own lines, cursor on the empty line |

#### Relations and operators

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `neq` | `\neq` | Not equal |
| `leq` | `\leq` | Less or equal |
| `geq` | `\geq` | Greater or equal |
| `ll` | `\ll` | Much less |
| `gg` | `\gg` | Much greater |
| `approx` | `\approx` | Approximately equal |
| `equiv` | `\equiv` | Identical / congruent |
| `sim` | `\sim` | Similar / distributed as |
| `simeq` | `\simeq` | Asymptotically equal |
| `cong` | `\cong` | Congruent |
| `propto` | `\propto` | Proportional to |
| `pm` | `\pm` | Plus minus |
| `mp` | `\mp` | Minus plus |
| `times` | `\times` | Multiplication cross |
| `cdot` | `\cdot` | Dot product / multiplication dot |
| `circ` | `\circ` | Composition |
| `ast` | `\ast` | Asterisk operator |
| `oplus` | `\oplus` | Direct sum |
| `otimes` | `\otimes` | Tensor product |
| `perp` | `\perp` | Perpendicular |
| `parallel` | `\parallel` | Parallel |
| `angle` | `\angle` | Angle |
| `degree` | `^\circ` | Degree sign |
| `celsius` | `^\circ\mathrm{C}` | Degrees Celsius |
| `infinity` | `\infty` | Infinity |
| `partial` | `\partial` | Partial derivative symbol |
| `nabla` | `\nabla` | Nabla |
| `therefore` | `\therefore` | Therefore |
| `because` | `\because` | Because |
| `ldots` | `\ldots` | Dots on the line |
| `cdots` | `\cdots` | Centered dots |
| `vdots` | `\vdots` | Vertical dots |
| `ddots` | `\ddots` | Diagonal dots |

#### Logic and sets

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `implies` | `\implies` | Implies |
| `iff` | `\iff` | If and only if |
| `to` | `\to` | Arrow right / maps to |
| `mapsto` | `\mapsto` | Maps to |
| `leftarrow` | `\leftarrow` | Arrow left |
| `forall` | `\forall` | For all |
| `exists` | `\exists` | Exists |
| `nexists` | `\nexists` | Does not exist |
| `neg` | `\neg` | Not |
| `land` | `\land` | And |
| `lor` | `\lor` | Or |
| `in` | `\in` | Element of |
| `notin` | `\notin` | Not element of |
| `subset` | `\subset` | Subset |
| `subseteq` | `\subseteq` | Subset or equal |
| `supset` | `\supset` | Superset |
| `cup` | `\cup` | Union |
| `cap` | `\cap` | Intersection |
| `setminus` | `\setminus` | Set difference |
| `emptyset` | `\emptyset` | Empty set |
| `NN` | `\mathbb{N}` | Natural numbers |
| `ZZ` | `\mathbb{Z}` | Integers |
| `QQ` | `\mathbb{Q}` | Rationals |
| `RR` | `\mathbb{R}` | Reals |
| `CC` | `\mathbb{C}` | Complex numbers |

#### Greek letters

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `alpha` | `\alpha` | Greek letter alpha |
| `beta` | `\beta` | Greek letter beta |
| `gamma` | `\gamma` | Greek letter gamma |
| `delta` | `\delta` | Greek letter delta |
| `epsilon` | `\epsilon` | Greek letter epsilon |
| `varepsilon` | `\varepsilon` | Greek letter varepsilon |
| `zeta` | `\zeta` | Greek letter zeta |
| `eta` | `\eta` | Greek letter eta |
| `theta` | `\theta` | Greek letter theta |
| `vartheta` | `\vartheta` | Greek letter vartheta |
| `iota` | `\iota` | Greek letter iota |
| `kappa` | `\kappa` | Greek letter kappa |
| `lambda` | `\lambda` | Greek letter lambda |
| `mu` | `\mu` | Greek letter mu |
| `nu` | `\nu` | Greek letter nu |
| `xi` | `\xi` | Greek letter xi |
| `pi` | `\pi` | Greek letter pi |
| `rho` | `\rho` | Greek letter rho |
| `sigma` | `\sigma` | Greek letter sigma |
| `tau` | `\tau` | Greek letter tau |
| `phi` | `\phi` | Greek letter phi |
| `varphi` | `\varphi` | Greek letter varphi |
| `chi` | `\chi` | Greek letter chi |
| `psi` | `\psi` | Greek letter psi |
| `omega` | `\omega` | Greek letter omega |
| `Gamma` | `\Gamma` | Greek letter Gamma |
| `Delta` | `\Delta` | Greek letter Delta |
| `Theta` | `\Theta` | Greek letter Theta |
| `Lambda` | `\Lambda` | Greek letter Lambda |
| `Xi` | `\Xi` | Greek letter Xi |
| `Pi` | `\Pi` | Greek letter Pi |
| `Sigma` | `\Sigma` | Greek letter Sigma |
| `Phi` | `\Phi` | Greek letter Phi |
| `Psi` | `\Psi` | Greek letter Psi |
| `Omega` | `\Omega` | Greek letter Omega |

#### Functions, fractions, roots, scripts

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `frac` | `\frac{a}{b}` | Fraction |
| `sqrt` | `\sqrt{x}` | Square root |
| `nroot` | `\sqrt[n]{x}` | N-th root |
| `absval` | `\left\lvert x \right\rvert` | Absolute value |
| `norm` | `\left\lVert x \right\rVert` | Norm |
| `floor` | `\lfloor x \rfloor` | Floor |
| `ceil` | `\lceil x \rceil` | Ceiling |
| `sub` | `_{i}` | Subscript |
| `sup` | `^{n}` | Superscript |
| `inv` | `^{-1}` | Inverse |
| `transpose` | `^\top` | Transpose |
| `sin` | `\sin` | Sin function |
| `cos` | `\cos` | Cos function |
| `tan` | `\tan` | Tan function |
| `ln` | `\ln` | Ln function |
| `log` | `\log` | Log function |
| `exp` | `\exp` | Exp function |
| `arcsin` | `\arcsin` | Arcsin |
| `arccos` | `\arccos` | Arccos |
| `arctan` | `\arctan` | Arctan |

#### Calculus and analysis

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `sum` | `\sum` | sum sign (∑) |
| `prod` | `\prod` | product sign (∏) |
| `lim` | `\lim` | limit operator |
| `int` | `\int` | integral sign (∫) |
| `limit` | `\lim_{x \to a} f(x)` | Limit |
| `limsup` | `\limsup_{n \to \infty}` | Limit superior |
| `liminf` | `\liminf_{n \to \infty}` | Limit inferior |
| `sumn` | `\sum_{i=1}^{n} a_i` | Sum with bounds |
| `prodn` | `\prod_{i=1}^{n} a_i` | Product with bounds |
| `integral` | `\int f(x) \, dx` | Indefinite integral |
| `defint` | `\int_{a}^{b} f(x) \, dx` | Definite integral |
| `iint` | `\iint_{D} f \, dA` | Double integral |
| `iiint` | `\iiint_{V} f \, dV` | Triple integral |
| `oint` | `\oint_{C} F \cdot d\mathbf{r}` | Closed line integral |
| `deriv` | `\frac{df}{dx}` | Derivative d/dx |
| `pderiv` | `\frac{\partial f}{\partial x}` | Partial derivative |
| `deriv2` | `\frac{d^2 f}{dx^2}` | Second derivative |
| `grad` | `\nabla f` | Gradient |
| `divergence` | `\nabla \cdot \mathbf{F}` | Divergence |
| `curl` | `\nabla \times \mathbf{F}` | Curl |
| `laplacian` | `\nabla^2 f` | Laplacian |
| `bigO` | `O\left(n\right)` | Big-O |
| `seq` | `(a_{n})_{n \in \mathbb{N}}` | Sequence |
| `epsdelta` | `\forall \varepsilon > 0 \; \exists \delta > 0 :` | Epsilon-delta |

#### Linear algebra

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `vecarrow` | `\vec{v}` | Vector with arrow |
| `vecbold` | `\mathbf{v}` | Vector in bold |
| `hat` | `\hat{x}` | Unit vector / estimator hat |
| `colvec` | `\begin{pmatrix} a \\ b \\ c \end{pmatrix}` | Column vector |
| `matrix2` | `\begin{pmatrix} a & b \\ c & d \end{pmatrix}` | 2x2 matrix |
| `matrix3` | `\begin{pmatrix} a & b & c \\ d & e & f \\ g & h & i \end{pmatrix}` | 3x3 matrix |
| `det` | `\det(A)` | Determinant |
| `detmat` | `\begin{vmatrix} a & b \\ c & d \end{vmatrix}` | Determinant bars |
| `trace` | `\operatorname{tr}(A)` | Trace |
| `rank` | `\operatorname{rank}(A)` | Rank |
| `dim` | `\dim(V)` | Dimension |
| `kernel` | `\ker(A)` | Kernel |
| `image` | `\operatorname{im}(A)` | Image |
| `span` | `\operatorname{span}\{v_1, v_2\}` | Span |
| `inner` | `\langle u, v \rangle` | Inner product |
| `cross` | `a \times b` | Cross product |
| `identity` | `I_{n}` | Identity matrix |
| `eigen` | `A\mathbf{v} = \lambda \mathbf{v}` | Eigenvalue equation |

#### Statistics and probability

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `mean` | `\bar{x}` | Sample mean (bar) |
| `variance` | `\operatorname{Var}(X)` | Variance |
| `covariance` | `\operatorname{Cov}(X, Y)` | Covariance |
| `expect` | `\mathbb{E}\left[X\right]` | Expected value |
| `Prob` | `\mathbb{P}(A)` | Probability |
| `given` | `\mathbb{P}(A \mid B)` | Conditional probability |
| `binom` | `\binom{n}{k}` | Binomial coefficient |
| `normaldist` | `X \sim \mathcal{N}(\mu, \sigma^2)` | Normal distribution |
| `stddev` | `\sigma` | Standard deviation |
| `estimator` | `\hat{\theta}` | Estimator hat |
| `tilde` | `\tilde{x}` | Tilde accent |
| `chisq` | `\chi^2` | Chi-squared |
| `zscore` | `z = \frac{x - \mu}{\sigma}` | Z-score |
| `confint` | `\bar{x} \pm z_{\alpha/2} \frac{\sigma}{\sqrt{n}}` | Confidence interval |

#### Physics

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `vecF` | `\vec{F}` | Force vector |
| `dot` | `\dot{x}` | Time derivative (one dot) |
| `ddot` | `\ddot{x}` | Second time derivative |
| `hbar` | `\hbar` | Reduced Planck constant |
| `kB` | `k_{\mathrm{B}}` | Boltzmann constant |
| `deltaT` | `\Delta T` | Change in temperature |
| `deltaU` | `\Delta U` | Change in internal energy |
| `dQ` | `\delta Q` | Heat increment |
| `dW` | `\delta W` | Work increment |
| `newton2` | `\vec{F} = m\vec{a}` | Newton's second law |
| `kinematic` | `v = v_0 + a t` | V = v0 + a t |
| `workint` | `W = \int \vec{F} \cdot d\vec{r}` | Work as integral |
| `kinetic` | `E_k = \frac{1}{2} m v^2` | Kinetic energy |
| `potential` | `E_p = m g h` | Gravitational potential energy |
| `heatq` | `Q = m c \Delta T` | Heat capacity law |
| `firstlaw` | `\Delta U = Q - W` | First law of thermodynamics |
| `idealgas` | `p V = n R T` | Ideal gas law |
| `entropy` | `\Delta S = \int \frac{\delta Q}{T}` | Entropy change |
| `conserve` | `E_i = E_f` | Conservation of energy |
| `momentum` | `\vec{p} = m\vec{v}` | Momentum |

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
- The status line shows `Completed Checking document` and `ltex_plus` after opening a file. The first start is slow.
- Use the diagnostics: `]d` / `[d`, `<Space>dd` (message), `<Space>ca` (fixes).
- No personal dictionary or disabled-rule list is configured in the repo.
- Code actions on an unknown word (`Zorblat`, `<Space>ca`): `Use 'Format'`, `Use 'Combat'`, `Use 'Orbit'`, `Use 'Cobalt'`, `Use 'Oblast'`, `Add 'Zorblat' to dictionary`, `Hide false positive`, `Disable rule`, and `Create a Table of Contents` (from marksman). Choosing a replacement works: the word changes and `u` undoes it.
- `Add ... to dictionary`, `Hide false positive` and `Disable rule` do NOT work in this setup. They are client-side commands (`_ltex.addToDictionary` ...) that Neovim must implement, and your config has no handler; the server answers `Unknown command '_ltex.addToDictionary', ignoring`, nothing is saved, the warning stays. To silence a word use Vim's `zg` (see below), which only affects the Vim spell checker, not ltex_plus; to silence ltex_plus for a word, add it to the `ltex.dictionary` setting in `after/lsp/ltex_plus.lua` yourself.

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
| Preview does not open, or the page is blank (no diagrams or math) | No browser, or no internet (the page loads its libraries from CDNs). Check `:MdKite refresh` and that `:Lazy` shows mdkite.nvim installed |
| Preview tab stays open after I left the file | Intended: the preview keeps running until `:MdKite stop`, `<Alt-m>` in a Markdown buffer, or quitting Neovim |
| `<Alt-m>` in a second Markdown file stopped the preview instead of showing it | `:MdKite toggle` is global: with a preview running it stops it. Run `:MdKite start` in the second buffer |
| `and@` does not turn into `∧` | The buffer is not markdown, tex, plaintex or typst, or there is no space (non-letter) after the `@`; check `:iabbrev` |
| `:TruthTableExpand A nand B` gives a parse error | There is no `nand` / `nor`; write `not (A and B)` |
| `<Space>fm` or `:w` does not format | prettier is not on PATH (no message is shown): start Neovim from a shell that has prettier (nix profile or dev shell); `:ConformInfo` shows what will run. Or format on save is switched off: `<Space>fo` / `:FormatEnable` |
| `:ToPDF`: "pandoc not found" / "pandoc failed (exit N)" | Start Neovim inside the latex dev shell. Run the pandoc command in a terminal to see the error |
| `:ToPDF` does nothing visible | Normal: silent, 30 s or more the first time, no viewer on Linux. Look for the PDF next to the file |
| `@@` does not replay my macro | In Markdown it means "return from footnote". Use `@a` (register name) |
| Typing `^` or `@` has a delay | The `^^` / `@@` insert maps wait 500 ms for a second key. Accepted |
| `^^` puts the mark one letter early | At the end of a line in insert mode (see [Footnotes](#footnotes-vim-markdownfootnotes)). Use `<Space>mf` in normal mode |
| `<Space><Space>` does not remove trailing spaces | Intended in Markdown (hard line breaks) |
| Grammar warnings on Italian or German text | ltex_plus is `en-US` only |
| `^^` does nothing | The footnote plugin is not loaded: `:echo exists(':FootnoteNumber')` must give `2` |
| Maps do nothing in a huge file | Big-file mode: `:set ft=markdown` |

## Related sections

Section [15](../04-completion-snippets.md#15-snippets-ultisnips) and [52](../04-completion-snippets.md#52-snippets-for-developers-ultisnips) (snippets), section [16](../03-editing.md#16-code-commenting) (Code commenting: `gc` in Markdown writes `<!-- -->`; `gcs` / `gcr` use the comment style of the fence language inside a fenced block), section [27](../09-ai-and-writing.md#27-markdown-support) (short Markdown key list), section [28](../09-ai-and-writing.md#28-latex-and-typst-support) (LaTeX and Typst: same latex dev shell and ltex_plus), and the sections on [spelling](../09-ai-and-writing.md#31-spell-checking), [LSP diagnostics](../07-code.md#13-lsp-language-server-protocol) and big-file mode.


---
