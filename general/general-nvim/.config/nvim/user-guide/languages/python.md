<!-- chapter: Python -->
[Back to the guide index](../README.md)

# 79. Python (pyright, ruff, black, uv, running and debugging)

This section is one walk-through for everything Python in your config: what starts by itself, how to run, format and debug a file, how virtual environments are detected, and what to check when something does not work. Deeper background on the shared parts lives in the sections named in "[Related sections](#related-sections)" at the end.

## What you get

| Feature | What it does | Needs |
| --- | --- | --- |
| **pyright** (language server) | Type checking, import resolution, hover (`K`), go to definition (`gd`), rename (`<Space>rn`), references. Mode is `standard`, whole workspace is checked. Its own import sorting is turned off (ruff does that) | `pyright-langserver` on PATH (installed globally by `neovim.nix`, also in the python devShell) |
| **ruff** (language server, `ruff server`) | Fast linting (diagnostics), quick fixes and "organise imports" through `<Space>ca`. It is the server that offers formatting for `<Space>fm` | `ruff` on PATH (python and jupyter devShells; NOT global) |
| **black** (formatter) | `<Space>f` formats the file; after every save a background check warns when the file is not formatted | `black` on PATH (python devShell), or a uv project that has black (see [Running](#running-code)) |
| **typos_lsp** | Spell checker for identifiers and comments, attaches to every file type (also Python) | `typos-lsp` on PATH (installed globally by `neovim.nix`) |
| **tree-sitter** | Syntax highlighting (the `python` parser) | Nothing on Nix systems (parsers come from the nix store) |
| **Snippets** | `print` (f-string), `impa`, `main`, `sol` (see [Snippets](#snippets) below) | Nothing |
| **uv awareness** | In a project with `uv.lock` and no active virtual environment, `<Space>rf` / `<F9>` and `<Space>f` go through `uv run` | `uv` on PATH (it is: `/run/current-system/sw/bin/uv`) |
| **Statusline label** | Shows the active environment as `name (venv)` or `name (conda)` in Python buffers | An activated environment |
| **Format check** | After saving, `black --check` runs in the background and warns `<file>: file is not formatted (black)` | `black` on PATH, otherwise silent |
| **Run** | `<Space>rf` / `<F9>` (output in the quickfix window) and `<Space>rr` (output in a terminal split) | `python` / `python3` on PATH |
| **Debug** | `<Space>dp` starts `python -m pdb` inside nvim-gdb | Linux or Windows |
| **vim-illuminate** | Other uses of the word under the cursor are highlighted (Python is in its file type list) | Nothing |
| **aerial** | Symbol outline of classes, functions and methods (`<Space>t`) | Nothing |
| **Indentation** | 4 spaces, no wrapping, `colorcolumn` marker at 88 | Nothing |

## Quick start

1. Start nvim **inside the Python devShell** (a project folder with `.envrc` containing `use_dev_env python`, see "[Devshell and tools](#devshell-and-tools)"). Outside it, only pyright and typos_lsp exist.
2. Open a file: `nvim hello.py`. Wait a second or two. `:LspAttached` lists the running servers; in the python devShell: `pyright`, `ruff`, `typos_lsp`. The statusline shows `pyright (+2)` (the first server and two more).
3. Type a small program, save with `:w`, then run it with `<Space>rf` (or `<F9>`). A 6-line quickfix window opens at the bottom and shows the output.
4. Run it again as a full terminal with `<Space>rr`. A terminal split opens on the LEFT of the code.
5. Format with `<Space>f` (black). The file on disk is rewritten and the buffer reloads (`File changed on disk. Buffer reloaded!`).
6. Debug with `<Space>dp`. The code gets a `▶` marker and a pdb pane opens below it. Step with `<Space>dn` (or `<F10>`), quit with `:GdbDebugStop`. (`<F9>` and `<Space>rf` keep working afterwards.)

## Why each tool exists

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
| tree-sitter, aerial, illuminate, treesj, ufo | General tools that also work for Python (highlighting, outline, word highlight, split/join, folding) | See the sections in "[Related sections](#related-sections)" |

Python-specific configuration lives in only a few places:

| File | What it holds |
| --- | --- |
| `after/ftplugin/python.lua` | indentation, no wrapping, `<Space>rf` / `<F9>`, `<Space>f`, `<Space>dp` |
| `after/lsp/pyright.lua`, `after/lsp/ruff.lua` | server settings |
| `lua/config/lsp.lua` | which servers exist and when they are enabled |
| `my_snippets/python.snippets` | snippets |
| `lua/custom-autocmd.lua` | the after-save format check (`black --check`) |
| `lua/options.lua` | `colorcolumn` 88 for Python |

## Devshell and tools

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
| `python` / `python3` | `<Space>rf` / `<F9>` shows the shell error in the quickfix window. `<Space>rr` has no PATH check for Python: with an empty PATH, the terminal shows `bash: line 1: python3: command not found` and no nvim warning appears |
| `typos-lsp` | Silent |


## How Python is set up (the real code)

Python has no plugin spec of its own. It is a few small files, quoted here verbatim unless marked abridged. The binaries (`pyright-langserver`, `ruff`, `black`, `uv`) are never installed by Neovim: they come from the Nix system or the python devShell, and no Mason is used.

### The server entries (lua/config/lsp.lua)

Abridged (the other servers of the table are left out, see "[How language servers are registered](../07-code.md#how-language-servers-are-registered-luaconfiglsplua)" in the LSP chapter):

```lua
-- Servers: configured here (plus after/lsp/<name>.lua), enabled only when the binary exists
---@type table<string, vim.lsp.Config>
local servers = {
  pyright = { cmd = { "pyright-langserver", "--stdio" } },
  ruff = { cmd = { "ruff", "server" } },
```

In plain words:

- Only the command is set here. The settings of each server live in `after/lsp/<name>.lua`, which Neovim merges in by itself.
- A loop at the end of `lua/config/lsp.lua` enables a server only when its binary is on PATH. Outside the python devShell, with pyright or ruff missing, that server silently does not start.

### pyright settings (after/lsp/pyright.lua)

```lua
-- For what diagnostic is enabled in which type checking mode, check doc:
-- https://github.com/microsoft/pyright/blob/main/docs/configuration.md#diagnostic-settings-defaults
-- Currently, the pyright also has some issues displaying hover documentation:
-- https://www.reddit.com/r/neovim/comments/1gdv1rc/what_is_causeing_the_lsp_hover_docs_to_looks_like/

local new_capability = {
  textDocument = {
    publishDiagnostics = {
      tagSupport = {
        valueSet = { 2 },
      },
    },
    hover = {
      contentFormat = { "plaintext" },
      dynamicRegistration = true,
    },
  },
}

-- cmd lives in lua/config/lsp.lua (its executable check enables the server)
---@type vim.lsp.Config
return {
  ---@type lspconfig.settings.pyright
  settings = {
    pyright = {
      -- disable import sorting and use Ruff for this
      disableOrganizeImports = true,
      disableTaggedHints = false,
    },
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        typeCheckingMode = "standard",
        useLibraryCodeForTypes = true,
        -- we can this setting below to redefine some diagnostics
        diagnosticSeverityOverrides = {
          deprecateTypingAliases = false,
        },
      },
    },
  },
  capabilities = new_capability,
}
```

In plain words:

- `disableOrganizeImports = true`: ruff owns import sorting, so pyright must not offer a competing "Organize imports" action.
- `typeCheckingMode = "standard"`: the middle level between `basic` and `strict`.
- `diagnosticMode = "workspace"`: pyright reports problems in all files of the project, not only the open ones.
- `useLibraryCodeForTypes = true` and `autoSearchPaths = true`: use the source of installed packages for types when they ship no stubs, and search folders such as `src/` for imports.
- `diagnosticSeverityOverrides.deprecateTypingAliases = false`: no deprecation hints for `typing.List`, `typing.Dict` and similar.
- `capabilities`: `tagSupport = { valueSet = { 2 } }` lets the server mark deprecated code (shown struck through); the `hover` entry asks for plain text instead of Markdown, a work-around for badly rendered hover text (the Reddit link in the file comment describes the problem).

### ruff settings (after/lsp/ruff.lua)

```lua
---@type vim.lsp.Config
return {
  init_options = {
    -- the settings can be found here: https://docs.astral.sh/ruff/editors/settings/
    settings = {
      organizeImports = true,
    },
  },
}
```

In plain words: `organizeImports = true` makes ruff offer the "Organize imports" code action (see "[Code actions from ruff](#code-actions-from-ruff)"). Everything else comes from the project's `pyproject.toml` / `ruff.toml`.

### Which environment: get_py_env (lua/utils.lua)

Verbatim, the decision logic behind the table in "[When `<Space>rf` / `<F9>` uses uv](#when-spacerf--f9-uses-uv)":

```lua
--- Get the current virtual env name ("" if none) and its kind
--- @return string venv_name
--- @return string|nil kind "venv" | "conda" | nil (no env)
function M.get_virtual_env()
  local conda_env = os.getenv("CONDA_DEFAULT_ENV")
  local venv_path = os.getenv("VIRTUAL_ENV")
  if venv_path ~= nil then
    return vim.fn.fnamemodify(venv_path, ":t"), "venv"
  end
  if conda_env ~= nil then
    return conda_env, "conda"
  end
  return "", nil
end

--- Project root for python files
--- @return string|nil
function M.get_proj_root()
  return vim.fs.root(0, { ".git", "pyproject.toml" })
end

--- Python env kind of the current project
--- @return "plain_venv"|"uv"|""|nil (nil = no project root)
function M.get_py_env()
  local project_root = M.get_proj_root()
  if project_root == nil then
    return nil
  end
  if M.get_virtual_env() ~= "" then
    return "plain_venv"
  end
  if vim.fn.filereadable(vim.fs.joinpath(project_root, "uv.lock")) == 1 then
    return "uv"
  end
  return ""
end
```

In plain words:

- The project root is the nearest folder with `.git` or `pyproject.toml`. No root: `nil`.
- An active environment (`$VIRTUAL_ENV`, or else `$CONDA_DEFAULT_ENV`) always wins: result `"plain_venv"`, and the tools run as plain `python` / `black`.
- No active environment and a `uv.lock` in the root: `"uv"`, and the tools run through `uv run`.
- Otherwise `""`: plain commands.

### Run and format keys (after/ftplugin/python.lua)

Verbatim (lines 14-38; the indentation options at the top and the pdb part below are shown elsewhere):

```lua
-- `:compiler ruff` + `:make`: don't pass `--preview`
vim.g.ruff_makeprg_params = ""

-- in a uv project (uv.lock at the project root) without an activated venv, run tools through `uv run`
local py_env = utils.get_py_env()

if vim.fn.exists(":AsyncRun") == 2 then
  local py_cmd = (py_env == "uv") and "uv run python" or "python"
  for _, lhs in ipairs({ "<F9>", "<leader>rf" }) do -- <leader>rf: the same without function keys
    vim.keymap.set("n", lhs, string.format(':<C-U>AsyncRun %s -u "%%"<CR>', py_cmd), { buffer = true, silent = true, desc = "run python file" })
  end
end

-- <Space>f black: only when the formatter can run (black e.g. from the python devShell;
-- in a uv project black comes from the project env through `uv run`). Without it the key shows
-- ONE warning (an unmapped key would fall through to <Space> + f).
local py_fmt_bin = (py_env == "uv") and "uv" or "black"
if vim.fn.executable(py_fmt_bin) == 1 then
  local py_fmt_cmd = (py_env == "uv") and "!uv run black" or "!black"
  vim.keymap.set("n", "<Space>f", string.format("<cmd>silent %s %%<CR>", py_fmt_cmd), { buffer = true, silent = true, desc = "format file" })
else
  vim.keymap.set("n", "<Space>f", function()
    vim.notify("Python: black not found on PATH (open nvim inside the python devShell)", vim.log.levels.WARN)
  end, { buffer = true, desc = "format file (needs black)" })
end
```

In plain words:

- `py_env` is computed once, when the Python file is opened. That is why activating a venv or creating `uv.lock` afterwards needs `:e!`.
- The run keys exist only when the `:AsyncRun` command exists (the plugin is lazy and registers the command at startup). The `%%` in the format string becomes a literal `%`, which AsyncRun expands to the current file, in double quotes.
- `<Space>f` is a buffer-local map that overrides the global `<Space>f`. It runs black on the file on disk (`!black %`, so save first), through `uv run` in a uv project. If black (or uv) is missing, the key shows ONE warning instead of falling through to `<Space>` + `f`.
- `vim.g.ruff_makeprg_params = ""` is what lets `:compiler ruff` + `:make` work without `--preview` (see "[Linting from the command line](#linting-from-the-command-line-compiler-ruff)").

### AsyncRun (lua/plugin_specs.lua)

```lua
  -- Asynchronous command execution
  {
    "skywind3000/asyncrun.vim",
    lazy = true,
    cmd = { "AsyncRun" },
    init = function()
      -- Automatically open quickfix window of 6 line tall after asyncrun starts
      vim.g.asyncrun_open = 6
      if vim.g.is_win then
        -- Command output encoding for Windows
        vim.g.asyncrun_encs = "gbk"
      end
    end,
  },
```

In plain words:

- `cmd = { "AsyncRun" }`: the plugin loads the first time `:AsyncRun` is used, that is, on the first `<F9>` / `<Space>rf`.
- `asyncrun_open = 6` is the "quickfix window 6 lines tall" of the table in "[Running code](#running-code)".
- The `gbk` branch matters only on Windows (output encoding of the console); on Linux and macOS nothing is set.

### pdb through nvim-gdb (plugin spec and ftplugin)

The plugin spec (`lua/plugin_specs.lua`, verbatim):

```lua
  -- Debugger plugin
  {
    "sakhnik/nvim-gdb",
    enabled = function()
      return vim.g.is_win or vim.g.is_linux
    end,
    build = { "bash install.sh" },
    cmd = { "GdbStart", "GdbStartLLDB", "GdbStartPDB", "GdbStartBashDB", "GdbStartRR" },
    init = function()
      -- do not let nvim-gdb create its global <leader>dd/dl/dp/db/dr start maps
      -- (they would overwrite the user's <leader>dd / <leader>db / <leader>dp)
      vim.g.nvimgdb_disable_start_keymaps = true
      -- nvim-gdb's eval key is <F9> by default and, at the end of a session, it removed our <F9> run key in
      -- the buffer: use <leader>dv (Normal: word under cursor, Visual: selection) instead
      vim.g.nvimgdb_config_override = { key_eval = "<space>dv" }
      -- <leader>dp (pdb on the current file) is python buffer-local: after/ftplugin/python.lua
    end,
    config = function()
      -- nvim-gdb's setup() maps cmdline <c-e> globally (cmake executable picker); keep the builtin <C-e>
      pcall(vim.keymap.del, "c", "<c-e>")
    end,
  },
```

The Python side (`after/ftplugin/python.lua`, lines 40-68, verbatim):

```lua
-- <leader>dp: start pdb on the current file (nvim-gdb, lazy-loaded on :GdbStart*; pdb is the
-- python stdlib module). nvim-gdb is disabled on macOS -> one warning instead.
if vim.fn.exists(":GdbStartPDB") == 2 then
  vim.keymap.set("n", "<leader>dp", [[:<C-U>GdbStartPDB python -m pdb %<CR>]], { buffer = true, desc = "start pdb on current file (nvim-gdb)" })
  -- debug-session keys without function keys (nvim-gdb's own keys are F4 until, F5 continue, F8 breakpoint,
  -- F10 next, F11 step, F12 finish; they keep working). <leader>dv (eval) is nvim-gdb's key_eval, see plugin_specs.lua.
  local function gdb(cmd)
    return function()
      local ok = pcall(vim.cmd, cmd)
      if not ok then
        vim.notify("pdb: no debug session here (start one with <Space>dp)", vim.log.levels.WARN)
      end
    end
  end
  for lhs, spec in pairs({
    ["<leader>dc"] = { "GdbContinue", "pdb: continue" },
    ["<leader>dn"] = { "GdbNext", "pdb: next line (step over)" },
    ["<leader>ds"] = { "GdbStep", "pdb: step into" },
    ["<leader>df"] = { "GdbFinish", "pdb: finish (run until the function returns)" },
    ["<leader>dB"] = { "GdbBreakpointToggle", "pdb: toggle breakpoint on this line" },
    ["<leader>du"] = { "GdbUntil", "pdb: run until this line" },
  }) do
    vim.keymap.set("n", lhs, gdb(spec[1]), { buffer = true, desc = spec[2] })
  end
else
  vim.keymap.set("n", "<leader>dp", function()
    vim.notify("<leader>dp: nvim-gdb is not available on this platform", vim.log.levels.WARN)
  end, { buffer = true, desc = "start pdb (needs nvim-gdb)" })
end
```

In plain words:

- `enabled` limits nvim-gdb to Windows and Linux. On macOS the `:GdbStartPDB` command does not exist, so `<Space>dp` shows one warning instead.
- `cmd = { ... }`: the plugin loads on the first `:GdbStart*` command. `build = { "bash install.sh" }` compiles its helper when it is installed.
- Three overrides protect your own keys: `nvimgdb_disable_start_keymaps` stops nvim-gdb from creating its global `<Space>dd/dl/dp/db/dr` (they would replace your `<Space>dd` and `<Space>db`); `key_eval = "<space>dv"` moves its evaluate key off `<F9>` (it used to remove your run key at the end of a session); the `config` function deletes the global command-line `<C-e>` map nvim-gdb adds, so the builtin `<C-e>` keeps working.
- `<Space>dp` runs `:GdbStartPDB python -m pdb %` (plain python, never `uv run`). The `<Space>dc/dn/ds/df/dB/du` keys are thin wrappers: they run the matching `:Gdb...` command and turn the error you would get outside a debug session into one warning. The full key table is in "[Debugging with pdb (nvim-gdb)](#debugging-with-pdb-nvim-gdb)" below.
- There is no debugpy and no nvim-dap setup for Python; nvim-dap is installed only as a dependency of nvim-java.

## Running code

Two ways, for different purposes.

| Key | Command it runs | Where output goes |
| --- | --- | --- |
| `<Space>rf` / `<F9>` | `python -u "<file>"`, or `uv run python -u "<file>"` in a uv project (see below) | Quickfix window, 6 lines tall at the bottom (AsyncRun opens it by itself). The last line says `[Finished in N seconds]` on success and `[Finished in N seconds with code C]` when the exit code C is not 0 |
| `<Space>rr` | `python3 <file>` (shell-escaped) | A new terminal in a vertical split on the LEFT of your code, titled like `term://...:python3 'file.py'`; Claude's panel stays on the right. When the program ends it shows `[Process exited 0]` |

Facts that differ between the two:

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

Press `<Space>rf` (or `<F9>`). Expect in the quickfix window: `3`, then the Python version, the venv path (or `None`) and the interpreter path, then `[Finished in 0 seconds]`. A program that crashes ends with `code 1` and the traceback, as in the example `add(1, "two")`:

```
TypeError: unsupported operand type(s) for +: 'int' and 'str'
[Finished in 0 seconds with code 1]
```

### When `<Space>rf` / `<F9>` uses uv

The choice is made when the Python file is opened (`after/ftplugin/python.lua`), from the project root (nearest `.git` or `pyproject.toml`). Abridged here (`...` stands for the options); the full code is in "[How Python is set up (the real code)](#how-python-is-set-up-the-real-code)" above:

```lua
local py_env = utils.get_py_env()
local py_cmd = (py_env == "uv") and "uv run python" or "python"
vim.keymap.set("n", "<F9>", string.format(':<C-U>AsyncRun %s -u "%%"<CR>', py_cmd), ...)
```

| Situation | `<Space>rf` / `<F9>` runs | `<Space>f` runs |
| --- | --- | --- |
| No project root (no `.git`, no `pyproject.toml`) | `python -u` | `black` |
| An environment is active (`$VIRTUAL_ENV` or `$CONDA_DEFAULT_ENV` set) | `python -u` | `black` |
| `uv.lock` in the project root and no active environment | `uv run python -u` (quickfix title `:AsyncRun uv run python -u "hello.py"`) | `uv run black` |
| Project root without `uv.lock`, no active environment | `python -u` | `black` |

In a folder with `pyproject.toml` + `uv.lock` and a plain shell, the quickfix title showed `uv run python -u`; inside the python devShell (where `$VIRTUAL_ENV` is the project's `.venv`) it showed plain `python -u`.

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
| `<Space>rf` / `<F9>` | `:AsyncStop` (with a 60-second `time.sleep`: `ps` showed `python -u slow.py` before and nothing after; stronger kill: `:AsyncStop!`) |
| `<Space>rr` | In the terminal press `<Ctrl-c>`, or delete the terminal buffer with `:bd!` (`ps` showed `python3 slow.py` before `:bd!` and nothing after) |

Warning: `<Space>q` on a terminal window only **closes the window**; the running program keeps running hidden. Stop it first. See section [55](../07-code.md#55-code-running-in-depth) and section [8](../06-windows-terminal-sessions.md#8-terminal-integration) for terminal navigation.

## Formatting and linting

| Key / command | What it does |
| --- | --- |
| `<Space>f` (Python buffers) | Runs `black` on the file **on disk** (`:silent !black %`); in a uv project `uv run black %`. Nvim then reloads the buffer and shows `File changed on disk. Buffer reloaded!` |
| `<Space>fm` | LSP format, async, **in the buffer** (not saved). In Python the formatter is ruff's server, so it is `ruff format`, not black (the buffer became modified, `●` in the tab, and `{"a":1,\n "b":2}` became `{"a": 1, "b": 2}`) |

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

Save again: no warning. (`os` and `sys` stay; ruff still shows `E401` and `F401` hints. See "[Code actions from ruff](#code-actions-from-ruff)".)

Key points:

- Both formatters give almost the same result on normal code, but they are different programs. `<Space>f` (black) matches the after-save check; `<Space>fm` does not need black installed.
- Nothing formats automatically on save.
- **Format check after save:** every `:w` of a Python file runs `black --check --quiet <file>` in the background. If the file would change you get `<file>: file is not formatted (black)`. If black fails (for example a syntax error) you get `<file>: black could not check the file (syntax error?)` plus the first error line. Nothing is changed. If `black` is not on PATH the check is silent. It uses plain `black`, even in uv projects.
- **Without black:** outside the devShell, `<Space>f` shows ONE warning `Python: black not found on PATH (open nvim inside the python devShell)`, and saving shows nothing. In a uv project (uv is on PATH) the key stays silent and changes nothing when the project has no black: the command fails inside `:silent`. When the project has black (with `uv add --dev black` in a scratch project), `<Space>f` runs `uv run black` and reformats the file, with the same `Buffer reloaded!` message.
- **Line length:** black's default is 88, and the `colorcolumn` marker for Python is also 88 (default for other files: 100). A line touching the marker is too long for black. Black does not wrap long strings or comments.
- **Indentation:** `tabstop`, `softtabstop`, `shiftwidth` = 4, `expandtab` on. No wrapping (`wrap` off, `sidescroll` 5, `sidescrolloff` 2).

### Code actions from ruff

Put the cursor on the first line of `messy.py` and press `<Space>ca`. Result (with `import os, sys` on line 1) is a list of eight ruff actions (one "Remove unused import" per unused name and one "Disable for this line" per diagnostic, so the exact number depends on how many diagnostics the line has):

```
1. Ruff (E401): Split imports [ruff]
2. Ruff (F401): Remove unused import [ruff]
3. Ruff (F401): Remove unused import [ruff]
4. Ruff (E401): Disable for this line [ruff]
5. Ruff (F401): Disable for this line [ruff]
6. Ruff (F401): Disable for this line [ruff]
7. Ruff: Fix all auto-fixable problems [ruff]
8. Ruff: Organize imports [ruff]
```

Pick a number with `<CR>`. "Organize imports" sorts and groups the imports (pyright's own version is disabled in `after/lsp/pyright.lua` so there is no conflict). "Fix all" applies every automatic fix, such as removing unused imports.

### Linting from the command line (`:compiler ruff`)

The ftplugin sets `vim.g.ruff_makeprg_params = ""` so that Neovim's built-in ruff compiler plugin works without `--preview`:

```vim
:compiler ruff
:make %
```

runs `ruff check --output-format=concise nav.py` and puts every finding in the quickfix list (then `:copen`, `]q`, `[q`; see [section 26](../05-search-and-files.md#26-quickfix--location-list)). Needs `ruff` on PATH (devShell).

## LSP keys

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

After `:LspInlayHints enable` no inline hints appeared in a small Python file (pyright sends none for this code), so expect little or nothing in Python.

Ruff reads its rules from `pyproject.toml` / `ruff.toml` in the project. Pyright reads `pyrightconfig.json` or `[tool.pyright]` in `pyproject.toml`. See section [13](../07-code.md#13-lsp-language-server-protocol) and section [44](../07-code.md#44-language-server-protocol-lsp-in-depth) for the LSP basics.

## Debugging with pdb (nvim-gdb)

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

Press `<Space>dp` in this file. After the session starts the cursor is in the pdb terminal pane, so the `<Space>d*` keys are typed into pdb until you move back to the source window (`<Ctrl-\><Ctrl-n>` then `<Ctrl-w>k`). Result: the source window shows the file with a `▶` mark in the sign column on line 1, and below it a terminal pane shows

```
> .../dbg.py(1)<module>()
-> def square(n):
(Pdb)
```

Press `<Space>dn` (or `<F10>`) twice. The `▶` moves to line 6, then line 7, and the terminal shows `n` typed for you each time. `<Space>dc` (or `<F5>`) continues; this small program finished and printed `total 5`, then pdb says `The program finished and will be restarted` and starts again at line 1.

Keys during the session. The `<Space>d` keys work in Python buffers without function keys; the F-keys are nvim-gdb's own. Outside a debug session the `<Space>d` keys show one warning `pdb: no debug session here (start one with <Space>dp)`. `<F4>` is not tested. Run them from the code window (go there with `<Ctrl-\><Ctrl-n>` then `<Ctrl-w>k` if you are in the pdb pane):

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

**Quit:** `:GdbDebugStop`. The debug layout was in the same tab here (one tab, two windows during the session, one after). Closing the debug windows also ends it.

**History (fixed):** nvim-gdb used to bind `<F9>` itself (evaluate) and removed it from the code buffer after a session, which also removed your `<F9>` run key until `:e!`. Its evaluate key is now `<Space>dv`, so `<F9>`, `<Space>rf`, `<Space>f` and `<Space>dp` work before, during and after a debug session.

Notes:

- nvim-gdb's own evaluate key was `<F9>`; it is moved to `<Space>dv` (only while a debug session is active), and `<F9>` is no longer the eval key. `<F4>` `<F5>` `<F8>` `<F10>` `<F11>` `<F12>` still work.
- nvim-gdb loads the first time you use a `:GdbStart*` command. Its default start keys `<Space>dd/dl/dp/db/dr` are turned off (`vim.g.nvimgdb_disable_start_keymaps = true`) so they do not replace your own `<Space>dd` and `<Space>db`; `<Space>dp` is yours, set in the ftplugin.
- A quick alternative without any plugin: add `breakpoint()` in the code and run it with `<Space>rr`; the terminal stops there with a `(Pdb)` prompt.
- Section [56](../07-code.md#56-debugging-in-depth) has the wider debugging picture.

## Virtual environments

**Statusline label.** In Python buffers only, the statusline shows the environment (section B of the lualine bar, section [32](../06-windows-terminal-sessions.md#32-statusline-lualinenvim)):

| Environment variable set | Label |
| --- | --- |
| `$VIRTUAL_ENV` (any venv, `.venv`, devShell's `venvShellHook`, uv `source .venv/bin/activate`) | `<folder name> (venv)`, for example `.venv (venv)` |
| only `$CONDA_DEFAULT_ENV` | `<env name> (conda)` |
| neither | nothing shown |

`$VIRTUAL_ENV` wins when both are set. In a uv project with `uv.lock` and no active environment the label stays empty, even though `uv run` will use the project's `.venv`. In the python devShell: the label read `.venv (venv)` (the folder name of `$VIRTUAL_ENV`, with its dot).

**How to activate an environment.**

| Goal | Do this |
| --- | --- |
| Use the devShell tools and the project's `.venv` | Enter the project folder (direnv loads the devShell and the `venvShellHook` `.venv`), then start nvim there |
| Plain venv | `python -m venv .venv`, `source .venv/bin/activate` (fish: `source .venv/bin/activate.fish`), then start nvim in that shell |
| uv project | Either `source .venv/bin/activate` before starting nvim, or leave it inactive and use `<Space>rf` / `<F9>` / `<Space>f`, which run through `uv run` |
| Switch environment | Close nvim, change environment, start nvim again (the shell environment is inherited at start) |

**How pyright finds packages.** In a uv project (`.venv` with packages) opened from the python devShell (whose own `python` lacks them), `import pytokens` gave the error `Import "pytokens" could not be resolved`. After adding a `pyrightconfig.json` with `{"venvPath": ".", "venv": ".venv"}` the error was gone. So the `.venv` folder alone is not enough: pyright uses the `python` on PATH, unless `venvPath` / `venv` say otherwise. Background: Pyright runs as a child of nvim and uses the `python` on PATH. If `VIRTUAL_ENV` was set when nvim started, it resolves imports from that environment. With `autoSearchPaths` it also searches `src/`. To point pyright explicitly, put `venvPath` and `venv` in `pyrightconfig.json` or `[tool.pyright]` in `pyproject.toml`, then `:LspRestart`.


## Testing

There is **no test runner support** for Python in this config: no neotest, no vim-test, no pytest or unittest keys. What you can do:

| Goal | How |
| --- | --- |
| Run all tests | In the terminal split: `:terminal pytest`, or run `pytest` in a shell next to nvim (pytest comes from the project environment; it is not in the python devShell list) |
| Run a test file | `<Space>rf` (or `<F9>`) or `<Space>rr` on a file that ends with `unittest.main()`, or `:!pytest %` |
| Debug a failing test | Put `breakpoint()` in the test and run `<Space>rr`, or `pytest --pdb` in a terminal |
| See failures in quickfix | `:AsyncRun pytest -q` (output opens in the 6-line quickfix window, section [26](../05-search-and-files.md#26-quickfix--location-list)) |

The only plugin that knows about tests is nvim-java (Java only, `<Space>jt...`).

## Navigation and text objects

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

Operators combine with the motions: `d]]` deletes up to the next top-level definition, `v]m` selects up to the next method. `ii` depends on indentation, so it works well in Python. Section [21](../07-code.md#21-treesitter--text-objects), [37](../02-navigation.md#37-symbol-outline-aerialnvim), [47](../07-code.md#47-code-folding-in-depth-nvim-ufo) and [50](../02-navigation.md#50-code-navigation-strategies) have more.

## Snippets

Source: `my_snippets/python.snippets` (UltiSnips, 4 snippets) and the shared vim-snippets collection. Type the trigger in insert mode and press `<Ctrl-j>` to expand; `<Ctrl-j>` / `<Ctrl-k>` jump to the next / previous placeholder. The text in quotes after each trigger is its description as the completion menu shows it. "Start of line" snippets expand only at the beginning of a line. Placeholders are shown in tab-stop order.

| Trigger | Description | Start of line only |
| --- | --- | --- |
| `print` | Print a text with the value of a variable (f-string: the variable name goes inside the braces) | no |
| `impa` | Import a module under an alias (import FOO as BAR, start of line) | yes |
| `main` | Main function plus the if __name__ == "__main__" guard (start of line) | yes |
| `sol` | LeetCode style: create a Solution object (needs a class Solution; start of line) | yes |

**`print`**: an f-string print. Type the text, jump, type the name of the variable; it is written inside the braces, so its value appears in the output.

```python
print(f"text {variable}")
```

Example: `text` = `total:`, `variable` = `count` gives `print(f"total: {count}")`, which prints `total: 3` when `count` is 3.

**`impa`**: import under an alias. Both placeholders are upper case words to overwrite.

```python
import FOO as BAR
```

Example: `FOO` = `numpy`, `BAR` = `np`.

**`main`**: the usual entry point. The cursor starts on the `# code` placeholder inside `main`.

```python
def main():
	# code


if __name__ == "__main__":
	main()
```

**`sol`**: the object that coding-challenge sites expect; it needs a `class Solution` in the file.

```python
solution = Solution()
```

The snippet menu may also offer vim-snippets entries (`def`, `class`, `ifmain`, ...). Section [15](../04-completion-snippets.md#15-snippets-ultisnips) and section [52](../04-completion-snippets.md#52-snippets-for-developers-ultisnips) explain the engine.

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

## Related sections

Section [8](../06-windows-terminal-sessions.md#8-terminal-integration) (terminal integration), section [13](../07-code.md#13-lsp-language-server-protocol) (LSP), section [15](../04-completion-snippets.md#15-snippets-ultisnips) (snippets), section [18](../07-code.md#18-code-folding-nvim-ufo) (folding), section [19](../07-code.md#19-code-running) (code running), section [21](../07-code.md#21-treesitter--text-objects) (text objects), section [26](../05-search-and-files.md#26-quickfix--location-list) (quickfix), section [32](../06-windows-terminal-sessions.md#32-statusline-lualinenvim) (statusline), section [36](../07-code.md#36-debugging) (debugging), section [37](../02-navigation.md#37-symbol-outline-aerialnvim) (aerial), section [41](../10-various.md#41-filetype-specific-settings) (filetype settings), section [42](../10-various.md#42-automatic-behaviors) (automatic behaviours), section [43](../07-code.md#43-how-the-development-toolchain-fits-together) (toolchain), section [44](../07-code.md#44-language-server-protocol-lsp-in-depth) (LSP in depth), section [52](../04-completion-snippets.md#52-snippets-for-developers-ultisnips) (snippets for developers), section [55](../07-code.md#55-code-running-in-depth) (running in depth), section [56](../07-code.md#56-debugging-in-depth) (debugging in depth).


---
