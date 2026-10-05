<!-- chapter: Searching, replacing, files and the file tree -->
[Back to the guide index](README.md)

# 10. Searching, replacing, and refactoring text

This is one of the most important sections in the guide. It covers searching within a file, replacing text with various levels of control, and doing all of this across the entire project.

## Searching in the current file

| Keymap | Description |
| --- | --- |
| `/pattern` | Search **forward** for `pattern`. Press `<Enter>` to start the search. |
| `?pattern` | Search **backward** for `pattern` |
| `n` | Jump to the **next** match (with hlslens showing `[x/y]` count) |
| `N` | Jump to the **previous** match |
| `*` | Search **forward** for the exact word under cursor (whole word, literal; the cursor stays on the word, `3*` jumps to the 3rd match after the cursor) |
| `#` | Search **backward** for the exact word under cursor |
| `;noh<Enter>` (`;` is `:` here) | Clear the yellow search highlight (tested). The search itself is kept, so `n` / `N` still work; the highlight comes back on the next search or `*`. |

### Search modifiers

| Modifier | Where to put it | What it does | Example |
| --- | --- | --- | --- |
| `\c` | Anywhere in pattern | Force **case-insensitive** | `/\chello` finds `Hello`, `HELLO`, `hello` |
| `\C` | Anywhere in pattern | Force **case-sensitive** | `/\Chello` only finds `hello` |
| `\v` | At start of pattern | **Very magic**: regex works like Perl/Python (no need to escape `()`, `\|`, `+`, etc.) | `/\vfunction\(.*\)` |
| `\<` and `\>` | Around pattern | **Whole word** match only | `/\<count\>` finds `count` but not `counter` |

By default, search is case-insensitive but becomes case-sensitive if you type any uppercase letter (smart case). This is for `/` and `?` only: while you type a `:` command, smart case is off, so `:s` and `:g` ignore case completely (use `\C` or the `I` flag of `:s` for an exact match).

### Search examples

| Search | What it finds |
| --- | --- |
| `/hello` | `hello`, `Hello`, `HELLO` (smart case: all lowercase = case-insensitive) |
| `/Hello` | Only `Hello` (smart case: has uppercase = case-sensitive) |
| `/\vdef \w+\(` | All Python function definitions (very magic regex) |
| `/\v(TODO\|FIXME\|HACK)` | Any of these three words (very magic `\|` for alternation) |
| `/\<user\>` | Only the word `user`, not `username` or `superuser` |
| `/error\c` | `error`, `Error`, `ERROR` (forced case-insensitive) |

The same searches on a sample file (tested: the match counts are the ones the search reports):

```
1  Hello world
2  hello again
3  HELLO
4  user, username, superuser
5  error Error ERROR
6  TODO: x
7  FIXME: y
8  def foo(a):
```

| Search | Matches |
| --- | --- |
| `/hello` | 3: lines 1, 2 and 3 (smart case: all lowercase ignores case) |
| `/Hello` | 1: only line 1 (a capital makes it exact) |
| `/\<user\>` | 1: only the first word on line 4; `username` and `superuser` are not matched |
| `/error\c` | 3: the three words on line 5 |
| `/\v(TODO\|FIXME)` | 2: lines 6 and 7 |
| `/\vdef \w+\(` | 1: `def foo(` on line 8 |

---

## Substitution (find & replace in current file)

The substitute command has this structure: `:[range]s/old/new/[flags]`

### Understanding the range (where to replace)

The range tells Vim which lines to search. If omitted, only the current line is affected.

| Range | Meaning | Example |
| --- | --- | --- |
| (none) | Current line only | `:s/old/new/` |
| `%` | **Entire file** (all lines) | `:%s/old/new/g` |
| `.` | Current line (same as no range) | `:.s/old/new/g` |
| `$` | Last line of file | `:$s/old/new/` (replaces on the last line only; tested) |
| `.,$` | From current line to end of file | `:.,$s/old/new/g` |
| `1,.` | From first line to current line | `:1,.s/old/new/g` |
| `20,30` | From line 20 to line 30 (absolute) | `:20,30s/old/new/g` |
| `-3,+3` | From 3 lines above to 3 lines below cursor (relative) | `:-3,+3s/old/new/g` |
| `'<,'>` | Current visual selection (auto-filled when you press `:` in visual mode) | `:'<,'>s/old/new/g` |

### Understanding the flags (how to replace)

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

### Flag combinations

| Command | What happens |
| --- | --- |
| `:%s/old/new/` | Replace the first `old` on each line in the file |
| `:%s/old/new/g` | Replace **every** `old` in the entire file |
| `:%s/old/new/gc` | Replace every `old`, but **ask confirmation** for each one |
| `:%s/old/new/gi` | Replace every `old` case-insensitively (`Old`, `OLD`, `old` all match) |
| `:%s/old/new/gn` | **Count** how many `old` exist in the file (no replacement) |
| `:%s/old/new/gce` | Confirm each, and don't error if not found |

Results on the two lines `old old` / `old` (tested):

| Command | Result |
| --- | --- |
| `:%s/old/new/` | `new old` / `new` |
| `:%s/old/new/g` | `new new` / `new` (message `3 substitutions on 2 lines`) |
| `:%s/old/new/gn` | no change, message `3 matches on 2 lines` |

And on the single line `old Old OLD` (`:s` ignores case here, see the `I` flag above):

| Command | Result |
| --- | --- |
| `:%s/old/X/gi` | `X X X` |
| `:%s/Old/X/g` | `X X X` (the capital in the pattern does not matter) |
| `:%s/Old/X/gI` | `old X OLD` (only the exact `Old` changed) |

The same holds with word boundaries: in a typed `:s` the case is always ignored unless you add `\C` (inside the pattern) or the `I` flag; a capital in the pattern does not help. (Reason: while you type a `:` command, smart case is switched off by an autocmd in `lua/custom-autocmd.lua`.) Tested with typed keys in tmux 2026-10-05, real Neovim with this config, on the line `Result and result and RESULT`:

| Command | Matches | Result |
| --- | --- | --- |
| `:%s/\<result\>/X/ge` | all three words (case ignored) | `X and X and X` |
| `:%s/\<Result\>/X/ge` | all three words (a capital does NOT make it exact) | `X and X and X` |
| `:%s/\C\<result\>/X/ge` | only the exact lowercase `result` (`\C` forces exact case) | `Result and X and RESULT` |
| `:%s/\<result\>/X/gIe` | only the exact lowercase `result` (the `I` flag) | `Result and X and RESULT` |
| `:%s/\<Result\>/X/gIe` | only the exact `Result` (`I` plus the exact-case word) | `X and result and RESULT` |

Take care with renames: because `:s` ignores case, renaming a variable `calc` also changes the class `Calc`, `Result`, `RESULT` and similar. Use `\C` (or the `I` flag) when only the exact case is meant. This applies equally to `:cfdo`, `:bufdo` and `:argdo` renames (see "Using regex with `:grep`" and "Example 6" below). `/` and `?` searches keep smart case.

**Quick difference between the three common endings** (same `:%s/old/new` start, only the end changes):

| Ending | Replaces | Asks you? |
| --- | --- | --- |
| `/` (no flag) | only the **first** `old` on each line | no |
| `/gc` | **every** `old` on each line | yes, `y/n` for each one |
| `/gcc` | **every** `old` on each line (tested: the second `c` switches confirmation off again, so `/gcc` behaves like `/g`; `/gccc` asks again) | no |

Do not confuse `/gcc` with the normal-mode `gcc` (toggle comment on the current line): inside `:s/…/…/` the letters are flags, outside it `gcc` is a command.

### Confirmation mode (`c` flag) controls

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

Example (tested): on the lines `old old` / `old`, `:%s/old/new/gc` highlights the first `old` and the bottom line asks

```
replace with new? (y)es/(n)o/(a)ll/(q)uit/(l)ast/scroll up(^E)/down(^Y)
```

Press `y` (first `old` becomes `new`), `n` (the second stays `old`), `a` (the last one and everything after it is replaced without asking): the result is `new old` / `new`.

### Changing the delimiter

If your search/replace text contains `/`, use a different delimiter to avoid confusion:

| Command | What it does |
| --- | --- |
| `:%s#/usr/local/bin#/opt/bin#g` | Replace path using `#` as delimiter |
| `:%s\|old\|new\|g` | Use `\|` as delimiter |

You can use almost any character as a delimiter. Just use the same character for all three separators.

Example (tested): on the line `/usr/local/bin/x`, `:s#/usr/local/bin#/opt/bin#` gives `/opt/bin/x`.

### Special replacement patterns

| Pattern in replacement | What it means |
| --- | --- |
| `&` | The entire matched text |
| `\1`, `\2`, etc. | Capture group 1, 2, etc. from `\( \)` in the search |
| `\u` | Uppercase the next character |
| `\U` | Uppercase everything after this |
| `\l` | Lowercase the next character |
| `\L` | Lowercase everything after this |
| `\r` | Newline (line break) |

Examples (tested):

| Command | Before | After |
| --- | --- | --- |
| `:s/cat/[&]/` | `cat dog` | `[cat] dog` |
| `:s/\w\+/\U&/` | `foo bar` | `FOO bar` |
| `:s/\w\+/\L&/` | `FOO BAR` | `foo BAR` |
| `:s/\w\+/\l&/` | `FOO BAR` | `fOO BAR` |
| `:s/, /\r/g` | `a, b, c` | `a` / `b` / `c` (3 lines) |
| `:%s/\v(\w+), (\w+)/\2 \1/g` | `Smith, John` / `Doe, Jane` | `John Smith` / `Jane Doe` |
| `:%s/\v(\w+), (\w+)/\2, \1/g` | `Smith, John` / `Doe, Jane` | `John, Smith` / `Jane, Doe` (the comma stays) |

### Substitution examples

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

Results (tested):

| Command | Before | After |
| --- | --- | --- |
| `:%s/foo//g` | `foo foo x` | `  x` (two spaces are left) |
| `:%s/\<foo\>/bar/g` | `foo foobar` | `bar foobar` |
| `:%s/\<\(\w\)/\u\1/g` | `hello big world` | `Hello Big World` |
| `:%s/$/;/` | `a` / `b` | `a;` / `b;` |
| `:%s/^\s*$\n//g` | `a` / (empty) / `b` / (only spaces) / `c` | `a` / `b` / `c` |
| `:2,3s/x/y/` | `x` / `x` / `x` / `x` | `x` / `y` / `y` / `x` |

---

## Searching in the current buffer with `*` and `#`

These are the fastest ways to search for a word:

1. Place cursor on any word
2. Press `*` -- all occurrences highlight, the hlslens overlay shows `[1/N]`
3. Press `n` to jump forward, `N` to jump backward
4. With no count the cursor stays on the word you pressed `*` on (custom behavior in this config: a whole-word, literal search; `3*` jumps to the 3rd match after the cursor instead)

This is often combined with `ciw` + `.` for selective replacement (see below).

---

## Using `ciw` + `.` for selective single-file replacement

This is the **most practical replacement method** for everyday use. It gives you full control, replacing one occurrence at a time:

1. Place cursor on the word you want to replace (e.g., `oldName`)
2. `*` -- search for it (all occurrences highlight)
3. `ciw` -- delete the word and enter insert mode
4. Type the new word (e.g., `newName`), then press `<Esc>`
5. `n` -- jump to the next occurrence
6. Decide: press `.` to replace this one too, or `n` to skip it
7. Repeat step 5-6 until done

Example (tested): the line is `foo a foo b foo`, the cursor is on the first `foo`.

1. `*` (all three `foo` highlight, the cursor stays on the first)
2. `ciw`, type `bar`, `<Esc>`: `bar a foo b foo`
3. `n` jumps to the second `foo`: you decide to skip it, so `n` again jumps to the third `foo`
4. `.` repeats the change there: `bar a foo b bar`. The middle `foo` was left alone.

**Why this is great**: Unlike `:%s`, you see each occurrence in context and can decide whether to replace it. Unlike `:%s/old/new/gc`, you stay in normal mode between replacements and can scroll around.

---

# 67. Multi-file search and replace (complete guide)

This is the section you need when you want to find or replace text across your entire project -- not just the current file.

## Quick decision guide: which method to use

| Scenario | Best method |
| --- | --- |
| Rename a function/variable/class (code-aware) | **LSP Rename** (`<Space>rn`) |
| Replace a plain string in many files | **`:grep` + `:cfdo`** |
| Replace only in certain file types (e.g., only `.py`) | **`:grep --type` or `:vimgrep`, then `:cfdo`** |
| Just find where something is used (no replace) | **`<Space>fg`** (live grep) |
| Replace with confirmation for each occurrence | **`:cfdo` with the `gc` flag** |

---

## Method 1: LSP rename (best for code symbols)

If you're renaming a function, variable, class, or any code symbol, this is the best method because it understands scope and language semantics.

1. Place cursor on the symbol you want to rename
2. Press `<Space>rn`
3. Type the new name
4. Press `<Enter>`

Example (tested with pyright): `a.py` contains `def load():` and `b.py` contains `from a import load` and `print(load())`. With the cursor on `load` in `a.py`, `<Space>rn` opens a small prompt with `load` already in it; clear it (`<Ctrl-w>`), type `read` and press `<Enter>`. All three places are renamed (`def read():`, `from a import read`, `print(read())`), including the other file (it is changed in a buffer: save it with `:wa`). This works across files only in a project with a root marker such as `.git` or `pyproject.toml`; without one pyright only sees the open file (tested: only `a.py` was renamed). A same-named symbol in another scope is left alone (tested in a project with a `pyproject.toml`: with `count` in two functions `f` and `g`, renaming `count` to `total` inside `f` changed only `f`).

**What happens**: The LSP server finds every reference to that symbol across the entire project and renames them all. It's smart: renaming `count` in one function won't affect `count` in another function.

**Limitations**: Only works for code symbols (not arbitrary text), and requires an LSP server that supports rename.

### LSP rename versus `:grep` + `:cfdo`: can the fast text rename replace a slow `<Space>rn`?

Short answer: NOT a drop-in replacement. It is a fast alternative only when the word is unique enough, and only if you review what it matches first. `:cfdo` is a plain text substitution (like `:%s/old/new/g`), not a semantic rename. It does NOT run over the whole workspace and NOT over the open buffers: it runs over the FILES IN THE QUICKFIX LIST, that is exactly the files in which ripgrep (`:grep`) found a match (`:cfdo` opens each one, runs the command, and `| update` saves it). Open buffers are irrelevant (`:bufdo` is the one that walks open buffers).

| | LSP rename (`<Space>rn`) | `:grep` + `:cfdo` |
| --- | --- | --- |
| What it understands | Code: changes the symbol only (its declaration and real usages); a same-named method or variable in another class is NOT touched; strings and comments are not touched; knows overloads and scopes | Text: changes every occurrence of the characters or word: comments, strings, same-named but unrelated symbols, other file types (`pom.xml`, `.md`) |
| Speed | Java with jdtls: 10 to 17 s when healthy (tested); can be slower or fail with a stale index (see [When a rename does nothing](languages/java.md#when-a-rename-does-nothing)) | About a second |
| Needs | An attached language server with a healthy index | Only ripgrep |
| Review before | No preview: the buffers change after the answer arrives | `:copen` to read every match first; the `c` flag confirms each change: `:cfdo %s/\<old\>/new/gc \| update` |
| Undo | Several files change: see [Undoing a multi-file replace](#undoing-a-multi-file-replace) | The same |

Tested example (scratch copy of a small Java project, headless Neovim with this config): `:grep "add"` then `:cfdo %s/\<add\>/addition/ge | update`. The method `add` of class `Calc` exists in `Calc.java` and is called from three other files. The text rename ALSO changed a comment that mentioned `add`, and a `names.add("apple")` line in another file, which is `java.util.List.add`, not `Calc.add`. In real code a `list.add(...)` call would be a compile error after the rename. `<Space>rn` on `Calc.add` changed only the method and its calls.

- The word-boundary form `\<word\>` avoids matching inside longer words (tested).
- Tested with a local variable `total`: `:grep "total"` then `:cfdo %s/\<total\>/result/g | update` also changed a string literal `"total is "` and a comment. Fine when you want that, wrong when the string is output text.
- Tested in a folder WITHOUT a `.git` directory: a `.gitignore` entry (`target`) was NOT honored; `:grep` also listed a file in the ignored `target/` folder, so `:cfdo` would have changed it too. Ripgrep honors `.gitignore` only inside a git repository (inside one: assumption, not tested here). Check build output folders such as `target/` in the `:copen` list before running `:cfdo`.

Which to use (rule of thumb):

- A method, field, class or local variable whose name also occurs elsewhere (`add`, `get`, `name`, `size`, `value`): `<Space>rn`.
- A long, unique name (`calculateInvoiceTotal`), or a name in non-code text (config key, string, docs, comment wording): `:grep`, review with `:copen`, then `:cfdo`.
- `<Space>rn` fails or hangs: first the repair `<Space>jbc` (Java: [When a rename does nothing](languages/java.md#when-a-rename-does-nothing)); the text rename is a fallback only when the matches are reviewed.
- Renaming a class by text does NOT rename its file. (Whether the LSP rename of a public class renames the file too: assumption, not tested.)

Status: reported by the user, not verified here: `<Space>rn` stays slow even after `<Space>jbc`; slow jdtls rename is a known issue reported online.

---

## Method 2: `:grep` + `:cfdo` (best for plain text)

This is the most versatile method. It uses ripgrep (very fast) to search the entire project, puts results in the quickfix list, then runs a command on each file of the list.

**Requirement: fill the quickfix list FIRST.** `:cfdo` (and `:cdo`) has no search of its own. It only runs a command on the files (or entries) that are ALREADY in the quickfix list, so the order is always: 1. fill the list (`:grep`, `:vimgrep`, `:make`, diagnostics: see [What populates the quickfix list](#what-populates-the-quickfix-list)), 2. check it with `:copen`, 3. run `:cfdo`. With an EMPTY list `:cfdo` and `:cdo` do nothing and print no error (tested in headless Neovim: the commands returned without error; a visible message in a UI session was not seen). So "nothing happened" usually means the list was empty: look with `:copen`. The sibling commands for other file sets (location list, buffers, argument list, windows, tabs) are in [Understanding `:cdo` vs `:cfdo` vs `:bufdo`](#understanding-cdo-vs-cfdo-vs-bufdo).

**Why `:cfdo` and not `:cdo`**: `:grep` here creates ONE quickfix entry per match. `:cdo s/x/y/g` visits a line once per match; after the first visit replaced every `x` on the line, the next visit finds nothing and stops with `E486: Pattern not found` (tested), so the rest is NOT replaced. `:cfdo %s/x/y/g` runs once per file and avoids this. If you prefer `:cdo`, add the `e` flag: `:cdo s/x/y/ge | update`.

### Step-by-step: replace all without confirmation

```
:grep "oldFunction"                       -- search entire project
:cfdo %s/oldFunction/newFunction/g | update   -- replace in every matching file and save it
```

### Step-by-step: replace with confirmation for each occurrence

```
:grep "oldFunction"                       -- search entire project
:cfdo %s/oldFunction/newFunction/gc | update  -- 'c' flag asks y/n for EACH occurrence
```

When the `c` flag is active, for each match you see it highlighted and can press:
- `y` to replace this one
- `n` to skip this one
- `a` to replace all remaining in this file (then moves to the next file, where you are prompted again; tested)
- `q` to stop entirely

### Step-by-step: review results before replacing

```
:grep "oldFunction"                       -- search entire project
:copen                                    -- open the quickfix window to review all results
```

Now you can see every file and line that matches. Use `:cnext`/`:cprev` (or `j`/`k` in the quickfix window then `<Enter>`) to jump through them. Once satisfied:

```
:cfdo %s/oldFunction/newFunction/g | update   -- replace and save
```

### Using regex with `:grep`

`:grep` passes the pattern directly to ripgrep, so you can use ripgrep regex. It is smart-case: an all-lowercase pattern ignores case, a pattern with a capital is exact (add `-s` to force exact case). For an exact-case project-wide rename BOTH sides must be exact: `:grep -s "word"` to collect the files and `\C` (or the `I` flag) in the substitution, for example `:cfdo %s/\Cword/new/g | update`. Otherwise `:s` still changes `Word` and `WORD` in those files (tested in a single file, see "Substitution" above):

| Command | What it finds |
| --- | --- |
| `:grep "TODO"` | All lines containing `TODO` |
| `:grep "TODO\|FIXME"` | Lines with `TODO` or `FIXME` (type `\|` with the backslash; a rendered table may hide it) |
| `:grep "\buser\b"` | Only the whole word `user` |
| `:grep "def \w+\("` | Python function definitions |
| `:grep "console\.log"` | All `console.log` calls |

What `:grep "TODO"` puts in the quickfix list (tested; the list has one row per match: file, line number and the text of the line):

```
src/c.py ┃ 1┃# TODO: fix
src/c.py ┃ 2┃print(1)  # TODO later
src/d.py ┃ 1┃# TODO: three
```

`:grep "TODO\|FIXME"` (tested on a small project with `TODO` and `FIXME` in three files) fills the list with every line containing either word. The order of the files can vary, because ripgrep searches in parallel. A line with two matches (such as `x and x` for `:grep "x"`) appears twice in the list: this is why `:cfdo` is used below.

### Limiting to specific file types

Ripgrep supports file type filters:

| Command | What it searches |
| --- | --- |
| `:grep "pattern" --type py` | Only Python files |
| `:grep "pattern" --type js` | Only JavaScript files |
| `:grep "pattern" --type java` | Only Java files |
| `:grep "pattern" src/` | Only files in the `src/` directory |
| `:grep "pattern" --glob "*.tsx"` | Only `.tsx` files |

---

## Method 3: `:vimgrep` + `:cfdo` (built-in, slower but portable)

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

## Method 4: `<Space>fg` for finding (no replace)

`<Space>fg` (live grep via fzf-lua) is the fastest way to **find** where something is used, but it doesn't directly support replace. Use it for:

- Exploring: "Where is this function called?"
- Investigating: "Which files reference this config key?"
- Planning: "How many places use this pattern?" before deciding on a replace strategy

After reviewing results in fzf, you can then use `:grep` + `:cfdo` for the actual replacement.

---

## Complete examples

### Example 1: rename an API endpoint across the project

You renamed `/api/users` to `/api/v2/users`:

```
:grep "/api/users"                        -- find all references
:copen                                    -- review: make sure you're not catching wrong things
:cfdo %s#/api/users#/api/v2/users#g | update   -- replace (using # as delimiter since / is in the text) and save
```

### Example 2: replace a deprecated function name (with confirmation)

```
:grep "getUser"
:cfdo %s/getUser/fetchUser/gc | update   -- confirm each one ('y' to replace, 'n' to skip)
```

### Example 3: delete all `console.log` statements in JavaScript files

```
:grep "console\.log" --type js            -- find them
:cfdo g/console\.log/d                    -- delete every line containing the match
:cfdo update                              -- save the files
```

### Example 4: add a comment before every TODO

```
:grep "TODO"
:cfdo %s/TODO/NOTE: was TODO/g | update
```

### Example 5: replace only in Python files in the src/ directory

```
:grep "old_function" --type py src/
:cfdo %s/old_function/new_function/g | update
```

### Example 6: case-insensitive project-wide replace

```
:grep -i "oldname"                        -- ripgrep's -i flag for case-insensitive
:cfdo %s/oldname/newname/g | update       -- :s ignores case in this config anyway; for exact case use :grep -s and \C
```

---

## Understanding `:cdo` vs `:cfdo` vs `:bufdo`

These are the "do-command family": each runs `{cmd}` over a different list. None of them searches by itself; they only walk a list that already exists (the quickfix and location commands need it filled first, see the requirement in [Method 2](#method-2-grep--cfdo-best-for-plain-text)).

| Command | Which list it walks | Filled by / source |
| --- | --- | --- |
| `:cdo {cmd}` | Every **entry (line)** of the quickfix list; may visit the same file several times | `:grep`, `:vimgrep`, `:make`, diagnostics keys `<Space>qw` / `<Space>qb` (see [What populates the quickfix list](#what-populates-the-quickfix-list)) |
| `:cfdo {cmd}` | Once per **file** of the quickfix list | The same sources |
| `:ldo {cmd}` / `:lfdo {cmd}` | Like `:cdo` / `:cfdo`, but over the **location list** (one per window); open it with `:lopen` | `:lgrep`, `:lvimgrep`, `:lmake` |
| `:bufdo {cmd}` | Every buffer in the **buffer list** (see `:ls`), shown in a window or not. Project files that are not open are NOT visited (documented `:bufdo` behaviour) | Files you opened |
| `:argdo {cmd}` | Every file of the **argument list**: the files given on the command line (`nvim a b c`) or set with `:args <glob>`, e.g. `:args src/**/*.java` | `:args` |
| `:windo {cmd}` | Every **window of the current tab page** | Your splits |
| `:tabdo {cmd}` | Every **tab page** (runs in the current window of each tab) | Your tabs |

Which one when:

| I want to change... | Use |
| --- | --- |
| Project text found by a search | `:grep "old"` then `:cfdo ...` |
| Per-window results (several searches at once, each in its own window) | `:lgrep "old" .` then `:lfdo ...` |
| The files I already have open | `:bufdo ...` |
| An explicit set of files | `:args <files or glob>` then `:argdo ...` |
| The windows I see now | `:windo ...` |
| Every tab | `:tabdo ...` |

Tested (scratch Java project, headless Neovim):

- `:lgrep "total" .` then `:lfdo %s/\<total\>/loc/ge | update` changed both files that had matches (13 entries, 6 + 7 substitutions).
- With two files loaded and a third never opened, `:bufdo %s/\<total\>/buf/ge | update` changed the two loaded ones. The third had no match anyway, so this alone does not prove it would be skipped; that a file outside the buffer list is not visited is the documented behaviour of `:bufdo`.
- `nvim a b`, then `:argdo %s/\<total\>/arg/ge | update` changed both files.
- With two split windows `:windo ...` and with two tabs `:tabdo ...` (same substitution with `| update`) changed both files.
- With an EMPTY quickfix or location list, `:cdo`, `:cfdo` and `:lfdo` do nothing and print no error (headless; a visible message in a UI session was not seen). "Nothing happened" usually means an empty list: check with `:copen` / `:lopen`.

**Gotcha (tested): always add the `e` flag** for `:bufdo`, `:argdo`, `:windo` and `:tabdo` substitutions: `%s/old/new/ge`. Without it, `:bufdo %s/\<total\>/buf/g | update` STOPPED at the first buffer without a match with `E486: Pattern not found` and the following buffers were not processed (the same stop rule as the `:cdo` stop below). `:cfdo` after `:grep` is safe without `e` only because every file in the list has a match.

The `|` chain: `{cmd} | update` runs the command and then saves the buffer. Without `update` (or `set hidden` / autowrite) a modified buffer may refuse to be left (`E37: No write since last change`). The auto-save plugin of this config saves when you leave a buffer, but do not rely on it for these commands (assumption, not tested).

`:argdo` as a project-wide file set without grep: `:args **/*.java` (assumption, not tested), then `:argdo %s/old/new/ge | update`.

For search-and-replace use `:cfdo %s/old/new/g` (see [Method 2](#method-2-grep--cfdo-best-for-plain-text) for why a plain `:cdo s/old/new/g` can stop early). `:cdo` is fine for commands that act on the entry's line once, or with the `e` flag.

Example (tested): the file `x.txt` has the single line `x and x`.

| Steps | What happens |
| --- | --- |
| `:grep "x" x.txt` | The quickfix list has TWO entries, both for line 1 (one per `x`) |
| `:cdo s/x/y/g` | Entry 1 (`(1 of 2)`): the line becomes `y and y`. Entry 2 (`(2 of 2)`): nothing is left to replace, so it stops with `E486: Pattern not found: x` |
| `:cdo s/x/y/ge` | The same, but the `e` flag hides the error: no message |
| `:cfdo %s/x/y/g` | One visit per file: `y and y` |

---

## Undoing a multi-file replace

If the replace went wrong, each file has its own undo history:

1. `:cfdo undo` -- undo the last change in every affected file
2. `:cfdo update` -- save the reverted files

Or use `:cfdo earlier 1f` to go back one save-state in each file (both recipes tested: both files were restored exactly).

---

# 12. Fuzzy finding & project-wide search (`fzf-lua`)

Plugin: **fzf-lua**. A powerful popup interface that connects to FZF (a command-line fuzzy finder). It lets you search file names, search text inside files, browse buffers, and more. The popup opens centered on screen at 70% height.

## Moving inside any picker (lists with a search bar)

Several things look the same: a search bar on top and a filtered list below it. They are the fzf-lua pickers (`<Space>ff`, `<Space>fg`, `<Space>fb`, `<Space>fr`, `<Space>gbl` ...), the snacks pickers (the branch menu you get by clicking the branch in the statusline, the code-action menu `<Space>ca`, every other `vim.ui.select` list) and Telescope (`:Telescope`, `<Space>db`, the devdocs commands). The search bar takes your typing, so `j` and `k` type the letters `j` and `k` there. Move through the list with these keys (all tested in a real terminal):

| Keys | What it does |
| --- | --- |
| `<Ctrl-n>` / `<Ctrl-p>`, or `<Down>` / `<Up>` | Next / previous item. Works in all three kinds of picker. |
| `<Ctrl-j>` / `<Ctrl-k>` | The same, but only in fzf-lua and the snacks pickers (NOT in Telescope) |
| `<Tab>` | Move down. In fzf-lua and Telescope it also marks the item, so you can choose several at once |
| `<Enter>` | Choose the item (or the marked ones) |
| `<Esc>` | fzf-lua: close the picker. snacks and Telescope: the first `<Esc>` leaves the search bar for Normal mode, where `j` / `k` move the list; a second `<Esc>` closes it |

The same `<Ctrl-n>` / `<Ctrl-p>` also move through the completion menu ([section 14](04-completion-snippets.md#14-autocompletion-nvim-cmp)); on the `:` command line use `<Tab>` / `<S-Tab>`.

## Keymaps

| Keymap | Description |
| --- | --- |
| `<Space>ff` | **Find files**: search file names in the project |
| `<Space>fg` | **Live grep**: search text content across all files in the project |
| `<Space>fh` | Search Neovim help tags |
| `<Space>ft` | Search tags (functions, classes) in the current buffer (needs `ctags`; the Nix nvim wrapper provides universal-ctags) |
| `<Space>fb` | Search currently open buffers |
| `<Space>fr` | Search recently opened files |
| `<Space>fs` | Search only your own snippets (`my_snippets/`) and insert one; also `<Alt-s>` in insert mode ([section 52, The snippet gallery](04-completion-snippets.md#the-snippet-gallery)) |
| `<Space>gbl` | Fuzzy-search git branches (`<Enter>` checks the branch out) |
| `<Space>gB` | Branch menu (the same menu as clicking the branch name in the statusline): choose a branch and Neovim switches to it. Move with `<Ctrl-n>` / `<Ctrl-p>`, see "[Moving Inside Any Picker](#moving-inside-any-picker-lists-with-a-search-bar)" |

`<Space>ff` has no preview window and shows git status icons next to modified/untracked files; `.gitignore` is respected.

## Inside the fzf-lua popup

| Key | What it does |
| --- | --- |
| Type text | Filters results in real-time |
| `<Enter>` | Open the selected result |
| `<Esc>` | Cancel and close the popup |
| `<Ctrl-j>` / `<Ctrl-k>` | Move down / up in the results list |
| `<Ctrl-n>` / `<Ctrl-p>` | Move down / up (alternative keys) |

## `<Space>fg` -- Live grep (project-wide text search) in depth

This is one of the most important keymaps for developers. It searches inside every file in your project directory using **ripgrep** (`rg`) under the hood.

### What it does

1. Press `<Space>fg`
2. A popup appears with a search prompt
3. As you type, ripgrep searches **all files** in the project folder and shows matching lines in real-time
4. Results show: file path, line number, and the matching line
5. Press `<Enter>` to jump directly to that file and line

What the popup looks like after typing `TODO` (tested; the list is on top, the preview of the highlighted match below; move with `<Ctrl-n>` / `<Ctrl-p>` or `<Down>` / `<Up>`, open with `<Enter>`):

```
+---------------------------- Grep -----------------------------+
| > TODO                                                  3/3 (0) |
|  :: <ctrl-g> to Fuzzy Search                                    |
| > src/c.py:1:3:# TODO: fix                                      |
|   src/c.py:2:13:print(1)  # TODO later                          |
|   src/d.py:1:3:# TODO: three                                    |
+---------------------- buf 1: c.py ----------------------------+
|  1 # TODO: fix                                                  |
|  2 print(1)  # TODO later                                       |
+-----------------------------------------------------------------+
```

Each result is `file:line:column:text`.

### Plain text search

Just type normal text. For example, typing `getUserById` finds every file and line containing that string.

### Regex search

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

### Use cases for live grep

| Scenario | What to search |
| --- | --- |
| Find where a function is called | Type the function name |
| Find all TODOs | Type `TODO` |
| Find a specific error message | Type part of the error string |
| Find all API endpoints | Type `@GetMapping` (Java) or `app.get(` (Express) or `@app.route` (Flask) |
| Find all imports of a module | Type `import.*moduleName` (regex) |
| Find environment variable usage | Type `process.env` or `os.environ` |
| Find hardcoded strings | Type the string in quotes |

## `<Space>ff` -- Find files (file name search)

Searches **file names** (not content). Useful when you know the file you want but not the exact path.

- Type `userserv` to find `UserService.java` (fuzzy matching)
- Type `config.py` to find configuration files
- Type `.env` to find environment files (only if they are not git-ignored: `.gitignore` is respected; a `.ignore` file containing `!.env` makes them visible)
- Type `test` to see all test files

## The difference between search methods

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

# 26. Quickfix & location list

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

## Inside the quickfix window (nvim-bqf, quicker.nvim)

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
| `O` | Open the item in a window that already shows the buffer (otherwise open it) and close the quickfix window, like `o` (tested: the quickfix window was closed afterwards; `<Enter>` is the key that keeps the list open) |
| `t` / `T` | Open in a new tab (`T` stays in the quickfix window) |
| `<Ctrl-x>` / `<Ctrl-v>` / `<Ctrl-t>` | Open in a horizontal split / vertical split / new tab |

Example (tested): `:grep "TODO"` gives 3 hits and `:copen` opens the list. Press `<Tab>` twice: the first two hits are marked (each `<Tab>` marks and moves down). Press `zn`: a NEW list is made with just those 2 hits (the old list is kept). `<` goes back to the older list with all 3 hits, `>` forward to the new one. `o` on a hit opens it and closes the quickfix window (tested), `<Enter>` opens it and keeps the list open.

---

# 51. Quickfix workflows for developers

The quickfix list is a central tool for developers. It's a list of locations (file + line number) that you can jump through. Many features populate it.

## What populates the quickfix list

| Source | How to populate | Description |
| --- | --- | --- |
| Project-wide search | `:vimgrep /pattern/ **/*` | Search results across all files |
| LSP diagnostics | `<Space>qw` | Diagnostics of all open buffers |
| Buffer diagnostics | `<Space>qb` | Errors/warnings in current file only |
| Build errors | `:make` | Compiler output |
| Grep | `:grep pattern` | Uses ripgrep (configured in this setup) |

## Navigating the quickfix list

| Command / Keymap | What it does |
| --- | --- |
| `:copen` | Open the quickfix window at the bottom |
| `:cclose` or `\x` | Close the quickfix window (`\x` also closes all location lists) |
| `:cnext` | Jump to the next item |
| `:cprev` | Jump to the previous item |
| `:cfirst` / `:clast` | Jump to the first / last item |
| `:cc 5` | Jump to item number 5 |
| `:colder` / `:cnewer` | Go to the previous / next quickfix list (history) |

## Batch operations on quickfix items

| Command | What it does |
| --- | --- |
| `:cfdo %s/old/new/g \| update` | Run a substitution once in every file of the quickfix list, then save it |
| `:cdo s/old/new/ge \| update` | The same per quickfix entry (the `e` flag is needed, see the [Multi-File Search and Replace](#67-multi-file-search-and-replace-complete-guide) section) |

**Example workflow**: Rename a string across the project:
1. `:grep "oldName"` to populate quickfix with all occurrences
2. `:cfdo %s/oldName/newName/g | update` to replace in all files and save them

## trouble.nvim: better quickfix UI

Plugin: **trouble.nvim**. A nicer interface for browsing diagnostics and quickfix items.

| Keymap / Command | What it does |
| --- | --- |
| `<Space>dw` | Toggle Trouble with the diagnostics of every loaded buffer, grouped by file (`:Trouble diagnostics toggle`; see "[Diagnostics in depth](07-code.md#diagnostics-in-depth)" in the code chapter) |
| `:Trouble` | Open Trouble window |

Trouble shows diagnostics grouped by file with icons and colors, making it easier to triage errors.

---

# 11. File explorer (`nvim-tree`)

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

# 30. Working with directories

| Keymap / Command | Description |
| --- | --- |
| `<Space>cd` | Change working directory to current file's directory (window-local) |
| `:cd <path>` | Change directory globally |
| `:lcd <path>` | Change directory for current window only |
| `:tcd <path>` | Change directory for current tab |
| `:pwd` | Print current working directory |
| `:Z {keywords}` (or `:z {keywords}`) | `cd` to the best zoxide match (e.g. `:z nix nixos`) and print `cd <dir>`; without arguments it opens the fuzzy zoxide directory picker; without zoxide installed one warning |

### Path modifiers (for use in commands)

| Modifier | Meaning | Example |
| --- | --- | --- |
| `%` | Current file path | `/home/user/project/src/main.lua` |
| `%:h` | Directory of current file | `/home/user/project/src` |
| `%:t` | Filename only | `main.lua` |
| `%:p` | Full absolute path | `/home/user/project/src/main.lua` |

---

# 57. File management for developers

## File operations

| Plugin / Feature | What it does |
| --- | --- |
| **nvim-tree** (`<Space>s`) | Visual file browser. Create (`a`), delete (`d`), rename (`r`), copy (`c`), cut (`x`), paste (`p`). |
| **vim-eunuch** | Unix file commands, all available from a fresh start (lazy `cmd` list): `:Rename <newname>`, `:Move <path>` (move the file, creating directories), `:Duplicate <name>`, `:Copy <path>`, `:Delete` / `:Remove` / `:Unlink` (delete the file; `:Delete` also the buffer, and it needs `!` for a file that has content; tested), `:Mkdir <dir>` (always creates the missing parent folders, like `mkdir -p`; do NOT type `-p`, it would become part of the folder name; a `!` makes no difference; with no argument it creates the folder of the current file; an existing folder only gives the message "Directory already exists"), `:Chmod <mode>`, `:Cfind` / `:Lfind` / `:Clocate` / `:Llocate` (find / locate into the quickfix / location list), `:SudoEdit`, `:SudoWrite`, `:Wall` (write all) and `:W` (= `:Wall`). |
| **gx.nvim** (`gx`) | Open the URL or file path under cursor in a browser. |
| `:CopyPath absolute` | Copy the full file path to clipboard. |
| `:CopyPath relative` | Copy path relative to project root. |
| `:CopyPath nameonly` | Copy just the filename. |

Examples of the vim-eunuch commands (all tested in a scratch project, checking the files on disk and the buffer afterwards; the cursor is in the buffer `lua/old.lua` and Neovim was started in the project root):

| Command | Result on disk |
| --- | --- |
| `:Rename new.lua` | `lua/old.lua` becomes `lua/new.lua` (a bare name is relative to the file's folder); the buffer follows the file |
| `:Duplicate copy.lua` | `lua/copy.lua` is written next to it, and the buffer now shows `lua/copy.lua` (the original stays) |
| `:Mkdir a/b/c` | the folders `a/b/c` are created, relative to the folder Neovim was started in (here the project root), NOT to the file's folder |
| `:Delete` | refuses with `File not empty (add ! to override)` as long as the file has content |
| `:Delete!` | the file is deleted from disk and its buffer is closed (Neovim shows the previous buffer) |
| `:Move lua/sub/m2.lua` | the file is moved there (the missing folder `lua/sub` is created) and the buffer is renamed to `lua/sub/m2.lua`, with its text intact |
| `:Remove` | the file is deleted from disk; the buffer keeps its name but is reloaded EMPTY and unmodified (tested: `u` brings the TEXT back into the buffer, marked modified, but the file stays deleted until you save it with `:w`) |

## Project structure navigation

| Keymap | What it does |
| --- | --- |
| `<Space>s` | Toggle file tree sidebar |
| `<Space>ff` | Fuzzy-find any file in the project |
| `<Space>fg` | Search for text across all project files |
| `<Space>cd` | Change the working directory of THIS window only (`:lcd`) to the current file's folder and print it |
| `<Space>t` | Toggle the symbol outline (aerial) for the current file |

---

# 63. Working with multiple files

## Opening several files

| Method | How |
| --- | --- |
| From command line | `nvim file1.py file2.py file3.py` (opens all as buffers) |
| From inside Neovim | `<Space>ff` to find and open files one at a time |
| Split open | `:vs file2.py` opens file2 in a vertical split next to current file |
| Tab open | `:tabe file2.py` opens in a new tab |
| From file tree | `<Space>s`, navigate to file, press `<Tab>` to open without leaving the tree |

## Comparing two files side by side

1. Open the first file
2. `:vs second_file.py` -- open the second file in a vertical split
3. Now both files are visible side-by-side
4. Use `<Ctrl-w>h` / `<Ctrl-w>l` to switch between them
5. Use `:diffthis` in each window to enable diff mode (highlights differences)
6. Leave diff mode (tested): `:diffoff` turns it off only in the window you are in, so the other window still shows the diff until you run it there too. `:diffoff!` turns it off in all windows of the tab at once. To get rid of the second file as well, close its window with `:q` (or `<Ctrl-w>c`); with one window left diff mode ends by itself. `:only` / `<Ctrl-w>o` keeps just the current window.

What it looks like for two files that differ in two lines (tested; the changed lines are highlighted in colour, `*` marks them here):

```
 d1.txt                      |  d2.txt
   1  one                    |    1  one
*  2  two                    | *  2  TWO
   3  three                  |    3  three
   ...                       |    ...
* 15  fifteen                | * 15  15
  16  sixteen                |   16  sixteen
```

In the real window, a line that exists only in one file is highlighted in green there (an added line), and the other window shows diagonal hatching (`/////`) at that position: these are filler lines that keep both windows aligned (seen on screen: the left file had one line, the right file three, so the left window showed hatching under its line and the right window showed line 3 in green). The bar at the top of the screen (the buffer tabs) lists buffers in the order they were opened, not the positions of the windows: after `nvim d1.txt` then `:vs d2.txt`, `d2.txt` is the second tab even though its window is on the left or right of the split.

Or use the diffview plugin: `:DiffviewOpen` for git diffs.

## Copying between files

1. In file A: select text with `V` or `v`, then `y` to yank
2. Switch to file B: `<Ctrl-w>l` or `gb` or `<Space>bp`
3. Navigate to where you want the text
4. `p` to paste

Since clipboard is `unnamedplus`, yanked text is shared across all buffers and even with external applications.

## Running the same edit across multiple files

Use the quickfix list:

1. `:grep "TODO"` -- find all files with "TODO"
2. `:cfdo %s/TODO/DONE/g | update` -- replace in every file of the list and save it

## Closing files you're done with

| Keymap | What it does |
| --- | --- |
| `\d` | Close current buffer, keep window |
| `\D` | Close all other buffers EXCEPT those with unsaved changes or a still-running terminal (one message says how many were kept) |
| `<Space>q` | Save the buffer if modified, then close the window (last window: quits nvim) |

---
