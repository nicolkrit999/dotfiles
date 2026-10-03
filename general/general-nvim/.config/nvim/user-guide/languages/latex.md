<!-- chapter: LaTeX -->
[Back to the guide index](../README.md)

# 80. LaTeX (vimtex, texlab, ltex, PDF viewer)

This section covers everything that is specific to LaTeX in this config: what each tool is for, how it works, the keys, and what to do when something fails. Global things (LSP keys, completion menu, windows, spell checking) are only mentioned with a pointer to their own section. Typst and Markdown have their own sections.

Everything marked "(tested)" was run in a real Neovim inside the LaTeX devShell with a scratch project (October 2026).

## The big picture

Writing LaTeX means: a `.tex` source file, a compiler (`latexmk` runs `pdflatex` as many times as needed and runs BibTeX/biber), and a PDF viewer. Each tool in the config covers one part:

| Tool | Why it is in the setup | What you use it for |
| --- | --- | --- |
| **vimtex** (plugin) | Knows LaTeX syntax and the compile chain | Compile (`<Space>rf`), view PDF, jump between sections/environments, text objects, change/delete/toggle environments and commands, table of contents, error list |
| **texlab** (language server) | Understands the whole project (labels, citations, includes) | Completion of `\ref{` / `\cite{` / commands, diagnostics, hover (`K`), symbols, rename, `:LspTexlabBuild` |
| **ltex_plus** (language server) | Grammar and spelling for prose | Underlines mistakes in the text (not in commands) as diagnostics |
| **typos_lsp** (language server) | Catches common typos in any file | Same diagnostics channel; it attaches to every file type |
| **UltiSnips snippets** | Typing shortcuts | `use`, `eqa` (file `my_snippets/tex.snippets`) |
| **zathura** (PDF viewer) | Light viewer that reloads when the PDF changes and supports forward/inverse search | Shows the result |
| **LaTeX devShell** | Provides all the programs | `latex`, `latexmk`, `texlab`, `zathura`, `pandoc` |

In a `.tex` buffer the config also sets `textwidth = 120`, `wrap` on and a column marker at 120 (`after/ftplugin/tex.lua`, `lua/options.lua`). The statusline shows `texlab (+2)` when texlab, ltex_plus and typos_lsp are attached (tested).

## What it needs (the devShell)

vimtex is **enabled only when `latex` is on PATH**:

```lua
-- lua/plugin_specs.lua
"lervag/vimtex",
enabled = function() return utils.executable("latex") end,
ft = { "tex" },
```

Outside a LaTeX environment the plugin does not load: no `<Space>rf`, no `<F9>`, no `\ll`, no `:Vimtex*` commands. The environment comes from the flake `~/nix/templates/krit/dev-environments/language-specific/latex/flake.nix`. Its packages: `texlive.combined.scheme-full` (gives `latex`, `latexmk`, all packages), `texlab`, `zathura`, `pandoc`, `tectonic`, `latex2html`, `latex2mathml`.

| How you enter it | Details |
| --- | --- |
| direnv (normal) | The project folder has an `.envrc` with one line: `use_dev_env latex` (see `~/github-repos/personal/developing-projects/latex-projects/.envrc`). Run `direnv allow` once. Then `cd` in and start `nvim` there. |
| By hand | `nix develop <path-to-flake>` and then `nvim` |

Check inside the folder: `which latex latexmk texlab zathura` must print four paths.

**Start Neovim from inside the devShell.** The tools are looked up when Neovim starts; entering the shell afterwards does not enable vimtex in the already running Neovim.

Outside the devShell a `.tex` file still gets syntax colours, `ltex_plus`, `typos_lsp`, snippets and buffer/path completion. It gets no vimtex, no texlab, no PDF.

## Quick start

1. `cd` into the project folder (direnv loads the devShell).
2. Create and open `main.tex`:
   ```latex
   \documentclass{article}
   \begin{document}
   \section{Test}
   Hello \LaTeX.
   \end{document}
   ```
3. Wait until the statusline shows `texlab (+2)`. `:LspAttached` lists the clients.
4. `<Space>rf` (or `<F9>`) starts continuous compiling. After the first successful compile **zathura opens by itself** with the PDF (see "The viewer").
5. Edit, then `:w`. The compiler notices the saved file, recompiles, zathura reloads. (Auto-save never saves `.tex`; save yourself.)
6. `\lv` shows or re-opens the PDF at the cursor position.
7. `<Space>rf` / `<F9>` again stops compiling; `\lc` removes the auxiliary files.

## Compiling

`<Space>rf` and `<F9>` (buffer-local, set by an autocommand for `tex` files; description "LaTeX: start/stop compiling (vimtex)") and `\ll` are the same command, `<Plug>(vimtex-compile)` (tested). It starts `latexmk` in the background in **continuous mode** (recompiles whenever a source file changes); pressing it again stops it. `\` is the local leader: the config sets only `mapleader = <Space>`, so vimtex keeps the backslash.

**Where the output goes.** Tested: `main.pdf`, `main.aux`, `main.log`, `main.bbl` and the other files are written **next to `main.tex`**, not into a `build/` folder. The config contains

```vim
let g:vimtex_compiler_latexmk = { 'build_dir' : 'build' }
```

but the installed vimtex has no `build_dir` option (its documentation does not mention it; the current name is `out_dir`), so this line has no effect. `:LspTexlabBuild` (texlab's own one-shot build) also writes `main.pdf` next to the source (tested). If you want a `build/` folder, the option to set is `out_dir`.

| Command / key | What it does |
| --- | --- |
| `<Space>rf`, `<F9>` or `\ll` (`:VimtexCompile`) | Start or stop continuous compiling (tested) |
| `\lk` (`:VimtexStop`) | Stop. Message "VimTeX: Compiler stopped (name.tex)" (tested) |
| `\lc` (`:VimtexClean`) | Remove auxiliary files; keeps `main.pdf`, `main.bbl`, `main.synctex.gz`. Message "VimTeX: Compiler clean finished" (tested) |
| `\lC` | Clean everything including the PDF |
| `\lo` | Show the compiler output |
| `\lg` / `\lG` | Status of this / all compilers |
| `\lL` | Compile only the selected lines (visual mode too) |
| `\lq` | Show the vimtex log |
| `\li` / `\lI` | Info about the vimtex state of this document (short / full) |
| `\lx` / `\lX` | Reload vimtex / reload its state (use after changing the document structure) |
| `\ls` | Toggle the main file (`:VimtexToggleMain`) |
| `\la` | Context menu for the item under the cursor |
| `:LspTexlabBuild` | texlab's own build, once (tested: produces `main.pdf`). For daily work use `<Space>rf`: it keeps recompiling. |

All `\l...` keys above were checked in the live buffer; each points at the `<Plug>(vimtex-...)` map named in the vimtex documentation (tested).

### Errors

When a compile fails vimtex opens the **quickfix list** by itself, titled "VimTeX errors (LaTeX logfile)", and shows "VimTeX: Compilation failed!" (tested with a file containing `\foobar`; the entry was `Undefined control sequence. \foobar`, with the line number). texlab also puts the problem in the text as a diagnostic (`]d` / `[d`, `<Space>dd`; see the LSP section).

| Key / command | What it does |
| --- | --- |
| `\le` (`:VimtexErrors`) | Open the error list again |
| `:cnext` / `:cprev` | Next / previous error; `:cclose` closes the list |
| `\lo` | Read the raw compiler output |

If an error stops the compile, fix it, `:w`: the continuous compiler retries by itself (it does not have to be restarted).

Common messages: "Undefined control sequence" (a command is misspelled or its `\usepackage` is missing), "File `x.sty' not found" (a package is not in texlive; in the full scheme this should not happen), "Missing $ inserted" (maths outside `$...$`), "Runaway argument" (a `{` without `}`).

### Several files (a project with chapters)

Compile always starts from the **main file** (the one with `\documentclass`). When you open a chapter that is loaded with `\input` or `\include`, vimtex has to know the main file. The reliable way is a magic comment on the first lines of the chapter:

```latex
%! TEX root = ../main.tex
Chapter text.
```

Tested: opening `chap/c1.tex` with this comment gives `b:vimtex.tex` = the full path of `main.tex`, and `<Space>rf` in the chapter built `main.pdf`. Without the comment vimtex tries to find the main file itself, but in my test it picked a different `main.tex` from a neighbouring folder, so always add the comment in chapters. `\ls` toggles between the file and the main file.

## The viewer

`vim.g.vimtex_view_method` is `zathura` when `zathura` is on PATH, otherwise `general` (the system default PDF program). Windows uses SumatraPDF and macOS Skim (config lines for those platforms exist in the same spec).

- **A zathura window opens by itself after the first successful compile.** This is vimtex's default (`g:vimtex_view_automatic = 1`), not a bug. Later compiles only refresh the open window. If you do not want it: `:let g:vimtex_view_automatic = 0` (until you quit); you then open the PDF yourself with `\lv`. For a permanent change the line has to go into the config. (Tested both ways: without the option a zathura window titled with the full path of `main.pdf` opened about 14 seconds after `<Space>rf` in a fresh Neovim; with `view_automatic=0` nothing opened until `\lv`.)
- `\lv` (`:VimtexView`) opens the viewer or, if open, jumps to the place of the cursor (forward search). Tested from a chapter file with `%! TEX root`: zathura opened the PDF of the **main** file (`main.pdf`), and the process got `--synctex-forward 1:1:<path>/chap/c1.tex`, i.e. the cursor position of the chapter.
- **Inverse search** (Ctrl+click in the PDF jumps back to the source): the config writes the address of the running Neovim into `/tmp/vimtexserver.txt` every time a `tex` file is opened (`v:servername`). It is only a helper file; never edit it. With two Neovims open, the last one wins (the file is shared in `/tmp`). Tested prerequisites: the file exists and holds the same address as the running Neovim (`:echo v:servername`); the zathura process was started by vimtex with the inverse-search callback `-x "nvim --headless -c \"VimtexInverseSearch %{line}:%{column} '%{input}'\""`. Only the actual Ctrl+click cannot be tested without a mouse.

## Table of contents

`\lT` toggles, `\lt` opens the vimtex table of contents (`:VimtexTocToggle`, `:VimtexTocOpen`) (tested). It is a 30-column window on the left called TOC; the help lines are shown on top (config: `split_width = 30`, `show_help = 1`, layers content, todo, include). It lists sections, labelled equations, `\input` files and `TODO`/`FIXME` comments of the whole project.

| Key in the TOC | Action |
| --- | --- |
| `<Space>` | Jump to the entry, keep the TOC open |
| `<Enter>` | Jump and close the TOC |
| `<Esc>` / `q` | Close |
| `r` | Refresh |
| `h` | Toggle the help text |
| `t` | Toggle sorted TODO list |
| `s` | Hide / show numbers |
| `-` / `+` | Show fewer / more section levels |
| `f` / `F` | Apply / clear a filter |
| `L`, `I`, ... | Switch layers (label, include, ...) |

Move between the TOC and the text with `<Ctrl-w>h` / `<Ctrl-w>l` or `<Left>` / `<Right>`; the same keys move to the quickfix window (`<Ctrl-w>j` / `<Ctrl-w>k`, `<Down>` / `<Up>`). `<Ctrl-w>c` closes the window you are in.

## Moving and editing (vimtex)

Example text for the tests below (all keys tested in this exact file):

```latex
\section{One}
Text with $a+b$ and \textbf{bold} here. See \cite{knuth}.
\begin{equation}
x = 1
\end{equation}
\section{Two}
```

### Motions

| Key | Action |
| --- | --- |
| `]]` / `[[` | Next / previous section start (`\section`, `\begin{document}`, ...). From line 1 `]]` went to `\begin{document}`; from the text of One it went to `\section{Two}` |
| `][` / `[]` | Next / previous section end |
| `]m` / `[m` | Next / previous `\begin` of an environment |
| `]M` / `[M` | Next / previous `\end` of an environment |
| `]n` / `[n`, `]N` / `[N` | Next / previous start / end of a maths zone |
| `]r` / `[r`, `]R` / `[R` | Frames (beamer) |
| `]/` / `[/`, `]*` / `[*` | Comment blocks |
| `K` | In this config **LSP hover** (texlab), not vimtex's package-documentation lookup |
| `%` | Jumps between `\begin` and `\end` and brackets, but here the map belongs to **matchup** (`<Plug>(matchup-%)`), not vimtex (tested: from `\begin{equation}` it went to the `\end`) |

### Text objects (use after `d`, `y`, `c`, `v`)

| Keys | Object | Result in the example |
| --- | --- | --- |
| `ie` / `ae` | Environment: inside / with `\begin..\end` | cursor on `x = 1`: `yie` = `x = 1`, `yae` = whole equation (tested) |
| `ic` / `ac` | Command: name only / whole command | cursor on `textbf`: `yic` = `textbf`, `yac` = `\textbf{bold}` (tested) |
| `id` / `ad` | Delimiter pair: inside / with delimiters | cursor in `{bold}`: `yid` = `bold`, `yad` = `{bold}` (tested) |
| `i$` / `a$` | Maths | **unreliable**: on display maths it gives `x = 1` (`yi$` inside the equation), but on inline `$a+b$` it selected the display equation instead (tested; tree-sitter highlighting replaces vim's syntax for maths), see the note below |
| `iP` / `aP` | Section | `yaP` on the heading line = from `\section{One}` up to before `\section{Two}` (tested) |
| `im` / `am` | List item | needs an `itemize`/`enumerate` item |

`ic` / `ac` also exist in Markdown buffers with a different meaning (a config map for Markdown only); in `.tex` they are vimtex's.

**Note on maths detection.** Tree-sitter colours `.tex` files here, so Vim's own syntax is off, and vimtex shows a hint at start ("For more info, see :help vimtex-faq-treesitter"). Features that need the syntax groups to know "this is maths" are therefore unreliable for inline maths: `i$` / `a$`, `]n`, and the math insert maps. Environments, commands, delimiters and sections work (tested).

### Change, delete, toggle

| Keys | Action | Tested result |
| --- | --- | --- |
| `dse` | Delete the surrounding environment | the `\begin..\end` lines vanish, the body stays |
| `cse` | Change the environment name (prompt "Change surrounding environment: equation", type the new name, Enter) | `equation` became `align` in both places |
| `tss` | Toggle star of the environment | `equation` became `equation*` |
| `tse` | Toggle between two environments; default pair only `itemize` / `enumerate` (`g:vimtex_env_toggle_map`) | no change on `equation` |
| `dsc` / `csc` | Delete / change the surrounding command | `\textbf{bold}` became `bold` |
| `tsc` | Toggle star of a command | `\section{One}` became `\section*{One}` |
| `ds$` / `cs$` / `ts$` | Delete / change / toggle maths delimiters (`$..$`, `\[..\]`, `equation`) | not tested |
| `tsd` / `tsD` | Toggle `\left..\right` modifiers | not tested |
| `tsf` | Toggle fraction `a/b` and `\frac{a}{b}` | not tested |
| `<F6>` | Surround the line (or visual selection) with an environment (vimtex default; no leader alternative is set) | map exists |
| `<F7>` | Create a command from the word (insert and normal mode; vimtex default, no leader alternative) | map exists |
| `<F8>` | Add `\left`/`\right` to delimiters (vimtex default, no leader alternative) | map exists |
| `]]` in insert mode | Close the open environment/delimiter | map exists |
| `` ` `` + letter in insert mode | Maths shortcuts (`` `a `` = `\alpha`), made by `vimtex#imaps#wrap_math`. `\lm` (`:VimtexImapsList`) opens a "VimTeX imaps" window that lists all of them; close it with `:close` | The maps exist but **did not expand** in the test, even inside `equation`: they only fire when `vimtex#syntax#in_mathzone()` is true, and it returned 0 there (tree-sitter note below). `\lm` itself was tested |

These do not clash with the vim-sandwich keys of the config (`sa`, `sd`, `sr`).

## Language server (texlab)

texlab attaches to `tex` files when `texlab` is on PATH. It reads the whole project, so it also knows labels and citations of other files.

- **Completion**: commands, environments, `\ref{` labels, `\cite{` keys. The menu opens while you type; `<Ctrl-n>` opens it manually, `<Tab>` / `<Ctrl-n>` move down, `<CR>` confirms only an item you picked, `<Ctrl-e>` or `<Esc>` closes it (see section 14).
- **Diagnostics** (including errors from the build log), hover (`K`), symbols, rename, code actions (`<Space>ca`): the global LSP keys, see the LSP section.
- `:LspTexlabBuild`: one build (tested).

Sources for `tex` files (`lua/config/nvim-cmp.lua`):

```lua
cmp.setup.filetype("tex", { sources = {
  { name = "omni" },        -- vimtex
  { name = "nvim_lsp" },    -- texlab
  { name = "ultisnips" },
  { name = "buffer", keyword_length = 2 },
  { name = "path" },
}})
```

**Duplicates are normal**: typing `\sec` and `<Ctrl-n>` shows entries from vimtex (omni) and texlab (nvim_lsp), 26 entries with several "section" (tested). Either inserts the same text.

## Citations (bibliography)

Put references in a `.bib` file and load it in the document:

```latex
See \cite{knuth}.
\bibliographystyle{plain}
\bibliography{refs}      % refs.bib next to main.tex
```

with `refs.bib`:

```bibtex
@book{knuth, author={Knuth}, title={TAOCP}, year={1968}, publisher={AW}}
```

Typing `\cite{kn` and `<Ctrl-n>` shows `knuth [book] Knuth (1968), "TAOCP"` in the menu (tested). `latexmk` runs BibTeX itself during compile; the first compile after adding a `\cite` may show `[?]` until the next automatic run (tested: `main.bbl` was created by the first run). With biblatex use `\usepackage{biblatex}` and `\addbibresource{refs.bib}`; `latexmk` then runs biber (not tested here).

## Grammar and spelling (ltex_plus)

LanguageTool as a language server. Config (`after/lsp/ltex_plus.lua`):

```lua
filetypes = { "markdown", "tex", "plaintex", "typst", "gitcommit", "text" },
settings = { ltex = { language = "en-US", ... } },
```

- **One language per document: `en-US`**, although `spelllang` is `en,it,de,fr`. LaTeX commands are skipped; only the prose is checked.
- Problems are diagnostics. In my test a misspelled word got **two** underlines, one from `typos` and one from `LTeX`; this is normal.
- **Fix**: `<Space>ca` on the word opens the list (tested):

  | Entry | Result |
  | --- | --- |
  | `Use 'sentence'` | Replaces the word. Works (tested) |
  | `Use 'sen tense'` | Other suggestion |
  | `Add 'sentense' to dictionary` | **Had no effect in my test**: the LTeX diagnostic stayed (the config has no handler for ltex's client commands). Do not rely on it |
  | `Hide false positive`, `Disable rule` | No effect, same as `Add to dictionary` (tested, see section 81) |
  | `sentence`, `Ignore ... in the project` (typos_lsp) | typos fix; "Ignore" is a typos command |

- **What works for false positives**: ltex magic comments in the file (tested). `% LTeX: enabled=false` on a line of its own switches ltex off for the file (the LTeX underlines disappeared, typos stayed). `% LTeX: language=de-DE` makes the file checked as German (tested: German messages). Remove the line to undo.
- **Built-in spell checker** (different thing): `<Space>cz` toggles, `]s` / `[s`, `z=`, `zg` (adds to `spell/en.utf-8.add`, a file in the public repo). More in section 31.

## Snippets

UltiSnips, file `my_snippets/tex.snippets`. Both are start-of-line snippets (`b`): type the trigger at the beginning of a line, `<Ctrl-j>` expands and jumps forward, `<Ctrl-k>` jumps back. They also appear in the completion menu (tested: `use` + `<Ctrl-j>` gave `\usepackage{}` with the cursor inside; `eqa` + `<Ctrl-j>` gave the equation environment with the cursor in `\label{}`).

| Trigger | Result |
| --- | --- |
| `use` | `\usepackage{package}`, name selected |
| `eqa` | `\begin{equation}\label{}` / body / `\end{equation}`; first stop in the label, second in the body |

## Troubleshooting

| Problem | Cause and fix |
| --- | --- |
| `<Space>rf`, `<F9>` and `\ll` do nothing, `:VimtexCompile` unknown | vimtex not loaded: `latex` not on PATH. Start Neovim inside the devShell (`which latex`, `direnv allow`). Check `:set ft?` is `tex` |
| Compile fails, quickfix opened | Read the first entry (`\le`), fix that line, `:w`; the compiler retries. Raw output: `\lo` |
| No PDF | Look next to `main.tex` (not in `build/`), see "Where the output goes". A fatal error stops the PDF |
| Viewer did not open | `zathura` not on PATH, or the compile failed, or `g:vimtex_view_automatic` is 0. Try `\lv` |
| A viewer opened that I did not expect | Normal after the first successful compile; `:let g:vimtex_view_automatic = 0` |
| "Undefined control sequence" | Misspelled command or missing package: add `\usepackage{...}` (snippet `use`) |
| Chapter file compiles the wrong document or errors | Add `%! TEX root = ../main.tex` at the top of the chapter |
| Citation shows `[?]` | `.bib` file not found or first run: compile again; check `\bibliography{refs}` |
| texlab not in the statusline | `texlab` not on PATH, or still starting. `:LspAttached`, `:checkhealth vim.lsp` |
| Same completion twice | Normal (vimtex omni and texlab) |
| `i$` / `]n` / `` ` `` shortcuts do not find inline maths | Tree-sitter highlighting replaces vim syntax, see the note above |
| Real word marked wrong by ltex | Magic comment, or fix the spelling; "Add to dictionary" does not work here |
| German/other language text full of errors | `% LTeX: language=de-DE` on its own line |
| Edits not in the PDF | Auto-save does not save `.tex`: `:w`. Check the compiler is running (`\lg`) |
| First compile is slow | `latexmk` builds everything once (bibliography, references); later runs are fast. Stop with `<Space>rf` when not needed |
| Inverse search from zathura jumps nowhere | `/tmp/vimtexserver.txt` has the address of the last Neovim that opened a `tex` file; reopen the file in the Neovim you want |

## Related sections

Typst (`<Space>tw`), Markdown, 28 (LaTeX and Typst, older summary), 31 (spell checking), the LSP and completion sections (diagnostic and completion keys), snippets (UltiSnips), windows (`<Ctrl-w>` moves).


---
