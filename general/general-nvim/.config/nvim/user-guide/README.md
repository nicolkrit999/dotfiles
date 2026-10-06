# Neovim user guide

Leader key: `<Space>`

A hands-on manual for one specific Neovim setup (Catppuccin Mocha theme, plugins managed by lazy.nvim). It explains how to work in this editor without touching the mouse: what to press, what happens, and why.

**Who it is for.** People new to Neovim or to this config, and the author when a key has been forgotten. No Vim knowledge is assumed: modes and the verb + noun idea are explained first (section [1](01-basics.md#1-understanding-modes)). Every key listed here is taken from the real config, so it works as written.

**What it covers.**

| Area | Sections |
| --- | --- |
| Basics: modes, cheat sheet, saving, recovering, getting help | [1](01-basics.md#1-understanding-modes), [2](#2-day-to-day-cheat-sheet), [69](01-basics.md#69-tips-for-vim-beginners) to [70](01-basics.md#70-the-verb--noun-system-how-vim-commands-work), [72](01-basics.md#72-saving-quitting-and-file-state) to [74](01-basics.md#74-discovering-keymaps-and-getting-help) |
| Moving around | [3](02-navigation.md#3-core-navigation-moving-without-the-mouse), [22](02-navigation.md#22-jump-navigation-hopnvim), [23](02-navigation.md#23-search-lens-nvim-hlslens), [37](02-navigation.md#37-symbol-outline-aerialnvim), [50](02-navigation.md#50-code-navigation-strategies) |
| Editing: selection, text objects, registers, macros, the dot command | [4](03-editing.md#4-editing) to [6](03-editing.md#6-working-with-parentheses-quotes-and-brackets), [16](03-editing.md#16-code-commenting), [17](03-editing.md#17-surrounding-pairs-vim-sandwich--nvim-autopairs), [24](03-editing.md#24-yank-history-yankynvim), [25](03-editing.md#25-undo-history), [29](03-editing.md#29-registers--macros), [60](03-editing.md#60-macros-in-depth) to [62](03-editing.md#62-visual-block-editing-multi-cursor-like), [64](03-editing.md#64-everyday-editing-scenarios), [65](03-editing.md#65-swapping-function-arguments-vim-swap), [68](03-editing.md#68-useful-vim-tricks), [71](03-editing.md#71-the-global-command-g), [76](03-editing.md#76-common-editing-power-combos) |
| Search, replace, fuzzy finding, file tree, quickfix, files | [10](05-search-and-files.md#10-searching-replacing-and-refactoring-text) to [12](05-search-and-files.md#12-fuzzy-finding--project-wide-search-fzf-lua), [26](05-search-and-files.md#26-quickfix--location-list), [30](05-search-and-files.md#30-working-with-directories), [51](05-search-and-files.md#51-quickfix-workflows-for-developers), [57](05-search-and-files.md#57-file-management-for-developers), [63](05-search-and-files.md#63-working-with-multiple-files), [67](05-search-and-files.md#67-multi-file-search-and-replace-complete-guide) |
| Windows, buffers, terminal, sessions, statusline and UI | [7](06-windows-terminal-sessions.md#7-windows-splits-and-buffers), [8](06-windows-terminal-sessions.md#8-terminal-integration), [32](06-windows-terminal-sessions.md#32-statusline-lualinenvim), [33](06-windows-terminal-sessions.md#33-ui-features), [58](06-windows-terminal-sessions.md#58-session-and-productivity) |
| Code: LSP, completion, snippets, folding, treesitter, running, debugging, docs, workflows | [13](07-code.md#13-lsp-language-server-protocol) to [15](04-completion-snippets.md#15-snippets-ultisnips), [18](07-code.md#18-code-folding-nvim-ufo), [19](07-code.md#19-code-running), [21](07-code.md#21-treesitter--text-objects), [35](07-code.md#35-java-development-nvim-java), [36](07-code.md#36-debugging), [43](07-code.md#43-how-the-development-toolchain-fits-together) to [47](07-code.md#47-code-folding-in-depth-nvim-ufo), [52](04-completion-snippets.md#52-snippets-for-developers-ultisnips) to [56](07-code.md#56-debugging-in-depth), [59](07-code.md#59-useful-developer-commands), [75](07-code.md#75-real-world-developer-workflows) |
| Git | [20](08-git.md#20-git-integration), [48](08-git.md#48-git-workflow-in-depth) |
| Claude Code, Markdown, LaTeX/Typst, spelling, URLs | [9](09-ai-and-writing.md#9-ai-assistant-window-claude-code-claude-codenvim), [27](09-ai-and-writing.md#27-markdown-support), [28](09-ai-and-writing.md#28-latex-and-typst-support), [31](09-ai-and-writing.md#31-spell-checking), [38](09-ai-and-writing.md#38-url--unicode-gxnvim-vim-highlighturl-unicodevim), [49](09-ai-and-writing.md#49-ai-assisted-development-in-depth) |
| Everything else: custom commands, configuration, automatic behaviors, shell commands, Neovide, other plugins | [34](10-various.md#34-custom-commands), [39](10-various.md#39-other-plugins) to [42](10-various.md#42-automatic-behaviors), [66](10-various.md#66-shell-commands-from-inside-neovim), [77](10-various.md#77-neovide-graphical-neovim) |
| Languages: Java, Python, LaTeX, Markdown, Typst, C++, Vim, Nix | [78](languages/java.md#78-java-nvim-java-jdtls-tests-debugging) to [82](languages/typst.md#82-typst-typstvim-tinymist-watch-and-preview), [84](languages/cpp.md#84-c-snippets-compile-and-run) to [86](languages/nix.md#86-nix-snippets-and-delib-modules) |
| Catalog of every plugin, each linked to its section | [83](11-plugins.md#83-plugin-catalog) |

**How it is organized.** Every topic is a numbered section, and the text "see section N" always means that number. [Section 2](#2-day-to-day-cheat-sheet) is a one-page cheat sheet of the daily keys, with pointers to the full sections. Sections with "in depth" in the title go further than the short section on the same topic. Start with [section 1](01-basics.md#1-understanding-modes), then [section 2](#2-day-to-day-cheat-sheet); use the table of contents (or the plugin catalog, [section 83](11-plugins.md#83-plugin-catalog)) to find the rest.

**Conventions.**

| Notation | Meaning |
| --- | --- |
| `<Space>ff` | Press the leader key (Space), then `f`, then `f` |
| `<Ctrl-o>`, `<Alt-j>`, `<Esc>`, `<CR>`, `<BS>` | A key with a modifier, or a named key (`<CR>` is Enter, `<BS>` is Backspace); all key names: section [2](#2-day-to-day-cheat-sheet), "[Key names](#key-names-how-keys-are-written)" |
| `:Z word` | A command: type it after `:` in Normal mode and press Enter |
| `n`, `x`, `o`, `i`, `s`, `t`, `cmd` in a Mode column | Normal, Visual (also `v`), Operator-pending, Insert, Select, Terminal, Command-line; several letters (e.g. `n, x`) mean the key works in each of those modes |
| N/A in a table cell | Not applicable: nothing is produced or to enter (cells are never left empty) |
| see section N | Go to that section number (not the PDF's "Chapter" number, which counts files) |

**Reading and rebuilding.** In Neovim press `<Space>?` (or use the dashboard item) to open the PDF at the contents page. The `.md` files are the source: after editing run `user-guide/build-pdf.py`, then `user-guide/build-pdf.py --check` (details under Contents).

## Contents

Every section keeps its number; the text "see section N" in the guide refers to these numbers. The list is generated by `build-pdf.py` (do not edit it by hand). Reading: press `<Space>?` (or use the dashboard item) to open the PDF. Editing: the `.md` files are the source; after changing them run `user-guide/build-pdf.py` (rebuilds this list and the PDF) and `user-guide/build-pdf.py --check` (verifies).

<!-- toc:start -->

1. **[Day-to-day cheat sheet](README.md#2-day-to-day-cheat-sheet)**
    - [Key names (how keys are written)](README.md#key-names-how-keys-are-written)
    - [Reading the guide PDF (zathura keys)](README.md#reading-the-guide-pdf-zathura-keys)
    - [Navigation](README.md#navigation)
    - [Copy, delete and move](README.md#copy-delete-and-move)
    - [Indented blocks](README.md#indented-blocks)
    - [Text objects (what to delete, change or copy)](README.md#text-objects-what-to-delete-change-or-copy)
    - [Macros](README.md#macros)
    - [Bulk rename and replace](README.md#bulk-rename-and-replace)
    - [Undo, redo and repeat](README.md#undo-redo-and-repeat)
    - [Visual block (many lines at once)](README.md#visual-block-many-lines-at-once)
    - [Comments and surrounding pairs (vim-commentary, vim-sandwich)](README.md#comments-and-surrounding-pairs-vim-commentary-vim-sandwich)
    - [Search in a file](README.md#search-in-a-file)
    - [Buffers, splits, tabs](README.md#buffers-splits-tabs)
    - [Save and quit](README.md#save-and-quit)
    - [Sessions, dashboard and zoxide](README.md#sessions-dashboard-and-zoxide)
    - [Code intelligence (LSP)](README.md#code-intelligence-lsp)
    - [Completion and snippets](README.md#completion-and-snippets)
    - [Git day to day](README.md#git-day-to-day)
    - [Mouse](README.md#mouse)
    - [Language guides (tools that exist only for one language)](README.md#language-guides-tools-that-exist-only-for-one-language)
    - [Language devShells (:DevEnv)](README.md#language-devshells-devenv)
    - [Neovide (Neovim in its own window)](README.md#neovide-neovim-in-its-own-window)
    - [Lists with a search bar (pickers)](README.md#lists-with-a-search-bar-pickers)
    - [Quickfix list (search results, errors)](README.md#quickfix-list-search-results-errors)
    - [Spell checking](README.md#spell-checking)
    - [Run code and terminal](README.md#run-code-and-terminal)
    - [Python debugger keys (pdb through nvim-gdb)](README.md#python-debugger-keys-pdb-through-nvim-gdb)
    - [Java debugger keys (nvim-dap through nvim-java)](README.md#java-debugger-keys-nvim-dap-through-nvim-java)
    - [Keyboards without function keys, Insert or Page keys](README.md#keyboards-without-function-keys-insert-or-page-keys)
    - [Folding (nvim-ufo)](README.md#folding-nvim-ufo)
    - [Text tricks](README.md#text-tricks)
    - [Claude and fuzzy finders](README.md#claude-and-fuzzy-finders)
    - [Other most-used keys (from the former quick reference)](README.md#other-most-used-keys-from-the-former-quick-reference)

2. **[Basics: modes, saving, recovering, getting help](01-basics.md)**
    - [1. Understanding modes](01-basics.md#1-understanding-modes)
        - [Entering insert mode](01-basics.md#entering-insert-mode)
        - [Leaving insert mode](01-basics.md#leaving-insert-mode)
        - [Visual mode variants](01-basics.md#visual-mode-variants)
    - [69. Tips for Vim beginners](01-basics.md#69-tips-for-vim-beginners)
        - [The most important habits](01-basics.md#the-most-important-habits)
        - [Common mistakes and how to fix them](01-basics.md#common-mistakes-and-how-to-fix-them)
        - [Keyboard layouts with dead keys (for example US International)](01-basics.md#keyboard-layouts-with-dead-keys-for-example-us-international)
        - [Learning path](01-basics.md#learning-path)
    - [70. The verb + noun system (how Vim commands work)](01-basics.md#70-the-verb--noun-system-how-vim-commands-work)
        - [Operators (verbs)](01-basics.md#operators-verbs)
        - [Motions (nouns)](01-basics.md#motions-nouns)
        - [Text objects (structured nouns)](01-basics.md#text-objects-structured-nouns)
        - [Combining verbs and nouns](01-basics.md#combining-verbs-and-nouns)
        - [Using counts](01-basics.md#using-counts)
        - [Why this matters](01-basics.md#why-this-matters)
    - [72. Saving, quitting, and file state](01-basics.md#72-saving-quitting-and-file-state)
        - [Saving](01-basics.md#saving)
        - [Quitting](01-basics.md#quitting)
        - [Closing buffers (without quitting Neovim)](01-basics.md#closing-buffers-without-quitting-neovim)
    - [73. Recovering from mistakes](01-basics.md#73-recovering-from-mistakes)
        - [Undo and redo](01-basics.md#undo-and-redo)
        - [Undo tree (builtin)](01-basics.md#undo-tree-builtin)
        - [Time-based undo](01-basics.md#time-based-undo)
        - [If you accidentally deleted a file](01-basics.md#if-you-accidentally-deleted-a-file)
    - [74. Discovering keymaps and getting help](01-basics.md#74-discovering-keymaps-and-getting-help)
        - [See available keybindings with which-key.nvim](01-basics.md#see-available-keybindings-with-which-keynvim)
        - [Browse all keymaps](01-basics.md#browse-all-keymaps)
        - [Getting help](01-basics.md#getting-help)
        - [Checking system health](01-basics.md#checking-system-health)

3. **[Navigation](02-navigation.md)**
    - [3. Core navigation (moving without the mouse)](02-navigation.md#3-core-navigation-moving-without-the-mouse)
        - [Basic cursor movement](02-navigation.md#basic-cursor-movement)
        - [Moving within a line](02-navigation.md#moving-within-a-line)
        - [Moving by word](02-navigation.md#moving-by-word)
        - [Moving by line/screen](02-navigation.md#moving-by-linescreen)
        - [Jumping to matching brackets/parentheses](02-navigation.md#jumping-to-matching-bracketsparentheses)
        - [Jumping to specific characters](02-navigation.md#jumping-to-specific-characters)
        - [Jump navigation with hop.nvim (plugin)](02-navigation.md#jump-navigation-with-hopnvim-plugin)
        - [Jump history](02-navigation.md#jump-history)
        - [Word references (vim-illuminate)](02-navigation.md#word-references-vim-illuminate)
        - [Marks (bookmarks)](02-navigation.md#marks-bookmarks)
    - [22. Jump navigation (hop.nvim)](02-navigation.md#22-jump-navigation-hopnvim)
    - [23. Search lens (nvim-hlslens)](02-navigation.md#23-search-lens-nvim-hlslens)
    - [37. Symbol outline (aerial.nvim)](02-navigation.md#37-symbol-outline-aerialnvim)
    - [50. Code navigation strategies](02-navigation.md#50-code-navigation-strategies)
        - [Finding files](02-navigation.md#finding-files)
        - [Finding code](02-navigation.md#finding-code)
        - [Understanding code](02-navigation.md#understanding-code)
        - [Refactoring code](02-navigation.md#refactoring-code)

4. **[Editing, text objects, macros and tricks](03-editing.md)**
    - [4. Editing](03-editing.md#4-editing)
        - [Entering insert mode for editing](03-editing.md#entering-insert-mode-for-editing)
        - [Deleting text](03-editing.md#deleting-text)
        - [Copying (yanking) text](03-editing.md#copying-yanking-text)
        - [Pasting text](03-editing.md#pasting-text)
        - [Changing (delete + enter insert)](03-editing.md#changing-delete--enter-insert)
        - [Replacing text](03-editing.md#replacing-text)
        - [Undo / redo](03-editing.md#undo--redo)
        - [Repeating actions](03-editing.md#repeating-actions)
        - [Line operations](03-editing.md#line-operations)
            - [Split and join code (treesj)](03-editing.md#split-and-join-code-treesj)
        - [Indentation](03-editing.md#indentation)
        - [Insert mode shortcuts](03-editing.md#insert-mode-shortcuts)
        - [Miscellaneous editing](03-editing.md#miscellaneous-editing)
    - [5. Selection (visual mode)](03-editing.md#5-selection-visual-mode)
        - [Selecting characters](03-editing.md#selecting-characters)
        - [Selecting lines](03-editing.md#selecting-lines)
        - [Selecting blocks (columns)](03-editing.md#selecting-blocks-columns)
        - [Selecting inside/around delimiters (text objects)](03-editing.md#selecting-insidearound-delimiters-text-objects)
            - [Parentheses, brackets, braces](03-editing.md#parentheses-brackets-braces)
            - [Quotes](03-editing.md#quotes)
            - [Words, lines, paragraphs](03-editing.md#words-lines-paragraphs)
            - [Tags (HTML/XML)](03-editing.md#tags-htmlxml)
            - [Example for the text objects above](03-editing.md#example-for-the-text-objects-above)
            - [Using with operators (d, c, y)](03-editing.md#using-with-operators-d-c-y)
            - [Select a whole block, from its first line to the closing brace (method, function, if, class)](03-editing.md#select-a-whole-block-from-its-first-line-to-the-closing-brace-method-function-if-class)
            - [Treesitter node selection (builtin)](03-editing.md#treesitter-node-selection-builtin)
            - [More text objects](03-editing.md#more-text-objects)
            - [Markdown code block text objects](03-editing.md#markdown-code-block-text-objects)
        - [Precision selection: from the cursor to an exact spot](03-editing.md#precision-selection-from-the-cursor-to-an-exact-spot)
            - [Quick lookup](03-editing.md#quick-lookup)
            - [End of line: L](03-editing.md#end-of-line-l)
            - [t and T: stop just before a character](03-editing.md#t-and-t-stop-just-before-a-character)
            - [Counting: v2tX is not 2vtX](03-editing.md#counting-v2tx-is-not-2vtx)
            - [) and ( are sentence motions, not parentheses](03-editing.md#-and--are-sentence-motions-not-parentheses)
            - [Search as a selection motion (crosses lines)](03-editing.md#search-as-a-selection-motion-crosses-lines)
            - [hop.nvim: select to something you can see (no counting)](03-editing.md#hopnvim-select-to-something-you-can-see-no-counting)
            - [Target on another line, count unknown: use the relative numbers](03-editing.md#target-on-another-line-count-unknown-use-the-relative-numbers)
            - [Typing before or after: i a I A](03-editing.md#typing-before-or-after-i-a-i-a)
            - [Non-contiguous lines (for example line 3 and line 10 together)](03-editing.md#non-contiguous-lines-for-example-line-3-and-line-10-together)
        - [Line range yanking (command mode)](03-editing.md#line-range-yanking-command-mode)
    - [6. Working with parentheses, quotes, and brackets](03-editing.md#6-working-with-parentheses-quotes-and-brackets)
        - [Jumping to matching pair](03-editing.md#jumping-to-matching-pair)
        - [Selecting inside/around pairs](03-editing.md#selecting-insidearound-pairs)
        - [Changing text inside pairs](03-editing.md#changing-text-inside-pairs)
        - [Deleting text inside pairs](03-editing.md#deleting-text-inside-pairs)
        - [Adding surrounding pairs (vim-sandwich plugin)](03-editing.md#adding-surrounding-pairs-vim-sandwich-plugin)
        - [Removing surrounding pairs (vim-sandwich plugin)](03-editing.md#removing-surrounding-pairs-vim-sandwich-plugin)
        - [Replacing surrounding pairs (vim-sandwich plugin)](03-editing.md#replacing-surrounding-pairs-vim-sandwich-plugin)
            - [Wrap a whole list or part of it (headless in a scratch copy)](03-editing.md#wrap-a-whole-list-or-part-of-it-headless-in-a-scratch-copy)
        - [Auto-pairing (nvim-autopairs plugin)](03-editing.md#auto-pairing-nvim-autopairs-plugin)
    - [16. Code commenting](03-editing.md#16-code-commenting)
        - [vim-commentary (plugin)](03-editing.md#vim-commentary-plugin)
        - [Smart commenting (custom)](03-editing.md#smart-commenting-custom)
    - [17. Surrounding pairs (vim-sandwich + nvim-autopairs)](03-editing.md#17-surrounding-pairs-vim-sandwich--nvim-autopairs)
    - [24. Yank history (yanky.nvim)](03-editing.md#24-yank-history-yankynvim)
    - [25. Undo history](03-editing.md#25-undo-history)
    - [29. Registers & macros](03-editing.md#29-registers--macros)
        - [Registers](03-editing.md#registers)
        - [Macros](03-editing.md#macros)
    - [60. Macros in depth](03-editing.md#60-macros-in-depth)
        - [Recording a macro](03-editing.md#recording-a-macro)
        - [Playing a macro](03-editing.md#playing-a-macro)
        - [Scenario: add semicolons to the end of 20 lines](03-editing.md#scenario-add-semicolons-to-the-end-of-20-lines)
        - [Scenario: wrap each line in double quotes](03-editing.md#scenario-wrap-each-line-in-double-quotes)
        - [Scenario: append the same text to a block of lines](03-editing.md#scenario-append-the-same-text-to-a-block-of-lines)
        - [Scenario: turn // name lines into names.add("name"); calls](03-editing.md#scenario-turn--name-lines-into-namesaddname-calls)
        - [Scenario: convert a list of variables to assignments](03-editing.md#scenario-convert-a-list-of-variables-to-assignments)
        - [Scenario: turn CSV into SQL VALUES](03-editing.md#scenario-turn-csv-into-sql-values)
        - [Tips for writing macros](03-editing.md#tips-for-writing-macros)
        - [Visual mode macros](03-editing.md#visual-mode-macros)
    - [61. The dot command (.) -- repeating actions](03-editing.md#61-the-dot-command-----repeating-actions)
        - [What counts as a "change"](03-editing.md#what-counts-as-a-change)
        - [Scenario: change a variable name one-by-one](03-editing.md#scenario-change-a-variable-name-one-by-one)
        - [Scenario: add a prefix to multiple lines](03-editing.md#scenario-add-a-prefix-to-multiple-lines)
        - [Scenario: delete the first word on several lines](03-editing.md#scenario-delete-the-first-word-on-several-lines)
        - [Scenario: indent multiple blocks](03-editing.md#scenario-indent-multiple-blocks)
        - [Combining . with counts](03-editing.md#combining--with-counts)
    - [62. Visual block editing (multi-cursor-like)](03-editing.md#62-visual-block-editing-multi-cursor-like)
        - [Scenario: add a prefix to multiple lines at once](03-editing.md#scenario-add-a-prefix-to-multiple-lines-at-once)
        - [Scenario: append text to multiple lines](03-editing.md#scenario-append-text-to-multiple-lines)
        - [Scenario: delete a column](03-editing.md#scenario-delete-a-column)
        - [Scenario: replace a column](03-editing.md#scenario-replace-a-column)
    - [64. Everyday editing scenarios](03-editing.md#64-everyday-editing-scenarios)
        - [Swap two lines](03-editing.md#swap-two-lines)
        - [Swap two words (vim-swap)](03-editing.md#swap-two-words-vim-swap)
        - [Duplicate a line](03-editing.md#duplicate-a-line)
        - [Duplicate a block of code](03-editing.md#duplicate-a-block-of-code)
        - [Fix indentation of entire file](03-editing.md#fix-indentation-of-entire-file)
        - [Remove all blank lines](03-editing.md#remove-all-blank-lines)
        - [Sort lines](03-editing.md#sort-lines)
        - [Convert tabs to spaces (or vice versa)](03-editing.md#convert-tabs-to-spaces-or-vice-versa)
        - [Wrap a selection in a tag/function](03-editing.md#wrap-a-selection-in-a-tagfunction)
    - [65. Swapping function arguments (vim-swap)](03-editing.md#65-swapping-function-arguments-vim-swap)
    - [68. Useful Vim tricks](03-editing.md#68-useful-vim-tricks)
        - [Run a normal-mode command on every line](03-editing.md#run-a-normal-mode-command-on-every-line)
        - [Execute a command on a range](03-editing.md#execute-a-command-on-a-range)
        - [Increment/decrement numbers](03-editing.md#incrementdecrement-numbers)
        - [Letter sequences (a, b, c...) instead of numbers](03-editing.md#letter-sequences-a-b-c-instead-of-numbers)
        - [Open the file under cursor](03-editing.md#open-the-file-under-cursor)
        - [Change case](03-editing.md#change-case)
        - [Align text with tabular](03-editing.md#align-text-with-tabular)
        - [Command abbreviations](03-editing.md#command-abbreviations)
    - [71. The global command (:g)](03-editing.md#71-the-global-command-g)
        - [Common uses](03-editing.md#common-uses)
        - [Everyday scenarios](03-editing.md#everyday-scenarios)
            - [Delete all print/debug statements](03-editing.md#delete-all-printdebug-statements)
            - [Keep only lines matching a pattern](03-editing.md#keep-only-lines-matching-a-pattern)
            - [Extract all function signatures](03-editing.md#extract-all-function-signatures)
            - [Add prefix/suffix to matching lines](03-editing.md#add-prefixsuffix-to-matching-lines)
            - [Move lines matching a pattern to the top](03-editing.md#move-lines-matching-a-pattern-to-the-top)
    - [76. Common editing power combos](03-editing.md#76-common-editing-power-combos)
        - [Changing text](03-editing.md#changing-text)
        - [Deleting text](03-editing.md#deleting-text-1)
        - [Copying text](03-editing.md#copying-text)
        - [Selecting text](03-editing.md#selecting-text)
        - [Quick transformations](03-editing.md#quick-transformations)
        - [The most powerful patterns](03-editing.md#the-most-powerful-patterns)

5. **[Completion and snippets](04-completion-snippets.md)**
    - [14. Autocompletion (nvim-cmp)](04-completion-snippets.md#14-autocompletion-nvim-cmp)
    - [15. Snippets (UltiSnips)](04-completion-snippets.md#15-snippets-ultisnips)
        - [Java snippets](04-completion-snippets.md#java-snippets)
        - [Other snippets](04-completion-snippets.md#other-snippets)
    - [45. Autocompletion in depth (nvim-cmp)](04-completion-snippets.md#45-autocompletion-in-depth-nvim-cmp)
        - [How it works](04-completion-snippets.md#how-it-works)
        - [The smart tab behavior](04-completion-snippets.md#the-smart-tab-behavior)
        - [Completion keymaps](04-completion-snippets.md#completion-keymaps)
        - [Visual indicators](04-completion-snippets.md#visual-indicators)
        - [Completion sources and helpers](04-completion-snippets.md#completion-sources-and-helpers)
    - [52. Snippets for developers (UltiSnips)](04-completion-snippets.md#52-snippets-for-developers-ultisnips)
        - [What snippets are](04-completion-snippets.md#what-snippets-are)
        - [Ready-made snippets (vim-snippets)](04-completion-snippets.md#ready-made-snippets-vim-snippets)
        - [How to use snippets](04-completion-snippets.md#how-to-use-snippets)
        - [The snippet gallery](04-completion-snippets.md#the-snippet-gallery)
        - [Custom snippets](04-completion-snippets.md#custom-snippets)
        - [Creating your own snippets](04-completion-snippets.md#creating-your-own-snippets)

6. **[Searching, replacing, files and the file tree](05-search-and-files.md)**
    - [10. Searching, replacing, and refactoring text](05-search-and-files.md#10-searching-replacing-and-refactoring-text)
        - [Searching in the current file](05-search-and-files.md#searching-in-the-current-file)
            - [Search modifiers](05-search-and-files.md#search-modifiers)
            - [Search examples](05-search-and-files.md#search-examples)
        - [Substitution (find & replace in current file)](05-search-and-files.md#substitution-find--replace-in-current-file)
            - [Understanding the range (where to replace)](05-search-and-files.md#understanding-the-range-where-to-replace)
            - [Understanding the flags (how to replace)](05-search-and-files.md#understanding-the-flags-how-to-replace)
            - [Flag combinations](05-search-and-files.md#flag-combinations)
            - [Confirmation mode (c flag) controls](05-search-and-files.md#confirmation-mode-c-flag-controls)
            - [Changing the delimiter](05-search-and-files.md#changing-the-delimiter)
            - [Special replacement patterns](05-search-and-files.md#special-replacement-patterns)
            - [Substitution examples](05-search-and-files.md#substitution-examples)
        - [Searching in the current buffer with * and #](05-search-and-files.md#searching-in-the-current-buffer-with--and-)
        - [Using ciw + . for selective single-file replacement](05-search-and-files.md#using-ciw---for-selective-single-file-replacement)
    - [67. Multi-file search and replace (complete guide)](05-search-and-files.md#67-multi-file-search-and-replace-complete-guide)
        - [Quick decision guide: which method to use](05-search-and-files.md#quick-decision-guide-which-method-to-use)
        - [Method 1: LSP rename (best for code symbols)](05-search-and-files.md#method-1-lsp-rename-best-for-code-symbols)
            - [LSP rename versus :grep + :cfdo: can the fast text rename replace a slow <Space>rn?](05-search-and-files.md#lsp-rename-versus-grep--cfdo-can-the-fast-text-rename-replace-a-slow-spacern)
        - [Method 2: :grep + :cfdo (best for plain text)](05-search-and-files.md#method-2-grep--cfdo-best-for-plain-text)
            - [Step-by-step: replace all without confirmation](05-search-and-files.md#step-by-step-replace-all-without-confirmation)
            - [Step-by-step: replace with confirmation for each occurrence](05-search-and-files.md#step-by-step-replace-with-confirmation-for-each-occurrence)
            - [Step-by-step: review results before replacing](05-search-and-files.md#step-by-step-review-results-before-replacing)
            - [Using regex with :grep](05-search-and-files.md#using-regex-with-grep)
            - [Limiting to specific file types](05-search-and-files.md#limiting-to-specific-file-types)
        - [Method 3: :vimgrep + :cfdo (built-in, slower but portable)](05-search-and-files.md#method-3-vimgrep--cfdo-built-in-slower-but-portable)
        - [Method 4: <Space>fg for finding (no replace)](05-search-and-files.md#method-4-spacefg-for-finding-no-replace)
        - [Complete examples](05-search-and-files.md#complete-examples)
            - [Example 1: rename an API endpoint across the project](05-search-and-files.md#example-1-rename-an-api-endpoint-across-the-project)
            - [Example 2: replace a deprecated function name (with confirmation)](05-search-and-files.md#example-2-replace-a-deprecated-function-name-with-confirmation)
            - [Example 3: delete all console.log statements in JavaScript files](05-search-and-files.md#example-3-delete-all-consolelog-statements-in-javascript-files)
            - [Example 4: add a comment before every TODO](05-search-and-files.md#example-4-add-a-comment-before-every-todo)
            - [Example 5: replace only in Python files in the src/ directory](05-search-and-files.md#example-5-replace-only-in-python-files-in-the-src-directory)
            - [Example 6: case-insensitive project-wide replace](05-search-and-files.md#example-6-case-insensitive-project-wide-replace)
        - [Understanding :cdo vs :cfdo vs :bufdo](05-search-and-files.md#understanding-cdo-vs-cfdo-vs-bufdo)
        - [Undoing a multi-file replace](05-search-and-files.md#undoing-a-multi-file-replace)
    - [12. Fuzzy finding & project-wide search (fzf-lua)](05-search-and-files.md#12-fuzzy-finding--project-wide-search-fzf-lua)
        - [Moving inside any picker (lists with a search bar)](05-search-and-files.md#moving-inside-any-picker-lists-with-a-search-bar)
        - [Keymaps](05-search-and-files.md#keymaps)
        - [Inside the fzf-lua popup](05-search-and-files.md#inside-the-fzf-lua-popup)
        - [<Space>fg -- Live grep (project-wide text search) in depth](05-search-and-files.md#spacefg----live-grep-project-wide-text-search-in-depth)
            - [What it does](05-search-and-files.md#what-it-does)
            - [Plain text search](05-search-and-files.md#plain-text-search)
            - [Regex search](05-search-and-files.md#regex-search)
            - [Use cases for live grep](05-search-and-files.md#use-cases-for-live-grep)
        - [<Space>ff -- Find files (file name search)](05-search-and-files.md#spaceff----find-files-file-name-search)
        - [The difference between search methods](05-search-and-files.md#the-difference-between-search-methods)
    - [26. Quickfix & location list](05-search-and-files.md#26-quickfix--location-list)
        - [Commands](05-search-and-files.md#commands)
        - [Inside the quickfix window (nvim-bqf, quicker.nvim)](05-search-and-files.md#inside-the-quickfix-window-nvim-bqf-quickernvim)
    - [51. Quickfix workflows for developers](05-search-and-files.md#51-quickfix-workflows-for-developers)
        - [What populates the quickfix list](05-search-and-files.md#what-populates-the-quickfix-list)
        - [Navigating the quickfix list](05-search-and-files.md#navigating-the-quickfix-list)
        - [Batch operations on quickfix items](05-search-and-files.md#batch-operations-on-quickfix-items)
        - [trouble.nvim: better quickfix UI](05-search-and-files.md#troublenvim-better-quickfix-ui)
    - [11. File explorer (nvim-tree)](05-search-and-files.md#11-file-explorer-nvim-tree)
    - [30. Working with directories](05-search-and-files.md#30-working-with-directories)
        - [Path modifiers (for use in commands)](05-search-and-files.md#path-modifiers-for-use-in-commands)
    - [57. File management for developers](05-search-and-files.md#57-file-management-for-developers)
        - [File operations](05-search-and-files.md#file-operations)
        - [Project structure navigation](05-search-and-files.md#project-structure-navigation)
    - [63. Working with multiple files](05-search-and-files.md#63-working-with-multiple-files)
        - [Opening several files](05-search-and-files.md#opening-several-files)
        - [Comparing two files side by side](05-search-and-files.md#comparing-two-files-side-by-side)
        - [Copying between files](05-search-and-files.md#copying-between-files)
        - [Running the same edit across multiple files](05-search-and-files.md#running-the-same-edit-across-multiple-files)
        - [Closing files you're done with](05-search-and-files.md#closing-files-youre-done-with)

7. **[Windows, buffers, terminal, sessions and the interface](06-windows-terminal-sessions.md)**
    - [7. Windows, splits, and buffers](06-windows-terminal-sessions.md#7-windows-splits-and-buffers)
        - [Key concepts](06-windows-terminal-sessions.md#key-concepts)
        - [Creating splits](06-windows-terminal-sessions.md#creating-splits)
            - [Put two chosen buffers side by side or one above the other](06-windows-terminal-sessions.md#put-two-chosen-buffers-side-by-side-or-one-above-the-other)
        - [Navigating between windows](06-windows-terminal-sessions.md#navigating-between-windows)
        - [Resizing windows](06-windows-terminal-sessions.md#resizing-windows)
        - [Moving windows around](06-windows-terminal-sessions.md#moving-windows-around)
        - [Buffer tabs (the top line, bufferline.nvim)](06-windows-terminal-sessions.md#buffer-tabs-the-top-line-bufferlinenvim)
            - [Changing the order of the tabs](06-windows-terminal-sessions.md#changing-the-order-of-the-tabs)
        - [Closing windows](06-windows-terminal-sessions.md#closing-windows)
        - [Buffer management](06-windows-terminal-sessions.md#buffer-management)
            - [Reading the :ls flags](06-windows-terminal-sessions.md#reading-the-ls-flags)
        - [Tabs](06-windows-terminal-sessions.md#tabs)
        - [Closing floating windows](06-windows-terminal-sessions.md#closing-floating-windows)
    - [8. Terminal integration](06-windows-terminal-sessions.md#8-terminal-integration)
        - [Opening a terminal](06-windows-terminal-sessions.md#opening-a-terminal)
        - [Navigating in and out of terminal](06-windows-terminal-sessions.md#navigating-in-and-out-of-terminal)
        - [Closing a terminal](06-windows-terminal-sessions.md#closing-a-terminal)
    - [58. Session and productivity](06-windows-terminal-sessions.md#58-session-and-productivity)
        - [Auto-save (auto-save.nvim)](06-windows-terminal-sessions.md#auto-save-auto-savenvim)
        - [Session management (persistence.nvim, vim-obsession)](06-windows-terminal-sessions.md#session-management-persistencenvim-vim-obsession)
        - [Collaborative editing (instant.nvim)](06-windows-terminal-sessions.md#collaborative-editing-instantnvim)
    - [32. Statusline (lualine.nvim)](06-windows-terminal-sessions.md#32-statusline-lualinenvim)
    - [33. UI features](06-windows-terminal-sessions.md#33-ui-features)
        - [Breadcrumb bar (dropbar.nvim)](06-windows-terminal-sessions.md#breadcrumb-bar-dropbarnvim)
        - [LSP progress messages (fidget.nvim)](06-windows-terminal-sessions.md#lsp-progress-messages-fidgetnvim)
        - [Colorschemes](06-windows-terminal-sessions.md#colorschemes)
            - [Which theme is active at startup](06-windows-terminal-sessions.md#which-theme-is-active-at-startup)
            - [Switching and listing themes](06-windows-terminal-sessions.md#switching-and-listing-themes)
            - [The 19 themes of the random list](06-windows-terminal-sessions.md#the-19-themes-of-the-random-list)
        - [Line number column (statuscol.nvim)](06-windows-terminal-sessions.md#line-number-column-statuscolnvim)
        - [Icons and UI libraries](06-windows-terminal-sessions.md#icons-and-ui-libraries)
        - [Input popups and big files (snacks.nvim)](06-windows-terminal-sessions.md#input-popups-and-big-files-snacksnvim)
        - [Dashboard (start screen, dashboard-nvim)](06-windows-terminal-sessions.md#dashboard-start-screen-dashboard-nvim)
            - [Help keys: the user guide and Claude (any buffer, and the dashboard)](06-windows-terminal-sessions.md#help-keys-the-user-guide-and-claude-any-buffer-and-the-dashboard)

8. **[Code: LSP, running, debugging, folding, treesitter](07-code.md)**
    - [13. LSP: language server protocol](07-code.md#13-lsp-language-server-protocol)
        - [Configured language servers](07-code.md#configured-language-servers)
        - [LSP keymaps](07-code.md#lsp-keymaps)
        - [Built-in Neovim LSP and diagnostic keys](07-code.md#built-in-neovim-lsp-and-diagnostic-keys)
        - [LSP commands](07-code.md#lsp-commands)
        - [glance.nvim: peek without jumping](07-code.md#glancenvim-peek-without-jumping)
        - [Diagnostics (errors, warnings)](07-code.md#diagnostics-errors-warnings)
    - [44. Language server protocol (LSP) in depth](07-code.md#44-language-server-protocol-lsp-in-depth)
        - [What LSP is](07-code.md#what-lsp-is)
        - [How LSP is managed (nvim-lspconfig)](07-code.md#how-lsp-is-managed-nvim-lspconfig)
        - [Configured servers and what they provide](07-code.md#configured-servers-and-what-they-provide)
        - [How language servers are registered (lua/config/lsp.lua)](07-code.md#how-language-servers-are-registered-luaconfiglsplua)
            - [Shared capabilities](07-code.md#shared-capabilities)
            - [The server table](07-code.md#the-server-table)
            - [When is a server enabled](07-code.md#when-is-a-server-enabled)
            - [R: the one-time probe](07-code.md#r-the-one-time-probe)
        - [Lua: lua_ls and stylua](07-code.md#lua-lua_ls-and-stylua)
        - [typos_lsp: where it attaches](07-code.md#typos_lsp-where-it-attaches)
        - [LSP keymaps (all languages)](07-code.md#lsp-keymaps-all-languages)
        - [Peeking without jumping (glance.nvim)](07-code.md#peeking-without-jumping-glancenvim)
        - [Diagnostics in depth](07-code.md#diagnostics-in-depth)
        - [The lightbulb (nvim-lightbulb)](07-code.md#the-lightbulb-nvim-lightbulb)
        - [Editing the Neovim config in Lua (lazydev.nvim)](07-code.md#editing-the-neovim-config-in-lua-lazydevnvim)
    - [18. Code folding (nvim-ufo)](07-code.md#18-code-folding-nvim-ufo)
    - [47. Code folding in depth (nvim-ufo)](07-code.md#47-code-folding-in-depth-nvim-ufo)
        - [What it is](07-code.md#what-it-is)
        - [How it works](07-code.md#how-it-works)
        - [Folding keymaps](07-code.md#folding-keymaps)
    - [21. Treesitter & text objects](07-code.md#21-treesitter--text-objects)
        - [nvim-treesitter (plugin)](07-code.md#nvim-treesitter-plugin)
        - [targets.vim (plugin)](07-code.md#targetsvim-plugin)
        - [vim-matchup (plugin)](07-code.md#vim-matchup-plugin)
    - [46. Treesitter in depth (nvim-treesitter)](07-code.md#46-treesitter-in-depth-nvim-treesitter)
        - [What treesitter is](07-code.md#what-treesitter-is)
        - [Installed parsers](07-code.md#installed-parsers)
    - [19. Code running](07-code.md#19-code-running)
        - [Filetype-specific](07-code.md#filetype-specific)
    - [55. Code running in depth](07-code.md#55-code-running-in-depth)
        - [The universal runner](07-code.md#the-universal-runner)
        - [Language-specific details](07-code.md#language-specific-details)
        - [Filetype-specific runners](07-code.md#filetype-specific-runners)
    - [36. Debugging](07-code.md#36-debugging)
    - [56. Debugging in depth](07-code.md#56-debugging-in-depth)
        - [Debug adapter protocol (DAP, nvim-dap)](07-code.md#debug-adapter-protocol-dap-nvim-dap)
        - [GDB integration (nvim-gdb)](07-code.md#gdb-integration-nvim-gdb)
    - [43. How the development toolchain fits together](07-code.md#43-how-the-development-toolchain-fits-together)
        - [Enter a language devShell from a running Neovim (:DevEnv)](07-code.md#enter-a-language-devshell-from-a-running-neovim-devenv)
    - [53. Documentation lookup](07-code.md#53-documentation-lookup)
        - [nvim-devdocs (plugin)](07-code.md#nvim-devdocs-plugin)
        - [Hover documentation (LSP)](07-code.md#hover-documentation-lsp)
    - [59. Useful developer commands](07-code.md#59-useful-developer-commands)
    - [Part III: everyday scenarios & recipes](07-code.md#part-iii-everyday-scenarios--recipes)
    - [75. Real-world developer workflows](07-code.md#75-real-world-developer-workflows)
        - [Workflow: investigating a bug](07-code.md#workflow-investigating-a-bug)
        - [Workflow: code review (reviewing your own changes)](07-code.md#workflow-code-review-reviewing-your-own-changes)
        - [Workflow: refactoring a function name across the project](07-code.md#workflow-refactoring-a-function-name-across-the-project)
        - [Workflow: adding a feature in a new branch](07-code.md#workflow-adding-a-feature-in-a-new-branch)
        - [Workflow: quickly editing a config file](07-code.md#workflow-quickly-editing-a-config-file)
        - [Workflow: working with JSON](07-code.md#workflow-working-with-json)
        - [Workflow: writing documentation (Markdown)](07-code.md#workflow-writing-documentation-markdown)
        - [Workflow: pair programming with split views](07-code.md#workflow-pair-programming-with-split-views)
    - [35. Java development (nvim-java)](07-code.md#35-java-development-nvim-java)
        - [Build & run](07-code.md#build--run)
        - [Testing](07-code.md#testing)
        - [Refactoring](07-code.md#refactoring)
    - [54. Java development in depth](07-code.md#54-java-development-in-depth)
        - [How it works](07-code.md#how-it-works-1)
        - [Build & run](07-code.md#build--run-1)
        - [Testing](07-code.md#testing-1)
        - [Debugging](07-code.md#debugging)
        - [Refactoring](07-code.md#refactoring-1)

9. **[Git](08-git.md)**
    - [20. Git integration](08-git.md#20-git-integration)
        - [vim-fugitive (plugin)](08-git.md#vim-fugitive-plugin)
        - [gitsigns.nvim (plugin)](08-git.md#gitsignsnvim-plugin)
        - [gitlinker.nvim (plugin)](08-git.md#gitlinkernvim-plugin)
        - [Neogit (plugin)](08-git.md#neogit-plugin)
        - [vim-flog (plugin)](08-git.md#vim-flog-plugin)
        - [diffs.nvim (plugin)](08-git.md#diffsnvim-plugin)
        - [codediff.nvim (plugin)](08-git.md#codediffnvim-plugin)
        - [Other Git tools](08-git.md#other-git-tools)
        - [Resolving merge conflicts (diffview.nvim)](08-git.md#resolving-merge-conflicts-diffviewnvim)
    - [48. Git workflow in depth](08-git.md#48-git-workflow-in-depth)
        - [The Git plugin ecosystem](08-git.md#the-git-plugin-ecosystem)
        - [Daily Git workflow](08-git.md#daily-git-workflow)
        - [Understanding gitsigns.nvim](08-git.md#understanding-gitsignsnvim)

10. **[Claude, Markdown, LaTeX/Typst, spelling, URLs](09-ai-and-writing.md)**
    - [9. AI assistant window (Claude Code, claude-code.nvim)](09-ai-and-writing.md#9-ai-assistant-window-claude-code-claude-codenvim)
        - [Claude Code keys (claude-code.nvim)](09-ai-and-writing.md#claude-code-keys-claude-codenvim)
    - [49. AI-assisted development in depth](09-ai-and-writing.md#49-ai-assisted-development-in-depth)
        - [Claude Code in depth (claude-code.nvim)](09-ai-and-writing.md#claude-code-in-depth-claude-codenvim)
    - [27. Markdown support](09-ai-and-writing.md#27-markdown-support)
        - [Preview (markdown-preview.nvim)](09-ai-and-writing.md#preview-markdown-previewnvim)
        - [Footnotes (vim-markdownfootnotes)](09-ai-and-writing.md#footnotes-vim-markdownfootnotes)
        - [Text objects & operators (Markdown only)](09-ai-and-writing.md#text-objects--operators-markdown-only)
        - [Other Markdown plugins](09-ai-and-writing.md#other-markdown-plugins)
    - [28. LaTeX and Typst support](09-ai-and-writing.md#28-latex-and-typst-support)
        - [LaTeX (vimtex)](09-ai-and-writing.md#latex-vimtex)
        - [Typst (typst.vim, tinymist)](09-ai-and-writing.md#typst-typstvim-tinymist)
    - [31. Spell checking](09-ai-and-writing.md#31-spell-checking)
    - [38. URL & Unicode (gx.nvim, vim-highlighturl, unicode.vim)](09-ai-and-writing.md#38-url--unicode-gxnvim-vim-highlighturl-unicodevim)

11. **[Various: custom commands, other plugins, configuration, Neovide](10-various.md)**
    - [34. Custom commands](10-various.md#34-custom-commands)
        - [Plugin manager shortcuts (lazy.nvim)](10-various.md#plugin-manager-shortcuts-lazynvim)
    - [39. Other plugins](10-various.md#39-other-plugins)
        - [telescope.nvim (second picker)](10-various.md#telescopenvim-second-picker)
        - [Copying over SSH (vim-oscyank)](10-various.md#copying-over-ssh-vim-oscyank)
        - [Keyboard layout switching (vim-xkbswitch)](10-various.md#keyboard-layout-switching-vim-xkbswitch)
        - [Neovim in the browser (firenvim)](10-various.md#neovim-in-the-browser-firenvim)
        - [Live preview of :norm (live-command.nvim)](10-various.md#live-preview-of-norm-live-commandnvim)
        - [Vim-script debugging (vim-scriptease)](10-various.md#vim-script-debugging-vim-scriptease)
        - [Libraries and dependencies](10-various.md#libraries-and-dependencies)
        - [SQL databases (nvim-dbee, vim-dadbod-ui)](10-various.md#sql-databases-nvim-dbee-vim-dadbod-ui)
    - [40. Configuration management](10-various.md#40-configuration-management)
    - [41. Filetype-specific settings](10-various.md#41-filetype-specific-settings)
        - [Filetype syntax plugins (vim-tmux, vim-toml)](10-various.md#filetype-syntax-plugins-vim-tmux-vim-toml)
    - [42. Automatic behaviors](10-various.md#42-automatic-behaviors)
    - [Part II: developer guide](10-various.md#part-ii-developer-guide)
    - [66. Shell commands from inside Neovim](10-various.md#66-shell-commands-from-inside-neovim)
        - [Running a shell command](10-various.md#running-a-shell-command)
        - [Inserting command output into the buffer](10-various.md#inserting-command-output-into-the-buffer)
        - [Filtering a selection through a command](10-various.md#filtering-a-selection-through-a-command)
        - [The asyncrun.vim plugin](10-various.md#the-asyncrunvim-plugin)
    - [77. Neovide (graphical Neovim)](10-various.md#77-neovide-graphical-neovim)
        - [Starting it](10-various.md#starting-it)
        - [What this configuration sets for Neovide](10-various.md#what-this-configuration-sets-for-neovide)
        - [Keys that only exist in a GUI](10-various.md#keys-that-only-exist-in-a-gui)

12. **[Plugin catalog](11-plugins.md)**
    - [83. Plugin catalog](11-plugins.md#83-plugin-catalog)
        - [LSP and code intelligence](11-plugins.md#lsp-and-code-intelligence)
            - [Language servers, diagnostics and navigation](11-plugins.md#language-servers-diagnostics-and-navigation)
            - [Java](11-plugins.md#java)
            - [Debugging and running code](11-plugins.md#debugging-and-running-code)
        - [Completion and snippets](11-plugins.md#completion-and-snippets)
            - [Completion](11-plugins.md#completion)
            - [Snippets and pairs](11-plugins.md#snippets-and-pairs)
        - [Editing and motions](11-plugins.md#editing-and-motions)
            - [Text objects and surroundings](11-plugins.md#text-objects-and-surroundings)
            - [Moving around and searching in the buffer](11-plugins.md#moving-around-and-searching-in-the-buffer)
            - [Editing helpers](11-plugins.md#editing-helpers)
        - [Search and files](11-plugins.md#search-and-files)
        - [Sessions and saving](11-plugins.md#sessions-and-saving)
        - [Git](11-plugins.md#git)
            - [Everyday Git in the buffer](11-plugins.md#everyday-git-in-the-buffer)
            - [Git interfaces and diffs](11-plugins.md#git-interfaces-and-diffs)
        - [Databases](11-plugins.md#databases)
        - [User interface](11-plugins.md#user-interface)
            - [Bars, messages and start screen](11-plugins.md#bars-messages-and-start-screen)
            - [Visual helpers](11-plugins.md#visual-helpers)
            - [Icons and UI libraries](11-plugins.md#icons-and-ui-libraries)
        - [Colorschemes](11-plugins.md#colorschemes)
        - [Writing: Markdown, LaTeX, Typst](11-plugins.md#writing-markdown-latex-typst)
        - [AI and collaboration](11-plugins.md#ai-and-collaboration)
        - [Plugin manager, libraries and other tools](11-plugins.md#plugin-manager-libraries-and-other-tools)
            - [Plugin manager and libraries](11-plugins.md#plugin-manager-and-libraries)
            - [Terminal, browser and file types](11-plugins.md#terminal-browser-and-file-types)

13. **[Java](languages/java.md)**
    - [78. Java (nvim-java, jdtls, tests, debugging)](languages/java.md#78-java-nvim-java-jdtls-tests-debugging)
        - [1. What you get and why](languages/java.md#1-what-you-get-and-why)
            - [How nvim-java is loaded](languages/java.md#how-nvim-java-is-loaded)
            - [spring-boot (Spring Boot tools)](languages/java.md#spring-boot-spring-boot-tools)
            - [The Java devShell (use_dev_env java)](languages/java.md#the-java-devshell-use_dev_env-java)
            - [Outside the devShell](languages/java.md#outside-the-devshell)
        - [2. Quick start](languages/java.md#2-quick-start)
        - [3. Project layout rules](languages/java.md#3-project-layout-rules)
            - [The root folder](languages/java.md#the-root-folder)
            - [First start and where files appear](languages/java.md#first-start-and-where-files-appear)
        - [4. Keys and commands](languages/java.md#4-keys-and-commands)
            - [Build (<Space>jb)](languages/java.md#build-spacejb)
            - [Runner (<Space>jr)](languages/java.md#runner-spacejr)
            - [Test (<Space>jt)](languages/java.md#test-spacejt)
            - [Refactor / extract (<Space>je)](languages/java.md#refactor--extract-spaceje)
            - [Debug (<Space>jh, <Space>jp, <Space>jP, <Space>jx)](languages/java.md#debug-spacejh-spacejp-spacejp-spacejx)
            - [Settings and debugger setup](languages/java.md#settings-and-debugger-setup)
            - [The :Java* commands](languages/java.md#the-java-commands)
            - [The runner window](languages/java.md#the-runner-window)
            - [Profiles window (<Space>jrp)](languages/java.md#profiles-window-spacejrp)
            - [Clean workspace (<Space>jbc)](languages/java.md#clean-workspace-spacejbc)
            - [Change runtime (<Space>jj)](languages/java.md#change-runtime-spacejj)
        - [5. Language server features in a Java buffer](languages/java.md#5-language-server-features-in-a-java-buffer)
            - [Go to definition, back, hover, references](languages/java.md#go-to-definition-back-hover-references)
            - [When a rename does nothing](languages/java.md#when-a-rename-does-nothing)
            - [Rename: :grep + :cfdo instead of <Space>rn?](languages/java.md#rename-grep--cfdo-instead-of-spacern)
            - [Add a missing import (auto-import)](languages/java.md#add-a-missing-import-auto-import)
            - [Generate getters, setters and constructors](languages/java.md#generate-getters-setters-and-constructors)
        - [6. Tests (JUnit)](languages/java.md#6-tests-junit)
            - [Why and how](languages/java.md#why-and-how)
            - [Using it](languages/java.md#using-it)
            - [cursor is not on a test method](languages/java.md#cursor-is-not-on-a-test-method)
            - [The test terminal window does not come back after you close it](languages/java.md#the-test-terminal-window-does-not-come-back-after-you-close-it)
            - [Needs](languages/java.md#needs)
        - [7. Debugging](languages/java.md#7-debugging)
            - [Why and how](languages/java.md#why-and-how-1)
            - [Debug workflow](languages/java.md#debug-workflow)
            - [Learning exercise (try it)](languages/java.md#learning-exercise-try-it)
            - [Learning exercise: debug a test](languages/java.md#learning-exercise-debug-a-test)
            - [The Configuration picker](languages/java.md#the-configuration-picker)
        - [8. Refactoring (extract)](languages/java.md#8-refactoring-extract)
        - [9. Snippets](languages/java.md#9-snippets)
        - [10. Windows while running, testing and debugging](languages/java.md#10-windows-while-running-testing-and-debugging)
        - [11. Troubleshooting](languages/java.md#11-troubleshooting)
        - [Related sections](languages/java.md#related-sections)

14. **[Python](languages/python.md)**
    - [79. Python (pyright, ruff, black, uv, running and debugging)](languages/python.md#79-python-pyright-ruff-black-uv-running-and-debugging)
        - [What you get](languages/python.md#what-you-get)
        - [Quick start](languages/python.md#quick-start)
        - [Why each tool exists](languages/python.md#why-each-tool-exists)
        - [Devshell and tools](languages/python.md#devshell-and-tools)
        - [How Python is set up (the real code)](languages/python.md#how-python-is-set-up-the-real-code)
            - [The server entries (lua/config/lsp.lua)](languages/python.md#the-server-entries-luaconfiglsplua)
            - [pyright settings (after/lsp/pyright.lua)](languages/python.md#pyright-settings-afterlsppyrightlua)
            - [ruff settings (after/lsp/ruff.lua)](languages/python.md#ruff-settings-afterlsprufflua)
            - [Which environment: get_py_env (lua/utils.lua)](languages/python.md#which-environment-get_py_env-luautilslua)
            - [Run and format keys (after/ftplugin/python.lua)](languages/python.md#run-and-format-keys-afterftpluginpythonlua)
            - [AsyncRun (lua/plugin_specs.lua)](languages/python.md#asyncrun-luaplugin_specslua)
            - [pdb through nvim-gdb (plugin spec and ftplugin)](languages/python.md#pdb-through-nvim-gdb-plugin-spec-and-ftplugin)
        - [Running code](languages/python.md#running-code)
            - [When <Space>rf / <F9> uses uv](languages/python.md#when-spacerf--f9-uses-uv)
            - [Stopping a running program](languages/python.md#stopping-a-running-program)
        - [Formatting and linting](languages/python.md#formatting-and-linting)
            - [Code actions from ruff](languages/python.md#code-actions-from-ruff)
            - [Linting from the command line (:compiler ruff)](languages/python.md#linting-from-the-command-line-compiler-ruff)
        - [LSP keys](languages/python.md#lsp-keys)
        - [Debugging with pdb (nvim-gdb)](languages/python.md#debugging-with-pdb-nvim-gdb)
        - [Virtual environments](languages/python.md#virtual-environments)
        - [Testing](languages/python.md#testing)
        - [Navigation and text objects](languages/python.md#navigation-and-text-objects)
        - [Snippets](languages/python.md#snippets)
        - [Troubleshooting](languages/python.md#troubleshooting)
        - [Related sections](languages/python.md#related-sections)

15. **[LaTeX](languages/latex.md)**
    - [80. LaTeX (vimtex, texlab, ltex, PDF viewer)](languages/latex.md#80-latex-vimtex-texlab-ltex-pdf-viewer)
        - [The big picture](languages/latex.md#the-big-picture)
        - [What it needs (the devShell)](languages/latex.md#what-it-needs-the-devshell)
        - [How vimtex is set up (the real code)](languages/latex.md#how-vimtex-is-set-up-the-real-code)
        - [Quick start](languages/latex.md#quick-start)
        - [Compiling](languages/latex.md#compiling)
            - [Errors](languages/latex.md#errors)
            - [Several files (a project with chapters)](languages/latex.md#several-files-a-project-with-chapters)
        - [The viewer](languages/latex.md#the-viewer)
        - [Table of contents](languages/latex.md#table-of-contents)
        - [Moving and editing (vimtex)](languages/latex.md#moving-and-editing-vimtex)
            - [Motions](languages/latex.md#motions)
            - [Text objects (use after d, y, c, v)](languages/latex.md#text-objects-use-after-d-y-c-v)
            - [Change, delete, toggle](languages/latex.md#change-delete-toggle)
        - [Language server (texlab)](languages/latex.md#language-server-texlab)
        - [Citations (bibliography)](languages/latex.md#citations-bibliography)
        - [Grammar and spelling (ltex_plus)](languages/latex.md#grammar-and-spelling-ltex_plus)
        - [Snippets](languages/latex.md#snippets)
            - [Math symbols](languages/latex.md#math-symbols)
        - [Troubleshooting](languages/latex.md#troubleshooting)
        - [Related sections](languages/latex.md#related-sections)

16. **[Markdown](languages/markdown.md)**
    - [81. Markdown (writing, preview, footnotes, PDF)](languages/markdown.md#81-markdown-writing-preview-footnotes-pdf)
        - [The tools and why they exist](languages/markdown.md#the-tools-and-why-they-exist)
        - [Quick start](languages/markdown.md#quick-start)
        - [Requirements](languages/markdown.md#requirements)
        - [Try the keys: an example file](languages/markdown.md#try-the-keys-an-example-file)
        - [Keys](languages/markdown.md#keys)
        - [Text objects and operators](languages/markdown.md#text-objects-and-operators)
        - [Footnotes (vim-markdownfootnotes)](languages/markdown.md#footnotes-vim-markdownfootnotes)
        - [Reference links and tables](languages/markdown.md#reference-links-and-tables)
        - [Preview (markdown-preview.nvim)](languages/markdown.md#preview-markdown-previewnvim)
        - [Rendering inside the buffer (render-markdown.nvim)](languages/markdown.md#rendering-inside-the-buffer-render-markdownnvim)
        - [Formatting with prettier](languages/markdown.md#formatting-with-prettier)
        - [PDF export (:ToPDF)](languages/markdown.md#pdf-export-topdf)
        - [Snippets](languages/markdown.md#snippets)
            - [Math symbols](languages/markdown.md#math-symbols)
        - [Writing quality](languages/markdown.md#writing-quality)
            - [ltex_plus (grammar, LanguageTool)](languages/markdown.md#ltex_plus-grammar-languagetool)
            - [Vim spell checking](languages/markdown.md#vim-spell-checking)
            - [typos_lsp](languages/markdown.md#typos_lsp)
        - [Troubleshooting](languages/markdown.md#troubleshooting)
        - [Related sections](languages/markdown.md#related-sections)

17. **[Typst](languages/typst.md)**
    - [82. Typst (typst.vim, tinymist, watch and preview)](languages/typst.md#82-typst-typstvim-tinymist-watch-and-preview)
        - [What you get](languages/typst.md#what-you-get)
        - [Requirements: the Typst devShell](languages/typst.md#requirements-the-typst-devshell)
            - [Outside the devShell](languages/typst.md#outside-the-devshell)
        - [Quick start](languages/typst.md#quick-start)
        - [Keys and commands](languages/typst.md#keys-and-commands)
        - [The language server: tinymist](languages/typst.md#the-language-server-tinymist)
        - [Watch, compile and the PDF](languages/typst.md#watch-compile-and-the-pdf)
        - [Prose checking in Typst](languages/typst.md#prose-checking-in-typst)
        - [Filetype settings](languages/typst.md#filetype-settings)
        - [Example document](languages/typst.md#example-document)
            - [What to try](languages/typst.md#what-to-try)
        - [Snippets](languages/typst.md#snippets)
            - [Starting flow](languages/typst.md#starting-flow)
            - [Where they work and limits](languages/typst.md#where-they-work-and-limits)
            - [Math delimiters](languages/typst.md#math-delimiters)
            - [Math symbols](languages/typst.md#math-symbols)
        - [Troubleshooting](languages/typst.md#troubleshooting)
        - [Related sections](languages/typst.md#related-sections)

18. **[C++](languages/cpp.md)**
    - [84. C++ (snippets, compile and run)](languages/cpp.md#84-c-snippets-compile-and-run)
        - [What you get](languages/cpp.md#what-you-get)
        - [Snippets](languages/cpp.md#snippets)
        - [Related sections](languages/cpp.md#related-sections)

19. **[Vimscript](languages/vim.md)**
    - [85. Vimscript (snippets, source and settings)](languages/vim.md#85-vimscript-snippets-source-and-settings)
        - [What you get](languages/vim.md#what-you-get)
        - [Snippets](languages/vim.md#snippets)
        - [Related sections](languages/vim.md#related-sections)

20. **[Nix](languages/nix.md)**
    - [86. Nix (snippets and delib modules)](languages/nix.md#86-nix-snippets-and-delib-modules)
        - [What you get](languages/nix.md#what-you-get)
        - [The Nix devShell](languages/nix.md#the-nix-devshell)
        - [What delib is](languages/nix.md#what-delib-is)
        - [Snippets](languages/nix.md#snippets)
        - [Related sections](languages/nix.md#related-sections)

<!-- toc:end -->

The cheat sheet below is section 2: the keys and commands you use every day, with pointers to the full sections.

---

# 2. Day-to-day cheat sheet


The things you do all day, in one place. Details are in the sections named at the end of each table.

### Key names (how keys are written)

| Written as | Key to press | Notes |
| --- | --- | --- |
| `<Ctrl-w>h`, `<C-w>h` | Hold **Control**, press `w`, release both, then press `h` | `<Ctrl-x>`, `<C-x>` and `<c-x>` are spellings of the same thing; the key after it is a separate press |
| `<Alt-j>`, `<A-j>`, `<M-j>` | Hold **Alt**, press `j` | Alt is also called Meta; all three spellings are the same |
| `<S-Tab>` | Hold **Shift**, press `Tab` | A capital letter such as `G` or `V` is Shift + the letter; `g` is the plain letter |
| `<Esc>` | **Escape** | Leaves Insert, Visual and other modes |
| `<CR>`, `<Enter>`, `<Return>` | **Enter** | All the same key |
| `<BS>` | **Backspace** | Deletes the character before the cursor |
| `<Del>` | **Delete** | Deletes the character under the cursor |
| `<Tab>` | **Tab** | |
| `<Space>` | The **space bar** | In this config it is also the **leader** key |
| `<leader>`, `<Leader>` | The leader key, which is `<Space>` here | `<leader>rf` is the same as `<Space>rf` |
| `<Up>`, `<Down>`, `<Left>`, `<Right>` | The arrow keys | |
| `<Home>`, `<End>` | The Home and End keys | |
| `<PageUp>`, `<PageDown>`, `<Insert>`, `<F1>` to `<F12>` | Page, Insert and function keys | The guide avoids needing them (see "[Keyboards without function keys, Insert or Page keys](#keyboards-without-function-keys-insert-or-page-keys)") |
| `gg`, `dd`, `<Space>ff` | Press the keys one after another, quickly | After `<Space>` a popup (which-key) lists what can follow |
| `;` | Same as `:` in Normal and Visual mode | `;w<Enter>` saves, `;qa!<Enter>` quits everything without asking |
| `<file>`, `<name>`, `<path>`, `<word>`, `<char>`, `<url>` | Not a key: replace it with your own value | Any word in `<...>` that is not a key name is a placeholder |
| `<Plug>(...)`, `<Cmd>`, `<C-U>` (in code) | Not keys you press | Internal names inside the quoted Lua and Vim script of a mapping |
| `:'<,'>` | Not typed by you | Vim writes it after `:` when you press `:` in Visual mode; it means "the selected lines" |
| `<p>`, `<script>`, `<style>`, `<b>` in examples | Not keys | Literal HTML tags in the text being edited |

### Reading the guide PDF (zathura keys)

`<Space>?` opens this guide in zathura. Zathura has its own keys (the defaults, from its man page), not Neovim's:

| Keys | What it does |
| --- | --- |
| `J` / `K` | Next page / previous page (the same as `<PageDown>` / `<PageUp>`) |
| `j` `k`, `h` `l` | Scroll down / up, left / right |
| `<Ctrl-d>` / `<Ctrl-u>`, `<Space>` | Scroll half a page down / up, a full page down |
| `gg`, `G`, `42G` | First page, last page, page 42 |
| `Tab` | Show the table of contents (index): `j` `k` move, `l` / `h` expand / collapse an entry, `<Enter>` opens it, `Tab` or `<Esc>` hides the index again |
| `/word<Enter>`, `n` / `N` | Search; next / previous match (`n` is NOT "next page") |
| `f` | Show the clickable links of the page as numbers; type a number to follow it. `<Ctrl-o>` goes back |
| `a` / `s` | Fit the whole page / the page width in the window |
| `R` | Reload the file (after rebuilding the PDF) |
| `q` | Close zathura |

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

More: sections [3](02-navigation.md#3-core-navigation-moving-without-the-mouse), [7](06-windows-terminal-sessions.md#7-windows-splits-and-buffers), [11](05-search-and-files.md#11-file-explorer-nvim-tree), [12](05-search-and-files.md#12-fuzzy-finding--project-wide-search-fzf-lua), [22](02-navigation.md#22-jump-navigation-hopnvim).

### Copy, delete and move

| Keys | What it does |
| --- | --- |
| `yy` then `p` | Copy a line, paste it below |
| `dd` then `p` | Cut a line, paste it below |
| `diw` / `ciw` / `yiw` | Delete / change / copy the word under the cursor (`c` does not overwrite your paste register) |
| `5dd` / `5yy` | Delete / copy 5 lines |
| `<Alt-j>` / `<Alt-k>` | Move the line (or selection) down / up |
| `;3m10<CR>` / `;.m+2<CR>` | Move line 3 below line 10 / move the current line below the line 2 further down (`;` is `:`; `m` puts the line BELOW the target, `m0` = top) |
| `;.t+2<CR>` | Copy the current line below the line 2 further down (`t` copies, `m` moves) |
| `d` / `dd` / `D` / `x` then `p` | Delete is cut: there is no separate cut key. `c` / `C` / `cc` do not fill the register |
| `<Space>y` | Copy the whole buffer |
| `<Space>p` / `<Space>P` | Paste on a new line below / above |
| `p` in Visual mode | Replace the selection with what you copied |
| `[y` / `]y` | After a paste, step back / forward through the yank history |
| `:Rename <name>` / `:Move <path>` / `:Duplicate <name>` / `:Delete` | Rename, move, copy or delete the current FILE |
| tree: `a` `d` `r` `c` `x` `p` | Create, delete, rename, copy, cut, paste files in the file tree |

More (moving lines by number, a selection, part of a line: [Non-contiguous lines](03-editing.md#non-contiguous-lines-for-example-line-3-and-line-10-together)): sections [4](03-editing.md#4-editing), [11](05-search-and-files.md#11-file-explorer-nvim-tree), [24](03-editing.md#24-yank-history-yankynvim), [57](05-search-and-files.md#57-file-management-for-developers).

### Indented blocks

| Keys | What it does |
| --- | --- |
| `dii` / `yii` / `cii` / `vii` | Delete / copy / change / select the code block at the cursor's indent level |
| `dai` / `yai` / `cai` / `vai` | Same, including the lines that open and close the block |
| `[i` / `]i` | Jump to the top / bottom of the block |

More: section [5](03-editing.md#5-selection-visual-mode) ("ii / ai").

### Text objects (what to delete, change or copy)

| Keys | What it does |
| --- | --- |
| `diw` / `daw` | The word / the word with its space |
| `das` / `dis` / `cis` | The sentence with / without the space after it; change the sentence |
| `dip` / `dap` | The paragraph (without / with the blank line after it) |
| `di(` / `da(` | The text inside the parentheses / with the parentheses |
| `diS(` / `daS(` | Sandwich: empty the surrounding `(` `)` / remove them with their content |
| `ii` / `ai` | The indented block (see above) |
| `$V%` | Select a whole `{ }` block from its first line to the closing `}` (cursor on the line that ends with `{`; then `y`, `d`, `<Alt-j>` / `<Alt-k>` to copy, delete, move; [details](03-editing.md#select-a-whole-block-from-its-first-line-to-the-closing-brace-method-function-if-class)) |

The same objects work after `c`, `y` and `v`. More: sections [5](03-editing.md#5-selection-visual-mode), [6](03-editing.md#6-working-with-parentheses-quotes-and-brackets), [17](03-editing.md#17-surrounding-pairs-vim-sandwich--nvim-autopairs) and [70](01-basics.md#70-the-verb--noun-system-how-vim-commands-work).

### Macros

| Keys | What it does |
| --- | --- |
| `Qa` | Start recording into register `a` (`qa` works too) |
| `q` | Stop recording |
| `@a` / `5@a` / `@@` | Play it once / 5 times / repeat the last one (in Markdown buffers `@@` returns from a footnote instead: use `@a` again) |
| `:%normal @a` | Play it on every line of the file |

More: sections [29](03-editing.md#29-registers--macros) and [60](03-editing.md#60-macros-in-depth).

### Bulk rename and replace

| Goal | What to do |
| --- | --- |
| Rename a code symbol everywhere in the project | `<Space>rn`, type the new name, `<Enter>` (LSP) |
| Replace text in the current file | `:%s/old/new/g` (add `c` to confirm each one) |
| Replace text in every file of the project | `:grep "old"` then `:cfdo %s/old/new/g \| update` |
| Replace one by one, deciding each time | `*`, `ciw` + new word + `<Esc>`, then `n` to skip or `.` to replace |
| Rename or move one file | `:Rename <name>` / `:Move <path>`, or `r` in the file tree |
| Undo a multi-file replace | See section [67](05-search-and-files.md#67-multi-file-search-and-replace-complete-guide) |

Files are renamed one at a time with the commands above. More: sections [10](05-search-and-files.md#10-searching-replacing-and-refactoring-text) and [67](05-search-and-files.md#67-multi-file-search-and-replace-complete-guide).

### Undo, redo and repeat

| Keys | What it does |
| --- | --- |
| `u` / `<Ctrl-r>` | Undo / redo |
| `<Space>u` | Show the undo tree in a left panel |
| `.` | Repeat the last change (e.g. `ciw` + word, then `n` and `.` on the next match) |
| `[y` / `]y` | After a paste, replace the pasted text with an earlier / later yank (yank two lines, `p`, then `[y`) |

More: sections [24](03-editing.md#24-yank-history-yankynvim), [25](03-editing.md#25-undo-history), [61](03-editing.md#61-the-dot-command-----repeating-actions).

### Visual block (many lines at once)

| Keys | What it does |
| --- | --- |
| `<Ctrl-v>` then `j` / `k` | Select a rectangle of text |
| `I` then text then `<Esc>` | Insert the text at the start of every selected line |
| `A` then text then `<Esc>` | Append the text at the end of every selected line |
| `d` / `c` | Delete / change the selected block |
| `g<Ctrl-a>` | Count up 1, 2, 3 ... down the selected numbers |
| `<Alt-j>` / `<Alt-k>` | Move the selected lines down / up |

More: section [62](03-editing.md#62-visual-block-editing-multi-cursor-like).

### Comments and surrounding pairs (vim-commentary, vim-sandwich)

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

More: sections [16](03-editing.md#16-code-commenting) and [17](03-editing.md#17-surrounding-pairs-vim-sandwich--nvim-autopairs).

### Search in a file

| Keys | What it does |
| --- | --- |
| `/text` then `<Enter>`, `n` / `N` | Search forward, next / previous match |
| `*` / `#` | Search the word under the cursor forward / backward |
| `;noh<Enter>` | Clear the search highlight |
| `:%s/old/new/gc` | Replace with a question for each match |

More: sections [10](05-search-and-files.md#10-searching-replacing-and-refactoring-text) and [23](02-navigation.md#23-search-lens-nvim-hlslens).

### Buffers, splits, tabs

| Keys | What it does |
| --- | --- |
| `gb` / `gB`, `<Space>bp` | Next / previous buffer, pick one by letter |
| `<Ctrl-^>` (in Neovide also `<Ctrl-6>`) | Jump to the previous buffer and back again, like Alt-Tab for files |
| `\d` / `\D` | Close this buffer / close all other buffers |
| `<Space>-` / `<Space>\|` | Split below / to the right (same file) |
| `:b <name\|number>` then `:vert sbuffer <name\|number>` | Two chosen open buffers side by side (`:sbuffer` without `vert`: one above the other) |
| `<Ctrl-w>h` `j` `k` `l` | Move between windows |
| `<Left>` `<Down>` `<Up>` `<Right>` | The same, with the arrow keys (normal mode) |
| From a terminal window (run output, `:term`) | `<Esc>`, then `<Ctrl-w>h` (or an arrow key) to go to the code; `i` to type in the terminal again |
| From the Claude panel | `<Ctrl-h>` goes back to the code on the left (`<Esc>` is sent to Claude); `<Ctrl-w>l` or `<Right>` from the code goes back in |
| `<Ctrl-w>=` / `<Ctrl-w>o` | Make windows equal / keep only this window |
| `<Ctrl-w>x` / `<Ctrl-w>r` | Swap this window with the next one (the file on the right goes to the left) / rotate all windows of the row |
| `:BufferLineMovePrev` / `:BufferLineMoveNext` | Move the current tab one place left / right in the top bar (no key for it: type the command; section [7](06-windows-terminal-sessions.md#7-windows-splits-and-buffers)) |
| `gt` / `gT`, `\t` / `\T` | Next / previous tab, close this tab / the other tabs |
| `:sp <file>` / `:vs <file>` | Open a file in a new horizontal / vertical split (`;` works like `:`, so `;vs <file>` too) |

More: section [7](06-windows-terminal-sessions.md#7-windows-splits-and-buffers).

### Save and quit

| Keys | What it does |
| --- | --- |
| `<Space>w` | Save (only writes if changed) |
| `<Space>q` | Save and close this window |
| `<Space>Q` | Quit nvim, asks first (default No), discards unsaved work |
| `:wa` / `:q!` | Save all buffers / close this window and discard changes |
| (automatic) | Auto-save: a changed file saves itself when you switch buffer or leave the nvim window; a message "AutoSave: saved at ..." appears (not for unnamed or read-only buffers, terminals, LaTeX and Typst files) |

More: section [72](01-basics.md#72-saving-quitting-and-file-state).

### Sessions, dashboard and zoxide

| Keys | What it does |
| --- | --- |
| `\h` / `\H` | Open the dashboard / return to the previous buffer |
| `r` / `L` on the dashboard | Restore the session of this folder / of the last folder |
| `<Space>?` | Open the user guide as a PDF in zathura next to Neovim (any buffer and the dashboard; clickable table of contents; `q` closes it) |
| `<Space>a` | Ask Claude "how do I do X in Neovim": split on the right (own tab on the dashboard), skill loaded, always Sonnet; `/exit` closes it |
| `:Z <word>` / `:z <word>` | Jump to the best zoxide match (the file tree follows) |
| `:Obsession`, `nvim -S Session.vim` | Keep a `Session.vim` up to date, restore it later |
| `<Space>sv` | Restart nvim (writes all files first) |

More: sections [30](05-search-and-files.md#30-working-with-directories) and [58](06-windows-terminal-sessions.md#58-session-and-productivity).

### Code intelligence (LSP)

| Keys | What it does |
| --- | --- |
| `gd` / `K` | Go to definition / hover documentation |
| `<Space>gd` / `<Space>gr` / `<Space>gi` | Peek definitions / references / implementations |
| `<Space>rn` / `<Space>ca` | Rename symbol / code actions |
| `<Space>fm` | Format the file |
| `]d` / `[d` | Next / previous diagnostic |
| `<Space>dd` | Show the diagnostic under the cursor |

More: sections [13](07-code.md#13-lsp-language-server-protocol) and [44](07-code.md#44-language-server-protocol-lsp-in-depth).

### Completion and snippets

The completion menu opens by itself while you type in Insert mode (from 1 character; buffer words from 2).

| Keys | What it does |
| --- | --- |
| `<Tab>` | Menu open: select the next item. Menu closed: insert a normal tab |
| `<CR>` | Confirm the item you picked with `<Tab>`; with nothing picked it is a plain newline |
| `<Ctrl-e>` / `<Esc>` | Close the menu (without it: end of line / leave Insert mode) |
| `<Ctrl-d>` / `<Ctrl-f>` | Scroll the documentation window up / down (menu open) |
| `<Ctrl-j>` / `<Ctrl-k>` | Expand a snippet or jump to the next placeholder / jump back |
| `<Space>fs` | Gallery: fuzzy-search only your own snippets (`my_snippets/`) for this filetype and insert one |
| `<Alt-s>` (Insert mode) | Same gallery, inserting at the cursor |

Menu order: language server, then snippets, then paths, then buffer words (LaTeX files start with vimtex). In the `/` search line the menu offers buffer words; in `:` it offers paths and commands.

More: sections [14](04-completion-snippets.md#14-autocompletion-nvim-cmp), [15](04-completion-snippets.md#15-snippets-ultisnips), [45](04-completion-snippets.md#45-autocompletion-in-depth-nvim-cmp) and [52](04-completion-snippets.md#52-snippets-for-developers-ultisnips) (the gallery is in section [52](04-completion-snippets.md#52-snippets-for-developers-ultisnips), "[The snippet gallery](04-completion-snippets.md#the-snippet-gallery)").

### Git day to day

| Keys | What it does |
| --- | --- |
| `<Space>gs` | Git status |
| `<Space>gw` / `<Space>ga` | Add the current file / add all changes |
| `<Space>gu` | Unstage the current file |
| `<Space>gv` | Vertical diff of the file against the index |
| `<Space>gc` / `<Space>gA` | Commit / amend the last commit |
| `<Space>gpl` / `<Space>gpu` | Pull / push |
| `<Space>gB` | Branch menu: pick a branch to switch to (same as clicking the branch in the statusline) |
| `]c` / `[c` | Next / previous changed hunk |
| `<Space>hp` / `<Space>hb` | Preview the hunk / blame the line |
| `<Space>hs` / `<Space>hr` | Stage / reset the hunk (reset asks Yes/No; works on selected lines in visual mode) |
| `<Space>gl` | Copy a permalink for the line |
| `:Neogit` / `:NeogitLogCurrent` | Open the Neogit status window / the log of the current file (`q` closes) |

More: sections [20](08-git.md#20-git-integration) and [48](08-git.md#48-git-workflow-in-depth).

### Mouse

| Action | What it does |
| --- | --- |
| Click a tab in the top line | Switch to that buffer |
| Click the `x` / `●` of a tab | Close the buffer (a changed file asks Save / Discard / Cancel) |
| Click the branch name in the statusline | Branch menu (also `<Space>gB`) |
| Click the language-server name in the statusline | Popup with the attached language servers (also `:LspAttached`) |
| Right-click in the text | Neovim's menu: `Paste` pastes the clipboard, `Select All` selects the whole file, `Inspect` shows which highlight and syntax group is under the click, `How-to disable mouse` opens the help for it |

More: sections [7](06-windows-terminal-sessions.md#7-windows-splits-and-buffers) and [32](06-windows-terminal-sessions.md#32-statusline-lualinenvim).

### Language guides (tools that exist only for one language)

| Language | What the guide covers | Section |
| --- | --- | --- |
| Java | nvim-java, jdtls, running, JUnit tests, debugging, refactoring, profiles | [78](languages/java.md#78-java-nvim-java-jdtls-tests-debugging) |
| Python | pyright, ruff, black, uv, `<Space>rf` / `<F9>` and `<Space>rr`, pdb debugging | [79](languages/python.md#79-python-pyright-ruff-black-uv-running-and-debugging) |
| LaTeX | vimtex, texlab, ltex, compiling, the PDF viewer | [80](languages/latex.md#80-latex-vimtex-texlab-ltex-pdf-viewer) |
| Markdown | marksman, rendering, preview, footnotes, `:ToPDF` | [81](languages/markdown.md#81-markdown-writing-preview-footnotes-pdf) |
| Typst | tinymist, `<Space>tw` watch, the PDF viewer | [82](languages/typst.md#82-typst-typstvim-tinymist-watch-and-preview) |

### Language devShells (`:DevEnv`)

| Command | What it does |
| --- | --- |
| `:DevEnv <lang>` | Enter a language devShell (`java`, `latex`, `typst`, `python`, ...) from the running Neovim, without restarting: adds its programs to `PATH`, enables the language servers and plugins that were waiting. `<Tab>` lists the names. First call about 10 s, then cached. Example: `:DevEnv java` |

Full list of devShells and details: [section 43](07-code.md#43-how-the-development-toolchain-fits-together).

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

`j` and `k` type letters into the search bar. More: section [12](05-search-and-files.md#12-fuzzy-finding--project-wide-search-fzf-lua).

### Quickfix list (search results, errors)

| Keys | What it does |
| --- | --- |
| `:copen` / `:cclose` | Open / close the list |
| `:cnext` / `:cprev` | Next / previous item |
| `\x` | Close the quickfix and location lists |
| `p` / `zf` in the list | Preview the item / filter the list with fzf |
| `<Tab>` in the list | Mark the item |
| `<Ctrl-x>` / `<Ctrl-v>` in the list | Open the item in a horizontal / vertical split |
| `:cfdo %s/old/new/g \| update` | Replace in every file of the list (fill the list first with `:grep`; other file sets: `:bufdo`, `:argdo`, see [do-commands](05-search-and-files.md#understanding-cdo-vs-cfdo-vs-bufdo)) |

More: sections [26](05-search-and-files.md#26-quickfix--location-list) and [51](05-search-and-files.md#51-quickfix-workflows-for-developers).

### Spell checking

| Keys | What it does |
| --- | --- |
| `<Space>cz` | Spell checking on / off (`:set spell` / `:set nospell` too) |
| `]s` / `[s` | Next / previous misspelled word |
| `z=` | Show suggestions |
| `zg` / `zw` | Add the word to your allowed list / mark it as wrong (`2zg` Italian, `3zg` German, `4zg` French) |
| `zug` | Undo the last `zg` |
| `:e ~/.config/nvim/spell/en.utf-8.add` | Open the list of allowed English words (one per line: delete a line to forbid the word again) |

`:set nospell` only turns off the built-in checker. Typo underlines that come from the language servers (`typos_lsp` in code, `ltex_plus` in prose) stay; they are diagnostics. More: section [31](09-ai-and-writing.md#31-spell-checking).

### Run code and terminal

| Keys | What it does |
| --- | --- |
| `<Space>rr` | Run the current file in a terminal on the left |
| `<Space>rf` / `<F9>` | Run or compile the file the editor's own way (Lua, Vim script, Python, C++, LaTeX; one warning in other file types) |
| `:term` | Open a terminal in this window |
| `<Esc>` / `i` | Leave terminal mode / go back into it (`<Esc>` works differently in the Claude panel, see sections [8](06-windows-terminal-sessions.md#8-terminal-integration) and [9](09-ai-and-writing.md#9-ai-assistant-window-claude-code-claude-codenvim)) |

More: sections [8](06-windows-terminal-sessions.md#8-terminal-integration) and [19](07-code.md#19-code-running). `<Space>rf` in any other file type shows one warning (`no editor-run for this file type (use <Space>rr for a terminal run)`).

### Python debugger keys (pdb through nvim-gdb)

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

More: section [79](languages/python.md#79-python-pyright-ruff-black-uv-running-and-debugging).

### Java debugger keys (nvim-dap through nvim-java)

Global keys; all four (`<Space>jp`, `<Space>jh`, `<Space>jP`, `<Space>jx`). Stepping and continuing have no keys: type the commands.

| Keys | What it does |
| --- | --- |
| `<Space>jp` | Toggle a breakpoint on this line (put it on a line with code) |
| `:DapContinue` | Start the debugger on a `main` class (pick an entry in the `Configuration` list) or run on while paused |
| `:DapStepOver` / `:DapStepInto` / `:DapStepOut` | Next line / into the call / back to the caller |
| `<Space>jh` | While paused: show the value of the variable under the cursor |
| `<Space>jx` | Stop the debug session |
| `<Space>jP` | Remove ALL breakpoints in all files at once (capital P; no undo) |
| `:DapClearBreakpoints` | Same as `<Space>jP` (`<Space>jp` removes only the one on the line) |

More: section [78](languages/java.md#7-debugging).

### Keyboards without function keys, Insert or Page keys

Nearly every key in this guide has a version without function keys. `<F9>` is `<Space>rf` (run the file the editor's own way); the Python debugger has the `<Space>d` keys above. `<S-Insert>` (paste in the GUI, ginit.vim) is replaced by `<Ctrl-r>` then `+` in Insert mode or on the command line (built-in Vim, works everywhere); `<Ctrl-d>` / `<Ctrl-u>` scroll instead of the Page keys. Unicode `<F4>` is replaced by `<Ctrl-k>` + two letters (section [38](09-ai-and-writing.md#38-url--unicode-gxnvim-vim-highlighturl-unicodevim)). The only keys left are three vimtex defaults in section [80](languages/latex.md#80-latex-vimtex-texlab-ltex-pdf-viewer) (`<F6>`, `<F7>`, `<F8>`).

### Folding (nvim-ufo)

| Keys | What it does |
| --- | --- |
| `za` | Toggle the fold under the cursor |
| `zR` / `zM` | Open / close all folds |
| `zr` / `zm` | Open / close one more fold level |
| `<Space>K` | Preview the folded lines |

More: section [18](07-code.md#18-code-folding-nvim-ufo).

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

More: sections [66](10-various.md#66-shell-commands-from-inside-neovim), [68](03-editing.md#68-useful-vim-tricks) and [71](03-editing.md#71-the-global-command-g).

### Claude and fuzzy finders

| Keys | What it does |
| --- | --- |
| `<Space>cc` | Toggle the Claude Code window |
| `<Space>a` | Ask Claude how to do something in Neovim (vertical split, skill loaded, always Sonnet) |
| `<Space>?` | Open the user guide PDF |
| `<Space>ff` / `<Space>fg` | Find a file / search text in the project |
| `<Space>fb` / `<Space>fr` / `<Space>fh` | Open buffers / recent files / help tags |
| `<Space>fs` (`<Alt-s>` in insert mode) | Fuzzy-search your own snippets and insert one (section [52](04-completion-snippets.md#52-snippets-for-developers-ultisnips)) |

More: sections [9](09-ai-and-writing.md#9-ai-assistant-window-claude-code-claude-codenvim) and [12](05-search-and-files.md#12-fuzzy-finding--project-wide-search-fzf-lua).

### Other most-used keys (from the former quick reference)

| Keymap | Action |
| --- | --- |
| `]<Space>` / `[<Space>` | Insert a blank line below / above (cursor stays; `3]<Space>` inserts 3) |
| `gS` | Split / join the list, arguments or block under the cursor (treesj) |
