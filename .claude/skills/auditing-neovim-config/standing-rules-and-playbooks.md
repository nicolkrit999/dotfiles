# Neovim config: standing rules, playbooks, layout, state

Contents: 1 Standing rules (git, public repo, decision guard, keymaps, gating, docs, testing, manual-check format, working method) / 2 Playbooks A-K / 3 Layout and deployment facts / 4 Final state / 5 How to test a change / 6 Other things a stranger needs


Scope: the Neovim config in the dotfiles repo (`~/dotfiles`, config dir `general/general-nvim/.config/nvim`). It started as a manual clone of the upstream `jdhao/nvim-config` (baseline upstream commit `360513d`), was heavily customised, and was then synced with 184 later upstream commits plus local work. That project is FINISHED. The project's working docs (state log, keymaps list, change log, manual-check list, gate scripts, test helper scripts) are DELETED and do not exist any more. Everything below stands alone; the single source of truth is now the code plus the user guide.

Terms: devShell = a `nix develop` shell with the tools for one language. LspAttach = autocmd fired when an LSP client attaches. PR = GitHub pull request. "The user" = the config's owner (detail-oriented, wants plain-language explanations, recommendation first, and explicit statements of what choosing or not choosing an option causes).

---

## 1. Standing rules (each with the reason)

### 1.1 Git and branches
1. NEVER touch branch `main` (in `~/dotfiles` or in `~/nix`): no merge, push, PR base, commit, or checkout-and-commit. Only an explicit instruction in the CURRENT session that names `main` (e.g. "merge develop into main now") allows it, and then only for that action (Playbook G below). "Everything is finished" is never a permission you may judge yourself. WHY: `main` is the released, known-good state; the user's rollback depends on it.
2. Acting freely on `develop` and any other branch (commit, push, branches, PRs) is allowed. Keep using a branch + PR (base `develop`) for changes. Still ask before MERGING a PR unless the user says to merge. Merge with merge commits, not squash (the user's history consists of merge commits).
3. Permission is per action and per session: "fix this typo on develop" allows that one commit; "merge PR 8" allows that merge; it never carries over to the next request or the next session and is never inferred from mood.
4. The two PRE-CHANGE TAGS are the user's rollback points: `v0.9.0-pre-neovim-changes` (dotfiles, = old `main`) and `v7.1.3-pre-neovim-changes` (nix). Never delete or move them. If asked to, restate that they are rollback points and ask ONE confirmation. Creating a new release tag is the user's decision and naming (convention `vX.Y.Z[-description]`; look at existing tags).
5. Commit trailer: end commit messages with the `Co-Authored-By: Claude ...` line your harness reminder specifies; end PR bodies with the `Generated with [Claude Code]` line your harness specifies.
6. Never commit `.claude/settings.local.json` (tracked file: never commit changes to it), `.claude/worktrees/`, scratch/tmp dirs, logs, `.bak`.
7. Never edit `~/nix` yourself and never run `nh os switch` / nixos-rebuild / darwin-rebuild: the user does that. If a nix change is needed, write the exact request lines (what to add, which file, why) and give them to the user. Never touch `~/dotfiles-private` (the user's private Claude-data repo).
8. Every change goes in: branch off `develop` -> commit (one commit per fix) -> push -> PR with base `develop` -> mandatory diff review (Playbook H) -> user's OK -> merge commit.
9. Everything worth keeping must be committed and pushed. Assume a reboot or crash can happen at any moment; `/tmp` is volatile RAM.

### 1.2 Public repo: no secrets
The dotfiles repo is PUBLIC. Never commit API keys, access credentials, private hostnames, emails, personal absolute paths. If a config needs a secret, read it at runtime from an untracked file or sops. Scan every diff you add (grep added lines for keys/credentials/emails/private hosts/`/home/<user>`/stray `.claude`, tmp dirs, logs, `.bak`).

### 1.3 Behaviour changes are the user's decisions (DECISION GUARD)
- Every behaviour, key, plugin setting and option in the code is the RESULT of a recorded user decision. NEVER revert, simplify, "clean up" or change existing behaviour unless the user asks for exactly that.
- If a test result, a review, a warning or your own judgement seems to contradict a decision: do not act. Tell the user what the situation is, give options (recommended first), let them choose. If they answer "I don't understand", re-explain in plain words and re-ask.
- Obvious one-line bugs may be fixed, but tell the user.
- Things that look like bugs but are DECISIONS (do not "fix"):
  - `gcs`/`gcr` smart comment operators: they only add/remove comment characters; markers are language-specific; redundant markers are deleted (gcs never nests, gcr strips every level); no special protection for multi-line strings.
  - Vim sentence objects `is`/`as` are restored; vim-sandwich's query objects live on `iS`/`aS`; operator-pending `s` cancels; there is no visual `x p`.
  - yanky loads at VeryLazy (final decision; the yank-ring storage is yanky's default, check `lua/config/yanky.lua` and the plugin doc before claiming whether history persists across sessions).
  - Panel layout: short single-task panels (help, undotree) on the LEFT; persistent panels (claude-code, aerial outline) on the RIGHT.
  - One-warning fallbacks for gated keys (never fall through to a plain Vim key).
  - vim-oscyank keeps its known bug in its lazy `cmd` list (`OSCYankReg`; the real commands are OSCYank, OSCYankVisual, OSCYankRegister): the user chose to leave it. Remind them ONCE at the end of a session.
  - Third-party (plugin-defined) maps without `desc`; the vim-scriptease `g!`/`g=` overlap warning in `:checkhealth which-key`.
  - Declined ideas (do not do unless asked): a generic helper that adds descs to third-party plugin keys; lazy-loading diffs.nvim, vim-flog, vim-oscyank, vim-scriptease, unicode.vim, vim-highlighturl; language servers for JSON/TOML/Docker/CSS; the idea of an ongoing upstream-sync process (git subtree + review skill), never implemented.
- Known accepted noise (do not "fix"): nvim-dbee `vim.validate` deprecation, auto-save.nvim deprecated API, `^` waiting 500 ms before markdown's `^^` (also a lone `^` or `@` typed in insert mode in markdown, because of the `^^`/`@@` insert maps), a rare fidget.nvim traceback once seen in `:messages` (not reproduced).
- When a new thing replaces an old one (aerial replaced vista, undotree replaced mundo, diffview replaced git-conflict), REMOVE the old one completely; leave no leftovers.

### 1.4 Keymaps
- Every key WE define (vim.keymap.set, lazy `keys`, buffer-local, dashboard keys) needs a short, clear `desc` that tells the user at a glance what it does (style: "Git: get permalink", "Fuzzy search files"; no trailing period). Never guess what a key does: unsure -> ask.
- Never change an existing key without asking.
- Check every new key for conflicts before adding it: prefix waits (a key that is a prefix of a longer one forces a `timeoutlen` wait, 500 ms), shadowing, in n/o/x/i modes.
- The user's keyboard has NO function keys, Insert, Page or numpad keys. Do not bind those. Existing replacements: `<Space>rf` (was `<F9>`) in lua/vim/python/c++/tex; python pdb keys `<Space>dc dn ds df dB du dv`.
- The leader is `<Space>`. Mouse: clickable statusline/bufferline exist (cannot be tested by tmux; NEEDS-HUMAN).

### 1.5 Gating and portability
- Tools, LSP servers and devShell features are enabled only when the binary exists (`executable()`) or on LspAttach. A missing tool gives at most ONE short warning or silence, never falls through to a plain Vim key, and never a blanket notify mute.
- No env-var-based devShell detection.
- A language that relies on a devShell must not produce useless warnings when its files are opened outside the devShell (smart detection, like the Java `has_java` guard).
- The config must degrade gracefully on a host without nix devShells or tools (there is a host that runs plain nvim without this config; others may disable the tmux module). Never assume tmux exists; guard with `executable("tmux")` / `$TMUX`; never make nvim behaviour depend on tmux settings.
- Tool placement (nix): tools nvim needs itself go in `neovim.nix` (even if another module also provides them); language-specific tools go in the matching devShell template; "only in one devShell" is not a reason to remove a tool (ask whether it is useful globally).
- Code new tools as ENABLED, assuming the nix tool is present (rebuild happens right after coding); no conditional toggling for new tools.
- Investigate EVERY warning encountered (checkhealth, startup messages, deprecations, stderr) unless it is a proven false positive. Real ones: root cause + fix proposal; ask if a decision is needed.

### 1.6 Docs: no stale or wrong information
- Every change to the config (code, option, key) must ALSO update the user guide (`user-guide/` folder, see section 3) and run the applicable verification before it is called done. State which verifications ran and which did not apply.
- Guide order of work: remove stale/wrong text FIRST, then add new content. The guide must be as complete as possible. The guide has 0 `CHECK-USER` markers; never add an unresolved marker, never invent examples the user did not approve.
- Remove matching guide text when a key is removed or changed; docs must describe exactly the code change; unrelated rewrites of docs are unexpected hunks.

### 1.7 Testing and certainty
- Automated checks need 101% certainty. If not 100% sure a check passes, retry; after 3 retries without certainty, record it as "unsure" and make it a manual check for the user (tell them exactly how to run it).
- Verdicts: PASS, FAIL, NEEDS-HUMAN (looks, mouse, real devShell tools, clipboard, hardware), BLOCKED (binary missing: say which). When unsure it is NEEDS-HUMAN, never PASS. Show results honestly; never present an unverified claim as verified. Verify what a subagent reports yourself (agents have drifted: one reported work not done, one reported a false "prompt injection", one haiku report was simply wrong; compare counts with a known number).
- NEVER use the user's clipboard in tests (one verifier overwrote it once). Disable the provider or use `:set clipboard=` first.
- Never touch the user's own tmux sessions; use a private tmux server (`tmux -L <name>`) and always `kill-server` at the end.
- Order for manual checks: first the ones only the user can do; automated devShell checks only after. Before automated devShell checks, give the user the exact list of `direnv allow` commands so devShells install while they do manual ones.
- Fake git repos in tests use LOCAL remotes only, with `GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=true` (a fake https remote once caused credential popups on the desktop).
- Test with the live checkout never run against plugin-affecting nvim directly: lazy.nvim rewrites `lazy-lock.json` inside the config dir on any plugin operation. Use an isolated copy (section 5).

### 1.8 Manual-check format (when you hand the user checks)
- Every step is ONLY the exact command or keymap, alone on its own line, with NO trailing period or punctuation (an earlier ":term." made the user unsure whether to type the dot).
- Directly after each step, state what is expected, so a bare "ok" can be matched to it.
- Quickest checks first; at most 8 per batch; then stop and ask whether to continue with the next 8.
- Whenever the user must act (merge a PR, nix rebuild, restart nvim, manual test, approve something), say so in a clearly marked "ACTION FOR YOU" block, and do not block independent work on it. A task that DEPENDS on a manual user action waits.

### 1.9 Working method
- NON-AUTONOMOUS: new problems, choices, behaviour/key/plugin changes are the user's decision. Batch questions (each option says plainly what it changes; recommended first; say what NOT choosing causes). Questions are asked in one batch per wave, then one coding round, then a verify-only round (no new design questions in the verify round: only real breakage is reported, minor details become notes).
- Small non-critical questions (wording, ordering of checks) may be asked freely.
- Agents: choose the model by task (haiku = mechanical/research, sonnet = implementation/standard review, opus = hard judgement), effort medium, at most 4 background agents at once, `nice -n 10` for heavy test runs, one nvim at a time per agent, git worktrees for parallel coding, push after each stage. Maximise parallelism but a task that depends on another waits. Do not start heavy tests while a nix build runs.
- Subagent prompt checklist (agents start with NO context): exact task and acceptance criteria; files/branch it owns and must not touch; rules (never touch main/develop, never edit ~/nix, never commit `.claude/settings.local.json`); the git binary note (use `/run/current-system/sw/bin/git` if plain `git` is blocked by a hook); how to test (isolated nvim, private tmux, scratch dir, cleanup); commit trailer and "push the branch only"; "do NOT revert, simplify or clean up anything outside the task and list every changed file with the reason"; where to write the report; model and effort; "new problems/choices are not decided: report them".
- An agent that says it saw a "prompt injection" in a tool result may be seeing your own SendMessage: resend it as a normal message.
- If an agent cannot run a destructive git command (permission classifier), the user runs it (`! git revert ...`) or you ask; never work around a denied permission.
- Scratch/temp files: only in the harness scratchpad or a scratch dir you delete afterwards.

---

## 2. Playbooks (condensed)

**A. The user reports a bug or a manual-check result (default working mode)**
1. Restate it. 2. Reproduce with real keys in a private tmux using an isolated nvim (section 5) if possible. 3. Tell the user cause + options (recommended first); let them choose. 4. Implement on `git switch -c nvim-sync/<topic> develop` in `~/dotfiles` (the live config follows the checked-out branch: tell the user when you switch, and switch the live checkout back to `develop` once the PR is merged). For read-only inspection or throw-away experiments use a git worktree instead. 5. One commit per fix; update the user guide; run the checks in Playbook H; push the branch; open a PR with base `develop`; tell the user; merge only on their OK.

**B. The user wants a change.** Same as A, but first ask what they want in concrete terms; propose keys only after the conflict check (1.4).

**C. The user answers an open guide question.** Edit the guide line, remove any marker, commit on a branch + PR. Docs-only PRs still go through a branch and Playbook H; a docs PR must not touch code.

**D. A nix change is needed.** Write the request lines, give them to the user (or the nix-scoped session); the user reviews, commits and rebuilds. Follow the tool-placement policy in 1.5.

**E. Reboot/crash recovery.** First `git -C ~/dotfiles branch --show-current`. If it is a task branch left by an interrupted session, tell the user; switch back to `develop` only if that branch is pushed and clean, else ask (the live editor follows the checked-out branch). Then `git status` and `git log -3` in both repos and `git branch -a`.

**F. Docs hygiene.** When the state changes, the guide and any facts stated in it must change in the same commit; no invented timestamps.

**G. The user explicitly asks to merge `develop` into `main` (only then).**
1. Re-verify the exact merge: `git diff --stat origin/main...origin/develop` must be exactly the project's net change (the nvim config tree plus the one skill file; for nix the nvim-related files). Any other file is a blocker. State in one message: which repo(s), source `develop` sha, target `main` sha, method (merge commit), and that the two pre-change tags stay; ask ONE confirmation.
2. dotfiles: open a PR with base `main`, head `develop`; merge with a merge commit (conflict-free because main's tree equals the original develop base).
3. nix: same, but the rebuild is the user's job: tell them.
4. Update local `main` without switching the live checkout: `git -C ~/dotfiles fetch origin main:main` (if it refuses, STOP and tell the user). Never `git switch main` in `~/dotfiles` unless asked (it changes the live editor).
5. Never delete/move the pre-change tags; ask for a new tag name. Do not delete `develop`.

**H. MANDATORY DIFF REVIEW (before opening/updating/merging any PR and before saying "done").** Let B be the branch and BASE `origin/develop`.
1. Scope: `git fetch origin; git diff --stat BASE...B`. Every changed file must be explained by the request or a recorded decision; an unintended file is a blocker.
2. Read EVERY hunk (`git diff BASE...B -- <file>`). Label each INTENDED, SUPPORT (docs/tests describing exactly the change) or UNEXPECTED. Any UNEXPECTED hunk is a blocker: remove it or ask.
3. Revert/drift detection: list every removed line (`git diff BASE...B | grep '^-' | grep -v '^---'`). For anything not obviously part of the change, find who added it (`git log -S'<text>' --oneline BASE -- <file>`, `git blame -L`). If it came from a deliberate decision (list in 1.3) the hunk is a REVERT: blocker, ask. Also grep the diff for re-introduction of things removed on purpose: `x p`, `<Space>o` (old), mason, git-conflict, iron, treesitter-textobjects, viml_conf, old dashboard keys, string protection in smart_comment, fixed hex colours that were made theme-derived.
4. Behaviour snapshots (automated gate; see section 5 for the contents): compare against the gate of the state you branched from. Every difference must be intended; a vanished key, command, autocmd or plugin you did not mean to remove is a blocker. The smart_comment suite must run at least 10000 cases (10073 at the end) with 0 failures; `lazy-lock.json` unchanged unless the task was a plugin update; startup messages, notify history and stderr empty.
5. Docs match code: the guide changes describe exactly the code change.
6. Secret/privacy scan of added lines (repo is public).
7. Independent second review: one fresh read-only reviewer subagent (sonnet or opus, no context) given the diff command, the decision-guard list (1.3) and the instruction "find every hunk that reverts, contradicts or silently changes a recorded decision, or is outside the stated task; report file:line and the decision it contradicts; do not fix". Treat each finding as a blocker until checked yourself.
8. Report to the user BEFORE asking to merge: table (hunk -> why -> request id), snapshot differences, gate verdict, reviewer findings (or "none"), and the explicit statement "no unexplained hunks, no reverted decisions". If you cannot say that honestly, say what is unresolved.

**J. Merging an already-reviewed PR ("merge PR N").**
1. `git fetch origin`; confirm the PR head is still the reviewed sha; if it moved, STOP and redo H on the new diff.
2. Merge via the GitHub tooling with method `merge` and the expected head sha.
3. Update the live checkout: with `~/dotfiles` on `develop` and clean: `git -C ~/dotfiles merge --ff-only origin/develop`.
4. Delete the branch locally and on origin.
5. Verify: `git rev-parse develop origin/develop` equal; remote heads are only `main` and `develop`; no open PRs.
6. Update any docs whose facts changed.

**K. The user mentions a key or command (e.g. `<Space>zz`).** grep the user guide, then the code (`grep -rn '<space>zz' lua after` in the config dir), then ask nvim (`maparg`, section 5; an EMPTY `{}` means no such mapping). If it is not mapped, say exactly that and ask what they meant; never invent a meaning for a key.

(The letter I was never used; there is no Playbook I.)

---

## 3. Layout and deployment facts that matter for an audit

- Repo `~/dotfiles` (public, GitHub). Config dir (also the LIVE config): `general/general-nvim/.config/nvim/`. Repo tree is categorised: `general/` cross-platform, `linux/`, `macOS/`, `various-scripts/`; a config's leaf path mirrors its `$HOME` target.
- Deployment is by nix symlinks, NOT GNU Stow: `~/nix/users/<user>/{nixos,darwin}/services/ext-dotfiles.nix` contains `".config/nvim" = "general/general-nvim/.config/nvim"`. So `~/.config/nvim` is the repo checkout: `git switch` in `~/dotfiles` changes the user's live editor instantly. Never leave `~/dotfiles` on a non-`develop` branch when you finish; never check out the old tag there (browse it via `git show <tag>:<path>` or a worktree). A new config only deploys once a mapping line exists in ext-dotfiles.nix (in both nixos and darwin files for cross-platform configs).
- Check: `readlink -f ~/.config/nvim` must print the repo path.
- Neovim 0.12.5 from nixpkgs-unstable (provided by `~/nix`, file `users/<user>/common/programs/cli-programs/neovim.nix`, which also lists the extra packages and LSP/format tools). Plugin manager lazy.nvim; about 115 plugins, all specs in `lua/plugin_specs.lua`. Theme: Catppuccin Mocha everywhere.
- Config dir contents: `init.lua` (requires globals, options, custom-autocmd, mappings, zoxide, plugin_specs, diagnostic-conf, colorschemes); `lua/` with `plugin_specs.lua`, `mappings.lua` (our global maps), `custom-autocmd.lua`, `options.lua`, `utils.lua`, `zoxide.lua` (`:Z`/`:z`), `colorschemes.lua`, `diagnostic-conf.lua`, `config/*.lua` (per-plugin configs incl. `lsp.lua`, `dashboard-nvim.lua`, `lualine.lua`, `nvim_ufo.lua`, `yanky.lua`), `smart_comment/` (gcs/gcr engine); `after/ftplugin/*` (buffer-local maps/options); `plugin/`; `autoload/`; `ftdetect/`; `spell/` (+README); `my_snippets/`; `tests/smart_comment/` (suite, about 10073 cases); `lazy-lock.json`; `ginit.vim`; `user-guide/` (folder).
- THE USER GUIDE lives at `general/general-nvim/.config/nvim/user-guide/`. There is no `user-guide.md` any more. Entry point `README.md` = intro, Contents table (with GitHub-slug anchors) above the Day-to-Day Cheat Sheet (section 2, plus one appended row table). Chapters `01-basics` ... `10-various`; language guides `languages/{java,python,latex,markdown,typst}.md`. Section numbers (about 82; language sections 78-82) were kept when the old single file was split; sections were copied verbatim by a script and checked by an independent agent. The dashboard key `u` opens `user-guide/README.md`.
- The skill `answering-neovim-usage-questions` (`.claude/skills/answering-neovim-usage-questions/SKILL.md` in the dotfiles repo) answers "how do I do X in Neovim" from that guide, verifies every key against the real keymaps (`lua/mappings.lua` and plugin configs), states when an answer is only an assumption, and keeps the guide correct and complete without adding examples the user did not approve. It points at the `user-guide/` folder.
- Project agents live in the repo under `.claude/agents/` (dotfiles-architect, neovim-configurator, emacs-configurator, shell-config-author, script-author, dotfiles-linter); `dotfiles-linter` does parse checks, deployment-mapping check and secret scan.
- Hosts (nix): a NixOS desktop and laptop, a macOS laptop (darwin), a NAS that runs plain nvim without this config, a minimal template host. Current-day machine for tests was the desktop.
- GitHub work uses the GitHub MCP tools (owner `nicolkrit999`, repo `dotfiles`; `gh` CLI is not installed). If an MCP call fails with `missing Mcp-Param-owner header`, ask the user to run `/mcp` and reconnect `github`. SSH pushes need the user's agent; `GIT_TERMINAL_PROMPT=0` worked for agent pushes.
- A shell hook may rewrite commands (RTK proxy); if plain `git` is blocked, use `/run/current-system/sw/bin/git`.

### 3.1 What the project changed (themes; for orientation when auditing)
- Structure: `viml_conf/*.vim` moved to Lua (`lua/options.lua`, spec `init`).
- Bug fixes: lualine branch counts, colorscheme fallback, ftplugin option leaks (11 filetypes), targets/sandwich conflict, nvim-gdb lazy load.
- Neovim 0.12 compat: removed deprecated plugins/APIs (git-conflict.nvim, legacy lspconfig for Java, dead blink-cmp/iron/treesitter-textobjects configs), `:LspInfo/:LspLog/:LspRestart` replaced, ltex_plus.
- Features: python/uv-aware runner, format-check warnings, `:LspInlayHints`, `:LspAttached`, `:TermHL`, clickable statusline, typos_lsp, texlab, `<Space>sv`, diffview conflict maps, `:help` split, border options.
- Plugins added: aerial, illuminate, treesj, colorful-menu, vimade, diffs/codediff, dashboard (+persistence sessions, `:Z`/`:z` zoxide, dashboard-only keys r L o d m u e q, `\h` open / `\H` close-and-resume). Removed: e-ink, vlime, mundo, grammarous, mason.
- LSP servers enabled by `executable()` (rust_analyzer needs cargo too; gopls; hls; sourcekit; ts_ls; phpactor; r_language_server after a one-time async probe); theme-derived colours; spell cleanup + silent `.add.spl` rebuild; bigfile fixes; 8 lazy-loading changes.
- Later round: per-language `colorcolumn`; `<Space>-` / `<Space>|` splits; `<Space>gB` branch menu; `<Space>Q` asks Yes/No; nvim-tree custom window picker (vimade paused) and `sync_root_with_cwd`; illuminate uses tree-sitter/regex in `.nix` files (nixd highlights a whole `with pkgs` list); Neovide font; resize fix (code windows equal around the 30% Claude panel); vimtex loaded at startup so PDF Ctrl+click inverse search works (it had been lazy `ft=tex`).

---

## 4. Final state (5 lines)
1. dotfiles: only branches `main` and `develop` exist (local and origin). `develop` is the live checkout, clean, at `2280f92` ("nvim(latex): load vimtex at startup ...") or later; `main` = tag `v0.9.0-pre-neovim-changes` = `a04a21b`, untouched. No open PRs. All other branches deleted.
2. nix: `develop` at `6319cbc8` or later (about 23 files, +185/-153 vs tag `v7.1.3-pre-neovim-changes`); `main` untouched at `4e0b0366` = that tag.
3. Merging `develop` into `main` (both repos) has NOT been done: only when the user says so (Playbook G).
4. Verification at the end: all automated devShell checks passed (c-cpp, rust, node, latex, java, db); user-run manual checks passed; the guide has 0 CHECK-USER markers; every key WE define has a desc (about 750 distinct maps, about 440 third-party maps without desc, by decision); no unintended key conflicts; secret scan clean; headless startup about 32 ms.
5. Two soft reminders to give once at the END of a session: the vim-oscyank known bug (left in by choice), and asking whether and when to merge `develop` into `main`.

---

## 5. How to test a change (condensed; the helper scripts no longer exist, rebuild what you need)

Idea: never run a plugin-affecting nvim against the live config dir.
1. Make a scratch dir (in the harness scratchpad), copy the live config dir into it as `$S/cfg`, and run nvim with its own XDG dirs: `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME` all under `$S`, config at `$S/config/nvim` (a copy or symlink of the copy). Restore or ignore `lazy-lock.json` afterwards: it must be unchanged in the repo (`git -C ~/dotfiles status -sb`).
2. Gotcha: a test nvim with an EMPTY data dir downloads nvim-java bundles (about 61 MB) and silently runs half the tree-sitter tests. Seed the scratch data dir from the live one (`site/` parsers, `nvim-java/`) or accept the download.
3. Keys and screen: run it in a PRIVATE tmux server, `tmux -L <name> new-session -d -s t -x 160 -y 45 -c <dir> "nice -n 10 <nvim command> file"`, `sleep 6` (lazy/LSP/VeryLazy start; dashboard and jdtls take longer). Send keys with `tmux -L <name> send-keys -t t ...`: named keys (`Escape`, `Enter`, `Tab`, `Space`, `C-w`, `M-m`, `BSpace`), literal text with `-l --` (the leader is the key name `Space`, not `<Space>` in `-l` mode), Ex commands as `Escape`, `-l ':cmd'`, `Enter`. Read with `capture-pane -t t -p` (`-e` for colour codes, `-S -200` for scrollback). Wait with a loop `until capture-pane | grep -q <text>`.
4. Pitfalls: `Escape` followed at once by a key is read as Alt-key (sleep 0.3 after it); in insert mode the completion menu swallows the first `Escape` (send twice); `timeoutlen` is 500 ms (prefix tests: send `g c s`, sleep 1.2, send `j`); relative numbers are on, so a 2-line file shows `1 alpha` / `1 beta` (normal); mouse via SGR sequences is unreliable: mark NEEDS-HUMAN; never write the system clipboard.
5. Facts instead of pixels: write a value to a file with `:lua vim.fn.writefile({tostring(x)}, '<path>')` and `cat` it. Useful: `:Inspect` (highlight sources), `vim.fn.maparg('<space>fr','n',false,true)` (empty `{}` = unmapped), list maps via `vim.api.nvim_get_keymap('n')` (the leader appears as a literal space in `lhs`), `:LspAttached`, `vim.lsp.get_clients({bufnr=0})`, `require('lazy.core.config').plugins['name']._.loaded`, extmark counts per namespace.
6. Headless alternative for counts/queries (not key timing): `nice -n 10 timeout 120 nvim --headless <file> -c "luafile probe.lua"` where the probe waits via `vim.defer_fn` (about 5 s; forcing all plugins to load takes about 15 s), writes results to a file and `qa!`. A headless run that "finishes instantly" with tiny numbers is wrong (a wrong report once claimed 207 mappings where about 750 exist).
7. Fake git repos (for gitsigns/lualine/fugitive/neogit): `git init`, commit a base with throwaway author env vars, local bare clone as origin only. To reproduce a user's file WITH its uncommitted diff: commit the old version, copy the working-tree version over it.
8. Clean up always: `tmux -L <name> kill-server; rm -rf $S`; confirm `lazy-lock.json` unchanged.

The automated gate (what to re-create for a full verification of a branch) captured, with all plugins force-loaded: empty startup messages, notify history, loadall and stderr; Lua syntax; filetype smoke with LSP; `:checkhealth` (known which-key overlaps allow-listed, everything else must be empty); startup time; lists of keymaps, keymap shadowing, commands, autocmds, plugins, options, filetypes, enabled LSP servers; `lazy-lock.json`; and the smart_comment suite (must run at least 10000 cases, 0 failures). A branch is compared against the previous snapshot with `diff` per file (Playbook H step 4).

---

## 6. Other things a stranger needs to continue safely
- Verify the state in one minute before acting (expected values as of the end): `git -C ~/dotfiles rev-parse origin/main origin/develop v0.9.0-pre-neovim-changes^{commit}` -> main and tag `a04a21b...`, develop `2280f92...` or later; `git -C ~/dotfiles branch --show-current` -> `develop`; `git -C ~/dotfiles ls-remote --heads origin` -> only develop and main; `git -C ~/dotfiles worktree list` -> only the main checkout; `git -C ~/nix rev-parse origin/main v7.1.3-pre-neovim-changes^{commit}` -> both `4e0b0366...`; `grep -rc CHECK-USER <config>/user-guide/ | grep -v ':0'` -> no output. If anything differs, the state changed: check `git log`, tell the user before acting.
- When you may ask vs not. Do NOT ask: whether to touch main/develop (no, unless explicitly instructed this session), whether to test in isolation (yes), whether our keys need descs (yes; third-party no), model/effort/concurrency choices, how to merge (merge commits). ALWAYS do (not a question): the diff review before any PR/merge/"done". ALWAYS ask: any change of behaviour/keys/plugins, any step that would revert a recorded decision, merging into `main`, anything that deletes data, anything touching `~/nix`, a new feature idea.
- Sources of truth when facts conflict: current code and `git log` > the user guide > anything remembered. If the guide and the code disagree, the guide is wrong (fix the guide, not the code) unless the user decides otherwise.
- Git history is the only remaining record of why things are as they are: use `git log -S'<text>'`, `git blame`, and merge commit messages of PRs #1 to #11 (structure, bug fixes, compat, improvements, features, plugins, polish, round 2) to find the origin of a line before judging it a bug.
- The upstream `jdhao/nvim-config` (a plain clone existed read-only) is only a reference; never push to it. Its author discourages using the repo as-is; the user chose to vendor and customise it.
- Test-project folders (per-language devShell sample projects) lived outside the repo under the user's `github-repos/.../nvim-tests/`; they are untracked, direnv-allowed by the user. Do not rely on them existing.
- Declined/optional work is listed in 1.3; nothing is mandatory to do; only the process rules are always mandatory.

- Asking the owner decisions: use checkbox questions (AskUserQuestion), at most 4 per call, the recommended option first, and say what not choosing it results in.
- Project record keeping that existed during development (change log rows, per-change manual-check rows) is not needed any more; the guide, the commit messages and this skill are the record.
