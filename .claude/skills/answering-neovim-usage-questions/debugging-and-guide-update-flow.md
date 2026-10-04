# After the answer: confirm, debug, update the guide

Used by `SKILL.md` step 6 onward. Three outcomes after "Did this work?":

```
worked ──────────────► stop (nothing else to do)
failed + user names the working key/command ──► Guide update (section 3)
failed + user does not know ──► Autonomous trial loop (1) ──► found? ──► Guide update (3)
                                                      └─ stale after 20 ──► Debug with the user (2)
```

## 1. Autonomous trial loop (starts only after the user says the step failed)

Dispatch the `nvim-trial-runner` agent (its contract is the `auditing-neovim-config` skill, `trial-mode-for-usage-questions.md`, which holds the sandbox rules and harness). Its prompt must be self-contained: the goal as a result, the starting state, the failed steps and what the user saw. It returns FOUND, STALE, CANNOT-REPRODUCE or NEEDS-INPUT with the attempt log; relay it. If the agent is unavailable, run the same method yourself. Summary of the method:

1. Build a sandbox under the scratchpad or `/tmp`: throwaway git repo if the task needs one, `isolated-nvim.sh` for nvim, private `tmux -L <name>` for real keys. Never push, never use the real clipboard or the user's tmux.
2. Reproduce the user's task (same starting text, same cursor position, same mode), then try the original steps once to confirm the failure reproduces. If it does not reproduce, that is the first finding: say so and go to section 2 (the difference is probably the user's environment, keyboard layout first, see `SKILL.md` step 4b).
3. Try alternatives one at a time. Each attempt is a different keymap or command (config mappings first, then plain Neovim), judged by a fact query (buffer text, cursor, mode, `:messages`) AND the screen, never by reasoning alone.
4. Keep a numbered attempt log: attempt number, keys or command, expected result, actual result, verdict PASS, FAIL or NEEDS-HUMAN. A failed attempt is never retried unchanged.
5. **Found** (a PASS that reproduces the user's goal): stop the loop, delete the sandbox, tell the user the exact steps in the answer format of `SKILL.md` step 3, mark it as "confirmed in a sandbox, not yet by you", and ask them to try it. When the user confirms, go to section 3.
6. **Stale**: 20 failed attempts without a PASS. Stop, delete the sandbox, tell the user the loop stopped (attempt count, one line per attempt) and go to section 2. An ambiguous result (cannot tell if it worked, depends on looks, mouse, clipboard, a real devShell) counts as NEEDS-HUMAN, not as a failed attempt and not as a pass; hand those to section 2.

## 2. Debug with the user (after a stale loop, or when the loop cannot reproduce)

Work in small turns:

1. Research (guide, mappings, plugin config, `:help`, default Neovim behaviour) and propose ONE new keymap or command, different from every attempt already failed. Use the numbered answer format of `SKILL.md` step 3.
2. If the earlier failure was clear (error, wrong text, nothing happened) do not propose that key again. If it was ambiguous, propose the user test it manually, with the exact keys and the exact result to look for.
3. Ask what happened and which exact result they got (resulting text, mode, error message, what the screen showed). Use the answer to narrow the cause before proposing the next thing.
4. Repeat until the user says it worked, then go to section 3. Do not drag on: if the user's reports show the thing cannot be done, say so plainly (hard rule 1).

## 3. Guide update (the user said which step worked)

Triggered by: the user confirming a working keymap or command, in the original answer, in the trial loop result, or in the debugging turns. This counts as approval (see hard rule 2); no extra "do you want it added" question.

Dispatch the `nvim-guide-maintainer` agent (sonnet; it already knows this skill's rules and the task list below, and re-reads them from the skill files). Give it a self-contained prompt, because it does not see this conversation:

- The user's goal in one sentence, the exact working keys or command, in which mode, and what the user confirmed.
- What failed before (so the guide can mention the surprise, for example a remapped key).
- Repo root, the guide folder, and the rules of `SKILL.md` ("Rules for adding or fixing guide text") and of the guide (generalized neutral examples, existing format, never renumber, never duplicate).
- The task list below. Tell it not to commit.

Agent task list:

1. **Guide.** Find the right place with the README table of contents and the chapter file names. Record the PREVIOUS text (or "no entry"). Fix wrong text first, then add or extend the entry. Mark "tested" only because the user confirmed.
2. **Keymap desc.** Find the mapping of the working key in the Lua config (`lua/mappings.lua`, `lua/config/*.lua`, `lua/plugin_specs.lua`, `after/`, `plugin/`).
   - It has a `desc`: check it is still true for what the key does and follows the style of the config ("Git: get permalink", no trailing period). If outdated, change it.
   - It has no `desc` and one can be added by editing our own config line: add it.
   - It cannot be added without extra steps (a third-party plugin map, a built-in Neovim key, a default created by a plugin): do not work around it; report it and stop that part.
   - The working path is plain default Neovim with no mapping at all: nothing to check; say so.
3. **Plugin involved** (a new plugin, or the working key/command belongs to a plugin the guide does not cover): also follow `./documenting-plugins-in-the-guide.md` (catalog entry in `11-plugins.md` plus an in-depth section the agent chooses).
4. **Rebuild.** After the last guide edit: `./build-pdf.py` then `./build-pdf.py --check` must print `OK` (see `SKILL.md`, "Rebuild the PDF").
5. **Report back**, structured: per changed file the path and section heading, the previous state, the new state; the `desc` result (already right / changed / added / could not be added and why); page count and `--check` result; for a plugin, the catalog group and the in-depth section.

When the agent finishes, YOU (not the agent) tell the user, verbatim from its report and after reading the diff (`git diff` on the touched files):

- that the guide was changed (or that nothing needed changing),
- the previous state, the new state, and where (file and section),
- the `desc` outcome, including anything left for the user (for example a third-party map that cannot get a `desc`),
- the PDF rebuild and `--check` result.

If the agent's report and the diff disagree, trust the diff and say so.
