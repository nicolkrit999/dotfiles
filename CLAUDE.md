# CLAUDE.md

Personal dotfiles repository managed with **GNU Stow**. Must be cloned to `~/dotfiles/` for stow to create correct symlinks into `$HOME`.

## Stow Package Architecture

Each top-level directory is a stow package. The directory structure inside each package mirrors the target path relative to `$HOME`.

**Platform-specific packages** exist for some tools (e.g., `catppuccin-mocha-fastfetch-fedora`, `catppuccin-mocha-fastfetch-macOS`, `catppuccin-mocha-fastfetch-nixOS`). Only stow the one matching the current platform.

## Theme Convention

All packages use the **Catppuccin Mocha** palette. FZF styling is kept consistent across all shells.
