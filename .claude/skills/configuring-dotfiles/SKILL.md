---
name: configuring-dotfiles
description: Use this skill when the user says 'add a config for <program>', 'add an alias', 'write a fish function', 'configure my nvim/emacs' (for Neovim it only handles config changes; usage questions, audits and debugging go to answering-neovim-usage-questions or auditing-neovim-config), 'rice <program>', 'add a utility script', or 'dotfile this' in this PUBLIC dotfiles repo (general/, linux/, macOS/, various-scripts/, Catppuccin Mocha theme). It routes program-specific work to the right specialist (neovim-configurator, emacs-configurator, shell-config-author, script-author) or to dotfiles-architect for structural, new-program or unclear-placement decisions, verifies with dotfiles-linter (parse checks, secret scan, deployment-mapping check), and ends by handing over the exact ext-dotfiles.nix mapping line(s) needed to deploy the new file. Does NOT cover system-level config (NixOS modules, /etc, services - that is the ~/nix repo) or standalone scripts unrelated to dotfiles.
---

# Configuring Dotfiles

## Context

This is a **PUBLIC** dotfiles repo - never write secrets, tokens, or credentials into it. Files are organized under `general/`, `linux/`, `macOS/`, `various-scripts/`. Theme is Catppuccin Mocha throughout. Deployment is via nix symlinks: a new config file does **nothing** on its own - it only takes effect once a mapping line is added to `~/nix/users/krit/{nixos,darwin}/services/ext-dotfiles.nix` (format: `"<path-rel-to-HOME>" = "<repo-path>";`) and the system is rebuilt. That file lives in the separate `~/nix` repo, not here.

## Agent fleet (exact names, cannot call each other)

- `dotfiles-architect` (sonnet) - placement/structure/portability/deployment strategy; also the catch-all for program config with no dedicated specialist.
- `neovim-configurator` (sonnet) - Neovim config.
- `emacs-configurator` (sonnet) - Emacs config.
- `shell-config-author` (sonnet) - bash/zsh/fish rc config, aliases, functions.
- `script-author` (sonnet) - standalone scripts.
- `nvim-guide-maintainer` (sonnet) - Neovim user guide text, PDF rebuild and key `desc` check; contract is the `answering-neovim-usage-questions` skill.
- `nvim-gate-runner` (sonnet, read-only) - Neovim regression gate; contract is the `auditing-neovim-config` skill.
- `nvim-trial-runner` (sonnet) - sandbox search for a working key or command; used by the Neovim skills, not by this loop.
- `dotfiles-linter` (haiku, read-only) - parse/load checks, `ext-dotfiles.nix` deployment-mapping check, PUBLIC-repo secret scan. Never edits files.

The orchestrator (this chat) is the only one that dispatches agents and loops between them - agents cannot invoke one another.

## Neovim requests: check first, redirect without asking

If the task touches Neovim (keys, plugins, `general-nvim`, the user guide), classify it before anything else and, when it is not an authoring task, invoke the right skill with the Skill tool immediately and stop following this one. Do not refuse and do not make the user retype the request:

| The user wants... | Action |
|---|---|
| to know how to do something, what a key does, why a key behaved a certain way | invoke `answering-neovim-usage-questions` |
| a key or command that does not work debugged, or a working alternative found | invoke `auditing-neovim-config` (trial mode) |
| to audit, review, verify, check clashes, check the guide is stale, run the gate, "bug or deliberate?" | invoke `auditing-neovim-config` |
| to ADD or CHANGE Neovim config (plugin, keymap, option, LSP, autocmd) | stay here: route to `neovim-configurator` (Loop below), then apply the Neovim guards |

When unsure which row applies, ask one short question. A mixed request is split: authoring first, then the audit skill on the result.

### Neovim guards for the authoring row

- `neovim-configurator` already carries the standing rules (`desc`, clash check, branch rule); it ends with a guide brief. Dispatch `nvim-guide-maintainer` with that brief in the same change so the guide and PDF are updated.
- Never touch `main`, never merge or push unasked; work on `develop` or a task branch.
- After VERIFY, dispatch `nvim-gate-runner` for any change to Lua, plugins or keymaps, and report its verdicts next to the linter's.

## Loop

1. **ROUTE** - Program-specific work goes straight to the matching specialist: `neovim-configurator`, `emacs-configurator`, `shell-config-author`, or `script-author`. Anything structural, a brand-new program with no specialist, or unclear placement goes to `dotfiles-architect` first - it decides the category-tree location (`general/`, `linux/`, `macOS/`, `various-scripts/`) and the deployment mapping shape.
2. **AUTHOR** - The chosen specialist writes the config: portable across the target platform(s), styled Catppuccin Mocha where applicable, and **never** containing secrets (public repo).
3. **VERIFY** - Dispatch `dotfiles-linter` on the touched files: parse/load check, secret scan, and - for anything new - a check of whether `ext-dotfiles.nix` mapping exists yet.
4. **FIX** - Any linter findings go back to the authoring specialist (or `dotfiles-architect` if it's a placement issue). Loop 3→4 until the linter passes. Safeguard: ~4 rounds, then stop and report what's still failing.
5. **DEPLOY HANDOFF** - For new files, end the turn by giving the user the exact `ext-dotfiles.nix` mapping line(s) to add in the `~/nix` repo - both `nixos` and `darwin` platform files if the config is cross-platform - and note that a rebuild is required to create the symlink.

## Neovim user guide

Any change under `general/general-nvim/.config/nvim/user-guide/**/*.md` ends with a mandatory rebuild: run `user-guide/build-pdf.py` (regenerates the README table of contents and the committed `neovim-user-guide.pdf`), then `build-pdf.py --check` must print OK. `<Space>?` and the dashboard item open that PDF, so a stale PDF means the user reads wrong information. Include the PDF and its `.stamp` file in the change.

## Exit condition

`dotfiles-linter` reports clean AND the mapping line(s) have been delivered to the user. Report the files written and the mapping line(s) verbatim.

## Out of scope

- System-level configuration (NixOS modules, `/etc`, services) - that belongs in the `~/nix` repo, not here.
- Standalone-script requests with no dotfiles connection - only use `script-author` here when the script is part of this repo's dotfiles.
