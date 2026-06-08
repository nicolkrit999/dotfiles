# CLAUDE.md

Personal **public** dotfiles repository, deployed via **nix symlinks** (no longer GNU Stow — see Deployment).

## Repository Structure

Files are organized by a **category tree**, not flat stow packages:
- `general/` — cross-platform configs (`general/general-nvim/`, `general/shells/`, …).
- `linux/` — Linux-specific (`linux/linux-general/`, `linux/linux-distro-specific/<distro>/`).
- `macOS/` — macOS-specific.
- `various-scripts/` — standalone scripts.

By convention a config's leaf path mirrors its `$HOME`-relative target (e.g. `general/general-nvim/.config/nvim/` → `~/.config/nvim`). Platform-specific variants (e.g. fastfetch logos per distro) live under the matching `linux/linux-distro-specific/<distro>/` or `macOS/` subtree.

## Theme Convention

All configs use the **Catppuccin Mocha** palette. FZF styling is kept consistent across all shells.

## ⚠️ Public repo

This repository is **public**. Never commit secrets (API keys, tokens, passwords, private hosts/emails). If a config needs a secret, source it at runtime from an untracked file or `sops` — never inline. Run `dotfiles-linter` for a secret scan before committing.

## Deployment (nix symlinks — no stow)

This repo is **no longer GNU-Stow compatible**. Symlinks into `$HOME` are created declaratively by **`ext-dotfiles.nix`** (`~/nix/users/krit/{nixos,darwin}/services/ext-dotfiles.nix`). Adding a new config does nothing until you add a mapping line there: `"<path-rel-to-HOME>" = "<repo-path>";` (e.g. `".config/nvim" = "general/general-nvim/.config/nvim";`). Cross-platform configs go in both files; platform-specific ones only in the matching file. A `nixos-rebuild` / `darwin-rebuild` then creates the symlink. (A vestigial `.stow-local-ignore` may exist but is unused.)

## Subagents & Delegation

Project-scoped fleet (lives in `.claude/agents/`; model in brackets — haiku = mechanical, sonnet = authoring):

- **General structure / what-to-dotfile / naming / portability / ricing / any program without a specialist** → `dotfiles-architect` [sonnet].
- **Neovim** (Lua, plugins, keymaps, LSP) → `neovim-configurator` [sonnet].
- **Emacs** (Elisp, packages, keybinds) → `emacs-configurator` [sonnet].
- **Shells** (bash/zsh/fish aliases, functions, prompts) → `shell-config-author` [sonnet].
- **Standalone scripts** (various-scripts, any language) → `script-author` [sonnet].
- **Verify** (parse/load checks, deployment-mapping check, **secret scan**) → `dotfiles-linter` [haiku].

These agents live in this repo (public) and are picked up automatically when working here — they are NOT symlinked from dotfiles-private, by design.
