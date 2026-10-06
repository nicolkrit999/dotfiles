<!-- chapter: Windows, buffers, terminal, sessions and the interface -->
[Back to the guide index](README.md)

# 7. Windows, splits, and buffers

This section explains how to open, navigate, resize, and close split windows entirely with the keyboard.

## Key concepts

- **Buffer**: A file loaded into memory. You can have many buffers open but only see some of them.
- **Window**: A visible area showing a buffer. You can split your screen into multiple windows.
- **Tab**: A collection of windows. Think of it as a different workspace layout.

**Panel layout**: short single-task panels open on the LEFT (undo tree `<Space>u`, `<Space>rr` output, `:help` on a screen of at least 200 columns, which then opens as a full-height split on the far left), persistent panels on the RIGHT (Claude Code). Inactive windows are dimmed (vimade); the current window is always full colour.

## Creating splits

| Keymap / Command | Description |
| --- | --- |
| `<Ctrl-w>s` or `:sp` | Split the current window **horizontally** (new window appears below) |
| `<Ctrl-w>v` or `:vs` | Split the current window **vertically** (new window appears to the right) |
| `<Space>-` | Split the current window **horizontally** (new window below, same buffer) |
| `<Space>\|` | Split the current window **vertically** (new window to the right, same buffer) |
| `:sp <file>` | Open `<file>` in a new horizontal split |
| `:vs <file>` | Open `<file>` in a new vertical split |

**Config note**: `splitbelow` and `splitright` are set, so new splits always open below/right.

```
<Ctrl-w>s  (or <Space>-)       <Ctrl-w>v  (or <Space>|)

+------------------+           +---------+---------+
| old (above)      |           | old     | new     |
+------------------+           |         | (focus) |
| new (focus)      |           |         |         |
+------------------+           +---------+---------+
```

### Put two chosen buffers side by side or one above the other

The rows above split with the SAME buffer (`<Space>|`, `<Space>-`, `<Ctrl-w>v`) or open a file PATH (`:vs <file>`). To show two buffers that are already open, chosen by name or number, use `:sbuffer`. The two buffers do not have to be neighbours in the buffer list: you address them by name or number, never by "next/previous". Typical use: a window was closed by accident, or you want two of several open files next to each other.

Side by side (vertical split):

1. `:ls`  Lists the buffers with their NUMBERS and names. The number is stable and is not the position in the list.
2. `:b <name>` or `:b <number>`  Shows the wanted LEFT buffer in the current window. `<Tab>` completes the name, and a partial unique name is enough (e.g. `:b a`).
3. `:vert sbuffer <name or number>`  Splits vertically and shows the second buffer in the NEW window on the RIGHT (`splitright` is set). The cursor is in the new window.
4. `<Ctrl-w>h` / `<Ctrl-w>l`  Move between the two windows.

One above the other: the same, but `:sbuffer <name or number>` without `vert`. The new window opens BELOW (`splitbelow` is set) and gets the cursor. Move with `<Ctrl-w>k` / `<Ctrl-w>j`.

| Command | Effect |
| --- | --- |
| `:b <name\|number>` | Show that buffer in the current window |
| `:sbuffer <name\|number>` | New horizontal split below showing that buffer |
| `:vert sbuffer <name\|number>` | New vertical split to the right showing that buffer |
| `:vs <file>` / `:sp <file>` | Split and open a FILE PATH (loaded if needed); not a buffer name or number |
| `<Ctrl-^>` or `:b#` | Flip the current window between the current and the previously used buffer (see "Buffer management") |
| `:ls` or `:buffers` | List the buffers with their numbers |

`:bn` / `:bp` only move to the neighbours in the list, so they do not help when the two wanted buffers are far apart.

Example with four open buffers (`:ls` shows `1 a.txt`, `2 b.txt`, `3 c.txt`, `4 d.txt`): to see `a.txt` and `d.txt` side by side, run `:b 1` then `:vert sbuffer 4`, or by name `:b a` then `:vert sbuffer d`. No need to go through 2 and 3.

Headless Neovim with this config, 4 buffers open: `:vert sbuffer <name>` with another buffer in the current window gave two windows side by side (current buffer left, requested buffer right, cursor in the new right window); `:sbuffer <name>` gave a stacked layout (new window below, cursor in it); `:vs <file>` gave side by side; `:sbuffer 99` (no such buffer) gives `E86: Buffer 99 does not exist`.

Gotchas:

- If the current window already shows the buffer you name, you get the same buffer twice (for the horizontal case).
- Closing one of the windows (`:q`, or `<Space>q`, which also saves) does not close the buffer: it stays in `:ls`. Only `\d` closes the buffer (see "Buffer management").

## Navigating between windows

| Keymap | Description |
| --- | --- |
| `<Ctrl-w>h` or `<Left>` | Move to the window on the **left** |
| `<Ctrl-w>j` or `<Down>` | Move to the window **below** |
| `<Ctrl-w>k` or `<Up>` | Move to the window **above** |
| `<Ctrl-w>l` or `<Right>` | Move to the window on the **right** |
| `<Ctrl-w>w` | Cycle to the **next** window |
| `<Ctrl-w>W` | Cycle to the **previous** window |
| `<Ctrl-w>p` | Jump to the **previously active** window |

```
+-----+-----+    from A: <Ctrl-w>l -> B,  <Ctrl-w>j -> C
|  A  |  B  |    from B: <Ctrl-w>h -> A,  <Ctrl-w>j -> C
+-----+-----+    from C: <Ctrl-w>k -> A or B (see below)
|     C     |    <Ctrl-w>p from C -> back to the window you came from
+-----------+
```

C spans the full width, so `<Ctrl-w>k` from C goes to the window that lies above the cursor's screen column: A while the cursor is in the left half, B in the right half (with the cursor at columns 0 to 39 and 45 to 70 of an 80 column screen). `<Ctrl-w>j` from A or B always lands in C.

## Resizing windows

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

Example (two windows, one above the other, the cursor in the upper one): `<Ctrl-w>_` makes the upper window as tall as possible and squeezes the lower one down to a single line; `<Ctrl-w>=` gives both the same height again.

**Auto-resize**: When you resize your terminal, all windows resize equally, except the Claude Code panel, which goes back to 30% of the screen width.

## Moving windows around

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

Example, starting with A and B side by side and C below them, the cursor in A:

```
start                 <Ctrl-w>L on A          <Ctrl-w>J on A          <Ctrl-w>x on A
+-----+-----+         +-----+-----+           +-----------+           +-----+-----+
|  A  |  B  |         |  B  |     |           |     B     |           |  B  |  A  |
+-----+-----+         +-----+  A  |           +-----------+           +-----+-----+
|     C     |         |  C  |     |           |     C     |           |     C     |
+-----------+         +-----+-----+           +-----------+           +-----------+
                                              |     A     |
                                              +-----------+
```

`<Ctrl-w>x` swaps A with the next window in the same row (B). `<Ctrl-w>H` is like `<Ctrl-w>L` but puts A on the far left, `<Ctrl-w>K` is like `<Ctrl-w>J` but puts A at the very top.

## Buffer tabs (the top line, bufferline.nvim)

The top line shows one tab per open buffer (bufferline). Click a tab to switch to it. The `x` at the right of a tab closes it; while that buffer has unsaved changes the `x` is replaced by a `●`, and clicking the `●` closes it too. For a changed file Vim then asks `Save changes to "name"? [Y]es, (N)o, (C)ancel`: Yes saves and closes, No discards and closes, Cancel keeps the buffer and shows the warning "unsaved changes, buffer kept". A terminal whose program is still running is kept ("running terminal, buffer kept"). A right-click opens Neovim's own menu (see the [Mouse table](README.md#mouse) in the cheat sheet).

| Key | Effect |
| --- | --- |
| `<Space>bp` | Pick a buffer (`:BufferLinePick`): per the plugin's docs every visible tab shows a character, and typing that character jumps to that buffer |

Example (README.md is the current buffer and has unsaved changes; the second line is what you see after `<Space>bp`, then pressing `b` jumps to notes.txt):

```
  a.lua   ▕ notes.txt  ▕▎README.md ●
  a a.lua   ▕ b notes.txt  ▕▎R README.md ●
```

Quickfix, fugitive and git buffers never get a tab. The tabs show no file icons and no diagnostics, and they are ordered by buffer number.

### Changing the order of the tabs

The tabs are sorted by buffer number, which is the order in which the files were first opened, so a new file always appears on the right. There is no key for reordering; use these commands (type them after `:`):

| Command | Effect |
| --- | --- |
| `:BufferLineMovePrev` | Move the current tab one place to the left |
| `:BufferLineMoveNext` | Move the current tab one place to the right |

Example: you opened `hello.java` and then `calculator.java`, so the tabs read `hello.java | calculator.java` and `calculator.java` is the current buffer. `:BufferLineMovePrev` makes them `calculator.java | hello.java`; `:BufferLineMoveNext` puts them back. The new order stays while you switch between the buffers (within one Neovim session).

This only changes the order of the tabs. If the two files are shown side by side in two split windows and you want to swap which one is on the left, that is a window operation: `<Ctrl-w>x` (see "[Moving windows around](#moving-windows-around)" above); with `hello.java` on the left and `calculator.java` on the right, `<Ctrl-w>x` gives `calculator.java | hello.java`.

## Closing windows

| Keymap / Command | Description |
| --- | --- |
| `<Space>q` | Close the current window (saves if modified, `:x`). It fires after a short pause because `<Space>qb` / `<Space>qw` also exist |
| `<Space>Q` | Force quit Neovim, **discarding unsaved changes**, after a Yes/No confirmation (default No) |
| `:q` | Close current window |
| `:q!` | Close current window discarding unsaved changes |
| `:only` or `<Ctrl-w>o` | Close ALL other windows, keep only the current one |
| `\x` | Close the quickfix window and all location lists of the tab (the cursor stays in the current window) |

## Buffer management

| Keymap / Command | Description |
| --- | --- |
| `gb` | Go to the **next** buffer; `{N}gb` (e.g. `3gb`) goes to buffer number N (an invalid number warns "Invalid bufnr") |
| `gB` | Go to the **previous** buffer. Do not give it a count: `{N}gB` does nothing (an invalid number warns "Invalid bufnr"); use `{N}gb` to jump to buffer N |
| `<Space>bp` | **Pick** a buffer: each open buffer shows a letter, press it to switch |
| `\d` | Close/delete the current buffer (window stays open, shows previous buffer). On the last buffer an empty buffer is left. A named file with changes is saved first by auto-save (BufLeave); a buffer auto-save does not save (unnamed, read-only, Typst/LaTeX) is not deleted: you land in the previous buffer and the unsaved one stays loaded. On the only, unnamed buffer with typed text, Vim's confirm dialog "Save changes?" appears (the unsaved buffer is shown for a moment while it asks); your answer decides whether it is closed (in a real terminal). |
| `\D` | Close all other buffers, but **keep** buffers with unsaved changes and terminals that are still running (one message "kept N buffer(s) (unsaved or running terminal)") |
| `<Ctrl-^>` | Switch to the **alternate buffer**: the buffer you were in before this one. Press it again to come back, so you can flip between two files. It is the same as `:b#` or `:e #`. On a US keyboard `^` is Shift-6, so the keys are Ctrl-Shift-6; many terminals cannot send that, which is why Neovide gets the plain `<Ctrl-6>` as well (see [section 77](10-various.md#77-neovide-graphical-neovim)) |
| `:ls` or `:buffers` | List all open buffers; the flag columns are explained below ("Reading the `:ls` flags") |
| `:b <name>` | Switch to a buffer by (partial) name |
| `:b 3` | Switch to buffer number 3 |

### Reading the `:ls` flags

Each `:ls` line shows the buffer number, then up to four flag columns, then the name. Example (headless Neovim): ` 1 #a + "a.txt"`, ` 2  h   "b.txt"`, ` 3 %aF "term://..."`.

| Flag | Meaning | Status |
| --- | --- | --- |
| `%` | The buffer in the current window (line 3 above) | tested |
| `#` | The alternate buffer, the one `<Ctrl-^>` flips to (line 1) | tested |
| `a` | Active: loaded and visible in a window | tested |
| `h` | Hidden: loaded but shown in no window (line 2) | tested |
| `+` | Modified, unsaved changes (line 1) | tested |
| `F` | Terminal buffer whose job has finished (a terminal showing `Process exited`) | tested |
| `u` | Unlisted buffer; only shown with `:ls!` | from `:help :ls`, not tested |
| `R` | Terminal buffer with a running job | from `:help :ls`, not tested |
| `?` | Terminal buffer without a job (`:terminal NONE`) | from `:help :ls`, not tested |
| `-` | Buffer with `modifiable` off | from `:help :ls`, not tested |
| `=` | Read-only buffer | from `:help :ls`, not tested |
| `x` | Buffer with read errors | from `:help :ls`, not tested |

Use these when choosing buffers for [Put two chosen buffers side by side or one above the other](#put-two-chosen-buffers-side-by-side-or-one-above-the-other): `h` buffers are loaded but not on screen. A closed test terminal that shows `hF` is the case described in [The test terminal window does not come back after you close it](languages/java.md#the-test-terminal-window-does-not-come-back-after-you-close-it). `:help :ls` also lists `:ls` filter flags (for example `:ls h` for hidden buffers only; from help, not tested).

## Tabs

| Command | Description |
| --- | --- |
| `:tabnew` | Open a new empty tab |
| `:tabe <file>` | Open `<file>` in a new tab |
| `gt` | Go to the next tab |
| `gT` | Go to the previous tab |
| `:tabclose` or `\t` | Close the current tab |
| `:tabonly` or `\T` | Close all other tabs |

With exactly two tabs `gt` toggles between them: `:tabnew` (you are now in tab 2), `gt` goes back to tab 1, `gt` again to tab 2.

## Closing floating windows

Some plugins open floating windows (diagnostics, hover docs, etc.):

| Keymap | Description |
| --- | --- |
| `<Esc>` | Close any floating window (custom mapping) |

---

# 8. Terminal integration

## Opening a terminal

| Command / Keymap | Description |
| --- | --- |
| `:term` or `:terminal` | Open terminal in the current window |
| `:sp \| term` | Open terminal in a horizontal split below |
| `:vs \| term` | Open terminal in a vertical split to the right |
| `<Space>rr` | Run code (opens a terminal in a vertical split on the **left** of the code window) |

The terminal automatically starts in insert mode (you can type immediately) and hides line numbers. (in a real terminal: both start in insert mode).

## Navigating in and out of terminal

| Keymap | Context | Description |
| --- | --- | --- |
| `<Esc>` | In terminal | **Exit terminal mode** and enter Normal mode. Now you can navigate away from the terminal window using `<Ctrl-w>h/j/k/l` or arrow keys. Exception: in a Claude terminal `<Esc>` goes to Claude; there `<Ctrl-w>h/j/k/l` work directly from terminal mode, and `<Ctrl-\><Ctrl-n>` leaves terminal mode (see [section 9](09-ai-and-writing.md#9-ai-assistant-window-claude-code-claude-codenvim)). |
| `i` or `a` | In terminal (Normal mode) | Re-enter terminal mode (start typing commands again) |
| `<Ctrl-w>h/j/k/l` | In terminal (Normal mode) | Move to another window |
| `<Left>/<Right>/<Up>/<Down>` | In terminal (Normal mode) | Move to another window (arrow key shortcuts) |

**Workflow example**: You run code with `<Space>rr`. A terminal opens showing output. To go back to your code: press `<Esc>` to exit terminal mode, then `<Ctrl-w>l` (or `<Right>`) to move to the code window (the output is on the left). To close the terminal: `<Space>q` while in the terminal window.

## Closing a terminal

| Method | Description |
| --- | --- |
| `<Space>q` | While the terminal window is focused (press `<Esc>` first), close the window. A program that is still running keeps running in a hidden buffer (`\D` keeps such buffers) |
| Type `exit` | In an interactive shell terminal (`:term`), `exit` ends the shell and the window closes. A `<Space>rr` run does NOT close its window when the program ends: the output stays (it ends with the line `[Process exited 0]`) until you close it with `<Space>q` |
| `\d` | Delete the terminal buffer If the program is still running, Vim asks `Close "term://..."? [Y]es, (N)o, (C)ancel` first (in a real terminal). |

---

# 58. Session and productivity

## Auto-save (auto-save.nvim)

Plugin: **auto-save.nvim**. Files are automatically saved when you:
- Switch to another application (`FocusLost`)
- Leave the current buffer (`BufLeave`)

It never saves unnamed, read-only or special buffers (terminals, help, ...) and never saves Typst and LaTeX files (their watchers would recompile on every save). After each save the message "AutoSave: saved at HH:MM:SS" appears.

## Session management (persistence.nvim, vim-obsession)

Plugin: **persistence.nvim** saves a session for the current folder (and git branch) automatically when you quit, once a real file was opened. It is never restored by itself: restore it from the dashboard (`r` this folder, `L` last session). Windows of Claude Code, terminals, nvim-tree, the outline, help and quickfix are left out of the saved session. `<Space>sv` (restart) brings windows, tabs and files back on its own.

Plugin: **vim-obsession** (manual alternative). Save and restore your entire Neovim session (open files, window layout, etc.). It loads right after the first screen, so a session started with `nvim -S Session.vim` keeps being updated while you work (no need to type `:Obsession` again).

| Command | What it does |
| --- | --- |
| `:Obsession` | Start recording the session (saves to `Session.vim`) |
| `:Obsession!` | Stop recording and delete the session file |
| `nvim -S Session.vim` | Restore the session from the command line |

## Collaborative editing (instant.nvim)

Plugin: **instant.nvim**. Real-time collaborative editing.

- The plugin loads on its first `:Instant...` command. Host and port are arguments of `:InstantStartServer` / `:InstantStartSession` / `:InstantJoinSession` (e.g. `:InstantStartSession 127.0.0.1 8081`); the built-in server defaults to port 8080.
- Uses your system username automatically

Example (with two Neovim instances on one machine): the host runs `:InstantStartServer 127.0.0.1 8081`, then `:InstantStartSession 127.0.0.1 8081`; the guest runs `:InstantJoinSession 127.0.0.1 8081` and sees "Connected!" (the host sees "Peer connected! 2 connected."). The host's open buffers appear in the guest's buffer list (`:ls`; the buffer numbers are the guest's own). What either side types in a shared buffer shows up in the other one at once (in both directions), together with the other person's name at their cursor line.

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

Example (in a git repo, the cursor in the first line of a Lua file with one added, one changed and one removed line; the Nerd Font icons are left out, the real line has a branch icon before `main`, a diagnostic icon before the count `5` and a gear before `lua_ls`):

```
 a.lua   main \ +1 ~1 -1 \ <icon> 5                      lua_ls (+1)  Top
 A       B                                               X            Z
```

`Top` is the progress through the file (`Top`, a percentage or `Bot`).

---

# 33. UI features

| Feature | Description |
| --- | --- |
| **which-key.nvim** | Press `<Space>` and wait: a popup shows all available leader keybindings |
| **Dashboard** | Start screen for a bare `nvim` (no file, directory or stdin); menu and keys in "[Dashboard (Start Screen)](#dashboard-start-screen-dashboard-nvim)" below |
| **nvim-notify** | Animated notification popups (fade + slide, 1500ms) |
| **Colorschemes** | On Nix systems the base16 theme named by `NVIM_BASE16_THEME` (fallback Catppuccin Mocha); on other systems one of 19 themes chosen at random at each start. UI colours (yank flash, hop keys, notifications, float borders) follow the active theme. Details: "[Colorschemes](#colorschemes)" below |
| **dropbar.nvim** | Breadcrumb bar at top showing file > class > function |
| **nvim-colorizer** | Color codes (hex, rgb) are highlighted with their actual color; plain color words such as `red` are not |
| **mini.indentscope** | Visual `▏` guide for current indent scope (loads right after the first screen; `ii`/`ai` exist from then on) |
| **fidget.nvim** | LSP progress messages in bottom-right corner |
| **nvim-lightbulb** | Lightbulb icon when code actions are available |
| **vim-illuminate** | Highlights the other uses of the word under the cursor (`<Alt-n>` / `<Alt-p>` jump between them) |
| **vimade** | Dims inactive windows |
| **Borders** | Floating windows and the completion menu have a single-line border (exceptions: `:Lazy` and the DevDocs float use rounded corners) |

## Breadcrumb bar (dropbar.nvim)

Plugin: **dropbar.nvim**. A line at the top of a window shows the path to the code under the cursor: the file path, then the class and function you are in. It follows the cursor by itself and appears for files that have a Treesitter parser or a language server with symbols (and for markdown and terminal buffers). Files over 1 MB, help buffers, floating windows and windows that already have their own winbar do not get it. This config loads the plugin with its default settings and maps no key for it.

| Action | Effect |
| --- | --- |
| Click a part of the bar with the mouse | Opens a menu of the entries at that level (for example the other functions of the class); `<CR>` or a click on an entry jumps there (plugin default) |
| In that menu: `q` or `<Esc>` | Close the menu (plugin default) |

For a keyboard-driven view of the same information use the symbol outline (`<Space>t`, "[Symbol Outline](02-navigation.md#37-symbol-outline-aerialnvim)" in the navigation chapter).

## LSP progress messages (fidget.nvim)

Plugin: **fidget.nvim**. While a language server is busy (starting up, indexing a project), a small progress message appears in the bottom-right corner and disappears when the server is done. It is only informational: there is nothing to press, and the config calls `setup {}` with the default settings. If the message stays for a while after opening a file, the server is still working; wait until it vanishes before expecting completion or go-to-definition.

## Colorschemes

Twenty-two plugins in this config are colour themes or their helper library: 19 themes of the random list, plus catppuccin, nvim-base16 and lush.nvim. None of them is loaded at startup (all are lazy): lazy.nvim loads a theme plugin only when its colorscheme is selected.

### Which theme is active at startup

| System | What happens |
| --- | --- |
| Nix / NixOS (the folder `/etc/nixos` or `/etc/nix` exists) | The base16 theme named by the environment variable `NVIM_BASE16_THEME` is applied through nvim-base16 as `base16-<name>`. If the variable is missing or empty, or that theme fails to load, `base16-catppuccin-mocha` is used |
| Any other system | One theme out of the 19 below is picked at random at every start |

If even the Nix fallback fails, a warning ("Failed to load base16 colorscheme ...") is shown and Neovim's built-in `default` colorscheme is used. If a random theme fails to load, a warning ("Failed to load colorscheme ...") is shown and `default` is used.

The Catppuccin Mocha look is the convention of this repository. In Neovim it comes only from the Nix fallback `base16-catppuccin-mocha` (nvim-base16). The catppuccin plugin is installed too, but it is not in the random list and has no setup of its own: use it by hand with `:colorscheme catppuccin-mocha`.

### Switching and listing themes

There is no key or custom command for it; use the built-in commands:

| Command | Effect |
| --- | --- |
| `:colorscheme <Tab>` | Lists and completes the names of the colorschemes Neovim knows (plugin colorschemes that are not loaded yet are expected to be included, because lazy.nvim registers them; not tried) |
| `:colorscheme <name>` | Switches to that theme; lazy.nvim loads the plugin first when needed |
| `:colorscheme` | Shows the name of the active theme |

A manual switch lasts until you quit Neovim; the next start picks the theme again as described above. The per-theme settings in the table below (style, italics, background) are set only by the startup loader. A manual `:colorscheme <name>` does not run that code, so the theme starts from the plugin's own defaults (read from the code, not tried).

The UI colours of this config (yank flash, cursor and float borders, hop hint keys, notification background, completion menu, git signs) are derived from the active theme again after every `:colorscheme`, so they follow a manual switch.

### The 19 themes of the random list

| Plugin | Colorscheme loaded at startup | Other names the plugin provides |
| --- | --- | --- |
| onedark.nvim | `onedark` (style "darker") | N/A (the plugin has only this one colorscheme file) |
| edge | `edge` (default style, italics on) | N/A (the plugin has only this one colorscheme file) |
| sonokai | `sonokai` (italics on) | N/A (the plugin has only this one colorscheme file) |
| gruvbox-material | `gruvbox-material` (hard background, original foreground, italics on) | N/A (the plugin has only this one colorscheme file) |
| everforest | `everforest` (hard background, italics on) | N/A (the plugin has only this one colorscheme file) |
| nightfox.nvim | `carbonfox` | `nightfox`, `dayfox`, `dawnfox`, `duskfox`, `nordfox`, `terafox` |
| onedarkpro.nvim | `onedark_dark` | `onedark`, `onedark_vivid`, `onelight`, `vaporwave` |
| material.nvim | `material` (style "darker") | `material-darker`, `material-lighter`, `material-oceanic`, `material-palenight`, `material-deep-ocean` |
| arctic | `arctic` (needs lush.nvim) | N/A (the plugin has only this one colorscheme file) |
| kanagawa.nvim | `kanagawa-dragon` | `kanagawa`, `kanagawa-wave`, `kanagawa-lotus` |
| modus-themes.nvim | `modus` | `modus_operandi`, `modus_vivendi` |
| jellybeans.nvim | `jellybeans` | `jellybeans-default`, `-hc`, `-mono`, `-muted`, `-warm` and light variants |
| github-theme | `github_dark_default` | `github_dark`, `github_dark_dimmed`, `github_dark_high_contrast`, `github_dark_colorblind`, `github_dark_tritanopia`, `github_light*` |
| ashen.nvim | `ashen` | N/A (the plugin has only this one colorscheme file) |
| melange-nvim | `melange` | N/A (the plugin has only this one colorscheme file) |
| makurai-nvim | `makurai_dark` | `makurai_autumn`, `makurai_light` |
| vague.nvim | `vague` | N/A (the plugin has only this one colorscheme file) |
| kanso.nvim | `kanso` | `kanso-ink`, `kanso-mist`, `kanso-pearl`, `kanso-zen` |
| citruszest.nvim | `citruszest` | N/A (the plugin has only this one colorscheme file) |

The "other names" are the colorscheme files found in the installed plugin folders, so they depend on the plugin version.

Not in the random list: catppuccin (`catppuccin`, `catppuccin-mocha`, `-macchiato`, `-frappe`, `-latte`) and nvim-base16 (many `base16-<name>` themes; the one used on Nix). lush.nvim is only a library that arctic needs; it provides no colorscheme (see "[Libraries and dependencies](10-various.md#libraries-and-dependencies)" in "[39. Other plugins](10-various.md#39-other-plugins)" in `10-various.md`).

## Line number column (`statuscol.nvim`)

The column at the left of every window is drawn by statuscol.nvim as one column with three parts, from left to right: the sign column, the line number and the fold column. Each part has a click handler of the plugin (its default handlers; not described further here).

| Part | What it shows |
| --- | --- |
| Signs | The sign column is one cell wide (`signcolumn=yes:1`). The config defines signs for git changes (gitsigns) and for diagnostics (error, warning, info, hint glyphs) |
| Number | The line number; `number` and `relativenumber` are both on (see "[Automatic behaviors](10-various.md#42-automatic-behaviors)" for which window gets relative numbers). `relculright` is off, so the number of the cursor line is not right-aligned |
| Folds | The fold markers; fold levels deeper than 3 show a blank instead |

Example (in a git repository, the cursor in line 1 of a file with no diagnostics; compared with the last commit, line 3 was changed, one line below it was deleted and two lines were added at the end; the cursor line shows its absolute number, the other lines their distance from the cursor):

```
 sign number text
        1    return {          <- cursor line: absolute number
        1      a = 1,
 ~      2      b = 20,         <- git sign: changed line
 _      3      c = 3,          <- git sign: lines deleted below
        4      e = 5,
 +      5      f = 6,          <- git sign: added line
 +      6      g = 7,          <- git sign: added line
        7    }
```

The sign column is one cell wide: when a line also has a diagnostic (for example a lua_ls hint such as "unused local"), the diagnostic sign is drawn instead of the git sign.

The fold keys are in "[Code folding (`nvim-ufo`)](07-code.md#18-code-folding-nvim-ufo)".

## Icons and UI libraries

These plugins have no keys and no commands of their own; other plugins use them. Icons need a Nerd Font in the terminal.

| Plugin | Role |
| --- | --- |
| mini.icons | Supplies file-type and LSP-kind icons (the completion menu kind icons come from it). The config calls its `mock_nvim_web_devicons()`, so plugins that only know nvim-web-devicons get mini.icons answers; it is lazy and loads when a plugin asks for it |
| nvim-web-devicons | The older icon plugin. It has no spec of its own: lazy.nvim installs it because trouble.nvim lists it as a dependency (the nvim-tree config also has a `web_devicons` setting). Which of the two answers when both are present was not checked |
| nui.nvim | Popup, menu and layout building blocks. Needed by nvim-java, nvim-dbee and ascii.nvim |
| ascii.nvim | A collection of ASCII-art pictures, only needed by the dashboard, which takes a random one for its header at each start |

## Input popups and big files (`snacks.nvim`)

Plugin: **snacks.nvim**. Loaded at startup; three of its parts are enabled, with no keys or commands of their own.

| Part | What it does here |
| --- | --- |
| input | Replaces `vim.ui.input`: questions that ask for text appear as a small popup at the cursor with a darkened backdrop |
| picker | Replaces `vim.ui.select` (the snacks picker option `ui_select` is on by default and the config does not turn it off), so selection lists such as the branch menu or code actions are filterable pickers. The keys inside them are in "[Moving Inside Any Picker](05-search-and-files.md#moving-inside-any-picker-lists-with-a-search-bar)" (`05-search-and-files.md`) |
| bigfile | A file over 1.5 MB, or one whose lines average more than 5000 characters, gets the filetype `bigfile`: no Treesitter and no filetype keys. The language server of the real filetype starts a little later, without semantic tokens or completion. `:lsp stop` drops it; `:set ft=<language>` (for example `:set ft=json`) returns to full mode |

## Dashboard (start screen, dashboard-nvim)

The dashboard opens for a bare `nvim` (no file, no directory, no stdin) or with `:Dashboard`. `<Enter>` runs the item under the cursor. These single-letter keys work only inside the dashboard (the items that show `[<Leader> ...]` on the right are the global keys, they work everywhere, see "[Help keys](#help-keys-the-user-guide-and-claude-any-buffer-and-the-dashboard)" below):

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

What a bare `nvim` shows (in a terminal; the header picture is random, here a penguin, and the Nerd Font icons before each item are left out; the real list continues below "Open tree view"):

```
                  .---.
                 /     \
                 \.@-@./
                 /`\_/`\
                //  _  \\
               | \     )|_

        Restore session (this folder)                        [r]
        Restore last session                                 [L]
        Find File                                 [<Leader> f f]
        Recent files here                                    [o]
        Recently opened files                     [<Leader> f r]
        Recent directories                                   [d]
        Project grep                              [<Leader> f g]
        Open tree view                              [<Leader> s]
```

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

In the Claude split, `<Esc>` goes to Claude (it interrupts a running answer). `<Ctrl-w>h` (or `j`/`k`/`l`) moves to another window directly, even from terminal mode; `<Ctrl-\><Ctrl-n>` still leaves terminal mode. To edit the guide itself open the `.md` files directly (`<A-m>` previews one in the browser).

`:Dashboard` does the same as `\h`. To close the current buffer and get the dashboard instead: `:Dashboard | bdelete #` (a buffer with unsaved changes refuses with E89). `\d` deletes the buffer but shows the previous one, not the dashboard.

---
