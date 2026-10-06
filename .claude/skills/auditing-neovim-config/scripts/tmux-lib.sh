#!/usr/bin/env bash
# tmux-lib.sh: helper library to drive a REAL Neovim inside a PRIVATE tmux server (real keys, real timing, real screen).
#   source tmux-lib.sh          (isolated-nvim.sh must sit next to this file)
# Env: AUDIT_OUT (work root, default /tmp/nvim-audit; scratch dirs MUST be under it), TN_COLS/TN_ROWS, TN_BOOT, TN_KEYWAIT.
# Rules: nvim only through isolated-nvim.sh (protects lazy-lock.json); one UNIQUE socket name per test; never touch the
# user's tmux; no system clipboard (use fake wl-copy/wl-paste/xclip scripts on PATH or `:set clipboard=` before yanking);
# never open GUI windows; delete the scratch dir afterwards.
#
# --- plain mode (tn_*) -------------------------------------------------------
#   tn_start NAME SCRATCH [WORKDIR] [nvim args...]   e.g. tn_start t1 $AUDIT_OUT/t1 $AUDIT_OUT/t1/files t.txt
#   tn_keys i Escape C-w Space   tmux key names;   tn_text 'hello'  literal text (no key-name parsing)
#   tn_cmd 'set number?'         types :cmd + Enter;  tn_screen [-e]  screen (-e = colour codes)
#   tn_wait 'regex' [secs]       wait for the screen to match;  tn_lua 'vim.bo.filetype'  evaluate Lua, print result
#   tn_stop                      ALWAYS call (also after failures)
# --- devShell mode (at_*) ----------------------------------------------------
#   at_start NAME SHELLDIR CWD [nvim args...]   nvim started inside `direnv exec SHELLDIR` (nix devShell), cwd CWD.
#   Pass at least one file argument: with no args nvim shows the dashboard and hides the file.
#   k KEY...  kl TEXT  cmd EXCMD [wait]  scr  fact 'lua expr'  at_stop
#   AT_FAKEBIN=<dir> puts fake binaries (clipboard tools, ...) first on PATH INSIDE the devShell (direnv exec
#   resets PATH, so the prefix must be applied after it; it is done in the inner command).
_TL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TN_ISO=${TN_ISO:-$_TL_DIR/isolated-nvim.sh}
TN_WORK=${AUDIT_OUT:-/tmp/nvim-audit}
AT=$TN_WORK/at

# --- user-tmux protection (HARD RULE) ---------------------------------------------------------
# The owner works INSIDE a tmux server (see $TMUX). Killing that server kills the owner's shell, the Claude session
# and everything running in it. Therefore: never run a bare `tmux ...` (no -L/-S), never `kill-session`,
# `kill-window`, `kill-pane`, `kill-server`, `pkill tmux`, `killall tmux` outside these helpers. Every kill goes
# through _tn_kill, which (1) refuses an empty or non-private socket name, (2) refuses when the target socket is the
# owner's ($TMUX) or the default socket, (3) afterwards confirms the owner's server still answers, else prints a
# loud "USER TMUX DIED" and returns 99 (stop and tell the user at once).
_tn_user_sock() { [ -n "${TMUX:-}" ] && printf '%s' "${TMUX%%,*}"; }
_tn_sock_path() { printf '%s/tmux-%s/%s' "${TMUX_TMPDIR:-/tmp}" "$(id -u)" "$1"; }
_tn_kill() {  # _tn_kill SOCKNAME   (SOCKNAME must start with tn- or at-)
  local name=$1 target user
  case "$name" in tn-?*|at-?*) ;; *) echo "_tn_kill: refusing socket name '$name' (must be tn-* or at-*)" >&2; return 2;; esac
  target=$(_tn_sock_path "$name"); user=$(_tn_user_sock)
  if [ "$name" = default ] || { [ -n "$user" ] && [ "$(realpath -m "$target")" = "$(realpath -m "$user")" ]; }; then
    echo "_tn_kill: REFUSED, '$name' is the owner's tmux socket" >&2; return 3
  fi
  tmux -L "$name" kill-server 2>/dev/null || true
  if [ -n "$user" ] && ! tmux -S "$user" list-sessions >/dev/null 2>&1; then
    echo "USER TMUX DIED after killing '$name': stop all work and tell the user immediately" >&2; return 99
  fi
}

_tn_check_scratch() { case "$(realpath -m "$1")" in "$(realpath -m "$TN_WORK")"/*) return 0;; *) echo "scratch must be under $TN_WORK/" >&2; return 2;; esac; }

tn_start() {  # name scratch [workdir] [nvim args...]
  TN_NAME=$1; TN_SCRATCH=$2; local wd=${3:-$PWD}; shift 3 || shift $#
  _tn_check_scratch "$TN_SCRATCH" || return 2
  TN_SOCK=tn-$TN_NAME; mkdir -p "$TN_SCRATCH" "$wd"
  _tn_kill "$TN_SOCK" || return $?
  tmux -L "${TN_SOCK:?TN_SOCK unset}" new-session -d -s t -x "${TN_COLS:-160}" -y "${TN_ROWS:-45}" -c "$wd" \
    "nice -n 10 $TN_ISO $TN_SCRATCH $(printf '%q ' "$@")"
  tn_wait '.' 30 >/dev/null || { echo "tn_start: no screen output" >&2; return 1; }
  sleep "${TN_BOOT:-6}"          # let lazy.nvim/LSP/plugins settle (dashboard, VeryLazy plugins)
}
tn_keys()   { tmux -L "${TN_SOCK:?TN_SOCK unset}" send-keys -t t "$@"; sleep "${TN_KEYWAIT:-0.4}"; }   # tmux key names: Enter Escape C-w M-m Tab Space Up ...
tn_text()   { tmux -L "${TN_SOCK:?TN_SOCK unset}" send-keys -t t -l -- "$1"; sleep "${TN_KEYWAIT:-0.4}"; } # literal characters; `<Space>` is NOT understood: use tn_keys Space
tn_cmd()    { tmux -L "${TN_SOCK:?TN_SOCK unset}" send-keys -t t Escape; sleep 0.3; tn_text ":$1"; tmux -L "${TN_SOCK:?TN_SOCK unset}" send-keys -t t Enter; sleep "${TN_KEYWAIT:-0.4}"; }
tn_screen() { tmux -L "${TN_SOCK:?TN_SOCK unset}" capture-pane -t t -p "$@"; }                           # -e = colour escapes, -S -50 = scrollback
tn_wait()   { local re=$1 t=${2:-10} i; for ((i=0; i<t*5; i++)); do tn_screen | grep -qE "$re" && return 0; sleep 0.2; done; echo "tn_wait: timeout waiting for /$re/" >&2; return 1; }
tn_lua()    {  # evaluate a Lua expression in the running nvim and print it (via a file, no screen scraping)
  local f=$TN_SCRATCH/lua-out.txt; rm -f "$f"
  tn_cmd "lua vim.fn.writefile({tostring($1)}, '$f')"; local i; for ((i=0;i<25;i++)); do [ -s "$f" ] && break; sleep 0.2; done; cat "$f" 2>/dev/null
}
tn_stop()   { tmux -L "${TN_SOCK:?TN_SOCK unset}" send-keys -t t Escape ':qa!' Enter 2>/dev/null; sleep 0.5; _tn_kill "$TN_SOCK"; }

# at_start <name> <shell-dir> <cwd> [nvim args...]  (nvim inside the nix devShell of <shell-dir>, cwd <cwd>)
at_start() { N=$1; SD=$2; CWD=$3; shift 3; SOCK=at-$N; SCR=$AT/s-$N; mkdir -p "$CWD" "$AT"
  _tn_kill "$SOCK" || return $?
  INNER="PATH=${AT_FAKEBIN:+$AT_FAKEBIN:}\$PATH exec nice -n 10 $TN_ISO $SCR $(printf '%q ' "$@")"
  tmux -L "${SOCK:?SOCK unset}" new-session -d -s t -x 200 -y 50 -c "$CWD" "direnv exec '$SD' sh -c $(printf '%q' "$INNER")"
  sleep ${AT_BOOT:-10}; }
k()   { tmux -L "${SOCK:?SOCK unset}" send-keys -t t "$@"; }
kl()  { tmux -L "${SOCK:?SOCK unset}" send-keys -t t -l -- "$1"; }
cmd() { k Escape; sleep .3; kl ":$1"; k Enter; sleep ${2:-1}; }
scr() { tmux -L "${SOCK:?SOCK unset}" capture-pane -t t -p; }
fact(){ local F=$AT/o-$SOCK.txt; rm -f $F; cmd "lua vim.fn.writefile({tostring($1)}, '$F')" .6; sleep .4; cat $F 2>/dev/null; }
at_stop(){ _tn_kill "$SOCK"; rm -rf "$AT/s-$N"; }
