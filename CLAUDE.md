# CLAUDE.md

Personal dotfiles repository managed with **GNU Stow**. Must be cloned to `~/dotfiles/` for stow to create correct symlinks into `$HOME`.

## Stow Package Architecture

Each top-level directory is a stow package. The directory structure inside each package mirrors the target path relative to `$HOME`.

**Platform-specific packages** exist for some tools (e.g., `catppuccin-mocha-fastfetch-fedora`, `catppuccin-mocha-fastfetch-macOS`, `catppuccin-mocha-fastfetch-nixOS`). Only stow the one matching the current platform.

## Theme Convention

All packages use the **Catppuccin Mocha** palette. FZF styling is kept consistent across all shells.

## ⚠️ Public repo

This repository is **public**. Never commit secrets (API keys, tokens, passwords, private hosts/emails). If a config needs a secret, source it at runtime from an untracked file or `sops` — never inline. Run `dotfiles-linter` for a secret scan before committing.

## Deployment (nix hosts vs stow)

The repo is stow-*structured*, but on the user's NixOS / nix-darwin hosts the symlinks are created declaratively by **`ext-dotfiles.nix`** (`~/nix/users/krit/{nixos,darwin}/services/ext-dotfiles.nix`), **not** by `stow`. Adding a new config therefore needs a mapping line there (`"<path-rel-to-HOME>" = "<package>/<path>";`) to appear on those hosts. On non-nix hosts, deploy with `stow <package>`.

## Subagents & Delegation

Project-scoped fleet (lives in `.claude/agents/`; model in brackets — haiku = mechanical, sonnet = authoring):

- **General structure / what-to-dotfile / naming / portability / ricing / any program without a specialist** → `dotfiles-architect` [sonnet].
- **Neovim** (Lua, plugins, keymaps, LSP) → `neovim-configurator` [sonnet].
- **Emacs** (Elisp, packages, keybinds) → `emacs-configurator` [sonnet].
- **Shells** (bash/zsh/fish aliases, functions, prompts) → `shell-config-author` [sonnet].
- **Standalone scripts** (various-scripts, any language) → `script-author` [sonnet].
- **Verify** (parse/load checks, stow dry-run, **secret scan**) → `dotfiles-linter` [haiku].

These agents live in this repo (public) and are picked up automatically when working here — they are NOT symlinked from dotfiles-private, by design.
