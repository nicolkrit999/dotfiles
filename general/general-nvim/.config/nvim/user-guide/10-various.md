<!-- chapter: Various: custom commands, other plugins, configuration, Neovide -->
[Back to the guide index](README.md)

# 34. Custom commands

| Command | Description |
| --- | --- |
| `:CopyPath nameonly` | Copy filename to clipboard |
| `:CopyPath relative` | Copy `<project-root>/path/to/file` (root = nearest `.git` or `pyproject.toml`; a warning when there is none) |
| `:CopyPath absolute` | Copy absolute path |
| `:JSONFormat` | Pretty-print JSON through Python (whole file or visual range; no key; `<Space>fm` formats JSON with prettier) |
| `:Redir <cmd>` | Run the command and show its output in a new tab (scratch buffer, wiped when closed) |
| `:Edit <pattern>...` | Open every file matching the glob patterns (`:Edit src/*.lua`); `:edit` typed as the first word expands to `:Edit` |
| `:Datetime [format]` | Show date and time (optional format argument) |
| `:ToPDF` | Convert markdown to PDF (requires pandoc) |
| `:Z {keywords}` | zoxide jump (see [Working with directories](05-search-and-files.md#30-working-with-directories)) |
| `:TermHL` | Show the current buffer (e.g. a log with ANSI colour codes) rendered with its colours in a read-only terminal buffer |
| `:LogAutocmds` | Toggle logging of all autocommand events to `~/.local/state/nvim/log-autocmds.log` (the file is emptied each time logging starts) |
| `:StripTrailingWhitespace` | Remove trailing whitespace (same as `<Space><Space>`) |
| `:Notifications` | Show the notification history (nvim-notify) |
| `:Inspect` / `:InspectTree` | Show the highlight groups / the Treesitter tree at the cursor |

Examples (in the file `lua/mappings.lua` of a git repository at `/tmp/demo`):

| Command | Result |
| --- | --- |
| `:CopyPath nameonly` | The clipboard (register `+`) holds `mappings.lua`; Neovim prints "Filepath copied to clipboard!" |
| `:CopyPath relative` | `<project-root>/lua/mappings.lua` |
| `:CopyPath absolute` | `/tmp/demo/lua/mappings.lua` |
| `:Datetime` | Prints the date and time, for example `2026-10-05 10:57:32+0200` |
| `:Edit lua/*.lua` | With `lua/mappings.lua`, `lua/x.lua` and `lua/y.lua` on disk, all three are in the buffer list (the last one, `lua/y.lua`, is shown) |
| `:Redir echo 1` | A new tab opens with a scratch buffer that contains the output (`1`); the buffer is wiped when the tab is closed |

### Plugin manager shortcuts (lazy.nvim)

Type these in command mode, then press space (or Enter) to expand:

| Shortcut | Expands to |
| --- | --- |
| `pi` | `:Lazy install` |
| `pud` | `:Lazy update` |
| `pc` | `:Lazy clean` |
| `ps` | `:Lazy sync` |

---

# 39. Other plugins

| Plugin | Trigger | Description |
| --- | --- | --- |
| `auto-save.nvim` | Automatic (active from right after the first screen) | Saves on `FocusLost` / `BufLeave` (a small nvim-notify popup "AutoSave: saved at HH:MM:SS"); never formats; never saves unnamed, read-only or special buffers, nor Typst and LaTeX files |
| `better-escape.vim` | `jk` (insert) | Fast escape from insert mode (200ms window) |
| `vim-repeat` | `.` | Makes plugin actions repeatable with `.` |
| `vim-swap` | `gs` (n, x) | Interactively swap function arguments / list items |
| `vim-eunuch` | `:Rename`, `:Delete` | Unix file operations |
| `vim-obsession` | `:Obsession` | Session save/restore |
| `instant.nvim` | `:InstantStartServer`, `:InstantStartSession {host} {port}`, `:InstantJoinSession {host} {port}` | Collaborative editing (loads on its first `:Instant...` command) |
| `firenvim` | Browser | Neovim in browser text areas |
| `aerial.nvim` | `<Space>t` | Symbol outline ([section 37](02-navigation.md#37-symbol-outline-aerialnvim)) |
| `treesj` | `gS` | Split / join code blocks |
| `vim-illuminate` | `<Alt-n>`, `<Alt-p>`, `<Alt-i>` | Word references: `<Alt-n>` / `<Alt-p>` jump to the next / previous one, `<Alt-i>` selects the reference (Visual and operator-pending mode) |
| `vimade` | Automatic | Dims inactive windows |
| `persistence.nvim` | Dashboard `r` / `L` | Saves a session per folder when you quit (see [Session Management](06-windows-terminal-sessions.md#session-management-persistencenvim-vim-obsession)) |
| `snacks.nvim` | Automatic | Nicer input / select popups; light mode for big files |
| `colorful-menu.nvim` | Automatic | Completion labels coloured like code |
| `live-command.nvim` | `:norm` | Live preview of `:norm` while you type |
| `lazydev.nvim` | Lua files | Neovim API completion when editing the config |
| `vim-oscyank` | `:OSCYank {text}`, `:OSCYankVisual`, `:OSCYankRegister` | Copy to the system clipboard through the terminal (works over SSH; Linux). `:OSCYank` needs the text as an argument; in Visual mode use `:OSCYankVisual`, for a register `:OSCYankRegister {reg}` |
| `vim-scriptease` | `:Messages`, `:Scriptnames`, `:Verbose {command}` | Vim-script debugging helpers |
| `nvim-dbee`, `vim-dadbod-ui` | `<Space>D...` | SQL clients (see below) |

## telescope.nvim (second picker)

Plugins: **telescope.nvim** and **telescope-symbols.nvim**. Telescope is a second popup picker next to fzf-lua (the file, grep and buffer pickers are fzf-lua, see [`05-search-and-files.md`](05-search-and-files.md#12-fuzzy-finding--project-wide-search-fzf-lua)). It is lazy: it loads only on its first `:Telescope` command, so nothing starts at launch. nvim-devdocs lists it as a dependency too.

| Command / key | Effect |
| --- | --- |
| `<Space>db` | Telescope list of the diagnostics of the current buffer (the config calls `telescope.builtin.diagnostics` for this buffer only) |
| `:Telescope keymaps` | Searchable list of all keymaps |
| `:Telescope symbols` | Pick a symbol from a list and insert it at the cursor (emoji, kaomoji, gitmoji, math, latex, julia, nerd font glyphs) |

telescope-symbols.nvim has no command, key or setup of its own; it only ships the symbol lists (JSON files) that the built-in `:Telescope symbols` picker reads from the runtime path. Lazy.nvim loads it together with Telescope. The keys inside the picker (and the ways Telescope differs from fzf-lua) are in "[Moving Inside Any Picker](05-search-and-files.md#moving-inside-any-picker-lists-with-a-search-bar)" in `05-search-and-files.md`. `:Telescope symbols` was read from the plugin code, not tried.

## Copying over SSH (vim-oscyank)

Plugin: **vim-oscyank** (enabled on Linux only; loaded on its first command). It wraps text in an OSC 52 escape sequence and writes it to the terminal, which then puts it into the system clipboard of the machine you sit at, also when Neovim runs on another machine over SSH. Your terminal (and tmux, if used) must allow OSC 52 clipboard writes. This configuration maps no key for it.

| Command | Effect |
| --- | --- |
| `:OSCYank {text}` | Copy the given text (the argument is required) |
| `:OSCYankVisual` | Copy the Visual selection (run it from Visual mode) |
| `:OSCYankRegister {reg}` | Copy the content of a register |

Example (inside tmux with `set-clipboard on` and `allow-passthrough on`): `:OSCYank hello` shows `[oscyank] 5 characters copied` and the text `hello` arrives in the terminal's clipboard (in tmux it appeared in tmux's own paste buffer). Pasting on the local machine then gives `hello`.

## Keyboard layout switching (vim-xkbswitch)

Plugin: **vim-xkbswitch** (`lyokha/vim-xkbswitch`). It switches the keyboard layout automatically when you enter and leave Insert mode, so that Normal-mode keys keep working while you type text in another layout (for example a non-Latin one).

- **Only on macOS**, and only when the `xkbswitch` command is found on `PATH`. On Linux and Windows it is declared but disabled: it is not installed and does nothing.
- It loads on the first `InsertEnter` and the config only turns it on (`XkbSwitchEnabled = 1`); there are no keys and no commands of our own.
- **Unverified:** this plugin is declared in the config but not installed or run on this Linux machine, so nothing in this section was tested. It is written as a best effort from the plugin's documented purpose and the spec in `lua/plugin_specs.lua`.

## Neovim in the browser (firenvim)

Plugin: **firenvim**. With the Firenvim browser extension installed, a browser text area can be edited in a Neovim window. The config applies the following only when Neovim was started by Firenvim:

| Setting | Value |
| --- | --- |
| Which fields | `textarea` elements only |
| Takeover | `never`: Firenvim does not open by itself; you start it from the extension |
| Command line | Neovim's own (`cmdline: neovim`) |
| Filetype | Buffers from `github.com` and `stackoverflow.com` are Markdown, `sqlzoo*` buffers are SQL |
| Look | No sign column, ruler, command display, statusline or tabline in the browser window; lualine and bufferline are not loaded there |

The plugin build (`:Lazy build firenvim`) installs the native part for the browser, using the `PATH` of the running Neovim. The browser-side button or shortcut for a manual takeover belongs to the extension, not to this config.

## Live preview of :norm (live-command.nvim)

Plugin: **live-command.nvim**. When `norm` is typed as an Ex command (at the start of the command line, after a range, after `|`, after `:g/pattern/` or `:v/pattern/`, or after a command modifier such as `:silent!`), a command-line abbreviation turns it into `:Norm`. `:Norm` behaves like `:norm` but shows the effect in the buffer, with the changed text highlighted inline, while you are still typing. The word `norm` inside a pattern, a string or other text is left alone.

| You type | Effect |
| --- | --- |
| `:%norm Atext` | Preview of appending `text` to every line; `<Enter>` runs it, `<Esc>` leaves the buffer unchanged |
| `:g/<pattern>/norm dd` | The preview also works after `:g/.../` and `:v/.../` |
| `:silent! norm ...` | The preview also works after command modifiers |

Example (in a terminal): with the three lines `a` / `b` / `c`, typing `:%norm Atext` (without `<Enter>`) turns the buffer into `atext` / `btext` / `ctext` while you type, and the command line shows `:%Norm Atext`. `<Enter>` keeps the result, `<Esc>` restores `a` / `b` / `c`. The other rows of the table are standard `:norm` uses.

## Vim-script debugging (vim-scriptease)

Plugin: **vim-scriptease**. Loaded on the first use of one of its three commands (the lazy list names `:Scriptnames`, `:Messages`, `:Verbose`). The plugin has more commands; only these three are loaded on demand here.

| Command | Effect (from the plugin's help) |
| --- | --- |
| `:Messages` | Load the output of `:messages` into the quickfix list; `:Messages clear` clears the messages. Not the same as the built-in lower-case `:messages` |
| `:Scriptnames` | Load the list of `:scriptnames` into the quickfix list and open it |
| `:Verbose {command}` | Like `:verbose {command}`, but the output goes to a file and is shown in the preview window (handy for noisy commands; a count in front raises the verbosity) |

## Libraries and dependencies

These plugins have no commands or keys. Other plugins need them, and lazy.nvim loads them when one of those plugins starts or asks for them.

| Plugin | What it is | Needed by (in this configuration) |
| --- | --- | --- |
| plenary.nvim | Lua helper library (async, paths, jobs) | claude-code.nvim, neogit, nvim-devdocs and Telescope |
| promise-async | Promise and async library | nvim-ufo (code folding) |
| lush.nvim | Library for writing colour themes in Lua | the arctic colorscheme (see "[Colorschemes](06-windows-terminal-sessions.md#colorschemes)" in `06-windows-terminal-sessions.md`) |
| nui.nvim | Popup, menu and layout building blocks | nvim-java, nvim-dbee, ascii.nvim (see "[Icons and UI libraries](06-windows-terminal-sessions.md#icons-and-ui-libraries)" in `06-windows-terminal-sessions.md`) |
| nvim-web-devicons, mini.icons | File and kind icons | see "[Icons and UI libraries](06-windows-terminal-sessions.md#icons-and-ui-libraries)" in `06-windows-terminal-sessions.md` |

## SQL databases (nvim-dbee, vim-dadbod-ui)

Two independent SQL clients. Neither has connections by default: this repo is public, so connections are never stored in the config.

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>Dt` | n | Dbee: toggle the UI |
| `<Space>Do` | n | Dbee: open the UI |
| `<Space>Dc` | n | Dbee: close the UI |
| `<Space>Du` | n | Dadbod: toggle the UI (connections, saved queries, results) |
| `<Space>Da` | n | Dadbod: add a connection |
| `<Space>Df` | n | Dadbod: find the DB buffer |

Commands: `:Dbee`, `:DB <url> <query>` (`:%DB <url>` runs the whole buffer as a query), `:DBUI`, `:DBUIToggle`, `:DBUIAddConnection`, `:DBUIFindBuffer`.

Connections come from the environment (set them in an untracked shell file, direnv or sops, never in the repo):
- nvim-dbee: `$DBEE_CONNECTIONS`, a JSON array such as `[{"name":"local","type":"postgres","url":"postgres://user:pw@localhost:5432/db"}]`. Connections added inside the UI are not saved.
- vim-dadbod-ui: `$DADBOD_CONNECTIONS`, a JSON object `{"name":"url"}`. Saved queries go to `~/.local/share/nvim/db_ui`.

`:checkhealth` shows a known, accepted `vim.validate{}` deprecation warning from nvim-dbee. Connections come from the environment, never from the config: `$DBEE_CONNECTIONS` (JSON list, dbee) and `$DADBOD_CONNECTIONS` (JSON object name -> URL, dadbod), for example `export DBEE_CONNECTIONS='[{"name":"test","type":"sqlite","url":"/path/test.sqlite"}]'`. Keys:

| Where | Keys | What it does |
| --- | --- | --- |
| dbee | `<Space>Do` open, `<Space>Dt` toggle, `<Space>Dc` close | `<Space>Do` opens four windows: drawer, SQL editor, result, call log |
| dbee drawer | `<CR>`, `o`, `r`, `cw`, `dd` | select / expand, toggle, refresh, rename, delete; the drawer's own help is listed inside it |
| dbee editor | `BB`, `<CR>` | `BB` runs the whole file (Visual: the selection), `<CR>` runs the statement under the cursor; the rows appear in the result window |
| dbee result | `L` / `H`, `E` / `F`, `yaj` / `yac`, `<C-c>` | next / previous page, last / first page, yank the row as JSON / CSV, cancel |
| dadbod (`<Space>Du`) | `o`, `S`, `R`, `A`, `H`, `d`, `r`, `q`, `?` | in the drawer: open/toggle, open in a vertical split, redraw, add a connection, toggle details, delete, rename, close, help; the drawer tree shows connection, New query, Saved queries, Tables |
| dadbod SQL buffer | `<Space>S`, `<Space>W`, `<Space>E` | run, save, edit bind parameters; `:DB sqlite:/path select ...` runs one query and shows the rows |

In an automated test the dadbod result window opened after `<Space>S` but stayed empty, so check that step in a real terminal.

---

# 40. Configuration management

| Keymap / Command | Description |
| --- | --- |
| `<Space>ev` | Open `init.lua` in a new tab |
| `<Space>sv` | Write all buffers and restart Neovim (windows, tabs and files are restored; terminals such as Claude Code are not restarted). Builtin `ZR` restarts without writing |
| `:Lazy` | Open plugin manager UI |

New or changed config needs a restart. Mappings, options and plugin specs in `lua/*.lua` are read at startup: a Neovim that was already running when keys were added or changed (for example by a tool or another editor) does not have them (observed: a newly added key did nothing until restart). The config's own comment says re-sourcing `$MYVIMRC` is not supported with lazy.nvim, so do not try `:source`. Restart with `<Space>sv` (see the row above); after `<Space>sv` Neovim reloaded and the newly added keys were available. To check that a key exists afterwards, press `<Space>` and read the which-key popup, or run `:verbose nmap <Space>jp` (replace the key; `:verbose map` is default Neovim, not tested here).
| `:Lazy update` | Update all plugins |

---

# 41. Filetype-specific settings

| Filetype | Settings |
| --- | --- |
| Python | 4-space indent, `<Space>rf` (or `<F9>`) to run, `<Space>fm` (and every `:w`) formats with `ruff format` |
| Lua | `<Space>rf` (or `<F9>`) to execute (`:luafile %`), `<Space>fm` (and every `:w`) formats with stylua |
| C++ | `<Space>rf` (or `<F9>`) to compile and run (only when a C++ compiler is on PATH, e.g. the c-cpp devShell) |
| Markdown | Word wrap enabled, syntax highlighting continues up to column 3000 on long lines; `<Space>fm` (and every `:w`) formats with prettier; `<Space><Space>` does not strip trailing spaces |
| JSON | `<Space>fm` (and every `:w`) formats with prettier (in Visual mode the selection); `:JSONFormat` pretty-prints through Python |
| Typst | `<Space>tw` TypstWatch, `textwidth=100`, wrap |
| Vim script | `<Space>rf` (or `<F9>`) sources the file |
| Line-length marker | The coloured column marker (`colorcolumn`) sits at 100 by default and, per language, exactly at that language's convention: 80 for C, C++, shell, YAML, Vim script, Haskell, R, JavaScript and TypeScript (also jsx/tsx); 88 for Python (ruff format); 100 for Java, Rust, Swift, Nix, Typst; 120 for Lua, PHP, TeX; plain `.txt` files show none. A line touching the marker is over that language's limit. Nothing wraps or reflows. |

## Filetype syntax plugins (vim-tmux, vim-toml)

These two plugins add syntax highlighting and filetype settings. They have no keys or commands in this configuration and load only when a file of that type is opened.

| Plugin | Files | Notes |
| --- | --- | --- |
| vim-tmux | tmux configuration files (filetype `tmux`) | Installed only when the `tmux` program is found on the machine. Per its README it also sets the comment string, makes `K` jump to the matching place in `man tmux` and adds `g!` (run lines as tmux commands); those extras were not tried here |
| vim-toml | `.toml` files (filetype `toml`) | Follows the plugin's `main` branch |

---

# 42. Automatic behaviors

These happen without any keypress:

| Behavior | Description |
| --- | --- |
| Auto-create directories | Missing parent directories are created on save |
| Auto-resize windows | Windows resize equally when terminal is resized (the Claude Code panel goes back to 30% width) |
| Relative line numbers | Relative in the focused window in normal mode; absolute in insert mode and in other windows; none in terminals |
| Non-UTF-8 warning | Warns if file encoding is not UTF-8 |
| Yank highlight | Yanked text highlighted for 300ms |
| Cursor restore | Cursor returns to original position after yank |
| Auto-quit | When only utility windows remain in a tab (quickfix, aerial outline, nvim-tree), the tab closes; on the last tab Neovim quits |
| Diagnostic float | Diagnostics auto-show when cursor rests on a line |
| Smart case | Case-insensitive search unless uppercase is used (only `/` and `?`; `:s` and `:g` always ignore case) |
| Colorscheme | Fixed base16 theme on Nix systems (`NVIM_BASE16_THEME`, fallback Catppuccin Mocha); random on other systems |
| Auto-save | Files save automatically on focus lost / buffer leave (not unnamed, read-only or special buffers, not Typst/LaTeX); these saves never format |
| Format on save | Every explicit save (`:w`, `:x`, `ZZ`) formats the file with the formatter of its file type (conform.nvim); `<Space>fo` toggles it for all buffers, `:FormatDisable` / `:FormatDisable!` / `:FormatEnable` also work, `<Space>fm` formats on demand. See [Formatting (conform.nvim)](07-code.md#formatting-conformnvim) |
| File changed on disk | Checked when Neovim gets focus and when idle. An unmodified buffer is reloaded ("File changed on disk. Buffer reloaded!"); if the buffer was changed too it is kept ("File changed on disk and in the buffer (buffer kept)"); a deleted file keeps its buffer (one warning) |
| Format check after save | After saving a Python or Lua file, `ruff format --check` / `stylua --check` run in the background; when the save did not format (an auto-save, or format on save switched off) and the file is still unformatted it gives the hint `<file>: file is not formatted (ruff)` (`(stylua)` for Lua); a file the tool cannot check (syntax error) gives `<file>: <tool> could not check the file (syntax error?)` plus the first error line. Nothing is changed |
| `nvim <directory>` | The directory becomes the working directory and the file tree opens there |
| Git plugins | fugitive and gitlinker load when the working directory or an opened file is inside a git repository; neogit loads on its first `:Neogit*` command (with diffview and fzf-lua) |
| Big files | Files over about 1.5 MB (or with very long lines) open in a light mode: no Treesitter, no completion, the language server starts a little later. `:set ft=<language>` gives the full mode back |
| Help window | On a screen of at least 200 columns `:help` opens as a full-height split on the far left |

---
---

# Part II: developer guide

Everything below is aimed at developers. It explains the plugins and tools in this config that make Neovim a full development environment, what they do under the hood, why they matter, and how to use them effectively.

---

# 66. Shell commands from inside Neovim

## Running a shell command

| Command | What it does |
| --- | --- |
| `:!ls` | Run `ls` and show the output (press Enter to return) |
| `:!python %` | Run the current file with python (`%` is the current filename) |
| `:!git diff` | Run git diff without leaving Neovim |
| `:!mkdir -p src/utils` | Create directories |

## Inserting command output into the buffer

| Command | What it does |
| --- | --- |
| `:read !date` | Insert the output of `date` below the cursor |
| `:read !ls` | Insert directory listing into the buffer |
| `:read !curl -s <url>` | Insert the contents of a URL |
| `:%!sort` | Replace the entire buffer with its sorted version |
| `:%!python -m json.tool` | Format the entire buffer as JSON with 4-space indent (`:JSONFormat` does the same with 2 spaces and leaves invalid JSON untouched) |

Examples:

| Command | Before | After |
| --- | --- | --- |
| `:read !echo hi` (cursor on line 1) | `a` / `b` | `a` / `hi` / `b` |
| `:%!sort` | `b` / `c` / `a` | `a` / `b` / `c` |
| `:%!python3 -m json.tool` | `{"a":1,"b":[2,3]}` | 7 lines: `{`, `    "a": 1,`, `    "b": [`, `        2,`, `        3`, `    ]`, `}` |

## Filtering a selection through a command

1. Select lines with `V`
2. Type `:!sort` -- the selected lines are replaced with the sorted result
3. Or `:!awk '{print $2}'` -- replace with second column only

Examples: the four lines `z` / `c` / `b` / `a` with `Vj` on lines 2 and 3, then `:!sort` (the command line shows `:'<,'>!sort`): the result is `z` / `b` / `c` / `a`, only the selected lines are sorted. The two lines `1 x` / `2 y` selected with `Vj` and `:!awk '{print $2}'` become `x` / `y`.

## The asyncrun.vim plugin

Plugin: **asyncrun.vim**. Runs commands asynchronously (non-blocking) and sends output to the quickfix list.

| Command | What it does |
| --- | --- |
| `:AsyncRun make` | Run make in the background, results go to quickfix |
| `:AsyncRun python %` | Run current file, output in quickfix |

The quickfix window auto-opens (6 lines tall) when AsyncRun starts.

Example: `:AsyncRun echo hi` opens the quickfix window with three lines: `[echo hi]`, `hi` and `[Finished in 0 seconds]`.

---

# 77. Neovide (graphical Neovim)

Neovide is a graphical program that runs Neovim in its own desktop window, instead of inside a terminal such as kitty and tmux. It is the same Neovim and the same configuration (`~/.config/nvim`); only the window around it changes. Nothing in this guide depends on it: everything works in the terminal.

## Starting it

| Command | What it does |
| --- | --- |
| `neovide` | Open an empty Neovim window |
| `neovide file.txt` | Open a file in a Neovide window |

You start it from a terminal (or your application launcher). A Neovide window has no tmux and no terminal around it, so tmux keys do nothing there; the editor itself, `:terminal` and the Claude panel work as usual.

## What this configuration sets for Neovide

The settings live in the Neovide block of `ginit.vim` in the nvim config (they apply only when Neovide runs):

| Setting | Value | Effect |
| --- | --- | --- |
| `guifont` | JetBrainsMono Nerd Font, size 10 | The font of the window (the same font as the kitty terminal; change the name or `:h10` in the Neovide block of `ginit.vim`) |
| `neovide_transparency` | 1.0 | Opaque window (no see-through background) |
| `neovide_cursor_animation_length` | 0.1 | The cursor glides to its new place in 0.1 seconds |
| `neovide_cursor_trail_size` | 0.3 | A short trail behind the moving cursor |
| `neovide_cursor_vfx_mode` | empty | No particle effects around the cursor |

Change a value by editing that block; the `neovide_...` names are the standard Neovide options.

## Keys that only exist in a GUI

A terminal swallows some key combinations, so `ginit.vim` adds them for GUIs (`:imap`, `:cmap` and `:nmap` show them with a description ending in "(GUI)"):

| Keys | Mode | What it does |
| --- | --- | --- |
| `<Shift-Insert>` | Insert, command line | Paste the system clipboard |
| `<Ctrl-6>` | Normal | Jump to the alternate (previously open) buffer, like `<Ctrl-^>` |

`ginit.vim` also has small blocks for other graphical frontends (nvim-qt and fvim); they do nothing in Neovide.

---
