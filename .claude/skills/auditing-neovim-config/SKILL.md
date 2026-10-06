---
name: auditing-neovim-config
description: Audits, reviews and verifies the owner's Neovim config in this dotfiles repo (general/general-nvim/.config/nvim) before a commit, PR or merge of nvim changes. Use when asked to audit, review, verify or check the neovim config, find keymap clashes or conflicts, find keymaps missing a desc, check whether the user guide is stale or wrong, run the regression gate, or decide "is this a bug or deliberate?". Also runs trial mode: when a keymap or command does not do what the user wants (called directly, or by answering-neovim-usage-questions after a failed answer), it tests alternatives alone in a sandbox until one works or 20 attempts fail. Holds the standing rules, the list of deliberate choices that must not be flagged, keymap false-positive catalogs, and a portable isolated test harness.
---

# Auditing the Neovim config

Audit the config in `general/general-nvim/.config/nvim` (deployed as `~/.config/nvim` by a nix symlink, so the checkout IS the live editor). The audit is read-only unless the user asks for fixes. The project is finished; the code plus the `user-guide/` folder are the only sources of truth, and git history records why things are as they are.

## When to use

- "audit / review / verify / check the neovim config", "any keymap clashes?", "which maps have no desc?"
- "is the user guide stale or wrong?", "is this a bug or deliberate?"
- Before a commit, PR or merge that touches the nvim config (the regression gate, mandatory diff review).

- "this key/command does not do what I want, find what works" (a known problem; load this skill directly and run **trial mode**, below).

For "how do I do X in Neovim" questions use `answering-neovim-usage-questions` instead; it calls this skill's trial mode when its steps fail and the user does not know the fix.

## Trial mode (separate from the 5-step audit)

Tests alternative keymaps and commands alone in a sandbox (fake git repo, isolated nvim, private tmux) until one reproduces the goal, up to 20 failed attempts, then hands over to debugging with the user. Run by the `nvim-trial-runner` agent. Entered from `answering-neovim-usage-questions` or directly by the user. Guide fixes that follow a found answer go to the `nvim-guide-maintainer` agent. Full method, stop conditions and report format: `./trial-mode-for-usage-questions.md`. The sandbox rules of the verification doc, section 1, apply.

## The 5-step audit flow

1. **Scope and state.** Run the one-minute state check (`./standing-rules-and-playbooks.md` section 6). Confirm `git branch --show-current` is `develop` or a task branch, never `main`. Work in an isolated copy, never against the live config dir for plugin-affecting runs.
2. **Gate.** Dispatch the `nvim-gate-runner` agent (it runs and classifies the gate below and returns the report), or run `bash scripts/verify.sh <label> [baseline-dir]` yourself (see `./verification-gates-and-isolated-harness.md`). Required: startup messages, notify history, load-all, checkhealth-unexpected, luac and stderr files empty; `smart_comment` suite at least 10000 cases with 0 failures; `lazy-lock.json` unchanged. Diff against the last green gate and classify every diff line.
3. **Keymaps.** Dump all maps (global, buffer-local, lazy) and check clashes, desc, and the no-function-keys rule (`./keymap-clash-audit-and-false-positives.md`). Look every candidate finding up in its false-positive catalog first.
4. **Guide.** Compare guide against code in both directions (plugins: every plugin has a brief entry in `11-plugins.md` plus an in-depth section it links to) and run the staleness checklist (`./user-guide-audit-and-stale-info-patterns.md`). Code wins; wrong guide text is corrected, new examples need the owner's approval. Always run `user-guide/build-pdf.py --check` (README table of contents, links, PDF vs markdown); after any guide fix run `build-pdf.py` first, then `--check` must be OK.
5. **Report.** One row per area with GREEN / ISSUES / RED, findings as `file:line | quote | class | evidence | exact fix`, a "verified OK" list and a "not re-run" list. Separate pre-existing issues from regressions. Split fixes into auto-fix and needs-user-decision. Say which checks ran and which did not apply.

## Standing rules (short form; full text in `./standing-rules-and-playbooks.md`)

Per-change checklist, every config change must have all of these:

1. **Keymap clash check** for every new or changed key: prefix waits (`timeoutlen` 500 ms), shadowing, duplicates, per mode and scope.
2. **A `desc` on every key we define** (style "Git: get permalink", no trailing period). Third-party plugin maps are exempt by decision. Unsure what a key does: ask, never guess.
3. **Guide update** in the `user-guide/` folder in the same change: remove stale or wrong text first, then add. A new, removed or changed plugin means a brief entry in `user-guide/11-plugins.md` AND an in-depth section elsewhere (`.claude/skills/answering-neovim-usage-questions/documenting-plugins-in-the-guide.md`). No invented examples, no unresolved `CHECK-USER` markers. After the last guide edit rebuild the PDF (`user-guide/build-pdf.py`) and confirm `build-pdf.py --check` prints OK; commit the PDF and `.stamp` with the markdown.
4. **No stale or wrong info** anywhere; verify the claim against code or a real run.
5. **Branch rule:** never touch `main` (no merge, push, PR base, commit) unless the user explicitly names it in the current session. Work on `develop` or a branch with a PR whose base is `develop`; ask before merging; merge commits, never squash. Leave `~/dotfiles` on `develop` when done.
6. **Public repo:** no secrets, credentials, emails, private hosts or personal absolute paths in anything committed. Scan added lines.
7. **101% certainty:** an automated check counts only if unambiguous; retry, and after 3 retries without certainty make it a manual check for the user. Verdicts: PASS, FAIL, NEEDS-HUMAN, BLOCKED. Unsure is NEEDS-HUMAN, never PASS.
8. **No clipboard:** never touch the user's real clipboard; set `clipboard=` in tests.
8b. **TMUX SAFETY (hard rule, an agent once killed the owner's tmux and with it the whole Claude session):** the owner works inside a tmux server (`$TMUX`). Never run a bare `tmux` command (no `-L`/`-S`), never `kill-session`/`kill-window`/`kill-pane`/`kill-server`/`pkill tmux`/`killall tmux` except through the helpers of `scripts/tmux-lib.sh` (`tn_stop`/`at_stop`/`_tn_kill`). Before ANY kill: (1) the target is a private server `tmux -L tn-<name>` or `at-<name>` started by you, never a bare session name; (2) its socket is not the one in `$TMUX` (`echo ${TMUX%%,*}`) and not `default`; (3) right after the kill, `tmux -S "${TMUX%%,*}" list-sessions` must still succeed. If it does not: stop all work and tell the user immediately. When briefing an agent, say "private tmux SERVER via `tmux -L tn-<name>`", never "tmux session".
9. **Decision guard:** never revert, simplify or "clean up" existing behaviour; if a result contradicts a decision, report and ask (recommendation first).
10. Never edit `~/nix`, never run a nix rebuild, never touch `~/dotfiles-private`, never commit `.claude/settings.local.json`.

Owner facts that shape the audit: the keyboard has no function keys, Insert, Page or numpad keys, so no new mapping may require them. The "US Alt-Intl dead-key layout" note is the owner's own keyboard fact (recorded from an earlier session note), which is why ASCII-reachable keys such as `<Space>-`, `<Space>|`, `<Space>rf` exist; do not flag them as odd.

## Top false-positive warnings (look up before reporting)

- Buffer-local vs global shadows like `<Space>ca`, `<Space>rn`, `<Space>fm`, `<Space>rf`, `<Space>dp`, `<Space>j*`, `<A-m>` are the deliberate one-warning fallback pattern, not duplicates.
- Accepted prefix overlaps: `<Space>q`/`qb`/`qw`, `<Space>s`/`sv`, `gc`/`gcs`/`gcr`, `sd`/`sdb`, `g!`/`g=`, markdown `^`/`^^` and typed `^`/`@` in insert mode. The which-key warnings in the ignore list are known; only a NEW overlap is a finding.
- `<F9>`, nvim-gdb F-keys and vimtex `<F6>` `<F7>` `<F8>` still existing is by decision (leader twins exist).
- Removed on purpose, so absence is not a finding: `x p`, `<Space>o/O`, `<Space>gy`, `<Space>ct`, mason, git-conflict, treesitter-textobjects, blink.cmp (stays on nvim-cmp).
- `gcs`/`gcr` quirks (never nests, `gcr` strips all levels, no string protection) are the owner-confirmed spec.
- Missing tools outside a devShell (java, latex, typst, clang++ ...) are silent skips or ONE warning by design; LSP servers are gated by `executable()`.
- **Toolchain tests (devShells).** If a check needs a language toolchain, git history or a real project, build a fake repo under `/tmp` (copy of this repo or a small well-known project in that language) and run `nix develop ~/nix/templates/krit/dev-environments/language-specific/<lang>` there, then `nvim --headless` from inside it (no `direnv allow` needed). Test tool availability with `vim.fn.exepath` inside nvim, not `which` (global on nvim's PATH: prettier, pyright, stylua, lua-language-server, nixd, typos-lsp, ltex-ls-plus, marksman; devShell-only: black, ruff, rust-analyzer, gopls, tinymist/typst, texlab/latex). Never write inside `~/dotfiles` for tests. Leave UNVERIFIED only what still fails after several attempts (UI-only, visual look, inconsistent results) and record it in `~/.claude/projects/-home-krit-dotfiles/memory/neovim-guide-unverified-items.md`. Full rule: `skills/auditing-neovim-config/verification-gates-and-isolated-harness.md` section 6.1.
- A plain keymap dump misses runtime-only, gated, lazy and plugin-buffer maps (nvim-gdb, dashboard, diffview, jdtls, vimtex); audit those from source.
- Headless runs finishing instantly with tiny counts are wrong (about 750 maps, 100+ plugins expected); an empty scratch data dir silently halves the tree-sitter tests.
- Git SHAs, counts and "as of" facts in the references were true at the end of the project; re-derive before relying on them.

## Files

- `./standing-rules-and-playbooks.md`: all standing rules with reasons, playbooks A-K (bug report, merge, diff review H), layout and deployment, how to test, state-check commands.
- `./deliberate-choices-do-not-flag.md`: every recorded owner decision (keys, options, plugins, LSP, UI, nix, smart_comment, guide). Read before calling anything a bug.
- `./keymap-clash-audit-and-false-positives.md`: clash vocabulary, dump method, false-positive catalogs, which-key ignore list, desc scan, key-family map for choosing free keys, no-F-keys rules.
- `./verification-gates-and-isolated-harness.md`: gate steps A-F, thresholds, diff meaning, headless and tmux methods, devShell testing, test pitfalls, clean-up.
- `./user-guide-audit-and-stale-info-patterns.md`: guide structure and notation, per-claim-class verification, past wrong-info patterns, staleness checklist.
- `./trial-mode-for-usage-questions.md`: trial mode: sandbox trial loop that searches for a working keymap or command (20-attempt cap), report format, hand-off to the guide update.
- `./known-issues-and-environment.md`: accepted known issues, late-found bug patterns, nix and platform environment, upstream sync outcome, process lessons.
- `scripts/`: portable harness (`verify.sh`, `isolated-nvim.sh`, `tmux-lib.sh`, `capture.lua`, `checks.lua`, `README.txt`). Needs nvim 0.12 or newer, tmux, git. Output goes to `${AUDIT_OUT:-/tmp/nvim-audit}`.
