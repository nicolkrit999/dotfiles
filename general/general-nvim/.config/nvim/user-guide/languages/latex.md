<!-- chapter: LaTeX -->
[Back to the guide index](../README.md)

# 80. LaTeX (vimtex, texlab, ltex, PDF viewer)

This section covers everything that is specific to LaTeX in this config: what each tool is for, how it works, the keys, and what to do when something fails. Global things (LSP keys, completion menu, windows, spell checking) are only mentioned with a pointer to their own section. [Typst](typst.md#82-typst-typstvim-tinymist-watch-and-preview) and [Markdown](markdown.md#81-markdown-writing-preview-footnotes-pdf) have their own sections.

Unless marked otherwise, everything below was run in a real Neovim inside the LaTeX devShell with a scratch project (October 2026).

## The big picture

Writing LaTeX means: a `.tex` source file, a compiler (`latexmk` runs `pdflatex` as many times as needed and runs BibTeX/biber), and a PDF viewer. Each tool in the config covers one part:

| Tool | Why it is in the setup | What you use it for |
| --- | --- | --- |
| **vimtex** (plugin) | Knows LaTeX syntax and the compile chain | Compile (`<Space>rf`), view PDF, jump between sections/environments, text objects, change/delete/toggle environments and commands, table of contents, error list |
| **texlab** (language server) | Understands the whole project (labels, citations, includes) | Completion of `\ref{` / `\cite{` / commands, diagnostics, hover (`K`), symbols, rename, `:LspTexlabBuild` |
| **ltex_plus** (language server) | Grammar and spelling for prose | Underlines mistakes in the text (not in commands) as diagnostics |
| **typos_lsp** (language server) | Catches common typos in any file | Same diagnostics channel; it attaches to every file type |
| **UltiSnips snippets** | Typing shortcuts | `use`, `eqa`, and 191 math snippets (`mk`, `dm`, symbol names such as `leq`) (file `my_snippets/tex.snippets`) |
| **zathura** (PDF viewer) | Light viewer that reloads when the PDF changes and supports forward/inverse search | Shows the result |
| **LaTeX devShell** | Provides all the programs | `latex`, `latexmk`, `texlab`, `zathura`, `pandoc` |

In a `.tex` buffer the config also sets `textwidth = 120`, `wrap` on and a column marker at 120 (`after/ftplugin/tex.lua`, `lua/options.lua`). The statusline shows `texlab (+2)` when texlab, ltex_plus and typos_lsp are attached.

## What it needs (the devShell)

vimtex is **enabled only when `latex` is on PATH**:

The real spec head (`lua/plugin_specs.lua`; the `init` function is shown in pieces under ["How vimtex is set up"](#how-vimtex-is-set-up-the-real-code) below):

```lua
-- LaTeX support: loaded on every platform whenever `latex` is on PATH (on Linux via the LaTeX devShell)
{
  "lervag/vimtex",
  enabled = function()
    return utils.executable("latex")
  end,
  -- not lazy on purpose: the PDF viewer's Ctrl+click starts a separate headless nvim (no tex file) that
  -- needs the :VimtexInverseSearch command, which only exists once vimtex is loaded
  lazy = false,
  init = function()
```

In plain words:

- `enabled`: the plugin only exists when `latex` is on PATH, as described above.
- `lazy = false`: vimtex is **not** lazy-loaded on `ft = "tex"`. The PDF viewer's Ctrl+click starts a separate headless Neovim with no `tex` file, and that Neovim needs the `:VimtexInverseSearch` command, which only exists once vimtex is loaded (see ["The viewer"](#the-viewer)).
- `init` runs before the plugin loads and sets its options (the next section).

Outside a LaTeX environment the plugin does not load: no `<Space>rf`, no `<F9>`, no `\ll`, no `:Vimtex*` commands. The environment comes from the flake `~/nix/templates/krit/dev-environments/language-specific/latex/flake.nix`. Its packages: `texlive.combined.scheme-full` (gives `latex`, `latexmk`, all packages), `texlab`, `zathura`, `pandoc`, `tectonic`, `latex2html`, `latex2mathml`.

| How you enter it | Details |
| --- | --- |
| direnv (normal) | The project folder has an `.envrc` with one line: `use_dev_env latex` (see `~/github-repos/personal/developing-projects/latex-projects/.envrc`). Run `direnv allow` once. Then `cd` in and start `nvim` there. |
| By hand | `nix develop <path-to-flake>` and then `nvim` |

Check inside the folder: `which latex latexmk texlab zathura` must print four paths.

**Option 1: `:DevEnv latex` in the running Neovim.** Type `:DevEnv latex` then `<CR>`. It evaluates the LaTeX flake in the background (about 10 seconds the first time, then cached), adds its programs to `PATH` for this session, enables texlab, loads vimtex and replays the file type for open `.tex` buffers. A notification `DevEnv: latex ready: ...` lists what started. Opening a `.tex` file without `latex` shows a one-time hint, `latex not found on PATH: run :DevEnv latex to enter its devShell`. Details and the list of all devShells: [section 43](../07-code.md#43-how-the-development-toolchain-fits-together). It affects this session only.

**Option 2: start Neovim from inside the devShell.** The tools are looked up when Neovim starts; entering the shell with direnv or `nix develop` afterwards does not enable vimtex in an already running Neovim (use Option 1 for that).

Outside the devShell a `.tex` file still gets syntax colours, `ltex_plus`, `typos_lsp`, snippets and buffer/path completion. It gets no vimtex, no texlab, no PDF.

## How vimtex is set up (the real code)

All of it is the `init` function of the vimtex spec in `lua/plugin_specs.lua`, quoted verbatim in four pieces plus a short closing block (the spec head is shown in "[What it needs](#what-it-needs-the-devshell)"). Each piece is dedented to its own left margin (the original is indented 10 spaces inside `vim.cmd`); only the indentation differs from the file. The VimL part sits inside `vim.cmd([[ ... ]])` and only runs when `latex` is on PATH.

**1. Viewer choice and inverse-search helper**

```lua
vim.g.vimtex_view_method = (utils.executable("zathura") and "zathura") or "general"
vim.cmd([[
  if executable('latex')
    " Hacks for inverse search to work semi-automatically,
    function! s:write_server_name() abort
      let nvim_server_file = (has('win32') ? $TEMP : '/tmp') . '/vimtexserver.txt'
      call writefile([v:servername], nvim_server_file)
    endfunction

    augroup vimtex_common
      autocmd!
      autocmd FileType tex call s:write_server_name()
      " buffer-local like the old nmap, via Lua so the map can carry a desc
      autocmd FileType tex lua for _, lhs in ipairs({ "<F9>", "<leader>rf" }) do vim.keymap.set("n", lhs, "<Plug>(vimtex-compile)", { buffer = true, remap = true, desc = "LaTeX: start/stop compiling (vimtex)" }) end
    augroup END
```

In plain words:

- `vimtex_view_method` is `zathura` when zathura is installed, otherwise `general` (the system default PDF program).
- `s:write_server_name` writes Neovim's address (`v:servername`) into `/tmp/vimtexserver.txt` (`%TEMP%` on Windows) every time a `tex` file is opened. The viewer's inverse search (Ctrl+click) uses it to find the right Neovim; see ["The viewer"](#the-viewer).
- The autocommand sets the compile key twice, buffer-local, for `tex` files only: `<F9>` and `<leader>rf` both map to `<Plug>(vimtex-compile)`. `remap = true` is required because the target is a `<Plug>` mapping; it is set from Lua so the key can carry a `desc`.

**2. latexmk build directory and the table of contents**

```lua
let g:vimtex_compiler_latexmk = {
      \ 'build_dir' : 'build',
      \ }

" TOC settings
let g:vimtex_toc_config = {
      \ 'name' : 'TOC',
      \ 'layers' : ['content', 'todo', 'include'],
      \ 'resize' : 1,
      \ 'split_width' : 30,
      \ 'todo_sorted' : 0,
      \ 'show_help' : 1,
      \ 'show_numbers' : 1,
      \ 'mode' : 2,
      \ }
```

In plain words:

- `build_dir = 'build'` is in the config but has no effect: see "Where the output goes" under ["Compiling"](#compiling). vimtex's current option is called `out_dir`.
- `g:vimtex_toc_config` configures the `\lt` / `\lT` table of contents (section ["Table of contents"](#table-of-contents)): `layers` = what is listed (document content, todo comments, included files); `split_width = 30` = a 30-column window; `resize = 1` = Vim is resized automatically when that vertical window opens (vimtex default 0); `mode = 2` = separate window **and** a location list (1 = window only, 3/4 = location list only); `show_numbers = 1` = section numbers; `show_help = 1` = the key hint lines at the top; `todo_sorted = 0` = todo entries stay in file order. Meanings checked against vimtex's `:help vimtex-toc` upstream text.

**3. Viewers on Windows and macOS**

```lua
" Viewer settings for different platforms
if g:is_win
  let g:vimtex_view_general_viewer = 'SumatraPDF'
  let g:vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
endif

if g:is_mac
  " let g:vimtex_view_method = "skim"
  let g:vimtex_view_general_viewer = '/Applications/Skim.app/Contents/SharedSupport/displayline'
  let g:vimtex_view_general_options = '-r @line @pdf @tex'

  augroup vimtex_mac
    autocmd!
    autocmd User VimtexEventCompileSuccess call UpdateSkim()
  augroup END

  " The following code is adapted from https://gist.github.com/skulumani/7ea00478c63193a832a6d3f2e661a536.
  function! UpdateSkim() abort
    let l:out = b:vimtex.out()
    let l:src_file_path = expand('%:p')
    let l:cmd = [g:vimtex_view_general_viewer, '-r']

    if !empty(system('pgrep Skim'))
      call extend(l:cmd, ['-g'])
    endif

    call jobstart(l:cmd + [line('.'), l:out, l:src_file_path])
  endfunction
endif
```

In plain words:

- Windows (`g:is_win`): SumatraPDF with `-reuse-instance -forward-search @tex @line @pdf` (one window, jumps to the cursor line).
- macOS (`g:is_mac`): Skim through its `displayline` helper (`-r @line @pdf @tex`). `UpdateSkim()` runs after every successful compile (`VimtexEventCompileSuccess`) and re-opens or refreshes Skim at the cursor line; `-g` keeps Skim in the background when it is already running. The function is adapted from the public gist named in the comment. The commented `vimtex_view_method = "skim"` line is a leftover.
- On Linux none of this runs; zathura from piece 1 is used.
- The last four lines (shown below) close the `if executable('latex')`, the `vim.cmd`, the `init` function and the spec.

Closing lines of the spec:

```lua
      endif
    ]])
  end,
},
```

One more cross-plugin setting belongs to vimtex: `vim.g.matchup_override_vimtex = 1` in the `vim-matchup` spec (same file). It lets vim-matchup take over `%` matching in `tex` files instead of vimtex's own implementation.

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
4. `<Space>rf` (or `<F9>`) starts continuous compiling. After the first successful compile **zathura opens by itself** with the PDF (see ["The viewer"](#the-viewer)).
5. Edit, then `:w`. The compiler notices the saved file, recompiles, zathura reloads. (Auto-save never saves `.tex`; save yourself.)
6. `\lv` shows or re-opens the PDF at the cursor position.
7. `<Space>rf` / `<F9>` again stops compiling; `\lc` removes the auxiliary files.

## Compiling

`<Space>rf` and `<F9>` (buffer-local, set by an autocommand for `tex` files; description "LaTeX: start/stop compiling (vimtex)") and `\ll` are the same command, `<Plug>(vimtex-compile)`. It starts `latexmk` in the background in **continuous mode** (recompiles whenever a source file changes); pressing it again stops it. `\` is the local leader: the config sets only `mapleader = <Space>`, so vimtex keeps the backslash.

**Where the output goes.** `main.pdf`, `main.aux`, `main.log`, `main.bbl` and the other files are written **next to `main.tex`**, not into a `build/` folder. The config contains

```vim
let g:vimtex_compiler_latexmk = { 'build_dir' : 'build' }
```

but the installed vimtex has no `build_dir` option (its documentation does not mention it; the current name is `out_dir`), so this line has no effect. `:LspTexlabBuild` (texlab's own one-shot build) also writes `main.pdf` next to the source. If you want a `build/` folder, the option to set is `out_dir`.

| Command / key | What it does |
| --- | --- |
| `<Space>rf`, `<F9>` or `\ll` (`:VimtexCompile`) | Start or stop continuous compiling |
| `\lk` (`:VimtexStop`) | Stop. Message "VimTeX: Compiler stopped (name.tex)" |
| `\lc` (`:VimtexClean`) | Remove auxiliary files; keeps `main.pdf`, `main.bbl`, `main.synctex.gz`. Message "VimTeX: Compiler clean finished" |
| `\lC` | Clean everything including the PDF |
| `\lo` | Show the compiler output |
| `\lg` / `\lG` | Status of this / all compilers |
| `\lL` | Compile only the selected lines (visual mode too) |
| `\lq` | Show the vimtex log |
| `\li` / `\lI` | Info about the vimtex state of this document (short / full) |
| `\lx` / `\lX` | Reload vimtex / reload its state (use after changing the document structure) |
| `\ls` | Toggle the main file (`:VimtexToggleMain`) |
| `\la` | Context menu for the item under the cursor |
| `:LspTexlabBuild` | texlab's own build, once (produces `main.pdf`). For daily work use `<Space>rf`: it keeps recompiling. |

Each of the `\l...` keys above points at the `<Plug>(vimtex-...)` map named in the vimtex documentation.

### Errors

When a compile fails vimtex opens the **quickfix list** by itself, titled "VimTeX errors (LaTeX logfile)", and shows "VimTeX: Compilation failed!" (with a file containing `\foobar`; the entry was `Undefined control sequence. \foobar`, with the line number). texlab also puts the problem in the text as a diagnostic (`]d` / `[d`, `<Space>dd`; see the [LSP section](../07-code.md#13-lsp-language-server-protocol)).

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

Opening `chap/c1.tex` with this comment gives `b:vimtex.tex` = the full path of `main.tex`, and `<Space>rf` in the chapter built `main.pdf`. Without the comment vimtex tries to find the main file itself, but in my test it picked a different `main.tex` from a neighbouring folder, so always add the comment in chapters. `\ls` toggles between the file and the main file.

## The viewer

`vim.g.vimtex_view_method` is `zathura` when `zathura` is on PATH, otherwise `general` (the system default PDF program). Windows uses SumatraPDF and macOS Skim (config lines for those platforms exist in the same spec).

- **A zathura window opens by itself after the first successful compile.** This is vimtex's default (`g:vimtex_view_automatic = 1`), not a bug. Later compiles only refresh the open window. If you do not want it: `:let g:vimtex_view_automatic = 0` (until you quit); you then open the PDF yourself with `\lv`. For a permanent change the line has to go into the config. (Both ways: without the option a zathura window titled with the full path of `main.pdf` opened about 14 seconds after `<Space>rf` in a fresh Neovim; with `view_automatic=0` nothing opened until `\lv`.)
- `\lv` (`:VimtexView`) opens the viewer or, if open, jumps to the place of the cursor (forward search). From a chapter file with `%! TEX root`: zathura opened the PDF of the **main** file (`main.pdf`), and the process got `--synctex-forward 1:1:<path>/chap/c1.tex`, i.e. the cursor position of the chapter.
- **Inverse search** (Ctrl+click in the PDF jumps back to the source): the config writes the address of the running Neovim into `/tmp/vimtexserver.txt` every time a `tex` file is opened (`v:servername`). It is only a helper file; never edit it. With two Neovims open, the last one wins (the file is shared in `/tmp`). Prerequisites: the file exists and holds the same address as the running Neovim (`:echo v:servername`); the zathura process was started by vimtex with the inverse-search callback `-x "nvim --headless -c \"VimtexInverseSearch %{line}:%{column} '%{input}'\""`. Running that same callback in a second Neovim made the first Neovim jump to the clicked line and column. This only works because vimtex is loaded at startup (not only for `tex` files): the callback Neovim has no `tex` file open and needs the `:VimtexInverseSearch` command (found and fixed 2026-10-03; before, the click did nothing and showed no error).

## Table of contents

`\lT` toggles, `\lt` opens the vimtex table of contents (`:VimtexTocToggle`, `:VimtexTocOpen`). It is a 30-column window on the left called TOC; the help lines are shown on top (config: `split_width = 30`, `show_help = 1`, layers content, todo, include). It lists sections, labelled equations, `\input` files and `TODO`/`FIXME` comments of the whole project.

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

Example text for the tests below (all keys run in this exact file):

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
| `%` | Jumps between `\begin` and `\end` and brackets, but here the map belongs to **matchup** (`<Plug>(matchup-%)`), not vimtex (from `\begin{equation}` it went to the `\end`) |

### Text objects (use after `d`, `y`, `c`, `v`)

| Keys | Object | Result in the example |
| --- | --- | --- |
| `ie` / `ae` | Environment: inside / with `\begin..\end` | cursor on `x = 1`: `yie` = `x = 1`, `yae` = whole equation |
| `ic` / `ac` | Command: name only / whole command | cursor on `textbf`: `yic` = `textbf`, `yac` = `\textbf{bold}` |
| `id` / `ad` | Delimiter pair: inside / with delimiters | cursor in `{bold}`: `yid` = `bold`, `yad` = `{bold}` |
| `i$` / `a$` | Maths | **unreliable**: on display maths it gives `x = 1` (`yi$` inside the equation), but on inline `$a+b$` it selected the display equation instead (tree-sitter highlighting replaces vim's syntax for maths), see the note below |
| `iP` / `aP` | Section | `yaP` on the heading line = from `\section{One}` up to before `\section{Two}` |
| `im` / `am` | List item | needs an `itemize`/`enumerate` item |

`ic` / `ac` also exist in Markdown buffers with a different meaning (a config map for Markdown only); in `.tex` they are vimtex's.

**Note on maths detection.** Tree-sitter colours `.tex` files here, so Vim's own syntax is off, and vimtex shows a hint at start ("For more info, see :help vimtex-faq-treesitter"). Features that need the syntax groups to know "this is maths" are therefore unreliable for inline maths: `i$` / `a$`, `]n`, and the math insert maps. Environments, commands, delimiters and sections work.

### Change, delete, toggle

| Keys | Action | Result |
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
| `` ` `` + letter in insert mode | Maths shortcuts (`` `a `` = `\alpha`), made by `vimtex#imaps#wrap_math`. `\lm` (`:VimtexImapsList`) opens a "VimTeX imaps" window that lists all of them; close it with `:close` | The maps exist but **did not expand** in the test, even inside `equation`: they only fire when `vimtex#syntax#in_mathzone()` is true, and it returned 0 there (tree-sitter note below). `\lm` itself ran in the same test |

These do not clash with the vim-sandwich keys of the config (`sa`, `sd`, `sr`).

## Language server (texlab)

texlab attaches to `tex` files when `texlab` is on PATH. It reads the whole project, so it also knows labels and citations of other files.

- **Completion**: commands, environments, `\ref{` labels, `\cite{` keys. The menu opens while you type; `<Ctrl-n>` opens it manually, `<Tab>` / `<Ctrl-n>` move down, `<CR>` confirms only an item you picked, `<Ctrl-e>` or `<Esc>` closes it (see [section 14](../04-completion-snippets.md#14-autocompletion-nvim-cmp)).
- **Diagnostics** (including errors from the build log), hover (`K`), symbols, rename, code actions (`<Space>ca`): the global LSP keys, see the [LSP section](../07-code.md#13-lsp-language-server-protocol).
- `:LspTexlabBuild`: one build.

The server entry (`lua/config/lsp.lua`):

```lua
-- LaTeX (texlab comes from the LaTeX devShell; enabled only when executable)
texlab = { cmd = { "texlab" } },
```

Only the command is given. The server is enabled only when `texlab` is on PATH (the generic rule for all servers), so outside the devShell nothing starts and nothing warns.

Sources for `tex` files (`lua/config/nvim-cmp.lua`):

```lua
cmp.setup.filetype("tex", {
  sources = {
    { name = "omni" },
    { name = "nvim_lsp" }, -- texlab (LaTeX devShell); no-op when no LSP is attached
    { name = "ultisnips" },
    { name = "buffer",   keyword_length = 2 },
    { name = "path" },
  },
})
```

**Duplicates are normal**: typing `\sec` and `<Ctrl-n>` shows entries from vimtex (omni) and texlab (nvim_lsp), 26 entries with several "section". Either inserts the same text.

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

Typing `\cite{kn` and `<Ctrl-n>` shows `knuth [book] Knuth (1968), "TAOCP"` in the menu. `latexmk` runs BibTeX itself during compile; the first compile after adding a `\cite` may show `[?]` until the next automatic run (`main.bbl` was created by the first run). With biblatex use `\usepackage{biblatex}` and `\addbibresource{refs.bib}`; `latexmk` then runs biber (not tested here).

## Grammar and spelling (ltex_plus)

LanguageTool as a language server. Config (`after/lsp/ltex_plus.lua`):

```lua
-- LanguageTool grammar/spell checking via ltex-ls-plus (installed globally by nix).
---@type vim.lsp.Config
return {
  filetypes = { "markdown", "tex", "plaintex", "typst", "gitcommit", "text" },
  ---@type lspconfig.settings.ltex
  settings = {
    ltex = {
      -- user's spelllang is en,it,de,fr; LanguageTool checks ONE language per document.
      -- Alternative: language = "auto" (LanguageTool detects the language per document;
      -- less reliable on short texts such as commit messages).
      language = "en-US",
      -- language ids (after get_language_id): this list REPLACES lspconfig's default list
      enabled = { "markdown", "latex", "tex", "plaintex", "typst", "gitcommit", "git-commit", "plaintext", "text" },
      -- setting ltex.ltex-ls.logLevel: the default ("fine") writes whole documents to stderr,
      -- i.e. into lsp.log, on every check
      ["ltex-ls"] = { logLevel = "warning" },
    },
  },
}
```

The file is quoted in full (`after/lsp/ltex_plus.lua`). `enabled` lists language ids and **replaces** the plugin default list; `logLevel = "warning"` stops the server from logging whole documents on every check.

- **One language per document: `en-US`**, although `spelllang` is `en,it,de,fr`. LaTeX commands are skipped; only the prose is checked.
- Problems are diagnostics. In my test a misspelled word got **two** underlines, one from `typos` and one from `LTeX`; this is normal.
- **Fix**: `<Space>ca` on the word opens the list:

  | Entry | Result |
  | --- | --- |
  | `Use 'sentence'` | Replaces the word. Works |
  | `Use 'sen tense'` | Other suggestion |
  | `Add 'sentense' to dictionary` | **Had no effect in my test**: the LTeX diagnostic stayed (the config has no handler for ltex's client commands). Do not rely on it |
  | `Hide false positive`, `Disable rule` | No effect, same as `Add to dictionary` (see [section 81](markdown.md#81-markdown-writing-preview-footnotes-pdf)) |
  | `sentence`, `Ignore ... in the project` (typos_lsp) | typos fix; "Ignore" is a typos command |

- **What works for false positives**: ltex magic comments in the file. `% LTeX: enabled=false` on a line of its own switches ltex off for the file (the LTeX underlines disappeared, typos stayed). `% LTeX: language=de-DE` makes the file checked as German (German messages). Remove the line to undo.
- **Built-in spell checker** (different thing): `<Space>cz` toggles, `]s` / `[s`, `z=`, `zg` (adds to `spell/en.utf-8.add`, a file in the public repo). More in [section 31](../09-ai-and-writing.md#31-spell-checking).

## Snippets

UltiSnips, file `my_snippets/tex.snippets`. Both are start-of-line snippets (`b`): type the trigger at the beginning of a line, `<Ctrl-j>` expands and jumps forward, `<Ctrl-k>` jumps back. They also appear in the completion menu, which shows the description in quotes below.

| Trigger | Description |
| --- | --- |
| `use` | \usepackage line: type the package name (start of line) |
| `eqa` | Numbered equation environment with a label, referenced with \ref{label} (start of line) |

**`use`**: the cursor starts on the `package` placeholder inside the braces.

```latex
\usepackage{package}
```

Example: `package` = `amsmath` gives `\usepackage{amsmath}`.

**`eqa`**: an equation environment with a label. The first placeholder is `label` (inside `\label{}`), the second is `content` (the formula on its own indented line). Refer to the equation elsewhere with `\ref{label}` using the same label text.

```latex
\begin{equation}\label{label}
	content
\end{equation}
```

Example: `label` = `eq:energy`, `content` = `E = mc^2`; later `\ref{eq:energy}` prints the equation number.

### Math symbols

Inside math, a symbol is one typed word: you type its name instead of remembering the LaTeX command. This part of the file has 191 snippets: 2 math delimiters and 189 symbols.

How to use them, step by step:

1. Type `mk` for inline math or `dm` for a display math block, then press `<Ctrl-j>` (hold the Ctrl key and press j). `mk` writes `$` `$` and puts the cursor between them; `dm` writes `\[`, an indented empty line and `\]` on three lines and puts the cursor on the empty middle line. Typing the `$` characters yourself works too.
2. Inside the math, type a symbol name such as `leq` and press `<Ctrl-j>` (or accept the name in the completion menu). The name is replaced by the symbol and the cursor ends right after it. The symbol snippets expand only while the cursor is inside math: outside math `<Ctrl-j>` does not expand them and only does what it does without a snippet (it starts a new line); the completion menu may still list the names.
3. A snippet with placeholders (for example `frac`) selects the first placeholder; type over it, then press `<Ctrl-j>` to go to the next one. After the last placeholder, `<Ctrl-j>` moves the cursor to the end of the symbol, still inside the math. For `mk`, one more `<Ctrl-j>` then moves it past the closing `$`; for `dm`, past the closing `\]` (the cursor stays on that line). When the math contains only plain symbols (no placeholders), the first `<Ctrl-j>` after you finish typing already leaves the closing delimiter.

After the expansion the cursor is always after the symbol. Word-like commands (`\leq`, `\alpha`, `\infty`, `\cdot`, ...) get one trailing space so the next letter you type does not stick to the command; the space is not shown in the tables. `sub`, `sup`, `inv`, `transpose`, `degree` and `celsius` attach to what you typed before, so they add no space and also expand right after a letter (`x` then `sub` gives `x_{i}`). In the Produces column the words in a placeholder show the text you can type over (for example `\frac{a}{b}`).

Worked example: inline math `x \leq y`.

| You type | You get (`<cursor>` marks the cursor) |
| --- | --- |
| `mk`, then `<Ctrl-j>` | `$<cursor>$` |
| `x` | `$x<cursor>$` |
| a space, then `leq`, then `<Ctrl-j>` | `$x \leq <cursor>$` |
| `y` | `$x \leq y<cursor>$` |
| `<Ctrl-j>` | `$x \leq y$<cursor>` (the cursor is after the closing `$`) |

Where they work: the check reads the text of the file from the top down to the cursor, so it does not depend on vimtex or on syntax colours. These count as math: text between a pair of `$`, between `$$` and `$$`, between `\(` and `\)`, between `\[` and `\]`, and the body of `equation`, `align`, `gather`, `multline`, `flalign`, `eqnarray`, `displaymath`, `math` and `split` (with or without the `*`). These do not count as math: text outside those places, a `\text{...}`, `\textrm{...}`, `\mbox{...}` group inside math, a line after a `%` comment sign, a `\$` with a backslash, and the body of `verbatim`, `lstlisting`, `minted` and `comment` environments. A blank line ends an unclosed `$...$`, `$$...$$` or `\(...\)`. The symbol names are not offered straight after a backslash (`\alpha` typed by hand stays as typed). `mk` and `dm` expand in text and in math, but not in a comment or a verbatim environment. The snippets belong to the file type `tex`. `vim.g.tex_flavor = "latex"` (in `lua/globals.lua`) makes every `.tex` file open as `tex`, also one whose first lines have no `\documentclass` (Neovim would otherwise open it as `plaintex`, which gets no snippets).

Switched off in `tex` files: these triggers of the shared vim-snippets collection are removed by a `clearsnippets` line at the top of the math block (`my_snippets/tex.snippets`), so they no longer expand: `cc`, `inn`, `Nn`, `UU`, `uuu`, `nnn`, `HH`, `DD`, `part`, `ooo`, `=>`, `=<`, `==`, `!=`, `<=`, `>=`, `lll`, `xx`, `<!`, `!>`, `srt`, `srto`, `ss`, `__`, `compl`, `conj`, `bar`, `taylor`, `rij`, `pmat`, `bmat`, `lrb`, `lra`, the `invs` suffix snippet (`3invs`), and the word triggers `sin`, `cos`, `arccot`, `cot`, `csc`, `ln`, `log`, `exp`, `star`, `perp` (the math tables below define their own `sin`, `cos`, `ln`, `log`, `exp`, `perp` and the other functions). `sum`, `lim` and `prod` are in the same list; the math tables below define new `sum`, `prod` and `lim`. The environment and structure snippets of vim-snippets (`abs`, `prob`, `prop`, `def`, `lemma`, `fig`, `tab`, `table`, ...) are not touched.

#### Math delimiters

| Trigger | Produces | Meaning |
| --- | --- | --- |
| `mk` | `$` `$` | Inline math, cursor between the dollar signs |
| `dm` | `\[`, empty line, `\]` | Display math on its own lines, cursor on the empty line |

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

## Troubleshooting

| Problem | Cause and fix |
| --- | --- |
| `<Space>rf`, `<F9>` and `\ll` do nothing, `:VimtexCompile` unknown | vimtex not loaded: `latex` not on PATH. Run `:DevEnv latex`, or start Neovim inside the devShell (`which latex`, `direnv allow`). Check `:set ft?` is `tex` |
| Compile fails, quickfix opened | Read the first entry (`\le`), fix that line, `:w`; the compiler retries. Raw output: `\lo` |
| No PDF | Look next to `main.tex` (not in `build/`), see "[Where the output goes](#compiling)". A fatal error stops the PDF |
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
| Inverse search from zathura jumps nowhere | Quit and restart Neovim (an old session may still have vimtex lazy-loaded); `/tmp/vimtexserver.txt` has the address of the last Neovim that opened a `tex` file, so reopen the file in the Neovim you want |

## Related sections

[Typst](typst.md#82-typst-typstvim-tinymist-watch-and-preview) (`<Space>tw`), [Markdown](markdown.md#81-markdown-writing-preview-footnotes-pdf), [28](../09-ai-and-writing.md#28-latex-and-typst-support) (LaTeX and Typst, older summary), [31](../09-ai-and-writing.md#31-spell-checking) (spell checking), the [LSP](../07-code.md#13-lsp-language-server-protocol) and [completion](../04-completion-snippets.md#14-autocompletion-nvim-cmp) sections (diagnostic and completion keys), [snippets](../04-completion-snippets.md#15-snippets-ultisnips) (UltiSnips), [windows](../06-windows-terminal-sessions.md#7-windows-splits-and-buffers) (`<Ctrl-w>` moves).


---
