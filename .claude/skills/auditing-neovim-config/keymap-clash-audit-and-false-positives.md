# Keymap audit reference (auditing-neovim-config)

Contents: 1 How to audit key clashes (vocabulary, dumping maps, what counts as ours, dump limits) / 2 Catalog of known false positives (exact shadows, prefix overlaps, other, which-key ignore list) / 3 The desc rule / 4 Our key families / 5 The no-function-keys constraint


Self-contained. Goal: audit the Neovim keymaps of this config with very few false positives.
Config root: `general/general-nvim/.config/nvim` (in `~/dotfiles`). Neovim 0.12.x. Leader = `<Space>`
(`vim.g.mapleader = " "`, lua/globals.lua), localleader NOT set (default `\`), `timeoutlen = 500` (lua/options.lua).
`<space>x` and `<leader>x` written in source are the SAME key; normalise before comparing.

Rule zero: a finding is only real if it is NOT in section 2. Before reporting anything, look the key up there.

---------------------------------------------------------------------------------------------------

## 1. How to audit key clashes correctly

### 1.1 Vocabulary (do not mix these up)

| term | meaning | consequence |
|---|---|---|
| exact duplicate | same mode + same lhs + same scope (both global, or both in the same buffer) defined twice | the later definition wins silently. Real bug unless a lazy `keys` stub is replaced by its own config() |
| exact shadow | same mode + lhs, one GLOBAL and one BUFFER-local (or builtin default vs ours) | buffer-local wins in that buffer. Usually intentional (fallback pattern, per-filetype) |
| prefix overlap | short map `A` and longer map `AB` in the same mode/scope | typing `A` waits `timeoutlen` (500 ms) for `B`. Cosmetic delay, not a broken key. Only matters if `A` is a frequently used key |
| mode difference | same lhs in `n` vs `x` vs `o` vs `i` | NOT a clash (`gcs` in n and x, `f` in n/x/o, `<Space>f` n+x in json) |
| buffer vs buffer | same lhs in two different filetypes | NOT a clash (`<F9>`, `<Space>rf`, `<Space>f` per filetype) |
| `nowait` | buffer map with `nowait=true` skips the prefix wait | invisible in a plain dump (`nvim_get_keymap` rows do have a `nowait` field, but the old dump script did not copy it). Example: claude-code terminal `<Esc>` |

Prefix overlaps must be computed per EFFECTIVE scope: global + one filetype at a time, per mode (n x o i c t s). A global key
`a` and a buffer key `ab` in python is an overlap only inside python. Ignore `<Plug>...` and `<SNR>...` lhs (plumbing,
never typed). Compare after normalising: `<space>`/`<Space>`/`<leader>`, `<M-x>`=`<A-x>`, `<C-x>`=`<c-x>` (`nvim_get_keymap`
returns `<C-A>` upper-case for control and a literal space for leader: normalise by `lhs:gsub(" ", "<Space>")`).

Typing speed matters: `gcs` then `s` typed fast is an exact match; the wait only happens after a PAUSE. A prefix overlap is
"harmless" when the short key does nothing useful (`s` is `<Nop>`) or when the long key is typed in one go.

### 1.2 Dumping ALL maps (global + buffer-local + lazy)

Use an isolated or normal nvim headless run:

1. Force-load every lazy plugin so lazy `keys` stubs are replaced by the real maps: `vim.cmd("Lazy! load all")` then
   `vim.wait(4000)` (or `require("lazy.core.loader").load(p, {cmd="verify"})` per plugin). `lazy.plugins()` lists them.
   Take TWO snapshots when it matters: right after startup (phase "pre": stubs, every stub must carry a desc) and after
   load-all (phase "post": real maps).
2. Global: `for _, mode in ipairs({"n","x","o","i","c","t","s","v","l"}) do vim.api.nvim_get_keymap(mode) end`.
   `v` rows include `x` and `s` maps: dedupe or use `x` + `s` only.
3. Buffer-local: open a sample file per filetype, `doautocmd FileType <ft>`, `vim.wait(300+)` (LSP attach is async: wait up to
   ~20 s or until `vim.lsp.get_clients({bufnr=b})` is initialised, otherwise `K gd <Space>rn <Space>ca` buffer maps are missing),
   then `vim.api.nvim_buf_get_keymap(buf, mode)`. Filetypes that carry custom maps here: markdown, lua, python, vim, json,
   cpp (and c), typst, tex, java, sh, help, qf, dashboard, plus nix/yaml/rust/go/haskell/php/r/javascript/typescript for the
   LSP and aerial maps.
4. Record per row: `mode, lhs, scope(global|buffer:<ft>), desc, rhs(first 60), callback?, sid, buffer, nowait`.
5. Source resolution: `m.sid > 0` -> `vim.fn.getscriptinfo({sid=m.sid})[1].name`; `m.callback` ->
   `debug.getinfo(m.callback,"S").source`; `sid < 0` = Lua map. With `vim.loader` enabled Lua modules often report
   `src = .../nvim/init.lua`, lazy `keys` stubs report `src = lua`, LSP callbacks report `vim/lsp/buf.lua`.
6. Optional definition-site log: wrap `vim.api.nvim_set_keymap`, `nvim_buf_set_keymap`, `nvim_del_keymap` (and `vim.keymap.set/del`)
   before loading to log every call with `debug.traceback`. A "duplicate" is real only if a set-over-set happens with no
   intervening delete. Use this to prove or refute a suspected exact duplicate.
7. which-key cross-check: `:checkhealth which-key` reports overlaps and duplicates (see 2.4). Expected result for a healthy config:
   "duplicate mappings: none", and overlaps only from the ignore list in 2.4.

### 1.3 What counts as OURS (heuristics, in decreasing reliability)

The dump flag `src in config dir` is UNRELIABLE (only ~109 of ~325 own rows were flagged). Use the union:
- `src` path inside `~/.config/nvim` or `~/dotfiles/general/general-nvim/.config/nvim`, OR
- the row has a non-empty `desc` and that exact desc string occurs verbatim in the config's `.lua`/`.vim` files and the src is not
  a builtin default/plugin runtime file, OR
- the lhs appears in a source scan of `lua/`, `after/`, `plugin/`, `ginit.vim` (strings like `"<leader>..."`).
Not ours (exempt from desc rules, never report as our clash): yanky `<Plug>(Yanky*)` (~170 rows), vim-sandwich `sa sd sdb sr srb`,
vim-matchup `% g% [% ]% z% a% i%`, vim-commentary `gc gcc gcu` (their desc-less versions replace our lazy stub descs after load),
targets.vim `a i A I @`, vim-scriptease `g! g= K(vim) zS`, unicode.vim (`<F4>` n/v, i `<C-X><C-G/Z/B>`, `<C-G><C-F>`), UltiSnips
(`<C-J>` i/s/x, `<C-Tab>`, select-mode `<C-R> <C-H> <Del> <BS>`), vim-fugitive (`y<C-G>`, c `<C-R><C-G>`), vim-eunuch i `<CR>`, nvim-autopairs
i `<CR>`, better-escape i `k`, vim-illuminate `<M-i>` x/o and `<A-n>/<A-p>`, markdown-preview `<Plug>MarkdownPreview*`,
vim-markdownfootnotes `<Plug>`s, vim-swap `<Plug>(swap-*)`, runtime ftplugin maps (python `[[ ]] [] ][ [m ]m [M ]M`, vim `[[ ]] [] ][ [" ]"`,
markdown `[[ ]]` x, markdown `gO`, go/rust/php runtime maps, sql ftplugin maps), nvim-tree defaults (`a d r x p <CR> o g? ...`),
bqf/quicker qf maps, diffview defaults (`<tab> [F ]F gf dx dX <leader>cO/cT/cB/cA ...`), dashboard-nvim `<CR>`, nvim-cmp internal
mapping tables, nui LSP menu keymap table, Neovim 0.12 builtins (`grn gra grr gri grt gO [d ]d <C-w>d gc gcc [q ]q [b ]b [a ]a [l ]l [<Space> ]<Space> <C-s>(i)`).

### 1.4 Limits of a dump (what it can NOT see; check these in source, never report them as missing)

- Runtime-only maps: nvim-gdb creates buffer-local maps ONLY during a debug session (`<Space>dv` = `key_eval`, and F4 F5 F8 F10 F11 F12).
  A dump will never show them; `<Space>dv` is unmapped globally and not a prefix of anything, so no clash is possible.
- Plugin buffers not in a normal dump: dashboard (`r L o d m u e q <CR>`; open with a real `:Dashboard`), nvim-tree (`<Tab>` ours + defaults),
  diffview views (`<Space>gC{a,b,o,t}`, `]C [C`; disabled defaults `<Space>co ct cb ca`), qf/bqf, DBUI, nui LSP menu,
  Claude Code terminal (`t <Esc>` buffer-local, `nowait`, created on TermEnter).
- Gated keys (exist only if a tool is on PATH, detection is `executable()` at ftplugin time or jdtls LspAttach, never env vars): vimtex
  maps and tex `<F9>`/`<Space>rf` (need `latex`, in a devShell), cpp `<F9>`/`<Space>rf` (need `clang++` or `g++`), python `<Space>f`
  (needs `black`, uv project: `uv`), typst `<Space>tw` (needs `typst`), the 18 Java `<Space>j*` (jdtls LspAttach, global fallbacks otherwise),
  nvim-gdb keys (disabled on macOS). To see them put fake binaries on PATH (`mkdir bin; printf '#!/bin/sh\n' > bin/latex; chmod +x`)
  and rerun; otherwise audit them from source (`after/ftplugin/*`, `plugin_specs.lua` vimtex init, lines with `autocmd FileType tex`).
- Lazily defined later: `<Space>gB` (lualine.lua at VeryLazy, not in the startup snapshot), fugitive maps (User InGitRepo), gitsigns maps
  (buffer-local on attach, only in git buffers), ufo/hlslens/hop stubs (replaced on first use), yanky `p P [y ]y` (VeryLazy).
- LSP maps (`K gd <Space>ca <Space>rn`) are recomputed on every LspAttach/LspDetach and depend on server capabilities; a buffer with no
  server shows only the global one-warning fallbacks (`<Space>ca`, `<Space>rn`) and the builtin `K`/`gd`.
- `nowait`: copy the field in the dump or you cannot tell if a prefix wait is avoided.
- `:checkhealth which-key` only sees maps loaded at that moment; run it after load-all.
- Terminal `<Esc>`: global `t <Esc>` = `<C-\><C-n>`; Claude Code buffers override it buffer-local.

---------------------------------------------------------------------------------------------------

## 2. Catalog of known false positives and documented intentional pairs

Everything below is INTENTIONAL and verified. Not a finding. Counts at last audit: 752 distinct (mode,lhs) post-load, ~1333 dump rows
with all filetypes, 0 unresolved clashes, 0 own maps without desc, 52 distinct prefix pairs (all documented), 11 exact-shadow groups.

### 2.1 Exact shadows (global or builtin key overridden in a buffer)

| mode | key | scope | why fine |
|---|---|---|---|
| n | `<Space>ca` | global fallback vs LSP buffer map (every filetype with a server) | global = ONE warning "no language server attached" (otherwise `<Space>c`+`a` would fall through to `l`+... and run random keys); buffer = real code action or ONE warning "no attached server supports it". Recomputed on LspAttach/LspDetach |
| n | `<Space>rn` | same pattern as `ca` | rename; same fallback design |
| n | `<Space>fm` | global (`vim.lsp.buf.format`) vs buffer lua (stylua) and markdown (prettier via stdin) | lua_ls formatting is disabled; formatters differ per filetype; lua also maps `<Space>f` to the same function (alias, same desc "Format file (stylua)") |
| n | `<Space>mf`, `<Space>mr` | global warning "only in markdown buffers" vs markdown buffer (`<Plug>AddVimFootnote`, `<Plug>ReturnFromFootnote`) | gated fallback |
| n | `<A-m>` / `<M-m>` | global warning "Markdown preview: only in markdown buffers" vs markdown buffer `MarkdownPreviewToggle` | an unmapped `<A-m>` acts as `<Esc>m`, so a fallback exists |
| n | `<Space>dp` | global warning "only in python buffers" vs python buffer `GdbStartPDB python -m pdb %` | unmapped it would fall through to `l`+`dp` = E99 |
| n | `<Space>rf` | global warning fallback (mappings.lua) vs buffer-local aliases in lua, vim, python, cpp, tex ("run file the editor's own way", same as `<F9>`) | NEW round 2; same global-vs-buffer pattern as `<Space>dp`. cpp and tex are PATH-gated so they are not in a plain dump |
| n | `<Space>j*` (18 keys) | global one-warning fallbacks "Java: jdtls not attached" vs buffer maps created on LspAttach of `jdtls` | gated; removed again on LspDetach of jdtls |
| n | `<Space>f` | buffer json (n+x `:JSONFormat`), python (black, or fallback warning), lua (stylua) | there is no global `<Space>f`; only per-filetype. NOT a shadow of fzf `<Space>ff...` (that is a prefix overlap, 2.2) |
| n | `<Space>tw` | typst buffer (`TypstWatch`, or one warning if no `typst`) | no global `<Space>tw`; `<Space>t` (aerial) is its prefix, see 2.2 |
| n | `K`, `gd` | LSP buffer maps vs builtin `K` (keywordprg) / `gd` | our map exists only if an attached server supports hover/definition; otherwise the buffer map is removed and the builtin works (e.g. .vim file with only typos_lsp) |
| n | `[t`, `]t` | aerial buffer maps (all buffers where aerial attaches, ~18 filetypes) vs builtin `:tprevious`/`:tnext` | we do not use tag stack navigation; documented in the user guide |
| n | `gO` | markdown runtime ftplugin vs builtin LSP `gO` document symbol | NOT ours (nvim runtime `ftplugin/markdown.lua`); no action |
| n | `L` | dashboard buffer (`L` = restore last session) vs our global `L` (`g_`) | dashboard only |
| n | `d e m o q r u` | dashboard buffer vs builtin operators/keys | dashboard buffer is nomodifiable; harmless. Dashboard buffer maps = `<CR>`, `e`, `q` real + `r L o d m u` |
| n | `<F9>` | per filetype: cpp, lua, python, vim, tex | each in its own buffer; not a duplicate |
| t | `<Esc>` | global `<C-\><C-n>` vs Claude Code terminal buffer (`<Esc>` passes through, `nowait`) | `<C-\><C-n>` still leaves terminal mode there |
| n | `<F4>` | unicode.vim global (`MakeDigraph`) vs nvim-gdb buffer-local `<F4>` (until) during a pdb session | informational, third-party |
| n | hlslens `* # n N` | lazy stubs in plugin_specs.lua (~154-157) vs hlslens.lua config | same descs; the lazy stub is deleted before config re-defines. Not a duplicate |
| n | hop `f`; commentary `gc`; `gcc` | lazy stub desc vs real map after load | 7 desc changes on load; commentary's real maps have no desc (third-party, accepted) |
| n | `<Esc>` | `fclose!` (n) vs `<C-\><C-n>` (t) | different modes |

Overrides of builtins by design (documented, never report): `;`=`:` (loses `;` repeat), `H`=`^`, `L`=`g_`, `Q`=`q`, `s`=`<Nop>`,
o-mode `s`=`<Esc>`, `J`/`gJ` (cursor kept, count honoured), `j k` (display lines, expr), `0 ^` (`g0 g^`), x `$`=`g_`, `<Up/Down/Left/Right>` (window moves),
`c C` (`"_` variants, n and x), `p P` (yanky, n,x), `n N * #` (hlslens), `f` (hop, n,x,o), `ga` (unicode info), `gs` (vim-swap),
`gx` (gx.nvim), `zr zm zR zM` (ufo counter), `+` and `@@` in markdown, `<Esc>` n (close float), `<Esc>` t, i `<C-A> <C-D> <C-E> <C-T> <C-U>`,
c `<C-A>`, `<A-j>/<A-k>` (move lines, n and x), `<leader>p/P` etc. `gb`/`gB` have no builtin.
Removed on purpose, so their ABSENCE is not a finding: `[[`/`]]` (LSP definition, removed), `cc`, `<Space>gy`, `<Space>o/O`, `\` (markdown line break),
`<Space>ct`, `<Space>is/ib/ab/ai/as`, `x p` in mappings.lua, vim-swap `g<`/`g>`, git-conflict maps, `<M-S-m>`, grammarous maps, unicode `<Space>un`.

### 2.2 Prefix overlaps (timeoutlen waits) that are accepted

| mode | short -> longer | scope | why fine |
|---|---|---|---|
| n | `<Space>q` -> `<Space>qb`, `<Space>qw` | global | `<Space>q` = `x` (save+quit window); accepted wait |
| n | `<Space>s` -> `<Space>sv` | global | `<Space>s` = nvim-tree toggle; accepted |
| n | `<Space>t` -> `<Space>tw` | typst buffer | `<Space>t` = aerial toggle |
| n | `<Space>f` -> `<Space>ff fg fh fr ft fb fm` | buffer json, lua, python only | buffer-local format key; accepted (which-key line ignored in checks.lua) |
| n | `<Space>r` -> `rn rr rf` | global | `<Space>r` is NOT itself mapped, no wait, no overlap |
| n | `^` -> `^^` | markdown buffer | `^` = `g^`; `^^` = insert footnote; `^` waits 500 ms in markdown. Accepted (pre-existing) |
| i | `^` and `@` (typed text) | markdown buffer | insert maps `^^` and `@@` make a single typed `^` or `@` wait 500 ms before it appears. No exact shorter map exists, so a pair-based scan does NOT find it: check insert maps whose lhs is a doubled character |
| n | `gc` -> `gcs gcr gcc gcu gcss gcrr` (x: `gc` -> `gcs gcr`) | global | commentary vs smart_comment (intended); which-key line ignored |
| n | `gcs` -> `gcss`, `gcr` -> `gcrr` | global (n only; x has no `gcss`, so x never waits) | intended: operator plus "current line" variant; `gcs{motion}` typed in one go is unaffected |
| n | `s` (`<Nop>`) -> `sa sd sr sdb srb` | global | `s` does nothing; the wait is invisible. sandwich owns the prefix by design |
| o | `s` (`<Esc>`) | global | cancels a pending operator (e.g. `gcs`, pause, `s`); no o-mode `s*` map exists, so instant |
| n | `sd` -> `sdb`, `sr` -> `srb` | global | sandwich's own |
| o,x | targets `a` -> `ai aS an a%` (+ markdown `ac`), `i` -> `ii iS in i%` (+ markdown `ic`) | global (+ markdown) | targets.vim owns `a`/`i` (getchar-driven expr maps). Typed fast it works; accepted |
| x | builtin `@` -> targets `@(targets)` | global | plumbing |
| n | `g!` -> `g!!`, `g=` -> `g==` | global, after scriptease loads | vim-scriptease own defaults, accepted noise (open decision: accept / delete / `<Nop>`) |
| n | `\h \H \d \D \x \t \T` | global | the `\` family has NO prefix relations among itself; `<Space>h` was REJECTED as a home for dashboard keys because gitsigns `<Space>hp/hb` make it a prefix |
| n | `<Space>d` family | global + python | `db dd de dE dp dt dw` and python `dc dn ds df dB du dv`: `dB` vs `db` are case-distinct, no key is a prefix of another |

Third-party-vs-third-party overlaps (19 pairs, no action): scriptease, commentary `gc/gcc/gcu`, sandwich `sd/sdb sr/srb`, targets x matchup (`a/a% i/i%`),
targets x mini.indentscope (`a/ai i/ii`), targets x builtin treesitter selection (`a/an i/in`, nvim 0.12 `an`/`in` override targets' next-object).

### 2.3 Other documented "looks wrong but is fine"

- `<Space>cb` global (blink cursor) vs diffview default `<Space>cb` (choose base): diffview defaults `co ct cb ca` are DISABLED (`false`) in lua/config/diffview.lua;
  our conflict keys are `<Space>gC{o,t,b,a}` inside diffview only. LSP `<Space>ca` therefore also works in diffview.
- `<Space>cu` (unicode completion swap) replaces unicode.vim's default `<Space>un`, which made `<Space>u` (undo tree) a prefix. Do not "restore" `<Space>un`.
- `<Space>gy`: gitlinker's default is deleted right after setup (`mappings=nil` does NOT disable it). `<Space>gl` is the only permalink key. Do not report a missing `gy`.
- `<Space>dE` appears once (prev ERROR). An old telescope duplicate was removed; a struck-through row in old notes is stale.
- `<Space>gb` is x-mode `:Git blame` (fugitive) while n-mode `gbd gbl gbn gbr` exist: different modes, not a prefix overlap. `<Space>gB` (capital, branch menu) is separate.
- `[c ]c` (gitsigns, lowercase) vs `[C ]C` (diffview conflict, uppercase, diffview views only).
- Leader `<Space>` + `<Space>` (`<leader><space>`, strip whitespace) is a leaf; no `<Space><Space>x` maps exist (the bogus dashboard maps were removed).
- Dashboard center items show hints like `[<Leader> f f]` as display text, not as maps. Only `e` and `q` carry a real `key`.
- `ic`/`ac` (markdown fenced code block objects, x and o) sit under targets `i`/`a` AND vimtex defines `ic ac id ad ie ae iP aP im am i$ a$` in tex buffers (only with latex on PATH). Keep markdown `ic/ac`; do not add `ie/ae`, `id/ad`, `im/am`, `iP`.
- sandwich query objects moved to `iS`/`aS` so builtin sentence objects `is`/`as` work. `vim.g.textobj_sandwich_no_default_key_mappings = 1` is set; targets keeps `ib/ab`. Do not re-add `is/as`.
- nvim-gdb: `vim.g.nvimgdb_disable_start_keymaps = true` (else it overwrites `<Space>dd/db/dp`); `key_eval` moved from `<F9>` to `<Space>dv` (it used to delete our buffer `<F9>` at session end).
- `<Space>u` = builtin undo tree (`packadd nvim.undotree`), not vim-mundo.
- `<Space>cc/cR/cV` are claude-code.nvim maps (plugin supplies desc "Claude Code: ..."); `<Space>ct` terminal toggle is disabled.
- `s` `<Nop>` and o `s` are set with `remap=true` so the plugin's later `<Plug>` handling still works.

### 2.4 which-key overlap ignore list (`ignore` list in `scripts/checks.lua`, matched with `string.find` on "<section> | <line>")

Source of the lines: `:checkhealth which-key`. A NEW overlap not matching one of these is a real finding. Healthy state: 15 warnings (13 known + 2 scriptease), 0 new.

| pattern | reason |
|---|---|
| `In mode \`n\`, <c> overlaps with <cc>:` | stale (`cc` map removed), harmless leftover |
| `In mode \`n\`, <<Space>f> overlaps with <<Space>f%a>` | buffer-local `<Space>f` (lua/python/json) vs fzf `ff fg ...`; accepted. Appears only in those buffers |
| `In mode \`n\`, <<Space>q> overlaps with <<Space>q%a>` | `<Space>q` vs `qb qw` |
| `In mode \`n\`, <<Space>s> overlaps with <<Space>sv>:` | nvim-tree toggle vs restart |
| `In mode \`n\`, <s[rd]> overlaps with <s[rd]b>:` | sandwich `sd/sdb`, `sr/srb` (own prefix pairs) |
| `In mode \`n\`, <g!> overlaps with <g!!>` | vim-scriptease own default (Q-pol-3, accepted noise) |
| `In mode \`n\`, <g=> overlaps with <g==>` | vim-scriptease own default |
| `In mode \`[nx]\`, <gc> overlaps with <gc` | commentary `gc` vs smart_comment `gcs gcr` (+ `gcc gcu`) |
| `In mode \`n\`, <gc([sr])> overlaps with <gc%1%1>:` | `gcs/gcss`, `gcr/gcrr` (intended, Q71) |
| `In mode \`x\`, <@> overlaps with <@%(targets%)>:` | builtin `@` vs targets plumbing |
| `In mode \`[xo]\`, <[ai]> overlaps with <[ai][%isancS]>` | targets `a/i` vs `ai ii an in a% i% ac ic aS iS`. The char class must contain `c` (markdown `ac/ic`) and `S`; order of lines varies per run |

Not reported by which-key: `s`/`sa` (`s` is `<Nop>`), `<Space>t`/`tw` and `^`/`^^` (buffer-specific, only if that buffer is the current one when the health buffer opens).
Related ignore list for checkhealth noise that is NOT keymaps (hg_cmd, `site/pack/hm`, GDB/LLDB/RR/BashDB backends, viu, snacks modules, `vim.validate` deprecation...): leave to the health audit.

---------------------------------------------------------------------------------------------------

## 3. The `desc` rule

Rule: every map WE define carries a non-empty `desc` (so which-key, `FzfLua keymaps` and the dashboard search show it). Third-party maps are exempt.
Verified state: 0 own maps without desc in a full dump (752 distinct maps, 222/222 lazy stubs with desc) and 0 in a source scan.

### 3.1 Dump check
Rows where `desc == ""` and "ours" (1.3) is true, `<Plug>` lhs excluded. Expect 0. Also check lazy stubs right after startup: all must have desc.
Desc quality: no empty-ish, `desc`, `TODO` text; duplicates are legitimate when same key in several modes, same key per buffer (`K gd <Space>ca <Space>rn`, aerial `[t ]t`),
or an intentional alias (lua `<Space>f` and `<Space>fm`, all `<F9>`/`<Space>rf` pairs). Cosmetic mixed casing is not a defect.

### 3.2 Source scan (finds maps a plain dump cannot see: gated, runtime, other filetypes)
Balanced-call scanner idea: for every file `lua/**/*.lua` (skip `tests/`), `after/**/*.lua`, `*.vim`, `ginit.vim`:
1. Find each occurrence of `vim.keymap.set(`, `keymap.set(` (aliases: `local keymap = vim.keymap` in mappings, fugitive, git-linker, hlslens, nvim-tree, nvim_hop, dadbod), `vim.api.nvim_set_keymap(`, `nvim_buf_set_keymap(` and of lazy `keys = {` entries.
2. Extract the full call by balanced parentheses (respect strings and `[[...]]` long strings, comments).
3. Parse the top-level options table (the last table argument; ignore tables inside `function` bodies) and test for `desc =` at depth 1.
4. Map lines inside `vim.cmd`/VimL strings: `lua vim.keymap.set(...)` in `after/ftplugin/*.vim`, and `v:lua.vim.keymap.set(` in cpp.vim (desc is on the NEXT line), and the vimtex `autocmd FileType tex lua for ...` string in plugin_specs.lua. Scan multi-line calls across lines.
5. Also grep for Vimscript maps (`nnoremap`, `inoremap`, `nmap`, `map`...): they cannot carry a desc. Expected count in this config: 0 (ginit.vim was converted or is GUI only).
Counts at last audit: ~154 `keymap.set` calls, 4 gitsigns wrapper calls, 16 lazy `keys` entries, 14 VimL-embedded Lua maps, all with desc.

Known FALSE POSITIVES of the scanner (do not report):
- lua/config/gitsigns.lua line ~16: the local wrapper `map(mode, l, r, opts)` contains `vim.keymap.set(mode, l, r, opts)` with no literal desc. The 4 real calls (`]c [c <Space>hp <Space>hb`) all pass desc.
- lua/config/nvim-tree.lua line ~30: `<Tab>` passes `opts('Open & Keep Focus')`; the `opts()` helper returns `{desc = 'nvim-tree: ' .. desc, ...}`.
- diffview `keymaps` entries `{ "n", "<leader>co", false }`: these DISABLE a default, not define a map.
- nvim-cmp `cmp.mapping` tables (lua/config/nvim-cmp.lua), nui LSP menu `keymap` table (lsp_utils.lua), dashboard `key = "r"` entries (dashboard-nvim.lua, plugin builds the maps; label desc is "Dashboard-action: ..."), claude-code `keymaps` table (plugin supplies desc), devdocs `mappings.open_in_browser = ""`, treesj/git-linker maps disabled: plugin option tables, not `vim.keymap` calls.
- `iabbrev` (plugin/abbrev.vim), `cabbrev` (autoload/utils.vim, live-command.lua `keymap.set("ca", ...)` has desc): abbreviations are not keymaps.
- ginit.vim (GUI only, never loaded in a TUI): `<C-6>` n only; `<S-Insert>` was removed or is GUI-only.
- Dead files that once held maps (blink-cmp.lua, treesitter-textobjects.lua, iron.lua) were deleted; if a scan finds maps there, they are NEW.

Fixes when a real gap exists: VimL `:map` cannot carry desc; re-create through `lua vim.keymap.set` with identical lhs/rhs/mode/buffer/silent/remap. A `<Plug>` rhs needs `remap = true`
(`vim.keymap.set` sets it automatically for `<Plug>` only if rhs starts with `<Plug>`; pass explicitly in VimL-embedded calls). Third-party maps cannot get a real desc without re-mapping to the same `<Plug>` with `remap=true` (not
recommended for expr maps: targets `a/i`, UltiSnips `<C-J>`, better-escape, eunuch, fugitive `<C-R><C-G>`, matchup o-mode `<Ignore>` rhs); a which-key `add{desc=}` label does NOT change `maparg().desc`.

---------------------------------------------------------------------------------------------------

## 4. Our key families (reference to avoid new clashes)

`<Space>` = `<leader>`. Before adding a key: check it is not a leaf and not a prefix/extension of anything below in the same mode and scope.
Case matters: `dB` and `db` are different keys. Mode n unless stated. G = global, B = buffer-local.

### 4.1 `<Space>` + one letter (leaf or prefix)

| key | meaning | notes |
|---|---|---|
| `<Space><Space>` | strip trailing whitespace (warns, does nothing in markdown) | leaf |
| `<Space>-` / `<Space>\|` | `:split` / `:vsplit` | leaves |
| `<Space>K` | ufo: peek folded lines | |
| `<Space>P` / `p` | paste above / below current line | |
| `<Space>Q` | force quit (confirm) | |
| `<Space>q` | `x` save+quit window | PREFIX of `qb qw` |
| `<Space>s` | nvim-tree toggle | PREFIX of `sv` |
| `<Space>t` | aerial toggle | PREFIX of typst `tw` |
| `<Space>u` | builtin undo tree (left, 30 cols) | leaf |
| `<Space>v` | reselect last pasted area | |
| `<Space>w` | `update` | |
| `<Space>y` | `%yank` | |
| `<Space>f` | B lua/python/json: format | PREFIX of `ff fg fh fr ft fb fm` in those buffers |
| `<Space>x` | free (grammarous removed) | |
| `<Space>o` / `O` | free (blank-line maps removed; use `[<Space>`/`]<Space>`) | |
| `<Space>1-9`, `a`, `e`(prefix), `k`, `l`, `n`, `z`, `A`, `B`, `C`, `E`, `F`, `G`, `H`, `I`, `J`, `L`, `M`, `N`, `R`, `S`, `T`, `U`, `V`, `W`, `X`, `Y`, `Z` | free as the FIRST key (see families below for taken second keys) | `h` is a prefix (gitsigns), `i` is a prefix (text objects), `m` prefix, `e` prefix |

### 4.2 Families (second and third letters)

| prefix | taken | free (examples) |
|---|---|---|
| `<Space>c` (code/cursor/claude) | `ca` (LSP code action G fallback+B), `cb` (blink cursor), `cc` (claude-code), `cd` (lcd), `cl` (cursor column), `cR` (claude --continue), `cu` (unicode swap), `cV` (claude --verbose), `cz` (spell) | `ce cf cg ch ci cj ck cm cn cp cq cr cs ct`(ct removed, free but avoid), `cv cw cx cy`, `cA cB cC...`. diffview defaults `co ct cb ca cO cT cB cA` are inside diffview only |
| `<Space>d` (diagnostics/debug) | G: `db` (buffer diags telescope), `dd` (float), `de` (next error), `dE` (prev error), `dp` (pdb fallback/B python), `dt` (toggle diagnostics), `dw` (Trouble). B python: `dc dn ds df dB du`, `dp`; nvim-gdb runtime `dv` | `da dg dh di dj dk dl dm do dq dr dx dy dz`, `dA dC dD dF...` (avoid `dD`: capital D is the dadbod prefix) |
| `<Space>D` (database) | `Da Df Du` (dadbod UI add/find/toggle), `Dt Do Dc` (dbee toggle/open/close) | `Db Dd De Dg Dh ...` |
| `<Space>e` | `ev` (open init.lua) | `ee ef ...` |
| `<Space>f` (fzf-lua, G) | `fb ff fg fh fm fr ft` (fm = format; B lua/markdown override) | `fa fc fd fe fi fj fk fl fn fo fp fq fs fu fv fw fx fy fz` (but all are 2nd-level under a `<Space>f` that is also a leaf in lua/python/json: wait) |
| `<Space>g` (git/glance) | `ga` (add all), `gA` (amend), `gb`(x blame; prefix of n `gbd gbl gbn gbr`), `gB` (branch menu), `gc` (commit), `gd gi gr` (glance def/impl/refs; written lowercase `<space>gd` in glance.lua, so grep case-insensitively), `gD` (DiffviewOpen), `gf` (fetch), `gl` (permalink n,x), `gL` (file log), `gm` (merge cmdline), `gn` (Neogit), `gpl gpu`, `gR` (rebase cmdline), `gs`, `gu` (unstage file), `gv` (Gvdiffsplit), `gw`, `gx` (discard file, confirm), `gz gZ` (stash, pop), `gC{a,b,o,t}` (diffview conflict, B diffview) | `ge gg gh gj gk go gq gt gy`, `gE gF...` |
| `<Space>h` | gitsigns B (git-tracked buffers): `hb` (blame line), `hp` (preview hunk), `hs` (stage hunk, n+x), `hr` (reset hunk, n+x, confirm), `hu` (unstage last hunk), `hS` (stage buffer), `hR` (reset buffer, confirm), `hd` (diff vs index), `ht` (toggle deleted) | `ha hc he hf hg hh hi hj hk hl hm hn ho hq hv hw hx hy hz` |
| `<Space>i` (text objects x,o) | `iB` (buffer), `iu` (URL) | other letters free in x/o |
| `<Space>j` (Java, gated) | `jbb jbc` build, `jrr jrs jrl jrp` runner, `jtc jtC jtm jtM jtr` test, `jev jeo jec jem jef` extract, `jd` (DAP config), `jj` (change runtime); which-key groups `j jb jr jt je` (lua/config/which-key.lua) | `ja jg jh ji jk jl jm jn jo jp jq js ju jv jw jx jy jz`, and `jbX jrX jtX jeX` other letters |
| `<Space>m` (markdown) | `mb` (hard line break n op + x), `mf` (footnote, global fallback), `mr` (return from footnote) | `ma mc md me mg mh mi mj mk ml mm mn mo mp mq ms mt mu mv mw mx my mz` |
| `<Space>r` (run/rename) | `rf` (run file the editor's way, G fallback + B lua/vim/python/cpp/tex), `rn` (LSP rename), `rr` (run file by filetype, vsplit terminal) | `ra rb rc rd re rg rh ri rj rk rl rm ro rp rq rs rt ru rv rw rx ry rz` |
| `<Space>s` | leaf (nvim-tree); `sv` (restart nvim) | any other `s?` extends the nvim-tree wait |
| `<Space>q` | leaf; `qb` (buffer diag to qf), `qw` (all diag to qf) | |
| `<Space>t` | leaf (aerial); B typst `tw` | |
| `<Space>b` | `bp` (bufferline pick) | `bb bc bd bn ...` |

### 4.3 Other families

| prefix | taken | notes |
|---|---|---|
| `\` (G, no localleader) | `\d` (delete buffer, keep window), `\D` (delete other buffers, keeps unsaved), `\h` (dashboard open), `\H` (dashboard close/resume), `\t` (tabclose), `\T` (tabonly), `\x` (close loclist+quickfix) | free: `\a \b \c \e \f \g \i \j \k \l \m \n \o \p \q \r \s \u \v \w \y \z`. No prefix relations among the family; vimtex `\ll` etc. are tex-buffer only (needs localleader default `\`) |
| `g` | ours: `gb gB gJ gS gcs gcr gcss gcrr ga(unicode) gs(swap) gx gd(LSP B)`; plugin: `gc gcc gcu g% g! g= gO`; nvim 0.12 builtins `gra grn grr gri grt` | `gc` is a prefix (gcs gcr gcc gcu gcss gcrr); `g!`/`g=` scriptease; `g<` builtin restored |
| `[` `]` | ours: `[t ]t` (aerial B), `[c ]c` (gitsigns B), `[C ]C` (diffview B), `[y ]y` (yanky), `[i ]i` (indentscope), `[d ]d` (builtin, ltex/LSP diag), `[% ]%` (matchup) | builtin `[q ]q [b ]b [a ]a [l ]l [<Space> ]<Space>`; `[[ ]]` are runtime (markdown/python/vim) |
| `z` | `zr zm zR zM` (ufo counter), `z%` (matchup), `zS` (scriptease) | |
| `<A-x>` / `<M-x>` | n: `<A-j>`, `<A-k>` (move lines, n+x), `<A-m>` (markdown preview B), `<A-n>`, `<A-p>` (illuminate); i: `<A-;>` (append `;`); x,o: `<A-i>` (illuminate) | free: other `<A-letter>` |
| insert `<C-x>` | `<C-A>` Home, `<C-D>` Del, `<C-E>` End, `<C-t>` toggle case of word's first letter, `<C-u>` upper-case word, `<C-j>`/`<C-k>` UltiSnips, `<C-f>` cmp docs, `<C-n>/<C-p>/<C-y>` cmp, `<C-X><C-G/Z/B>` unicode, `<C-G><C-F>` unicode | free: `<C-b>`, `<C-q>` (terminal/driver conflicts possible), etc. |
| insert punctuation | `! , . : ; ?` = char + `<C-g>u` (undo break); `<CR>` cmp confirm(select=false); `<Tab>` cmp; `<Esc>` cmp close | |
| insert markdown | `^^` (footnote), `@@` (return from footnote) | cause the typed-text waits in 2.2 |
| n single keys ours | `j k 0 ^ H L J C c ; Q <Esc> + (md) f(hop) n N * # p P s(nop)` | |
| x/o text objects | `iS aS` (sandwich query), `ii ai` (indentscope), `<A-i>` (illuminate), markdown `ic ac`, `<Space>iB`, `<Space>iu`, targets `a i A I` owners, nvim `in an`, matchup `i% a%` | free letters after `i`/`a`: `r z x g y` and uppercase `C D E F G H J K L M N O P Q R T U V X Y Z` (avoid `ie ae id ad im am iP aP` vimtex, `iq aq` targets any-quote) |
| `<F9>` and other F keys | see section 5 | |
| `ga`/`<Space>cu` | unicode | |
| `<Space>cc` etc. | claude-code | |

---------------------------------------------------------------------------------------------------

## 5. The keyboard constraint: no function keys, Insert, Page keys, numpad

The user's keyboard has no F-keys, Insert, PageUp/PageDown or numpad. Rules for the audit:

1. Every map on `<F1>..<F12>`, `<S-F*>`, `<C-F*>`, `<Insert>`, `<S-Insert>`, `<PageUp>`, `<PageDown>`, `<k0>..<k9>`, `<kEnter>` must have a leader or Ctrl/Alt alternative that does the same.
   Scan: `grep -rnE '<(S-|C-|M-|A-)?(F[0-9]+|Insert|PageUp|PageDown|Home|End|k[0-9A-Za-z]+)>'` over `lua/ after/ plugin/ ginit.vim` and the dump. (`<Home>`/`<End>`/`<DEL>` as RHS in insert maps `<C-A>`, `<C-E>`, `<C-D>` are fine: they are rhs only; check them only if used as lhs.)
2. Pairs in place (all with desc):
   - `<F9>` = `<Space>rf` (run file the editor's way): buffer lua (`luafile %`), vim (`source %`), python (`AsyncRun python -u %`, `uv run` in a uv project), cpp (compile+run, gated on `clang++`/`g++`), tex (`<Plug>(vimtex-compile)`, gated on `latex`). Global `<Space>rf` is the one-warning fallback. Lua/vim/python are Lua loops over `{"<F9>", "<leader>rf"}`; cpp.vim uses a VimL loop with `v:lua.vim.keymap.set`; tex is the `autocmd FileType tex lua for ...` string in plugin_specs.lua's vimtex init. A new filetype run key MUST be added under both keys.
   - nvim-gdb session keys: `<F5>` continue = `<Space>dc`, `<F10>` next = `<Space>dn`, `<F11>` step = `<Space>ds`, `<F12>` finish = `<Space>df`, `<F8>` breakpoint = `<Space>dB`, `<F4>` until = `<Space>du`, eval = `<Space>dv` (nvim-gdb `key_eval` override, replaces `<F9>`). These are python-buffer maps with desc "pdb: ...", each warns "pdb: no debug session here (start one with <Space>dp)" outside a session.
   - GUI `<S-Insert>` (ginit.vim) is replaced by `<Ctrl-r>` + `+`; page scroll by `<C-d>`/`<C-u>`; unicode `<F4>` (MakeDigraph) by `<C-k>` + two letters (builtin digraphs).
3. Documented EXCEPTIONS (third-party, no alternative set; do not report):
   - vimtex defaults in tex buffers: `<F6>` (surround with environment), `<F7>` (create command from word, n and i), `<F8>` (add `\left`/`\right`). vimtex is only loaded with `latex` on PATH.
   - nvim-gdb's own `<F4> <F5> <F8> <F10> <F11> <F12>` buffer-local keys during a session (they keep working; the `<Space>d` keys are the alternatives).
   - unicode.vim `<F4>` (n, v) MakeDigraph (global, third-party; `<C-k>` is the alternative). nvim-gdb's `<F4>` shadows it during a pdb session: informational.
   - ginit.vim `<S-Insert>` (i, c) and `<C-6>` (n): GUI-only file, never loaded in a TUI.
4. A new F-key finding is real only if the map is OURS (1.3) and has no leader/Ctrl twin. A third-party F-key that is not in the list above is a finding for the report ("no alternative", severity low), not a defect in our code.
5. When the user guide documents a key it must show the non-F form (`<Space>rf` next to `<F9>`); the guide says the only F keys left are vimtex `<F6> <F7> <F8>`.
