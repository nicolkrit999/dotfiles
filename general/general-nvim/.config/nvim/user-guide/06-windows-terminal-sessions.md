<!-- chapter: Windows, buffers, terminal, sessions and the interface -->
[Back to the guide index](README.md)

# 7. Windows, Splits, and Buffers

This section explains how to open, navigate, resize, and close split windows entirely with the keyboard.

## Key Concepts

- **Buffer**: A file loaded into memory. You can have many buffers open but only see some of them.
- **Window**: A visible area showing a buffer. You can split your screen into multiple windows.
- **Tab**: A collection of windows. Think of it as a different workspace layout.

**Panel layout**: short single-task panels open on the LEFT (undo tree `<Space>u`, `<Space>rr` output, `:help` on a screen of at least 200 columns, which then opens as a full-height split on the far left), persistent panels on the RIGHT (Claude Code). Inactive windows are dimmed (vimade); the current window is always full colour.

## Creating Splits

| Keymap / Command | Description |
| --- | --- |
| `<Ctrl-w>s` or `:sp` | Split the current window **horizontally** (new window appears below) |
| `<Ctrl-w>v` or `:vs` | Split the current window **vertically** (new window appears to the right) |
| `<Space>-` | Split the current window **horizontally** (new window below, same buffer) |
| `<Space>\|` | Split the current window **vertically** (new window to the right, same buffer) |
| `:sp <file>` | Open `<file>` in a new horizontal split |
| `:vs <file>` | Open `<file>` in a new vertical split |

**Config note**: `splitbelow` and `splitright` are set, so new splits always open below/right.

## Navigating Between Windows

| Keymap | Description |
| --- | --- |
| `<Ctrl-w>h` or `<Left>` | Move to the window on the **left** |
| `<Ctrl-w>j` or `<Down>` | Move to the window **below** |
| `<Ctrl-w>k` or `<Up>` | Move to the window **above** |
| `<Ctrl-w>l` or `<Right>` | Move to the window on the **right** |
| `<Ctrl-w>w` | Cycle to the **next** window |
| `<Ctrl-w>W` | Cycle to the **previous** window |
| `<Ctrl-w>p` | Jump to the **previously active** window |

## Resizing Windows

| Keymap | Description |
| --- | --- |
| `<Ctrl-w>=` | Make all windows **equal size** |
| `<Ctrl-w>+` | Increase current window height by 1 line |
| `<Ctrl-w>-` | Decrease current window height by 1 line |
| `<Ctrl-w>>` | Increase current window width by 1 column |
| `<Ctrl-w><` | Decrease current window width by 1 column |
| `10<Ctrl-w>+` | Increase height by 10 lines |
| `10<Ctrl-w>>` | Increase width by 10 columns |
| `<Ctrl-w>_` | Maximize current window height (make it as tall as possible) |
| `<Ctrl-w>\|` | Maximize current window width (make it as wide as possible) |
| `:resize 20` | Set window height to 20 lines |
| `:vertical resize 80` | Set window width to 80 columns |

**Auto-resize**: When you resize your terminal, all windows resize equally, except the Claude Code panel, which goes back to 30% of the screen width.

## Moving Windows Around

| Keymap | Description |
| --- | --- |
| `<Ctrl-w>H` | Move current window to the **far left** (becomes full height) |
| `<Ctrl-w>J` | Move current window to the **very bottom** (becomes full width) |
| `<Ctrl-w>K` | Move current window to the **very top** (becomes full width) |
| `<Ctrl-w>L` | Move current window to the **far right** (becomes full height) |
| `<Ctrl-w>r` | **Rotate** windows in the current row/column |
| `<Ctrl-w>R` | Rotate windows in reverse |
| `<Ctrl-w>x` | **Swap** current window with the next one |
| `<Ctrl-w>T` | Move current window to a **new tab** |

## Buffer Tabs (the Top Line)

The top line shows one tab per open buffer (bufferline). Click a tab to switch to it. The `x` at the right of a tab closes it; while that buffer has unsaved changes the `x` is replaced by a `●`, and clicking the `●` closes it too. For a changed file Vim then asks `Save changes to "name"? [Y]es, (N)o, (C)ancel`: Yes saves and closes, No discards and closes, Cancel keeps the buffer and shows the warning "unsaved changes, buffer kept". A terminal whose program is still running is kept ("running terminal, buffer kept"). A right-click opens Neovim's own menu (see the Mouse table in the cheat sheet).

## Closing Windows

| Keymap / Command | Description |
| --- | --- |
| `<Space>q` | Close the current window (saves if modified, `:x`). It fires after a short pause because `<Space>qb` / `<Space>qw` also exist |
| `<Space>Q` | Force quit Neovim, **discarding unsaved changes**, after a Yes/No confirmation (default No) |
| `:q` | Close current window |
| `:q!` | Close current window discarding unsaved changes |
| `:only` or `<Ctrl-w>o` | Close ALL other windows, keep only the current one |
| `\x` | Close the quickfix window and all location lists of the tab (the cursor stays in the current window) |

## Buffer Management

| Keymap / Command | Description |
| --- | --- |
| `gb` | Go to the **next** buffer; `{N}gb` (e.g. `3gb`) goes to buffer number N (an invalid number warns "Invalid bufnr") |
| `gB` | Go to the **previous** buffer. Do not give it a count: `{N}gB` does nothing (an invalid number warns "Invalid bufnr"); use `{N}gb` to jump to buffer N |
| `<Space>bp` | **Pick** a buffer: each open buffer shows a letter, press it to switch |
| `\d` | Close/delete the current buffer (window stays open, shows previous buffer). On the last buffer an empty buffer is left. A named file with changes is saved first by auto-save (BufLeave); a buffer auto-save does not save (unnamed, read-only, Typst/LaTeX) is not deleted: you land in the previous buffer and the unsaved one stays loaded. On the only, unnamed buffer with typed text, Vim's confirm dialog "Save changes?" appears (the unsaved buffer is shown for a moment while it asks); your answer decides whether it is closed (tested in a real terminal). |
| `\D` | Close all other buffers, but **keep** buffers with unsaved changes and terminals that are still running (one message "kept N buffer(s) (unsaved or running terminal)") |
| `<Ctrl-^>` | Switch to the **alternate buffer**: the buffer you were in before this one. Press it again to come back, so you can flip between two files. It is the same as `:b#` or `:e #`. On a US keyboard `^` is Shift-6, so the keys are Ctrl-Shift-6; many terminals cannot send that, which is why Neovide gets the plain `<Ctrl-6>` as well (see section 77) |
| `:ls` or `:buffers` | List all open buffers |
| `:b <name>` | Switch to a buffer by (partial) name |
| `:b 3` | Switch to buffer number 3 |

## Tabs

| Command | Description |
| --- | --- |
| `:tabnew` | Open a new empty tab |
| `:tabe <file>` | Open `<file>` in a new tab |
| `gt` | Go to the next tab |
| `gT` | Go to the previous tab |
| `:tabclose` or `\t` | Close the current tab |
| `:tabonly` or `\T` | Close all other tabs |

## Closing Floating Windows

Some plugins open floating windows (diagnostics, hover docs, etc.):

| Keymap | Description |
| --- | --- |
| `<Esc>` | Close any floating window (custom mapping) |

---

# 8. Terminal Integration

## Opening a Terminal

| Command / Keymap | Description |
| --- | --- |
| `:term` or `:terminal` | Open terminal in the current window |
| `:sp \| term` | Open terminal in a horizontal split below |
| `:vs \| term` | Open terminal in a vertical split to the right |
| `<Space>rr` | Run code (opens a terminal in a vertical split on the **left** of the code window) |

The terminal automatically starts in insert mode (you can type immediately) and hides line numbers. (tested in a real terminal: both start in insert mode).

## Navigating In and Out of Terminal

| Keymap | Context | Description |
| --- | --- | --- |
| `<Esc>` | In terminal | **Exit terminal mode** and enter Normal mode. Now you can navigate away from the terminal window using `<Ctrl-w>h/j/k/l` or arrow keys. Exception: in the Claude Code panel `<Esc>` goes to Claude; use `<Ctrl-\><Ctrl-n>` there (see section 9). |
| `i` or `a` | In terminal (Normal mode) | Re-enter terminal mode (start typing commands again) |
| `<Ctrl-w>h/j/k/l` | In terminal (Normal mode) | Move to another window |
| `<Left>/<Right>/<Up>/<Down>` | In terminal (Normal mode) | Move to another window (arrow key shortcuts) |

**Workflow example**: You run code with `<Space>rr`. A terminal opens showing output. To go back to your code: press `<Esc>` to exit terminal mode, then `<Ctrl-w>l` (or `<Right>`) to move to the code window (the output is on the left). To close the terminal: `<Space>q` while in the terminal window.

## Closing a Terminal

| Method | Description |
| --- | --- |
| `<Space>q` | While the terminal window is focused (press `<Esc>` first), close the window. A program that is still running keeps running in a hidden buffer (`\D` keeps such buffers) |
| Type `exit` | In an interactive shell terminal (`:term`), `exit` ends the shell and the window closes. A `<Space>rr` run does NOT close its window when the program ends: the output stays (tested, no exit-code line is shown) until you close it with `<Space>q` |
| `\d` | Delete the terminal buffer If the program is still running, Vim asks `Close "term://..."? [Y]es, (N)o, (C)ancel` first (tested in a real terminal). |

---

# 58. Session and Productivity

## Auto-Save

Plugin: **auto-save.nvim**. Files are automatically saved when you:
- Switch to another application (`FocusLost`)
- Leave the current buffer (`BufLeave`)

It never saves unnamed, read-only or special buffers (terminals, help, ...) and never saves Typst and LaTeX files (their watchers would recompile on every save). After each save the message "AutoSave: saved at HH:MM:SS" appears.

## Session Management

Plugin: **persistence.nvim** saves a session for the current folder (and git branch) automatically when you quit, once a real file was opened. It is never restored by itself: restore it from the dashboard (`r` this folder, `L` last session). Windows of Claude Code, terminals, nvim-tree, the outline, help and quickfix are left out of the saved session. `<Space>sv` (restart) brings windows, tabs and files back on its own.

Plugin: **vim-obsession** (manual alternative). Save and restore your entire Neovim session (open files, window layout, etc.). It loads right after the first screen, so a session started with `nvim -S Session.vim` keeps being updated while you work (no need to type `:Obsession` again).

| Command | What it does |
| --- | --- |
| `:Obsession` | Start recording the session (saves to `Session.vim`) |
| `:Obsession!` | Stop recording and delete the session file |
| `nvim -S Session.vim` | Restore the session from the command line |

## Collaborative Editing

Plugin: **instant.nvim**. Real-time collaborative editing.

- The plugin loads on its first `:Instant...` command. Host and port are arguments of `:InstantStartServer` / `:InstantStartSession` / `:InstantJoinSession` (e.g. `:InstantStartSession 127.0.0.1 8081`); the built-in server defaults to port 8080.
- Uses your system username automatically

---

# 32. Statusline (`lualine.nvim`)

| Section | Position | Contents |
| --- | --- | --- |
| A | Leftmost | Filename + a lock icon (Nerd Font) when the file is read-only |
| B | Left | Git branch (click: pick a branch and check it out), `↑[n]` / `↓[n]` commits ahead / behind the upstream (the upstream is refreshed with a silent `git fetch origin` at most once a minute; long branch names are cut at 20 characters), diff stats (+~-), diagnostic counts (same icons as the sign column), Python virtualenv (Python buffers only) |
| C | Center-left | Pending command (e.g. `2d`), spell indicator (`[SPELL]`) |
| X | Center-right | Active LSP (gear icon; ` (+N)` = other attached clients; click: popup with the attached clients), `[N]trailing` (first line with trailing whitespace), `MI:N` (mixed tabs and spaces) |
| Y | Right | Encoding (only when not UTF-8) and file format (only when not unix), both in red; `[CN]` input-method badge on macOS |
| Z | Rightmost | Progress through the file (%). The line:column position is shown only in inactive windows |

---

# 33. UI Features

| Feature | Description |
| --- | --- |
| **which-key.nvim** | Press `<Space>` and wait: a popup shows all available leader keybindings |
| **Dashboard** | Start screen for a bare `nvim` (no file, directory or stdin); menu and keys in "Dashboard (Start Screen)" below |
| **nvim-notify** | Animated notification popups (fade + slide, 1500ms) |
| **Colorschemes** | On Nix systems the base16 theme named by `NVIM_BASE16_THEME` (fallback Catppuccin Mocha); on other systems one of 19 themes chosen at random at each start. UI colours (yank flash, hop keys, notifications, float borders) follow the active theme |
| **dropbar.nvim** | Breadcrumb bar at top showing file > class > function |
| **nvim-colorizer** | Color codes (hex, rgb) are highlighted with their actual color |
| **mini.indentscope** | Visual `▏` guide for current indent scope (loads right after the first screen; `ii`/`ai` exist from then on) |
| **fidget.nvim** | LSP progress messages in bottom-right corner |
| **nvim-lightbulb** | Lightbulb icon when code actions are available |
| **vim-illuminate** | Highlights the other uses of the word under the cursor (`<Alt-n>` / `<Alt-p>` jump between them) |
| **vimade** | Dims inactive windows |
| **Borders** | Floating windows and the completion menu have a single-line border (exceptions: `:Lazy` and the DevDocs float use rounded corners) |

## Dashboard (Start Screen)

The dashboard opens for a bare `nvim` (no file, no directory, no stdin) or with `:Dashboard`. `<Enter>` runs the item under the cursor. These single-letter keys work only inside the dashboard (the items that show `[<Leader> ...]` on the right are the global keys, they work everywhere, see "Help keys" below):

| Key | Item |
| --- | --- |
| `r` | Restore session (this folder) |
| `L` | Restore last session |
| `o` | Recent files here (only files under the current directory) |
| `d` | Recent directories (zoxide picker; the item is shown only when `zoxide` is installed) |
| `m` | Search keymaps |
| `e` | New file |
| `q` | Quit Neovim |

The other items show their normal key: Find File `<Space>ff`, Recently opened files `<Space>fr`, Project grep `<Space>fg`, Open tree view `<Space>s`, Search help `<Space>fh`, Claude Code `<Space>cc`, Open Nvim config `<Space>ev`. With nothing saved, `r` / `L` show one warning ("no saved session for this folder" / "no saved session"). Sessions are never restored automatically.

| Keymap | Description |
| --- | --- |
| `\h` | Open the dashboard in the current window (the previous buffer stays open in the background; inside the dashboard it only says "already in the dashboard") |
| `\H` | Close the dashboard and return to the previous buffer (the dashboard buffer is deleted so it does not pile up); outside the dashboard it only warns "not in the dashboard", with no previous buffer "no previous buffer to resume" |

### Help keys: the user guide and Claude (any buffer, and the dashboard)

The same two keys work in every normal buffer and as dashboard items (shown as `[<Leader> ?]` and `[<Leader> a]`), so you learn them once.

| Keys | What it does |
| --- | --- |
| `<Space>?` | Open this user guide as a PDF (`user-guide/neovim-user-guide.pdf`, built from the markdown files) in its own zathura window next to Neovim, always at page 2, the table of contents (zathura's remembered last page is ignored); close it with `q` in zathura. Pressing the key again while it is open only shows a notice. Without zathura the system viewer opens the PDF |
| `<Space>a` | Ask Claude how to do something in Neovim: a fresh `claude` session, always on the Sonnet model (`--model sonnet`), with the `answering-neovim-usage-questions` skill loaded, started in the nvim config folder with permissions bypassed (`--dangerously-skip-permissions`: it reads the guide and config, and can run commands or edit files, without asking). In a normal buffer it opens in a vertical split on the right (40% of the screen); on the dashboard it opens in its own tab. Type your question; `/exit` ends the session and closes the split or tab |

In the Claude split, `<Esc>` goes to Claude (it interrupts a running answer). To leave terminal mode use `<Ctrl-\><Ctrl-n>`, then move to the editor window with `<Ctrl-w>h`. To edit the guide itself open the `.md` files directly (`<A-m>` previews one in the browser).

`:Dashboard` does the same as `\h`. To close the current buffer and get the dashboard instead: `:Dashboard | bdelete #` (a buffer with unsaved changes refuses with E89). `\d` deletes the buffer but shows the previous one, not the dashboard.

---
