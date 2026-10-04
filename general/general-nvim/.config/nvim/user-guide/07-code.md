<!-- chapter: Code: LSP, running, debugging, folding, treesitter -->
[Back to the guide index](README.md)

# 13. LSP: Language Server Protocol

Plugin: nvim-lspconfig (default server definitions; Neovim's builtin `vim.lsp` does the rest). Provides IDE features. The keys below work per buffer according to what the attached servers support: if no attached server supports it, `K` and `gd` fall back to Vim's builtin versions and `<Space>rn` / `<Space>ca` show one warning.

### Configured Language Servers

| Server | Language | Program(s) that must be on PATH |
| --- | --- | --- |
| `pyright` + `ruff` | Python | `pyright-langserver`, `ruff` |
| `lua_ls` | Lua | `lua-language-server` |
| `bashls` | Bash | `bash-language-server` |
| `yamlls` | YAML | `yaml-language-server` |
| `marksman` | Markdown | `marksman` |
| `nixd` | Nix | `nixd` |
| `jdtls` | Java (via nvim-java) | `java` (Java devShell) |
| `clangd` | C/C++ | `clangd` (c-cpp devShell) |
| `ltex_plus` | Grammar and spelling (LanguageTool) for markdown, tex, plain TeX, typst, gitcommit, text | `ltex-ls-plus` |
| `typos_lsp` | Typos in identifiers and comments, every real file | `typos-lsp` |
| `tinymist` | Typst | `tinymist` |
| `texlab` | LaTeX | `texlab` (LaTeX devShell) |
| `rust_analyzer` | Rust | `rust-analyzer` AND `cargo` |
| `gopls` | Go | `gopls` AND `go` |
| `hls` | Haskell | `haskell-language-server-wrapper` |
| `sourcekit` | Swift, Objective-C | `sourcekit-lsp` |
| `ts_ls` | JavaScript / TypeScript | `typescript-language-server` (the project's `node_modules/.bin` copy is preferred) |
| `phpactor` | PHP | `phpactor` (php devShell) |
| `r_language_server` | R, Rmd, quarto | `R` plus the R package `languageserver`: the first R file runs one silent background check; restart nvim after installing the package |

A server is enabled only when ALL its programs are on PATH; otherwise it is skipped silently (no warning when you open a file of that language outside its devShell). The programs come from the Nix system or the language's devShell; nothing is downloaded by Neovim. `:LspStart <name>` tells you which program is missing.

### LSP Keymaps

| Keymap | Description |
| --- | --- |
| `gd` | **Go to definition**: jump to where the symbol is defined (several different places open the location list) |
| `K` | **Hover**: show documentation in a floating window |
| `<Space>rn` | **Rename**: rename the symbol everywhere it's used |
| `<Space>ca` | **Code action**: show available fixes/refactors |
| `<Space>fm` | **Format** the file on demand (LSP formatter, async). Lua: stylua. Markdown: prettier. Lua, Python and JSON have `<Space>f` (stylua / black / `:JSONFormat`) |

### Built-in Neovim LSP and Diagnostic Keys

Neovim's own LSP keys also work next to the custom ones (in every buffer with a server that supports them):

| Keymap | Mode | Description |
| --- | --- | --- |
| `grn` | n | Rename (same as `<Space>rn`) |
| `gra` | n, x | Code action (same as `<Space>ca`) |
| `grr` | n | References (quickfix list) |
| `gri` | n | Implementation |
| `grt` | n | Type definition |
| `grx` | n | Run the code lens of the line |
| `gO` | n | Document symbols (outline in the location list) |
| `<Ctrl-s>` | i, s | Signature help |
| `]d` / `[d` | n | Next / previous diagnostic of any severity (`<Space>de` / `<Space>dE` jump to errors only) |
| `]D` / `[D` | n | Last / first diagnostic in the buffer |
| `<Ctrl-w>d` | n | Show the diagnostics under the cursor |

### LSP Commands

| Command | What it does |
| --- | --- |
| `:LspInfo` | LSP status (same as `:checkhealth vim.lsp`) |
| `:LspAttached` | Small popup with the servers attached to this buffer (`q` / `<Esc>` closes; also opens when you click the LSP name in the statusline; with no server attached it only shows a notification) |
| `:LspLog` | Open the LSP log file |
| `:LspRestart [name...]` | Restart the servers of this buffer, or the named ones |
| `:LspStop [name...]` | Stop them |
| `:LspStart [name...]` | Start the enabled servers of this buffer that are not running, or the named ones |
| `:LspInlayHints enable` / `disable` | Switch inlay hints on / off globally (off by default) |

### Glance: Peek Without Jumping

Plugin: glance.nvim. Preview definitions/references in a popup, without leaving your current file.

| Keymap | Description |
| --- | --- |
| `<Space>gd` | Peek at definitions |
| `<Space>gr` | Peek at all references |
| `<Space>gi` | Peek at implementations |

### Diagnostics (Errors, Warnings)

Nerd Font signs in the gutter: 󰅚 (error), 󰀪 (warning), 󰋽 (info), 󰌶 (hint). No underline and no inline text: the message appears in a floating window when the cursor rests on the line (it closes when you move, leave the window or enter Insert mode).

| Keymap | Description |
| --- | --- |
| `<Space>db` | Telescope picker with the diagnostics of the current file |
| `<Space>dw` | Toggle the Trouble diagnostics list (the diagnostics of every buffer Neovim has loaded, grouped by file; see "Diagnostics In Depth") |
| `<Space>de` | Jump to next error |
| `<Space>dE` | Jump to previous error |
| `<Space>dd` | Show diagnostic detail in floating window |
| `<Space>dt` | Toggle diagnostics on/off |
| `<Space>qw` | Send the diagnostics of all open buffers to the quickfix list |
| `<Space>qb` | Send buffer diagnostics to quickfix list |

---

# 44. Language Server Protocol (LSP) In Depth

## What LSP Is

LSP is a protocol that lets Neovim communicate with language-specific servers (programs that understand your code). The server analyzes your code and provides:

- **Diagnostics**: Errors and warnings shown in the gutter and floating windows
- **Go to definition**: Jump to where a function/class/variable is defined
- **Hover**: Show documentation for the symbol under cursor
- **Rename**: Rename a symbol across the entire project
- **Code actions**: Quick fixes, auto-imports, refactorings
- **Formatting**: Auto-format your code according to language standards
- **Completion**: Suggestions as you type

## How LSP Is Managed

Each server is configured in `lua/config/lsp.lua` (plus `after/lsp/<name>.lua`) with Neovim's builtin `vim.lsp.config` / `vim.lsp.enable`. **nvim-lspconfig** only supplies the default server definitions. A server is enabled only when its program is on PATH: the programs come from the Nix system (`neovim.nix`) or from the language's devShell, nothing is downloaded by Neovim. Java (jdtls) is managed by nvim-java.

## Configured Servers and What They Provide

| Server | Language | What it provides |
| --- | --- | --- |
| **pyright** | Python | Type checking, import resolution, diagnostics. Disables import sorting (ruff handles that). |
| **ruff** | Python | Fast linting and formatting. Complementary to pyright. |
| **lua_ls** | Lua | Full Lua analysis with `vim` global recognized. Its formatting is switched off: Lua is formatted by stylua (`<Space>f` / `<Space>fm`). |
| **bashls** | Bash/Shell | Shell script analysis and diagnostics. |
| **yamlls** | YAML | Schema validation and formatting for YAML files. |
| **marksman** | Markdown | Link validation, heading completion. Formatting is done by `<Space>fm` with Prettier (not by marksman). |
| **nixd** | Nix | Nix language analysis. Formatter: nixpkgs-fmt. |
| **jdtls** | Java | Full Java IDE features via nvim-java (see Java section). Auto-configured. |
| **clangd** | C/C++ | Compilation, diagnostics, code completion for C/C++. |
| **ltex_plus** | Prose (markdown, tex, typst, gitcommit, text) | Grammar and spell checking with LanguageTool; problems are diagnostics. |
| **typos_lsp** | Every real file | Finds typos in identifiers and comments; offers fixes as code actions. |
| **tinymist** | Typst | Diagnostics, completion (PDF export is left to `:TypstWatch`). |
| **texlab** | LaTeX | Diagnostics, hover, symbols, rename. |
| **rust_analyzer** | Rust | Full Rust analysis (needs `cargo` too). |
| **gopls** | Go | Full Go analysis (needs `go` too). |
| **hls** | Haskell | Haskell language server. |
| **sourcekit** | Swift, Objective-C | Swift analysis (C/C++ stay with clangd). |
| **ts_ls** | JavaScript / TypeScript | TypeScript language server. |
| **phpactor** | PHP | PHP analysis and refactoring. |
| **r_language_server** | R | R analysis, after a one-time check that the R package `languageserver` is installed. |

Each server starts only when its program is installed (see the table in section 13); `:LspAttached` (or a click on the LSP name in the statusline) shows what is attached.

## LSP Keymaps (All Languages)

These keys work per buffer according to what the attached servers support: `K` and `gd` fall back to Vim's builtin versions when no attached server supports hover / definition; `<Space>rn` and `<Space>ca` show one warning instead ("rename: no attached language server supports it", or "... no language server attached to this buffer").

| Keymap | What it does | When to use |
| --- | --- | --- |
| `gd` | **Go to definition**. If there's only one definition, jumps directly. If multiple, opens a location list so you can pick. Deduplicates results. | When you want to see where a function/class/variable is defined. |
| `K` | **Hover documentation**. Shows docs in a floating window with a border (at most 100 x 40). | When you need to check what a function does, its parameters, return type, etc. |
| `<Space>rn` | **Rename symbol**. Renames the symbol under cursor everywhere it appears in the project. | When refactoring: changing a function name, variable name, etc. |
| `<Space>ca` | **Code action**. Shows a menu of available fixes and refactorings. | When the lightbulb icon appears, or when you want to auto-import, extract a variable, fix a lint warning, etc. |
| `<Space>fm` | **Format file**. Runs the LSP formatter asynchronously (ruff, nixd, ...); in Markdown buffers Prettier, in Lua buffers stylua. | Before committing, or whenever you want clean formatting. |

## Peeking Without Jumping (Glance)

Plugin: **glance.nvim**. Instead of jumping away to a definition (which changes your context), you can peek at it in an inline popup:

| Keymap | What it does |
| --- | --- |
| `<Space>gd` | Peek at definitions in a popup. You see the code without leaving your current file. Press `<Esc>` to close. |
| `<Space>gr` | Peek at all references. See every place in the project that uses this symbol. |
| `<Space>gi` | Peek at implementations. See how interfaces/abstract methods are implemented. |

Neovim's builtin `grn`, `gra`, `grr`, `gri`, `grt` and `gO` also work (see section 13).

**When to use Glance vs `gd`**: Use Glance when you want to quickly check something and come back. Use `gd` when you want to actually navigate to the definition and work there.

## Diagnostics In Depth

Diagnostics are the errors, warnings, and hints that the LSP server reports about your code.

**How they appear**:
- Nerd Font signs in the gutter: 󰅚 (error), 󰀪 (warning), 󰋽 (info), 󰌶 (hint)
- A floating window automatically appears after ~500ms when your cursor rests on a line with diagnostics; it closes when you move the cursor or enter insert mode
- The statusline (left side) shows the diagnostic counts with the same icons, e.g. `󰅚 1 󰀪 3`

**Navigation**:

| Keymap | What it does |
| --- | --- |
| `<Space>de` | Jump to the next **error** (skips warnings/hints) |
| `<Space>dE` | Jump to the previous **error** |
| `<Space>dd` | Manually open the diagnostic float for the current line |
| `<Space>db` | Open a Telescope picker showing all diagnostics in the current file |
| `<Space>dw` | Toggle Trouble (`:Trouble diagnostics toggle`): the diagnostics of every buffer Neovim has loaded, grouped by file, not only the current one. A file that was never opened is listed only when its language server sends project-wide diagnostics. The key's `desc` says "Workspace Diagnostics" |
| `<Space>dt` | Toggle diagnostics on/off globally (a message says which; the automatic float stays off while disabled) |

**Sending diagnostics to quickfix**:

| Keymap | What it does |
| --- | --- |
| `<Space>qw` | Put the diagnostics of all open buffers into the quickfix list |
| `<Space>qb` | Put current buffer diagnostics into the quickfix list (with none you only get "No diagnostics in this buffer") |

Then use `:cnext`/`:cprev` to jump through them one by one.

## The Lightbulb

Plugin: **nvim-lightbulb**. A lightbulb icon appears in the sign column whenever the LSP has code actions available for the current line. This is your cue to press `<Space>ca`.

The lightbulb filters out noisy ruff actions (`source.fixAll.ruff`, `source.organizeImports.ruff`) to avoid false positives.

## Editing the Neovim Config in Lua (lazydev.nvim)

Plugin: **lazydev.nvim**. When you edit a Lua file (for example this config), the Lua language server (`lua_ls`) must know the Neovim API. lazydev adds those definitions to the server's workspace, so `vim.*` gets completion, hover (`K`) and signature help instead of "undefined global" warnings. It also adds the modules you `require(...)` in the open file as you go, so only what is used is loaded.

| Item | Detail |
| --- | --- |
| Loads | Only in Lua files (lazy `ft = "lua"`); no cost elsewhere |
| Extra libraries (`lua/plugin_specs.lua`) | The luv types when the file mentions `vim.uv`; the nvim-lspconfig types when it mentions `lspconfig` (type help for `after/lsp/*.lua` files) |
| Keys | None |
| Needs | `lua_ls` attached to the buffer (see the server table above) |
| Not set up | lazydev's optional nvim-cmp source for `require("...")` module names is not configured here, so module-name completion inside `require(...)` only lists modules that are already loaded in the workspace |

How the results reach the menu: the names come from `lua_ls` through the normal LSP source (see section 45, "Completion Sources and Helpers"); it was not verified here that every lazydev-provided name shows up in the menu.

---

# 18. Code Folding (`nvim-ufo`)

Plugin: nvim-ufo. Folds code blocks using the LSP folding ranges, falling back to indentation.

| Keymap | Description |
| --- | --- |
| `za` | Toggle fold at cursor |
| `zA` | Toggle all folds under cursor recursively |
| `zc` / `zo` | Close / open fold at cursor |
| `zC` / `zO` | Close / open all folds recursively |
| `zR` | Open **all** folds in the file |
| `zM` | Close **all** folds in the file |
| `zr` | Open one more fold level (`2zr` = two levels; counted from the folds you see, so it works right after `zM`; in a buffer without ufo folds: one warning) |
| `zm` | Close one more fold level (accepts a count) |
| `<Space>K` | Preview folded lines in a popup |
| `zi` | Toggle folding feature on/off |

---

# 47. Code Folding In Depth

## What It Is

Plugin: **nvim-ufo** + **promise-async**. Code folding collapses blocks of code (functions, classes, if-blocks, etc.) into a single line to help you see the big picture.

## How It Works

nvim-ufo uses the LSP server's folding ranges to determine what can be folded, and falls back to indentation when no server provides folds.

Folded lines show a preview: the first line of the fold + a count like `󰁂 42` showing how many lines are hidden.

## Folding Keymaps

| Keymap | What it does | When to use |
| --- | --- | --- |
| `za` | Toggle the fold under cursor | Quick open/close of a single fold |
| `zR` | Open ALL folds in the file | When you want to see everything |
| `zM` | Close ALL folds in the file | When you want the bird's-eye view |
| `zr` | Open one more fold level (`{N}zr` = N levels; in a buffer without ufo folds: one warning) | Gradually reveal more detail |
| `zm` | Close one more fold level (`{N}zm` = N levels) | Step back to less detail |
| `zo` / `zc` | Open / close fold at cursor | Precise control |
| `zO` / `zC` | Open / close all nested folds at cursor | Deep open/close |
| `<Space>K` | Preview folded lines in popup | See what's inside without unfolding |
| `zi` | Toggle folding on/off globally | Temporarily disable all folding |

**Workflow tip**: Press `zM` to close all folds when you open a large file. This gives you an outline view. Then use `za` to open only the sections you care about. Use `<Space>K` to peek inside folds without opening them.

---

# 21. Treesitter & Text Objects

## Treesitter (Plugin)

Provides tree-sitter syntax highlighting (started automatically per filetype when a parser exists). On Nix systems the parsers come from the nix store and nothing is installed by Neovim; on other systems these parsers are installed automatically: cpp, diff, dockerfile, git_config, git_rebase, gitcommit, html, json, lua, python, toml, vim.

## targets.vim (Plugin)

Adds many additional text objects for quotes, brackets, arguments, separators. Works automatically with `d`, `c`, `y`, `v`. If the cursor is not inside the pair, `i(`, `i"` and friends look forward on the line.

## vim-matchup (Plugin)

Enhanced `%` matching for language keywords (`if`/`else`/`end`, `do`/`while`, etc.). Shows offscreen match in popup. Also: `g%` (backwards `%`), `[%` / `]%` (start / end of the enclosing pair), `z%` (into the next pair), text objects `i%` / `a%`. `g%` and `[%` / `]%` were tested (`g%` from `if` goes backwards to `end`). `z%` was tested in a real terminal: from `if` it moves to the closing `)` of the next pair inside the block.

---

# 46. Treesitter In Depth

## What Treesitter Is

Plugin: **nvim-treesitter**. It parses your code into a syntax tree (like an AST) and uses that for:

- **Syntax highlighting**: More accurate than regex-based highlighting. Understands the actual structure of the code.
- **Symbols**: the aerial outline (`<Space>t`) can read the symbols from the tree.

## Installed Parsers

On Nix-managed systems (a folder `/etc/nixos` or `/etc/nix` exists) the parsers come from the nix store (home-manager); Neovim installs nothing. On other systems Neovim installs this fixed set at startup: cpp, diff, dockerfile, git_config, git_rebase, gitcommit, html, json, lua, python, toml, vim. Neovim itself bundles the parsers for c, lua, vim, vimdoc, query and markdown, so those highlight everywhere. Other languages get no tree-sitter highlighting there until you run `:TSInstall <lang>`. Tested on a simulated non-nix system: each of the 12 grammars is downloaded, but the install needs the `tree-sitter` command and a C compiler (`gcc`/`cc`); without the `tree-sitter` command every grammar fails with `Error during "tree-sitter build": ... ENOENT ... 'tree-sitter'` and nothing is installed (the error lines appear again at every start). So on a non-nix machine install `tree-sitter` (the CLI) and a C compiler first.

---

# 19. Code Running

Custom function in `lua/mappings.lua`. Opens the output in a vertical split terminal on the left. If the file has no name (the buffer was never saved), the filetype has no runner, or the needed program is not on PATH, you get one warning (naming the devShell to start nvim in) instead of a terminal. A named buffer with unsaved changes runs the version on disk, so save first (`:w`).

| Keymap | Description |
| --- | --- |
| `<Space>rr` | Run current file (auto-detects language) |

Supported: Python, Java, C, C++, C#, JavaScript, TypeScript, Go, Rust, Bash, Lua, Ruby, PHP. Special cases: Java with jdtls attached runs `:JavaRunnerRunMain` (nvim-java's own runner split at the bottom, not the `<Space>rr` terminal on the left); Rust inside a cargo project runs `cargo run`; C# with a `.csproj` runs `dotnet run --project`; Go runs `go run .` for the whole package.

After running, the terminal output appears in a split. See [Terminal Integration](06-windows-terminal-sessions.md#8-terminal-integration) for how to navigate to/from it and close it.

### Filetype-Specific

| Keymap | Filetype | Description |
| --- | --- | --- |
| `<Space>rf` / `<F9>` | Python | Run with `python -u` via AsyncRun (`uv run python -u` inside a uv project) |
| `<Space>rf` / `<F9>` | C++ | Compile (clang++, else g++, C++20) and run in a split below; only mapped when a compiler is on PATH |
| `<Space>rf` / `<F9>` | LaTeX | Compile with vimtex |
| `<Space>rf` / `<F9>` | Lua | Run the file inside Neovim (`:luafile %`) |
| `<Space>rf` / `<F9>` | Vim script | Source the file (`:source %`) |

---

# 55. Code Running In Depth

## The Universal Runner

The `<Space>rr` keymap detects the current filetype and runs the appropriate command in a **vertical split terminal** on the left. If the file is unsaved, the filetype has no runner, or the compiler/interpreter is not on PATH, you get ONE warning and no terminal opens (the message names the devShell to start nvim in).

**How it works**:
1. Detects the filetype of the current buffer
2. Builds the correct command (e.g., `python3 file.py`, `go run .`)
3. Opens a vertical split
4. Starts a terminal in that split running the command
5. Output appears in real-time

**After running**:
- The terminal window opens on the LEFT of your code
- Press `<Esc>` in the terminal to enter Normal mode
- Navigate back to your code with `<Ctrl-w>l` or `<Right>`
- Close the terminal window with `<Space>q`, or delete its buffer with `\d`
- Run again with `<Space>rr` (it opens a new terminal each time)

## Language-Specific Details

| Language | Command used | Notes |
| --- | --- | --- |
| Python | `python3 <file>` | |
| Java | `:JavaRunnerRunMain` when jdtls (nvim-java) is attached; otherwise `java <file>` | With jdtls nvim-java opens its own runner split at the bottom (not the `<Space>rr` terminal on the left) |
| C | `gcc -Wall -Wextra -std=c11 <file> -o <binary> && <binary>` | Compiles and runs; the binary sits next to the source; needs gcc (c-cpp devShell) |
| C++ | `g++ -Wall -Wextra -std=c++20 <file> -o <binary> && <binary>` | Compiles and runs; needs g++ (c-cpp devShell) |
| C# | `dotnet run --project <nearest .csproj>` | Without a project file: `dotnet run <file>` |
| JavaScript | `node <file>` | |
| TypeScript | `node <file>` | Node runs `.ts` directly |
| Go | `go run .` in the file's directory | Runs the whole package |
| Rust | `cargo run` when a `Cargo.toml` is above the file | Otherwise `rustc <file>` and runs the binary |
| Bash | `bash <file>` | |
| Lua | `nvim -l <file>` | Neovim's own LuaJIT |
| Ruby | `ruby <file>` | |
| PHP | `php <file>` | |

## Filetype-Specific Runners

Some filetypes have an additional `<Space>rf` runner (also `<F9>`):

| Filetype | What `<Space>rf` / `<F9>` does |
| --- | --- |
| Python | Runs with `python -u <file>` via AsyncRun (unbuffered output; `uv run python -u` in a uv project) |
| C++ | Compiles with `clang++` (else `g++`) `-Wall -Wextra -std=c++20 -O2` and runs it in a horizontal split; only mapped when a compiler is on PATH |
| LaTeX | vimtex compile; only when `latex` is on PATH |

---

# 36. Debugging

| Plugin | Keymap / Command | Description |
| --- | --- | --- |
| nvim-dap | (lazy-loaded) | Debug Adapter Protocol client. Java debugging auto-configured via nvim-java. |
| nvim-gdb | `<Space>dp` | Python buffers only: start pdb on the current file (Linux/Windows only; elsewhere one warning); during the session `<Space>dc` `dn` `ds` `df` `dB` `du` `dv` step and inspect (table in section 2). `:GdbStart` (gdb) works inside the c-cpp / rust devShells |

---

# 56. Debugging In Depth

## Debug Adapter Protocol (DAP)

Plugin: **nvim-dap**. DAP is a standardized protocol (created by Microsoft) for communication between an editor and a debugger. It's the same protocol used by VS Code.

**Java**: Debugging is auto-configured via nvim-java (only inside the Java devShell, where `java` is on PATH). Open a Java file, set breakpoints, and use `<Space>jtC` (debug the current test class) or `<Space>jtM` (debug the current test method).

**Python**: In Python buffers `<Space>dp` starts `python -m pdb` on the current file through nvim-gdb. Only available on Linux/Windows. During the session use `<Space>dc` (continue), `dn` (next), `ds` (step), `df` (finish), `dB` (breakpoint), `du` (until) and `dv` (evaluate); the full table is in section 2 ("Python debugger keys").

## GDB Integration

Plugin: **nvim-gdb**. A visual front end for GDB, LLDB, pdb and a few other debuggers: it starts the debugger in a terminal pane under your code and marks the current line in the source window. Available on Linux and Windows only (disabled on macOS). It loads the first time one of the start commands below runs.

| Command | Effect |
| --- | --- |
| `:GdbStart gdb -q ./a.out` | Start GDB on a program (you give the whole gdb command line) |
| `:GdbStartLLDB lldb ./a.out` | The same with LLDB |
| `:GdbStartPDB python -m pdb file.py` | Python's pdb (in Python buffers `<Space>dp` runs this for the current file) |
| `:GdbStartBashDB bashdb script.sh` | bashdb for shell scripts |
| `:GdbStartRR` | Replay a recording made with `rr` |

The command forms are the plugin's documented usage (its README); the pdb one is what `<Space>dp` runs, the others were not run for this guide.

The plugin's own start keys (`<Space>dd`, `dl`, `dp`, `db`, `dr`) are switched off in `lua/plugin_specs.lua` so they do not replace the diagnostic keys; `<Space>dp` is a Python-buffer key defined in `after/ftplugin/python.lua`. During a session the plugin sets these keys in the source window (buffer-local, removed again when the session ends):

| Key | Command | Effect |
| --- | --- | --- |
| `<F8>` | `:GdbBreakpointToggle` | Toggle a breakpoint on the cursor line |
| `<F5>` | `:GdbContinue` | Continue |
| `<F10>` | `:GdbNext` | Step over |
| `<F11>` | `:GdbStep` | Step into |
| `<F12>` | `:GdbFinish` | Step out of the current frame |
| `<F4>` | `:GdbUntil` | Run until the cursor line |
| `<Ctrl-p>` / `<Ctrl-n>` | `:GdbFrameUp` / `:GdbFrameDown` | Move one stack frame up / down (plugin default) |
| `<Space>dv` | (evaluate) | Evaluate the word under the cursor (Normal) or the selection (Visual); moved here from the plugin's `<F9>` |

Two commands without a key: `:GdbCreateWatch <command>` (for example `info locals` in GDB) opens a watch window that re-runs the command at every step, and `:GdbLopenBacktrace` / `:GdbLopenBreakpoints` put the backtrace / breakpoints into the location list. The Python-only Space keys for the same actions (`<Space>dc`, `dn`, `ds`, `df`, `dB`, `du`) are in the Python guide ("Debugging with pdb"). The F-keys, `<Ctrl-p>` / `<Ctrl-n>` and the commands are the plugin's defaults from its README and help (`:help nvimgdb`). They are untested here beyond what the Python guide documents for pdb.

---

# 43. How the Development Toolchain Fits Together

When you open a code file in Neovim, several systems activate automatically behind the scenes:

```
You open a file
  |
  v
Treesitter parses the syntax tree --> accurate highlighting (plus symbols for the aerial outline)
  |
  v
LSP server starts (e.g., pyright for Python) --> diagnostics, go-to-definition, hover, rename, code actions
  |
  v
Completion engine (nvim-cmp) connects to LSP --> autocomplete suggestions as you type
  |
  v
Gitsigns reads git status --> change markers in gutter
  |
  v
Lightbulb watches LSP --> shows icon when code actions are available
  |
  v
Diagnostics config --> errors/warnings appear as Nerd Font signs, a float opens on CursorHold
```

You don't need to start any of this manually. It all happens on file open.

---

# 53. Documentation Lookup

## DevDocs (Plugin)

Plugin: **nvim-devdocs**. Browse programming documentation without leaving Neovim.

| Command | What it does |
| --- | --- |
| `:DevdocsOpen` | Open the documentation in a normal buffer (current window) |
| `:DevdocsOpenFloat` | Open in floating window (25 lines tall, 100 chars wide) |
| `:DevdocsInstall` | Install documentation for a language (e.g., `:DevdocsInstall python`) |
| `:DevdocsUninstall` | Remove installed docs |
| `:DevdocsFetch` | Download the list of available documentation sets (the registry); if another command says the registry is not found, run this first |
| `:DevdocsOpenCurrent` | Open the documentation for the current file's filetype in a normal buffer |
| `:DevdocsOpenCurrentFloat` | The same in a floating window |
| `:DevdocsToggle` | Show or hide the floating documentation window |
| `:DevdocsKeywordprg <word>` | Look a word up in the documentation set that is currently open (needs the word as argument; the plugin sets it as `keywordprg` in its documentation buffers, so `K` there uses it) |
| `:DevdocsUpdate [name]` / `:DevdocsUpdateAll` | Update one / all installed documentation sets |

The plugin loads only when you run one of these commands. Without an argument, `:DevdocsOpen`, `:DevdocsInstall` and the others use a Telescope picker. Installing builds the documentation synchronously (large sets can block input for a while) and needs the network; `:DevdocsFetch`, `:DevdocsInstall` and the updates download, reading an installed set is local. The command descriptions follow the plugin's README (not run for this guide). No keys are mapped; the plugin's own "open in browser" key is disabled in `lua/config/devdocs.lua`.

## Hover Documentation (LSP)

Press `K` on any symbol to see its documentation in a floating window. This pulls from:
- Function signatures and return types
- Docstrings / JSDoc / Javadoc
- Type information

---

# 59. Useful Developer Commands

| Command | What it does |
| --- | --- |
| `:LspInfo` | LSP status (runs `:checkhealth vim.lsp`) |
| `:Lazy` | Open plugin manager |
| `:Lazy update` | Update all plugins |
| `:JSONFormat` | Format JSON (works on visual selection too) |
| `:ToPDF` | Convert markdown to PDF via pandoc |
| `:Redir <cmd>` | Capture any Neovim command output (e.g., `:Redir messages`) |
| `:Telescope keymaps` | Browse all defined keymaps |
| `:checkhealth` | Diagnose Neovim installation issues |
| `:Flog` | Git log graph |
| `:DiffviewOpen` | Side-by-side diff view |
| `:Neogit` | Full git UI |
| `:DevdocsOpen` | Browse programming documentation |
| `:YankyRingHistory` | Browse yank history |
| `:LspAttached` | Popup with the LSP servers attached to this buffer |
| `:LspLog` | Open the LSP log |
| `<Space>u` | Toggle the undo tree (the `:Undotree` command exists only after the first `<Space>u`) |
| `:AerialToggle!` | Toggle the symbol outline (`<Space>t`) |
| `:Dashboard` | Open the start screen |
| `:CodeDiff` | VSCode-style side-by-side diff |
| `:DBUI` / `:Dbee` | SQL clients |

---
---

# Part III: Everyday Scenarios & Recipes

Practical, step-by-step walkthroughs for common tasks.

---

# 75. Real-World Developer Workflows

Step-by-step walkthroughs of common developer tasks entirely within Neovim.

## Workflow: Investigating a Bug

1. `<Space>fg` -- search for the error message text across the project
2. `<Enter>` on the relevant result -- jumps to the file and line
3. `gd` -- go to the definition of the function that causes the error
4. `K` -- read the function's documentation
5. `<Space>gr` -- see everywhere this function is called (glance references)
6. `<Ctrl-o>` -- jump back to where you were
7. `<Space>hb` -- check git blame: who changed this and when
8. `]c` / `[c` -- navigate to nearby git changes (hunks)
9. `<Space>hp` -- preview what the hunk changed
10. Fix the issue, `<Space>w` to save, `<Space>rr` to run and test

## Workflow: Code Review (Reviewing Your Own Changes)

1. `<Space>gs` -- open git status
2. Navigate to a changed file, press `<Enter>` to open it
3. `]c` -- jump to the first changed hunk
4. `<Space>hp` -- preview the change
5. `]c` -- next change, repeat
6. `:DiffviewOpen` -- for a full side-by-side diff of all changes
7. When satisfied: `<Space>gw` to stage, `<Space>gc` to commit

## Workflow: Refactoring a Function Name Across the Project

**If it's a code symbol (function, class, variable):**

1. Place cursor on the name
2. `<Space>rn` -- LSP rename, type new name, Enter
3. Done. All references updated intelligently.

**If it's arbitrary text (e.g., a string, API path, config key):**

1. `<Space>fg` -- search for it first, verify all the places it appears
2. `:grep "oldText"` -- populate the quickfix list
3. `:copen` -- review the matches
4. `:cfdo %s/oldText/newText/gc | update` -- replace with confirmation (`y`/`n` each) and save all files

## Workflow: Adding a Feature in a New Branch

1. `<Space>gbn` -- create a new branch (type name, Enter)
2. `<Space>s` -- open file tree, navigate to where you'll add files
3. `a` in the tree -- create a new file
4. Write code; `<Space>fm` to format; `<Space>rr` to run/test
5. `<Space>de` -- jump through any errors
6. `<Space>ca` -- apply code action fixes
7. `<Space>gw` -- stage the file
8. `<Space>gc` -- commit
9. `<Space>gpu` -- push

## Workflow: Quickly Editing a Config File

1. `<Space>ff` -- fuzzy find the config file by name
2. Make your changes
3. `<Space>w` -- save
4. If it's the Neovim config: `<Space>sv` to restart Neovim (writes all buffers, restores windows/tabs/files; terminals such as Claude Code are not restarted)

## Workflow: Working with JSON

1. Open the JSON file
2. If it's messy: `:JSONFormat` to pretty-print it
3. `<Space>fg` in another terminal to find references to JSON keys
4. `za` to fold/unfold sections for readability
5. `ci"` to change a value inside quotes
6. `<Space>w` to save

## Workflow: Writing Documentation (Markdown)

1. Open the `.md` file
2. `<Alt-m>` -- live preview in browser
3. Write content; wrapping is auto-enabled for markdown
4. `^^` -- add a footnote
5. `+` (operator) -- convert lines to a bulleted list
6. `:Tabularize /|` -- align a markdown table
7. `:AddRef label url` -- add a reference link
8. `<Space>cz` -- toggle spell check
9. `]s` / `[s` -- navigate misspelled words
10. `z=` -- fix spelling

## Workflow: Pair Programming with Split Views

1. `:vs <file>` -- open another file side-by-side
2. `<Ctrl-w>l` / `<Ctrl-w>h` -- switch between the two files
3. `van` in file A -- select the surrounding syntax node; repeat `an` to grow the selection (for example to the whole function), `in` shrinks it again; then `y` to copy
4. `<Ctrl-w>l` -- switch to file B
5. `p` -- paste the function
6. `<Ctrl-w>=` -- equalize window sizes if they got uneven
7. `<Ctrl-w>o` -- when done, close all splits except current

---

# 35. Java Development (`nvim-java`)

The Java keys work only in a Java buffer with the Java language server (jdtls) attached: open nvim inside the Java devShell (`java` on PATH). Everywhere else the same keys show one warning "Java: jdtls not attached (open nvim inside the Java devShell)". which-key groups: `<Space>j` Java, `jb` build, `jr` runner, `jt` test, `je` extract.

### Build & Run

| Keymap | Description |
| --- | --- |
| `<Space>jbb` | Build workspace |
| `<Space>jbc` | Clean workspace |
| `<Space>jrr` | Run main class |
| `<Space>jrs` | Stop running main |
| `<Space>jrl` | Toggle runner log window |
| `<Space>jrp` | Profiles UI |

### Testing

| Keymap | Description |
| --- | --- |
| `<Space>jtc` | Run all tests in current class |
| `<Space>jtC` | Debug all tests in current class |
| `<Space>jtm` | Run test method under cursor |
| `<Space>jtM` | Debug test method under cursor |
| `<Space>jtr` | View last test report |

### Refactoring

| Keymap | Description |
| --- | --- |
| `<Space>jev` | Extract variable |
| `<Space>jeo` | Extract variable (all occurrences) |
| `<Space>jec` | Extract constant |
| `<Space>jem` | Extract method |
| `<Space>jef` | Extract field |
| `<Space>jj` | Change JDK runtime |
| `<Space>jd` | Configure debugger (DAP) |

---

# 54. Java Development In Depth

Plugin: **nvim-java**.

This is the most feature-rich language setup in this config. It provides a full Java IDE experience. nvim-java loads when you open the first Java file of the session (not at startup), so opening a Java file takes a moment longer the first time; non-Java sessions do not pay for it.

## How It Works

nvim-java wraps the Eclipse JDT Language Server (jdtls) and adds:
- Build system integration
- Test runner and debugger
- Spring Boot tools
- Refactoring commands
- DAP (Debug Adapter Protocol) for step-through debugging

All of this only starts inside the Java devShell (`java` on PATH). Elsewhere `.java` files open without Java tooling, and the `<Space>j` keys show one warning "Java: jdtls not attached (open nvim inside the Java devShell)".

On Nix systems the JDK comes from the Java devShell (`JAVA_HOME`) and nvim-java never downloads one. On other systems nvim-java auto-installs a JDK.

## Build & Run

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jbb` | `:JavaBuildBuildWorkspace` | Compile the entire workspace |
| `<Space>jbc` | `:JavaBuildCleanWorkspace` | Clear the jdtls workspace cache (after a Yes/No question; jdtls is restarted automatically) |
| `<Space>jrr` | `:JavaRunnerRunMain` | Run the main class |
| `<Space>jrs` | `:JavaRunnerStopMain` | Stop the running program |
| `<Space>jrl` | `:JavaRunnerToggleLogs` | Show/hide the runner log window (it opens as a full-width, 15-line split at the bottom) |
| `<Space>jrp` | `:JavaProfile` | Profiles UI |

## Testing

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jtc` | `:JavaTestRunCurrentClass` | Run all `@Test` methods in the current class |
| `<Space>jtC` | `:JavaTestDebugCurrentClass` | Debug all tests (with breakpoints) |
| `<Space>jtm` | `:JavaTestRunCurrentMethod` | Run only the test method under cursor |
| `<Space>jtM` | `:JavaTestDebugCurrentMethod` | Debug only the test under cursor |
| `<Space>jtr` | `:JavaTestViewLastReport` | Show pass/fail results from the last test run |

## Debugging

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jd` | `:JavaDapConfig` | Configure the debug adapter (auto-runs on Java file open, but can be re-triggered) |

DAP is configured automatically when jdtls starts. Debugging uses the nvim-dap commands (`:DapToggleBreakpoint`, `:DapContinue`, `:DapStepOver`, `:DapStepInto`, `:DapStepOut`, `:DapTerminate`); this config has no keys for them.

## Refactoring

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jev` | `:JavaRefactorExtractVariable` | Extract the expression under the cursor (or selection) to a local variable |
| `<Space>jeo` | `:JavaRefactorExtractVariableAllOccurrence` | Extract and replace ALL occurrences of the expression |
| `<Space>jec` | `:JavaRefactorExtractConstant` | Extract a constant |
| `<Space>jem` | `:JavaRefactorExtractMethod` | Extract a method |
| `<Space>jef` | `:JavaRefactorExtractField` | Extract a field |
| `<Space>jj` | `:JavaSettingsChangeRuntime` | Switch the JDK version |

Only the `:JavaBuild*` and `:JavaRefactor*` commands exist after jdtls has attached; the other `:Java*` commands exist as soon as nvim-java is loaded but do nothing useful without jdtls.

---
