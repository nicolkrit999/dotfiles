<!-- chapter: Typst -->
[Back to the guide index](../README.md)

# 82. Typst (typst.vim, tinymist, watch and preview)

Typst is a modern markup language that compiles to PDF (like LaTeX, but much faster and simpler). This section covers everything that is specific to Typst files (`*.typ`): the plugin, the language server, the compile-and-preview workflow, prose checking and the files that make it work. Global tools (completion, folding, quickfix, spell keys) are only mentioned with a pointer to their own section.

## What you get

| Piece | What it does | Where it comes from |
| --- | --- | --- |
| `kaarmu/typst.vim` | `:TypstWatch`, `:Toc`/`:Toch`/`:Tocv`/`:Toct`, `:make` (compiles once), indentation, `//` comments, Typst syntax colours | plugin, loaded only when `typst` is on PATH |
| `<Space>tw` | Starts `typst watch` for the current file (recompile on every save, open the PDF) | `after/ftplugin/typst.lua` |
| `tinymist` | Language server: diagnostics, completion, hover, go to definition, rename, symbols, formatter | typst devShell |
| `typstyle` | The formatter that `tinymist` uses (`<Space>fm`) | typst devShell |
| `zathura` | PDF viewer that reloads by itself when the PDF changes | typst devShell |
| `ltex_plus` and `typos_lsp` | Grammar, spelling and typo diagnostics in the prose | global (see "Prose checking") |
| Buffer settings | `textwidth=100`, wrap on, colour marker at column 100, indent of 2 spaces | `after/ftplugin/typst.lua`, `lua/options.lua`, typst.vim |

There are no Typst snippets (`my_snippets/` has no `typst.snippets`) and no Typst-specific completion source: completion comes from the language server (section 14).

## Requirements: the Typst devShell

The programs `typst`, `tinymist`, `typstyle` and `zathura` come from a Nix devShell, not from the system. The template is `~/nix/templates/krit/dev-environments/language-specific/typst/flake.nix`; its package list is:

```nix
packages = with pkgs; [ typst typstyle typstwriter tinymist prettypst utpm zathura ]
```

A project enters it through direnv. The `.envrc` of a Typst project contains one line:

```
use_dev_env typst
```

Then `cd` into the project (run `direnv allow` once per project). Start Neovim from that shell, so it sees the programs. Or, in an already running Neovim, run `:DevEnv typst` (then `<CR>`): it adds the programs to `PATH` for this session, loads typst.vim and enables tinymist (section 43). Check:

```bash
which typst tinymist typstyle zathura
```

### Outside the devShell

| What | Result |
| --- | --- |
| `typst` not on PATH | The plugin `typst.vim` does not load: no `:TypstWatch`, no `:Toc`. Tested: `exists(':TypstWatch')` is 0 |
| `<Space>tw` | Still mapped (buffer-local); it shows ONE warning: "Typst: typst not found on PATH (open nvim inside the typst devShell)". Nothing starts |
| `tinymist` not on PATH | No Typst language server. Tested: only `ltex_plus` and `typos_lsp` attach |
| Filetype | `*.typ` is still recognised as `typst`; prose checking (`ltex_plus`, `typos_lsp`) still works |

## Quick start

1. In a terminal, enter the project folder (the devShell loads through direnv).
2. Open a file: `nvim main.typ`.
3. Wait a few seconds until the statusline on the right shows `tinymist` (it is the main server; `(+2)` means two more servers: `ltex_plus` and `typos_lsp`). `ltex_plus` attaches last: in a test it was still missing after 14 seconds and present within 40.
4. Press `<Space>tw`. The command line shows `Starting: typst watch  --diagnostic-format short 'main.typ' --open zathura` and the PDF opens in zathura.
5. Edit the text and save with `:w` (Typst files are never saved automatically, see "Auto-save" below). The PDF is rebuilt and zathura reloads it.
6. If the document has an error, a quickfix window opens at the bottom with the message. Fix it and save again: the window closes by itself.
7. To stop: quit Neovim (`:qa`). The watcher is a child job and ends with Neovim (tested: no `typst watch` process was left). Closing the zathura window alone does not stop the watcher.

## Keys and commands

| Key / command | Where | Description |
| --- | --- | --- |
| `<Space>tw` | Typst buffers only | Runs `:TypstWatch`: `typst watch --diagnostic-format short <file> --open <viewer>` as a background job. Pressing it again stops the old job and starts a new one (tested: new process id) |
| `:TypstWatch {args}` | needs typst.vim | Same, with extra `typst` options, e.g. `:TypstWatch --root ..` |
| `:make` | needs typst.vim | Compiles the file once (`typst compile --diagnostic-format short %`); errors go to the quickfix list (section 26) |
| `:Toc` / `:Tocv` | needs typst.vim | Table of contents of the `=` headings in a vertical location list on the right; `:Toch` horizontal, `:Toct` in a new tab. Press `Enter` on a line to jump |
| `<Space>fm` | global | Format the whole file with the language server (typstyle). Tested: `#greet(   "x"  )   #let   y=3` became `#greet("x")   #let y = 3` |
| `gq` | global | Reformats prose lines to `textwidth` (100); not the Typst formatter |
| `K` | LSP | Hover: signature and parameters of a function (tested on `greet` and `text`) |
| `gd` | LSP | Go to definition: from a function call to its `#let`, from `@intro` to the `<intro>` label (tested) |
| `<Space>rn` | LSP | Rename symbol (`tinymist` supports rename) |
| `<Space>ca` | LSP | Code action menu at the cursor |
| `]d` / `[d`, `<Space>dd` | global | Next / previous diagnostic; `<Space>dd` shows a float with the diagnostic of the current line (section 13) |
| `gcc` | global | Comment line with `//` (typst.vim sets `commentstring` to `// %s`) |
| `<Space>t` | global | Symbol outline (aerial, section 37); in Typst buffers see the note below |
| `[t` / `]t` | aerial | Previous / next symbol (heading or `#let`) |

Note on `<Space>t`: in Typst buffers `<Space>tw` exists next to the global `<Space>t` (outline). When you press `<Space>t` alone, Neovim waits `timeoutlen` (500 ms) for a possible `w` before it opens the outline. This is expected; press `<Space>t` and wait half a second.

The tinymist server also advertises extra commands (`tinymist.exportPdf`, `tinymist.startDefaultPreview`, `tinymist.exportSvg`, `tinymist.pinMain`, ...). No key is bound to them; this setup uses `typst watch` instead (see next part). The setting `exportPdf = "never"` stops tinymist from writing PDFs on its own.

## The language server: tinymist

Why: it understands Typst while you type, without compiling to a PDF. Config (`lua/config/lsp.lua`):

```lua
tinymist = {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.dirname(vim.fs.find({ "typst.toml", ".git" }, { path = fname, upward = true })[1])
      or vim.fs.dirname(fname)
    on_dir(root)
  end,
  settings = {
    exportPdf = "never",
    outputPath = "$root/out/$name",
    formatterMode = "typstyle",
  },
},
```

| Setting | Meaning |
| --- | --- |
| `root_dir` | The project root is the nearest folder above the file with `typst.toml` (a Typst package) or `.git`; with neither, the folder of the file. Tested: a file in a folder without `.git` got that folder as root |
| `exportPdf = "never"` | The server does not export PDFs; only `typst watch` does. So there is one PDF writer, not two |
| `outputPath` | Only used when the server exports (it does not here); it is a leftover default |
| `formatterMode = "typstyle"` | `<Space>fm` formats with typstyle |

What it provides, as tested in a real session:

| Feature | How to see it |
| --- | --- |
| Diagnostics | A broken line (`#greet( 1 ,  2 )` with too many arguments) showed `typst:18:unexpected argument` in `vim.diagnostic.get()` and the error sign in the gutter. Source name: `typst` |
| Completion | 38 items for `#set te...` (`array literal`, `cite`, `context expression`, ...) in the completion menu (section 14) |
| Hover | `K` on a function shows its signature, e.g. `let greet(name: str) = str` |
| Definition | `gd` on a call or on a `@label` |
| Symbols | The outline (`<Space>t`) lists headings and `#let` definitions |
| Formatter | `<Space>fm` (typstyle) |

Check which servers are attached: `:LspAttached` (popup) or the statusline (right side, first name is the main server `tinymist`, `(+2)` the others). `:LspInfo` shows details; `:LspLog` opens the log (section 13).

## Watch, compile and the PDF

`<Space>tw` is defined like this (`after/ftplugin/typst.lua`):

```lua
if vim.fn.executable("typst") == 1 then
  vim.keymap.set("n", "<leader>tw", "<cmd>TypstWatch<cr>",
    { buffer = true, desc = "Typst: watch & recompile" })
else
  vim.keymap.set("n", "<leader>tw", function()
    vim.notify("Typst: typst not found on PATH (open nvim inside the typst devShell)", vim.log.levels.WARN)
  end, { buffer = true, desc = "Typst: watch & recompile (needs typst)" })
end
```

The real typst.vim spec (`lua/plugin_specs.lua`, verbatim):

```lua
-- Typst syntax highlighting, :TypstWatch, and :make support.
-- Requires the `typst` CLI on PATH (add pkgs.typst to your nix env).
{
  "kaarmu/typst.vim",
  enabled = function()
    return utils.executable("typst")
  end,
  ft = { "typst" },
  init = function()
    -- Conceal features are off by default; enable per-user if desired.
    vim.g.typst_conceal       = 0
    vim.g.typst_conceal_math  = 0
    vim.g.typst_conceal_emoji = 0
    -- Folding is off; enable by setting typst_folding = 1 locally.
    vim.g.typst_folding       = 0
    -- Auto-open quickfix window on compile errors.
    vim.g.typst_auto_open_quickfix = 1
    -- Use zathura for auto-reloading PDF preview; fall back to env var or system default.
    vim.g.typst_pdf_viewer = vim.env.TYPST_PDF_VIEWER or (utils.executable("zathura") and "zathura") or ""
  end,
},
```

In plain words:

- `enabled`: typst.vim only loads when `typst` is on PATH (inside the Typst devShell). Without it there is no `:TypstWatch`, `:Toc` or `:make` support.
- `ft = { "typst" }`: lazy-loaded when a Typst file is opened.
- `typst_conceal`, `typst_conceal_math`, `typst_conceal_emoji` = 0: no concealing; you see the raw source. Set one to 1 locally to hide markup / render math symbols / emoji names.
- `typst_folding = 0`: the plugin's folding is off. Set `vim.g.typst_folding = 1` to get folds by headings.
- `typst_auto_open_quickfix = 1`: a compile error opens the quickfix window by itself.
- `typst_pdf_viewer`: `$TYPST_PDF_VIEWER` if set, else `zathura` if installed, else an empty string (typst's `--open` then uses the system default PDF program).
- Not set: `typst_output_to_tmp` (so the PDF stays next to the source).

The Typst-side filetype file is `after/ftplugin/typst.lua` (verbatim, whole file); it sets the two prose options and the `<Space>tw` key:

```lua
-- Typst filetype settings and keymaps.
-- Loaded automatically for *.typ buffers by Neovim's after/ftplugin mechanism.

-- Reasonable defaults for prose-heavy markup files.
vim.opt_local.textwidth = 100
vim.opt_local.wrap      = true

-- <leader>tw  - launch typst watch (recompile + open PDF) in background.
-- TypstWatch is provided by kaarmu/typst.vim, which is only enabled when `typst` is on PATH
-- (e.g. inside the typst devShell): same check here. Without typst the key shows ONE warning
-- (an unmapped key would fall through to <Space>t (aerial) + w).
if vim.fn.executable("typst") == 1 then
  vim.keymap.set("n", "<leader>tw", "<cmd>TypstWatch<cr>",
    { buffer = true, desc = "Typst: watch & recompile" })
else
  vim.keymap.set("n", "<leader>tw", function()
    vim.notify("Typst: typst not found on PATH (open nvim inside the typst devShell)", vim.log.levels.WARN)
  end, { buffer = true, desc = "Typst: watch & recompile (needs typst)" })
end
```

The `<Space>tw` part of this file is the block above ("Watch, compile and the PDF"); the two `vim.opt_local` lines are the `textwidth` and `wrap` rows in "Filetype settings".

| Question | Answer |
| --- | --- |
| What runs? | `typst watch  --diagnostic-format short '<file>' --open <viewer>` in a background job, started from the current folder of Neovim |
| Which viewer? | `$TYPST_PDF_VIEWER` if set, else `zathura` if installed, else (empty value) `--open` alone, i.e. the system default PDF program |
| Where is the PDF? | Next to the `.typ` file with the same name (`main.typ` gives `main.pdf`). Tested. (`g:typst_output_to_tmp` is not set, so `/tmp/typst_out` is not used) |
| When does it recompile? | Every time the `.typ` file (or a file it imports) is saved |
| Why is auto-save off for Typst? | A recompile on every focus change would restart the watcher over and over; save with `:w` (section 42) |
| Where are compile errors? | In the quickfix list (opens at the bottom, cursor stays in your window). Lines look like `main.typ\|19 col 13\| error: unexpected argument`. `]q`-style quickfix keys are in section 26 |
| What happens to the PDF on an error? | The old PDF stays (tested: file time unchanged) until the error is fixed |
| Does a fixed error clear the window? | Yes: the next successful compile empties the list and closes the window (tested) |
| How to stop? | Quit Neovim. A second `<Space>tw` replaces the running watcher. There is no stop command |
| One watcher only | The plugin keeps one watcher job; watching another file with `<Space>tw` stops the first |

To test the viewer by hand without Neovim: `zathura main.pdf` (reloads on change).

## Prose checking in Typst

| Tool | Result in a `.typ` file |
| --- | --- |
| `ltex_plus` | LanguageTool (English, `en-US`) on the text: `'smal': Possible spelling mistake found.`, `Don't put a space before the full stop.`. Source name `LTeX`. Needs `ltex-ls-plus` installed globally |
| `typos_lsp` | Common typos: `` `smal` should be `small` ``. Source name `typos` |
| `<Space>cz` | Toggles Vim's own spell checker (section 31); `zg` adds a word to your English list, `2zg`/`3zg`/`4zg` Italian/German/French |
| `<Space>ca` on a warning | Offers the fix (replace the word) |

All three appear as diagnostics together with the `tinymist` ones (use `]d`, `<Space>dd`). Typst code is not skipped: LanguageTool may complain about markup such as `#link(...)`. Both tools never attach to files that are too big (section 42).

## Filetype settings

| Setting | Value | From |
| --- | --- | --- |
| `textwidth` | 100 | `after/ftplugin/typst.lua` |
| `wrap` | on | `after/ftplugin/typst.lua` |
| `colorcolumn` | 100 | `lua/options.lua` (per-language table) |
| `expandtab`, `shiftwidth` | spaces, 2 | typst.vim |
| `commentstring` | `// %s` | typst.vim |
| `iskeyword` | letters, digits, `_`, `-` and accents | typst.vim: `ciw` on `my-label` takes the whole word |
| Folding | off (`typst_folding = 0`; `foldmethod=manual`); folds in general come from nvim-ufo (section 18) | `plugin_specs.lua` |
| Concealing | off (`typst_conceal*` all 0): you see the raw source | `plugin_specs.lua` |
| Auto-save | never for Typst files | `plugin_specs.lua` (auto-save condition) |

## Example document

Save as `main.typ` in a folder with the devShell:

```typst
#set page(paper: "a5")
#set text(size: 11pt)
#set heading(numbering: "1.")

= Introduction <intro>

This is a smal test document with a typo. See @intro and #link("https://typst.app")[Typst].

#let greet(name) = [Hello, #name!]

#greet("World")

== Math

$ E = m c^2 $

- first item
- second item
```

### What to try

| Do | Expected result |
| --- | --- |
| Open the file, wait 5 seconds | Statusline shows `tinymist (+2)`; signs for line 7 (`smal`) |
| `<Space>tw` | Message `Starting: typst watch ... --open zathura`; `main.pdf` appears; zathura opens it (tested) |
| Change `a5` to `a4`, `:w` | The PDF is recompiled and zathura shows the bigger page |
| Add a line `#greet( 1 ,  2 )` at the end, `:w` | Quickfix window with `error: unexpected argument`; the error sign on the line; PDF unchanged |
| Delete that line, `:w` | Quickfix window closes; PDF updated |
| `gd` on `@intro` | Cursor jumps to the heading line `= Introduction <intro>` |
| `gd` on `greet` in `#greet("World")` | Cursor jumps to `#let greet(name) = ...` |
| `K` on `greet` | Floating window with `let greet(name: str) = str` |
| Type `#set te` and wait | Completion menu with `text` and others |
| Type `#greet(   "x"  )   #let   y=3` then `<Space>fm` | `#greet("x")   #let y = 3` |
| `:Tocv` | Location list at the right with `Introduction` and `Math` |
| `<Space>t` and wait | Symbol outline (aerial): `Introduction`, `Math`, `greet` |
| `:make` | Compiles once; empty quickfix when everything is fine |

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `<Space>tw` shows "Typst: typst not found on PATH" | Neovim was not started inside the devShell | `cd` into the project (direnv), check `which typst`, restart Neovim |
| `E492: Not an editor command: TypstWatch` | Same: typst.vim did not load without `typst` | Same fix |
| No `tinymist` in the statusline | `tinymist` not on PATH, or file is not `typst` filetype | `which tinymist`; `:set ft?` must say `typst`; `:LspAttached` |
| `direnv: error ... .envrc is blocked` | The project's `.envrc` is not approved | `direnv allow` once in the project |
| Watch starts but the PDF does not change | The file has a compile error (old PDF stays), or you did not save | Look at the quickfix window or `:copen`; save with `:w` |
| Watch compiles the wrong file or cannot find imports | Watcher started from another current folder than the file's | `:cd %:p:h`, then `<Space>tw` again |
| Viewer does not open | `zathura` missing, or `$TYPST_PDF_VIEWER` points to a missing program | `which zathura`; unset or fix `TYPST_PDF_VIEWER`; open `main.pdf` by hand |
| Two PDFs or a PDF in `out/` | A server export was enabled by hand | Keep `exportPdf = "never"` in `lua/config/lsp.lua` |
| Quickfix window did not open | The error has no `file:line:col` (e.g. a missing font warning) | Run `:!typst compile --diagnostic-format short %` and read the output |
| `<Space>t` feels slow in Typst files | It waits for a possible `w` (`<Space>tw`) | Expected; wait 500 ms, or use `:AerialToggle` |
| Warnings about prose inside markup | LanguageTool reads Typst source as text | Ignore, or `<Space>cz`/`zg` for words; see section 31 |
| File not saved automatically | By design, Typst files are excluded from auto-save | `:w` |

## Related sections

Section 13 (LSP), 14 (autocompletion), 18 (folding), 26 (quickfix and location list), 27 (Markdown), 28 (LaTeX and Typst overview), 31 (spell checking), 32 (statusline), 37 (symbol outline), 41 (filetype settings), 42 (automatic behaviours), 44 (LSP in depth).
