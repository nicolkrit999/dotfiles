<!-- chapter: Plugin catalog -->
[Back to the guide index](README.md)

# 83. Plugin catalog

This chapter lists every plugin of the config in one place, grouped by what it is for. Each entry says in one or two sentences what the plugin is and what it is used for here, and links to the in-depth section of the guide that explains it (keys, commands, examples). Plugins that only load under a condition (a language, an operating system, a tool on PATH) say so.

The catalog is kept in sync by `build-pdf.py --check`: it fails when a plugin of the config has no entry here, when an entry has no working link to a section that really names the plugin, or when an entry names a plugin that is no longer installed. Whoever adds, removes or renames a plugin updates this chapter and the in-depth section in the same change.

**Loaded at startup.** An entry that begins with this label is loaded in every session without any trigger from you: either while Neovim starts or right after the first screen appears (lazy.nvim's `VeryLazy`), or on a bare `nvim` start for the dashboard. Entries without the label are loaded only when needed (a key, a command, a file type, a git repository, Insert mode and so on), so their startup cost is zero until then. The colorscheme of the current session is also loaded at startup, which theme that is depends on the machine (see [Colorschemes](#colorschemes)).

<!-- plugin-count: 118 -->

## LSP and code intelligence

### Language servers, diagnostics and navigation

- `nvim-lspconfig`: **Loaded at startup.** Ships the ready-made definitions of language servers (command, filetypes, root markers). This config enables the servers itself in lua/config/lsp.lua; the plugin only provides the defaults. Keys such as `K`, `gd`, `<Space>rn`, `<Space>ca` are this config's own. In depth: [How LSP Is Managed](07-code.md#how-lsp-is-managed-nvim-lspconfig)
- `lazydev.nvim`: Teaches the Lua language server the Neovim API, so editing this config gives completion, hover and no false "undefined global vim" warnings. Loads only in Lua files. In depth: [Editing the Neovim config in Lua (lazydev.nvim)](07-code.md#editing-the-neovim-config-in-lua-lazydevnvim)
- `glance.nvim`: **Loaded at startup.** Shows definitions, references and implementations in a popup so you can peek without leaving your file. Keys: `<Space>gd`, `<Space>gr`, `<Space>gi`. In depth: [Peeking Without Jumping (Glance)](07-code.md#peeking-without-jumping-glancenvim)
- `nvim-lightbulb`: Shows a lightbulb in the sign column when the LSP has a code action for the current line; filters out ruff's two always-on actions. Press `<Space>ca` to use it. In depth: [The Lightbulb](07-code.md#the-lightbulb-nvim-lightbulb)
- `trouble.nvim`: A tidy list window for diagnostics grouped by file. In this config it is opened by `<Space>dw` (`:Trouble diagnostics toggle`) to look at errors and warnings across the project. In depth: [Trouble (Better Quickfix UI)](05-search-and-files.md#troublenvim-better-quickfix-ui)
- `fidget.nvim`: **Loaded at startup.** Shows small progress messages in the bottom-right corner while a language server is working (indexing, starting up). No keys; defaults only. In depth: [LSP progress messages (fidget.nvim)](06-windows-terminal-sessions.md#lsp-progress-messages-fidgetnvim)
- `aerial.nvim`: A sidebar outline of the file's functions, classes and methods, built from Treesitter or the LSP. Toggle it with `<Space>t`; `[t` / `]t` jump between symbols. In depth: [37. Symbol outline (`aerial.nvim`)](02-navigation.md#37-symbol-outline-aerialnvim)
- `dropbar.nvim`: **Loaded at startup.** A bar at the top of the window (winbar) showing where you are as a path, like file > class > function. Used here only with its defaults; no keys are configured. In depth: [Breadcrumb bar (dropbar.nvim)](06-windows-terminal-sessions.md#breadcrumb-bar-dropbarnvim)
- `nvim-devdocs`: Reads DevDocs documentation (language and library references) inside Neovim, in a buffer or a floating window. Used through its `:Devdocs*` commands; no keys are mapped. In depth: [DevDocs (Plugin)](07-code.md#nvim-devdocs-plugin)
- `nvim-treesitter`: **Loaded at startup.** Parses code into a syntax tree for accurate highlighting. Started per buffer when a parser exists; also feeds aerial, treesj, devdocs and the smart comment code. Parsers come from the Nix store on Nix systems. In depth: [46. Treesitter In Depth](07-code.md#46-treesitter-in-depth-nvim-treesitter)

### Java

- `nvim-java`: Wires the Java tooling together: starts the jdtls language server, test and debug extensions and adds the `:Java*` commands. Used here for building, running, testing, debugging and refactoring Java projects with the `<Space>j` key family. Only for Java files (it loads when you open one). In depth: [78. Java (nvim-java, jdtls, tests, debugging)](languages/java.md#78-java-nvim-java-jdtls-tests-debugging)
- `spring-boot.nvim`: A second language server for Spring Boot projects that attaches next to jdtls. Brought in automatically by nvim-java; there is nothing to configure or press for it. In depth: [spring-boot (Spring Boot tools)](languages/java.md#spring-boot-spring-boot-tools)
- `nvim-dap`: The general debugger client (breakpoints, stepping) implementing the Debug Adapter Protocol. Here it is installed only for Java debugging through nvim-java; there is no panel; four keys (`<Space>jp` breakpoint, `<Space>jP` clear all breakpoints, `<Space>jh` value under the cursor, `<Space>jx` stop) and the typed `:Dap*` commands (`:DapContinue`, `:DapStepOver`, ...) do the rest. In depth: [Debug Adapter Protocol (DAP)](07-code.md#debug-adapter-protocol-dap-nvim-dap)

### Debugging and running code

- `nvim-gdb`: Visual front end for GDB, LLDB and pdb: starts the debugger in a terminal pane and marks the current line in your code. Used mainly to step through Python with pdb (`<Space>dp`) and for C/C++ with `:GdbStart` in the c-cpp devShell. In depth: [GDB Integration](07-code.md#gdb-integration-nvim-gdb) and [Debugging with pdb](languages/python.md#debugging-with-pdb-nvim-gdb)
- `asyncrun.vim`: Runs a shell command as a background job and streams its output into the quickfix window (opened 6 lines tall). Here `<Space>rf` / `<F9>` for Python goes through it. In depth: [The AsyncRun Plugin](10-various.md#the-asyncrunvim-plugin)

## Completion and snippets

### Completion

- `nvim-cmp`: **Loaded at startup.** The completion engine: shows a popup menu with suggestions from the language server, snippets, paths and buffer words while you type, and in the `:` and `/` command lines. Keys are tuned so `<Tab>` picks and `<CR>` only confirms a picked item. In depth: [14. Autocompletion (`nvim-cmp`)](04-completion-snippets.md#14-autocompletion-nvim-cmp)
- `cmp-nvim-lsp`: **Loaded at startup.** Completion source that feeds the language server's suggestions (functions, variables, types) into the nvim-cmp menu. In depth: [Completion sources and helpers](04-completion-snippets.md#completion-sources-and-helpers)
- `cmp-path`: **Loaded at startup.** Completion source for file and folder paths, in insert mode and in the `:` command line. In depth: [Completion sources and helpers](04-completion-snippets.md#completion-sources-and-helpers)
- `cmp-buffer`: **Loaded at startup.** Completion source that offers words already present in the current buffer; also completes words in the `/` search line. In depth: [Completion sources and helpers](04-completion-snippets.md#completion-sources-and-helpers)
- `cmp-omni`: **Loaded at startup.** Completion source that passes through a filetype's omni-completion function; used here only in LaTeX files (BibTeX and citation completion). In depth: [Completion sources and helpers](04-completion-snippets.md#completion-sources-and-helpers)
- `cmp-cmdline`: **Loaded at startup.** Completion source for the command line: offers Ex command names and arguments (and paths) after `:`, and buffer words in the `/` search. In depth: [Completion sources and helpers](04-completion-snippets.md#completion-sources-and-helpers)
- `cmp-nvim-ultisnips`: **Loaded at startup.** Bridge that lists UltiSnips snippet triggers in the completion menu, so a snippet can be picked from the menu like any other item. In depth: [Completion sources and helpers](04-completion-snippets.md#completion-sources-and-helpers)
- `colorful-menu.nvim`: **Loaded at startup.** Colours the labels in the completion menu like code (name, arguments, type) instead of plain text; works automatically, no keys. In depth: [Completion sources and helpers](04-completion-snippets.md#completion-sources-and-helpers)

### Snippets and pairs

- `ultisnips`: **Loaded at startup.** The snippet engine: type a trigger, expand it into a template and jump through its placeholders. Personal snippets live in `my_snippets/`. In depth: [15. Snippets (`UltiSnips`)](04-completion-snippets.md#15-snippets-ultisnips)
- `vim-snippets`: **Loaded at startup.** A ready-made collection of snippets for many languages that UltiSnips loads alongside the personal ones; no config. In depth: [Ready-made snippets (`vim-snippets`)](04-completion-snippets.md#ready-made-snippets-vim-snippets)
- `nvim-autopairs`: Inserts the closing bracket or quote automatically when you type the opening one. Default behaviour, no keys of its own. In depth: [Auto-pairing (nvim-autopairs plugin)](03-editing.md#auto-pairing-nvim-autopairs-plugin)

## Editing and motions

### Text objects and surroundings

- `vim-sandwich`: **Loaded at startup.** Adds, deletes and replaces surrounding characters (quotes, brackets) with `sa`, `sd`, `sr`. Here `s` alone is disabled (use `cl`), and its "query" text objects live on `iS` / `aS`. In depth: [Adding surrounding pairs (vim-sandwich plugin)](03-editing.md#adding-surrounding-pairs-vim-sandwich-plugin)
- `targets.vim`: **Loaded at startup.** Extra text objects: any-bracket `ib`/`ab`, arguments `ia`/`aa`, quotes `iq`/`aq`, separators `i,`/`a,`, and it looks forward on the line when the cursor is not inside the pair. In depth: [targets.vim (plugin)](07-code.md#targetsvim-plugin)
- `vim-matchup`: Better `%` that jumps between `if`/`else`/`end` style keywords as well as brackets, highlights the pair and shows an off-screen partner in a popup. Also gives `i%`/`a%`, `g%`, `[%`, `]%`, `z%`. In depth: [vim-matchup (plugin)](07-code.md#vim-matchup-plugin)
- `vim-swap`: **Loaded at startup.** Swaps items of a comma-separated list or argument list interactively with `gs`. Only that one key is kept (plugin defaults off, so `g<` and `g>` stay builtin). In depth: [65. Swapping function arguments (`vim-swap`)](03-editing.md#65-swapping-function-arguments-vim-swap)
- `treesj`: Splits a one-line list, argument list, table or block into one item per line, and joins it back, using the Treesitter syntax tree. One key: `gS`. In depth: [Split and join code (treesj)](03-editing.md#split-and-join-code-treesj)

### Moving around and searching in the buffer

- `hop.nvim`: `f` + two characters labels every match on screen; press the label to jump. It replaces the builtin `f`. Hint colours follow the active colorscheme's Search highlight. In depth: [22. Jump navigation (`hop.nvim`)](02-navigation.md#22-jump-navigation-hopnvim)
- `nvim-hlslens`: Shows a `[x/y]` match counter next to the current search match. `n`, `N`, `*`, `#` are remapped in config/hlslens.lua; `*` and `#` search the whole word literally and keep the cursor in place (with a count they jump). In depth: [23. Search lens (`nvim-hlslens`)](02-navigation.md#23-search-lens-nvim-hlslens)
- `vim-illuminate`: **Loaded at startup.** Highlights other uses of the word under the cursor (LSP, else Treesitter; plain text matching in nix files) when there are at least 2. `<Alt-n>` / `<Alt-p>` jump between them, `<Alt-i>` selects one. In depth: [Word references (vim-illuminate)](02-navigation.md#word-references-vim-illuminate)

### Editing helpers

- `vim-commentary`: **Loaded at startup.** Toggles comments with `gc` + motion, `gcc`, and `:[range]Commentary`. A custom smart-comment module sits next to it. In depth: [vim-commentary (plugin)](03-editing.md#vim-commentary-plugin)
- `tabular`: `:Tabularize /char` aligns text around a character (equals signs, colons, table pipes). Loads on first `:Tabularize` or with the first Markdown file. In depth: [Align Text](03-editing.md#align-text-with-tabular)
- `vim-repeat`: **Loaded at startup.** Makes the `.` key repeat plugin actions (surround, comment, swap and so on) and not only builtin edits. It has no keys or commands of its own. In depth: [61. The dot command (`.`) -- repeating actions](03-editing.md#61-the-dot-command-----repeating-actions)
- `better-escape.vim`: Typing `jk` quickly in Insert mode returns to Normal mode, with a 200 ms window between the two keys. In depth: [Leaving insert mode](01-basics.md#leaving-insert-mode)
- `yanky.nvim`: **Loaded at startup.** Keeps a history of yanks, highlights pasted text for 300 ms, and lets `[y` / `]y` swap a fresh paste for an earlier or later yank. `p`/`P` are yanky's paste in Normal and Visual mode. In depth: [24. Yank history (`yanky.nvim`)](03-editing.md#24-yank-history-yankynvim)
- `nvim-ufo`: **Loaded at startup.** Code folding that uses the language server's folding ranges (indentation as fallback) and shows a preview of folded lines. Keys are the standard `z` fold keys plus `<Space>K` to preview a fold. In depth: [18. Code folding (`nvim-ufo`)](07-code.md#18-code-folding-nvim-ufo)
- `promise-async`: **Loaded at startup.** A small helper library that nvim-ufo (code folding) needs for asynchronous work. Nothing to use directly. In depth: [47. Code Folding In Depth](07-code.md#47-code-folding-in-depth-nvim-ufo)
- `unicode.vim`: Unicode info (`ga`), completion of characters by name, digraph helpers. In depth: [38. URL & Unicode](09-ai-and-writing.md#38-url--unicode-gxnvim-vim-highlighturl-unicodevim)
- `gx.nvim`: `gx` opens the URL or file under the cursor (also on a Visual selection) in the browser or default program. In depth: [Open the file under cursor](03-editing.md#open-the-file-under-cursor)
- `whitespace.nvim`: **Loaded at startup.** Highlights trailing whitespace and provides `:StripTrailingWhitespace`, which `<Space><Space>` calls. Not active in Markdown, where two trailing spaces are a line break. In depth: [Miscellaneous editing](03-editing.md#miscellaneous-editing)

## Search and files

- `fzf-lua`: **Loaded at startup.** Popup fuzzy finder on top of the fzf program. Used for file search, live grep, help tags, buffer tags, buffers, recent files, git branches, keymaps (dashboard `m`) and the zoxide picker. In depth: [12. Fuzzy finding & project-wide search (`fzf-lua`)](05-search-and-files.md#12-fuzzy-finding--project-wide-search-fzf-lua)
- `telescope.nvim`: Second picker framework, loaded only on `:Telescope`. In this config it is used for the `<Space>db` buffer diagnostics list and for `:Telescope keymaps`; devdocs and telescope-symbols also use it. In depth: [Telescope (second picker)](10-various.md#telescopenvim-second-picker)
- `telescope-symbols.nvim`: Data package for telescope: adds symbol/emoji sources so `:Telescope symbols` can insert them. No key of its own in this config. In depth: [Telescope (second picker)](10-various.md#telescopenvim-second-picker)
- `nvim-tree.lua`: Sidebar file tree toggled with `<Space>s`; `<Tab>` opens a file but keeps the cursor in the tree. Has its own window picker when several windows are open. In depth: [11. File explorer (`nvim-tree`)](05-search-and-files.md#11-file-explorer-nvim-tree)
- `nvim-bqf`: Better quickfix window: item preview, marking items, fuzzy filter. The preview does not start by itself here. Only inside the quickfix window. In depth: [Inside the quickfix window (nvim-bqf, quicker.nvim)](05-search-and-files.md#inside-the-quickfix-window-nvim-bqf-quickernvim)
- `quicker.nvim`: Nicer quickfix and location list display (grouped by file). Editing the list as a buffer is switched off. In depth: [Inside the quickfix window (nvim-bqf, quicker.nvim)](05-search-and-files.md#inside-the-quickfix-window-nvim-bqf-quickernvim)
- `vim-eunuch`: Unix file commands inside Neovim: rename, move, delete, mkdir, chmod, sudo write. In depth: [File operations](05-search-and-files.md#file-operations)

## Sessions and saving

- `persistence.nvim`: Saves one session per folder (and git branch) when you quit. Never restored automatically; restore it from the dashboard items. In depth: [Session Management](06-windows-terminal-sessions.md#session-management-persistencenvim-vim-obsession)
- `vim-obsession`: **Loaded at startup.** Manual session recording with `:Obsession` into `Session.vim`; keeps updating a session started with `nvim -S Session.vim`. In depth: [Session Management](06-windows-terminal-sessions.md#session-management-persistencenvim-vim-obsession)
- `auto-save.nvim`: **Loaded at startup.** Saves a changed file when you leave the buffer or Neovim loses focus; prints "AutoSave: saved at HH:MM:SS". In depth: [Auto-Save](06-windows-terminal-sessions.md#auto-save-auto-savenvim)

## Git

### Everyday Git in the buffer

- `gitsigns.nvim`: **Loaded at startup.** Shows `+ ~ _ ‾ │` signs in the gutter for added, changed and deleted lines and gives hunk keys (jump, preview, stage, reset, blame line). In this config it is the everyday tool for staging or discarding one block of a file. In depth: [gitsigns.nvim (plugin)](08-git.md#gitsignsnvim-plugin)
- `vim-fugitive`: Runs git from inside Neovim (`:Git`, `:Gwrite`, `:Gvdiffsplit`). Here it carries most of the `<Space>g...` keys: status, add, unstage, commit, amend, stash, pull, branch, fetch; the cmdline abbreviation `git` becomes `Git`. Only inside a git repository (nvim started in one, or a file of one opened); outside one its keys do not exist. In depth: [vim-fugitive (plugin)](08-git.md#vim-fugitive-plugin)
- `gitlinker.nvim`: Builds a web URL (permalink) to the current line or visual selection on the host (GitHub, Azure DevOps via a custom callback) and can open the repository in the browser. Only inside a git repository (nvim started in one, or a file of one opened); outside one its keys do not exist. In depth: [gitlinker.nvim (plugin)](08-git.md#gitlinkernvim-plugin)

### Git interfaces and diffs

- `neogit`: A Magit-style full-screen git interface (status, stage, commit, log). Here it is opened with `<Space>gn` or `:Neogit` and uses diffview and fzf-lua as optional integrations. The key exists only inside a git repository; `:Neogit` works anywhere. In depth: [Neogit (plugin)](08-git.md#neogit-plugin)
- `diffview.nvim`: Side-by-side diff viewer for the working tree, branches and commits, plus a file-history panel and a 3-way merge tool. Here `<Space>gD` opens it and the conflict keys `<Space>gCo/gCt/gCb/gCa`, `]C`, `[C` work inside it. The key `<Space>gD` exists only inside a git repository; `:DiffviewOpen` works anywhere. In depth: [Resolving merge conflicts (diffview.nvim)](08-git.md#resolving-merge-conflicts-diffviewnvim)
- `vim-flog`: Draws the git commit graph (branches and merges) in a buffer. Here it is opened with `:Flog`; there is no key for it. Needs vim-fugitive, so open it inside a git repository. In depth: [vim-flog (plugin)](08-git.md#vim-flog-plugin)
- `diffs.nvim`: **Loaded at startup.** Adds syntax/treesitter highlighting inside the diff buffers of fugitive, neogit and gitsigns, highlights conflict markers, and provides `:Diff`. In depth: [diffs.nvim (plugin)](08-git.md#diffsnvim-plugin)
- `codediff.nvim`: VSCode-style side-by-side diff opened with `:CodeDiff`. No key is mapped. In depth: [codediff.nvim (plugin)](08-git.md#codediffnvim-plugin)

## Databases

- `vim-dadbod`: Engine behind `:DB`: runs a query against a database URL (`:DB sqlite:file select ...`, `:%DB url` for the whole buffer). It has no screen of its own; vim-dadbod-ui adds one. In depth: [SQL databases (nvim-dbee, vim-dadbod-ui)](10-various.md#sql-databases-nvim-dbee-vim-dadbod-ui)
- `vim-dadbod-ui`: Browsable connection tree, saved queries and result pane for vim-dadbod. Keys `<Space>Du` (toggle), `<Space>Da` (add connection), `<Space>Df` (find buffer). In depth: [SQL databases (nvim-dbee, vim-dadbod-ui)](10-various.md#sql-databases-nvim-dbee-vim-dadbod-ui)
- `nvim-dbee`: SQL client with drawer, editor, result and call-log windows and a Go backend. Opened with `<Space>Do` / `<Space>Dt`, closed with `<Space>Dc`. In depth: [SQL databases (nvim-dbee, vim-dadbod-ui)](10-various.md#sql-databases-nvim-dbee-vim-dadbod-ui)

## User interface

### Bars, messages and start screen

- `which-key.nvim`: **Loaded at startup.** Shows a popup of the keys that can follow what you have typed (press `<Space>` and wait). The only groups it names are the Java ones (`<Space>j...`). In depth: [Which-Key: See Available Keybindings](01-basics.md#see-available-keybindings-with-which-keynvim)
- `lualine.nvim`: **Loaded at startup.** The statusline at the bottom: file name, git branch and diff, diagnostics, active LSP, trailing-whitespace and mixed-indent warnings, progress. Clicking the branch or the LSP name opens a picker or popup. In depth: [32. Statusline (`lualine.nvim`)](06-windows-terminal-sessions.md#32-statusline-lualinenvim)
- `bufferline.nvim`: **Loaded at startup.** The top line showing one tab per open buffer (not Vim tabpages). Click to switch, click the x or the modified dot to close; qf, fugitive and git buffers are hidden from it. In depth: [Buffer Tabs (the Top Line)](06-windows-terminal-sessions.md#buffer-tabs-the-top-line-bufferlinenvim)
- `dashboard-nvim`: **Loaded at startup.** The start screen shown for a bare `nvim`, with a menu (sessions, files, keymap search, user guide, Claude help) and random ASCII art. `\h` reopens it, `\H` closes it again. In depth: [Dashboard (Start Screen)](06-windows-terminal-sessions.md#dashboard-start-screen-dashboard-nvim)
- `statuscol.nvim`: **Loaded at startup.** Builds the column left of the text: signs (git, diagnostics), line numbers and the fold column (fold levels deeper than 3 are not shown). Clicks on the three parts have their own handlers. In depth: [Line number column (`statuscol.nvim`)](06-windows-terminal-sessions.md#line-number-column-statuscolnvim)
- `nvim-notify`: **Loaded at startup.** Animated popup notifications (fade in, slide out, 1.5 s) that replace the plain message line for everything that calls vim.notify. The popup background follows the active colorscheme; `:Notifications` shows the history. In depth: [33. UI features](06-windows-terminal-sessions.md#33-ui-features)
- `snacks.nvim`: **Loaded at startup.** A toolbox of which three parts are used: nicer `vim.ui.input` popup at the cursor, the picker (used for `vim.ui.select` and some lists), and the light mode for very big files (over 1.5 MB or lines averaging over 5000 characters). In depth: [Input popups and big files (`snacks.nvim`)](06-windows-terminal-sessions.md#input-popups-and-big-files-snacksnvim)

### Visual helpers

- `vimade`: **Loaded at startup.** Dims the windows that do not have focus, to half strength without animation, so the active window stands out. In depth: [33. UI features](06-windows-terminal-sessions.md#33-ui-features)
- `nvim-colorizer.lua`: **Loaded at startup.** Paints color codes (hex, rgb and similar) in the text with the color they stand for. Plain color words are deliberately left alone. In depth: [33. UI features](06-windows-terminal-sessions.md#33-ui-features)
- `mini.indentscope`: **Loaded at startup.** Draws a thin vertical line for the indent block the cursor is in, and adds the `ii` / `ai` text objects plus `[i` / `]i` to jump to the top or bottom of the scope. In depth: [More text objects](03-editing.md#more-text-objects)
- `vim-highlighturl`: Highlights URLs in any buffer so they stand out. In depth: [38. URL & Unicode](09-ai-and-writing.md#38-url--unicode-gxnvim-vim-highlighturl-unicodevim)

### Icons and UI libraries

- `mini.icons`: **Loaded at startup.** The icon provider. It also pretends to be nvim-web-devicons for plugins that only know that one, and gives the completion menu its kind icons. In depth: [Icons and UI libraries](06-windows-terminal-sessions.md#icons-and-ui-libraries)
- `nvim-web-devicons`: Library only: file icons for plugins that ask for it (trouble.nvim, nvim-tree). mini.icons stands in for it. In depth: [Icons and UI libraries](06-windows-terminal-sessions.md#icons-and-ui-libraries)
- `nui.nvim`: Library only: popup, menu and layout building blocks used by nvim-java, nvim-dbee and ascii.nvim. Nothing to use directly. In depth: [Icons and UI libraries](06-windows-terminal-sessions.md#icons-and-ui-libraries)
- `ascii.nvim`: A library of ASCII-art pictures; the dashboard picks a random one that fits the window height. In depth: [Icons and UI libraries](06-windows-terminal-sessions.md#icons-and-ui-libraries)

## Colorschemes

- `catppuccin`: The Catppuccin theme family (mocha, macchiato, frappe, latte), the palette this repo uses everywhere. Installed but not in the random list and not configured; select it with `:colorscheme catppuccin-mocha`. On Nix the Mocha look comes from nvim-base16 instead. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `nvim-base16`: Collection of base16 themes. This is what makes the Nix startup theme: `base16-<NVIM_BASE16_THEME>`, fallback `base16-catppuccin-mocha`. Not in the random list. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `lush.nvim`: Library for writing themes in Lua; only installed because arctic needs it. No colorscheme, no commands used here. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `arctic`: Dark VS Code-like theme; one of the random startup themes on non-Nix systems. Provides `arctic`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `ashen.nvim`: Dark, muted ash-toned theme; random-list member. Provides `ashen`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `citruszest.nvim`: Vivid dark theme with citrus accents; random-list member. Provides `citruszest`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `edge`: Clean, modern dark theme; random-list member (default style, italics on). Provides `edge`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `everforest`: Green, low-contrast forest theme; random-list member (hard background, italics on). Provides `everforest`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `github-theme`: GitHub's light and dark palettes; random list loads `github_dark_default`. Also dimmed, high-contrast, colorblind and light variants. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `gruvbox-material`: Softer gruvbox variant; random-list member (hard background, original foreground, italics on). Provides `gruvbox-material`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `jellybeans.nvim`: Port of the jellybeans theme; random-list member, with several variants (hc, mono, muted, warm, light). In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `kanagawa.nvim`: Theme inspired by Hokusai's wave painting; random list loads `kanagawa-dragon`; also wave and lotus. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `kanso.nvim`: Calm, kanagawa-inspired theme; random list loads `kanso`; also ink, mist, pearl, zen. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `makurai-nvim`: Dark theme with autumn and light variants; random list loads `makurai_dark`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `material.nvim`: Material Design theme; random list loads `material` with style "darker"; also oceanic, palenight, deep-ocean, lighter. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `melange-nvim`: Warm, earthy theme; random-list member. Provides `melange`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `modus-themes.nvim`: Accessible high-contrast Modus themes; random list loads `modus`; also `modus_operandi` (light) and `modus_vivendi` (dark). In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `nightfox.nvim`: Fox theme family; random list loads `carbonfox`; also nightfox, dayfox, dawnfox, duskfox, nordfox, terafox. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `onedark.nvim`: Atom One Dark port; random list loads it via its Lua setup with style "darker". In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `onedarkpro.nvim`: Another One Dark port; random list loads `onedark_dark` (the config comment says `onedark_vivid` lacks contrast). In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `sonokai`: Monokai-pro-inspired theme; random-list member (italics on). Provides `sonokai`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
- `vague.nvim`: Minimal, low-saturation dark theme; random-list member. Provides `vague`. In depth: [Colorschemes](06-windows-terminal-sessions.md#colorschemes)

## Writing: Markdown, LaTeX, Typst

- `markdown-preview.nvim`: Live browser preview of a Markdown file; `<Alt-m>` toggles it in Markdown buffers. Only in Markdown files. In depth: [Preview (markdown-preview.nvim)](languages/markdown.md#preview-markdown-previewnvim)
- `render-markdown.nvim`: Draws headings, lists, code blocks, tables and checkboxes nicely inside the buffer; pauses in Insert mode. Only in Markdown files. In depth: [Rendering inside the buffer (render-markdown.nvim)](languages/markdown.md#rendering-inside-the-buffer-render-markdownnvim)
- `vim-markdownfootnotes`: Fast footnote insertion and jump back in Markdown files. Only in Markdown files. In depth: [Footnotes](languages/markdown.md#footnotes-vim-markdownfootnotes)
- `vimtex`: **Loaded at startup.** Full LaTeX support (compile with `latexmk`, forward and inverse search with the PDF viewer, table of contents, motions and text objects). Only loaded when `latex` is on PATH, in practice inside the LaTeX devShell. In depth: [LaTeX (vimtex, texlab, ltex, PDF viewer)](languages/latex.md#80-latex-vimtex-texlab-ltex-pdf-viewer)
- `typst.vim`: Typst syntax colours, indentation, `:TypstWatch`, `:make` and the `:Toc` outline commands for `.typ` files. Only loaded when `typst` is on PATH. In depth: [Typst (typst.vim, tinymist, watch and preview)](languages/typst.md#82-typst-typstvim-tinymist-watch-and-preview)

## AI and collaboration

- `claude-code.nvim`: **Loaded at startup.** Runs the Claude Code CLI in a side panel inside Neovim; toggle with `<Space>cc`, resume or continue older conversations. In depth: [Claude Code](09-ai-and-writing.md#claude-code-in-depth-claude-codenvim)
- `instant.nvim`: Real-time collaborative editing: start a server and a session, others join. In depth: [Collaborative Editing](06-windows-terminal-sessions.md#collaborative-editing-instantnvim)

## Plugin manager, libraries and other tools

### Plugin manager and libraries

- `lazy.nvim`: **Loaded at startup.** The plugin manager that installs, loads (lazily) and updates every other plugin. `:Lazy` opens its window; `pi`, `pud`, `pc`, `ps` are typed shortcuts. In depth: [Plugin Manager Shortcuts](10-various.md#plugin-manager-shortcuts-lazynvim)
- `plenary.nvim`: **Loaded at startup.** Lua helper library (async, paths, jobs) required by other plugins. Nothing to use directly. In depth: [Libraries and dependencies](10-various.md#libraries-and-dependencies)

### Terminal, browser and file types

- `vim-oscyank`: Copies text to the system clipboard through the terminal (OSC 52 escape sequence), so it works over SSH. No key is mapped in this config; it is used through commands. In depth: [Copying over SSH (vim-oscyank)](10-various.md#copying-over-ssh-vim-oscyank)
- `firenvim`: **Loaded at startup.** Lets Neovim edit browser text areas (needs the Firenvim browser extension). In this config takeover is manual only. In depth: [Neovim in the browser (firenvim)](10-various.md#neovim-in-the-browser-firenvim)
- `live-command.nvim`: **Loaded at startup.** Live preview of `:norm` while you type it; typing `:norm` is turned into `:Norm`. In depth: [Live preview of :norm (live-command.nvim)](10-various.md#live-preview-of-norm-live-commandnvim)
- `vim-scriptease`: Helpers for debugging Vim script and the config: `:Messages`, `:Scriptnames`, `:Verbose`. In depth: [Vim-script debugging (vim-scriptease)](10-various.md#vim-script-debugging-vim-scriptease)
- `vim-tmux`: Syntax highlighting, commenting and `K` lookup for `tmux.conf` files; loads only for the `tmux` filetype and only when tmux is installed. In depth: [Filetype syntax plugins (vim-tmux, vim-toml)](10-various.md#filetype-syntax-plugins-vim-tmux-vim-toml)
- `vim-toml`: Syntax highlighting for `.toml` files (for example `pyproject.toml`); follows the plugin's `main` branch. Only in `.toml` files. In depth: [Filetype syntax plugins (vim-tmux, vim-toml)](10-various.md#filetype-syntax-plugins-vim-tmux-vim-toml)
- `vim-xkbswitch`: Switches the keyboard layout automatically when you enter and leave Insert mode. macOS only (needs the `xkbswitch` command); declared but disabled elsewhere, so it does nothing on Linux. Unverified: it cannot be run on this machine, so this entry and its section are written from the plugin's documented purpose. In depth: [Keyboard layout switching (vim-xkbswitch)](10-various.md#keyboard-layout-switching-vim-xkbswitch)
