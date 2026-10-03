# 05 - Auditing the user guide (self-contained)

Contents: 1 Structure and conventions (layout, tone and notation, tested markers, policies) / 2 Audit procedure (per claim class) / 3 Wrong-info patterns found in past audits / 4 Rule: every change updates the guide, and the staleness checklist


Goal: the guide must never contain stale or wrong information. Paths are relative to the config dir
`general/general-nvim/.config/nvim` in the dotfiles repo (call it `$NV`) unless absolute.
Hard facts first:

- The guide is the FOLDER `$NV/user-guide/` (there is no `user-guide.md` any more).
- Truth order: the live config (mappings, plugin specs, plugin source) beats the guide. When they disagree, the guide is corrected.
- Correcting wrong text needs no approval. ADDING new examples/content needs the owner's approval (see rule R5).
- The repo is PUBLIC: no secrets, private hosts, personal paths in the guide.

## 1. Structure and conventions

### 1.1 Layout

| File | Content |
| --- | --- |
| `user-guide/README.md` | Intro, "Contents" table (chapter -> sections with GitHub anchors), then section 2 = "Day-to-Day Cheat Sheet" (16+ topic tables, each ending with `More: sections N, M`) |
| `01-basics.md` .. `10-various.md` | Chapters. Each starts with `<!-- chapter: <name> -->` then `[Back to the guide index](README.md)`, then `# N. Title` headings |
| `languages/{java,python,latex,markdown,typst}.md` | Sections 78-82, one self-contained guide per language. Start with `<!-- chapter: X -->` and `[Back to the guide index](../README.md)` (note `../`) |

- Sections are numbered 1..82 (heading form `# N. Title`). Numbers are STABLE: never renumber, never reuse a number. "see section N" references everywhere point at these numbers; the README says so.
- Section order inside a chapter is by topic, not by number (e.g. 07-code has 13, 44, 18, 47 ...). Do not "fix" the order.
- "Part II: Developer Guide" is a heading inside `10-various.md`; "Part III: Everyday Scenarios & Recipes" is inside `07-code.md`. Parts are only headings, not files.
- Language guide layout (78-82): intro paragraph; "What you get" table (feature / what it does / needs); Quick start (numbered); Requirements/devShell (+ an "Outside the devShell" table: what happens when the tool is missing); keys and commands tables; tested workflows; Troubleshooting table (symptom | cause | fix); last heading "Related sections" listing `section N (topic)` pointers. Java uses numbered `## 1.` subheadings; the others do not.
- Where new content goes: first look for an existing subsection/table and extend it (never duplicate a near-identical entry; edit that one). New everyday keys also go into the cheat sheet (README, section 2) and, if language-specific, into the language section. New plugin = subsection in the section that owns that topic AND the "In Depth" twin section (Part II repeats Part I) AND `10-various.md` "Other Plugins" only if it has no better home. New command = section 34 Custom Commands and section 59 Useful Developer Commands. New file/chapter: add to the README Contents table.
- Do not reorganise sections. Keep the existing style.

### 1.2 Tone and notation

- Written for people who are NEW to Neovim: short plain sentences, explain the why, state the surprising part (remap, mode, count, what a selection includes). No jargon without a one-line explanation. No marketing words.
- Key notation: `<Space>` (never `<leader>` and never `<Space>` abbreviated), `<Ctrl-x>`, `<Alt-x>`, `<Shift-x>`, `<Enter>`, `<Esc>`, `<Tab>`, `<Left>`; combos in backticks: `<Ctrl-w>d`, `<Space>gbl`. The config source uses `<C-x>`, `<A-x>`, `<M-x>`, `<leader>`: when grepping the guide search BOTH spellings. `<A-x>` and `<M-x>` are the same key (the keymap dump prints `<M-x>`).
- Mode letters in "Mode" columns: `n` normal, `x` visual (NOT `v`; `v` also means select mode), `o` operator-pending, `i`, `c`, `t`. A map defined for `{n,x}` does not exist after an operator (`dL` uses builtin `L`). Wrong mode letters were a past finding (hop `f` is `n, x, o`; `<Space>gb` is `x`; builtin `an`/`in` are `x, o`).
- Key tables: `| Keymap | Mode | Description |` or `| Keys | What it does |`; cheat-sheet tables `| Keys | What it does |` / `| Goal | What to do |`; troubleshooting `| Symptom | Cause | Fix |`. Each table row = one thing; keep column counts equal on every row.
- Pipes inside table cells must be escaped (`\|`); a code span containing a pipe needs the escape too, or use a double-backtick span.
- Commands are written `:Name args`; shell lines go in ```bash fences; nix/lua in ```nix / ```lua fences. Code in the guide copied from the config (e.g. the nvim-java spec in section 78) must still equal the file (comments may be omitted).
- Emoji or glyph descriptions must match the config (diagnostic signs are Nerd Font glyphs, not emoji).

### 1.3 "tested" markers

- `(tested)` / `Tested:` / `(tested: <what was observed>)` means a REAL key/command was run and the stated result observed (43 plain `(tested)` plus many with the observation). Never write it from reasoning, source reading or a headless guess about UI behaviour; if only the source was read, write what the source says without "tested".
- Open questions were once marked `<!-- CHECK-USER -->`; there are 0 now. Any new `CHECK-USER` marker needs an entry for the owner; none should remain unresolved in a finished guide (`grep -rc CHECK-USER user-guide/ | grep -v ':0'` must print nothing). Leftover draft text such as "not tested yet", "Manual test", "Claims to verify", "actually simpler" is a defect.
- A claim that cannot be re-derived (needs a database, a PDF viewer click, a devShell tool that is absent) stays as-is but is listed as "not re-run" in the audit report, never silently approved.

### 1.4 Policies (condensed POL rules; the guide must reflect each)

- POL-1: visual `p` is yanky's (replaced text goes into the register; `"0p` re-pastes the last yank). The old `x p` map is gone; yanky loads at VeryLazy; `[y` / `]y` step through the ring after a paste.
- POL-2/3/23: all vim-eunuch commands exist from a fresh start; `:Mkdir <dir>` always creates parents (no `!` form, no `-p`); `:Tabularize` works in any filetype.
- POL-4: `is`/`as` are the BUILTIN sentence objects (`das`, `dis`, `cis`); the vim-sandwich query objects are `iS`/`aS` (`diS(`, `daS"`). `ib`/`ab` = targets.vim. `s` is disabled in normal mode (use `cl`); in operator-pending `s` = `<Esc>`.
- POL-5..13: lazy-loading facts: nvim-java loads on the first Java file (`ft=java`); claude-code, indentscope, auto-save, vim-obsession, vim-commentary, yanky load at VeryLazy; neogit loads on its first `:Neogit*` command in any directory; nvim-tree loads on `<Space>s` or any of the five `:NvimTree*` commands; `:DiffviewClose` exists only after a view was opened; `:Java*` commands exist only while jdtls is attached; unicode.vim/undotree commands exist only after their first key (`ga`, `<Space>cu`, `<Space>u`).
- POL-17: outside a git repo the fugitive/gitsigns keys are NOT mapped: `<Space>` moves one column right and the rest runs as normal Vim keys; `<Space>gbl` works everywhere. "Do nothing" is wrong wording.
- POL-18: vim-illuminate in `.nix` files uses text/treesitter matching, not the LSP provider.
- POL-19: colorcolumn per language: 80 c/cpp/sh/bash/yaml/vim/haskell/r/javascript(react)/typescript(react); 88 python; 100 java/rust/swift/nix/typst; 120 lua/php/tex; others 100; text none.
- POL-20: `<Space>-` = `:split`, `<Space>|` = `:vsplit`.
- POL-21/24: nvim-tree window picker draws letters with vimade switched off while picking; the tree root follows `:cd`, `:tcd`, `:Z`, `:z`.
- POL-22: `<Space>Q` asks "Quit nvim?" (Yes/No, default No) and discards unsaved changes on yes; `<Space>q` = save-if-modified and close the window.
- POL-25/26/28/29: cheat sheet (section 2), "Moving Inside Any Picker" (section 12), "Buffer Tabs (the Top Line)" (section 7, bufferline click on x/dot gives a Save dialog), Neovide (section 77) exist; keep them.
- POL-27: `<Space>gB` opens the statusline branch menu (also reachable by clicking the branch).
- POL-31: Claude panel exactly 30% wide after a terminal resize; code windows equal (+-1). Layout convention: RIGHT = persistent panels (Claude, aerial), LEFT = short single-task panels (`:help` on screens >= 200 columns, undo tree).
- POL-33: sections 78-82 are the language guides; the cheat sheet has a "Language guides" table pointing to them.
- POL-34/35: the user's keyboard has NO function keys: every `<F9>` run key has the alias `<Space>rf` (lua, vim, python, cpp, tex; other file types give one warning); python pdb keys are `<Space>dc dn ds df dB du dv` (leader keys; `<Space>dv` only during a session; `<Space>dp` starts pdb). The guide must show the `<Space>` alias next to every `<F9>`.
- gcs/gcr principle: `gc` = vim-commentary (uses `commentstring` only); `gcs`/`gcr` = the custom smart_comment engine (adds/removes language-specific markers, fence-language aware in markdown, never nests, `gcr` strips all levels).
- Replaced things are removed COMPLETELY from the guide: vista (now aerial `<Space>t`), mundo (undotree), git-conflict (diffview), mason/mason-lspconfig (LSPs come only from nix), iron, treesitter-textobjects plugin, vim-visual-multi (commented out: no multi-cursor), Copilot / CopilotChat, vlime, vim-grammarous (ltex_plus), `viml_conf/*.vim` (now `lua/options.lua`, plugin settings in spec `init`), the old dashboard keys, `<Space>o`/`<Space>O`, `x p`. Also gone: gitlinker `<Space>gy`. A mention is only allowed as an explicit "was removed / use X instead".
- Rule R5 (examples): no invented examples. Every example (recipe, sequence, expected output) must be one the owner approved or that was actually run. Generalise (`foo`, `X`, `<char>`), never use the owner's code/file names.
- Rule R6 (every keymap): a map must have a `desc`; changed keys update guide + desc + clash check (see section 4).

## 2. Audit procedure

Work in an ISOLATED copy so the real `lazy-lock.json` and data dirs are never mutated: lazy.nvim rewrites `lazy-lock.json` inside the config dir when a plugin is loaded. Either copy `$NV` to a scratch dir and run with scratch `XDG_CONFIG_HOME/DATA/STATE/CACHE` (symlink or `cp -a` the plugin dir `~/.local/share/nvim/lazy`, `site/` parsers and `nvim-java/`), or at minimum run `git -C $NV status --short lazy-lock.json` afterwards and `git checkout lazy-lock.json` if changed. Never touch the owner's clipboard (set `clipboard=` in tests), tmux sessions or the real data dir. Delete scratch dirs afterwards. Use `nice -n 10`; one nvim at a time.

Headless dump script (save under scratchpad, run `nvim --headless -u $NV/init.lua -c 'source dump.lua' -c qa`; load everything first, as keys of lazy plugins appear only after load):

```lua
vim.cmd("sleep 300m")
pcall(function() require("lazy").load({ plugins = vim.tbl_keys(require("lazy.core.config").plugins) }) end)
vim.cmd("doautocmd User VeryLazy")
local out = {}
for _, m in ipairs({ "n", "x", "o", "i", "c", "t" }) do
  for _, k in ipairs(vim.api.nvim_get_keymap(m)) do
    out[#out+1] = table.concat({ m, k.lhs, k.buffer == 1 and "buf" or "glob", k.desc or "", k.rhs or "" }, "\t")
  end
end
vim.fn.writefile(out, "/path/to/scratchpad/maps.txt")
local cmds = {}
for name in pairs(vim.api.nvim_get_commands({})) do cmds[#cmds+1] = name end
vim.fn.writefile(cmds, "/path/to/scratchpad/commands.txt")
```

Buffer-local maps (ftplugin, LspAttach, gitsigns, diffview, dashboard, markdown) only appear when a buffer of that kind is open: also dump with `nvim --headless file.md` / `.py` / `.lua` / `.tex` / `.typ` / a java file / a file in a git repo, and a run OUTSIDE a git repo and OUTSIDE the devShell. Compare `<A-x>` vs `<M-x>` spelling. Also run a FRESH-start dump (no forced loading) to learn what exists before a lazy trigger.

For each claim class:

| Claim class | How to verify | Typical failure |
| --- | --- | --- |
| Keys (lhs, mode, scope) | grep the dump; `vim.fn.maparg(lhs, mode, false, true)` gives `buffer`, `desc`, `rhs`; empty `{}` = no map. Then grep the source: `grep -rn '<space>zz' lua after plugin` (case-insensitive; lazy `keys = {}` stubs in `lua/plugin_specs.lua`; per-plugin `lua/config/*.lua`; `lua/mappings.lua`; `after/ftplugin/*`). Check duplicates (the later definition wins) | wrong mode letter, buffer-local key described as global, key that moved, key that never existed |
| What a key DOES | feed real keys: `nvim_feedkeys` in headless for text edits, or a private tmux server (`tmux -L t new -d -x 200 -y 50`, `send-keys`, `capture-pane -p`, `kill-server` at the end) for UI/float/terminal/dashboard behaviour. Builtin motions: test them; do not trust memory | wrong "selects X" statements, counts, cursor end position |
| Commands | `vim.fn.exists(":Cmd")` (2 = exists) in fresh and loaded runs; `:verbose command Cmd`; compare with `commands.txt`; lazy `cmd = {}` lists in `plugin_specs.lua` | command only exists after first use, removed command, wrong args (`:Mkdir!`) |
| Options | `:verbose set opt?` (shows who set it and where); `lua/options.lua`, `after/ftplugin/*`, `FileType` autocmds (colorcolumn) | value wrong, option leaks vs buffer-local, per-filetype value |
| Plugin behaviour | read the plugin source/doc under `~/.local/share/nvim/lazy/<name>/` (`doc/*.txt`, `lua/`, `plugin/`); plugin list vs `lua/plugin_specs.lua` and `lazy-lock.json`; `require("lazy").stats()` / `:Lazy` | doc says what the plugin does by memory, `:Obsession!` deletes the session, cmp `<Ctrl-d>` scrolls UP |
| Plugin loaded when? | spec triggers (`event`, `cmd`, `ft`, `keys`, `lazy`) vs fresh-start dump; `require("lazy.core.config").plugins[name]._.loaded` | "available at start" for lazy-only things |
| "tested" claims | spot-check a sample by re-running the exact keys in tmux/headless; at least every claim whose neighbour code changed since the text was written (`git log`). Claims that cannot be reproduced (database, viewer click, devShell tool absent) are reported "not re-run" | observation was a guess; claim contradicted by later config change |
| Section references | for every "section N" / "sections N, M": the target heading must exist (`grep -rn '^# N\. ' user-guide/`) and must be about the stated topic | closing floats is section 7 not 2; big files is section 42 not 41 |
| Table integrity | script: for each table, the cell count of every row equals the header's; count pipes outside code spans; a row flagged only because of a double-backtick span is a false positive | unescaped `\|` inside code span splits the cell |
| Code fences | per file the number of lines starting with three backticks must be even; no unclosed fence; nested fences use a longer fence | one stray fence swallows the rest of the file |
| Anchors / Contents | every README link `chapter.md#slug` must resolve: slug = heading lowercased, backticks and punctuation removed (`.`, `(`, `)`, `:`, `,`, `/`, `&`, `+`, `'`), spaces to hyphens; a removed `&`/`--` between spaces leaves a DOUBLE hyphen (`vim-sandwich--nvim-autopairs`, `the-dot-command-----repeating-actions`, `write-and-quit` style). Compare with the headings list; every section heading must be listed exactly once | renamed heading, new section missing from Contents |
| Dashboard `u` | `lua/config/dashboard-nvim.lua` (around the item with `u`) opens `stdpath("config") .. "/user-guide/README.md"` in a new tab; that file must exist; test `\h` / the dashboard `u` in tmux if the path or folder changed | path points to deleted `user-guide.md` |
| Skill paths | `.claude/skills/*/SKILL.md` (repo-relative) that mention the guide (answering-neovim-usage-questions, auditing-neovim-config) must name the folder `user-guide/` and the real chapter names; `ls user-guide user-guide/languages` and compare | skill still says `user-guide.md` or lists a missing chapter |
| LSP servers / formatters | list in sections 13 and 44 vs `lua/config/lsp.lua` and `after/lsp/*.lua` (identical sets; jdtls separate); formatters/tools vs `~/nix` devShell templates (`~/nix/templates/<user>/dev-environments/.../flake.nix`) and global `neovim.nix` package list | tool listed as global that is devShell only (ruff, black), server name `ltex` vs `ltex_plus` |
| Snippets / parsers / colorschemes / smart-comment languages | triggers vs `my_snippets/*.snippets`; parsers vs `lua/config/treesitter.lua`; colourschemes vs `lua/colorschemes.lua`; comment language list vs `lua/smart_comment/` specs | lists drifting |
| Removed things | `grep -rniE 'mason|git-conflict|iron\.|treesitter-textobjects|viml_conf|copilot|vista|mundo|vlime|grammarous|user-guide\.md|<Space>o\b|StartVlime|nvim-java-core' user-guide/` must only hit "was removed" sentences | whole sections for removed plugins |
| Every key in the config appears | diff the dump of OUR maps (those with a desc from `lua/mappings.lua`, `lua/config`, `after`) against the guide: any own map not documented anywhere = missing; any documented key absent = stale | silent additions never documented |

Also each time: `grep -rn "^# [0-9]" user-guide | wc -l` = 82 with no gaps/duplicates; every file starts with the `<!-- chapter: -->` comment and the Back link; cheat-sheet "More: sections ..." pointers resolve; no `<F9>` without `<Space>rf` mention in running-code text; no leftover "TODO", "XXX", "UNSURE".

## 3. Wrong-info patterns found in past audits (grep for the same kinds)

Keys and notation
- `<Tab>` named for snippets: UltiSnips expand and jump are `<Ctrl-j>` / `<Ctrl-k>` (in plugin_specs.lua); `<Tab>` only selects the next completion item or inserts a tab. Grep `Tab` near "snippet" / "placeholder".
- nvim-cmp: `<Ctrl-d>` scrolls docs UP, `<Ctrl-f>` DOWN; outside the menu `<Ctrl-e>` = end of line, `<Ctrl-d>` = delete char right, `<Ctrl-f>` nothing. `<CR>` confirms only a picked item.
- `<Space>dd` is `vim.diagnostic.open_float` (a float for the current line), NOT a diagnostics list (lists are `<Space>db`, `<Space>dw`, `<Space>qb`, `<Space>qw`).
- `gc` vs `gcs`/`gcr`: fenced-code-block language handling in Markdown belongs to `gcs`/`gcr` (smart_comment), not `gc` (vim-commentary: commentstring only).
- `<Esc>` closing floating windows is documented in section 7 ("Closing Floating Windows"), not section 2.
- Mode letter `v` where the map is `x`; `an`/`in` `x` only when really `x, o`; `H`/`L` are `n, x` only (not `o`).
- `sd{`/`sdB` (sandwich): `sdB` does nothing, use `sd{` or `sdb`; `gB` with a count does nothing (previous buffer only without count); `s` is disabled so "enter insert with `s`" is wrong.
- `@@` in Markdown buffers is the footnote-return key and shadows macro replay (use `@a`).
- `<Space>q` = `:x` (not "quit"), `<Space>Q` asks first (older text said "`:qa!` at once"); `<Space>q` and `<Space>s` cause a 500 ms wait (they prefix `<Space>qb` / `<Space>sv`; timeoutlen 500).
- Old keys still mentioned after removal: `<Space>o`/`O`, `x p`, `co/ct/cb/c0/]x/[x` (git-conflict), `<Space>gy`, vista `<Space>t` text, `\` markdown line break (now `<Space>mb`), `<M-m>` on mac/win.
- `vis`/`vas` described as "nearest pair" (they are sandwich query objects needing the char; now `iS`/`aS`).

Plugin / feature behaviour
- Snippet/environment: Python devShell outputs are `default`, `py-stable`, `py-lts`, `py311` (`use_dev_env "python#py-lts"`); `python#python-lts` and `python-lts` as an output name do NOT exist.
- Python debugging quirk "after a debug session `<F9>` is gone until `:e!`": FIXED (nvim-gdb eval key moved to `<Space>dv`); any remaining mention (sections 36/56, 79, troubleshooting rows) is stale. Check every "known quirk" against the current config.
- jdtls: "Clear the jdtls workspace cache (close and reopen Neovim afterwards)" is wrong: nvim-java restarts jdtls by itself after the Yes/No question. Also "With jdtls no terminal is used": the Java runner opens its own 15-line full-width split at the bottom (only the `<Space>rr` left terminal is not used). `JDK is managed by the system on NixOS` is wrong: JAVA_HOME comes from the Java devShell and nvim-java never auto-installs a JDK on nix.
- Big-file behaviour is section 42 (Automatic Behaviors), not 41 (Filetype-Specific Settings): files > 1.5 MB or average line > 5000 chars become filetype `bigfile` (no treesitter/LSP/ftplugin maps; `:set ft=json` restores them).
- nvim-tree: root follows `:cd`/`:Z` (sync_root_with_cwd true); window picker asks a letter when 2+ editor windows exist (letters visible because vimade is paused); commands load the tree from a fresh start; `<Space>s` toggles.
- `:Obsession!` stops AND deletes the session file; `:Mkdir` has no `!`; `:Move/:Mkdir/:Unlink/...` exist from a fresh start; `:Undotree` only after the first `<Space>u`; `:DiffviewClose`/`:Java*` only after the plugin/jdtls is active; `:LspInfo`/`:LspLog`/`:LspRestart` are custom shims on nvim 0.12 (`:LspInfo` = `:checkhealth vim.lsp`).
- quickfix (quicker.nvim) is NOT editable; `:cfdo ... | update` recipes must not claim "edit the quickfix and :w".
- Treesitter: only highlighting is started (no `indentexpr` from treesitter); the nvim-treesitter-textobjects plugin is not installed; builtin `an`/`in` select nodes.
- Markdown: `i$`/`a$` is unreliable (treesitter replaces vim syntax: on inline maths it picks the display equation) - never say "works"; ltex code actions "Hide false positive"/"Disable rule" and "Add to dictionary" have no effect (server log "Unknown command"); `<Space>rn` in markdown depends on marksman attached; typos_lsp attaches to almost every normal buffer (not special buffers/big files).
- LaTeX: texlab only inside the LaTeX devShell; vimtex only when `latex` is on PATH (not in the lazy dir otherwise, so vimtex key lists cannot be verified from files); tex cmp sources order `omni, nvim_lsp, ultisnips, buffer, path`; `<F9>` and `<Space>rf` are the same `<Plug>(vimtex-compile)` map (do not claim one was tested if the other was).
- Statusline: no filetype/line:col shown; encoding only when not UTF-8, fileformat only when not unix; venv label `name (venv)`/`(conda)` python buffers only; branch click opens the branch picker; LSP name click shows the `:LspAttached` popup.
- UI options: winborder single, pumborder single, scrolloff 5, listchars tab `→`, guicursor blinking 50% bar in insert, colorcolumn per language (POL-19). Check "Line-length marker" row against `colorcolumn_by_ft` in `lua/options.lua`.
- Diagnostics float closes on cursor move and InsertEnter; `<Space>dt` toggles globally and says which.
- `:help` opens as full-height split on the LEFT on screens >= 200 columns (the earlier "RIGHT" text is stale).
- Colour sign glyphs: Nerd Font glyphs, not emoji (diagnostics gutter and statusline).
- `g!` / `g=` (vim-scriptease) which-key overlap is a known accepted warning; do not document it as a bug.

Structure and housekeeping
- Section references that drifted after the split (e.g. "(see section Completion)" with no number; "see 'Manual test'" pointing at a heading that was never written).
- "Duplicate rows": cross-section repeats are intentional quick-reference copies; duplicates INSIDE one table are defects.
- Dangling draft markers (UNSURE, "Claims to verify", "not tested yet" after a test was done).
- A sentence inside a table row contradicting a neighbouring paragraph (the `<F9>` quirk existed in 3 places while the next paragraph said it was fixed): when fixing a fact, grep ALL occurrences (README cheat sheet, Part I, Part II "In Depth" twin, Part III recipes, language guide).

## 4. Rule: every config change updates the guide; "is the guide stale?" checklist

Rule (owner's, standing): every change to keymaps, plugins, options, commands, lazy triggers, devShell tools or behaviour MUST in the same change (a) update the guide (rows, sections, cheat sheet if everyday; remove outdated text FIRST, only then add new), (b) give every touched keymap a short clear `desc` (style "Git: get permalink", "Fuzzy search files", no trailing period; unsure what a key does -> ask, never guess), (c) check clashes: prefix overlaps (timeoutlen 500), same lhs defined twice, buffer-local shadowing of globals (`<Space>ca/fm/rn`, `[t`/`]t`), which-key `checkhealth` overlap warnings, and (d) get verified (dump compare + real keys for behaviour). Reviewers check all four. When asked to run verification, run what applies and say what was skipped.

Staleness checklist (run in this order):

1. Recency: `git -C ~/dotfiles log --format='%h %ad %s' --date=short -- general/general-nvim/.config/nvim/user-guide | head -5` vs the same for `lua/mappings.lua lua/plugin_specs.lua lua/options.lua lua/custom-autocmd.lua lua/config after plugin ftdetect my_snippets lazy-lock.json` (`-- <paths>`). Every config commit newer than the last guide commit is suspect: `git diff <last-guide-commit>..HEAD --stat -- <config paths>` and read each hunk that touches a map, spec, option, command, autocmd.
2. Plugins: compare spec names in `lua/plugin_specs.lua` (and `enabled`/`cond`) with plugin names in the guide: every enabled plugin that has user-visible behaviour is documented; every documented plugin is enabled. `lazy-lock.json` keys vs specs.
3. Keys: full dump (all filetypes, git/non-git, fresh and loaded) vs every key in the guide (both directions). Run the "removed things" grep.
4. Commands: `commands.txt` vs `:Command` mentions; custom commands in `plugin/*.vim`, `lua/` match section 34 and 59.
5. Options/autocmds: `:verbose set` for each option the guide states; `custom-autocmd.lua` vs section 42 rows.
6. LSP/tools/devShells: `lua/config/lsp.lua`, `after/lsp/`, `~/nix` devShell templates and `neovim.nix` vs sections 13, 44, 35, 78-82 (never copy private host names or secrets into the guide).
7. Mechanical integrity: section count/numbering, anchors, table columns, fences, chapter header comment and Back links, README Contents completeness, dashboard `u` target, skill paths, `grep -rc CHECK-USER`.
8. Re-test a sample of "tested" claims, prioritising sections whose code changed since.
9. Report: counts (rows/keys/commands/plugins checked), findings as a table `file:line | quote | class (WRONG/STALE/CHANGED/REMOVED/MISSING/UNSURE) | evidence (file:line or test) | exact replacement text`, plus "verified OK" and "not re-run" lists. Apply corrections to wrong/stale text; for MISSING content ask the owner (new examples need approval; plain key rows for new documented maps do not invent examples and may be added). Do not commit unless asked; the repo is public, never add secrets.
