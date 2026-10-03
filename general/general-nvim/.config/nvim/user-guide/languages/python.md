<!-- chapter: Python -->
[Back to the guide index](../README.md)

# 79. Python (pyright, ruff, black, uv, running and debugging)

This section is one walk-through for everything Python in your config: what starts by itself, how to run, format and debug a file, how virtual environments are detected, and what to check when something does not work. Deeper background on the shared parts lives in the sections named in "Related sections" at the end.

## What You Get

| Feature | What it does | Needs |
| --- | --- | --- |
| **pyright** (language server) | Type checking, import resolution, hover (`K`), go to definition (`gd`), rename (`<Space>rn`), references. Mode is `standard`, whole workspace is checked. Its own import sorting is turned off (ruff does that) | `pyright-langserver` on PATH (installed globally by `neovim.nix`, also in the python devShell) |
| **ruff** (language server, `ruff server`) | Fast linting (diagnostics), quick fixes and "organise imports" through `<Space>ca`. It is the server that offers formatting for `<Space>fm` | `ruff` on PATH (python and jupyter devShells; NOT global) |
| **black** (formatter) | `<Space>f` formats the file; after every save a background check warns when the file is not formatted | `black` on PATH (python devShell), or a uv project that has black (see Running) |
| **typos_lsp** | Spell checker for identifiers and comments, attaches to every file type (also Python) | `typos-lsp` on PATH (installed globally by `neovim.nix`) |
| **tree-sitter** | Syntax highlighting (the `python` parser) | Nothing on Nix systems (parsers come from the nix store) |
| **Snippets** | `print`, `impa`, `main`, `sol` (see Snippets below) | Nothing |
| **uv awareness** | In a project with `uv.lock` and no active virtual environment, `<Space>rf` / `<F9>` and `<Space>f` go through `uv run` | `uv` on PATH (it is: `/run/current-system/sw/bin/uv`, tested) |
| **Statusline label** | Shows the active environment as `name (venv)` or `name (conda)` in Python buffers | An activated environment |
| **Format check** | After saving, `black --check` runs in the background and warns `<file>: file is not formatted (black)` | `black` on PATH, otherwise silent |
| **Run** | `<Space>rf` / `<F9>` (output in the quickfix window) and `<Space>rr` (output in a terminal split) | `python` / `python3` on PATH |
| **Debug** | `<Space>dp` starts `python -m pdb` inside nvim-gdb | Linux or Windows |
| **vim-illuminate** | Other uses of the word under the cursor are highlighted (Python is in its file type list) | Nothing |
| **aerial** | Symbol outline of classes, functions and methods (`<Space>t`) | Nothing |
| **Indentation** | 4 spaces, no wrapping, `colorcolumn` marker at 88 | Nothing |

## Quick Start

1. Start nvim **inside the Python devShell** (a project folder with `.envrc` containing `use_dev_env python`, see "Devshell and Tools"). Outside it, only pyright and typos_lsp exist.
2. Open a file: `nvim hello.py`. Wait a second or two. `:LspAttached` lists the running servers; tested in the python devShell: `pyright`, `ruff`, `typos_lsp`. The statusline shows `pyright (+2)` (the first server and two more).
3. Type a small program, save with `:w`, then run it with `<Space>rf` (or `<F9>`). A 6-line quickfix window opens at the bottom and shows the output.
4. Run it again as a full terminal with `<Space>rr`. A terminal split opens on the LEFT of the code.
5. Format with `<Space>f` (black). The file on disk is rewritten and the buffer reloads (`File changed on disk. Buffer reloaded!`).
6. Debug with `<Space>dp`. The code gets a `▶` marker and a pdb pane opens below it. Step with `<Space>dn` (or `<F10>`), quit with `:GdbDebugStop`. (`<F9>` and `<Space>rf` keep working afterwards; tested.)

## Why Each Tool Exists

| Tool | Why it is in your setup | How it works |
| --- | --- | --- |
| pyright | Python does not check types by itself. Pyright finds wrong argument types, missing imports and typos in attribute names before you run the file | A language server (`pyright-langserver --stdio`). Neovim starts it when you open a `.py` file and it answers questions: errors, hover, definition, rename. Installed globally, so it also works outside a devShell |
| ruff | Fast linter (unused imports, undefined names, style problems) with automatic fixes and import sorting | `ruff server` is a second language server in the same buffer. Its diagnostics appear next to pyright's, and `<Space>ca` lists its fixes |
| black | One fixed code style, so you never decide about spaces or quotes | A command-line formatter. `<Space>f` runs it on the file, and a background check runs after each save |
| uv | Fast Python project and package manager. Projects managed by uv have a `uv.lock` file | The config checks for `uv.lock` and then runs `<Space>rf` / `<F9>` and `<Space>f` through `uv run`, so they use the project's own environment |
| venv / conda label | Tells you which environment nvim (and so pyright) was started with | Reads `$VIRTUAL_ENV` / `$CONDA_DEFAULT_ENV` |
| direnv + devShell | Gives each project its own tools without installing them globally | `.envrc` with `use_dev_env python` loads the nix devShell; start nvim from that folder |
| nvim-gdb | Step through a script with pdb (Python's built-in debugger) with the current line marked in your code | Starts `python -m pdb file.py` in a terminal pane and talks to it |
| AsyncRun | Run a script without leaving the editor and read the output in the quickfix window | `<Space>rf` / `<F9>` runs a shell command as a background job and streams its output into quickfix |
| typos_lsp | Catches misspelt words inside names and comments | A language server for every file type |
| tree-sitter, aerial, illuminate, treesj, ufo | General tools that also work for Python (highlighting, outline, word highlight, split/join, folding) | See the sections in "Related Sections" |

Python-specific configuration lives in only a few places:

| File | What it holds |
| --- | --- |
| `after/ftplugin/python.lua` | indentation, no wrapping, `<Space>rf` / `<F9>`, `<Space>f`, `<Space>dp` |
| `after/lsp/pyright.lua`, `after/lsp/ruff.lua` | server settings |
| `lua/config/lsp.lua` | which servers exist and when they are enabled |
| `my_snippets/python.snippets` | snippets |
| `lua/custom-autocmd.lua` | the after-save format check (`black --check`) |
| `lua/options.lua` | `colorcolumn` 88 for Python |

## Devshell and Tools

Python tools are not installed globally except two. Open nvim in a devShell to get the rest.

| Tool | Global (`neovim.nix`) | python devShell | jupyter devShell |
| --- | --- | --- | --- |
| `pyright` | yes | yes | no (uses the global one) |
| `typos-lsp` | yes | no (uses the global one) | no (uses the global one) |
| `ruff` | no | yes | yes |
| `black` | no | yes | no |
| `uv` | yes, system-wide (`which uv` shows `/run/current-system/sw/bin/uv`; `python3` is also on the system PATH) | not added | not added |
| `python` / `python3` | system `python3` exists | yes (version depends on the variant) | python 3.13 |

Templates live in `~/nix/templates/krit/dev-environments/language-specific/`:

| Template | What it gives you |
| --- | --- |
| `python` | Python, black, flake8, isort, pip, matplotlib, pylint, setuptools, numpy, pyright, ruff, and `venvShellHook` which creates `.venv` in the project folder (`venvDir = ".venv"`). It warns when `.venv` was built with a different Python version than the shell (delete `.venv` and reload) |
| `jupyter` | poetry, Python 3.13, ruff, ipykernel, pip, `venvShellHook` (also `.venv`). No black, no pyright of its own |

Variants of the `python` template (flake outputs): `default` = Python 3.15, `py-stable` = 3.13, `py-lts` = 3.12, `py311` = 3.11.

How direnv picks one: the `direnv.nix` helper defines `use_dev_env() { use flake <dev-environments>/language-specific/$1 }`. So the `.envrc` line decides the variant:

| `.envrc` content | Result |
| --- | --- |
| `use_dev_env python` | `python` template, default output (latest Python) |
| `use_dev_env "python#py-lts"` | same template, output named after `#` |
| `use_dev_env "python#py-stable"` | same template, output `py-stable` |

Your folders in `~/github-repos/personal/developing-projects/python-projects/`: `python-latest` (`use_dev_env python`), `python-lts` (`use_dev_env "python#py-lts"`), `python-stable` (`use_dev_env "python#py-stable"`). After a new or changed `.envrc` run `direnv allow` once. Then start nvim from that folder so nvim inherits the environment.

**When a tool is missing** the config does not complain:

| Tool missing | What happens |
| --- | --- |
| `pyright` or `ruff` | That server is silently not enabled (no warning when opening the file). `:LspStart pyright` or `:LspStart ruff` names the missing program |
| `black` | `<Space>f` shows ONE warning: `Python: black not found on PATH (open nvim inside the python devShell)`. The after-save format check stays silent |
| `uv` (in a uv project) | Not a real case here (uv is installed system-wide). If it were missing, `<Space>f` would show the same black warning and `<Space>rf` / `<F9>` would fail inside the quickfix window |
| `python` / `python3` | `<Space>rf` / `<F9>` shows the shell error in the quickfix window. `<Space>rr` has no PATH check for Python: tested with an empty PATH, the terminal shows `bash: line 1: python3: command not found` and no nvim warning appears |
| `typos-lsp` | Silent |


## Running Code

Two ways, for different purposes.

| Key | Command it runs | Where output goes |
| --- | --- | --- |
| `<Space>rf` / `<F9>` | `python -u "<file>"`, or `uv run python -u "<file>"` in a uv project (see below) | Quickfix window, 6 lines tall at the bottom (AsyncRun opens it by itself). The last line says `[Finished in N seconds with code C]` |
| `<Space>rr` | `python3 <file>` (shell-escaped) | A new terminal in a vertical split on the LEFT of your code, titled like `term://...:python3 'file.py'`; Claude's panel stays on the right. When the program ends it shows `[Process exited 0]` |

Facts that differ between the two (all tested):

- `<Space>rf` and `<F9>` are **buffer-local** and the same command: it exists only in Python buffers. `-u` means unbuffered, so `print` output appears while the program runs.
- `<Space>rr` is global and detects the file type. For Python it is always plain `python3 <file>`: **it never uses `uv run`, and has no `-u`**. In a uv project without an active environment use `<Space>rf`.
- Both run the file as saved on disk. Save first (`:w`).
- `<Space>rr` on an unnamed buffer shows one warning (`save the file first`).
- Paths with spaces or special characters are safe in `<Space>rr` (the name is shell-escaped). `<Space>rf` / `<F9>` wraps the name in double quotes, so a double quote or `$` inside a file name would break it.

Example to try both. Save as `hello.py`:

```python
import sys, os

def add(a: int, b: int) -> int:
    return a + b

print(add(1, 2))
print(sys.version_info[:2], os.environ.get("VIRTUAL_ENV"), sys.executable)
```

Press `<Space>rf` (or `<F9>`). Expect in the quickfix window: `3`, then the Python version, the venv path (or `None`) and the interpreter path, then `[Finished in 0 seconds with code 0]`. A program that crashes ends with `code 1` and the traceback, as in the tested example `add(1, "two")`:

```
TypeError: unsupported operand type(s) for +: 'int' and 'str'
[Finished in 0 seconds with code 1]
```

### When `<Space>rf` / `<F9>` uses uv

The choice is made when the Python file is opened (`after/ftplugin/python.lua`), from the project root (nearest `.git` or `pyproject.toml`):

```lua
local py_env = utils.get_py_env()
local py_cmd = (py_env == "uv") and "uv run python" or "python"
vim.keymap.set("n", "<F9>", string.format(':<C-U>AsyncRun %s -u "%%"<CR>', py_cmd), ...)
```

| Situation | `<Space>rf` / `<F9>` runs | `<Space>f` runs |
| --- | --- | --- |
| No project root (no `.git`, no `pyproject.toml`) | `python -u` | `black` |
| An environment is active (`$VIRTUAL_ENV` or `$CONDA_DEFAULT_ENV` set) | `python -u` | `black` |
| `uv.lock` in the project root and no active environment | `uv run python -u` (tested: quickfix title `:AsyncRun uv run python -u "hello.py"`) | `uv run black` |
| Project root without `uv.lock`, no active environment | `python -u` | `black` |

Tested: in a folder with `pyproject.toml` + `uv.lock` and a plain shell, the quickfix title showed `uv run python -u`; inside the python devShell (where `$VIRTUAL_ENV` is the project's `.venv`) it showed plain `python -u`.

Because the check runs at file open, activate the environment (or create `uv.lock`) before opening the file, or reload with `:e!`.

Create a uv test project like this:

```sh
mkdir uvp && cd uvp
git init
uv init --bare        # creates pyproject.toml
uv lock               # creates uv.lock
nvim hello.py
```

### Stopping a running program

| Started with | How to stop |
| --- | --- |
| `<Space>rf` / `<F9>` | `:AsyncStop` (tested with a 60-second `time.sleep`: `ps` showed `python -u slow.py` before and nothing after; stronger kill: `:AsyncStop!`) |
| `<Space>rr` | In the terminal press `<Ctrl-c>`, or delete the terminal buffer with `:bd!` (tested: `ps` showed `python3 slow.py` before `:bd!` and nothing after) |

Warning, tested earlier: `<Space>q` on a terminal window only **closes the window**; the running program keeps running hidden. Stop it first. See section 55 and section 8 for terminal navigation.

## Formatting and Linting

| Key / command | What it does |
| --- | --- |
| `<Space>f` (Python buffers) | Runs `black` on the file **on disk** (`:silent !black %`); in a uv project `uv run black %`. Nvim then reloads the buffer and shows `File changed on disk. Buffer reloaded!` (tested) |
| `<Space>fm` | LSP format, async, **in the buffer** (not saved). In Python the formatter is ruff's server, so it is `ruff format`, not black (tested: the buffer became modified, `●` in the tab, and `{"a":1,\n "b":2}` became `{"a": 1, "b": 2}`) |

Try it. Save as `messy.py`:

```python
import os, sys
def f( a,b ):
  return a+b
print(f(1,2))
```

Press `:w`. Expect the warning `messy.py: file is not formatted (black)`. Press `<Space>f`. Expect the file to become:

```python
import os, sys


def f(a, b):
    return a + b


print(f(1, 2))
```

Save again: no warning. (`os` and `sys` stay; ruff still shows `E401` and `F401` hints. See "Code actions from ruff".)

Key points:

- Both formatters give almost the same result on normal code, but they are different programs. `<Space>f` (black) matches the after-save check; `<Space>fm` does not need black installed.
- Nothing formats automatically on save.
- **Format check after save:** every `:w` of a Python file runs `black --check --quiet <file>` in the background. If the file would change you get `<file>: file is not formatted (black)`. If black fails (for example a syntax error) you get `<file>: black could not check the file (syntax error?)` plus the first error line. Nothing is changed. If `black` is not on PATH the check is silent. It uses plain `black`, even in uv projects.
- **Without black:** tested outside the devShell, `<Space>f` shows ONE warning `Python: black not found on PATH (open nvim inside the python devShell)`, and saving shows nothing. In a uv project (uv is on PATH) the key stays silent and changes nothing when the project has no black: the command fails inside `:silent`. When the project has black (tested with `uv add --dev black` in a scratch project), `<Space>f` runs `uv run black` and reformats the file, with the same `Buffer reloaded!` message.
- **Line length:** black's default is 88, and the `colorcolumn` marker for Python is also 88 (default for other files: 100). A line touching the marker is too long for black. Black does not wrap long strings or comments.
- **Indentation:** `tabstop`, `softtabstop`, `shiftwidth` = 4, `expandtab` on. No wrapping (`wrap` off, `sidescroll` 5, `sidescrolloff` 2).

### Code actions from ruff

Put the cursor on the first line of `messy.py` and press `<Space>ca`. Tested result, a list of four ruff actions:

```
1. Ruff (E401): Split imports [ruff]
2. Ruff (E401): Disable for this line [ruff]
3. Ruff: Fix all auto-fixable problems [ruff]
4. Ruff: Organize imports [ruff]
```

Pick a number with `<CR>`. "Organize imports" sorts and groups the imports (pyright's own version is disabled in `after/lsp/pyright.lua` so there is no conflict). "Fix all" applies every automatic fix, such as removing unused imports.

### Linting from the command line (`:compiler ruff`)

The ftplugin sets `vim.g.ruff_makeprg_params = ""` so that Neovim's built-in ruff compiler plugin works without `--preview`. Tested:

```vim
:compiler ruff
:make %
```

runs `ruff check --output-format=concise nav.py` and puts every finding in the quickfix list (then `:copen`, `]q`, `[q`; see section 26). Needs `ruff` on PATH (devShell).

## LSP Keys

Active in a Python buffer once pyright (and ruff) have attached. Maps are set per buffer and show ONE warning instead of falling through when no server supports the action.

| Key | What it does | Server |
| --- | --- | --- |
| `gd` | Go to definition (one result jumps, several open the location list) | pyright |
| `K` | Hover: type and docstring in a floating window (plain text format) | pyright |
| `<Space>rn` | Rename symbol everywhere | pyright |
| `<Space>ca` | Code action: quick fixes, organise imports, fix all | ruff (and pyright) |
| `<Space>gd` / `<Space>gr` / `<Space>gi` | Glance popups: definitions / references / implementations | pyright |
| `<Space>de` / `<Space>dE` | Next / previous error | diagnostics from pyright and ruff |
| `<Space>dd` | Show diagnostic detail under the cursor | any |
| `]d` / `[d` | Next / previous diagnostic (`]D` / `[D` last / first) | any |
| `<Space>db` / `<Space>dw` | Buffer / whole workspace diagnostics list | any |
| `<Space>dt` | Toggle diagnostics on and off | any |
| `<Space>qb` / `<Space>qw` | Put buffer / all diagnostics in the quickfix list | any |
| `<Ctrl-w>d` | Diagnostics under the cursor in a float | any |
| `<Space>fm` | Format the buffer (see above) | ruff |

Commands:

| Command | Use |
| --- | --- |
| `:LspAttached` | Popup with the servers attached to this buffer |
| `:LspInfo` | `checkhealth vim.lsp` (configs, enabled servers, problems) |
| `:LspRestart` | Restart the servers of this buffer (needed after changing a venv or installing a package in some cases) |
| `:LspStop` / `:LspStart [name]` | Stop / start; `:LspStart` explains a missing program |
| `:LspLog` | Open the LSP log file |
| `:LspInlayHints enable` / `disable` | Switch inlay hints globally (off by default) |

Who does what:

| Task | Server |
| --- | --- |
| Type errors, wrong arguments, unknown imports, hover, definitions, rename | pyright (`standard` mode; `deprecateTypingAliases` hint off; `useLibraryCodeForTypes` on) |
| Style and lint diagnostics, unused imports, fixes | ruff |
| Import sorting | ruff (`organizeImports = true`); pyright's is disabled |
| Spelling mistakes in names and comments | typos_lsp |

Tested: after `:LspInlayHints enable` no inline hints appeared in a small Python file (pyright sends none for this code), so expect little or nothing in Python.

Ruff reads its rules from `pyproject.toml` / `ruff.toml` in the project. Pyright reads `pyrightconfig.json` or `[tool.pyright]` in `pyproject.toml`. See section 13 and section 44 for the LSP basics.

## Debugging with pdb

`<Space>dp` (Python buffers only) runs `:GdbStartPDB python -m pdb %` through the nvim-gdb plugin. Linux and Windows only; on macOS you get one warning. In any other file type `<Space>dp` shows one warning (`only in python buffers`). It always uses plain `python -m pdb`, never `uv run`.

Why pdb and not a "real" DAP debugger: nvim-dap is installed only for Java. For Python you use pdb (in the standard library, nothing to install) and nvim-gdb adds the visual part: it marks the current line in your code and gives you function keys and leader keys.

Example to try. Save as `dbg.py`:

```python
def square(n):
    r = n * n
    return r


total = 0
for i in range(3):
    total += square(i)
print("total", total)
```

Press `<Space>dp` in this file. Tested result: the source window shows the file with a `▶` mark in the sign column on line 1, and below it a terminal pane shows

```
> .../dbg.py(1)<module>()
-> def square(n):
(Pdb)
```

Press `<Space>dn` (or `<F10>`) twice. The `▶` moves to line 6, then line 7, and the terminal shows `n` typed for you each time (tested). `<Space>dc` (or `<F5>`) continues; this small program finished and printed `total 5`, then pdb says `The program finished and will be restarted` and starts again at line 1.

Keys during the session. The `<Space>d` keys work in Python buffers without function keys; the F-keys are nvim-gdb's own. Outside a debug session the `<Space>d` keys show one warning `pdb: no debug session here (start one with <Space>dp)`. All tested except `<F4>`; run them from the code window (go there with `<Ctrl-\><Ctrl-n>` then `<Ctrl-w>k` if you are in the pdb pane):

| Key | Action | Command |
| --- | --- | --- |
| `<Space>dB` / `<F8>` | Toggle breakpoint on the current line (a `●` appears in the sign column) | `:GdbBreakpointToggle` |
| `<Space>dc` / `<F5>` | Continue (stops at the next breakpoint: `▶` lands on the `●` line) | `:GdbContinue` |
| `<Space>dn` / `<F10>` | Next (step over) | `:GdbNext` |
| `<Space>ds` / `<F11>` | Step (into a call): from `total += square(i)` the `▶` jumped to `def square(n):` | `:GdbStep` |
| `<Space>df` / `<F12>` | Finish (run until the function returns): the `▶` stopped on `return r` | `:GdbFinish` |
| `<Space>du` / `<F4>` | Until (pdb: continue until the next line greater than the current one) | `:GdbUntil` |
| `<Ctrl-p>` / `<Ctrl-n>` | Frame up / down (`<Ctrl-p>` typed `up` in pdb and the `▶` went to the caller line) | `:GdbFrameUp` / `:GdbFrameDown` |
| `<Space>dv` | Evaluate the word under the cursor (visual mode: the selection); with the cursor on `square` pdb printed `<function square at 0x...>` | `:GdbEvalWord` / `:GdbEvalRange` |

Other commands: `:GdbBreakpointClearAll`, `:GdbFrame` (jump to the current line), `:GdbInterrupt`, `:GdbLopenBacktrace`, `:GdbLopenBreakpoints`, `:GdbCreateWatch`.

You can also type plain pdb commands in the terminal pane (`n`, `s`, `c`, `p var`, `l`, `bt`, `q`): go there with `<Ctrl-w>j`, press `i`, type, press `<Enter>`. Leave terminal mode with `<Ctrl-\><Ctrl-n>`.

**Quit:** `:GdbDebugStop`. The debug layout was in the same tab here (tested: one tab, two windows during the session, one after). Closing the debug windows also ends it.

**History (fixed, tested):** nvim-gdb used to bind `<F9>` itself (evaluate) and removed it from the code buffer after a session, which also removed your `<F9>` run key until `:e!`. Its evaluate key is now `<Space>dv`, so `<F9>`, `<Space>rf`, `<Space>f` and `<Space>dp` work before, during and after a debug session.

Notes:

- nvim-gdb's own evaluate key was `<F9>`; it is moved to `<Space>dv` (only while a debug session is active), and `<F9>` is no longer the eval key. `<F4>` `<F5>` `<F8>` `<F10>` `<F11>` `<F12>` still work.
- nvim-gdb loads the first time you use a `:GdbStart*` command. Its default start keys `<Space>dd/dl/dp/db/dr` are turned off (`vim.g.nvimgdb_disable_start_keymaps = true`) so they do not replace your own `<Space>dd` and `<Space>db`; `<Space>dp` is yours, set in the ftplugin.
- A quick alternative without any plugin: add `breakpoint()` in the code and run it with `<Space>rr`; the terminal stops there with a `(Pdb)` prompt.
- Section 56 has the wider debugging picture.

## Virtual Environments

**Statusline label.** In Python buffers only, the statusline shows the environment (section B of the lualine bar, section 32):

| Environment variable set | Label |
| --- | --- |
| `$VIRTUAL_ENV` (any venv, `.venv`, devShell's `venvShellHook`, uv `source .venv/bin/activate`) | `<folder name> (venv)`, for example `.venv (venv)` |
| only `$CONDA_DEFAULT_ENV` | `<env name> (conda)` |
| neither | nothing shown |

`$VIRTUAL_ENV` wins when both are set. In a uv project with `uv.lock` and no active environment the label stays empty (tested), even though `uv run` will use the project's `.venv`. Tested in the python devShell: the label read `.venv (venv)` (the folder name of `$VIRTUAL_ENV`, with its dot).

**How to activate an environment.**

| Goal | Do this |
| --- | --- |
| Use the devShell tools and the project's `.venv` | Enter the project folder (direnv loads the devShell and the `venvShellHook` `.venv`), then start nvim there |
| Plain venv | `python -m venv .venv`, `source .venv/bin/activate` (fish: `source .venv/bin/activate.fish`), then start nvim in that shell |
| uv project | Either `source .venv/bin/activate` before starting nvim, or leave it inactive and use `<Space>rf` / `<F9>` / `<Space>f`, which run through `uv run` |
| Switch environment | Close nvim, change environment, start nvim again (the shell environment is inherited at start) |

**How pyright finds packages (tested).** In a uv project (`.venv` with packages) opened from the python devShell (whose own `python` lacks them), `import pytokens` gave the error `Import "pytokens" could not be resolved`. After adding a `pyrightconfig.json` with `{"venvPath": ".", "venv": ".venv"}` the error was gone. So the `.venv` folder alone is not enough: pyright uses the `python` on PATH, unless `venvPath` / `venv` say otherwise. Background: Pyright runs as a child of nvim and uses the `python` on PATH. If `VIRTUAL_ENV` was set when nvim started, it resolves imports from that environment. With `autoSearchPaths` it also searches `src/`. To point pyright explicitly, put `venvPath` and `venv` in `pyrightconfig.json` or `[tool.pyright]` in `pyproject.toml`, then `:LspRestart`.


## Testing

There is **no test runner support** for Python in this config: no neotest, no vim-test, no pytest or unittest keys. What you can do:

| Goal | How |
| --- | --- |
| Run all tests | In the terminal split: `:terminal pytest`, or run `pytest` in a shell next to nvim (pytest comes from the project environment; it is not in the python devShell list) |
| Run a test file | `<Space>rf` (or `<F9>`) or `<Space>rr` on a file that ends with `unittest.main()`, or `:!pytest %` |
| Debug a failing test | Put `breakpoint()` in the test and run `<Space>rr`, or `pytest --pdb` in a terminal |
| See failures in quickfix | `:AsyncRun pytest -q` (output opens in the 6-line quickfix window, section 26) |

The only plugin that knows about tests is nvim-java (Java only, `<Space>jt...`).

## Navigation and Text Objects

All keys below exist in the keymap dump for Python buffers (or globally).

| Key | Mode | What it does |
| --- | --- | --- |
| `]]` / `[[` | n, x, o | Next / previous top-level `class` or `def` (Neovim's runtime Python ftplugin; not mapped by your config) |
| `][` / `[]` | n, x, o | End of the next / previous top-level function or class |
| `]m` / `[m` | n, x, o | Next / previous `def` or `class`, any nesting (method start) |
| `]M` / `[M` | n, x, o | Next / previous end of a method |
| `<Space>t` | n | Toggle the aerial outline (classes, functions, methods) |
| `]t` / `[t` | n | Next / previous symbol (aerial) |
| `gS` | n | treesj: toggle split / join of the construct under the cursor (a long call or list to one item per line, and back) |
| `ii` / `ai` | x, o | Indent scope inside / with its border lines (mini.indentscope): `dii` deletes the body of the block you are in, `vai` selects a whole `if` or `def` |
| `za`, `zc`, `zo`, `zR`, `zM`, `zr`, `zm` | n | Folds (nvim-ufo: LSP folding ranges, else indent); `<Space>K` previews a closed fold |
| `gd` then `<Ctrl-o>` | n | Jump to a definition and back |
| `<Space>gr` | n | References in a Glance popup |

Operators combine with the motions: `d]]` deletes up to the next top-level definition, `v]m` selects up to the next method. `ii` depends on indentation, so it works well in Python. Section 21, 37, 47 and 50 have more.

## Snippets

Snippets come from `my_snippets/python.snippets` (UltiSnips) and the shared vim-snippets collection. Type the trigger and press `<Ctrl-j>` to expand; `<Ctrl-j>` / `<Ctrl-k>` jump to the next / previous placeholder.

| Trigger | Expands to | Only at line start |
| --- | --- | --- |
| `print` | `print("$1".format($2))` | no |
| `impa` | `import FOO as BAR` (two placeholders) | yes |
| `main` | `def main():` with an empty body and `if __name__ == "__main__": main()` | yes |
| `sol` | `solution = Solution()` (coding-challenge helper) | yes |

The snippet menu may also offer vim-snippets entries (`def`, `class`, `ifmain`, ...). Section 15 and section 52 explain the engine.


## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Nothing highlights errors, `:LspAttached` shows no `pyright` | nvim was not started in a shell where `pyright-langserver` is on PATH | Check `which pyright-langserver`; start nvim in the python devShell or after `direnv allow`; `:LspStart pyright` names the missing program |
| No `ruff` diagnostics | `ruff` is not global | Start nvim inside the python or jupyter devShell |
| `Import "xyz" could not be resolved` | Package is not in the Python that pyright sees (no active venv when nvim started, or packages not installed) | Activate the environment BEFORE starting nvim, install the package, then `:LspRestart`; or set `venvPath` / `venv` in `pyrightconfig.json` |
| Statusline shows no environment | No `$VIRTUAL_ENV` or `$CONDA_DEFAULT_ENV`, or it is a uv project that is not activated | Activate the environment before starting nvim; label only appears in Python buffers |
| `<Space>f` says `black not found on PATH` | Not in the python devShell, or `uv` missing in a uv project | Start nvim in the python devShell; for uv projects make sure `uv` is on PATH (and `uv add --dev black`) |
| No "not formatted" warning after save, although the file is untidy | `black` is not on PATH (check is silent), or the file type is not detected as `python` | `:!which black`; `:set ft?` |
| `<Space>rf` / `<F9>` prints `ModuleNotFoundError` | Wrong interpreter: plain `python` was used (environment not active when the file was opened) | Activate the environment, reopen the file with `:e` so the uv/venv choice is re-evaluated |
| `<Space>rf` / `<F9>` does nothing visible | Quickfix window closed or scrolled, or `AsyncRun` not loaded | `:copen`; check `:AsyncRun echo hi` works |
| `<Space>rr` opens nothing | Unnamed buffer (one warning: save the file first) or an unsupported file type | `:w file.py`; check `:set ft?` |
| `<Space>rr` terminal flashes and closes, or shows `command not found` | `python3` is not on PATH | Start nvim in the devShell |
| `<Space>rr` output is late | Python buffers stdout when not attached to a tty | Use `<Space>rf` (it uses `-u`) or `print(..., flush=True)` |
| `<Space>dp` shows one warning | Not a Python buffer, or macOS | Open a `.py` file; on macOS pdb is not available through this key |
| Pyright hover looks plain | Hover is set to plain text on purpose | None needed |
| Program keeps running after closing its terminal | `<Space>q` only closes the window | Reopen the buffer with `:ls`, `:b <n>`, `<Ctrl-c>`, or `:bd!` |
| Spelling squiggles on names | typos_lsp | Add the word to a `typos.toml` or `_typos.toml` at the project root |

## Related Sections

Section 8 (terminal integration), section 13 (LSP), section 15 (snippets), section 18 (folding), section 19 (code running), section 21 (text objects), section 26 (quickfix), section 32 (statusline), section 36 (debugging), section 37 (aerial), section 41 (filetype settings), section 42 (automatic behaviours), section 43 (toolchain), section 44 (LSP in depth), section 52 (snippets for developers), section 55 (running in depth), section 56 (debugging in depth).


---
