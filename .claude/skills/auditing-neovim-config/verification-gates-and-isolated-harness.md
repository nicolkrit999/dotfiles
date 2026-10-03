# Verification method: gates, isolated runs, real-key tests

Contents: 1 Hard rules / 2 What a gate is (steps A-F, thresholds, diffs, report format) / 3 Headless checks / 4 Real keys: private tmux harness / 5 Ask nvim for facts / 6 Testing inside nix devShells / 7 Text objects and operators / 8 Test-writing pitfalls / 9 Clean-up checklist


Self-contained. Scripts live in `scripts/` next to this file (portable copies; see `scripts/README.txt`).
All paths below use two variables:

```
SK=<dir holding scripts/>            # e.g. the skill directory
export AUDIT_OUT=${AUDIT_OUT:-/tmp/nvim-audit}   # all results + scratch dirs go here, nothing else is written
# config dir = $NVIM_CFG, else <git root>/general/general-nvim/.config/nvim
```

## 1. Hard rules (read first)
1. Never run a test nvim on the live config with state-changing tools around. Use `scripts/isolated-nvim.sh <scratch> [nvim args]`: it copies the config into `<scratch>/config/nvim`, gives nvim scratch `XDG_{CONFIG,DATA,STATE,CACHE}_HOME`, seeds `lazy/`, `site/` (tree-sitter grammars) and `nvim-java/` into the scratch data dir with `cp -a` (the real data dir is only read), and sha-checks the real `lazy-lock.json` around the run (restores it and exits 97 if it changed). lazy.nvim writes the lockfile into `stdpath('config')`, so a scratch XDG_DATA_HOME alone does NOT protect it; only a scratch XDG_CONFIG_HOME does.
2. The scratch dir must be under `$AUDIT_OUT/` (the script refuses anything else). Delete it afterwards (`rm -rf`).
3. Never touch the user's real clipboard or tmux, never open GUI windows or browsers, never `git switch`/commit in the live checkout, never run `:Lazy sync/clean/update` outside a scratch XDG. Remotes in test repos: local bare clones only, and always `GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=true` (a fake https/ssh remote makes credential popups appear on the desktop).
4. Verdict vocabulary: PASS, FAIL, NEEDS-HUMAN (looks, mouse, real devShell tools, clipboard, hardware), BLOCKED (a binary is missing: say which). When unsure it is NEEDS-HUMAN, never PASS. Use two kinds of evidence: the screen (what the user sees) AND a fact query (section 5).

## 2. What a "gate" is
A gate is one full automated check of the config at a given commit, saved as a snapshot directory so it can be diffed against an earlier gate. Run it before declaring any change done, and before/after every change batch:

```
bash $SK/scripts/verify.sh <label> [baseline-dir]
# -> $AUDIT_OUT/results/<label>-<short-hash>[-dirty]/   (-dirty = uncommitted changes under the config dir)
bash $SK/scripts/verify.sh diff <dirA> <dirB>            # compare any two snapshots
```
Default runs the live `nvim` (the deployed config, usually a symlink into the repo). `VERIFY_ISOLATED=1` routes every nvim through isolated-nvim.sh instead (slower, no risk to state). `NVIM_CFG` overrides the config dir. Samples for the filetype test come from `INV_SAMPLES` (default `$AUDIT_OUT/samples`, created with tiny a.lua/a.py/a.sh/a.json/a.md/a.nix/a.yaml/a.vim/a.fish/a.tex/a.typ and a java-project); replace them with the user's real filetypes.

### Steps A..F (what verify.sh does)
| Step | Action | Output file(s) |
|---|---|---|
| A | `capture.lua`: functional inventory after a 3 s wait for VeryLazy: plugins (name, enabled, lazy), all global keymaps in n/v/x/s/o/i/c/t, user commands, autocmd group+event+pattern, enabled LSP configs, 24 key options, colorscheme/leader/nvim version | `plugins keymaps commands autocmds lsp_enabled options meta`.txt, `capture_stderr.txt` |
| B | `checks.lua` (runs after VimEnter so which-key etc. are loaded): startup `:messages`; force-load every lazy plugin and keep error/warn lines; filetype smoke over every sample (waits up to 20 s for ALL expected LSP clients, settles 1.5 s before wiping the buffer; records ft, tree-sitter highlighter active, clients, missing clients, error); buffer-local maps that shadow global ones on a lua buffer; `:checkhealth` ERROR/WARNING lines, with a known-noise ignore list splitting out `checkhealth_unexpected`; nvim-notify history (nvim-notify swallows `vim.notify`, so `:messages` alone misses plugin warnings) | `startup_messages loadall filetypes keymap_shadowing checkhealth checkhealth_unexpected notify_history`.txt, `checkhealth_full.txt`, `checks_stderr.txt` |
| C | startup time: median of 5 `nvim --headless --startuptime` runs (ms) | `startuptime.txt` |
| D | the repo's own test suite (`tests/smart_comment/run.lua`, run from the config dir) plus the case-count guard | `tests_smart_comment.txt` |
| E | `loadfile` syntax check of every `**/*.lua` in the config | `luac.txt` |
| F | copy of `lazy-lock.json` plus a lockfile sanity check | `lazy-lock.json`, `lockfile_warning.txt` |

### Thresholds and what must be empty
- `smart_comment` total cases >= `MIN_SC_CASES` (default 10000; the suite had 10073 when set). Below it verify.sh writes `sc_count_FAIL.txt` and exits 3. Cause is almost always missing tree-sitter grammars (scratch data dir without `site/`): the suite still reports "all passed" with about half the cases. Bump the threshold when the suite grows. Also grep `FAIL` in `tests_smart_comment.txt`: the pass line must be "N/N".
- Must be EMPTY (0 lines): `startup_messages`, `loadall`, `notify_history`, `checkhealth_unexpected`, `luac`, `capture_stderr`, `checks_stderr`, `lockfile_warning`. Any line is a finding until it is explained or added to the ignore list in checks.lua with a comment saying why.
- `filetypes.txt`: every row has `missing=` empty and `err=` empty; `ts=true` for languages with a grammar. Outside a devShell the tools of that shell are legitimately absent (java, etc.): the expectation is "cope gracefully", i.e. no popups, no errors.
- Startup time: compare with the previous gate; flag a regression above about 15% or 15 ms. Typical full-featured config: 100 to 140 ms median.
- Lockfile: `LOCKFILE SUSPICIOUS` (fewer than `MIN_LOCK_ENTRIES`, default 100, `"commit"` entries) means something clobbered it: restore it from the last green `results/*/lazy-lock.json`.
- Sanity of numbers: a headless run that ends instantly with tiny counts is wrong. This config has about 750 keymap entries in the full inventory (about 255 global ones in `keymaps.txt`) and 100+ plugins; compare counts with the previous gate.

### Which snapshots are compared and what a diff means
Compare the new gate with (1) the last green gate and (2) the pre-change baseline gate. A diff line is classified, never ignored:
- `plugins`: removed/added plugin or changed enabled/lazy flag. Must map to an approved change. Check `lazy-lock.json` agrees (lock-only entries for plugins disabled outside some devShells are expected; `:Lazy sync` outside that devShell removes them again, harmless).
- `keymaps`: a removed or changed `mode<TAB>lhs<TAB>desc` is lost or altered functionality. A new lhs must not be a prefix of an existing one (adds a `timeoutlen` wait) nor be shadowed. Desc-only changes are fine.
- `commands`, `autocmds`, `lsp_enabled`, `options`: removal means lost behaviour unless approved; `options` diffs change user-visible behaviour.
- `filetypes`: a lost client or `ts=false` is a regression; a new `err=` is a bug.
- `checkhealth`/`checkhealth_unexpected`: new lines are new warnings. Known noise belongs in the ignore list of checks.lua.
- `startuptime`: printed as `a -> b`.
Every removed or changed line must be traced to a commit/approved item; if none, it is drift: report it, do not merge. Review the complete git diff line by line too (reverts, unrelated edits).

### Reading a gate result (report format)
One row per area: A1 lost functionality (diff vs baseline), A2 warnings (steps A/B empty files), A3 keymap conflicts (prefix waits, duplicates, buffer-local shadowing, Select-mode maps from `{"n","v"}` instead of `{"n","x"}`), A4 checkhealth, A5 tools/LSPs (executable status inside nvim, every sample `missing=` empty), A6 other (suite counts, luac, startup). Verdict per row GREEN/ISSUES/RED, then an overall verdict, then a fix plan split into auto-fix and needs-user-decision. After fixes, re-gate and diff against the previous gate: the only differences must be the intended ones.

## 3. Headless checks (no keys, no screen)
```
nice -n 10 $SK/scripts/isolated-nvim.sh $AUDIT_OUT/scratch/h1 --headless FILE -c "luafile $AUDIT_OUT/scratch/h1/probe.lua"
```
`probe.lua` waits (`vim.defer_fn(function() ... vim.fn.writefile(out, file); vim.cmd('qa!') end, 5000)`) and writes results to a file; wrap in `timeout 120`. Force-loading all plugins takes about 15 s. Good for counts, queries, mapping dumps and `Lazy! load all` diffs; NOT for key timing or what is drawn.
- `nvim --headless "+lua error('x')" +qa` exits 0 even with E5108: check stderr for `E5108`/`E185`, not the exit code.
- UI-dependent plugins (snacks `vim.ui.*` overrides) apply on `UIEnter`, which never fires headless: `pcall(vim.cmd, 'doautocmd UIEnter')`.
- Headless runs before VimEnter miss VeryLazy plugins (which-key). Hook `VimEnter` then `vim.schedule` (checks.lua does).
- A wrong queue: waiting only for `>0` LSP clients records just the first (typos_lsp) and races `%bwipeout!` against queued starts (`Invalid buffer id` traces). Wait for every expected client (`vim.lsp.get_configs({enabled=true})` filtered by filetype) then settle.
- Directory/old-config comparisons: `git worktree add $AUDIT_OUT/pre <tag>` and run with `NVIM_CFG=$AUDIT_OUT/pre/general/general-nvim/.config/nvim`; remove with `git worktree remove --force`. Never check an old tag out in the live checkout. To gate a branch without switching the live checkout, use a worktree plus `NVIM_CFG`.

## 4. Real keys: private tmux harness
Use it for key sequences, prefix-wait timing, what is drawn, highlights (`capture-pane -e`), popups.
```
source $SK/scripts/tmux-lib.sh          # isolated-nvim.sh must sit beside it
S=$AUDIT_OUT/t1; mkdir -p $S/files; printf 'alpha\nbeta\n' > $S/files/t.txt
trap tn_stop EXIT
tn_start t1 $S $S/files t.txt           # name (unique!), scratch, workdir, nvim args
tn_wait 'alpha' 20
tn_keys j; tn_keys A; tn_text ' HELLO'; tn_keys Escape
tn_wait 'beta HELLO' 5
tn_lua 'vim.bo.filetype'                 # value via file, no screen scraping
tn_cmd 'set tabstop?'; tn_screen | tail -3
tn_screen -e | head -5                   # colour codes: 38;2;R;G;B fg, 48;2;R;G;B bg
tn_stop; rm -rf $S
```
Functions: `tn_start name scratch [workdir] [nvim args]`, `tn_keys` (tmux key names: Enter Escape Tab Space C-w M-m Up BSpace), `tn_text` (literal, no key-name parsing), `tn_cmd` (Escape, `:text`, Enter), `tn_screen [-e] [-S -200]`, `tn_wait regex [secs]`, `tn_lua expr`, `tn_stop`. Env: `TN_COLS`/`TN_ROWS` (160x45; use 200+ columns for `:help` splits, 24 rows for small windows), `TN_BOOT` (settle seconds, default 6; dashboard/jdtls: more), `TN_KEYWAIT` (0.4). Raw equivalent: `tmux -L NAME new-session -d -s t -x 160 -y 45 -c DIR "nice -n 10 isolated-nvim.sh SCRATCH file"`, `send-keys -t t ...`, `capture-pane -t t -p`.

Notes: relative numbers are on in many configs, so a two-line file shows `1 alpha` / `1 beta` (cursor line shows its absolute number): normal.
- Leader mapping `<Space>ff`: `tn_keys Space f f` (separate keys; `<Space>` is NOT understood by `tn_text`).
- Prefix-wait timing: `tn_keys g c s; sleep 1.2; tn_keys j` (`timeoutlen` often 500 ms).
- Wait for a condition instead of blind sleeps: `tn_wait`.

### Pitfalls of the harness
- Socket names: one UNIQUE name per test (`tn-<name>` / `at-<name>`). Concurrent tests with the same name kill each other's server. Always `tn_stop`/`at_stop`, also after failures (use `trap`).
- A detached tmux session has no attached client, hence NO focus events: FocusLost/FocusGained (autoread, auto-save on FocusLost, relativenumber toggles) never fire. To test them attach a client (e.g. `script -qc "tmux -L NAME attach" /dev/null` in the background), split a pane and switch away, and assert with an autocmd probe writing to a file. The tmux option `focus-events on` must also be set (`:checkhealth` warns otherwise). If you cannot attach: NEEDS-HUMAN.
- `Escape` followed immediately by another key is read as Alt-key: `sleep 0.3` after Escape (tn_cmd does). In insert mode a completion menu swallows the first Escape: send it twice.
- Never yank/paste into the system clipboard: `:set clipboard=` first, or put fake `wl-copy`/`wl-paste`/`xclip` scripts first on PATH. The isolated config still uses the REAL clipboard provider.
- Mouse: SGR sequences via `send-keys -H` (`\e[<0;COL;ROWM` press, `m` release) are unreliable: mark NEEDS-HUMAN.
- Screen scraping is fragile: prefer `tn_lua`/`fact` for values, and keep the trimmed screen lines as evidence.
- `tn_start` with a directory or no file shows the dashboard/file tree. Pass a file to test an ordinary buffer.
- First start in a scratch dir copies plugins/grammars (several seconds, tens of MB); reuse one scratch dir for several consecutive runs when possible, but delete it at the end.
- `isolated-nvim.sh` copies the config at start. Edit the repo, restart nvim to see changes.
- Run everything with `nice -n 10` (the helpers do).

## 5. Ask nvim for facts instead of reading pixels
```
tn_lua 'vim.bo.filetype'
tn_lua 'vim.inspect(vim.fn.maparg("<space>fr","n",false,true))'   # desc, rhs, buffer-local, sid; {} = NO such mapping
tn_lua '#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace("illuminate.highlight"), 0, -1, {})'
tn_lua 'require("lazy.core.config").plugins["name"]._.loaded'
tn_lua 'vim.fn.exepath("java")'                                   # tool visible to nvim?
```
- List mappings with a prefix (leader appears as a literal space in `lhs`): `:lua local t={} for _,m in ipairs(vim.api.nvim_get_keymap('n')) do if m.lhs:find('^ f') then t[#t+1]=m.lhs..' | '..(m.desc or '') end end vim.fn.writefile(t,'FILE')`. Buffer-local: `nvim_buf_get_keymap(0,'n')`.
- Highlight under cursor: `:Inspect` then capture (names tree-sitter group, LSP semantic highlights, extmark groups). What a server answers: `vim.lsp.buf_request_sync(0,'textDocument/documentHighlight', vim.lsp.util.make_position_params(0,'utf-16'), 4000)`.
- LSP: `:LspAttached` or `vim.lsp.get_clients({bufnr=0})`; health: `:checkhealth <name>` then capture.
- Messages: `tn_cmd messages; tn_screen`, or write `vim.split(vim.fn.execute('messages'),'\n')` to a file. Also dump the nvim-notify history when nvim-notify is installed.
- Reproduce a user-reported visual problem: scratch git repo with the committed version plus the working-tree version of the file (so gitsigns shows the same hunks), `/pattern`, `n`, `:Inspect`, then query the source (extmark count, LSP answer), report cause + options, fix on a branch, re-run the same steps.
- A real-looking repo for gitsigns/lualine/fugitive: `git init -q; git add -A; GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t git commit -qm base` inside the scratch dir.

## 6. Testing inside nix devShells (language toolchains)
Some behaviour only exists inside a devShell (java, rust, latex, typst...). `at_start` starts nvim inside `direnv exec <shell-dir>`:
```
source $SK/scripts/tmux-lib.sh
export AT_FAKEBIN=$AUDIT_OUT/fakebin    # optional dir of fake wl-copy, wl-paste, browser launchers, ...
at_start j1 /path/with/.envrc /path/to/project Main.java     # name shelldir cwd [nvim args]; AT_BOOT (default 10 s)
k Escape; sleep .3; k Space r r; sleep 15; scr                 # keys / screen
cmd 'lua print(vim.fn.executable("javac"))' ; fact 'vim.fn.executable("javac")'
at_stop
```
- `direnv exec DIR sh -c CMD` runs CMD with the devShell environment and RESETS PATH. A fake-binary dir must therefore be prefixed INSIDE the inner command, after direnv (at_start does: `PATH=$AT_FAKEBIN:$PATH exec nice isolated-nvim.sh ...`). Prefixing PATH before `direnv exec` is lost.
- The shell dir must already be allowed (`direnv allow` was done by the user); do not run `direnv allow` yourself without asking. If `direnv exec` prints "blocked", report BLOCKED.
- Pass a file argument. `at_start` with no args opens the dashboard, which hides the buffer under test.
- Run-key tests (`<leader>rr`-style): use cwd outside the project and an absolute path, assert the output on screen, that the binary landed next to the source (not in cwd or /tmp), and `#nvim_tabpage_list_wins(0)`.
- Tools outside the devShell must be absent inside nvim (`executable == 0`) and produce no popups/errors: check both inside and outside.
- Clean up: `at_stop` removes `$AT/s-<name>`; also delete any compiled artifacts created in project dirs.

## 7. Testing text objects and operators properly
- Text objects only exist in operator-pending and visual modes. `ia`/`aa`/`i(`... pressed in normal mode are NOT commands; test them as `dia`, `cia`, `yia`, `vi(`, `via`, and `.`-repeat. Assert the buffer text afterwards (`tn_lua 'table.concat(vim.api.nvim_buf_get_lines(0,0,-1,false),"|")'`) rather than eyeballing.
- Test each operator x object x position (cursor inside, on the delimiter, at the start/end, on an empty line), count prefixes (`d2ia`), and visual mode (`v` + object, `x` mode maps).
- Operators from plugins (sandwich `sa`/`sd`/`sr`, comment `gc`, custom `gcs`): test with a motion (`gcj`), a text object (`gcip`), visual, and the doubled linewise form. Typing the sequence quickly vs with a pause (`timeoutlen`) behaves differently when one lhs is a prefix of another.
- Surround/targets plugins override builtin objects (`i(`, `a,`, `in`, `il`): test both the plugin behaviour and that the builtin cases still work.
- Mode matters: a `{"n","v"}` map also covers Select mode, so typing a space into a snippet placeholder triggers it; use `{"n","x"}`.
- Use real keys for anything with `<expr>`, `<Cmd>`, abbreviations, timing or visual selections; headless `feedkeys` is fine for pure text transforms only when `'x'` flag (execute) is used and `timeoutlen` waits are not under test.

## 8. Test-writing pitfalls (checklist)
1. Test the right thing: query the mapping (`maparg`) AND exercise it; an empty `maparg` result `{}` means it does not exist, a lazy stub exists before the plugin loads.
2. Lazy loading: a command that does not exist before first use (`exists(':X')==0`) may still have a lazy stub (`exists==2`). Check both before and after `Lazy! load`.
3. Global vs buffer-local: `set` in an ftplugin leaks to the global value; verify by opening the ftplugin file then an unrelated buffer and comparing options (`vim.o` vs `vim.bo`).
4. Read the cursor line number correctly with relative numbers on; use `:set nornu` or facts.
5. Only count ERROR/WARNING lines after a settle time; async plugins (LSP, mason-less installers, noice) print late.
6. Do not trust an exit code (`nvim` exits 0 on config errors); read stderr and `:messages`.
7. A headless run finishing instantly with tiny numbers is a broken test.
8. Never let a test write outside `$AUDIT_OUT`; check `git -C <repo> status -sb` afterwards: no change to `lazy-lock.json`, no stray files.
9. Same-name tmux sockets or scratch dirs collide between parallel tests: unique names, unique scratch dirs.
10. `sleep` is a smell: prefer `tn_wait` on a screen regex or a fact file with a bounded retry.
11. Sample sets must contain the real filetypes of the user (a missing sample means a missing check).
12. Time-based keys (`<Space>` prefixes, `gc` families) must be tested both fast and slow.
13. When a result contradicts a document (keymap guide, README), the code wins: fix the document or flag the code, never silently accept the document.
14. Pre-existing issues found during a gate are reported separately from regressions; do not fix them unasked.
15. Clipboard, mouse, focus, real browsers and hardware: NEEDS-HUMAN unless emulated as described above.
16. Report honestly: failing check = FAIL with the observed output; skipped step = say it was skipped.

## 9. Clean-up checklist (always, also after failures)
`tn_stop`/`at_stop`; `tmux -L <name> kill-server` for stragglers (`tmux -L name ls`); `rm -rf $AUDIT_OUT/scratch/* $AUDIT_OUT/t*`; `git worktree remove --force` for any worktree; `git -C <repo> status -sb` shows only intended changes and the lockfile is untouched; keep `$AUDIT_OUT/results/*` only if the user wants the snapshots.
