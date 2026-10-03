# Neovim User Guide

Leader key: `<Space>`

This guide is written for people who are new to Neovim. It covers everything you need to navigate, edit, and manage files without ever touching the mouse.

## Contents

Every section keeps its number; the text "see section N" in the guide refers to these numbers.

| Chapter | Sections |
| --- | --- |
| [Basics: modes, saving, recovering, getting help](01-basics.md) | [1. Understanding Modes](01-basics.md#1-understanding-modes); [69. Tips for Vim Beginners](01-basics.md#69-tips-for-vim-beginners); [70. The Verb + Noun System (How Vim Commands Work)](01-basics.md#70-the-verb--noun-system-how-vim-commands-work); [72. Saving, Quitting, and File State](01-basics.md#72-saving-quitting-and-file-state); [73. Recovering from Mistakes](01-basics.md#73-recovering-from-mistakes); [74. Discovering Keymaps and Getting Help](01-basics.md#74-discovering-keymaps-and-getting-help) |
| [Navigation](02-navigation.md) | [3. Core Navigation (Moving Without the Mouse)](02-navigation.md#3-core-navigation-moving-without-the-mouse); [22. Jump Navigation (`hop.nvim`)](02-navigation.md#22-jump-navigation-hopnvim); [23. Search Lens (`nvim-hlslens`)](02-navigation.md#23-search-lens-nvim-hlslens); [37. Symbol Outline (`aerial.nvim`)](02-navigation.md#37-symbol-outline-aerialnvim); [50. Code Navigation Strategies](02-navigation.md#50-code-navigation-strategies) |
| [Editing, text objects, macros and tricks](03-editing.md) | [4. Editing](03-editing.md#4-editing); [5. Selection (Visual Mode)](03-editing.md#5-selection-visual-mode); [6. Working with Parentheses, Quotes, and Brackets](03-editing.md#6-working-with-parentheses-quotes-and-brackets); [16. Code Commenting](03-editing.md#16-code-commenting); [17. Surrounding Pairs (`vim-sandwich` + `nvim-autopairs`)](03-editing.md#17-surrounding-pairs-vim-sandwich--nvim-autopairs); [24. Yank History (`yanky.nvim`)](03-editing.md#24-yank-history-yankynvim); [25. Undo History](03-editing.md#25-undo-history); [29. Registers & Macros](03-editing.md#29-registers--macros); [60. Macros In Depth](03-editing.md#60-macros-in-depth); [61. The Dot Command (`.`) -- Repeating Actions](03-editing.md#61-the-dot-command-----repeating-actions); [62. Visual Block Editing (Multi-Cursor-Like)](03-editing.md#62-visual-block-editing-multi-cursor-like); [64. Everyday Editing Scenarios](03-editing.md#64-everyday-editing-scenarios); [65. Swapping Function Arguments (`vim-swap`)](03-editing.md#65-swapping-function-arguments-vim-swap); [68. Useful Vim Tricks](03-editing.md#68-useful-vim-tricks); [71. The Global Command (`:g`)](03-editing.md#71-the-global-command-g); [76. Common Editing Power Combos](03-editing.md#76-common-editing-power-combos) |
| [Completion and snippets](04-completion-snippets.md) | [14. Autocompletion (`nvim-cmp`)](04-completion-snippets.md#14-autocompletion-nvim-cmp); [15. Snippets (`UltiSnips`)](04-completion-snippets.md#15-snippets-ultisnips); [45. Autocompletion In Depth](04-completion-snippets.md#45-autocompletion-in-depth); [52. Snippets for Developers](04-completion-snippets.md#52-snippets-for-developers) |
| [Searching, replacing, files and the file tree](05-search-and-files.md) | [10. Searching, Replacing, and Refactoring Text](05-search-and-files.md#10-searching-replacing-and-refactoring-text); [67. Multi-File Search and Replace (Complete Guide)](05-search-and-files.md#67-multi-file-search-and-replace-complete-guide); [12. Fuzzy Finding & Project-Wide Search (`fzf-lua`)](05-search-and-files.md#12-fuzzy-finding--project-wide-search-fzf-lua); [26. Quickfix & Location List](05-search-and-files.md#26-quickfix--location-list); [51. Quickfix Workflows for Developers](05-search-and-files.md#51-quickfix-workflows-for-developers); [11. File Explorer (`nvim-tree`)](05-search-and-files.md#11-file-explorer-nvim-tree); [30. Working with Directories](05-search-and-files.md#30-working-with-directories); [57. File Management for Developers](05-search-and-files.md#57-file-management-for-developers); [63. Working with Multiple Files](05-search-and-files.md#63-working-with-multiple-files) |
| [Windows, buffers, terminal, sessions and the interface](06-windows-terminal-sessions.md) | [7. Windows, Splits, and Buffers](06-windows-terminal-sessions.md#7-windows-splits-and-buffers); [8. Terminal Integration](06-windows-terminal-sessions.md#8-terminal-integration); [58. Session and Productivity](06-windows-terminal-sessions.md#58-session-and-productivity); [32. Statusline (`lualine.nvim`)](06-windows-terminal-sessions.md#32-statusline-lualinenvim); [33. UI Features](06-windows-terminal-sessions.md#33-ui-features) |
| [Code: LSP, running, debugging, folding, treesitter](07-code.md) | [13. LSP: Language Server Protocol](07-code.md#13-lsp-language-server-protocol); [44. Language Server Protocol (LSP) In Depth](07-code.md#44-language-server-protocol-lsp-in-depth); [18. Code Folding (`nvim-ufo`)](07-code.md#18-code-folding-nvim-ufo); [47. Code Folding In Depth](07-code.md#47-code-folding-in-depth); [21. Treesitter & Text Objects](07-code.md#21-treesitter--text-objects); [46. Treesitter In Depth](07-code.md#46-treesitter-in-depth); [19. Code Running](07-code.md#19-code-running); [55. Code Running In Depth](07-code.md#55-code-running-in-depth); [36. Debugging](07-code.md#36-debugging); [56. Debugging In Depth](07-code.md#56-debugging-in-depth); [43. How the Development Toolchain Fits Together](07-code.md#43-how-the-development-toolchain-fits-together); [53. Documentation Lookup](07-code.md#53-documentation-lookup); [59. Useful Developer Commands](07-code.md#59-useful-developer-commands); [75. Real-World Developer Workflows](07-code.md#75-real-world-developer-workflows); [35. Java Development (`nvim-java`)](07-code.md#35-java-development-nvim-java); [54. Java Development In Depth](07-code.md#54-java-development-in-depth) |
| [Git](08-git.md) | [20. Git Integration](08-git.md#20-git-integration); [48. Git Workflow In Depth](08-git.md#48-git-workflow-in-depth) |
| [Claude, Markdown, LaTeX/Typst, spelling, URLs](09-ai-and-writing.md) | [9. AI Assistant Window (Claude Code)](09-ai-and-writing.md#9-ai-assistant-window-claude-code); [49. AI-Assisted Development In Depth](09-ai-and-writing.md#49-ai-assisted-development-in-depth); [27. Markdown Support](09-ai-and-writing.md#27-markdown-support); [28. LaTeX and Typst Support](09-ai-and-writing.md#28-latex-and-typst-support); [31. Spell Checking](09-ai-and-writing.md#31-spell-checking); [38. URL & Unicode](09-ai-and-writing.md#38-url--unicode) |
| [Various: custom commands, other plugins, configuration, Neovide](10-various.md) | [34. Custom Commands](10-various.md#34-custom-commands); [39. Other Plugins](10-various.md#39-other-plugins); [40. Configuration Management](10-various.md#40-configuration-management); [41. Filetype-Specific Settings](10-various.md#41-filetype-specific-settings); [42. Automatic Behaviors](10-various.md#42-automatic-behaviors); [66. Shell Commands from Inside Neovim](10-various.md#66-shell-commands-from-inside-neovim); [77. Neovide (Graphical Neovim)](10-various.md#77-neovide-graphical-neovim) |
| [Java](languages/java.md) | [78. Java (nvim-java, jdtls, tests, debugging)](languages/java.md#78-java-nvim-java-jdtls-tests-debugging) |
| [Python](languages/python.md) | [79. Python (pyright, ruff, black, uv, running and debugging)](languages/python.md#79-python-pyright-ruff-black-uv-running-and-debugging) |
| [LaTeX](languages/latex.md) | [80. LaTeX (vimtex, texlab, ltex, PDF viewer)](languages/latex.md#80-latex-vimtex-texlab-ltex-pdf-viewer) |
| [Markdown](languages/markdown.md) | [81. Markdown (writing, preview, footnotes, PDF)](languages/markdown.md#81-markdown-writing-preview-footnotes-pdf) |
| [Typst](languages/typst.md) | [82. Typst (typst.vim, tinymist, watch and preview)](languages/typst.md#82-typst-typstvim-tinymist-watch-and-preview) |

The cheat sheet below is section 2: the keys and commands you use every day, with pointers to the full sections.

---

# 2. Day-to-Day Cheat Sheet


The things you do all day, in one place. Details are in the sections named at the end of each table.

### Navigation

| Keys | What it does |
| --- | --- |
| `h` `j` `k` `l`, `w` `b`, `H` `L`, `gg` `G` | Move by character, word, line start / end, file start / end |
| `f` + two characters | Hop to any matching spot on screen (then press the label letter) |
| `%` | Jump to the matching bracket |
| `<Ctrl-o>` / `<Ctrl-i>` | Back / forward through your jump history (after `gd`, searches, `gg` ...) |
| `ma`, then `` `a `` | Set mark `a`, jump back to it later |
| `gd` | Go to definition (use `<Ctrl-o>` to come back) |
| `<Space>ff` / `<Space>fg` / `<Space>fr` | Find a file / search text in the project / recent files |
| `<Space>s` | File tree (follows `:cd`, `:Z`, `:z`) |
| `gb` / `gB`, `<Space>bp` | Next / previous buffer, pick a buffer by letter |
| `<Space>t` | Symbol outline of the file |
| `:Z <word>` | Change the working folder with zoxide |

More: sections 3, 7, 11, 12, 22.

### Copy, delete and move

| Keys | What it does |
| --- | --- |
| `yy` then `p` | Copy a line, paste it below |
| `dd` then `p` | Cut a line, paste it below |
| `diw` / `ciw` / `yiw` | Delete / change / copy the word under the cursor (`c` does not overwrite your paste register) |
| `5dd` / `5yy` | Delete / copy 5 lines |
| `<Alt-j>` / `<Alt-k>` | Move the line (or selection) down / up |
| `<Space>y` | Copy the whole buffer |
| `<Space>p` / `<Space>P` | Paste on a new line below / above |
| `p` in Visual mode | Replace the selection with what you copied |
| `[y` / `]y` | After a paste, step back / forward through the yank history |
| `:Rename <name>` / `:Move <path>` / `:Duplicate <name>` / `:Delete` | Rename, move, copy or delete the current FILE |
| tree: `a` `d` `r` `c` `x` `p` | Create, delete, rename, copy, cut, paste files in the file tree |

More: sections 4, 11, 24, 57.

### Indented blocks

| Keys | What it does |
| --- | --- |
| `dii` / `yii` / `cii` / `vii` | Delete / copy / change / select the code block at the cursor's indent level |
| `dai` / `yai` / `cai` / `vai` | Same, including the lines that open and close the block |
| `[i` / `]i` | Jump to the top / bottom of the block |

More: section 5 ("ii / ai").

### Text objects (what to delete, change or copy)

| Keys | What it does |
| --- | --- |
| `diw` / `daw` | The word / the word with its space |
| `das` / `dis` / `cis` | The sentence with / without the space after it; change the sentence |
| `dip` / `dap` | The paragraph (without / with the blank line after it) |
| `di(` / `da(` | The text inside the parentheses / with the parentheses |
| `diS(` / `daS(` | Sandwich: empty the surrounding `(` `)` / remove them with their content |
| `ii` / `ai` | The indented block (see above) |

The same objects work after `c`, `y` and `v`. More: sections 5, 6, 17 and 70.

### Macros

| Keys | What it does |
| --- | --- |
| `Qa` | Start recording into register `a` (`qa` works too) |
| `q` | Stop recording |
| `@a` / `5@a` / `@@` | Play it once / 5 times / repeat the last one (in Markdown buffers `@@` returns from a footnote instead: use `@a` again) |
| `:%normal @a` | Play it on every line of the file |

More: sections 29 and 60.

### Bulk rename and replace

| Goal | What to do |
| --- | --- |
| Rename a code symbol everywhere in the project | `<Space>rn`, type the new name, `<Enter>` (LSP) |
| Replace text in the current file | `:%s/old/new/g` (add `c` to confirm each one) |
| Replace text in every file of the project | `:grep "old"` then `:cfdo %s/old/new/g \| update` |
| Replace one by one, deciding each time | `*`, `ciw` + new word + `<Esc>`, then `n` to skip or `.` to replace |
| Rename or move one file | `:Rename <name>` / `:Move <path>`, or `r` in the file tree |
| Undo a multi-file replace | See section 67 |

Files are renamed one at a time with the commands above. More: sections 10 and 67.

### Undo, redo and repeat

| Keys | What it does |
| --- | --- |
| `u` / `<Ctrl-r>` | Undo / redo |
| `<Space>u` | Show the undo tree in a left panel |
| `.` | Repeat the last change (e.g. `ciw` + word, then `n` and `.` on the next match) |
| `[y` / `]y` | After a paste, replace the pasted text with an earlier / later yank (yank two lines, `p`, then `[y`) |

More: sections 24, 25, 61.

### Visual block (many lines at once)

| Keys | What it does |
| --- | --- |
| `<Ctrl-v>` then `j` / `k` | Select a rectangle of text |
| `I` then text then `<Esc>` | Insert the text at the start of every selected line |
| `A` then text then `<Esc>` | Append the text at the end of every selected line |
| `d` / `c` | Delete / change the selected block |
| `g<Ctrl-a>` | Count up 1, 2, 3 ... down the selected numbers |
| `<Alt-j>` / `<Alt-k>` | Move the selected lines down / up |

More: section 62.

### Comments and surrounding pairs

| Keys | What it does |
| --- | --- |
| `gcc` / `gc` + motion / `gc` in Visual | Toggle a comment on a line / a motion / the selection (`gcip` = paragraph) |
| `gcss` / `gcs` + motion, `gcr` + motion | Comment / uncomment exactly the rows given (`gcsip`, `gcr200j`) |
| `gcu` | Uncomment the adjacent commented lines |
| `:1,3Commentary` | Toggle comments on a line range |
| `dgc` / `ygc` | Delete / copy the comment block under the cursor |
| `saiw"` | Surround the word with `"` |
| `sd"` | Delete the surrounding `"` |
| `sr"'` | Change the surrounding `"` into `'` |

More: sections 16 and 17.

### Search in a file

| Keys | What it does |
| --- | --- |
| `/text` then `<Enter>`, `n` / `N` | Search forward, next / previous match |
| `*` / `#` | Search the word under the cursor forward / backward |
| `;noh<Enter>` | Clear the search highlight |
| `:%s/old/new/gc` | Replace with a question for each match |

More: sections 10 and 23.

### Buffers, splits, tabs

| Keys | What it does |
| --- | --- |
| `gb` / `gB`, `<Space>bp` | Next / previous buffer, pick one by letter |
| `<Ctrl-^>` (in Neovide also `<Ctrl-6>`) | Jump to the previous buffer and back again, like Alt-Tab for files |
| `\d` / `\D` | Close this buffer / close all other buffers |
| `<Space>-` / `<Space>\|` | Split below / to the right (same file) |
| `<Ctrl-w>h` `j` `k` `l` | Move between windows |
| `<Left>` `<Down>` `<Up>` `<Right>` | The same, with the arrow keys (normal mode) |
| From a terminal window (run output, `:term`) | `<Esc>`, then `<Ctrl-w>h` (or an arrow key) to go to the code; `i` to type in the terminal again |
| From the Claude panel | `<Ctrl-h>` goes back to the code on the left (`<Esc>` is sent to Claude); `<Ctrl-w>l` or `<Right>` from the code goes back in |
| `<Ctrl-w>=` / `<Ctrl-w>o` | Make windows equal / keep only this window |
| `gt` / `gT`, `\t` / `\T` | Next / previous tab, close this tab / the other tabs |
| `:sp <file>` / `:vs <file>` | Open a file in a new horizontal / vertical split (`;` works like `:`, so `;vs <file>` too) |

More: section 7.

### Save and quit

| Keys | What it does |
| --- | --- |
| `<Space>w` | Save (only writes if changed) |
| `<Space>q` | Save and close this window |
| `<Space>Q` | Quit nvim, asks first (default No), discards unsaved work |
| `:wa` / `:q!` | Save all buffers / close this window and discard changes |
| (automatic) | Auto-save: a changed file saves itself when you switch buffer or leave the nvim window; a message "AutoSave: saved at ..." appears (not for unnamed or read-only buffers, terminals, LaTeX and Typst files) |

More: section 72.

### Sessions, dashboard and zoxide

| Keys | What it does |
| --- | --- |
| `\h` / `\H` | Open the dashboard / return to the previous buffer |
| `r` / `L` on the dashboard | Restore the session of this folder / of the last folder |
| `u` on the dashboard | Open the user guide |
| `:Z <word>` / `:z <word>` | Jump to the best zoxide match (the file tree follows) |
| `:Obsession`, `nvim -S Session.vim` | Keep a `Session.vim` up to date, restore it later |
| `<Space>sv` | Restart nvim (writes all files first) |

More: sections 30 and 58.

### Code intelligence (LSP)

| Keys | What it does |
| --- | --- |
| `gd` / `K` | Go to definition / hover documentation |
| `<Space>gd` / `<Space>gr` / `<Space>gi` | Peek definitions / references / implementations |
| `<Space>rn` / `<Space>ca` | Rename symbol / code actions |
| `<Space>fm` | Format the file |
| `]d` / `[d` | Next / previous diagnostic |
| `<Space>dd` | Show the diagnostic under the cursor |

More: sections 13 and 44.

### Git day to day

| Keys | What it does |
| --- | --- |
| `<Space>gs` | Git status |
| `<Space>gw` / `<Space>gc` | Add the current file / commit |
| `<Space>gpl` / `<Space>gpu` | Pull / push |
| `<Space>gB` | Branch menu: pick a branch to switch to (same as clicking the branch in the statusline) |
| `]c` / `[c` | Next / previous changed hunk |
| `<Space>hp` / `<Space>hb` | Preview the hunk / blame the line |
| `<Space>gl` | Copy a permalink for the line |
| `:Neogit` / `:NeogitLogCurrent` | Open the Neogit status window / the log of the current file (`q` closes) |

More: sections 20 and 48.

### Mouse

| Action | What it does |
| --- | --- |
| Click a tab in the top line | Switch to that buffer |
| Click the `x` / `●` of a tab | Close the buffer (a changed file asks Save / Discard / Cancel) |
| Click the branch name in the statusline | Branch menu (also `<Space>gB`) |
| Click the language-server name in the statusline | Popup with the attached language servers (also `:LspAttached`) |
| Right-click in the text | Neovim's menu: `Paste` pastes the clipboard, `Select All` selects the whole file, `Inspect` shows which highlight and syntax group is under the click, `How-to disable mouse` opens the help for it |

More: sections 7 and 32.

### Language guides (tools that exist only for one language)

| Language | What the guide covers | Section |
| --- | --- | --- |
| Java | nvim-java, jdtls, running, JUnit tests, debugging, refactoring, profiles | 78 |
| Python | pyright, ruff, black, uv, `<Space>rf` / `<F9>` and `<Space>rr`, pdb debugging | 79 |
| LaTeX | vimtex, texlab, ltex, compiling, the PDF viewer | 80 |
| Markdown | marksman, rendering, preview, footnotes, `:ToPDF` | 81 |
| Typst | tinymist, `<Space>tw` watch, the PDF viewer | 82 |

### Neovide (Neovim in its own window)

| Command | What it does |
| --- | --- |
| `neovide` | Open Neovim in a normal desktop window instead of the terminal, with smooth cursor animation. Same config, same keys. |

Full explanation: [section 77](10-various.md#77-neovide-graphical-neovim).

### Lists with a search bar (pickers)

| Keys | What it does |
| --- | --- |
| `<Ctrl-n>` / `<Ctrl-p>` or `<Down>` / `<Up>` | Next / previous item (branch menu, code actions, `<Space>ff`, `<Space>fg`, Telescope ...) |
| `<Ctrl-j>` / `<Ctrl-k>` | Same, except in Telescope |
| `<Tab>` | Move down (marks the item too in fzf-lua and Telescope) |
| `<Enter>` / `<Esc>` | Choose / close (in snacks and Telescope the first `<Esc>` only leaves the search bar) |

`j` and `k` type letters into the search bar. More: section 12.

### Quickfix list (search results, errors)

| Keys | What it does |
| --- | --- |
| `:copen` / `:cclose` | Open / close the list |
| `:cnext` / `:cprev` | Next / previous item |
| `\x` | Close the quickfix and location lists |
| `p` / `zf` in the list | Preview the item / filter the list with fzf |
| `<Tab>` in the list | Mark the item |
| `<Ctrl-x>` / `<Ctrl-v>` in the list | Open the item in a horizontal / vertical split |
| `:cfdo %s/old/new/g \| update` | Replace in every file of the list |

More: sections 26 and 51.

### Spell checking

| Keys | What it does |
| --- | --- |
| `<Space>cz` | Spell checking on / off (`:set spell` / `:set nospell` too) |
| `]s` / `[s` | Next / previous misspelled word |
| `z=` | Show suggestions |
| `zg` / `zw` | Add the word to your allowed list / mark it as wrong (`2zg` Italian, `3zg` German, `4zg` French) |
| `zug` | Undo the last `zg` |
| `:e ~/.config/nvim/spell/en.utf-8.add` | Open the list of allowed English words (one per line: delete a line to forbid the word again) |

`:set nospell` only turns off the built-in checker. Typo underlines that come from the language servers (`typos_lsp` in code, `ltex_plus` in prose) stay; they are diagnostics. More: section 31.

### Run code and terminal

| Keys | What it does |
| --- | --- |
| `<Space>rr` | Run the current file in a terminal on the left |
| `<Space>rf` / `<F9>` | Run or compile the file the editor's own way (Lua, Vim script, Python, C++, LaTeX; one warning in other file types) |
| `:term` | Open a terminal in this window |
| `<Esc>` / `i` | Leave terminal mode / go back into it (`<Esc>` works differently in the Claude panel, see sections 8 and 9) |

More: sections 8 and 19. `<Space>rf` in any other file type shows one warning (`no editor-run for this file type (use <Space>rr for a terminal run)`).

### Python debugger keys

Start with `<Space>dp` in a Python buffer (pdb through nvim-gdb); the keys work only during that session (otherwise one warning `pdb: no debug session here (start one with <Space>dp)`). nvim-gdb's own F-keys still work too.

| Keys | What it does |
| --- | --- |
| `<Space>dp` | Start the pdb debugger on this file |
| `<Space>dB` / `<F8>` | Toggle a breakpoint on this line |
| `<Space>dc` / `<F5>` | Continue to the next breakpoint |
| `<Space>dn` / `<F10>` | Next line (step over) |
| `<Space>ds` / `<F11>` | Step into the call |
| `<Space>df` / `<F12>` | Finish (run until the function returns) |
| `<Space>du` / `<F4>` | Run until this line |
| `<Space>dv` | Evaluate the word under the cursor (Visual: the selection) |
| `:GdbDebugStop` | Quit the debugger |

More: section 79.

### Keyboards without function keys, Insert or Page keys

Nearly every key in this guide has a version without function keys. `<F9>` is `<Space>rf` (run the file the editor's own way); the Python debugger has the `<Space>d` keys above. `<S-Insert>` (paste in the GUI, ginit.vim) is replaced by `<Ctrl-r>` then `+` in Insert mode or on the command line (built-in Vim, works everywhere); `<Ctrl-d>` / `<Ctrl-u>` scroll instead of the Page keys. Unicode `<F4>` is replaced by `<Ctrl-k>` + two letters (section 38). The only keys left are three vimtex defaults in section 80 (`<F6>`, `<F7>`, `<F8>`).

### Folding

| Keys | What it does |
| --- | --- |
| `za` | Toggle the fold under the cursor |
| `zR` / `zM` | Open / close all folds |
| `zr` / `zm` | Open / close one more fold level |
| `<Space>K` | Preview the folded lines |

More: section 18.

### Text tricks

| Keys | What it does |
| --- | --- |
| `gUiw` / `guiw` | Uppercase / lowercase the word |
| `<Ctrl-a>` / `<Ctrl-x>` | Add 1 to / subtract 1 from the number under the cursor (`10<Ctrl-a>` adds 10) |
| `:%!sort` | Sort the whole buffer |
| `:Tabularize /=` | Align the `=` signs |
| `:g/pattern/d` | Delete every line that matches |
| `:g/pattern/normal @a` | Run macro `a` on every matching line |
| `:!cmd` / `:read !cmd` | Run a shell command / insert its output |

More: sections 66, 68 and 71.

### Claude and fuzzy finders

| Keys | What it does |
| --- | --- |
| `<Space>cc` | Toggle the Claude Code window |
| `<Space>ff` / `<Space>fg` | Find a file / search text in the project |
| `<Space>fb` / `<Space>fr` / `<Space>fh` | Open buffers / recent files / help tags |

More: sections 9 and 12.

### Other most-used keys (from the former Quick Reference)

| Keymap | Action |
| --- | --- |
| `]<Space>` / `[<Space>` | Insert a blank line below / above (cursor stays; `3]<Space>` inserts 3) |
| `gS` | Split / join the list, arguments or block under the cursor (treesj) |
