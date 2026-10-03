# Deliberate choices of the owner (do NOT "fix" these)

Contents: 0 Owner environment facts / 1 Keys and mappings / 2 Options and file-type settings / 3 Plugins / 4 LSP and tooling / 5 UI and colours / 6 Nix and devShell side / 7 Git workflow and repo hygiene / 8 smart_comment (gcs/gcr) / 9 Guide and documentation


Format per bullet: WHAT -> DECISION -> WHY -> AUDIT NOTE.
Rule of thumb the owner uses: if a behaviour is wanted AND default, keep it; if unwanted, fix it minimally; never remove or rebind something without asking; "do nothing or show ONE warning, never fall through to another Vim key".

## 0. Owner environment facts that drive choices

- Keyboard -> no usable function keys, no Insert, no PageUp/PageDown, no numpad (Delete exists) -> keys must never REQUIRE those -> do not flag missing F-key / Insert / Page / numpad alternatives; do flag any NEW mapping that needs them. `<S-Insert>` in ginit.vim (GUI only) is only an alias of `<C-r>+`.
- Layout -> US Alt-Intl style keyboard (stated by the owner) -> prefer ASCII-reachable keys (`<Space>-`, `<Space>|`, `<Space>rf`) -> do not flag unusual-looking leader keys as typos.
- OS/terminals -> NixOS (home-manager, flake; main) and macOS; terminal kitty + tmux + fish; Neovide as GUI -> nvim is deployed by nix symlinks, plugins by lazy.nvim, LSP binaries/grammars by nix -> do not flag "not installed" for tools provided per devShell or by nix (see section 6).
- Neovide -> font `JetBrainsMono Nerd Font:h10` in ginit.vim (Hack Nerd Font is not installed; kitty uses JetBrainsMono NF) -> nix not touched for this -> do not flag the font name.
- Language mix -> spell languages en,it,de,fr (see section 1 spell) -> do not flag Italian/German words.
- Theme -> Catppuccin Mocha via base16 (`NVIM_BASE16_THEME`, fallback `base16-catppuccin-mocha`) on nix; on non-nix a random/loaded colourscheme -> see section 5 colours.
- Nvim version in use: 0.12.x. Builtin 0.12 LSP keys (`grn gra grr gri grt gO`) exist beside the custom ones and are only documented, not rebound.

## 1. Keys and mappings

- `<Space>rf` (run file the editor's own way, keeps `<F9>`) -> chosen because no F-keys -> do not flag `<F9>` still existing in ftplugins (lua, vim, python, c++, tex) nor suggest removing it.
- Python debug keys `<Space>dc` continue, `dn` next, `ds` step, `df` finish, `dB` breakpoint, `du` until, `dv` eval; nvim-gdb F-keys (F4 until, F5 continue, F8 breakpoint, F10 next, F11 step, F12 finish) keep working; F9 is no longer nvim-gdb's eval key (belongs to run) -> keep both families.
- unicode.vim `<F4>` digraph -> kept; no replacement needed.
- `<Space>-` = `:split`, `<Space>|` = `:vsplit` (same buffer) -> new keys by the owner's choice -> not duplicates of anything.
- `<Space>gB` = statusline branch menu; `<Space>Q` asks Yes/No (default No) -> intentional safety prompt; do not flag as extra friction.
- `<Space>rr` output window opens on the LEFT (`leftabove vnew`) -> owner's layout rule "left = short single-task panels" (help also opens on the far left: help | code | claude when wide) -> do not move to right/bottom.
- `<Space>rr` for Go / C# runs the project where possible (`go run .`, `dotnet run --project <nearest .csproj>`, else single file); binaries run by their full shell-escaped path; every branch shell-escapes the file name; C/C++ use the same standard (`-std=c++20` in both `<F9>` and `<Space>rr`) -> keep.
- `<Space>sv` (`:restart`) restores windows/files only, NO terminals (a second Claude would start otherwise): `terminal` removed from sessionoptions for the restart -> do not "restore terminals".
- `\D` (delete other buffers) skips modified buffers and running terminals (including the Claude panel) and prints one message; it never force-deletes -> do not flag "does not discard unsaved".
- `\d` on the last listed buffer does `:enew` then delete (no E516) -> intended landing on an empty buffer, not the dashboard.
- The cd-to-file-dir key (mappings.lua, uses `lcd`) desc says "cd to file dir (this window)" -> `lcd` is window-local on purpose.
- `gB` ignores a count by design; desc says "(no count; use {N}gb)". Keep.
- Insert `<C-t>` = toggle the case of the first letter of the word under/before the cursor (Foo <-> foo), also after whitespace to the previous word on the line; non-letter first char no-op. Only toggles when the case change round-trips (so exotic letters like dotless i and long s are left alone; decided alone overnight, reviewable) -> do not flag "dotless i not toggled".
- Insert `<C-u>` (upper-case word): owner approved fixing it to use the same word detection as `<C-t>`; stays in insert mode.
- `x p` (visual-mode keep-register paste) was REMOVED from mappings.lua; visual `p` follows yanky -> do not flag a missing keep-register paste.
- Text objects: `is`/`as` are the builtin sentence objects (restored); vim-sandwich query objects live on `iS`/`aS` (o and x modes, descs "Sandwich: inner/around surrounding (query)"); targets.vim keeps `ib`/`ab`; `vim.g.textobj_sandwich_no_default_key_mappings = 1`. Owner wants both kinds without duplicate keymaps -> do not "restore" sandwich `is/as/ib/ab`.
- The 5 fake text-object stubs `<Space>is/ib/ab/ai/as` were removed; unmapped `<Space>i...` in visual mode may act as `l` + object -> accepted, no function lost.
- vim-swap: only `gs` (`swap_no_default_key_mappings = 1`); builtin `g<` is back; `g>` has no builtin and now does nothing -> accepted.
- Operator-pending `s` = `<Esc>` (so `gcs` then pause then `s` cancels); the o-mode `sa` of sandwich is unmapped to avoid the which-key overlap -> keep.
- `zr` / `zm` / `zR` / `zM` -> per-window-and-buffer fold-level counter via ufo (`zM` level 0, `zr` +1, `zm` -1, `zR` all); counter initialised from the real fold state; without ufo attached (help/nofile/text buffers) `zr`/`zm` fall through to builtin on purpose (documented, no warning) -> do not flag the fall-through.
- Markdown hard line break: `<Space>mb` in n and x ("markdown: hard line break"); `\` is no longer mapped there; `+` and `^^` keep their keys, only got descs; the hard-break helper skips blank lines and lines already ending in `\`.
- Markdown `<Space>mf`/`<Space>mr` footnote maps are buffer-local with a one-warning fallback outside markdown; `<A-m>` and `<Space>dp` have global one-warning fallbacks (otherwise `<A-m>` acts as `<Esc>m`, `<Space>dp` as `l`+`dp`) -> keep those fallbacks.
- `<Space>j*` Java keys are global fallbacks with one warning, descs end in "(needs jdtls)"; which-key shows the Java groups in every buffer -> accepted.
- LSP keys (`K`, `gd`, `<Space>rn`, `<Space>ca`) are mapped per server capability; where a capability is missing: builtin `K`/`gd` stay, rename/code action give ONE warning (suffix " (no attached server supports it)") and never fall through. Descs use "LSP: hover", "LSP: go to definition", "LSP: rename symbol", "LSP: code action".
- `<Space>fm` in Lua runs stylua on the BUFFER via stdin (lua_ls formatting disabled), one warning if stylua missing/fails; `<Space>f` Lua desc is the same text "Format file (stylua)". In markdown `<Space>fm` runs prettier (hunk-wise, cursor restored). Cursor fallback searches the whole new buffer.
- `<Space>dt` toggles diagnostics from `vim.diagnostic.is_enabled()` (no local flag).
- `<Space><Space>` in markdown shows one warning "markdown: trailing spaces are hard line breaks, not stripped" (whitespace.nvim excludes markdown so hard breaks are never painted red or stripped) -> do not flag the no-op.
- Git: `<Space>gl` desc "Git: get permalink"; `<Space>hb` desc "blame line (full)" (blames the line, not the hunk).
- `<Space>ct` (claude-code terminal-mode toggle) disabled: `keymaps.toggle.terminal = false` (typing " ct" in any terminal would toggle Claude); leave a terminal with `<C-\><C-n>`, toggle with `<Space>cc`.
- Picker navigation documented as Ctrl-n/Ctrl-p/arrows everywhere; Ctrl-j/Ctrl-k are NOT Telescope navigation -> not a bug.
- `gcs` / `gcr` (smart_comment) -> see section 8.
- Known accepted which-key overlaps (keep, never "rebind"): `gc` < `gcr/gcs/gcc/gcu`, `<Space>s` < `<Space>sv`, `<Space>q` < `<Space>qw/qb`, buffer-local `<Space>f` < `<Space>ff...`, sandwich `sd/sr` < `sdb/srb`, text-object `i`/`a`/`@`, vim-scriptease `g!`<`g!!` and `g==`<`g=` (on the checkhealth allowlist).
- Overlap noise `<s>` vs `<sa>` removed by unmapping o-mode `sa`; anything else listed above is allowlisted noise, not a regression.

## 2. Options and file-type settings

- colorcolumn: default 100; exact per-language convention -> 80: c cpp sh bash yaml vim haskell r javascript(+react) typescript(+react); 88: python; 100: java rust swift nix typst; 120: lua php tex; go json markdown html toml css keep 100; text none -> do not "normalise" to one value.
- `spellfile` = the four add files (en,it,de,fr; `zg` writes en, `2zg` it ...); `spell/de.utf-8.add` was renamed from the misnamed utf-9. Word lists stay in the (public) repo with a README note "these words are public; review before committing" and a line in the guide; personal/employer words of the upstream list were removed; never move to stdpath. Compiled `.add.spl` stays untracked/gitignored; a silent VimEnter `mkspell!` rebuilds any stale/missing one -> do not track the .spl.
- `updatetime = 100` while Claude is open (claude-code refresh default) -> accepted; do not raise it.
- `sessionoptions`: `terminal` removed for restart (see keys).
- `winborder` is none (Lazy backdrop float gets border none); `<Space>fm` etc. unaffected.
- `max_filename_width = 37` (bufferline/tabs) so the visible width is 40.
- Mixed tab/space rows in one gcs block: markers not aligned -> accepted (Q48 keep).
- `:LogAutocmds` writes to `stdpath("state")/log-autocmds.log` via `writefile()` (not /tmp), echoes the path, and truncates the log every time it is switched on.
- Smartcase: smartcase applies in `/` and `?` searches; `:s`/`:g` always ignore case (set in `vim.schedule` on CmdlineLeave) -> intentional, preview and result match.
- Fold-count text (ufo) is aligned to the window edge when textwidth is 0.
- Dead `has("nvim-0.10")` branches and old comments may remain only where harmless; no version check on startup (owner never adopted upstream's).

## 3. Plugins (what to keep, what is lazy, what was declined)

- Plugin manager lazy.nvim, branch stable; `lazy-lock.json` is gitignored/untracked on purpose.
- Completion stays on nvim-cmp (upstream jdhao moved to blink.cmp; owner did not follow) -> do not flag as outdated. cmp `<CR>` confirms with `select = false` (newline unless an item is picked).
- nvim-treesitter main-branch API; on nix the grammars come from home-manager and are appended to rtp (two nvim-treesitter copies on rtp is known/accepted). `treesitter-textobjects` and blink configs are dead/absent on purpose (owner dropped textobjects).
- vim-oscyank: its known command-list bug (`OSCYankReg`) is deliberately left unfixed; keep the plugin, do not enable/remove.
- Not lazy-loaded on purpose (stay as today): diffs.nvim, vim-flog, vim-oscyank, vim-scriptease (loads on :Scriptnames/:Messages/:Verbose), unicode.vim, vim-highlighturl. Lazy-loading checklist was answered: loaded at VeryLazy -> claude-code.nvim, mini.indentscope, auto-save.nvim, vim-obsession, vim-commentary, yanky; `ft = "java"` -> nvim-java (removed from nvim-lspconfig dependencies); neogit `cmd` only (Neogit, NeogitCommit, NeogitLogCurrent, NeogitResetState); nvim-tree cmd list (NvimTreeToggle/Open/Focus/FindFile/FindFileToggle); vim-eunuch lazy `cmd` list contains ALL its commands including `:W` (`:Move`, `:Mkdir` ...); tabular `cmd = {"Tabularize"}`; vim-matchup and vim-highlighturl `event = {"BufReadPost","BufNewFile"}`; instant.nvim lazy on its `Instant*` commands; colorscheme plugins `lazy = true`; git plugins also load when the opened file is inside a repo (not only cwd).
- yanky loads at VeryLazy (records every yank of the session) -> an earlier "load on first p/P" idea is superseded; do not flag the early load.
- Third-party description (desc) idea for plugin maps and a further lazy-loading audit were DISCARDED (saved as future options) -> do not add descs to third-party keymaps or re-open the lazy audit.
- `auto-save` = okuuva/auto-save.nvim (maintained fork of archived Pocco81), saves only on `BufLeave`/`FocusLost`; the fork still calls deprecated `nvim_buf_get_option` -> accepted until upstream fixes it (no checkhealth line today).
- neuims removed entirely; vim-xkbswitch kept (macOS IME); lualine ime component is guarded on `vim.g.XkbSwitchLib`.
- Removed: hop `zh_sc` pinyin matching; duplicate standalone `nvim-dap` spec (nvim-java pulls dap); firenvim's always-true `enabled`; dead helpers in utils/globals/options/autoload (`get_git_branches`/`_get_branch` included); empty `toml.vim`; redundant cpp/sql commentstring ftplugin lines; commented `vim.print` lines; coc-pyright and extra treesitter withPlugins entries in devShells.
- nvim-dbee stays ENV-source only (`EnvSource:new("DBEE_CONNECTIONS")`): connections added in the drawer are not persisted, no secrets on disk -> do not add FileSource.
- gx.nvim, firenvim, markdown-preview enabled on all platforms; markdown-preview keeps the browser tab open (`mkdp_auto_close = 0`).
- vim-illuminate: allowlist includes c, tex, plaintex, rust, cpp, javascriptreact, typescriptreact (plus the earlier ones); in `.nix` files illuminate uses only providers `treesitter` and `regex` (nixd's documentHighlight highlights every package of a `with pkgs; [...]` list) -> do not re-enable the LSP provider for nix.
- instant.nvim, dbee, dadbod, devdocs, trouble, asyncrun stay as user-only plugins; devdocs keeps only `dir_path`, `float_win`, `wrap`, `mappings.open_in_browser`.
- whitespace.nvim excludes markdown.
- claude-code.nvim: `refresh.show_notifications = false`; one accurate notification from the config based on `v:fcs_reason` (reloaded vs deleted vs conflict); the panel is a vsplit terminal reset to 30% columns after `VimResized`/`wincmd =`.
- bufferline: close button uses `bdelete` (not force); unsaved buffer is kept and one warning "unsaved changes, buffer kept" appears; a running terminal says "running terminal, buffer kept"; clicking the x/dot of an unsaved buffer keeps Vim's "Save changes?" dialog; the Neovim right-click menu stays (its useful entries are documented); `right_mouse_command` not disabled in the final state.
- nvim-tree: `nvim` / `nvim .` shows the start folder, `nvim <dir>` cds into dir and shows it; `sync_root_with_cwd = true` so `:cd`/`:tcd`/`:Z`/`:z` move it; custom window picker keeps visible letters (vimade paused while picking).
- Dashboard (doom theme): hints are part of the desc text (no bogus buffer maps), buffer maps are `<CR>`, `e`, `q` plus dashboard-only letters `r` (restore session this folder), `L` (last session), `o`, `d`, `m`, `u` (opens user-guide README.md); `:z` / zoxide entry exists; restore items give ONE warning when no session ("no saved session for this folder" / "no saved session"); ascii.nvim/dashboard load lazily (only without file args).
- snacks picker only used as `vim.ui.select`; SQLite provided through the nix wrapper.
- Snacks.bigfile defaults `minianimate_disable`/`minihipatterns_disable` stay (harmless); bigfile sets `foldcolumn = "0"` and restores it on `:set ft=`.
- Lualine: slanted separators, nerd icons, filetype+location dropped, diagnostics in lualine_b using the same nerd-font glyphs as the sign column; background `git fetch origin` at most once a minute with `GIT_TERMINAL_PROMPT=0`, `GIT_ASKPASS=true`, `SSH_ASKPASS=true`, `-c credential.interactive=never` (never any popup; prompts for git actions the owner runs himself are fine).

## 4. LSP and tooling

- LSP servers are gated by `executable()`; missing ones are silently absent -> not an error. Servers on nix: bash-language-server, lua-language-server, nixd (formatter nixpkgs-fmt), pyright, python-lsp-server, yaml-language-server, vim-language-server; others come per devShell (gopls, rust_analyzer with DEFAULT cargo-check settings not clippy, hls, sourcekit, ts_ls, ruff, tinymist, marksman, phpactor, r_language_server after a one-time cached `R -e 'library(languageserver)'` probe, jdtls via nvim-java).
- No servers for json/toml/docker/css/html -> owner decided to leave; grammars only.
- No formatter plugin (conform/none-ls) -> formatting is per-language custom (stylua, prettier, lsp); marksman has no formatting (dead setting removed).
- `jdtls` goes through nvim-java; Java runner keys (jrs, jem, jtc/jtm/jtr) are tested by the owner in a real Java devShell -> fix only what he reports.
- typos_lsp attached alone makes `K`/`gd` unavailable: keep builtin `K`/`gd` fallbacks per capability.
- Snacks "SQLite3 not available" and lsp.log noise (dropbar cancel, nixd stderr, lua_ls default root) are accepted noise, not bugs.
- Left alone on purpose (owner "LEAVE"): `:g/x/norm` preview, `:Edit a%b.txt`, gitsigns hunk-preview syntax colours; URL text object without highlighturl stops at `[`/`*` (uses `<cfile>`); MdCodeBlock text object outside a code block is a silent no-op (no message).

## 5. UI and colours

- ALL colours derive from the active theme's highlight groups (cmp, notify bg, hop, lualine parts, YankColor, Cursor, FloatBorder); no fixed hex anywhere. On nix the base16 theme (`NVIM_BASE16_THEME`, fallback catppuccin-mocha) is active, on non-nix the loaded colourscheme. A fully transparent theme: notify shows its own one-time warning and uses black (nothing invented); hop hints with no Search/IncSearch bg stay unstyled -> accepted edge cases.
- Diagnostic signs use nerd-font glyphs of equal width (error 󰅚, warn 󰀪, info 󰋽, hint 󰌶); the old emoji are gone.
- GitSigns inline highlights are `reverse` only (no fg/bg), applied once and re-applied on ColorScheme.
- Statusline/winbar/ufo decisions above stand; guide documents them.

## 6. Nix / devShell side (outside the nvim directory)

- neovim.nix carries global tools: git, curl (even though other modules provide them), `xdg-utils` on Linux only, fzf, wl-clipboard, ripgrep, fd, universal-ctags (so `<Space>ft` btags works), nodejs, stylua, prettier. pandoc is in the LATEX devShell only (not global). Rule: remove what is not needed globally after checking a devShell that needs it, and ask to add it there.
- devShell additions the owner approved: fullstack += typescript-language-server, gopls, ruff; cs-cheat-sheets += tinymist; jupyter += ruff; R devShell += `rPackages.languageserver`; php devShell ships phpactor; devShells for all languages the config enables servers for.
- `~/nix` stray file named `;` has a staged deletion that stays. The unrelated nix commit (gh + claude-code line) goes along with the later develop->main merge. Never touch `~/nix` or dotfiles-private from nvim work.
- nvim automated checks inside devShells only with 101% certainty (3 retries); unsure ones become manual checks.

## 7. Git workflow and repo hygiene

- Branch rule: act freely on `develop` and any other branch, NEVER on `main`; ask before merging a PR; merges use merge commits (not squash), then local+origin helper branches deleted; tag `v0.9.0-pre-neovim-changes` stays. `.claude/worktrees/` is in `.gitignore`; `settings.local.json` untouched (a commit adding `skillOverrides` to it was reverted directly on develop).
- Public repo: no secrets; spell lists are public by decision (see spell).
- lazy-lock.json untracked; `.add.spl` untracked.
- Pending at the end of the project: vim-oscyank bug reminder; develop->main merge needs the owner's confirmation.

## 8. smart_comment (`gcs` / `gcr`) behaviour (owner-confirmed spec; tests/smart_comment suite, ~7295 cases)

- Principle (final, supersedes earlier string-protection decisions): gcs/gcr only add/remove comment characters, single lines and blocks; whether the code still compiles does not matter. Markers are language-specific (per-filetype entries in specs.lua).
- gcs never nests (redundant markers are recognised and deleted, also inside multi-line strings and trailing comments); gcr strips ALL marker levels. So gcr(gcs(x)) may differ from x for rows that were already comments or sit in multi-line strings -> BY SPEC, do not flag as a bug.
- Block comment at the smallest indent; blank rows untouched; hex colours and `#` in single-line strings are not comments; mixed tab/space markers not aligned (keep).
- Unknown filetypes: only the first non-blank marker counts; real entries (strings, "# only after a space") exist for damaged filetypes: kitty, tmux, i3config, conf, gitconfig, cmake, terraform (hcl = terraform rules), elixir. The more targeted per filetype the better; do not collapse to the lazy fallback.
- Edits change only marker bytes (marks, extmarks, `'<` `'>`, `gv` kept); above a budget (rows x trees > 50000, `M.bulk_budget`) the range is written in one go and extmarks refresh later -> accepted speed trade-off.
- Tree-sitter is the main path; the lexer path is the fallback. The lexer fallback still drops `#` in ruby nested strings and make recipe quotes, and multi-row elixir strings whose interpolation holds the closer -> accepted (grammars installed on hosts); only the wrong make spec comment was corrected.
- Operators: `gcs`/`gcr` accept motions (`gcsip`, `gcr200j`, `gcsG`), count form `200gcr` = rows, visual mode, `gcss`/`gcrr` for the current line(s) ("Comment current line(s)" / "Uncomment current line(s)", count = rows), `.` repeats. A count BEFORE gcs is rows (put the count after gcs when using a motion: `gcs3j`). `3gcs` then `G.` (repeat on the last row) does nothing, same as builtin `gcc` -> accepted.
- Normal and visual mode extend to the WHOLE closed fold (count counts visible rows).
- `gcs` then a pause then `s` cancels (o-mode `s` is `<Esc>`); `gcsgcs` is a trap (second `gc` is builtin text object) -> documented, not fixed.
- gcr after pause waits `timeoutlen` for `s`/`r` (same as builtin `gc`/`gcc`).
- Nothing in smart_comment is to be changed without asking (read-only audit only; report problems as questions).

## 9. Guide and documentation

- The guide is the `user-guide/` folder: README.md (contents with GitHub-slug anchors + Day-to-Day Cheat Sheet of 16+ topics, Quick Reference merged into it), 10 chapters, 5 language guides; the dashboard `u` key opens README.md. Every change updates the guide and runs applicable verification.
- Never add examples to the guide that the owner did not approve; the built-in `gr*` LSP keys get a one-line "built-in alternatives" note; `an`/`in` treesitter node selection example in the pair-programming step was approved.
- Every own (non-third-party) keymap that can easily have a desc has one; descs follow the "Area: text" style ("Git: get permalink", "LSP: hover"); which-key desc consistency is checked, key conflicts must be zero except the allowlisted overlaps.
- Manual check lists: exact command alone on its line, no trailing punctuation, expectation after each, batches of 8, quickest first.
- Explanations to the owner: plain language, recommendation first, say clearly what is only an assumption.
- Insert-mode `<Ctrl-t>` (case toggle) deliberately skips letters whose case change does not round-trip (dotless i, long s): not a bug.
