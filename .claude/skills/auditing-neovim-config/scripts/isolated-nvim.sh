#!/usr/bin/env bash
# Usage: isolated-nvim.sh <scratch-dir> [nvim args...]
# Runs nvim against a COPY of the config with scratch XDG_{CONFIG,DATA,STATE,CACHE}_HOME.
# REQUIRED for any run with fake tools on PATH (or anything that may make lazy install/clean/update):
# lazy.nvim writes lazy-lock.json to stdpath('config'), so a scratch XDG_DATA_HOME alone does NOT
# protect the real lockfile.
# The scratch data dir is SEEDED (cp -a, never a symlink into the real tree, so no test can write to
# the real data dir) with:
#   lazy/      installed plugins (nothing cloned from the network)
#   site/      tree-sitter grammars. Without it the smart_comment suite still PASSES but silently
#              runs about half the cases (tree-sitter cases skipped).
#   nvim-java/ jdtls/java-test/java-debug/lombok. Without it nvim-java downloads ~61 MB at startup.
# Env:
#   NVIM_CFG        config dir to copy (default: <git root>/general/general-nvim/.config/nvim)
#   AUDIT_OUT       work root (default /tmp/nvim-audit); the scratch dir MUST be under it
#   NVIM_REAL_DATA  real data dir, only READ (default ${XDG_DATA_HOME:-~/.local/share}/nvim)
# Rules: the real lazy-lock.json is sha-checked around the run and restored if changed (exit 97);
# delete the scratch dir afterwards. Run with `nice -n 10`.
set -eu
S=${1:?scratch dir}; shift
OUT=${AUDIT_OUT:-/tmp/nvim-audit}
case "$(realpath -m "$S")" in "$(realpath -m "$OUT")"/*) ;; *) echo "isolated-nvim.sh: scratch must be under $OUT/" >&2; exit 2;; esac
if [ -z "${NVIM_CFG:-}" ]; then
  root=$(git rev-parse --show-toplevel 2>/dev/null || git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
  NVIM_CFG=$root/general/general-nvim/.config/nvim
fi
CFG=$NVIM_CFG
[ -d "$CFG" ] || { echo "isolated-nvim.sh: no config dir $CFG (set NVIM_CFG)" >&2; exit 2; }
REAL=${NVIM_REAL_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/nvim}
mkdir -p "$S"/{config,data/nvim,state,cache}
rm -rf "$S/config/nvim"; cp -rL "$CFG" "$S/config/nvim"
for d in lazy site nvim-java; do
  [ -d "$S/data/nvim/$d" ] || { [ -d "$REAL/$d" ] && cp -a "$REAL/$d" "$S/data/nvim/$d"; } || true
done
LOCK="$CFG/lazy-lock.json"
sha0=none
if [ -f "$LOCK" ]; then sha0=$(sha256sum "$LOCK" | cut -d' ' -f1); cp -p "$LOCK" "$S/lazy-lock.real.bak"; fi
rc=0
env XDG_CONFIG_HOME="$S/config" XDG_DATA_HOME="$S/data" XDG_STATE_HOME="$S/state" XDG_CACHE_HOME="$S/cache" nvim "$@" || rc=$?
if [ -f "$LOCK" ] && [ "$(sha256sum "$LOCK" | cut -d' ' -f1)" != "$sha0" ]; then
  cp -p "$S/lazy-lock.real.bak" "$LOCK"; echo "isolated-nvim.sh: REAL lazy-lock.json changed during run; RESTORED" >&2; rc=97
fi
exit $rc
