# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with **GNU Stow**. The repo must be cloned to `~/dotfiles/` for stow to create correct symlinks into `$HOME`.

## Stow Package Architecture

Each top-level directory (except `.git`, `.claude`, `.config`) is a stow package. The directory structure inside each package mirrors the target path relative to `$HOME`.

```
stow <package-name>        # Symlink a package into $HOME
stow -D <package-name>     # Remove symlinks for a package
stow -R <package-name>     # Restow (remove + restow)
stow --no-folding <pkg>    # Prevent stow from folding entire dirs into symlinks
```

**Platform-specific packages** exist for some tools (e.g., `catppuccin-mocha-fastfetch-fedora`, `catppuccin-mocha-fastfetch-macOS`, `catppuccin-mocha-fastfetch-nixOS`). Only stow the one matching the current platform.

## Package Overview

| Package | Target | Notes |
|---|---|---|
| `general-bash/` | `~/.bashrc_custom` | Custom aliases/functions for bash |
| `general-fish/` | `~/.custom.fish` | Fish abbreviations and functions |
| `general-zshrc/` | `~/.zshrc_custom` | Zsh with vim keybinds; globally compatible |
| `general-nvim/` | `~/.config/nvim/` | Full Neovim config (jdhao/nvim-config base + nvim-java); randomizes color palette on startup |
| `gitconfig/` | `~/.gitconfig` | Git config for account `nicolkrit999` |
| `caelestia-shell/` | `~/.config/caelestia/shell.json` | Caelestia quickshell on Hyprland |
| `noctalia-shell/` | `~/.config/noctalia/config.json` | Noctalia bar/dashboard/notification config |
| `claude-ai/` | `~/.claude/` + `~/.config/ccstatusline/` | Claude Code settings, keybindings, skills |
| `profile-picture/` | `~/.face` | User profile image |
| Catppuccin theme packages | Various | Platform-specific; all use Catppuccin Mocha palette |

**General stows** (multi-package stows under `.config/`) are also available but less documented.

## Claude AI Package (`claude-ai/`)

The `claude-ai/` package is the most actively maintained. Key files:

- **`.claude/settings.json`** — Global Claude Code settings (permissions, status line, effort level)
- **`.claude/keybindings.json`** — Vim-inspired custom keybindings for all Claude UI contexts (Chat, Settings, Tasks, DiffDialog, ModelPicker, etc.)
- **`.claude/agents/`** — Custom agent definitions
- **`.claude/skills/`** — 175+ installed skills
- **`.claude/plugins/`** — Plugin configurations and marketplaces
- **`.config/ccstatusline/`** — Status line UI config (uses `ccstatusline@latest` npm package)

The status line displays: user@host, truncated CWD, model name, and context usage % (green <50%, yellow 50–80%, red >80%).

## Stow Ignore Rules

`.stow-local-ignore` excludes from symlinking: `.git*`, `README`, `LICENSE`, `lazy-lock.json` (Neovim's plugin lock file), and various Claude Code state directories (`agent-memory`, `cache`, `plans`, `projects`, `session-env`, `shell-snapshots`, etc.) and sensitive files (`.claude.json`, `credentials.json`).

## Theme Convention

All packages use the **Catppuccin Mocha** palette. FZF styling is kept consistent across all shells.

## Shell Configs

Shell packages (`general-bash`, `general-fish`, `general-zshrc`) are designed to be sourced from the main shell config (`.bashrc`, `config.fish`, `.zshrc`), not replace them. They add aliases/abbreviations for: `bat`, `eza`, `fzf`, `zoxide`, and set `JAVA_HOME`/`JDTLS_BIN` when available.
