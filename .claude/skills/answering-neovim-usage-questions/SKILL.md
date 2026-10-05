---
name: answering-neovim-usage-questions
description: Use this skill whenever the user asks how to do something in Neovim or Vim with their own config ("how do I select...", "how do I go to...", "how do I delete/copy/change...", "what key does...", "is it possible to...", "why did this key do that"). It looks in the user's neovim-guide (the user-guide/ folder) first, then in the real keymaps, then proposes standard Neovim; answers as numbered steps that separate the exact keys or command from what each step does; asks whether it worked; and if not, debugs (a sandbox trial loop first, then together with the user) and finally fixes the guide, its PDF and the keymap desc.
---

# Answering Neovim usage questions

Paths are relative to the dotfiles repo root (`/home/krit/dotfiles`):

- Guide: the folder `general/general-nvim/.config/nvim/user-guide/` (see "How to use the guide"). The markdown is the source of truth; `user-guide/neovim-user-guide.pdf` (what `<Space>?` and the dashboard item open) and the README table of contents are GENERATED from it by `user-guide/build-pdf.py` (see "Rebuild the PDF").
- Keymaps: `general/general-nvim/.config/nvim/lua/mappings.lua`
- Plugin keymaps and settings: `.../nvim/lua/config/*.lua`, `.../nvim/lua/plugin_specs.lua`
- Options and other mappings: `.../nvim/lua/options.lua`, `.../nvim/plugin/`, `.../nvim/after/`, `.../nvim/lua/custom-autocmd.lua`

## How to use the guide

The guide is large; never read it whole. It is divided on purpose, and chapter names and numbers change over time, so never rely on remembered ones. Discover them each time:

1. `ls user-guide/ user-guide/languages/`. The files are labeled: numbered chapter files whose names state the topic, and a `languages/` folder with one file per language or toolchain. `README.md` is the index.
2. Read the top of `README.md`: it holds a generated table of contents (chapters, then their sections, as links `file.md#anchor`) and a short day-to-day cheat sheet.
3. Map the question to a category from two signals: the table-of-contents entries and the chapter file names. Pick the one or two best chapters (a language-specific question goes to its `languages/` file first).
4. Read only that chapter's relevant section (`grep -n` the heading or keyword inside the file, then read around it). If the chapter has nothing, try the next best category, then `grep -rn "<keyword>" user-guide/` as a last net.
5. Chapters link to each other with "see section N" and `file.md#anchor`; follow those links instead of guessing.

## Where to look, in this order

1. **The user guide first.** If it answers, that is the answer (after the verification below).
2. **If the guide is silent or incomplete, the real mappings and plugin configs** (`lua/mappings.lua`, `lua/config/`, `lua/plugin_specs.lua`, `after/`).
3. **If still nothing, standard Neovim.** Say plainly that it is not in the guide or the config, propose the default Neovim way (`:help` is the authority; check `:help` rather than recall), and label it **"Not in your config or guide: this is default Neovim behaviour and an assumption until you try it."**

## Hard rules

1. **Never invent a solution.** If the thing cannot be done the way the user asked, say so plainly. If it needs several steps, list the steps and say it needs several steps. Do not present a workaround as if it were one command.
2. **Adding to the guide needs the user's confirmation that it worked.** The user reporting the working keymap or command is the approval, and then the update in `./debugging-and-guide-update-flow.md` section 3 runs automatically. Without that report, add nothing and do not write "tested" or "verified" from reasoning alone.
3. **If unsure, say so clearly** (see "Uncertain answers").
4. **Be skeptical of both sources, every time** (next section).

## Be skeptical: nothing is trusted by default

The guide may be stale, and the mappings may have changed since it was written or since you last read them.

- **Source of truth order.** The mappings are the authority on what a key is bound to; the guide only describes them and is the one that can be wrong. When they disagree, the mapping wins and the guide gets corrected.
- **Mappings can still mislead:** the same key bound twice (the later definition wins; grep every definition), an override in a plugin config, `after/ftplugin` file or buffer-local mapping, and a running Neovim that has not reloaded the file. A mapping says nothing about what a built-in motion does: label that part as an assumption until confirmed.
- **Read fresh on every question.** Re-read the relevant guide section and mapping lines each time; never answer from memory or from an earlier answer.
- **Check recency when it matters:** `git log -3 --format='%h %ad %s' --date=short -- <file>` and `git status --short` on `user-guide/`, `lua/mappings.lua` and the plugin config. A mapping changed after the guide text makes the guide suspect.
- **Cross-check the two sources.** A guide entry with no matching mapping, or a mapping the guide describes differently, is a discrepancy. Report it with `file:line`, say which one you trust and why, and offer to correct the guide.
- **Matching sources are still not proof** of behaviour (which mode, what a selection includes, what a plugin does). Not seen confirmed by the user means assumption.

## Workflow for every "how do I ..." question

### 1. Look in the guide
Use "How to use the guide". Note whether it answers fully, partly, or is silent.

### 2. Verify against the real config
Never trust the guide alone, and never answer from generic Vim knowledge alone. For every key in the answer:

- Is the key remapped? Read `lua/mappings.lua`, grep `lua/config/` and `lua/plugin_specs.lua`. Known traps: `f` is hop.nvim (2 characters plus a label), `;` is `:`, `$` is `g_` in visual mode only, `H`/`L` are remapped, `0` is `g0`, `c`/`C`/`cc` use the black-hole register, `s` is disabled (vim-sandwich), `j`/`k` follow wrapped lines only without a count.
- **Which modes does the mapping cover?** A mapping for `{ "n", "x" }` does NOT apply after an operator (`d`, `y`, `c`).
- Is the plugin enabled, or commented out in `plugin_specs.lua`?
- Options that change behaviour (`nowrap`, `ignorecase smartcase`, `relativenumber`): check `lua/options.lua`.
- A quick sandbox test is allowed (scratch copy under `/tmp` or the scratchpad, `isolated-nvim.sh`, private `tmux -L`; never push, never credentials; see the auditing skill's verification doc, section 1 rule 4).
- **Toolchain tests (devShells).** If a check needs a language toolchain, git history or a real project, build a fake repo under `/tmp` (copy of this repo or a small well-known project in that language) and run `nix develop ~/nix/templates/krit/dev-environments/language-specific/<lang>` there, then `nvim --headless` from inside it (no `direnv allow` needed). Test tool availability with `vim.fn.exepath` inside nvim, not `which` (global on nvim's PATH: prettier, pyright, stylua, lua-language-server, nixd, typos-lsp, ltex-ls-plus, marksman; devShell-only: black, ruff, rust-analyzer, gopls, tinymist/typst, texlab/latex). Never write inside `~/dotfiles` for tests. Leave UNVERIFIED only what still fails after several attempts (UI-only, visual look, inconsistent results) and record it in `~/.claude/projects/-home-krit-dotfiles/memory/neovim-guide-unverified-items.md`. Full rule: `skills/auditing-neovim-config/verification-gates-and-isolated-harness.md` section 6.1.

If a check is not possible, say which part could not be verified.

### 3. Answer: numbered steps, keys clearly separated from descriptions

The user must see exactly which keys to press, in which order, and which command to run with the exact syntax. Format every answer like this:

- A **numbered list, one action per step**. Each step has two visibly different parts: the **action** in a code span (keys or command), then the **description** after it, in plain text.
- **Keys**: write each key literally in a code span, Neovim notation, keys of one sequence together, separate presses apart: `` `<Space>` `` then `` `ff` ``. Say the mode when it matters (Normal, Visual, Insert, Command-line). Say whether to press keys together or one after another, and note `<Space>` is the leader.
- **Commands**: the full Ex command with `:` and exact syntax, placeholders in angle brackets that name what to fill in (`` `:%s/<pattern>/<replacement>/g` ``), and `<CR>` as the last step if needed. Never write a command without its arguments when it needs them.
- A step that is only a result or check ("the cursor is now on the first match") is labeled as such, not written as an action.

Example shape (generic, not a real answer):

```
1. `<Space>ff`  Opens the file finder.
2. `<text>`  Type part of the file name to filter the list.
3. `<CR>`  Opens the selected file.
```

Then, briefly: the result to expect, and gotchas that would surprise the user (a remapped key, `v2t` versus `2vt`, selections include the character under the cursor). If the request cannot be done as asked, say that first, then the multi-step alternative. Keep it short; a table only when comparing keys. State where the answer came from (guide, mappings, or default Neovim assumption).

### 4. Uncertain answers
When any part is not confirmed by both the guide and the config:

- Say explicitly: **"This is an assumption, I have not been able to confirm it."** and name the unconfirmed part.
- Give the exact keys to try and the result you expect, then ask the user to report exactly what happened.
- No "probably" inside an otherwise confident answer: it is confirmed or it is labelled.

### 4b. Unexpected behaviour: ask about the keyboard layout, do not assume
If a key sequence does nothing, needs an extra key, or types a strange or accented character, and config and guide do not explain it, **ask which keyboard layout or input method is used on this machine** before concluding anything. Dead keys (`"`, `'`, `` ` ``, `~`, `^` need a following `<Space>`) or an IME can swallow keys before Neovim sees them.

- The usual layout is US International (with dead keys) but the user works from different PCs: never assume, always ask. Do not blame the config before the answer. The guide has a section on dead-key keyboard layouts (find it through the table of contents).
- Quick test: type the key then a letter in Insert mode and see whether an accented letter appears.
- Only write confirmed layout facts into the guide.

### 5. Always end by asking whether it worked
Last line of every answer that gave steps, plain and short, for example: **"Did these steps work?"** Then act on the reply, following `./debugging-and-guide-update-flow.md`:

- **Yes:** confirm and stop. If the guide already covers it, nothing else happens; you may note it as confirmed. If the guide lacked it and the user confirmed the steps, the guide update of section 3 of that file still applies (the confirmation is the approval).
- **No, and the user says what worked** (the right key or command): go straight to the guide update in that file (section 3: dispatch the `nvim-guide-maintainer` agent to fix the guide, rebuild the PDF and check the keymap desc; then you report previous state, new state and location). Also correct your own earlier answer in the conversation.
- **No, and the user does not know what works:** start debugging. First the autonomous sandbox trial loop (section 1 there: the `nvim-trial-runner` agent, `auditing-neovim-config` trial mode, up to 20 failed attempts). If it finds a working way, offer it to the user to confirm. If it ends stale or ambiguous, continue together with the user (section 2 there) until the user says something worked, then the guide update.
- If the result contradicts the guide text, correct the wrong text as part of that update and say what was wrong.

## Rules for fixing or adding guide text

(`nvim-guide-maintainer` follows these.)

- Generalize: no variable names, file names or snippets from the user's current code. Neutral placeholders (`foo`, `X`, `<char>`).
- Put it in the matching chapter and section, found with the table of contents and file names. Extend an existing subsection before creating a new one. Do not renumber sections; update any quick-lookup table the entry belongs in.
- Match the format: Markdown tables for key / effect, short bullets for caveats, backticked keys. Include what surprised the user: remaps, modes, counts, what a selection includes.
- State status honestly: "tested" only because the user confirmed the exact keys.
- Never duplicate: edit a nearly identical entry instead. Fix wrong text before adding new.
- Plugins: a new, removed or changed plugin is documented in TWO places, a brief entry in `user-guide/11-plugins.md` and an in-depth section in a chapter the agent chooses. Full procedure: `./documenting-plugins-in-the-guide.md`.
- Touch only the files in `user-guide/` for the guide part (the keymap `desc` check may touch the Lua config line of the key). Do not commit unless the user asks. The repo is public: no secrets or private paths.

## Rebuild the PDF (mandatory whenever a guide file changed)

After the LAST edit of any `user-guide/**/*.md` file in a task:

1. `cd general/general-nvim/.config/nvim/user-guide && ./build-pdf.py` (regenerates the README table of contents and `neovim-user-guide.pdf` + `.stamp`; falls back to `nix shell nixpkgs#pandoc nixpkgs#typst` when pandoc or typst is missing).
2. `./build-pdf.py --check` must print `OK` (table of contents current, every `.md` link and `#anchor` resolves, PDF built from current sources, every heading in the PDF text). Any `FAIL`: fix the markdown and rebuild; never edit the PDF or stamp by hand.
3. Report the page count and the `--check` result. Stage the PDF and stamp together with the markdown.

New chapter file: add it to `FILES` in `build-pdf.py`, start it with `<!-- chapter: Title -->`. New heading: the table of contents picks it up.

## Quick checklist before sending an answer

- [ ] Found the right chapter through the table of contents and file names; re-read fresh
- [ ] Guide first, then mappings, then default Neovim (labelled as assumption)
- [ ] Every key checked in the config (remaps and modes)
- [ ] Guide and mappings compared; discrepancies reported with `file:line`
- [ ] Numbered steps: keys or command in code spans, description separate, exact syntax with placeholders
- [ ] Anything unconfirmed labelled as an assumption with a test
- [ ] Ended with "Did these steps work?"
- [ ] On "no": followed `./debugging-and-guide-update-flow.md`
- [ ] If a guide file changed: `build-pdf.py`, then `--check` printed OK
