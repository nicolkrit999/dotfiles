<!-- chapter: Searching, replacing, files and the file tree -->
[Back to the guide index](README.md)

# 10. Searching, Replacing, and Refactoring Text

This is one of the most important sections in the guide. It covers searching within a file, replacing text with various levels of control, and doing all of this across the entire project.

## Searching in the Current File

| Keymap | Description |
| --- | --- |
| `/pattern` | Search **forward** for `pattern`. Press `<Enter>` to start the search. |
| `?pattern` | Search **backward** for `pattern` |
| `n` | Jump to the **next** match (with hlslens showing `[x/y]` count) |
| `N` | Jump to the **previous** match |
| `*` | Search **forward** for the exact word under cursor (whole word, literal; the cursor stays on the word, `3*` jumps to the 3rd match after the cursor) |
| `#` | Search **backward** for the exact word under cursor |
| `;noh<Enter>` (`;` is `:` here) | Clear the yellow search highlight (tested). The search itself is kept, so `n` / `N` still work; the highlight comes back on the next search or `*`. |

### Search Modifiers

| Modifier | Where to put it | What it does | Example |
| --- | --- | --- | --- |
| `\c` | Anywhere in pattern | Force **case-insensitive** | `/\chello` finds `Hello`, `HELLO`, `hello` |
| `\C` | Anywhere in pattern | Force **case-sensitive** | `/\Chello` only finds `hello` |
| `\v` | At start of pattern | **Very magic**: regex works like Perl/Python (no need to escape `()`, `\|`, `+`, etc.) | `/\vfunction\(.*\)` |
| `\<` and `\>` | Around pattern | **Whole word** match only | `/\<count\>` finds `count` but not `counter` |

By default, search is case-insensitive but becomes case-sensitive if you type any uppercase letter (smart case). This is for `/` and `?` only: while you type a `:` command, smart case is off, so `:s` and `:g` ignore case completely (use `\C` or the `I` flag of `:s` for an exact match).

### Search Examples

| Search | What it finds |
| --- | --- |
| `/hello` | `hello`, `Hello`, `HELLO` (smart case: all lowercase = case-insensitive) |
| `/Hello` | Only `Hello` (smart case: has uppercase = case-sensitive) |
| `/\vdef \w+\(` | All Python function definitions (very magic regex) |
| `/\v(TODO\|FIXME\|HACK)` | Any of these three words (very magic `\|` for alternation) |
| `/\<user\>` | Only the word `user`, not `username` or `superuser` |
| `/error\c` | `error`, `Error`, `ERROR` (forced case-insensitive) |

---

## Substitution (Find & Replace in Current File)

The substitute command has this structure: `:[range]s/old/new/[flags]`

### Understanding the Range (Where to Replace)

The range tells Vim which lines to search. If omitted, only the current line is affected.

| Range | Meaning | Example |
| --- | --- | --- |
| (none) | Current line only | `:s/old/new/` |
| `%` | **Entire file** (all lines) | `:%s/old/new/g` |
| `.` | Current line (same as no range) | `:.s/old/new/g` |
| `$` | Last line of file | |
| `.,$` | From current line to end of file | `:.,$s/old/new/g` |
| `1,.` | From first line to current line | `:1,.s/old/new/g` |
| `20,30` | From line 20 to line 30 (absolute) | `:20,30s/old/new/g` |
| `-3,+3` | From 3 lines above to 3 lines below cursor (relative) | `:-3,+3s/old/new/g` |
| `'<,'>` | Current visual selection (auto-filled when you press `:` in visual mode) | `:'<,'>s/old/new/g` |

### Understanding the Flags (How to Replace)

Flags go at the very end, after the last `/`.

| Flag | What it does |
| --- | --- |
| (none) | Replace only the **first occurrence** on each line in range |
| `g` | **Global**: replace **all occurrences** on each line (not just the first) |
| `c` | **Confirm**: ask `y/n` for **each** replacement. You see the match highlighted and choose. |
| `i` | Case-**insensitive** matching |
| `I` | Case-**sensitive** matching. Needed here: `:s` ignores case completely, even with capitals in the pattern (tested: `:%s/Old/X/g` on `old Old OLD` gave `X X X`, with `gI` only `Old` changed) |
| `n` | **Count only**: show how many matches there are without replacing anything |
| `e` | Suppress "pattern not found" error |

### Flag Combinations

| Command | What happens |
| --- | --- |
| `:%s/old/new/` | Replace the first `old` on each line in the file |
| `:%s/old/new/g` | Replace **every** `old` in the entire file |
| `:%s/old/new/gc` | Replace every `old`, but **ask confirmation** for each one |
| `:%s/old/new/gi` | Replace every `old` case-insensitively (`Old`, `OLD`, `old` all match) |
| `:%s/old/new/gn` | **Count** how many `old` exist in the file (no replacement) |
| `:%s/old/new/gce` | Confirm each, and don't error if not found |

**Quick difference between the three common endings** (same `:%s/old/new` start, only the end changes):

| Ending | Replaces | Asks you? |
| --- | --- | --- |
| `/` (no flag) | only the **first** `old` on each line | no |
| `/gc` | **every** `old` on each line | yes, `y/n` for each one |
| `/gcc` | **every** `old` on each line (tested: the second `c` switches confirmation off again, so `/gcc` behaves like `/g`; `/gccc` asks again) | no |

Do not confuse `/gcc` with the normal-mode `gcc` (toggle comment on the current line): inside `:s/…/…/` the letters are flags, outside it `gcc` is a command.

### Confirmation Mode (`c` Flag) Controls

When you use the `c` flag, Vim highlights each match and asks what to do:

| Key | Action |
| --- | --- |
| `y` | **Yes**, replace this one and move to next |
| `n` | **No**, skip this one and move to next |
| `a` | **All**: replace this one and all remaining (stop asking) |
| `q` | **Quit**: stop replacing now |
| `l` | **Last**: replace this one and then stop |
| `<Ctrl-e>` | Scroll down to see more context |
| `<Ctrl-y>` | Scroll up to see more context |

### Changing the Delimiter

If your search/replace text contains `/`, use a different delimiter to avoid confusion:

| Command | What it does |
| --- | --- |
| `:%s#/usr/local/bin#/opt/bin#g` | Replace path using `#` as delimiter |
| `:%s\|old\|new\|g` | Use `\|` as delimiter |

You can use almost any character as a delimiter. Just use the same character for all three separators.

### Special Replacement Patterns

| Pattern in replacement | What it means |
| --- | --- |
| `&` | The entire matched text |
| `\1`, `\2`, etc. | Capture group 1, 2, etc. from `\( \)` in the search |
| `\u` | Uppercase the next character |
| `\U` | Uppercase everything after this |
| `\l` | Lowercase the next character |
| `\L` | Lowercase everything after this |
| `\r` | Newline (line break) |

### Substitution Examples

| Command | What it does |
| --- | --- |
| `:%s/foo/bar/g` | Replace all `foo` with `bar` |
| `:%s/\<foo\>/bar/g` | Replace only whole-word `foo` (not `foobar`) |
| `:%s/foo/bar/gc` | Replace all, confirming each one |
| `:%s/foo//g` | Delete all occurrences of `foo` |
| `:%s/\v(\w+), (\w+)/\2, \1/g` | Swap two comma-separated words: `last, first` becomes `first, last` |
| `:%s/\<\(\w\)/\u\1/g` | Capitalize the first letter of every word |
| `:%s/$/;/` | Add a semicolon at the end of every line |
| `:%s/^\s*$\n//g` | Delete all blank lines |
| `:20,30s/TODO/DONE/g` | Replace only between lines 20-30 |
| `:'<,'>s/old/new/g` | Replace only in the visual selection |

---

## Searching in the Current Buffer with `*` and `#`

These are the fastest ways to search for a word:

1. Place cursor on any word
2. Press `*` -- all occurrences highlight, the hlslens overlay shows `[1/N]`
3. Press `n` to jump forward, `N` to jump backward
4. With no count the cursor stays on the word you pressed `*` on (custom behavior in this config: a whole-word, literal search; `3*` jumps to the 3rd match after the cursor instead)

This is often combined with `ciw` + `.` for selective replacement (see below).

---

## Using `ciw` + `.` for Selective Single-File Replacement

This is the **most practical replacement method** for everyday use. It gives you full control, replacing one occurrence at a time:

1. Place cursor on the word you want to replace (e.g., `oldName`)
2. `*` -- search for it (all occurrences highlight)
3. `ciw` -- delete the word and enter insert mode
4. Type the new word (e.g., `newName`), then press `<Esc>`
5. `n` -- jump to the next occurrence
6. Decide: press `.` to replace this one too, or `n` to skip it
7. Repeat step 5-6 until done

**Why this is great**: Unlike `:%s`, you see each occurrence in context and can decide whether to replace it. Unlike `:%s/old/new/gc`, you stay in normal mode between replacements and can scroll around.

---

# 67. Multi-File Search and Replace (Complete Guide)

This is the section you need when you want to find or replace text across your entire project -- not just the current file.

## Quick Decision Guide: Which Method to Use

| Scenario | Best method |
| --- | --- |
| Rename a function/variable/class (code-aware) | **LSP Rename** (`<Space>rn`) |
| Replace a plain string in many files | **`:grep` + `:cfdo`** |
| Replace only in certain file types (e.g., only `.py`) | **`:grep --type` or `:vimgrep`, then `:cfdo`** |
| Just find where something is used (no replace) | **`<Space>fg`** (live grep) |
| Replace with confirmation for each occurrence | **`:cfdo` with the `gc` flag** |

---

## Method 1: LSP Rename (Best for Code Symbols)

If you're renaming a function, variable, class, or any code symbol, this is the best method because it understands scope and language semantics.

1. Place cursor on the symbol you want to rename
2. Press `<Space>rn`
3. Type the new name
4. Press `<Enter>`

**What happens**: The LSP server finds every reference to that symbol across the entire project and renames them all. It's smart: renaming `count` in one function won't affect `count` in another function.

**Limitations**: Only works for code symbols (not arbitrary text), and requires an LSP server that supports rename.

---

## Method 2: `:grep` + `:cfdo` (Best for Plain Text)

This is the most versatile method. It uses ripgrep (very fast) to search the entire project, puts results in the quickfix list, then runs a command on each file of the list.

**Why `:cfdo` and not `:cdo`**: `:grep` here creates ONE quickfix entry per match. `:cdo s/x/y/g` visits a line once per match; after the first visit replaced every `x` on the line, the next visit finds nothing and stops with `E486: Pattern not found` (tested), so the rest is NOT replaced. `:cfdo %s/x/y/g` runs once per file and avoids this. If you prefer `:cdo`, add the `e` flag: `:cdo s/x/y/ge | update`.

### Step-by-Step: Replace All Without Confirmation

```
:grep "oldFunction"                       -- search entire project
:cfdo %s/oldFunction/newFunction/g | update   -- replace in every matching file and save it
```

### Step-by-Step: Replace with Confirmation for Each Occurrence

```
:grep "oldFunction"                       -- search entire project
:cfdo %s/oldFunction/newFunction/gc | update  -- 'c' flag asks y/n for EACH occurrence
```

When the `c` flag is active, for each match you see it highlighted and can press:
- `y` to replace this one
- `n` to skip this one
- `a` to replace all remaining in this file (then moves to the next file, where you are prompted again; tested)
- `q` to stop entirely

### Step-by-Step: Review Results Before Replacing

```
:grep "oldFunction"                       -- search entire project
:copen                                    -- open the quickfix window to review all results
```

Now you can see every file and line that matches. Use `:cnext`/`:cprev` (or `j`/`k` in the quickfix window then `<Enter>`) to jump through them. Once satisfied:

```
:cfdo %s/oldFunction/newFunction/g | update   -- replace and save
```

### Using Regex with `:grep`

`:grep` passes the pattern directly to ripgrep, so you can use ripgrep regex. It is smart-case: an all-lowercase pattern ignores case, a pattern with a capital is exact (add `-s` to force exact case):

| Command | What it finds |
| --- | --- |
| `:grep "TODO"` | All lines containing `TODO` |
| `:grep "TODO\|FIXME"` | Lines with `TODO` or `FIXME` (type `\|` with the backslash; a rendered table may hide it) |
| `:grep "\buser\b"` | Only the whole word `user` |
| `:grep "def \w+\("` | Python function definitions |
| `:grep "console\.log"` | All `console.log` calls |

### Limiting to Specific File Types

Ripgrep supports file type filters:

| Command | What it searches |
| --- | --- |
| `:grep "pattern" --type py` | Only Python files |
| `:grep "pattern" --type js` | Only JavaScript files |
| `:grep "pattern" --type java` | Only Java files |
| `:grep "pattern" src/` | Only files in the `src/` directory |
| `:grep "pattern" --glob "*.tsx"` | Only `.tsx` files |

---

## Method 3: `:vimgrep` + `:cfdo` (Built-in, Slower but Portable)

`:vimgrep` is Vim's built-in search (doesn't require ripgrep). It's slower but lets you use Vim regex and file glob patterns:

| Command | What it does |
| --- | --- |
| `:vimgrep /pattern/ **/*` | Search all files recursively |
| `:vimgrep /pattern/ **/*.py` | Search only Python files |
| `:vimgrep /pattern/ **/*.{js,ts}` | Search JS and TS files |
| `:vimgrep /pattern/ src/**/*` | Search only in `src/` directory |

Then use `:cfdo` as before:

```
:vimgrep /oldName/ **/*.java
:cfdo %s/oldName/newName/g | update
```

---

## Method 4: `<Space>fg` for Finding (No Replace)

`<Space>fg` (live grep via fzf-lua) is the fastest way to **find** where something is used, but it doesn't directly support replace. Use it for:

- Exploring: "Where is this function called?"
- Investigating: "Which files reference this config key?"
- Planning: "How many places use this pattern?" before deciding on a replace strategy

After reviewing results in fzf, you can then use `:grep` + `:cfdo` for the actual replacement.

---

## Complete Examples

### Example 1: Rename an API Endpoint Across the Project

You renamed `/api/users` to `/api/v2/users`:

```
:grep "/api/users"                        -- find all references
:copen                                    -- review: make sure you're not catching wrong things
:cfdo %s#/api/users#/api/v2/users#g | update   -- replace (using # as delimiter since / is in the text) and save
```

### Example 2: Replace a Deprecated Function Name (with Confirmation)

```
:grep "getUser"
:cfdo %s/getUser/fetchUser/gc | update   -- confirm each one ('y' to replace, 'n' to skip)
```

### Example 3: Delete All Console.log Statements in JavaScript Files

```
:grep "console\.log" --type js            -- find them
:cfdo g/console\.log/d                    -- delete every line containing the match
:cfdo update                              -- save the files
```

### Example 4: Add a Comment Before Every TODO

```
:grep "TODO"
:cfdo %s/TODO/NOTE: was TODO/g | update
```

### Example 5: Replace Only in Python Files in the src/ Directory

```
:grep "old_function" --type py src/
:cfdo %s/old_function/new_function/g | update
```

### Example 6: Case-Insensitive Project-Wide Replace

```
:grep -i "oldname"                        -- ripgrep's -i flag for case-insensitive
:cfdo %s/oldname/newname/g | update       -- :s already ignores case in this config
```

---

## Understanding `:cdo` vs `:cfdo` vs `:bufdo`

| Command | What it does |
| --- | --- |
| `:cdo {cmd}` | Run `{cmd}` on every **line** in the quickfix list (may visit the same file multiple times) |
| `:cfdo {cmd}` | Run `{cmd}` once per **file** in the quickfix list (visits each file only once) |
| `:bufdo {cmd}` | Run `{cmd}` on every **open buffer** (not just quickfix results) |

For search-and-replace use `:cfdo %s/old/new/g` (see Method 2 for why a plain `:cdo s/old/new/g` can stop early). `:cdo` is fine for commands that act on the entry's line once, or with the `e` flag.

---

## Undoing a Multi-File Replace

If the replace went wrong, each file has its own undo history:

1. `:cfdo undo` -- undo the last change in every affected file
2. `:cfdo update` -- save the reverted files

Or use `:cfdo earlier 1f` to go back one save-state in each file (both recipes tested: both files were restored exactly).

---

# 12. Fuzzy Finding & Project-Wide Search (`fzf-lua`)

Plugin: **fzf-lua**. A powerful popup interface that connects to FZF (a command-line fuzzy finder). It lets you search file names, search text inside files, browse buffers, and more. The popup opens centered on screen at 70% height.

## Moving Inside Any Picker (Lists With a Search Bar)

Several things look the same: a search bar on top and a filtered list below it. They are the fzf-lua pickers (`<Space>ff`, `<Space>fg`, `<Space>fb`, `<Space>fr`, `<Space>gbl` ...), the snacks pickers (the branch menu you get by clicking the branch in the statusline, the code-action menu `<Space>ca`, every other `vim.ui.select` list) and Telescope (`:Telescope`, `<Space>db`, the devdocs commands). The search bar takes your typing, so `j` and `k` type the letters `j` and `k` there. Move through the list with these keys (all tested in a real terminal):

| Keys | What it does |
| --- | --- |
| `<Ctrl-n>` / `<Ctrl-p>`, or `<Down>` / `<Up>` | Next / previous item. Works in all three kinds of picker. |
| `<Ctrl-j>` / `<Ctrl-k>` | The same, but only in fzf-lua and the snacks pickers (NOT in Telescope) |
| `<Tab>` | Move down. In fzf-lua and Telescope it also marks the item, so you can choose several at once |
| `<Enter>` | Choose the item (or the marked ones) |
| `<Esc>` | fzf-lua: close the picker. snacks and Telescope: the first `<Esc>` leaves the search bar for Normal mode, where `j` / `k` move the list; a second `<Esc>` closes it |

The same `<Ctrl-n>` / `<Ctrl-p>` also move through the completion menu (section 14); on the `:` command line use `<Tab>` / `<S-Tab>`.

## Keymaps

| Keymap | Description |
| --- | --- |
| `<Space>ff` | **Find files**: search file names in the project |
| `<Space>fg` | **Live grep**: search text content across all files in the project |
| `<Space>fh` | Search Neovim help tags |
| `<Space>ft` | Search tags (functions, classes) in the current buffer (needs `ctags`; the Nix nvim wrapper provides universal-ctags) |
| `<Space>fb` | Search currently open buffers |
| `<Space>fr` | Search recently opened files |
| `<Space>gbl` | Fuzzy-search git branches (`<Enter>` checks the branch out) |
| `<Space>gB` | Branch menu (the same menu as clicking the branch name in the statusline): choose a branch and Neovim switches to it. Move with `<Ctrl-n>` / `<Ctrl-p>`, see "Moving Inside Any Picker" |

`<Space>ff` has no preview window and shows git status icons next to modified/untracked files; `.gitignore` is respected.

## Inside the FZF Popup

| Key | What it does |
| --- | --- |
| Type text | Filters results in real-time |
| `<Enter>` | Open the selected result |
| `<Esc>` | Cancel and close the popup |
| `<Ctrl-j>` / `<Ctrl-k>` | Move down / up in the results list |
| `<Ctrl-n>` / `<Ctrl-p>` | Move down / up (alternative keys) |

## `<Space>fg` -- Live Grep (Project-Wide Text Search) In Depth

This is one of the most important keymaps for developers. It searches inside every file in your project directory using **ripgrep** (`rg`) under the hood.

### What It Does

1. Press `<Space>fg`
2. A popup appears with a search prompt
3. As you type, ripgrep searches **all files** in the project folder and shows matching lines in real-time
4. Results show: file path, line number, and the matching line
5. Press `<Enter>` to jump directly to that file and line

### Plain Text Search

Just type normal text. For example, typing `getUserById` finds every file and line containing that string.

### Regex Search

Live grep supports **full regex** (ripgrep regex syntax). You don't need to learn all of regex, but here are the most useful patterns:

| Pattern you type | What it finds | Example matches |
| --- | --- | --- |
| `TODO` | Literal text `TODO` | `// TODO: fix this` |
| `TODO\|FIXME` | `TODO` OR `FIXME` | Both `// TODO` and `// FIXME` |
| `def \w+\(` | Python function definitions | `def process_data(`, `def main(` |
| `class \w+` | Class declarations | `class UserService`, `class App` |
| `import.*from` | ES6-style imports | `import { foo } from 'bar'` |
| `console\.log` | `console.log` (dot is escaped) | `console.log("debug")` |
| `function\s+\w+` | JavaScript function declarations | `function handleClick` |
| `\berror\b` | Whole word `error` only | `error` but not `errors` or `errorHandler` |
| `https?://` | URLs (http or https) | `https://example.com` |
| `v[0-9]+\.[0-9]+` | Version strings | `v1.0`, `v2.13` |

### Use Cases for Live Grep

| Scenario | What to search |
| --- | --- |
| Find where a function is called | Type the function name |
| Find all TODOs | Type `TODO` |
| Find a specific error message | Type part of the error string |
| Find all API endpoints | Type `@GetMapping` (Java) or `app.get(` (Express) or `@app.route` (Flask) |
| Find all imports of a module | Type `import.*moduleName` (regex) |
| Find environment variable usage | Type `process.env` or `os.environ` |
| Find hardcoded strings | Type the string in quotes |

## `<Space>ff` -- Find Files (File Name Search)

Searches **file names** (not content). Useful when you know the file you want but not the exact path.

- Type `userserv` to find `UserService.java` (fuzzy matching)
- Type `config.py` to find configuration files
- Type `.env` to find environment files (only if they are not git-ignored: `.gitignore` is respected; a `.ignore` file containing `!.env` makes them visible)
- Type `test` to see all test files

## The Difference Between Search Methods

| Method | Keymap | What it searches | Best for |
| --- | --- | --- | --- |
| **Live grep** | `<Space>fg` | Text **inside** files across the entire project | Finding where code/text is used |
| **Find files** | `<Space>ff` | **File names** in the project | Opening a file by name |
| **Buffer search** | `<Space>fb` | Names of **currently open** files | Switching between open files |
| **Recent files** | `<Space>fr` | Files you **recently edited** | Returning to a file you had open earlier |
| **Buffer tags** | `<Space>ft` | Functions/classes in **current file** (needs `ctags`) | Jumping to a function in the current file |
| **In-file search** | `/pattern` | Text in **current file only** | Finding something in the file you're editing |
| **Word under cursor** | `*` | Current word in **current file** | Quick highlight and jump to next occurrence |

---

# 26. Quickfix & Location List

## Commands

| Command | Description |
| --- | --- |
| `:copen` / `:cclose` | Open / close quickfix window |
| `:cnext` / `:cprev` | Next / previous item |
| `:cfirst` / `:clast` | First / last item |
| `:cc [nr]` | Jump to specific entry |
| `:cdo {cmd}` | Run command for each entry |
| `:colder` / `:cnewer` | Navigate quickfix history |
| `:lopen` / `:lclose` | Location list (per-window) |
| `\x` | Close quickfix and location list windows |

## Inside the Quickfix Window (nvim-bqf, quicker.nvim)

quicker.nvim formats the list (grouped by file, file-name column at most 40 characters or half the screen); the list cannot be edited as a buffer. nvim-bqf adds these keys inside the quickfix window (the preview does not start by itself):

| Key | Description |
| --- | --- |
| `p` / `P` | Toggle the preview of the item / toggle auto-preview while moving |
| `zp` | Toggle the preview between normal and maximum size |
| `<Ctrl-f>` / `<Ctrl-b>` | Scroll the preview down / up |
| `<Tab>` / `<S-Tab>` | Mark the item and move down / up; `z<Tab>` clears the marks |
| `zn` / `zN` | New list from the marked / unmarked items |
| `zf` | Fuzzy filter the list (fzf) |
| `<` / `>` | Go to the older / newer quickfix list |
| `o` | Open the item and close the quickfix window |
| `O` | Open the item in a window that already shows the buffer (otherwise open it); the list stays open |
| `t` / `T` | Open in a new tab (`T` stays in the quickfix window) |
| `<Ctrl-x>` / `<Ctrl-v>` / `<Ctrl-t>` | Open in a horizontal split / vertical split / new tab |

## Trouble (Plugin)

| Keymap / Command | Description |
| --- | --- |
| `:Trouble` | Open Trouble diagnostics viewer |
| `<Space>dw` | Workspace diagnostics via Trouble |

---

# 51. Quickfix Workflows for Developers

The quickfix list is a central tool for developers. It's a list of locations (file + line number) that you can jump through. Many features populate it.

## What Populates the Quickfix List

| Source | How to populate | Description |
| --- | --- | --- |
| Project-wide search | `:vimgrep /pattern/ **/*` | Search results across all files |
| LSP diagnostics | `<Space>qw` | Diagnostics of all open buffers |
| Buffer diagnostics | `<Space>qb` | Errors/warnings in current file only |
| Build errors | `:make` | Compiler output |
| Grep | `:grep pattern` | Uses ripgrep (configured in this setup) |

## Navigating the Quickfix List

| Command / Keymap | What it does |
| --- | --- |
| `:copen` | Open the quickfix window at the bottom |
| `:cclose` or `\x` | Close the quickfix window (`\x` also closes all location lists) |
| `:cnext` | Jump to the next item |
| `:cprev` | Jump to the previous item |
| `:cfirst` / `:clast` | Jump to the first / last item |
| `:cc 5` | Jump to item number 5 |
| `:colder` / `:cnewer` | Go to the previous / next quickfix list (history) |

## Batch Operations on Quickfix Items

| Command | What it does |
| --- | --- |
| `:cfdo %s/old/new/g \| update` | Run a substitution once in every file of the quickfix list, then save it |
| `:cdo s/old/new/ge \| update` | The same per quickfix entry (the `e` flag is needed, see the Multi-File Search and Replace section) |

**Example workflow**: Rename a string across the project:
1. `:grep "oldName"` to populate quickfix with all occurrences
2. `:cfdo %s/oldName/newName/g | update` to replace in all files and save them

## Trouble (Better Quickfix UI)

Plugin: **trouble.nvim**. A nicer interface for browsing diagnostics and quickfix items.

| Keymap / Command | What it does |
| --- | --- |
| `<Space>dw` | Open Trouble with workspace diagnostics |
| `:Trouble` | Open Trouble window |

Trouble shows diagnostics grouped by file with icons and colors, making it easier to triage errors.

---

# 11. File Explorer (`nvim-tree`)

Plugin: nvim-tree.lua. A sidebar file tree. It loads on the first `<Space>s` or the first `:NvimTreeToggle`, `:NvimTreeOpen`, `:NvimTreeFocus`, `:NvimTreeFindFile` or `:NvimTreeFindFileToggle`; `nvim <dir>` and the dashboard entry open it too. Which folder it shows: `nvim` or `nvim .` shows the folder you started in; `nvim <folder>` shows that folder; `nvim <folder>/file` shows the folder you started in (not the file's folder). From then on it keeps that folder until the working folder changes: after `:cd`, `:tcd`, `:Z` or `:z` it shows the new folder (also when it is open, or was closed and is opened again).

| Keymap | Context | Description |
| --- | --- | --- |
| `<Space>s` | global | Toggle the file explorer on/off |
| `<Enter>` | in tree | Open file (cursor moves to file) / expand directory. With 2 or more editor windows open and the file not already shown in one of them, it asks "Pick window:": a letter (A, B, C, ...) is drawn in the middle of each window's status line, press the letter of the window you want; any other key cancels. A file that is already open in a window is just focused. The dimming plugin vimade is switched off only while the letters are shown (otherwise they were nearly invisible) and switched on again right after. The tree itself always opens at the far left of the screen. |
| `<Tab>` | in tree | Open file but **keep cursor in the tree** (great for opening multiple files) |
| `<BS>` | in tree | Close (collapse) the directory under the cursor; on a file it closes its parent directory |
| `a` | in tree | Create a new file. Type the name and press Enter. Add `/` at the end for a directory. |
| `d` | in tree | Delete file/directory (asks for confirmation) |
| `r` | in tree | Rename file/directory |
| `c` | in tree | Copy file to clipboard |
| `x` | in tree | Cut file to clipboard |
| `p` | in tree | Paste from clipboard |
| `q` | in tree | Close the file explorer |
| `D` | in tree | Move file/directory to the trash (asks for confirmation; needs `trash`) |
| `g?` | in tree | Show the help with every key |
| `<Ctrl-v>` / `<Ctrl-x>` / `<Ctrl-t>` | in tree | Open in a vertical split / horizontal split / new tab |
| `-` / `<Ctrl-]>` | in tree | Make the parent / the folder under the cursor the root |
| `H` / `I` | in tree | Toggle dotfiles / git-ignored files |
| `f` / `F` | in tree | Live filter: start / clear |
| `R` | in tree | Refresh |
| `y` / `Y` / `gy` | in tree | Copy the name / relative path / absolute path |
| `]c` / `[c`, `]e` / `[e` | in tree | Next / previous git item, diagnostic item |
| `E` / `W` | in tree | Expand all / collapse all |

`nvim <dir>` opens the tree on that directory and makes it the working directory.

**Moving between tree and code**: Use `<Ctrl-w>h` / `<Ctrl-w>l` or `<Left>` / `<Right>` arrow keys.

---

# 30. Working with Directories

| Keymap / Command | Description |
| --- | --- |
| `<Space>cd` | Change working directory to current file's directory (window-local) |
| `:cd <path>` | Change directory globally |
| `:lcd <path>` | Change directory for current window only |
| `:tcd <path>` | Change directory for current tab |
| `:pwd` | Print current working directory |
| `:Z {keywords}` (or `:z {keywords}`) | `cd` to the best zoxide match (e.g. `:z nix nixos`) and print `cd <dir>`; without arguments it opens the fuzzy zoxide directory picker; without zoxide installed one warning |

### Path Modifiers (for use in commands)

| Modifier | Meaning | Example |
| --- | --- | --- |
| `%` | Current file path | `/home/user/project/src/main.lua` |
| `%:h` | Directory of current file | `/home/user/project/src` |
| `%:t` | Filename only | `main.lua` |
| `%:p` | Full absolute path | `/home/user/project/src/main.lua` |

---

# 57. File Management for Developers

## File Operations

| Plugin / Feature | What it does |
| --- | --- |
| **nvim-tree** (`<Space>s`) | Visual file browser. Create (`a`), delete (`d`), rename (`r`), copy (`c`), cut (`x`), paste (`p`). |
| **vim-eunuch** | Unix file commands, all available from a fresh start (lazy `cmd` list): `:Rename <newname>`, `:Move <path>` (move the file, creating directories), `:Duplicate <name>`, `:Copy <path>`, `:Delete` / `:Remove` / `:Unlink` (delete the file; `:Delete` also the buffer), `:Mkdir <dir>` (always creates the missing parent folders, like `mkdir -p`; do NOT type `-p`, it would become part of the folder name; a `!` makes no difference; with no argument it creates the folder of the current file; an existing folder only gives the message "Directory already exists"), `:Chmod <mode>`, `:Cfind` / `:Lfind` / `:Clocate` / `:Llocate` (find / locate into the quickfix / location list), `:SudoEdit`, `:SudoWrite`, `:Wall` (write all) and `:W` (= `:Wall`). |
| **gx.nvim** (`gx`) | Open the URL or file path under cursor in a browser. |
| `:CopyPath absolute` | Copy the full file path to clipboard. |
| `:CopyPath relative` | Copy path relative to project root. |
| `:CopyPath nameonly` | Copy just the filename. |

## Project Structure Navigation

| Keymap | What it does |
| --- | --- |
| `<Space>s` | Toggle file tree sidebar |
| `<Space>ff` | Fuzzy-find any file in the project |
| `<Space>fg` | Search for text across all project files |
| `<Space>cd` | Change the working directory of THIS window only (`:lcd`) to the current file's folder and print it |
| `<Space>t` | Toggle the symbol outline (aerial) for the current file |

---

# 63. Working with Multiple Files

## Opening Several Files

| Method | How |
| --- | --- |
| From command line | `nvim file1.py file2.py file3.py` (opens all as buffers) |
| From inside Neovim | `<Space>ff` to find and open files one at a time |
| Split open | `:vs file2.py` opens file2 in a vertical split next to current file |
| Tab open | `:tabe file2.py` opens in a new tab |
| From file tree | `<Space>s`, navigate to file, press `<Tab>` to open without leaving the tree |

## Comparing Two Files Side by Side

1. Open the first file
2. `:vs second_file.py` -- open the second file in a vertical split
3. Now both files are visible side-by-side
4. Use `<Ctrl-w>h` / `<Ctrl-w>l` to switch between them
5. Use `:diffthis` in each window to enable diff mode (highlights differences)
6. `:diffoff` to turn diff off

Or use the diffview plugin: `:DiffviewOpen` for git diffs.

## Copying Between Files

1. In file A: select text with `V` or `v`, then `y` to yank
2. Switch to file B: `<Ctrl-w>l` or `gb` or `<Space>bp`
3. Navigate to where you want the text
4. `p` to paste

Since clipboard is `unnamedplus`, yanked text is shared across all buffers and even with external applications.

## Running the Same Edit Across Multiple Files

Use the quickfix list:

1. `:grep "TODO"` -- find all files with "TODO"
2. `:cfdo %s/TODO/DONE/g | update` -- replace in every file of the list and save it

## Closing Files You're Done With

| Keymap | What it does |
| --- | --- |
| `\d` | Close current buffer, keep window |
| `\D` | Close all other buffers EXCEPT those with unsaved changes or a still-running terminal (one message says how many were kept) |
| `<Space>q` | Save the buffer if modified, then close the window (last window: quits nvim) |

---
