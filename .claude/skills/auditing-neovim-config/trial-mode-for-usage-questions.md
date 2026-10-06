# Trial mode: find a working keymap or command by testing alone

A mode of this skill, separate from the 5-step audit. It answers "this keymap/command did not do what I want, what does?" by trying alternatives in a sandbox. Two entry points, same loop:

- **Called by `answering-neovim-usage-questions`** after the user said its steps failed and did not know the fix. It passes the goal, the failed steps and what the user saw.
- **Called directly by the user** who already knows the problem ("X does nothing when I press it", "I want to do Y and cannot"). Load this skill normally, skip the audit flow, ask only for what is missing to reproduce (goal, exact keys tried, mode, filetype, what happened), then run the loop. Do not ask more than needed.

## Who runs the loop

Dispatch the `nvim-trial-runner` agent with a self-contained brief (it does not see the chat) containing the three inputs below; it follows this file and returns the report. The loop is long and noisy, which is why it runs in an agent. If the agent is unavailable, run the loop yourself. When called directly by the user, collect the inputs first, then dispatch.

## Inputs to pin down before the first attempt

1. **Goal** in one sentence, as a result (final text, cursor, mode, opened window).
2. **Starting state**: file content, filetype, cursor position, mode. Generalize from the user's text; a few lines of neutral text are enough.
3. **Failed attempt(s)**: exact keys or command, and the observed outcome.

## Sandbox (rules of `./verification-gates-and-isolated-harness.md`, section 1, apply in full)

- Scratch dir under `$AUDIT_OUT` (default `/tmp/nvim-audit`) or the session scratchpad. If the task involves git (fugitive, gitsigns, diffview, conflicts, blame), create a FRESH throwaway repo there: `git init`, fake commits, branches, a local bare clone as "remote". You may create, edit, stage, commit, branch, stash and reset freely inside it. Never push or fetch to a real or fake remote, never use `gh` or the user's credentials, never run state-changing git in the dotfiles checkout.
- nvim through `scripts/isolated-nvim.sh <scratch> [args]` (scratch XDG dirs, lockfile sha-guard). Real keys through the private tmux harness (`scripts/tmux-lib.sh`, `tmux -L <name>`, stop with `tn_stop`/`at_stop` at the end, TMUX SAFETY rule in SKILL.md 8b applies: never a bare tmux command, never kill anything but your own `tn-*`/`at-*` server, verify the owner's tmux survives), `clipboard=` set. Prefer headless `nvim --headless` with `feedkeys` plus a fact query when no screen is needed (section 5 there). A language toolchain may need its devShell (section 6 there).
- Evidence for every attempt: a fact query (buffer text, cursor, mode, `:messages`, `v:errmsg`) AND the screen when the result is visual. Verdicts: PASS, FAIL, NEEDS-HUMAN, BLOCKED. Unsure is NEEDS-HUMAN, never PASS.

## The loop

1. **Reproduce first.** Run the user's failed attempt. Same failure: continue. Different result: that is a finding (environment difference; keyboard layout and dead keys first, since the sandbox sends keys the user's keyboard may never produce); stop the loop and report it.
2. **Generate candidates, cheapest first:** the same goal through the guide and the mappings (`lua/mappings.lua`, `lua/config/*.lua`, plugin specs, which-key listing of the prefix, `:map <lhs>`, `:verbose map <lhs>`), then user commands (`:command`), then standard Neovim (`:help` search, `:Telescope keymaps`-style listing, built-in motions and Ex commands), then combinations of several steps.
3. **Try one candidate per attempt.** Number it. Log: number, keys or command, expected, actual, verdict. Never repeat an attempt unchanged; a variation must differ in keys, mode, count or order.
4. **Stop conditions:**
   - **Found:** a PASS that reproduces the goal from the same starting state. Stop, clean up, report.
   - **Stale:** **20 failed attempts** without a PASS. Stop, clean up, report the log.
   - **NEEDS-HUMAN or BLOCKED:** the result cannot be judged automatically (looks, mouse, real clipboard, missing binary). It does not count as a failure or a pass: stop that branch, list it for the user.
5. **Clean up always** (checklist in section 9 there): `rm -rf` the scratch dir, `tn_stop`/`at_stop` (guarded kill; confirm the owner's tmux still lists sessions), confirm the lockfile and dotfiles git status are unchanged.

## Report (to the answering skill's conversation or to the user)

- Outcome: FOUND, STALE or CANNOT-REPRODUCE.
- Found: the exact steps as a numbered list, each with the keys or command in a code span and a separate description, the mode, the evidence, and "confirmed in a sandbox, not yet by you".
- Stale or ambiguous: the numbered attempt log (one line each), what the failures have in common, the candidates not tried yet, and what only the user can check.

## What happens next

- **Found:** the user tries it. If it works, the guide update runs: `../answering-neovim-usage-questions/debugging-and-guide-update-flow.md`, section 3 (sonnet agent fixes the guide, rebuilds the PDF, checks the `desc` of the key, then the main session reports previous state, new state and location). That flow applies the same whether the loop was started by the answering skill or called directly.
- **Stale or ambiguous:** continue together with the user, one proposal per turn, as in section 2 of that same file; the user's reports drive the next proposal, and a working result ends in the same guide update.
- This mode is read-only for the dotfiles checkout apart from that guide update; it never changes the config to make an attempt pass.

**Toolchain tests (devShells).** If a check needs a language toolchain, git history or a real project, build a fake repo under `/tmp` (copy of this repo or a small well-known project in that language) and run `nix develop ~/nix/templates/krit/dev-environments/language-specific/<lang>` there, then `nvim --headless` from inside it (no `direnv allow` needed). Test tool availability with `vim.fn.exepath` inside nvim, not `which` (global on nvim's PATH: prettier, pyright, stylua, lua-language-server, nixd, typos-lsp, ltex-ls-plus, marksman; devShell-only: black, ruff, rust-analyzer, gopls, tinymist/typst, texlab/latex). Never write inside `~/dotfiles` for tests. Leave UNVERIFIED only what still fails after several attempts (UI-only, visual look, inconsistent results) and record it in `~/.claude/projects/-home-krit-dotfiles/memory/neovim-guide-unverified-items.md`. Full rule: `skills/auditing-neovim-config/verification-gates-and-isolated-harness.md` section 6.1.
