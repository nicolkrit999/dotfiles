Portable verification tooling for the Neovim config (no hard-coded paths). Needs nvim >= 0.12, tmux, git; direnv only for at_start.
Config dir = $NVIM_CFG or <git root>/general/general-nvim/.config/nvim; all output and scratch dirs live under ${AUDIT_OUT:-/tmp/nvim-audit}.
verify.sh <label> [baseline-dir]: steps A-F (capture.lua, checks.lua, startup median, smart_comment guard, luac, lock snapshot) + diff.
isolated-nvim.sh <scratch> [nvim args]: nvim on a COPY of the config with scratch XDG dirs; restores lazy-lock.json (exit 97 if changed).
tmux-lib.sh: source it; tn_start/tn_keys/tn_text/tn_cmd/tn_screen/tn_wait/tn_lua/tn_stop (+ at_start/k/kl/cmd/scr/fact for devShells).
Edit the ignore list in checks.lua and INV_SAMPLES (default: tiny files created in $AUDIT_OUT/samples) to fit the config under audit.
