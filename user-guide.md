# nvim guide

# Quick Reference

| Keymap | Action |
| --- | --- |
| `k` | move up |
| `j` | move down |
| `y` | copy (normal mode) |
| `p` | Paste (normal mode) |
| `viw` | Select current word (visually in word) |
| `<option>k` | Move single line up |
| `<option>j` | Move single line down |
| `<shift>v j|K <option>k` | Move multiple lines up |
| `<shift>v j|K <option>j` | Move multiple lines up |
| `<leader>fg` | Project-wide text search |
| `<leader>o` | Insert blank line below |
| `<leader>O` | Insert blank line above |
| `<leader>bp` | Switch buffer (opened file) |
| `<leader>s` | Toggle file explorer (nvim-tree) |
| `<leader>gs` | Git status |
| `<leader>gw` | Git add current file |
| `<leader>gc` | Git commit |
| `<leader>gpu` | Git push |
| `<leader>gpl` | Git pull |
| `<leader>gbn` | Create new Git branch |
| `<leader>gbd` | Delete Git branch |
| `<leader>q` | Quit current window |
| `<leader>Q` | Quit all/close nvim |
| `<leader>w` | Save buffer |
| `<leader>jk<leader>w` | exit editing mode and save buffer |
| `<leader><leader>` | Remove trailing whitespace |
| `<leader>y` | Yank entire buffer (copy entire buffer) |
| `<leader>cl` | Toggle cursor column |
| `<leader>cd` | Change working directory to absolute path of the current opened file |
| `<leader>t` | Toggle tag outline window |
| `<leader>K` | Hover symbol info |
| `gd` | Go to definition (official documentation) |
| `<leader>rn` | Rename symbol (all occurences) |
| `<leader>ca` | Code actions |
| `[d` / `]d` | Prev/next diagnostic (errors/warnings/hints) |
| `<leader>xx` | Project wide diagnostic |
| `<ctrl>wj` | Move to the window below |
| `<ctrl>wk` | Move to the window above |
| `gcc` | Toggle comment line (automatically recognize the language). This work when nothing is selected (apply to cursor position) |
| `gc` | Toggle comment selection on a single line selected with <shift>v or multiple lines selected using<shift> j | k |
| `gcr` | Remove comment on this line/selected lines. Supported languages javascript/typescript/java/c/cpp/rust/golang/css/php/xml/html/markdown |
| `Alt-m` | Markdown preview |
| `<leader>cz` | Toggle spell check |
| `<leader>p` | Paste copied text below (normal/non-linewise) |
| `<leader>P` | Paste copied above (normal/non-linewise) |
| `<leader>v` | Reselect last pasted text (show the copied text) |
| `<ctrl>ws` | Open horizontal split |
| `<ctrl>ws` | Open vertical split |
| `b]` / `gB` | go to previous opened tab (buffer) |
| `[b` / `gb` | go to next opened tab (buffer) |
| `sv` | Reload init.lua (reload entire neovim configuration) |
| `ggVG` | Select all the content of the file |
| `gg` | Go to start of document (normal mode) |
| `G` | Go to end of document (normal mode) |

# Startup and File Explorer

## File Explorer:  nvim-tree + word grep

### General

| Action | Keymap | Description |
| --- | --- | --- |
| N/A | `<leader>s` | Toggle nvim-tree file explorer (side window) |
| N/A | `<leader>ff` | Fuzzy file search via fzf-lua |
| N/A | `<leader>fr` | Fuzzy file recently opened files (fzf-lua) |
| `:vimgrep` or `:grep` | `<leader>fg` | Search for word or pattern in project |
| N/A | `<enter>` | If pressed on a directory: Expand the selected directory

If pressed on a file: Open it and move the cursor to the file |
| N/A | `<tab>` | If pressed on a directory: Expand the selected directory

If pressed on a file: Open it but keep the cursor on the file explorer |
| N/A | `<delete>` | Close the selected directory |

### Adding/rename/deleting/copy/paste

| Keymap(s) / Vim Motion | Description |
| --- | --- |
| In nvim-tree | `d` followed by “y” to confirm and “n” to deny |
| In nvim-tree | `r` followed by the new name |
| In nvim-tree | `c` (copy), `x` (cut), `p` (paste) |
| See copy/cut/paste | Use cut and paste in nvim-tree |
| Use nvim-tree UI | In file explorer: `a` (new file) |
| Use nvim-tree UI | In file explorer: `a` (new file) followed by “/” |

### Move single and multiple lines

| Keymap(s) / Vim Motion | Description |
| --- | --- |
| `<option>k` | Move line where the cursor is up |
| `<option>j` | Move line where the cursor is down |
| `<shift>v j|K <option>k` | Move line where the cursor is up |
| `<shift>v j|K <option>j` | Move line where the cursor is down |

---

# Essential Editing

## Cut, Copy, Paste, Delete, Undo/Redo, indent

| Operation | Keymap(s) / Vim Motion | Description |
| --- | --- | --- |
| N/A | `d` (Normal) | Cut/delete current line/word (depending on the selection) |
| N/A | Select lines (Visual), then `d` | Delete multiple lines |
| N/A | `y` | see keymaps that appear as options |
| N/A | `yy` (Normal) | Yank/copy current line |
| N/A | Select lines (Visual), then `y` | Yan/copy multiple lines |
| N/A | `p`/`P` | Paste after/before cursor |
| N/A | `<leader>P` | Paste above current line (custom) |
| N/A | `<leader>p` | Paste below current line (custom) |
| N/A | `x` | Remove text (also cuts to register) |
| `:undo` | `u` (Normal) | Undo previous change |
| `:redo` | `Ctrl+r` (Normal) | Redo undone change |
| N/A | `<leader>y` (copy), `<leader>d` (delete) | Yank/delete entire buffer |
| N/A | `<shift>>` | Intend the code (from right to left). Work with single and multiple lines selection |
| N/A | `<shift><` | Deindent the code (from right to left). Work with single and multiple lines selection |
| N/A | `ciw` | delete the currently selected word. Then replace with what is written after.

After that it is possible to press n/N and then “.” to apply the same change to the next match |

## Selection

to select the entire file use `<ggVG>`

### Word selection

| Keymap(s) / Vim Motion | Description |
| --- | --- |
| `v`(Visual) + movement | Visual Line mode for multi-line ops; then use `d`, `y`, `p` etc. |
| `viw` | Select a word (includes surrounding whitespace) |
| `viW` | Select inner WORD (including punctuation) |
| `vaw` | Select a word (includes surrounding whitespace) |
| `vi<char>+space` | Select a word inside a certain character, for example `vi"+space` would select the word inside |
| `ci<char>+space` | Select a word inside a certain character, and enter insert mode to replace the contend |
| `di<char>+space` | Delete a word inside a certain character |
| `vaW` | Select a WORD (with whitespace) |
| `v0` /`0` | From start of line to cursor position |
| `v$` /`$` | From start of line to cursor position |
| `vb` | from cursor position to previous word (until punctuation) |
| `vB` | from cursor position to previous word (until whitespace) |
| `vb` | from cursor position to next word (until punctuation) |
| `vB` | from cursor position to next word (until whitespace) |
| `ve` | from cursor position to the end of the current word (until punctuation) |
| `vE` | from cursor position to the end of the current word word (until whitespace) |
| `vG` | from cursor position to last line |
| `gg` | Go to first line |

### Character selection

| Keymap(s) / Vim Motion | Description |
| --- | --- |
| `vc` | delete character and enter insert mode |
| `vd` | delete character (stays in normal mode) |
| `h` | Move to previous character (including whitespaces) |
| `l` | Move to next character (including whitespaces) |
| `y` | copy character |

### Lines selection

| Keymap(s) / Vim Motion | Description |
| --- | --- |
| `V` (Visual) + movement | Visual Line mode for multi-line ops; then use `d`, `y`, `p` etc. |
| Select lines (Visual), then `d` | Delete multiple lines |
| `y` | Yank with different options. Press y and see keymaps that appear as options |
| `yy` (Normal) | Yank/copy current line |
| `:-5,+10yank"*` | Copy to special register 5 row  before the cursor and 10 lines after the cursor (relative line number) |
| `:-5,+10yank` | Copy  5 row  before the cursor and 10 lines after the cursor (relative line number) |
| `:2,10yank"*` | Copy to special register from line 2 to line 10 (absolute line number) |
| `:2,10yank` | Copy from line 2 to line 10 (absolute line number) |
| `5j<shift>V6j` | First enter visual mode. Then move to the starting line. Then use number + j or k to move the selection to the target. In this example it select lines from 5 after the cursor to 11 after the initial cursor and to 6 after the cursor moved for the first time. Essentially it copy 6 lines |

---

## Searching and Replacing in Current File (set aka substitute)

the code after `:%s` act as a delimiter. it can be changed if the text to replace include the delimiter itself to prevent a premature substitution for example `:%s#` instead of `:%s/` if the text to replace include`“/”`

| Operation | Keymap | Description |
| --- | --- | --- |
| N/A | `/word` | First method to search for a word |
| N/A | `<shift>*` | Second method to search for a word. It first require to hover the cursor on the word to serach |
| N/A | `:%s/old/new/` | Replace word only in current line |
| N/A | `:%s/old/new/g` | Replace word across all file (global) |
| N/A | `:%s/old/new/gc` | Replace word across all file. It ask for confirmation each replacement |
| N/A | `:%s#/oldpart1/oldpart2/newpart1/newpart2` | Replace the text if it include a slash “/”. “#” can be almost any symbol, what matters is that it never appear on the text to replace |
| N/A | `:%s\/oldpart1/oldpart2\/newpart1/newpart2` | Replace the text if it include a slash “/”. “\”act as a placeholder that tell it to keep the text. The new text start only after there is a “/” alone |
| `:previous` | `n` | Move to next match |
| `:next` | `N` | Move to previous match |

### Possible flags

| Keymap | Description |
| --- | --- |
| `:%s/` | Entire buffer (file) |
| `:.,$s` | From cursor to end of file |
| `:20,30s/` | From line 20 to line 30 (absolute line numbers) |
| `:-3,+3s/` | From current line - 3 to current line + 3 |
| `:s/` | Only current line |

---

# Registers

## General register

Work only inside neovim

| Keymap(s) / Vim Motion | Description |
| --- | --- |
| `"3y` | Yank (copy) to buffer with a specific register id “3 |
| `"3p` | Select a word (includes surrounding whitespace) |

## Special register

Work also outside neovim

- Windows + linux —> “+
- Mac os —> “*

| Keymap(s) / Vim Motion | Description |
| --- | --- |
| `"*y` | Yank (copy) to buffer with a specific register id “3 |
| `"*p` | paste from special register inside neovim. Not very used since inside neovime the regular register exist. For pasting outside neovim the normal paste keybindings are necessary. Eg <ctrl>c / <cmd>c |

# Macros

- Record an action, for example enclosing a text in double quotes and allow to re do it for other lines
- The recordings are done to a specific register
    - If a register already exist it is overwritten by the macro
    - it is possible to avoid this by checking before existing registers with `:reg`
    - macro recording is started with `Q` and recorded with the identifier of the letter after. For example `Qh` record macro to register “h”
    - if a macro require to modify the row. on top/before the current line it is suggested to also include the movement in the macro, so that it automatically move line after apply the changes to the current line.

| Keymap(s) / Vim Motion | Description |
| --- | --- |
| `Qh` | Record macro to reg “h |
| `q` | Stop macro recording  |
| `@h` | Apply macro at register “h to new line |
| `5@h` | Apply macro at register “h to the current line and 4 more (5 in total) |

# Working with directories

Changing Neovim’s working directory sets the base folder used for resolving relative paths and for external commands run via :!, so project navigation and tools operate relative to that directory.

## General navigation

| Operation | Scope | What It Does |
| --- | --- | --- |
| `:cd %:h` | Global | Changes the working directory globally for all windows and tabs to the directory of the current file. Affects the entire Neovim instance. |
| `:lcd %:h` | Window | Changes the working directory locally for the current window only. Other windows/splits maintain their own directories. Most commonly used. |
| `:tcd %:h` | Tab | Changes the working directory for the current tab. All windows within this tab share this directory, but other tabs are unaffected. |
| `:cd <path>` | Global | Changes to an absolute or relative path globally. |
| `:lcd <path>` | Window | Changes to an absolute or relative path for current window only. |
| `:tcd <path>` | Tab | Changes to an absolute or relative path for current tab only. |
| `:pwd` | N/A | Prints the current working directory. Use this to verify where you are. |
| `set autochdir` | Global | Automatically changes to the directory of the file being edited whenever you switch buffers. |

## Path Modifiers Explained

| Operation | Meaning | Example |
| --- | --- | --- |
| `%` | Current file path | `/home/user/project/src/main.lua` |
| `%:h` | Head (directory) of current file | `/home/user/project/src` |
| `%:t` | Tail (filename) of current file | `main.lua` |
| `%:p` | Full absolute path | `/home/user/project/src/main.lua` |
| `%:p:h` | Absolute directory path | `/home/user/project/src` |

## Recommendation

Use **`:lcd %:h`** for most situations as it keeps your directory changes isolated to the current window, preventing unexpected behavior when working with multiple files.

---

# Window/Tabs/Buffer Management

| Operation | Keymap/command | Description |
| --- | --- | --- |
| N/A | `b]` / `gB` | go to previous opened tab (buffer) |
| N/A | `[b` / `gb` | go to next opened tab (buffer) |
| N/A | `\d` | Close the current buffer (ask for confirmation) |
| N/A | `\D` | Delete all buffers that are not the currently opened one |
| `:buffer` | `<leader>bp` | Every buffer will have a letter on the left of it’s name, just type it after to open it |
| N/A | `<ctrl>wv` | Open horizontal split |
| N/A | `<ctrl>ws` | Open vertical split |
| N/A | `Ctrl-h/j/k/l` (arrow keys mapped) | Move between splits (keymaps for arrows) |
| N/A | `<leader>q` | Quit current window (split) |
| N/A | `<leader>Q` | Quit all windows. Careful it does not ask for confirmation |
| N/A | `<ctrl>wj` | Move to the window below |
| N/A | `<ctrl>wk` | Move to the window above |

---

# Terminal Integration

| Operation | Keymap | Description |
| --- | --- | --- |
| `:term`  | `:terminal` | N/A | Open the terminal |

---

# Code operations: running, testing, refactoring,debugging

## General code running

| Keymap / Command | Command | Description |
| --- | --- | --- |
| `<leader>rr` | N/A | python/java/c/cpp/cs/javascript/typescript/golang/rust/bash/lua/ruby/php |
| `Alt-m` |  | Preview Markdown in browser  |
| `\ll` (vimtex) |  | Compile/build with vimtex  |

## Running & refactoring

### Java specific keymaps

| Command | Keymap / Command | Description |
| --- | --- | --- |
| `:JavaRunnerRunMain` | `<leader>jr` | Run code |
| `:JavaBuildBuildWorkspace` | `<leader>jb` | Build workspace |
| `:JavaBuildBuildWorkspace` | :JavaBuildCleanWorkspace | Clean workspace. It require to close and reopen neovim for changes to take effect |
| `:JavaRefactorExtractConstant` | `<leader>jc` | Create a constant from the value at cursor/selection |
| `:JavaRefactorExtractVariable` | `<leader>jv` | Create a variable from value at cursor/selection |
| `:JavaRefactorExtractField` | `<leader>jf` | Create a field from the value at cursor/selection |
| `:JavaRefactorExtractMethod` | `<leader>jm` | Create a method from the value at cursor/selection |
| `:JavaDapConfig` | `<leader>jd` | DAP is autoconfigured on start up, but in case you want to force configure it again, you can use this API |
| `:JavaSettingsChangeRuntime` | `<leader>jj` | Change the JDK version to another (for now it does nothing, I didn't define another runtime) |
| `:JavaRunnerToggleLogs` | `<leader>jl` | Toggle between show & hide runner log window (show/hide the bottom runner log window) |
| `:JavaTestDebugCurrentMethod` | `<leader>jM` | Debug the test method on the cursor |

### Java Refactoring

| **Command** | **Explanation** | **Example code before** | **Example code after** |
| --- | --- | --- | --- |
| `:JavaRefactorExtractVariable` | Extracts the selected value/expression to a new local variable, improving readability. | `int area = 3.14 * r * r;` | `double temp = 3.14 * r * r;
int area = temp;` |
| `:JavaRefactorExtractVariableAllOccurrence` | Extracts all appearances of the selected value/expression to a single local variable for DRY code. | `int a = data * 100;
int b = data * 100 + 3;` | `int factor = data * 100;
int a = factor;
int b = factor + 3;` |
| `:JavaRefactorExtractConstant` | Extracts a literal to a static final constant to avoid "magic numbers." | `double circumference = 2 * 3.14 * r;` | `private static final double PI = 3.14;
double circumference = 2 * PI * r;` |
| `:JavaRefactorExtractMethod` | Moves selected code into a new method, replacing it with a call for modularity. | `int sum = 0;
for (int i = 0; i < arr.length; i++) sum += arr[i];` | `int sum = calculateSum(arr);
private int calculateSum(int[] arr) {
int sum = 0;
for (int i = 0; i < arr.length; i++) sum += arr[i];
return sum;
}` |
| `:JavaRefactorExtractField` | Lifts a value to a class field, making it accessible to methods or other parts of the class. | `void greet() {
System.out.println("Hello");
}` | `private String greeting =      "Hello";
void greet() {`
`System.out.println(greeting);
}` |
|  |  |  |  |

### Java Testing

| **Command** | **Explanation** | **Example code** | **Effect** |
| --- | --- | --- | --- |
| `:JavaTestRunCurrentClass` | Runs all test methods in the current class, useful to check if an entire test suite passes. | `public class MathTest {
    @Test
    void testAdd() {}
    @Test
    void testSub() {}
}` | Runs both testAdd and testSub |
| `:JavaTestDebugCurrentClass` | Debugs all test methods in the current class for step-by-step inspection while running all tests. | `public class MathTest {
    @Test
    void testAdd() {}
    @Test
    void testSub() {}
}` | Launches debugger on both testAdd and testSub |
| `:JavaTestRunCurrentMethod` | Runs only the test method under the cursor, handy when you want to test just one. | `public class MathTest {
    @Test
    void testAdd() {}` //cursor here
    `@Test
    void testSub() {}
}` | Runs only testAdd |
| `:JavaTestDebugCurrentMethod` | Debugs only the test method at the cursor for fine-grained inspection. | `public class MathTest {
    @Test
    void testAdd() {}
    @Test
    void testSub() {}` //cursor here
`}` | Launches debugger for just testSub |
| `:JavaTestViewLastReport` | Shows the last test report in a popup, useful to check summary, errors, or stack traces after a run. | `public class MathTest {
    @Test
    void testAdd() {}
    @Test
    void testSub() {}
}` | Opens a popup UI showing pass/fail output |

A few notes:

- DAP: The Debug Adapter Protocol is a standardized protocol created by Microsoft that defines communication between a development tool (like Neovim) and a debug adapter (debugger). It allows editors to support debugging for multiple languages through a unified interface.

### Debugging (da completare)

---

# Code documentation

| Keymap | Description |
| --- | --- |
| `<shift>k` | Show documentation for symbol under cursor |
| `gd` | Go to definition |
| `gr` | Show usage references (show everytime it's used) |
| `<leader>t` | Opens a sidebar that displays a hierarchical outline of the current file's structure, including:
- **Classes** and interfaces with line numbers
- **Methods** and functions with their signatures
- **Package** declarations
- **Variables** and fields
- Other code symbols and tags |

---

# LSP: Code Actions, Diagnostics & Formatting

## Code actions, formatting & renaming

| Keymap | Description |
| --- | --- |
| `<leader>ca` | Trigger code actions/quick fixes
There are various option so see what comes up |
| `<leader>rn` | Rename symbol (all occurences).
You need to be at the end of the current symbol, if not it will replace all the content with the first letter that was pressed after |
| `<leader>fm` | Format a file (if there are no errors). It needs a language server, they can be added in lsp.lua |

## Code diagnostics

Warning near the line numbers that show where errors are

| `[d` | Jump to next diagnostic issue |
| --- | --- |
| `]d` | Jump to previous diagnostic issue |

---

# File opening

| Command | Shorthand | Description | Use Case |
| --- | --- | --- | --- |
| `:edit /path/to/file` | `:e` | Opens file in current window (replaces view but keeps original buffer) | Quick file switching in same window |
| `:badd /path/to/file` | - | Adds file to buffer list without displaying it | Load file in background |
| `:split /path/to/file` | `:sp` | Opens file in horizontal split | View two files vertically stacked |
| `:vsplit /path/to/file` | `:vs` | Opens file in vertical split | View two files side by side |
| `:tabedit /path/to/file` | `:tabe` | Opens file in new tab | Separate workspace/context |

# Git Integration (vim-fugitive)

| Operation | Keymap | Description |
| --- | --- | --- |
| `:Git` | `<leader>gs` | Show git status window |
| `:Git add` | `<leader>gw` | Git add current file |
| `:Git commit` | `<leader>gc` | Commit staged changes |
| `:Git push` | `<leader>gpu` | Git push |
| `:Git pull` | `<leader>gpl` | Git pull |
| `:Git branch` | `<leader>gbn` | Create new branch |
| `:Git branch -d` | `<leader>gbd` | Delete a branch |
| N/A | `<leader>gbr` | (macOS only) Open repo in browser |

---

# Built-in Commands

| Command | Description |
| --- | --- |
| `:Lazy` | Open Lazy.nvim plugin manager UI |
| `:Lazy update` | Update plugins |
| `:Lazy config` | Edit plugin config |
| `:Telescope keymaps` | Show defined keymaps |
| `:term` | Open terminal split |
| `:edit` | Open file for editing |
| `:Redir` | Capture command output to tabpage |
| `:Edit` | Edit multiple files (*.vim etc) |
| `:Datetime` | Print or convert Unix date/time |
| `:JSONFormat` | Format JSON file |
| `:CopyPath` | Copy current file path to clipboard |
| `:Vista` | Open code outline window |
| `:set relativenumber` | Set line numbers to relative |
| `:set norelativenumber` | Set line numbers to absolute |

---

# UI/UX

| Keymap | Description |
| --- | --- |
| `<leader>cz` | Toggle spell checking in normal/insert mode |
| `<leader>cl` | Toggle highlight for cursor column |

---

# Autocompletion (`nvim-cmp`)

**What:** Provides completion menus for code, snippets, and words as you type.

| Keymap | Description |
| --- | --- |
| `<ctrl>p` | Go to previous suggestion |
| `<tab>` | Got to next suggestion |
| `<tab>` | Accept suggestion |
| `<ctrl>e` | Close suggestion menu/decline suggestion |

---

---

# Fast Code Commenting (`vim-commentary`)

Quick code commenting/uncommenting.

| Keymap | Description |
| --- | --- |
| `gcc` | Toggle (insert) comment on current line (Normal mode) |
| `gc` | Toggle (insert) comment on selection |
| `gcr` | Remove comment on this line/selected lines. Supported languages:
python / lua / javascript / typescript / java / c / cpp / rust / go / php / ruby / sh / bash / zsh / vim / sql / r / perl / yaml / toml / tex / matlab / haskell / cs / swift / kotlin / scala / elixir / clojure / lisp / scheme / julia / dart / groovy / css / html / xml / markdown |

---

# Matching Pair Insertion / Jump (`nvim-autopairs`)

**What:** Auto-inserts pairs (like parentheses, brackets) and moves cursor between them smartly.

**How to Use:**

- Works automatically as you type.
- Example: Typing `(` automatically inserts `)` and places the cursor between them.
- Special jump behavior for faster coding.

---

# Matching Pair Management (`vim-sandwich`)

**What:** Add, replace, delete surrounding pairs (quotes, tags, etc.).

**How to Use:**

- Keymaps (Normal/Visual):
    - `sa`: Add surroundings
    - `sd`: Delete surroundings
    - `sr`: Replace surroundings
    
    | Keymap | Description |
    | --- | --- |
    | `sa` | Go to previous suggestion |
    | `sr` | Replace parenthesis/quote with the one defined. For example to change a matching set of “()” into “{}” one would type `sr({` .
    To replace “” into ‘’ one would type `sr”’` |
    | `sd` | Remove parenthesis/quotes. It require a return to confirm For example to remove a set of “” one would type `sd” <return>`  |

---

# Fast Buffer Jump (`hop.nvim`)

**What:** Quickly jump to any visible text using as few keystrokes as possible.

**How to Use:**

| Keymap | Description |
| --- | --- |
| `f` | After “f” write 2 character of the match to find. After that all the matches will be highlighted with a letter. Just write that letter and you jump to that match |

---

# Snippet Insertion (`Ultisnips`)

**What:** Insert and expand code snippets quickly.

**How to Use:**

- Trigger snippet expansion with `<Tab>` after typing snippet trigger.
- Custom snippets are in `my_snippets/` for languages like Python, LaTeX, etc.

| Keymap | Description |
| --- | --- |
| `<Tab><enter>` | Start writing the snippet. then it appear as snipped, press <Tab> and confirm the expansion with <enter> |
| `<ctrl>j` | Next snippet placeholder |
| `<ctrl>k` | Previous snippet placeholder |

## Java snippets

| Name of the snippet | what it expands to |
| --- | --- |
| startscanner | Java Scanner input template |
| jarr | Java array definition |
| jarrlit | Java array with literal values |
| jdict | Java HashMap definition |
| jdictfull | Java HashMap with import |
| jfor | Java for loop |
| jforeach | Java enhanced for loop |
| jwhile | Java while loop |
| jdowhile | Java do-while loop |
| jif | Java if statement |
| jifelse | Java if-else statement |
| jifelif | Java if-else if-else statement |
| jswitchtraditional | Java traditional switch statement |
| jswitchmulti | Java traditional switch with multiple cases |
| jswitcharrow | Java switch with arrow syntax |
| jswitcharrowmulti | Java switch arrow with multiple cases |
| jswitchyield | Java switch expression with yield |
| jswitchyieldblock | Java switch expression with yield blocks |
| jtrycatch | Java try-catch block |
| jtryfinally | Java try-catch-finally block |
| jwhilescannerbreak | Java while block with exiting case |

---

# Statusline (lualine.nvim)

## Section overview

| Section | Position | Elements shown | Example / Notes |
| --- | --- | --- | --- |
| lualine_a | Leftmost | Filename with readonly indicator | init.lua [🔒] if buffer is read-only |
| lualine_b | Left | Git branch, ahead/behind, git diff, Python venv | main ↑ +5 ~2 -1  myenv (venv) |
| lualine_c | Center-left | Showcmd, Spell indicator | %S, [SPELL] when spell-check is on |
| lualine_x | Center-right | Active LSP, Diagnostics, Trailing whitespace, Mixed indent | 📡 pyright 🆇 1 ⚠️ 3 trailing MI:2 |
| lualine_y | Right | Virtual env or Encoding, File format, Filetype, IME state | UTF-8 unix python [CN] |
| lualine_z | Rightmost | Cursor location, Progress | 145:23 45% |
| Inactive | Center-left/rightmost | Filename and location only | Other sections hidden in inactive windows |

## Git and environment details

| Item | What it shows | Formatting / Color | Data source / Timing |
| --- | --- | --- | --- |
| Git branch | Current branch name | Italic/bold, truncated to 20 chars | From repo HEAD; always visible in git repos |
| Ahead/Behind | Commits vs upstream | ↑[N] / ↓[N], yellowish #E0C479 | Updated asynchronously after fetch |
| Diff stats | Added/Modified/Removed | +X, ~X, -X | From gitsigns integration |
| Python venv | Active Python environment |  myenv (venv) or (conda), light-yellow bg | Shown only for Python filetypes |

## Editing and diagnostics

| Item | Trigger | Display | Notes |
| --- | --- | --- | --- |
| Showcmd | While typing commands | %S (current command input) | Helpful for long/complex commands |
| Spell indicator | Spell on | [SPELL] | Toggles with :set spell |
| Active LSP | LSP client attached | 📡 server-name | 🚫 shown if no client |
| Diagnostics | Buffer diagnostics | 🆇 errors, ⚠️ warnings, ℹ️ info, hints (no symbol) | Counts update live from LSP |
| Trailing whitespace | Trailing spaces present | [line]trailing | Shows first offending line number |
| Mixed indentation | Mixed tabs/spaces | MI:<count> | Count of mixed-indent occurrences |

## File metadata and locale

| Item | Where | Display | Notes |
| --- | --- | --- | --- |
| Virtual env / Encoding | lualine_y | Env name or ENCODING (UPPERCASE) | Env prioritized for Python files; else encoding |
| File format | lualine_y | unix, dos, or mac | From fileformat option |
| Filetype | lualine_y | e.g., python, lua, rust | From &filetype |
| IME state (macOS) | lualine_y | [CN] | Shown when a Chinese input method is active |

## Location and progress

| Item | Format | Example | Notes |
| --- | --- | --- | --- |
| Cursor location | line:column | 145:23 | Always shown in lualine_z |
| Progress | Percent through file | 45% | Relative to total buffer lines |

## Configuration behaviors

| Feature | How it works | Key mechanism |
| --- | --- | --- |
| Git status (ahead/behind) | Compares HEAD with upstream after async git fetch | Custom async function + git plumbing |
| LSP client name | Per-buffer detection of attached clients and capabilities | vim.lsp.get_clients and capability checks |
| Diagnostics counters | Aggregated from current buffer diagnostics | LSP diagnostic API |
| Python environment | Reads venv/conda for Python buffers | Environment variables / interpreter context |
| IME indicator | Detects macOS input method state | Mac-specific IME query |
| Trailing/mixed indent | On-the-fly scan of current buffer | Lightweight buffer inspection |
| Highlights | Custom highlight groups for Cmp item kinds and menus | Overridden highlight groups |
| Extensions | Tailored statusline for Quickfix, Fugitive, Nvim-tree | lualine extensions enabled |

## Example output, decoded

| Token | Meaning |
| --- | --- |
| [config.py](http://config.py) | Current filename |
| main ↑ | On branch main, ahead by 2 commits |
| +5 ~2 -1 | Diff: 5 additions, 2 modifications, 1 removal |
| myenv (venv) | Active Python virtual environment |
| [SPELL] | Spell-check enabled |
| 📡 pyright | LSP client pyright attached |
| 🆇 1 ⚠️ 3 | Diagnostics: 1 error, 3 warnings |
| trailing | Trailing spaces at line 23 |
| UTF-8 unix python | Encoding UTF-8, fileformat unix, filetype python |
| 145:23 45% | Cursor at 145:23, 45% through file |

## Quick cheat sheet

| Area | Contents |
| --- | --- |
| Leftmost | Filename, readonly indicator |
| Left block | Git branch, ahead/behind, diff, Python venv |
| Center-left | Showcmd, Spell indicator |
| Center-right | Active LSP, Diagnostics, Trailing whitespace, Mixed indent |
| Right | Encoding or Env, File format, Filetype, IME |
| Far-right | Cursor location, Progress |

---

# Quickfix List (nvim-bqf)

## Overview

| Aspect | Description |
| --- | --- |
| What it is | A Neovim plugin that upgrades the built-in **quickfix** and **location list** with a live preview, better layout, and smarter navigation. |
| Purpose | Triage search results, diagnostics, and build/test errors faster without opening every file. |
| Integrations | Works with `:vimgrep`, `:grep`, `:make`, Telescope/rg exports to quickfix, and LSP diagnostics. |
| Behavior | Uses native quickfix/location lists; you keep using `:copen`, `:cnext`, etc., and bqf augments the UI. |
| Preview | Follows the selected entry and shows syntax-highlighted context so you can decide before jumping. |

## Quickfix vs Location list

| Feature | Quickfix List | Location List |
| --- | --- | --- |
| Scope | Global to the Neovim session | Local to a single window/buffer |
| Open/Close | `:copen` / `:cclose` | `:lopen` / `:lclose` |
| Navigation | `:cnext`, `:cprev`, `:cfirst`, `:clast` | `:lnext`, `:lprev`, `:lfirst`, `:llast` |
| Jump to entry | `:cc [nr]` | `:ll [nr]` |
| History | `:colder`, `:cnewer` | `:lolder`, `:lnewer` |
| Typical sources | Searches, builds, LSP across project | Buffer-specific searches or diagnostics |
| bqf support | Enhanced UI + preview | Enhanced UI + preview |

## Essential commands

| Command | What it does |
| --- | --- |
| `:copen` / `:cclose` | Open/close the quickfix window. |
| `:cnext` / `:cprev` | Jump to next/previous quickfix item. |
| `:cfirst` / `:clast` | Jump to first/last item. |
| `:cc [nr]` | Jump directly to entry number `[nr]`. |
| `:cdo {cmd}` | Run `{cmd}` for each quickfix entry (batch edits). |
| `:colder` / `:cnewer` | Move backward/forward in quickfix history. |
| `:lopen` / `:lclose` | Open/close the location list window. |
| `:lnext` / `:lprev` | Navigate location list entries. |
| `:ll [nr]` | Jump to numbered location entry. |
| `:ldo {cmd}` | Run `{cmd}` for each location-list entry. |
| `:vimgrep /pat/ **/*` | Populate quickfix with search results. |
| `:make` | Populate quickfix with compiler/build output. |
| `:lua vim.diagnostic.setqflist({open=true})` | Send LSP diagnostics to quickfix and open it. |

## Common workflows

| Task | Steps (short) | Notes |
| --- | --- | --- |
| Project search triage | `:vimgrep /pattern/ **/*` → `:copen` → navigate with `:cnext/:cprev` → Enter to open | Preview shows context; use splits with standard window commands. |
| Review LSP diagnostics | `:lua vim.diagnostic.setqflist({open=true})` → navigate → fix | Keep the list open while editing; preview updates as you move. |
| Build/test failures | `:make` → `:copen` → jump through errors → re-run | Combine with `:colder/:cnewer` to compare runs. |
| Buffer-local issues | Populate location list (via plugin or search) → `:lopen` → `:lnext/:lprev` | Use when you only care about the current file/window. |
| Batch edits | Populate quickfix → `:cdo s/foo/bar/g` → verify | Use with care; version control recommended. |

## Tips and pitfalls

| Tip | Why it matters |
| --- | --- |
| Keep lists focused | Clearing/refilling quickfix keeps navigation snappy and history meaningful. |
| Prefer quickfix for global tasks | Use quickfix for project-wide searches and errors; location list for per-buffer concerns. |
| Use history navigation | `:colder/:cnewer` let you flip between previous searches/builds quickly. |
| Mind your keymaps | bqf doesn’t replace built-in motions; any custom mappings you have still apply. |
| Preview focus | Ensure the cursor is in the quickfix window (filetype `qf`) to see the live preview follow entries. |

---

# Search Lens (`nvim-hlslens`)

**What:** Shows index/count of search matches (`n`/`N` behavior improved).

**How to Use:**

- Search as usual (`/pattern` then `n`/`N`)—results are highlighted with more context and index.
- The current match is highlighted in one color, all the other in another
- [x/y] represent the number of match
    - x is the current one (where the cursor is)
    - y is the total of match found

---

# Mapping Hints (`which-key.nvim`)

**What:** Displays possible keymaps in a popup when you start a mapping sequence.

**How to Use:**

- Type `<leader>` or other mapped prefix: a guide pops up to show available options.

---

---

---

# Vim in Browser (`firenvim`)

**What:** Use Neovim as the editor for text inputs in the browser.

**How to Use:**

- Install browser extension and configure—no typical Neovim keymap unless in the browser.
- Currently not usable because google doesn't want [https://chromewebstore.google.com/detail/firenvim/egpjdkipkomnmjhjmdamaniclmdlobbo](https://chromewebstore.google.com/detail/firenvim/egpjdkipkomnmjhjmdamaniclmdlobbo)

---

---

# Markdown Support (`vim-markdown`, `markdown-preview.nvim`)

**What:** Syntax highlighting, folding, and preview for Markdown files.

| Method | Example | Notes |
| --- | --- | --- |
| N/A | `<alt>m` | Start markdown preview |
| N/A | `<shift><alt>m` | Stop markdown preview |

---

# Copilot and claude code

**Claude Code:**

| Press | Action |
| --- | --- |
| `Space c c` | Toggle Claude Code |
| `Space c t` | Toggle from terminal mode |
| `Space c R` | Resume last conversation |
| `Space c V` | Verbose mode |

**Copilot:**

| Press | Action |
| --- | --- |
| `Space c p c` | Toggle Copilot Chat |
| `Space c p e` | Copilot Explain (visual mode) |
| `Space c p o` | Copilot Optimize (visual mode) |

---

# LaTeX Editing (`vimtex`)

**What:** Enhanced LaTeX editing—compiling, preview, forward/inverse search.

**How to Use:**

- Usual workflows via commands: `\ll` to compile, `\lv` to view PDF, etc.
- Many automations for LaTeX workflow are baked in.

---

# GUI Notifications (`nvim-notify`)

**What:** Visual, animated notifications for events in Neovim.

**How to Use:**

- Displays automatically on events (e.g., errors or completion results).
- 

---

# Tags Navigation (`vista`)

**What:** Sidebar with code symbols/tags for current buffer.

**How to Use:**

- Keymap:
    - `<leader>t`: Toggle the tag window.
- Lets you jump to functions, classes, or sections easily.

---

# Undo Management (`vim-mundo`)

Graphical undo tree plugin that lets you visualize, navigate, and operate on your file’s changes (undo history) intuitively. Instead of just moving backward (undo) and forward (redo), Mundo presents the full "tree" of possible states: you can jump to any past state, inspect when changes occurred, and view diffs between states. This is particularly useful when you need to recover or compare forks in your editing history, see exactly what you did when, and choose the best recovery path—all from a convenient UI panel.

| **Keymap** | **Example Use Case** | **What It Does (Before)** | **What It Does (After)** | **Applies To** |
| --- | --- | --- | --- | --- |
| `j/k` | Move up/down the undo tree to view different states. | You are at one position in the undo tree (e.g., after 3 changes). | Cursor is now on a different node representing a different change/set of changes. | Undo state list panel (navigation) |
| `J/K` | Move up/down the write state tree (save history). | Focused on one write state in the left panel. | Moves selection up/down in the write state list. | Write state history panel |
| `i` | Toggle inline diff mode to see changes highlighted in buffers. | Viewing the buffer normally. | Diff changes are shown inline (typically highlights edits vs. original state). | Buffer window |
| `n/p` | Find next/previous change that matches the search term. | Searching for changes (e.g., matching 'int'). | Jumps to next/previous occurrence in the change list/tree. | Undo tree, with search active |
| `P` | Play current state to selected undo. (Usually for replaying changes.) | Selected a state earlier in the tree. | Undoes/redoes changes up to that selected state, buffer updates to reflect. | Undo state tree, buffer changes |
| `D` | Diff current state and selected undo state. | Have two states (one selected, one current). | Shows diff between those two states. | Diff viewer, buffer |
| `p` | Diff selected undo and current state. | Select an undo state and have a current buffer. | Shows difference between them (helpful for reviewing multiple edits). | Diff viewer |
| `r` | Diff selected undo and prior undo. | Select two consecutive undo states. | Shows difference between those states (fine-grained diff browsing). | Diff viewer |
| `q` | Quit Mundo panel and return to regular editing. | Mundo panel is open. | Panel closes, buffer regains full focus. | Mundo UI |
| `r` | Revert to selected state. | Examining a previous undo state (e.g., made a mistake). | Buffer is restored to that state, effectively undoing/redrawing all edits since then. | Buffer, undo tree |
| `<CR>(Enter)` | Apply/revert to the selected undo state. | Cursor on an undo state. | Buffer jumps to match that state—useful for quickly "time-traveling". | Undo state panel, buffer |

---

# Code Folding (`nvim-ufo`, `statuscol.nvim`)

**What:** Advanced code folding and sidebar display support.

| **Keymaps** | **What it does** | **Applies to** |
| --- | --- | --- |
| `za` | Toggle fold (open/close) at cursor | Fold under cursor |
| `zA` | Toggle all folds under cursor recursively | All nested folds under cursor |
| `zc` | Close fold at cursor | Fold under cursor |
| `zC` | Close all folds under cursor recursively | All nested folds at cursor |
| `zo` | Open fold at cursor | Fold under cursor |
| `zO` | Open all folds under cursor recursively | All nested folds at cursor |
| `zd` | Delete fold at cursor | Fold under cursor |
| `zD` | Delete all folds at cursor recursively | All nested folds at cursor |
| `zf` | Create a fold in a visual selection or at the cursor | Selected lines or current line |
| `zx` | Update folds (recompute folds in the file) | Whole file |
| `zR` | Open all folds in the file | Whole file |
| `zM` | Close all folds in the file | Whole file |
| `zE` | Delete all folds in the file | Whole file |
| `zm` | Fold more (increase folding level) | Visible folds in file |
| `zr` | Fold less (decrease folding level) | Visible folds in file |
| `zi` | Toggle folding on/off | Entire buffer/file |

---

## Notes

- For more info, see [README](https://github.com/jdhao/nvim-config?tab=readme-ov-file) and [mappings.lua](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/41213625/cd781a57-52ba-4aa8-8fcb-c624876c1d50/mappings.lua).

---