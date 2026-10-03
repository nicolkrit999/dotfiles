#!/usr/bin/env bash
# Usage: verify.sh <label> [baseline-dir]   -> writes $AUDIT_OUT/results/<label>-<short-hash>[-dirty]/ ; with a baseline dir, prints the diff
#        verify.sh diff <dirA> <dirB>
# Runs the full automated check suite (steps A-F) against the config. Default: the LIVE nvim (the deployed config,
# normally a symlink to the repo). VERIFY_ISOLATED=1 runs every nvim through isolated-nvim.sh with scratch XDG dirs.
# Env: NVIM_CFG (config dir; default <git root>/general/general-nvim/.config/nvim), AUDIT_OUT (default /tmp/nvim-audit),
#      INV_SAMPLES (sample files dir; default $AUDIT_OUT/samples, created with tiny samples if missing),
#      MIN_SC_CASES (default 10000), MIN_LOCK_ENTRIES (default 100).
# Exit: 3 = smart_comment case count below threshold.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
AUDIT_OUT=${AUDIT_OUT:-/tmp/nvim-audit}; export AUDIT_OUT
SC_FAIL=0

do_diff() {
  diff -r -u "$1" "$2" --exclude=checkhealth_full.txt --exclude=startuptime_raw.txt --exclude=startuptime.txt
  echo "--- startuptime: $(cat "$1/startuptime.txt") -> $(cat "$2/startuptime.txt")"
}
if [ "${1:-}" = diff ]; then do_diff "$2" "$3"; exit 0; fi

label=${1:?label}; baseline=${2:-}
REPO=$(git rev-parse --show-toplevel 2>/dev/null || git -C "$HERE" rev-parse --show-toplevel)
CFG=${NVIM_CFG:-$REPO/general/general-nvim/.config/nvim}
[ -d "$CFG" ] || { echo "verify.sh: no config dir $CFG (set NVIM_CFG)" >&2; exit 2; }
h=$(git -C "$REPO" rev-parse --short HEAD)
[ -n "$(git -C "$REPO" status --porcelain -- "$CFG")" ] && h="$h-dirty"
OUT=$AUDIT_OUT/results/$label-$h
rm -rf "$OUT"; mkdir -p "$OUT"

# sample files for the filetype smoke test (checks.lua)
SAMPLES=${INV_SAMPLES:-$AUDIT_OUT/samples}
if [ ! -d "$SAMPLES" ]; then
  mkdir -p "$SAMPLES/java-project"
  printf 'local x = 1\nprint(x)\n' > "$SAMPLES/a.lua"
  printf 'def f(x):\n    return x + 1\n' > "$SAMPLES/a.py"
  printf '#!/usr/bin/env bash\necho hi\n' > "$SAMPLES/a.sh"
  printf '{"a": 1}\n' > "$SAMPLES/a.json"
  printf '# Title\n\ntext\n' > "$SAMPLES/a.md"
  printf '{ pkgs, ... }: {\n  x = 1;\n}\n' > "$SAMPLES/a.nix"
  printf 'a: 1\n' > "$SAMPLES/a.yaml"
  printf 'set number\n' > "$SAMPLES/a.vim"
  printf 'echo hi\n' > "$SAMPLES/a.fish"
  printf '\\documentclass{article}\n\\begin{document}\nhi\n\\end{document}\n' > "$SAMPLES/a.tex"
  printf '= Title\n' > "$SAMPLES/a.typ"
  printf 'public class A {}\n' > "$SAMPLES/java-project/A.java"
  printf '<project><modelVersion>4.0.0</modelVersion><groupId>t</groupId><artifactId>t</artifactId><version>1</version></project>\n' > "$SAMPLES/java-project/pom.xml"
fi
export INV_OUT=$OUT INV_SAMPLES=$SAMPLES

# nvim wrapper: live, or isolated (scratch XDG dirs, lockfile protected)
if [ "${VERIFY_ISOLATED:-0}" = 1 ]; then NV=("$HERE/isolated-nvim.sh" "$AUDIT_OUT/scratch/verify-$label"); else NV=(nvim); fi
export NVIM_CFG=$CFG
cd "$SAMPLES"

# A) functional inventory (plugins, keymaps, commands, autocmds, lsp, options)
timeout 90 "${NV[@]}" --headless "+lua dofile('$HERE/capture.lua')" +qa >"$OUT/capture_stderr.txt" 2>&1
# B) startup messages, force-load all plugins, filetype smoke, keymap shadowing, checkhealth
timeout 600 "${NV[@]}" --headless "+lua dofile('$HERE/checks.lua')" >"$OUT/checks_stderr.txt" 2>&1
# C) startup time (median of 5, ms)
for i in 1 2 3 4 5; do
  "${NV[@]}" --headless --startuptime "$OUT/startuptime_raw.txt" +qa >/dev/null 2>&1
  grep 'NVIM STARTED' "$OUT/startuptime_raw.txt" | awk '{print $1}'; rm -f "$OUT/startuptime_raw.txt"
done | sort -n | sed -n 3p > "$OUT/startuptime.txt"
# D) repo test-suite(s) (smart_comment), run from the config dir
sc_total=
if [ -f "$CFG/tests/smart_comment/run.lua" ]; then
  (cd "$CFG" && timeout 300 nvim --headless -c 'luafile tests/smart_comment/run.lua' -c 'qa!' 2>&1 | grep -E 'passed|FAIL') > "$OUT/tests_smart_comment.txt"
  # D2) case-count guard: a suite that runs without tree-sitter grammars passes with about half the cases.
  # Fail LOUDLY below the threshold (bump MIN_SC_CASES when the suite grows).
  MIN_SC_CASES=${MIN_SC_CASES:-10000}
  sc_total=$(grep -oE '[0-9]+ total' "$OUT/tests_smart_comment.txt" | tail -1 | awk '{print $1}')
  if [ "${sc_total:-0}" -lt "$MIN_SC_CASES" ]; then
    echo "SMART_COMMENT CASE COUNT TOO LOW: ${sc_total:-none} < $MIN_SC_CASES (tree-sitter grammars missing? site/ not seeded?)" | tee "$OUT/sc_count_FAIL.txt"
    SC_FAIL=1
  fi
else
  : > "$OUT/tests_smart_comment.txt"
fi
# E) lua syntax of every config file
nvim -l <(printf '%s\n' 'for _, f in ipairs(vim.fn.globpath("'"$CFG"'", "**/*.lua", false, true)) do local ok, e = loadfile(f); if not ok then print(e) end end') > "$OUT/luac.txt" 2>&1
# F) lazy-lock snapshot
cp "$CFG/lazy-lock.json" "$OUT/lazy-lock.json" 2>/dev/null
# guard: a clobbered lockfile (e.g. lazy run with fake tools and no scratch XDG_CONFIG_HOME) -> loud flag
n=$(grep -c '"commit"' "$CFG/lazy-lock.json" 2>/dev/null || echo 0)
MIN_LOCK_ENTRIES=${MIN_LOCK_ENTRIES:-100}
[ "$n" -lt "$MIN_LOCK_ENTRIES" ] && echo "LOCKFILE SUSPICIOUS: only $n entries in $CFG/lazy-lock.json (expected >= $MIN_LOCK_ENTRIES); restore from the last green results/*/lazy-lock.json" | tee "$OUT/lockfile_warning.txt"

echo "$OUT"
for f in startup_messages loadall notify_history checkhealth checkhealth_unexpected tests_smart_comment luac capture_stderr checks_stderr; do
  printf '%-22s %s lines\n' "$f" "$(grep -c . "$OUT/$f.txt" 2>/dev/null)"
done
echo "startuptime(ms median) $(cat "$OUT/startuptime.txt")"
echo "smart_comment cases: ${sc_total:-none} (min ${MIN_SC_CASES:-n/a})"
[ -n "$baseline" ] && { echo "=== diff vs $baseline"; do_diff "$baseline" "$OUT"; }
[ "${SC_FAIL:-0}" = 1 ] && { echo "VERIFY FAILED: smart_comment case count below threshold" >&2; exit 3; }
exit 0
