<!-- chapter: Code: LSP, running, debugging, folding, treesitter -->
[Back to the guide index](README.md)

# 13. LSP: language server protocol

Plugin: nvim-lspconfig (default server definitions; Neovim's builtin `vim.lsp` does the rest). Provides IDE features. The keys below work per buffer according to what the attached servers support: if no attached server supports it, `K` and `gd` fall back to Vim's builtin versions and `<Space>rn` / `<Space>ca` show one warning.

### Configured language servers

| Server | Language | Program(s) that must be on PATH |
| --- | --- | --- |
| `pyright` + `ruff` | Python | `pyright-langserver`, `ruff` |
| `lua_ls` | Lua | `lua-language-server` |
| `bashls` | Bash | `bash-language-server` |
| `yamlls` | YAML | `yaml-language-server` |
| `marksman` | Markdown | `marksman` |
| `nixd` | Nix | `nixd` |
| `jdtls` | Java (via nvim-java) | `java` (Java devShell) |
| `clangd` | C/C++ | `clangd` (c-cpp devShell) |
| `ltex_plus` | Grammar and spelling (LanguageTool) for markdown, tex, plain TeX, typst, gitcommit, text | `ltex-ls-plus` |
| `typos_lsp` | Typos in identifiers and comments, every real file | `typos-lsp` |
| `tinymist` | Typst | `tinymist` |
| `texlab` | LaTeX | `texlab` (LaTeX devShell) |
| `rust_analyzer` | Rust | `rust-analyzer` AND `cargo` |
| `gopls` | Go | `gopls` AND `go` |
| `hls` | Haskell | `haskell-language-server-wrapper` |
| `sourcekit` | Swift, Objective-C | `sourcekit-lsp` |
| `ts_ls` | JavaScript / TypeScript | `typescript-language-server` (the project's `node_modules/.bin` copy is preferred) |
| `phpactor` | PHP | `phpactor` (php devShell) |
| `r_language_server` | R, Rmd, quarto | `R` plus the R package `languageserver`: the first R file runs one silent background check; restart nvim after installing the package |

A server is enabled only when ALL its programs are on PATH; otherwise it is skipped silently (no warning when you open a file of that language outside its devShell). The programs come from the Nix system or the language's devShell; nothing is downloaded by Neovim. `:LspStart <name>` tells you which program is missing.

### LSP keymaps

| Keymap | Description |
| --- | --- |
| `gd` | **Go to definition**: jump to where the symbol is defined (several different places open the location list) |
| `K` | **Hover**: show documentation in a floating window |
| `<Space>rn` | **Rename**: rename the symbol everywhere it's used |
| `<Space>ca` | **Code action**: show available fixes/refactors |
| `<Space>fm` | **Format** the file (or only the selection in Visual mode) on demand with the formatter of the file type, async; see [Formatting (conform.nvim)](#formatting-conformnvim). Saving with `:w` formats too |
| `<Space>fo` | **Toggle format on save** for all buffers; prints `Format on save: on` or `off` |

Example (with pyright; the same file is used for the next examples):

```python
def load(path):          # line 1
    ...
x = load("a.txt")        # line 10, the cursor is on "load"
```

| Keys | What happens |
| --- | --- |
| `gd` | The cursor jumps to line 1, `def load(path):`; `<Ctrl-o>` brings it back to line 10 |
| `K` | A small bordered float shows the signature: `(function) def load(path: Unknown) -> str` (the type text comes from pyright); it closes when you move |
| `<Space>rn` | A "New Name" popup opens with `load` in it; erase it with `<BS>`, type `read`, `<Enter>`: line 1 becomes `def read(path):` and line 10 `x = read("a.txt")`. To cancel: `<Esc>` only leaves Insert mode (the popup stays open, in Normal mode); then `:q<Enter>` closes it with nothing renamed and your file still open |

**Why press `K` twice (going into the hover float).** The first `K` shows the documentation in a small float and leaves your cursor where it was; the float disappears as soon as you move. A second `K` moves the cursor INTO the float, where it stays until you close it. The float is then a read-only Markdown window (in a Lua file with `lua_ls`), so you can use normal Neovim keys on the documentation:

| Keys in the float | What happens |
| --- | --- |
| `j` `k`, `gg`, `G` | Move and scroll through a long documentation text that does not fit in the small float |
| `V` then `j`, then `y` | Copy lines of the documentation into a register, to paste them into your code or notes (it is read-only, so nothing in the float can be changed) |
| `/word<Enter>` | Search inside the documentation (`/Returns` jumped to the line with that word) |
| `q` or `<Esc>` | Close the float; the cursor is back in your file on the same spot |

So going inside is not only "more readable": it is how you scroll long docs, search them and copy from them. For a short signature the first `K` is enough.

### Built-in Neovim LSP and diagnostic keys

Neovim's own LSP keys also work next to the custom ones (in every buffer with a server that supports them):

| Keymap | Mode | Description |
| --- | --- | --- |
| `grn` | n | Rename (same as `<Space>rn`) |
| `gra` | n, x | Code action (same as `<Space>ca`) |
| `grr` | n | References (quickfix list) |
| `gri` | n | Implementation |
| `grt` | n | Type definition |
| `grx` | n | Run the code lens of the line |
| `gO` | n | Document symbols (outline in the location list) |
| `<Ctrl-s>` | i, s | Signature help |
| `]d` / `[d` | n | Next / previous diagnostic of any severity (`<Space>de` / `<Space>dE` jump to errors only) |
| `]D` / `[D` | n | Last / first diagnostic in the buffer |
| `<Ctrl-w>d` | n | Show the diagnostics under the cursor |

### LSP commands

| Command | What it does |
| --- | --- |
| `:LspInfo` | LSP status (same as `:checkhealth vim.lsp`) |
| `:LspAttached` | Small popup with the servers attached to this buffer (`q` / `<Esc>` closes; also opens when you click the LSP name in the statusline; with no server attached it only shows a notification) |
| `:LspLog` | Open the LSP log file |
| `:LspRestart [name...]` | Restart the servers of this buffer, or the named ones |
| `:LspStop [name...]` | Stop them |
| `:LspStart [name...]` | Start the enabled servers of this buffer that are not running, or the named ones |
| `:LspInlayHints enable` / `disable` | Switch inlay hints on / off globally (off by default) |

### glance.nvim: peek without jumping

Plugin: glance.nvim. Preview definitions/references in a popup, without leaving your current file.

| Keymap | Description |
| --- | --- |
| `<Space>gd` | Peek at definitions |
| `<Space>gr` | Peek at all references |
| `<Space>gi` | Peek at implementations |

Example (`<Space>gr` with the cursor on `load` in `x = load("a.txt")`): a panel opens across the window with two panes. The left pane previews the code (the file with its line numbers), the right pane is titled `References (2)` and lists `def load(path):` and `x = load("a.txt")`. `<Esc>` closes the panel and the cursor is back on the line where it was.

```
+----------------------------------+-------------------------+
| preview of the selected entry    | References (2)          |
| (the whole file, left)           |   def load(path):       |
|                                  |   x = load("a.txt")     |
+----------------------------------+-------------------------+
```

### Diagnostics (errors, warnings)

Nerd Font signs in the gutter: 󰅚 (error), 󰀪 (warning), 󰋽 (info), 󰌶 (hint). No underline and no inline text: the message appears in a floating window when the cursor rests on the line (it closes when you move, leave the window or enter Insert mode).

| Keymap | Description |
| --- | --- |
| `<Space>db` | Telescope picker with the diagnostics of the current file |
| `<Space>dw` | Toggle the Trouble diagnostics list (the diagnostics of every buffer Neovim has loaded, grouped by file; see "[Diagnostics in depth](#diagnostics-in-depth)") |
| `<Space>de` | Jump to next error |
| `<Space>dE` | Jump to previous error |
| `<Space>dd` | Show diagnostic detail in floating window |
| `<Space>dt` | Toggle diagnostics on/off |
| `<Space>qw` | Send the diagnostics of all open buffers to the quickfix list |
| `<Space>qb` | Send buffer diagnostics to quickfix list |

Example (with pyright on a file whose last line is `print(undefined_name)`): the line gets a 󰅚 sign in the gutter, and after a moment a float appears under it:

```
 󰅚 11   print(undefined_name)
        +--------------------------------------------------------------------+
        | Diagnostics:                                                       |
        |  Pyright: "undefined_name" is not defined [reportUndefinedVariable]|
        +--------------------------------------------------------------------+
```

`<Space>de` from the top of the file jumps to that line; `<Space>qw` opens the quickfix list with one entry for it (`hello.py ┃11┃"undefined_name" is not defined`).

---

# 44. Language server protocol (LSP) in depth

## What LSP is

LSP is a protocol that lets Neovim communicate with language-specific servers (programs that understand your code). The server analyzes your code and provides:

- **Diagnostics**: Errors and warnings shown in the gutter and floating windows
- **Go to definition**: Jump to where a function/class/variable is defined
- **Hover**: Show documentation for the symbol under cursor
- **Rename**: Rename a symbol across the entire project
- **Code actions**: Quick fixes, auto-imports, refactorings
- **Formatting**: Auto-format your code according to language standards (in this config the file formatters of [Formatting (conform.nvim)](#formatting-conformnvim) do the work; the language server formats only where no formatter is installed)
- **Completion**: Suggestions as you type

## How LSP is managed (nvim-lspconfig)

Each server is configured in `lua/config/lsp.lua` (plus `after/lsp/<name>.lua`) with Neovim's builtin `vim.lsp.config` / `vim.lsp.enable`. **nvim-lspconfig** only supplies the default server definitions. A server is enabled only when its program is on PATH: the programs come from the Nix system (`neovim.nix`) or from the language's devShell, nothing is downloaded by Neovim. Java (jdtls) is managed by nvim-java.

## Configured servers and what they provide

| Server | Language | What it provides |
| --- | --- | --- |
| **pyright** | Python | Type checking, import resolution, diagnostics. Disables import sorting (ruff handles that). |
| **ruff** | Python | Fast linting, quick fixes and import sorting. Complementary to pyright. Formatting is `ruff format` through conform.nvim. |
| **lua_ls** | Lua | Full Lua analysis with `vim` global recognized. Its formatting is switched off: Lua is formatted by stylua (on save and with `<Space>fm`, see [Formatting (conform.nvim)](#formatting-conformnvim)). |
| **bashls** | Bash/Shell | Shell script analysis and diagnostics. |
| **yamlls** | YAML | Schema validation and formatting for YAML files. |
| **marksman** | Markdown | Link validation, heading completion. Formatting is done with Prettier on save and with `<Space>fm` (not by marksman). |
| **nixd** | Nix | Nix language analysis. Formatter: nixpkgs-fmt. |
| **jdtls** | Java | Full Java IDE features via nvim-java (see [Java section](#54-java-development-in-depth)). Auto-configured. |
| **clangd** | C/C++ | Compilation, diagnostics, code completion for C/C++. |
| **ltex_plus** | Prose (markdown, tex, typst, gitcommit, text) | Grammar and spell checking with LanguageTool; problems are diagnostics. |
| **typos_lsp** | Every real file | Finds typos in identifiers and comments; offers fixes as code actions. |
| **tinymist** | Typst | Diagnostics, completion (PDF export is left to `:TypstWatch`). |
| **texlab** | LaTeX | Diagnostics, hover, symbols, rename. |
| **rust_analyzer** | Rust | Full Rust analysis (needs `cargo` too). |
| **gopls** | Go | Full Go analysis (needs `go` too). |
| **hls** | Haskell | Haskell language server. |
| **sourcekit** | Swift, Objective-C | Swift analysis (C/C++ stay with clangd). |
| **ts_ls** | JavaScript / TypeScript | TypeScript language server. |
| **phpactor** | PHP | PHP analysis and refactoring. |
| **r_language_server** | R | R analysis, after a one-time check that the R package `languageserver` is installed. |

Each server starts only when its program is installed (see the table in [section 13](#13-lsp-language-server-protocol)); `:LspAttached` (or a click on the LSP name in the statusline) shows what is attached.

## How language servers are registered (lua/config/lsp.lua)

One file registers every server, so there is no separate chapter for languages such as Rust, Go, TypeScript, Haskell, Swift, PHP, R or Nix: their whole setup is the entry quoted below. There is no Mason in this config: no tool installer manages servers. The programs come from the Nix system or from a devShell (see [section 43](#43-how-the-development-toolchain-fits-together)), and a server is started only if its program is found on PATH.

### Shared capabilities

Verbatim (`lua/config/lsp.lua`, top of the file):

```lua
-- Capabilities shared by every server
vim.lsp.config("*", {
  capabilities = require("lsp_utils").get_default_capabilities(),
})
```

`vim.lsp.config("*", ...)` is the wildcard: every server gets these client capabilities in addition to its own settings. `lsp_utils.get_default_capabilities()` currently returns Neovim's own `vim.lsp.protocol.make_client_capabilities()`, whose 0.12 defaults already include what nvim-ufo needs for folding.

### The server table

Abridged: the Python, Lua, Nix, LaTeX, Rust, Go, Haskell, Swift, TypeScript and PHP, R entries are quoted verbatim; the entries for bashls, clangd, yamlls, marksman, ltex_plus, typos_lsp and tinymist are left out (tinymist is quoted in the [Typst chapter](languages/typst.md#82-typst-typstvim-tinymist-watch-and-preview)). Lines starting with `-- ...` mark the cuts.

```lua
-- Servers: configured here (plus after/lsp/<name>.lua), enabled only when the binary exists
---@type table<string, vim.lsp.Config>
local servers = {
  pyright = { cmd = { "pyright-langserver", "--stdio" } },
  ruff = { cmd = { "ruff", "server" } },
  -- ...

  -- Lua setup
  lua_ls = {
    cmd = { "lua-language-server" },
    -- lua_ls still advertises formatting with format.enable = false: hide it, so nothing (LSP
    -- format, 'formatexpr' for gq) uses lua_ls's formatter next to stylua
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
    settings = {
      Lua = {
        -- one Lua formatter: stylua (through conform.nvim)
        format = { enable = false },
        diagnostics = {
          disable = { "duplicate-set-field" },
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
        },
      },
    },
  },

  -- ...

  -- Nix setup
  nixd = {
    -- --log=error: the default level writes every request to stderr, i.e. into lsp.log
    cmd = { "nixd", "--log=error" },
    settings = {
      nixd = {
        formatting = { command = { "nixpkgs-fmt" } },
      },
    },
  },

  -- ...

  -- LaTeX (texlab comes from the LaTeX devShell; enabled only when executable)
  texlab = { cmd = { "texlab" } },

  -- Rust (rust-analyzer + cargo: rust devShell); binaries checked in `needs` below
  rust_analyzer = { cmd = { "rust-analyzer" } },

  -- Go (gopls + go: go devShell); binaries checked in `needs` below
  gopls = {
    cmd = { "gopls" },
    -- nvim-lspconfig's list also has gotmpl: no filetype detection sets it (:checkhealth vim.lsp
    -- warns "Unknown filetype 'gotmpl'")
    filetypes = { "go", "gomod", "gowork" },
  },

  -- Haskell (haskell-language-server: haskell devShell; nixpkgs ships only the -wrapper binary
  -- (+ haskell-language-server-<ghc version>), no plain haskell-language-server)
  hls = { cmd = { "haskell-language-server-wrapper", "--lsp" } },

  -- Swift (sourcekit-lsp: swift devShell, or Xcode on macOS). nvim-lspconfig also lists c/cpp:
  -- dropped, clangd serves those (no second client next to clangd)
  sourcekit = { cmd = { "sourcekit-lsp" }, filetypes = { "swift", "objc", "objcpp" } },

  -- JavaScript/TypeScript (typescript-language-server: node devShell). No cmd here: nvim-lspconfig's
  -- cmd is a function that prefers the project's node_modules/.bin copy; binary checked in `needs`
  ts_ls = {},

  -- PHP (phpactor: php devShell). nvim-lspconfig's filetypes/root_markers are kept; the config only
  -- pins the command, so the binary check below is exactly executable("phpactor")
  phpactor = { cmd = { "phpactor", "language-server" }, filetypes = { "php" } },

  -- R (languageserver R package: R devShell). Enabled lazily by the one-time probe below, never
  -- by the loop that enables the other servers
  r_language_server = { cmd = { "R", "--no-echo", "-e", "languageserver::run()" } },
}
```

In plain words:

- Each entry is `name = { cmd = {...}, ... }`. Only what differs from nvim-lspconfig's default definition is written; anything left out (filetypes, root markers) is the default. More settings of a server live in `after/lsp/<name>.lua`.
- **Python:** `pyright` and `ruff`, see the [Python chapter](languages/python.md#79-python-pyright-ruff-uv-running-and-debugging).
- **Nix (`nixd`):** `--log=error` because the default level writes every request into the LSP log file; the formatter is `nixpkgs-fmt`.
- **LaTeX (`texlab`):** only the command; texlab comes from the LaTeX devShell.
- **Rust (`rust_analyzer`) and Go (`gopls`):** the comment says which devShell supplies them. `gopls` trims nvim-lspconfig's filetype list to `go`, `gomod`, `gowork` (the default also lists `gotmpl`, which no filetype detection sets, and `:checkhealth vim.lsp` would warn about it).
- **Haskell (`hls`):** the command is `haskell-language-server-wrapper --lsp`, because nixpkgs ships only the `-wrapper` binary (and a per-GHC-version one), no plain `haskell-language-server`.
- **Swift (`sourcekit`):** filetypes are `swift`, `objc`, `objcpp`. The default list also has `c` and `cpp`; they are dropped so clangd serves those and no second client attaches next to it.
- **TypeScript / JavaScript (`ts_ls`):** the entry is empty (`{}`) on purpose. nvim-lspconfig's `cmd` is a function that prefers the project's `node_modules/.bin` copy of the server; setting `cmd` here would replace it. The binary check for it is in `needs` (next section).
- **PHP (`phpactor`):** only the command is pinned; the default filetypes and root markers are kept.
- **R (`r_language_server`):** starts R and runs the `languageserver` package. It is never enabled by the plain loop, only by the probe described below.
- **Lua (`lua_ls`):** see "[Lua: lua_ls and stylua](#lua-lua_ls-and-stylua)" below.

### When is a server enabled

Verbatim:

```lua
-- servers that are NOT enabled at startup (something else enables them later)
local deferred = { r_language_server = true }

-- binaries a server needs, when that is not just cmd[1]
local needs = {
  -- nvim-lspconfig's rust_analyzer root_dir runs `cargo metadata` (it warns "cargo not found")
  rust_analyzer = { "rust-analyzer", "cargo" },
  -- nvim-lspconfig's gopls root_dir runs `go env` (it would fail without `go`)
  gopls = { "gopls", "go" },
  ts_ls = { "typescript-language-server" },
}

--- first binary the server needs that is not on PATH (nil: all present, or nothing known to check)
---@param name string
---@return string?
local function missing_binary(name)
  local config = vim.lsp.config[name]
  local cmd = config and config.cmd
  local bins = needs[name] or (type(cmd) == "table" and { cmd[1] }) or {}
  return vim.iter(bins):find(function(bin)
    return not utils.executable(bin)
  end)
end

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  if not deferred[name] and not missing_binary(name) then
    vim.lsp.enable(name)
  end
end
```

In plain words:

- `deferred`: servers that the loop must not enable. Only `r_language_server`.
- `needs`: servers that need more than their own `cmd[1]`. `rust_analyzer` also needs `cargo` (its root detection runs `cargo metadata`), `gopls` also needs `go` (it runs `go env`), and `ts_ls` has no `cmd` here, so its binary `typescript-language-server` is named explicitly.
- `missing_binary(name)` returns the first required program that is not on PATH, or `nil`.
- The loop at the end registers every server (`vim.lsp.config`) and calls `vim.lsp.enable` only if nothing is missing. So outside a devShell nothing starts and nothing warns; `:LspStart <name>` tells you which program is missing.

### R: the one-time probe

`R` on PATH is not enough, the R package `languageserver` must be installed too, and starting R to find out is slow. So the config asks once, at the first R-like file. Abridged: the comment, the state variables and the autocommand are quoted verbatim; the probe function (the `vim.system` call that runs R and, on success, enables the server and re-triggers `FileType` for R buffers already open) is left out and described below.

```lua
-- r_language_server: `R` alone is not enough, the `languageserver` R package must be installed, and
-- starting R to find out is slow. So: ONE probe, at the first R-ish file, async, cached for the
-- session. Silent when R or the package is missing, or when the probe fails or times out. When it
-- succeeds the server is enabled and started for the R buffers already open (vim.lsp.enable only
-- hooks FileType events that come later; the buffer that triggered the probe is already past it).
local r_probe = nil ---@type "running"|"ok"|"no"|nil
local R_PROBE_TIMEOUT_MS = 10000

-- ... local function probe_r_language_server() ... end

vim.api.nvim_create_autocmd("FileType", {
  group = lsp_keys_group,
  pattern = { "r", "rmd", "quarto" }, -- the filetypes of r_language_server
  desc = "One-time probe for the R languageserver package",
  callback = probe_r_language_server,
})
```

In plain words:

- The probe runs R in the background (`quit(status = !requireNamespace("languageserver", quietly=TRUE))`) with a 10 second timeout. Exit code 0 means the package is there.
- The answer is cached for the session (`r_probe` is `"running"`, `"ok"` or `"no"`). Missing R, a missing package, an error and a timeout are all silent.
- On success the server is enabled and started for the R buffers that are already open (`vim.lsp.enable` alone only hooks later `FileType` events, and the buffer that triggered the probe is already past that point). After you install the package, restart nvim, because a `"no"` stays for the session.

## Lua: lua_ls and stylua

Two things stop `lua_ls` from formatting, so that stylua (run by conform.nvim, see [Formatting (conform.nvim)](#formatting-conformnvim)) is the only Lua formatter: `format = { enable = false }` in the settings, and `on_init` removes the formatting capabilities (lua_ls still advertises them with the setting off). Both are in the `lua_ls` entry above. The rest of the Lua server settings are in `after/lsp/lua_ls.lua` (verbatim):

```lua
-- settings for lua-language-server can be found on https://luals.github.io/wiki/settings/
---@type vim.lsp.Config
return {
  ---@type lspconfig.settings.lua_ls
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      hint = {
        enable = true,
      },
    },
  },
}
```

In plain words: `runtime.version = "LuaJIT"` (Neovim runs LuaJIT), `hint.enable = true` turns on inlay hints (shown with `:LspInlayHints enable`), and the `lua_ls` entry adds `globals = { "vim" }` and ignores `duplicate-set-field`. lazydev.nvim (below) supplies the Neovim API types.

The run key lives in `after/ftplugin/lua.lua`. Abridged:

```lua
-- Disable inserting comment leader after hitting o/O/<Enter>
vim.opt_local.formatoptions:remove { "o", "r" }

for _, lhs in ipairs({ "<F9>", "<leader>rf" }) do -- <leader>rf: the same without function keys
  vim.keymap.set("n", lhs, "<cmd>luafile %<CR>", { buffer = true, silent = true, desc = "run lua file" })
end

```

In plain words:

- `<F9>` and `<Space>rf` run the file with `:luafile %`.
- Formatting has no Lua-specific key: `<Space>fm` and format on save run stylua through conform.nvim (the global key, see [Formatting (conform.nvim)](#formatting-conformnvim)). A project `stylua.toml` is honoured, and a missing stylua is skipped silently.

## typos_lsp: where it attaches

typos_lsp is registered like the others (`cmd = { "typos-lsp" }` in the server table). Its extra rules are in `after/lsp/typos_lsp.lua` (verbatim):

```lua
local root_markers = { "typos.toml", "_typos.toml", ".typos.toml", "pyproject.toml", "Cargo.toml", ".gitignore" }

-- filetypes typos_lsp must never attach to
local skip_ft = {
  -- Snacks.bigfile buffers: would receive the whole file (see lua/config/bigfile.lua)
  bigfile = true,
  -- start screens
  dashboard = true,
  alpha = true,
  snacks_dashboard = true,
}

---@type vim.lsp.Config
return {
  root_markers = root_markers,
  -- typos_lsp has no filetype list, so it would start on every buffer that gets a filetype:
  -- skip special buffers (buftype ~= "": help, terminal, quickfix, plugin panels...) and skip_ft
  root_dir = function(bufnr, on_dir)
    if vim.bo[bufnr].buftype ~= "" or skip_ft[vim.bo[bufnr].filetype] then
      return
    end
    on_dir(vim.fs.root(bufnr, root_markers))
  end,
}
```

In plain words: typos_lsp has no filetype list, so left alone it would start on every buffer with a filetype. The `root_dir` function refuses special buffers (`buftype ~= ""`: help, terminal, quickfix, plugin panels) and the filetypes in `skip_ft` (the big-file buffers and start screens). For real files the root is the nearest folder with one of the `root_markers`, where a `typos.toml` can hold your own accepted words.

## LSP keymaps (all languages)

These keys work per buffer according to what the attached servers support: `K` and `gd` fall back to Vim's builtin versions when no attached server supports hover / definition; `<Space>rn` and `<Space>ca` show one warning instead ("rename: no attached language server supports it", or "... no language server attached to this buffer").

| Keymap | What it does | When to use |
| --- | --- | --- |
| `gd` | **Go to definition**. If there's only one definition, jumps directly. If multiple, opens a location list so you can pick. Deduplicates results. | When you want to see where a function/class/variable is defined. |
| `K` | **Hover documentation**. Shows docs in a floating window with a border (at most 100 x 40). | When you need to check what a function does, its parameters, return type, etc. |
| `<Space>rn` | **Rename symbol**. Renames the symbol under cursor everywhere it appears in the project. | When refactoring: changing a function name, variable name, etc. |
| `<Space>ca` | **Code action**. Shows a menu of available fixes and refactorings. | When the lightbulb icon appears, or when you want to auto-import, extract a variable, fix a lint warning, etc. |
| `<Space>fm` | **Format file** (Visual mode: only the selection). Runs the formatter of the file type asynchronously (stylua, prettier, ruff format, ...); the LSP formatter only when none is installed. | Whenever you want clean formatting, also when format on save is off. |
| `<Space>fo` | **Toggle format on save** for all buffers. | To save once without formatting; press again to turn it back on. |

A worked example of `gd`, `K` and `<Space>rn` on a small Python file is in [section 13](#13-lsp-language-server-protocol) ("[LSP keymaps](#lsp-keymaps)").

## Formatting (conform.nvim)

**conform.nvim** (stevearc/conform.nvim) is the one formatter front end for every file type, also for files without a language server. It runs an external formatter program on the buffer text and applies only what changed, so marks and the cursor stay. Config: `lua/config/conform.lua`.

Where the programs come from: most formatters are installed together with Neovim (the nix wrapper); the others must be on PATH. A formatter that a project devShell provides wins over the global one when you start Neovim inside that devShell. A formatter that is not installed is skipped silently; when no formatter of the file type is available the language server formats instead (if one is attached). `:ConformInfo` shows what will run for the current buffer.

| File type | Formatter |
| --- | --- |
| Lua | stylua |
| Markdown, YAML, JSON, JSONC, CSS, SCSS, HTML, JavaScript, TypeScript, JSX, TSX | prettier |
| sh, bash | shfmt |
| fish | fish_indent |
| Nix | nixfmt |
| TOML | taplo |
| Typst | typstyle |
| TeX, plain TeX, BibTeX | latexindent |
| C, C++, Objective-C, Objective-C++ | clang-format |
| Java | google-java-format |
| Rust | rustfmt |
| Go | goimports, then gofumpt |
| Python | ruff format |
| XML | xmllint |
| SQL | sql-formatter |

### Format on save

Every explicit save formats the file first: `:w`, `:update`, `:x`, `ZZ`, `:wq` and `<Space>w`. The formatter gets 1000 ms. This applies to real file buffers only (not terminals, help or the quickfix window).

Auto-saves never format: the file that auto-save.nvim writes when you leave a buffer or Neovim loses focus is written as it is, so a file you are in the middle of editing is not reshuffled (see [Auto-save](06-windows-terminal-sessions.md#auto-save-auto-savenvim)). Typst and LaTeX files are never auto-saved at all, so format them with `<Space>fm` or by saving with `:w`.

### Keys and commands

| Key / command | Mode | What it does |
| --- | --- | --- |
| `<Space>fm` | Normal, Visual | Format the whole file; in Visual mode (`v`, `V` or Ctrl-v) only the selection. Asynchronous; works also when format on save is off. The buffer changes as one undo step (`u` undoes it) and is not saved |
| `<Space>fo` | Normal | Toggle format on save for ALL buffers. Prints `Format on save: off` or `Format on save: on` |
| `:FormatDisable` + Enter | Command-line | Turn format on save off for all buffers |
| `:FormatDisable!` + Enter | Command-line | Turn it off for the current buffer only (type `!` with Shift+1 right after `FormatDisable`, then Enter) |
| `:FormatEnable` + Enter | Command-line | Turn it on again (undoes both of the above) |
| `:ConformInfo` + Enter | Command-line | Show the formatters configured for this file type and which one will run |

Example (any Lua file with messy spacing like `local x=1`): press `<Space>fm`: the line becomes `local x = 1` and the buffer shows as modified; `u` brings the old text back. Press `<Space>fo` once, save with `:w` and the file is written unformatted; press `<Space>fo` again to turn format on save back on.

After a save that did not format (an auto-save, or format on save switched off) Python and Lua files can show the hint `<file>: file is not formatted (ruff)` or `(stylua)`. It is only a hint; press `<Space>fm` to format.

## Peeking without jumping (glance.nvim)

Plugin: **glance.nvim**. Instead of jumping away to a definition (which changes your context), you can peek at it in an inline popup:

| Keymap | What it does |
| --- | --- |
| `<Space>gd` | Peek at definitions in a popup. You see the code without leaving your current file. Press `<Esc>` to close. |
| `<Space>gr` | Peek at all references. See every place in the project that uses this symbol. |
| `<Space>gi` | Peek at implementations. See how interfaces/abstract methods are implemented. |

Neovim's builtin `grn`, `gra`, `grr`, `gri`, `grt` and `gO` also work (see [section 13](#13-lsp-language-server-protocol)).

**When to use Glance vs `gd`**: Use Glance when you want to quickly check something and come back. Use `gd` when you want to actually navigate to the definition and work there.

## Diagnostics in depth

Diagnostics are the errors, warnings, and hints that the LSP server reports about your code.

**How they appear**:
- Nerd Font signs in the gutter: 󰅚 (error), 󰀪 (warning), 󰋽 (info), 󰌶 (hint)
- A floating window automatically appears after ~500ms when your cursor rests on a line with diagnostics; it closes when you move the cursor or enter insert mode
- The statusline (left side) shows the diagnostic counts with the same icons, e.g. `󰅚 1 󰀪 3`

**Navigation**:

| Keymap | What it does |
| --- | --- |
| `<Space>de` | Jump to the next **error** (skips warnings/hints) |
| `<Space>dE` | Jump to the previous **error** |
| `<Space>dd` | Manually open the diagnostic float for the current line |
| `<Space>db` | Open a Telescope picker showing all diagnostics in the current file |
| `<Space>dw` | Toggle Trouble (`:Trouble diagnostics toggle`): the diagnostics of every buffer Neovim has loaded, grouped by file, not only the current one. A file that was never opened is listed only when its language server sends project-wide diagnostics. The key's `desc` says "Workspace Diagnostics" |
| `<Space>dt` | Toggle diagnostics on/off globally (a message says which; the automatic float stays off while disabled) |

**Sending diagnostics to quickfix**:

| Keymap | What it does |
| --- | --- |
| `<Space>qw` | Put the diagnostics of all open buffers into the quickfix list |
| `<Space>qb` | Put current buffer diagnostics into the quickfix list (with none you only get "No diagnostics in this buffer") |

Then use `:cnext`/`:cprev` to jump through them one by one.

## The lightbulb (nvim-lightbulb)

Plugin: **nvim-lightbulb**. A lightbulb icon appears in the sign column whenever the LSP has code actions available for the current line. This is your cue to press `<Space>ca`.

The lightbulb filters out noisy ruff actions (`source.fixAll.ruff`, `source.organizeImports.ruff`) to avoid false positives.

## Editing the Neovim config in Lua (lazydev.nvim)

Plugin: **lazydev.nvim**. When you edit a Lua file (for example this config), the Lua language server (`lua_ls`) must know the Neovim API. lazydev adds those definitions to the server's workspace, so `vim.*` gets completion, hover (`K`) and signature help instead of "undefined global" warnings. It also adds the modules you `require(...)` in the open file as you go, so only what is used is loaded.

| Item | Detail |
| --- | --- |
| Loads | Only in Lua files (lazy `ft = "lua"`); no cost elsewhere |
| Extra libraries (`lua/plugin_specs.lua`) | The luv types when the file mentions `vim.uv`; the nvim-lspconfig types when it mentions `lspconfig` (type help for `after/lsp/*.lua` files) |
| Keys | None |
| Needs | `lua_ls` attached to the buffer (see the [server table](#the-server-table) above) |
| Not set up | lazydev's optional nvim-cmp source for `require("...")` module names is not configured here, so module-name completion inside `require(...)` only lists modules that are already loaded in the workspace |

How the results reach the menu: the names come from `lua_ls` through the normal LSP source (see [section 45](04-completion-snippets.md#45-autocompletion-in-depth-nvim-cmp), "[Completion sources and helpers](04-completion-snippets.md#completion-sources-and-helpers)").

---

# 18. Code folding (`nvim-ufo`)

Plugin: nvim-ufo. Folds code blocks using the LSP folding ranges, falling back to indentation.

| Keymap | Description |
| --- | --- |
| `za` | Toggle fold at cursor |
| `zA` | Toggle all folds under cursor recursively |
| `zc` / `zo` | Close / open fold at cursor |
| `zC` / `zO` | Close / open all folds recursively |
| `zR` | Open **all** folds in the file |
| `zM` | Close **all** folds in the file |
| `zr` | Open one more fold level (`2zr` = two levels; counted from the folds you see, so it works right after `zM`; in a buffer without ufo folds: one warning) |
| `zm` | Close one more fold level (accepts a count) |
| `<Space>K` | Preview folded lines in a popup |
| `zi` | Toggle folding feature on/off |

Example (a Python file; `zM` closes every fold). Before:

```
 1  def load(path):
 2      with open(path) as f:
 3          data = f.read()
 4      parse(data)
 5      return data
```

After `zM` the whole function is one line: the first line of the fold, then `󰁂  4` at the right edge, the number of hidden lines:

```
 1  def load(path):                                         󰁂  4
```

`za` on that line opens it again, `zR` opens every fold, and `<Space>K` shows the hidden lines in a popup without opening the fold.

Java example (in a real Neovim on a class, without jdtls running: ufo then uses its other fold providers). A class `public class X {` holding several methods:

- `zc` on any line inside a method closes that method; the line shows `󰁂  N` (N = hidden lines). `zo` opens it, `za` toggles it.
- `zM` closes everything: only the class line `public class X {` is left, with the count of all hidden lines.
- After `zM`, `za` on the class line opens ONLY the class: the methods inside stay folded (one level). `zR` opens everything.

---

# 47. Code folding in depth (`nvim-ufo`)

## What it is

Plugin: **nvim-ufo** + **promise-async**. Code folding collapses blocks of code (functions, classes, if-blocks, etc.) into a single line to help you see the big picture.

## How it works

nvim-ufo uses the LSP server's folding ranges to determine what can be folded, and falls back to indentation when no server provides folds.

Folded lines show a preview: the first line of the fold + a count like `󰁂 42` showing how many lines are hidden.

## Folding keymaps

| Keymap | What it does | When to use |
| --- | --- | --- |
| `za` | Toggle the fold under cursor | Quick open/close of a single fold |
| `zR` | Open ALL folds in the file | When you want to see everything |
| `zM` | Close ALL folds in the file | When you want the bird's-eye view |
| `zr` | Open one more fold level (`{N}zr` = N levels; in a buffer without ufo folds: one warning) | Gradually reveal more detail |
| `zm` | Close one more fold level (`{N}zm` = N levels) | Step back to less detail |
| `zo` / `zc` | Open / close fold at cursor | Precise control |
| `zO` / `zC` | Open / close all nested folds at cursor | Deep open/close |
| `<Space>K` | Preview folded lines in popup | See what's inside without unfolding |
| `zi` | Toggle folding on/off globally | Temporarily disable all folding |

See "[Code folding](#18-code-folding-nvim-ufo)" ([section 18](#18-code-folding-nvim-ufo)) for a before/after picture.

**Workflow tip**: Press `zM` to close all folds when you open a large file. This gives you an outline view. Then use `za` to open only the sections you care about. Use `<Space>K` to peek inside folds without opening them.

---

# 21. Treesitter & text objects

## nvim-treesitter (plugin)

Provides tree-sitter syntax highlighting (started automatically per filetype when a parser exists). On Nix systems the parsers come from the nix store and nothing is installed by Neovim; on other systems these parsers are installed automatically: cpp, diff, dockerfile, git_config, git_rebase, gitcommit, html, json, lua, python, toml, vim.

The real setup (`lua/config/treesitter.lua`, verbatim):

```lua
-- nvim-treesitter `main` branch API (the old `nvim-treesitter.configs` module no longer exists).
local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
  return
end

ts.setup({})

-- On Nix systems grammars come from the nix store (neovim.nix, nvim-treesitter.withPlugins)
-- and the filesystem is read-only, so only install parsers on non-Nix systems.
local is_nix = vim.uv.fs_stat("/etc/nixos") or vim.uv.fs_stat("/etc/nix")
if not is_nix then
  ts.install({ "cpp", "diff", "dockerfile", "git_config", "git_rebase", "gitcommit", "html", "json", "lua", "python", "toml", "vim" })
end

-- Highlighting is no longer a module option: start it per buffer when a parser exists.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype == "help" then
      return
    end
    pcall(vim.treesitter.start, args.buf)
  end,
})
```

In plain words:

- This uses the `main` branch API of nvim-treesitter; the old `nvim-treesitter.configs` module no longer exists. If the plugin cannot be loaded, the file stops silently.
- On Nix systems (`/etc/nixos` or `/etc/nix` exists) nothing is installed: the grammars come from the nix store (`neovim.nix`, `withPlugins`) and the file system is read-only. On other systems the twelve listed parsers are installed.
- Highlighting is started per buffer by a `FileType` autocommand: `pcall(vim.treesitter.start, buf)`. The `pcall` makes a filetype without a parser a silent no-op, and the `help` filetype is skipped.

## targets.vim (plugin)

Adds many additional text objects for quotes, brackets, arguments, separators. Works automatically with `d`, `c`, `y`, `v`. If the cursor is not inside the pair, `i(`, `i"` and friends look forward on the line.

## vim-matchup (plugin)

Enhanced `%` matching for language keywords (`if`/`else`/`end`, `do`/`while`, etc.). Shows offscreen match in popup. Also: `g%` (backwards `%`), `[%` / `]%` (start / end of the enclosing pair), `z%` (into the next pair), text objects `i%` / `a%`. With `g%` and `[%` / `]%`, `g%` from `if` goes backwards to `end`. `z%` in a real terminal: from `if` it moves to the closing `)` of the next pair inside the block.

Example (in a real `.lua` file):

```lua
if x then      -- line 1
  a()          -- line 2
else           -- line 3
  b()          -- line 4
end            -- line 5
```

With the cursor on `if`, `%` goes to `else` (line 3), the next `%` to `end` (line 5), the next one back to `if`. `g%` from `if` goes backwards, to `end`.

---

# 46. Treesitter in depth (`nvim-treesitter`)

## What treesitter is

Plugin: **nvim-treesitter**. It parses your code into a syntax tree (like an AST) and uses that for:

- **Syntax highlighting**: More accurate than regex-based highlighting. Understands the actual structure of the code.
- **Symbols**: the aerial outline (`<Space>t`) can read the symbols from the tree.

## Installed parsers

On Nix-managed systems (a folder `/etc/nixos` or `/etc/nix` exists) the parsers come from the nix store (home-manager); Neovim installs nothing. On other systems Neovim installs this fixed set at startup: cpp, diff, dockerfile, git_config, git_rebase, gitcommit, html, json, lua, python, toml, vim. Neovim itself bundles the parsers for c, lua, vim, vimdoc, query and markdown, so those highlight everywhere. Other languages get no tree-sitter highlighting there until you run `:TSInstall <lang>`. On a simulated non-nix system: each of the 12 grammars is downloaded, but the install needs the `tree-sitter` command and a C compiler (`gcc`/`cc`); without the `tree-sitter` command every grammar fails with `Error during "tree-sitter build": ... ENOENT ... 'tree-sitter'` and nothing is installed (the error lines appear again at every start). So on a non-nix machine install `tree-sitter` (the CLI) and a C compiler first.

---

# 19. Code running

Custom function in `lua/mappings.lua`. Opens the output in a vertical split terminal on the left. If the file has no name (the buffer was never saved), the filetype has no runner, or the needed program is not on PATH, you get one warning (naming the devShell to start nvim in) instead of a terminal. A named buffer with unsaved changes runs the version on disk, so save first (`:w`).

| Keymap | Description |
| --- | --- |
| `<Space>rr` | Run current file (auto-detects language) |

Supported: Python, Java, C, C++, C#, JavaScript, TypeScript, Go, Rust, Bash, Lua, Ruby, PHP. Special cases: Java with jdtls attached runs `:JavaRunnerRunMain` (nvim-java's own runner split at the bottom, not the `<Space>rr` terminal on the left); Rust inside a cargo project runs `cargo run`; C# with a `.csproj` runs `dotnet run --project`; Go runs `go run .` for the whole package.

Example: in a saved `hi.py` containing `print("hi")`, `<Space>rr` opens the output on the left and keeps your code on the right. The output stays after the program ends, with a line `[Process exited 0]` below it, until you close it with `<Space>q`:

```
+---------------------------+----------------------+
| hi                        | print("hi")          |
|                           |                      |
| [Process exited 0]        |                      |
+---------------------------+----------------------+
   output (left)               your code (right)
```

After running, the terminal output appears in a split. See [Terminal integration](06-windows-terminal-sessions.md#8-terminal-integration) for how to navigate to/from it and close it.

### Filetype-specific

| Keymap | Filetype | Description |
| --- | --- | --- |
| `<Space>rf` / `<F9>` | Python | Run with `python -u` via AsyncRun (`uv run python -u` inside a uv project) |
| `<Space>rf` / `<F9>` | C++ | Compile (clang++, else g++, C++20) and run in a split below; only mapped when a compiler is on PATH |
| `<Space>rf` / `<F9>` | LaTeX | Compile with vimtex |
| `<Space>rf` / `<F9>` | Lua | Run the file inside Neovim (`:luafile %`) |
| `<Space>rf` / `<F9>` | Vim script | Source the file (`:source %`) |

---

# 55. Code running in depth

## The universal runner

The `<Space>rr` keymap detects the current filetype and runs the appropriate command in a **vertical split terminal** on the left. If the file is unsaved, the filetype has no runner, or the compiler/interpreter is not on PATH, you get ONE warning and no terminal opens (the message names the devShell to start nvim in).

**How it works**:
1. Detects the filetype of the current buffer
2. Builds the correct command (e.g., `python3 file.py`, `go run .`)
3. Opens a vertical split
4. Starts a terminal in that split running the command
5. Output appears in real-time

**After running**:
- The terminal window opens on the LEFT of your code
- Press `<Esc>` in the terminal to enter Normal mode
- Navigate back to your code with `<Ctrl-w>l` or `<Right>`
- Close the terminal window with `<Space>q`, or delete its buffer with `\d`
- Run again with `<Space>rr` (it opens a new terminal each time)

## Language-specific details

| Language | Command used | Notes |
| --- | --- | --- |
| Python | `python3 <file>` | N/A (plain run; needs `python3` on PATH) |
| Java | `:JavaRunnerRunMain` when jdtls (nvim-java) is attached; otherwise `java <file>` | With jdtls nvim-java opens its own runner split at the bottom (not the `<Space>rr` terminal on the left) |
| C | `gcc -Wall -Wextra -std=c11 <file> -o <binary> && <binary>` | Compiles and runs; the binary sits next to the source; needs gcc (c-cpp devShell) |
| C++ | `g++ -Wall -Wextra -std=c++20 <file> -o <binary> && <binary>` | Compiles and runs; needs g++ (c-cpp devShell) |
| C# | `dotnet run --project <nearest .csproj>` | Without a project file: `dotnet run <file>` |
| JavaScript | `node <file>` | N/A (plain run; needs `node` on PATH) |
| TypeScript | `node <file>` | Node runs `.ts` directly |
| Go | `go run .` in the file's directory | Runs the whole package |
| Rust | `cargo run` when a `Cargo.toml` is above the file | Otherwise `rustc <file>` and runs the binary |
| Bash | `bash <file>` | N/A (plain run; needs `bash` on PATH) |
| Lua | `nvim -l <file>` | Neovim's own LuaJIT |
| Ruby | `ruby <file>` | N/A (plain run; needs `ruby` on PATH) |
| PHP | `php <file>` | N/A (plain run; needs `php` on PATH) |

## Filetype-specific runners

Some filetypes have an additional `<Space>rf` runner (also `<F9>`):

| Filetype | What `<Space>rf` / `<F9>` does |
| --- | --- |
| Python | Runs with `python -u <file>` via AsyncRun (unbuffered output; `uv run python -u` in a uv project) |
| C++ | Compiles with `clang++` (else `g++`) `-Wall -Wextra -std=c++20 -O2` and runs it in a horizontal split; only mapped when a compiler is on PATH |
| LaTeX | vimtex compile; only when `latex` is on PATH |

---

# 36. Debugging

| Plugin | Keymap / Command | Description |
| --- | --- | --- |
| nvim-dap | (lazy-loaded) | Debug Adapter Protocol client. Java debugging auto-configured via nvim-java. |
| nvim-gdb | `<Space>dp` | Python buffers only: start pdb on the current file (Linux/Windows only; elsewhere one warning); during the session `<Space>dc` `dn` `ds` `df` `dB` `du` `dv` step and inspect (table in [section 2](README.md#2-day-to-day-cheat-sheet)). `:GdbStart` (gdb) works inside the c-cpp / rust devShells |

---

# 56. Debugging in depth

## Debug adapter protocol (DAP, nvim-dap)

Plugin: **nvim-dap**. DAP is a standardized protocol (created by Microsoft) for communication between an editor and a debugger. It's the same protocol used by VS Code.

**Java**: Debugging is auto-configured via nvim-java (only inside the Java devShell, where `java` is on PATH). Open a Java file, set a breakpoint with `<Space>jp`, and use `<Space>jtC` (debug the current test class) or `<Space>jtM` (debug the current test method). For a `main` class use `:DapContinue`; stepping commands and the other debug keys: [Java section 7](languages/java.md#7-debugging).

**Python**: In Python buffers `<Space>dp` starts `python -m pdb` on the current file through nvim-gdb. Only available on Linux/Windows. During the session use `<Space>dc` (continue), `dn` (next), `ds` (step), `df` (finish), `dB` (breakpoint), `du` (until) and `dv` (evaluate); the full table is in [section 2](README.md#2-day-to-day-cheat-sheet) ("[Python debugger keys](README.md#python-debugger-keys-pdb-through-nvim-gdb)").

## GDB integration (nvim-gdb)

Plugin: **nvim-gdb**. A visual front end for GDB, LLDB, pdb and a few other debuggers: it starts the debugger in a terminal pane under your code and marks the current line in the source window. Available on Linux and Windows only (disabled on macOS). It loads the first time one of the start commands below runs.

| Command | Effect |
| --- | --- |
| `:GdbStart gdb -q ./a.out` | Start GDB on a program (you give the whole gdb command line) |
| `:GdbStartLLDB lldb ./a.out` | The same with LLDB |
| `:GdbStartPDB python -m pdb file.py` | Python's pdb (in Python buffers `<Space>dp` runs this for the current file) |
| `:GdbStartBashDB bashdb script.sh` | bashdb for shell scripts |
| `:GdbStartRR` | Replay a recording made with `rr` |

The command forms are the plugin's documented usage (its README); the pdb one is what `<Space>dp` runs, the others were not run for this guide.

Example (with gdb 17 on a small C file): compile with `gcc -g a.c -o a.out`, open `a.c` in Neovim and run `:GdbStart gdb -q ./a.out`. A gdb terminal opens below the source. Move to the source window (`<Ctrl-\><Ctrl-n>`, then `<Ctrl-w>k`), put the cursor on `int y = x * 3;` and press `<F8>`: a `●` appears in the sign column. `<F5>` (continue) only works while the program runs: before that it prints "The program is not being run." in the gdb pane; start it with `:GdbRun`. It stops at the breakpoint and the line is marked with `▶`. `<F10>` steps over to the next line (the `▶` moves down one line).

```
 ●  5   int y = x * 3;          before :GdbRun: breakpoint
 ▶  5   int y = x * 3;          stopped at the breakpoint
 ▶  6   printf("%d\n", y);      after <F10>
```

The plugin's own start keys (`<Space>dd`, `dl`, `dp`, `db`, `dr`) are switched off in `lua/plugin_specs.lua` so they do not replace the diagnostic keys; `<Space>dp` is a Python-buffer key defined in `after/ftplugin/python.lua`. During a session the plugin sets these keys in the source window (buffer-local, removed again when the session ends):

| Key | Command | Effect |
| --- | --- | --- |
| `<F8>` | `:GdbBreakpointToggle` | Toggle a breakpoint on the cursor line |
| `<F5>` | `:GdbContinue` | Continue |
| `<F10>` | `:GdbNext` | Step over |
| `<F11>` | `:GdbStep` | Step into |
| `<F12>` | `:GdbFinish` | Step out of the current frame |
| `<F4>` | `:GdbUntil` | Run until the cursor line |
| `<Ctrl-p>` / `<Ctrl-n>` | `:GdbFrameUp` / `:GdbFrameDown` | Move one stack frame up / down (plugin default) |
| `<Space>dv` | (evaluate) | Evaluate the word under the cursor (Normal) or the selection (Visual); moved here from the plugin's `<F9>` |

Two commands without a key: `:GdbCreateWatch <command>` (for example `info locals` in GDB) opens a watch window that re-runs the command at every step, and `:GdbLopenBacktrace` / `:GdbLopenBreakpoints` put the backtrace / breakpoints into the location list. The Python-only Space keys for the same actions (`<Space>dc`, `dn`, `ds`, `df`, `dB`, `du`) are in the [Python guide ("Debugging with pdb")](languages/python.md#debugging-with-pdb-nvim-gdb). The F-keys, `<Ctrl-p>` / `<Ctrl-n>` and the commands are the plugin's defaults from its README and help (`:help nvimgdb`).

---

# 43. How the development toolchain fits together

When you open a code file in Neovim, several systems activate automatically behind the scenes:

```
You open a file
  |
  v
Treesitter parses the syntax tree --> accurate highlighting (plus symbols for the aerial outline)
  |
  v
LSP server starts (e.g., pyright for Python) --> diagnostics, go-to-definition, hover, rename, code actions
  |
  v
Completion engine (nvim-cmp) connects to LSP --> autocomplete suggestions as you type
  |
  v
Gitsigns reads git status --> change markers in gutter
  |
  v
Lightbulb watches LSP --> shows icon when code actions are available
  |
  v
Diagnostics config --> errors/warnings appear as Nerd Font signs, a float opens on CursorHold
```

You don't need to start any of this manually. It all happens on file open.

## Enter a language devShell from a running Neovim (`:DevEnv`)

Language servers and tools come from per-language Nix devShells (see "[Configured servers and what they provide](#configured-servers-and-what-they-provide)" in [section 44](#44-language-server-protocol-lsp-in-depth)). Normally direnv loads the devShell when you `cd` into a project and you start `nvim` there. If Neovim is already running without the devShell (for example a `.java` file opened from outside its project, so `java` is not on PATH), you do not have to quit:

1. `:DevEnv <lang>`  Type the command and a devShell name, for example `:DevEnv java`, then `<CR>`. Press `<Tab>` after `:DevEnv ` to list the available names.
2. Wait. The first call for a flake takes about 10 seconds and shows a progress notification (`DevEnv: evaluating the java devShell (about 10 s) ...`). Neovim stays usable meanwhile.
3. Read the result (a check, not an action): one INFO notification, `DevEnv: <lang> ready: ...`, lists what became available (language servers, `nvim-java`, `vimtex`, ...). If something fails you get a WARN notification instead.

What it does, in order:

- Runs `nix print-dev-env --json` on the flake folder, asynchronously.
- Takes only an allowlist of variables from the result: `PATH` (prepended to the current one), `JAVA_HOME`, `CLASSPATH`, `NODE_PATH`, `XDG_DATA_DIRS`, `NIX_CFLAGS_COMPILE`, `NIX_LDFLAGS` and `JAVA_TOOL_OPTIONS` (the Lombok agent). Nothing else (not `HOME`, `SHELL`, ...) is changed.
- Enables every language server whose programs are now on PATH ([section 44](#44-language-server-protocol-lsp-in-depth)) and replays the file type for open buffers, so a server attaches to the file you already have open.
- Starts the language-specific parts: nvim-java, jdtls and spring-boot for `java`; vimtex for `latex`; typst.vim for `typst`.
- Caches the result per flake (keyed on `flake.lock` and `flake.nix`), so the next call is instant. A cache whose Nix store paths were garbage-collected is ignored and evaluated again.

Things to know:

- It is a command only: there is no keybinding.
- It needs `nix` with the `nix-command` and `flakes` features on the machine.
- The flake's shell hook does not run, so the extension links the Java devShell makes (java-debug, java-test) are not created; see [section 78](languages/java.md#78-java-nvim-java-jdtls-tests-debugging) for what that means.
- The environment applies to this Neovim session only. Quit and restart, and you have to run it again (or start Neovim from the devShell).
- Opening a `.java` or `.tex` file without its tool shows a one-time hint: `java not found on PATH: run :DevEnv java to enter its devShell` (same for `latex`).
- The folder holding the flakes is the default below. Change it with `vim.g.devenv_base` (Lua) or the `$NVIM_DEVENV_BASE` environment variable. Only sub-folders that contain a `flake.nix` are listed as devShells.

Every devShell it supports (path: `~/nix/templates/krit/dev-environments/language-specific/<name>`):

| `:DevEnv` name | Path | What it provides (from its `flake.nix`) |
| --- | --- | --- |
| `c-cpp` | `~/nix/templates/krit/dev-environments/language-specific/c-cpp` | clang-tools (clangd), cmake, conan, cppcheck, doxygen, gtest, lcov, vcpkg, codespell, CLion |
| `go` | `~/nix/templates/krit/dev-environments/language-specific/go` | go, gopls, gotools, golangci-lint |
| `haskell` | `~/nix/templates/krit/dev-environments/language-specific/haskell` | ghc, cabal-install, haskell-language-server, ormolu |
| `java` | `~/nix/templates/krit/dev-environments/language-specific/java` | JDK (`JAVA_HOME`), Maven, Gradle, Lombok agent, jdtls wrapper, java-debug and java-test extensions (see [section 78](languages/java.md#78-java-nvim-java-jdtls-tests-debugging)) |
| `jupyter` | `~/nix/templates/krit/dev-environments/language-specific/jupyter` | python313, poetry, ruff, ipykernel, pip and a `.venv` virtual-environment hook |
| `latex` | `~/nix/templates/krit/dev-environments/language-specific/latex` | texlive (scheme-full: `latex`, `latexmk`), texlab, tectonic, pandoc, zathura, latex2html, latex2mathml |
| `nix` | `~/nix/templates/krit/dev-environments/language-specific/nix` | nixd, nixfmt, statix, nh, niv, cachix, lorri, vulnix, dhall-nix |
| `node` | `~/nix/templates/krit/dev-environments/language-specific/node` | nodejs, typescript, typescript-language-server, eslint, prettier, pnpm, yarn |
| `php` | `~/nix/templates/krit/dev-environments/language-specific/php` | php, composer, phpactor |
| `python` | `~/nix/templates/krit/dev-environments/language-specific/python` | Python with black, flake8, isort, pylint, numpy, matplotlib, pip and a virtual-environment hook; pyright, ruff |
| `r` | `~/nix/templates/krit/dev-environments/language-specific/r` | R with the `languageserver` and `knitr` packages |
| `rust` | `~/nix/templates/krit/dev-environments/language-specific/rust` | Rust toolchain, rust-analyzer, cargo-deny, cargo-edit, cargo-watch, openssl, pkg-config |
| `shell` | `~/nix/templates/krit/dev-environments/language-specific/shell` | shellcheck, shfmt, bash-language-server |
| `swift` | `~/nix/templates/krit/dev-environments/language-specific/swift` | swift, sourcekit-lsp |
| `typst` | `~/nix/templates/krit/dev-environments/language-specific/typst` | typst, tinymist, typstyle, prettypst, typstwriter, utpm, zathura |

Language chapters: Java [section 78](languages/java.md#78-java-nvim-java-jdtls-tests-debugging), LaTeX [section 80](languages/latex.md#80-latex-vimtex-texlab-ltex-pdf-viewer), Typst [section 82](languages/typst.md#82-typst-typstvim-tinymist-watch-and-preview).

---

# 53. Documentation lookup

## nvim-devdocs (plugin)

Plugin: **nvim-devdocs**. Browse programming documentation without leaving Neovim.

| Command | What it does |
| --- | --- |
| `:DevdocsOpen` | Open the documentation in a normal buffer (current window) |
| `:DevdocsOpenFloat` | Open in floating window (25 lines tall, 100 chars wide) |
| `:DevdocsInstall` | Install documentation for a language (e.g., `:DevdocsInstall python`) |
| `:DevdocsUninstall` | Remove installed docs |
| `:DevdocsFetch` | Download the list of available documentation sets (the registry); if another command says the registry is not found, run this first |
| `:DevdocsOpenCurrent` | Open the documentation for the current file's filetype in a normal buffer |
| `:DevdocsOpenCurrentFloat` | The same in a floating window |
| `:DevdocsToggle` | Show or hide the floating documentation window |
| `:DevdocsKeywordprg <word>` | Look a word up in the documentation set that is currently open (needs the word as argument; the plugin sets it as `keywordprg` in its documentation buffers, so `K` there uses it) |
| `:DevdocsUpdate [name]` / `:DevdocsUpdateAll` | Update one / all installed documentation sets |

The plugin loads only when you run one of these commands. Without an argument, `:DevdocsOpen`, `:DevdocsInstall` and the others use a Telescope picker. Installing builds the documentation synchronously (large sets can block input for a while) and needs the network; `:DevdocsFetch`, `:DevdocsInstall` and the updates download, reading an installed set is local. The command descriptions follow the plugin's README (not run for this guide). No keys are mapped; the plugin's own "open in browser" key is disabled in `lua/config/devdocs.lua`.

Example (with the Python 3.9 set; downloading and building it took about 40 seconds and freezes Neovim meanwhile, after the question "Building large docs can freeze neovim, continue? y/n"; answer `y` and `<Enter>`):

1. `:DevdocsFetch` downloads the list of available sets.
2. `:DevdocsInstall` opens a picker; type `python`, move to the set you want (the list offers `python-3.9`, `python-3.14`, ...) and press `<Enter>`.
3. In a Python buffer `:DevdocsOpenCurrentFloat` opens a picker over all entries of the installed set (`[python-3.9] print()`, ...) with a preview on the right. Type `print()`, press `<Enter>`: a float (100 columns wide) shows `print(*objects, sep=' ', end='\n', file=sys.stdout, flush=False)` and its description.

The picker filters on the entry names, so typing a file name such as `functions.html print` finds nothing.

## Hover documentation (LSP)

Press `K` on any symbol to see its documentation in a floating window. This pulls from:
- Function signatures and return types
- Docstrings / JSDoc / Javadoc
- Type information

Example (Python buffer): `K` on `open` in `with open(path) as f:` shows a bordered float with the signature, one parameter per line (`(function) def open(` / `file: FileDescriptorOrPath,` / `mode: OpenTextMode = "r",` / ... / `) -> TextIOWrapper[_WrappedBuffer]`). On a keyword such as `with` there is nothing to show and the message "No information available" appears instead.

---

# 59. Useful developer commands

| Command | What it does |
| --- | --- |
| `:LspInfo` | LSP status (runs `:checkhealth vim.lsp`) |
| `:Lazy` | Open plugin manager |
| `:Lazy update` | Update all plugins |
| `:JSONFormat` | Pretty-print JSON through Python (whole file or visual range; no key; `<Space>fm` formats JSON with prettier) |
| `:ToPDF` | Convert markdown to PDF via pandoc |
| `:Redir <cmd>` | Capture any Neovim command output (e.g., `:Redir messages`) |
| `:Telescope keymaps` | Browse all defined keymaps |
| `:checkhealth` | Diagnose Neovim installation issues |
| `:Flog` | Git log graph |
| `:DiffviewOpen` | Side-by-side diff view |
| `:Neogit` | Full git UI |
| `:DevdocsOpen` | Browse programming documentation |
| `:YankyRingHistory` | Browse yank history |
| `:LspAttached` | Popup with the LSP servers attached to this buffer |
| `:LspLog` | Open the LSP log |
| `<Space>u` | Toggle the undo tree (the `:Undotree` command exists only after the first `<Space>u`) |
| `:AerialToggle!` | Toggle the symbol outline (`<Space>t`) |
| `:Dashboard` | Open the start screen |
| `:CodeDiff` | VSCode-style side-by-side diff |
| `:DBUI` / `:Dbee` | SQL clients |

---
---

# Part III: everyday scenarios & recipes

Practical, step-by-step walkthroughs for common tasks.

---

# 75. Real-world developer workflows

Step-by-step walkthroughs of common developer tasks entirely within Neovim.

## Workflow: investigating a bug

1. `<Space>fg` -- search for the error message text across the project
2. `<Enter>` on the relevant result -- jumps to the file and line
3. `gd` -- go to the definition of the function that causes the error
4. `K` -- read the function's documentation
5. `<Space>gr` -- see everywhere this function is called (glance references)
6. `<Ctrl-o>` -- jump back to where you were
7. `<Space>hb` -- check git blame: who changed this and when
8. `]c` / `[c` -- navigate to nearby git changes (hunks)
9. `<Space>hp` -- preview what the hunk changed
10. Fix the issue, `<Space>w` to save, `<Space>rr` to run and test

## Workflow: code review (reviewing your own changes)

1. `<Space>gs` -- open git status
2. Navigate to a changed file, press `<Enter>` to open it
3. `]c` -- jump to the first changed hunk
4. `<Space>hp` -- preview the change
5. `]c` -- next change, repeat
6. `:DiffviewOpen` -- for a full side-by-side diff of all changes
7. When satisfied: `<Space>gw` to stage, `<Space>gc` to commit

## Workflow: refactoring a function name across the project

**If it's a code symbol (function, class, variable):**

1. Place cursor on the name
2. `<Space>rn` -- LSP rename, type new name, Enter
3. Done. All references updated intelligently.

**If it's arbitrary text (e.g., a string, API path, config key):**

1. `<Space>fg` -- search for it first, verify all the places it appears
2. `:grep "oldText"` -- populate the quickfix list
3. `:copen` -- review the matches
4. `:cfdo %s/oldText/newText/gc | update` -- replace with confirmation (`y`/`n` each) and save all files

## Workflow: adding a feature in a new branch

1. `<Space>gbn` -- create a new branch (type name, Enter)
2. `<Space>s` -- open file tree, navigate to where you'll add files
3. `a` in the tree -- create a new file
4. Write code; saving with `:w` formats it (`<Space>fm` formats on demand); `<Space>rr` to run/test
5. `<Space>de` -- jump through any errors
6. `<Space>ca` -- apply code action fixes
7. `<Space>gw` -- stage the file
8. `<Space>gc` -- commit
9. `<Space>gP` -- push

## Workflow: quickly editing a config file

1. `<Space>ff` -- fuzzy find the config file by name
2. Make your changes
3. `<Space>w` -- save
4. If it's the Neovim config: `<Space>sv` to restart Neovim (writes all buffers, restores windows/tabs/files; terminals such as Claude Code are not restarted)

## Workflow: working with JSON

1. Open the JSON file
2. If it's messy: `<Space>fm` formats it with prettier (`:JSONFormat` also pretty-prints it)
3. `<Space>fg` in another terminal to find references to JSON keys
4. `za` to fold/unfold sections for readability
5. `ci"` to change a value inside quotes
6. `<Space>w` to save

Result of step 2: the one-line file `{"a":1,"b":[2,3]}` becomes seven lines with two-space indentation:

```json
{
  "a": 1,
  "b": [
    2,
    3
  ]
}
```

## Workflow: writing documentation (Markdown)

1. Open the `.md` file
2. `<Alt-m>` -- live preview in browser
3. Write content; wrapping is auto-enabled for markdown
4. `^^` -- add a footnote
5. `+` (operator) -- convert lines to a bulleted list
6. `:Tabularize /|` -- align a markdown table
7. `:AddRef label url` -- add a reference link
8. `<Space>cz` -- toggle spell check
9. `]s` / `[s` -- navigate misspelled words
10. `z=` -- fix spelling

## Workflow: pair programming with split views

1. `:vs <file>` -- open another file side-by-side
2. `<Ctrl-w>l` / `<Ctrl-w>h` -- switch between the two files
3. `van` in file A -- select the surrounding syntax node; repeat `an` to grow the selection (for example to the whole function), `in` shrinks it again; then `y` to copy
4. `<Ctrl-w>l` -- switch to file B
5. `p` -- paste the function
6. `<Ctrl-w>=` -- equalize window sizes if they got uneven
7. `<Ctrl-w>o` -- when done, close all splits except current

---

# 35. Java development (`nvim-java`)

The Java keys work only in a Java buffer with the Java language server (jdtls) attached: open nvim inside the Java devShell (`java` on PATH) or run `:DevEnv java` ([section 43](#43-how-the-development-toolchain-fits-together)). Everywhere else the same keys (except the four global debug keys `<Space>jp`, `<Space>jP`, `<Space>jh`, `<Space>jx`) show one warning "Java: jdtls not attached (open nvim inside the Java devShell, or run :DevEnv java)". which-key groups: `<Space>j` Java, `jb` build, `jr` runner, `jt` test, `je` extract.

### Build & run

| Keymap | Description |
| --- | --- |
| `<Space>jbb` | Build workspace |
| `<Space>jbc` | Clean workspace |
| `<Space>jrr` | Run main class |
| `<Space>jrs` | Stop running main |
| `<Space>jrl` | Toggle runner log window |
| `<Space>jrp` | Profiles UI |

### Testing

| Keymap | Description |
| --- | --- |
| `<Space>jtc` | Run all tests in current class |
| `<Space>jtC` | Debug all tests in current class |
| `<Space>jtm` | Run test method under cursor |
| `<Space>jtM` | Debug test method under cursor |
| `<Space>jtr` | View last test report |

### Refactoring

| Keymap | Description |
| --- | --- |
| `<Space>jev` | Extract variable |
| `<Space>jeo` | Extract variable (all occurrences) |
| `<Space>jec` | Extract constant |
| `<Space>jem` | Extract method |
| `<Space>jef` | Extract field |
| `<Space>jj` | Change JDK runtime |
| `<Space>jd` | Configure debugger (DAP) |
| `<Space>jp` | Toggle breakpoint (global map, works in any buffer) |
| `<Space>jh` | Show value under cursor while the debugger is paused |
| `<Space>jP` | Clear ALL breakpoints in all files (no undo; capital P) |
| `<Space>jx` | Terminate the debug session |

Worked examples of these keys are in [section 78](languages/java.md#78-java-nvim-java-jdtls-tests-debugging) ([`languages/java.md`](languages/java.md#78-java-nvim-java-jdtls-tests-debugging)).

---

# 54. Java development in depth

Plugin: **nvim-java**.

This is the most feature-rich language setup in this config. It provides a full Java IDE experience. nvim-java loads when you open the first Java file of the session (not at startup), so opening a Java file takes a moment longer the first time; non-Java sessions do not pay for it.

## How it works

nvim-java wraps the Eclipse JDT Language Server (jdtls) and adds:
- Build system integration
- Test runner and debugger
- Spring Boot tools
- Refactoring commands
- DAP (Debug Adapter Protocol) for step-through debugging

All of this only starts inside the Java devShell (`java` on PATH). Elsewhere `.java` files open without Java tooling, and the `<Space>j` keys show one warning "Java: jdtls not attached (open nvim inside the Java devShell, or run :DevEnv java)".

On Nix systems the JDK comes from the Java devShell (`JAVA_HOME`) and nvim-java never downloads one. On other systems nvim-java auto-installs a JDK.

## Build & run

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jbb` | `:JavaBuildBuildWorkspace` | Compile the entire workspace |
| `<Space>jbc` | `:JavaBuildCleanWorkspace` | Clear the jdtls workspace cache (after a Yes/No question; jdtls is restarted automatically) |
| `<Space>jrr` | `:JavaRunnerRunMain` | Run the main class |
| `<Space>jrs` | `:JavaRunnerStopMain` | Stop the running program |
| `<Space>jrl` | `:JavaRunnerToggleLogs` | Show/hide the runner log window (it opens as a full-width, 15-line split at the bottom) |
| `<Space>jrp` | `:JavaProfile` | Profiles UI |

## Testing

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jtc` | `:JavaTestRunCurrentClass` | Run all `@Test` methods in the current class |
| `<Space>jtC` | `:JavaTestDebugCurrentClass` | Debug all tests (with breakpoints) |
| `<Space>jtm` | `:JavaTestRunCurrentMethod` | Run only the test method under cursor |
| `<Space>jtM` | `:JavaTestDebugCurrentMethod` | Debug only the test under cursor |
| `<Space>jtr` | `:JavaTestViewLastReport` | Show pass/fail results from the last test run |

## Debugging

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jd` | `:JavaDapConfig` | Configure the debug adapter (auto-runs on Java file open, but can be re-triggered) |

DAP is configured automatically when jdtls starts. Four global keys:

| Keymap | Same as | What it does |
| --- | --- | --- |
| `<Space>jp` | `:DapToggleBreakpoint` | Toggle a breakpoint on the cursor line |
| `<Space>jP` | `:DapClearBreakpoints` | Remove ALL breakpoints in all files at once; no undo (capital P on purpose) |
| `<Space>jh` | `:lua require("dap.ui.widgets").hover()` | While paused: value of the variable under the cursor in a float |
| `<Space>jx` | `:DapTerminate` | End the debug session |

Stepping and continuing deliberately have no keys: type `:DapContinue`, `:DapStepOver`, `:DapStepInto`, `:DapStepOut`. Workflow: [Java section 7](languages/java.md#7-debugging).

## Refactoring

| Keymap | Command | What it does |
| --- | --- | --- |
| `<Space>jev` | `:JavaRefactorExtractVariable` | Extract the expression under the cursor (or selection) to a local variable |
| `<Space>jeo` | `:JavaRefactorExtractVariableAllOccurrence` | Extract and replace ALL occurrences of the expression |
| `<Space>jec` | `:JavaRefactorExtractConstant` | Extract a constant |
| `<Space>jem` | `:JavaRefactorExtractMethod` | Extract a method |
| `<Space>jef` | `:JavaRefactorExtractField` | Extract a field |
| `<Space>jj` | `:JavaSettingsChangeRuntime` | Switch the JDK version |

Only the `:JavaBuild*` and `:JavaRefactor*` commands exist after jdtls has attached; the other `:Java*` commands exist as soon as nvim-java is loaded but do nothing useful without jdtls.

Worked examples of these keys are in [section 78](languages/java.md#78-java-nvim-java-jdtls-tests-debugging) ([`languages/java.md`](languages/java.md#78-java-nvim-java-jdtls-tests-debugging)).

---
