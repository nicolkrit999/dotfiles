---
name: answering-neovim-usage-questions
description: Use this skill whenever the user asks how to do something in Neovim or Vim with their own config ("how do I select...", "how do I go to...", "how do I delete/copy/change...", "what key does...", "is it possible to...", "why did this key do that"). It answers from the user's neovim-guide (user-guide.md), verifies every key against the real keymaps (lua/mappings.lua and plugin configs), states clearly when an answer is only an assumption, and keeps the guide correct and complete without ever adding examples the user did not approve.
---

# Answering Neovim usage questions

Paths are relative to the dotfiles repo root (`/home/krit/dotfiles`):

- Guide: `general/general-nvim/.config/nvim/user-guide.md` (large; never read it whole, grep first)
- Keymaps: `general/general-nvim/.config/nvim/lua/mappings.lua`
- Plugin keymaps and settings: `.../nvim/lua/config/*.lua`, `.../nvim/lua/plugin_specs.lua`
- Options and other mappings: `.../nvim/viml_conf/`, `.../nvim/plugin/`, `.../nvim/after/`, `.../nvim/lua/custom-autocmd.lua`

## Hard rules

1. **Never invent a solution.** If the thing cannot be done the way the user asked, say so plainly. If it needs several steps, list the steps and say it needs several steps. Do not present a workaround as if it were one command.
2. **Never add a new example to the guide unless the user explicitly approved it in this conversation.** Asking "do you want me to add it?" is required every time; silence or "ok" to something else is not approval.
3. **Never write "tested" or "verified" in the guide from reasoning alone.** Only after the user reports the real result.
4. **If unsure, say so clearly** (see "Uncertain answers").
5. **Be skeptical of both sources, every time** (see next section). The guide and the mappings are claims to check, not facts to repeat.

## Be skeptical: nothing is trusted by default

The guide may be stale, and the mappings may have changed since it was written or since you last read them. Even when everything looks up to date, assume there is a small chance it is not.

- **Source of truth order.** The mappings are the authority on what a key is bound to, because the keys are hardcoded in the config. The guide is only a description of them and is the one that can be wrong or stale. When they disagree, the mapping wins and the guide is what gets corrected.
- **Mappings can still mislead in three ways, so check them:** the same key bound twice (the later definition wins; grep for every definition of the key), an override in a plugin config, `after/ftplugin` file or buffer-local mapping, and the running Neovim not having reloaded the file. A mapping also says nothing about what a built-in motion does, so label that part as an assumption until the user confirms.
- **Read fresh on every question.** Re-read the relevant guide section and the relevant mapping lines each time, even if you read them earlier in the conversation. The user may have edited them in the meantime. Never answer from memory of an earlier read or from a previous answer.
- **Check recency when it matters.** Run `git log -3 --format='%h %ad %s' --date=short -- <file>` (and `git status --short`) on `user-guide.md`, `lua/mappings.lua` and the plugin config involved, to see whether the mappings changed after the guide text was written. If the mapping changed later than the guide, treat the guide's text as suspect.
- **Cross-check the two sources against each other.** If the guide says a key does X, find the mapping that actually does X. A guide entry with no matching mapping, or a mapping the guide describes differently, is a discrepancy.
- **Report discrepancies instead of smoothing them over.** Tell the user which file says what (with `file:line`), which one you trust and why (the real mapping wins over the guide), and offer to correct the guide. Fixing wrong guide text follows the same rule as step 5 of the workflow: correct it and say what changed.
- **Matching sources are still not proof.** Both can be right about the keys and wrong about the behaviour (which mode, what is included in a selection, what a plugin does). If you did not see the behaviour confirmed by the user, label it as an assumption.

## Workflow for every "how do I ..." question

### 1. Look in the guide

- Grep the guide for the keys and keywords involved (`grep -n` for the motion, key or plugin name), then read only the matching sections.
- Note whether the guide already answers it, partly answers it, or is silent.

### 2. Verify against the real config

Never trust the guide alone, and never answer from generic Vim knowledge alone. For every key in the answer, check the config:

- Is the key remapped? Read `lua/mappings.lua` and grep `lua/config/` and `lua/plugin_specs.lua`. Known traps in this config: `f` is hop.nvim (2 characters plus a label), `;` is `:`, `$` is `g_` in visual mode only, `H`/`L` are remapped, `0` is `g0`, `c`/`C`/`cc` use the black-hole register, `s` is disabled (vim-sandwich), `j`/`k` follow wrapped lines only without a count.
- **Which modes does the mapping cover?** A mapping for `{ "n", "x" }` does NOT apply after an operator (`d`, `y`, `c`). `dL` therefore uses the built-in `L` (bottom of screen, linewise) and deletes whole lines.
- Is the plugin actually enabled, or commented out in `plugin_specs.lua`? (for example vim-visual-multi is commented out, so there is no multi-cursor.)
- Options that change behaviour: `nowrap`, `ignorecase smartcase`, `relativenumber`. Check `viml_conf/options.vim` when they matter.

If a check is not possible (for example a plugin default not visible in the config), say which part could not be verified.

### 3. Answer

- Start with the direct answer: the keys, in order, and what each one does.
- Give a short example of the expected result when it helps.
- Mention related gotchas that would surprise the user (a key that looks right but is remapped, `v2t` versus `2vt`, selections include the character under the cursor, and so on).
- Keep it short. Use a table only when comparing keys.
- If the request cannot be done as asked, say so first, then the multi-step alternative.

### 4. Uncertain answers

Whenever any part of the answer is not confirmed by both the guide and the config, or the user's report contradicts an earlier answer:

- Say explicitly: **"This is an assumption, I have not been able to confirm it."** Name which part is unconfirmed.
- Give the exact keys to try and the result you expect.
- Ask the user to try it and **report back exactly what happened** (resulting text, selection, or error message).

Do not hedge with "probably" inside an otherwise confident answer. Either it is confirmed, or it is labelled as an assumption with a test.

### 4b. Unexpected behaviour: ask about the keyboard layout, do not assume

If a key sequence does nothing, needs an extra key, or types a strange or accented character, and the config and guide do not explain it, **ask the user which keyboard layout or input method they are using on this machine** before drawing any conclusion. Dead keys (`"`, `'`, `` ` ``, `~`, `^` need a following `<Space>`) or an IME can swallow keys before Neovim sees them.

- The user's usual layout is US International (with dead keys), but they work from different PCs, so **never assume** it is the same on this one. Ask, even if the symptom matches the usual layout.
- Do not blame the config until the layout question is answered. Check the guide section "Keyboard Layouts With Dead Keys" (section 70) for the known case.
- Suggest the quick test: type the key then a letter in Insert mode and see whether an accented letter appears.
- Only write confirmed layout facts into the guide, and only with the user's approval.

### 5. After the user reports the result

1. Re-read the relevant guide section.
2. **Result contradicts the guide (or your claim):** correct the wrong text in the guide right away, and tell the user what was wrong and what you changed. Also fix your own earlier answer in the conversation, not just the file. Correcting wrong information does not need approval; adding new examples does.
3. **Result matches the guide:** say it is confirmed, then ask whether the user wants this question added to the guide as a day-to-day example (see next section). If the guide already covers it, add nothing; you may mark it as tested.

### 6. Coverage check (also for questions answered without a test)

If step 1 found that the guide does not cover the question:

- Ask the user: "This isn't in the guide. Do you want me to add a generalized example?" and wait.
- **If yes:** add it (rules below). **If no or no answer:** add nothing.

If the guide already covers it, do not propose anything.

## Rules for adding an example (only after approval)

- Generalize it: no variable names, file names or snippets from the user's current code. Use neutral placeholders (`foo`, `X`, `<char>`).
- Put it in the matching section (selection in section 5, insert in section 4, searching in section 10, and so on). Extend an existing subsection before creating a new one. Do not renumber sections; check the table in "Quick lookup" style sections and update it if the new example belongs there.
- Match the guide's format: Markdown tables for key / effect, short bullets for caveats, backticked keys.
- Include the things that surprised the user: remaps, which modes, counts, what is included in a selection.
- State the status honestly: mark as tested only if the user confirmed the exact keys; otherwise write that it was not tested yet.
- Never duplicate: if a nearly identical entry exists, edit that one.
- Touch only `user-guide.md` unless the user asks otherwise. Do not commit unless asked; this repo is public, so never put secrets or private paths in examples.

## Quick checklist before sending an answer

- [ ] Searched the guide and re-read it fresh (not from memory)
- [ ] Every key checked in the config (remaps and modes), re-read fresh
- [ ] Checked whether the guide and the mappings agree, and which changed last
- [ ] Reported any discrepancy with `file:line`
- [ ] Anything unconfirmed is labelled as an assumption, with a test and a request for the output
- [ ] If it cannot be done as asked, said so first
- [ ] If the guide lacks it, asked the user whether to add a generalized example
- [ ] Did not edit the guide with new examples without approval
