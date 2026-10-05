-- :DevEnv <lang>  ->  enter a language devShell from the running Neovim.
--
-- Runs `nix print-dev-env --json <flake>` (async, 6-12 s, results cached per flake.lock), applies
-- an ALLOWLIST of its variables to vim.env, then late-starts what startup skipped: nvim-java +
-- jdtls (java), vimtex (latex), typst.vim (typst) and every LSP server whose binaries are on PATH
-- now (lua/config/lsp.lua). Needs nix with the nix-command and flakes features on the host; the
-- flakes themselves are the ones direnv's `use_dev_env` uses.
--
-- Not done on purpose: the flake's shellHook does not run under print-dev-env, so the Java
-- devShell's extension links (java-debug, java-test, ./.direnv/tools/jdtls) are not created here;
-- jdtls works without them (nvim-java brings its own copies), nvim-java warns once if they are missing.
--
-- The flakes' base directory: vim.g.devenv_base, else $NVIM_DEVENV_BASE, else the default below.
local utils = require("utils")

local M = {}

local DEFAULT_BASE = "~/nix/templates/krit/dev-environments/language-specific"
local TIMEOUT_MS = 180000

-- the ONLY variables taken from the devShell (never HOME, TMPDIR, SHELL, NIX_BUILD_TOP, IN_NIX_SHELL,
-- TERM, OLDPWD, ...). PATH is prepended to the current one; the rest replace; null values are skipped
local ALLOWLIST = {
  "PATH",
  "JAVA_HOME",
  "CLASSPATH",
  "NODE_PATH",
  "XDG_DATA_DIRS",
  "NIX_CFLAGS_COMPILE",
  "NIX_LDFLAGS",
  "JAVA_TOOL_OPTIONS", -- Lombok javaagent; only present when the flake exports it
}

--- the folder holding one flake per language
---@return string
function M.base()
  return vim.fn.expand(vim.g.devenv_base or vim.env.NVIM_DEVENV_BASE or DEFAULT_BASE)
end

--- language names = the sub-folders that hold a flake.nix
---@return string[]
function M.languages()
  local langs = {}
  for name, type in vim.fs.dir(M.base()) do
    if (type == "directory" or type == "link") and vim.uv.fs_stat(vim.fs.joinpath(M.base(), name, "flake.nix")) then
      table.insert(langs, name)
    end
  end
  table.sort(langs)
  return langs
end

---@param msg string
---@param level? integer
local function notify(msg, level)
  vim.notify("DevEnv: " .. msg, level or vim.log.levels.INFO)
end

local function warn(msg)
  notify(msg, vim.log.levels.WARN)
end

---@param path string
---@return string?
local function read_file(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local data = f:read("*a")
  f:close()
  return data
end

--- cache file for a flake: keyed by the hash of flake.lock + flake.nix (a changed lock or flake
--- re-evaluates; the store paths in the cache are checked for existence before use)
---@param dir string
---@param lang string
---@return string?
local function cache_path(dir, lang)
  local lock = read_file(vim.fs.joinpath(dir, "flake.lock"))
  local flake = read_file(vim.fs.joinpath(dir, "flake.nix"))
  if not lock or not flake then
    return nil
  end
  local cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "devenv")
  utils.may_create_dir(cache_dir)
  return vim.fs.joinpath(cache_dir, lang .. "-" .. vim.fn.sha256(lock .. flake):sub(1, 16) .. ".json")
end

--- keep only the allowlisted, non-null string values
---@param json table decoded `nix print-dev-env --json`
---@return table<string,string>
function M.extract(json)
  local vars = {}
  for _, name in ipairs(ALLOWLIST) do
    local v = json.variables and json.variables[name]
    local value = type(v) == "table" and v.value or nil
    if type(value) == "string" and value ~= "" then
      vars[name] = value
    end
  end
  return vars
end

--- PATH entries of `new` first, then the current ones, duplicates dropped
---@param new string
---@param current string
---@return string
function M.merge_path(new, current)
  local sep = utils.has("win32") and ";" or ":"
  local seen, out = {}, {}
  for _, entry in ipairs(vim.split(new .. sep .. current, sep, { plain = true, trimempty = true })) do
    if not seen[entry] then
      seen[entry] = true
      table.insert(out, entry)
    end
  end
  return table.concat(out, sep)
end

---@param vars table<string,string>
function M.apply(vars)
  for name, value in pairs(vars) do
    if name == "PATH" then
      vim.env.PATH = M.merge_path(value, vim.env.PATH or "")
    else
      vim.env[name] = value
    end
  end
end

--- a cached result is only trusted while its store paths still exist (nix-collect-garbage)
---@param vars table<string,string>
---@return boolean
local function still_valid(vars)
  local first = vars.PATH and vim.split(vars.PATH, ":", { plain = true })[1]
  return first ~= nil and vim.uv.fs_stat(first) ~= nil and (vars.JAVA_HOME == nil or vim.uv.fs_stat(vars.JAVA_HOME) ~= nil)
end

--- run an Ex command for a buffer that already has its filetype, so ftplugin/FileType hooks of a
--- plugin that only just arrived run for it
---@param filetypes string[]
local function replay_filetype(filetypes)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.list_contains(filetypes, vim.bo[buf].filetype) then
      vim.api.nvim_exec_autocmds("FileType", { buffer = buf })
    end
  end
end

--- load a lazy.nvim plugin that has no trigger at startup (spec: lazy = true while the tool was
--- missing). Its init() ran at startup but saw the old PATH, so it runs again before the load
---@param name string
---@return boolean ok, string? reason
local function load_skipped_plugin(name)
  local ok_cfg, Config = pcall(require, "lazy.core.config")
  local plugin = ok_cfg and Config.plugins[name]
  if not plugin then
    return false, name .. " is not in the plugin list"
  end
  if plugin._.loaded then
    return true
  end
  if not plugin._.installed then
    return false, name .. " is not installed (run :Lazy sync)"
  end
  if plugin.init then
    local ok, err = pcall(plugin.init, plugin)
    if not ok then
      return false, name .. " init failed: " .. tostring(err)
    end
  end
  local ok, err = pcall(require("lazy").load, { plugins = { name } })
  if not ok then
    return false, name .. ": " .. tostring(err)
  end
  return plugin._.loaded ~= nil, name .. " did not load"
end

--- per-language late start. Each entry returns a list of "what became available" strings
---@type table<string, fun(avail: string[], failed: string[])>
local late = {}

late.java = function(avail, failed)
  if not utils.executable("java") then
    table.insert(failed, "java is still not on PATH")
    return
  end
  table.insert(avail, "java " .. (vim.env.JAVA_HOME and "(JAVA_HOME set)" or ""))
  local lazy_ok, Config = pcall(require, "lazy.core.config")
  local plugin = lazy_ok and Config.plugins["nvim-java"]
  if not plugin then
    table.insert(failed, "nvim-java is not in the plugin list")
    return
  end
  if plugin._.loaded then
    -- already loaded by an earlier .java buffer, without java: run its setup again, now with it
    local ok, err = pcall(require("config.nvim-java").setup)
    if not ok then
      table.insert(failed, "nvim-java setup: " .. tostring(err))
      return
    end
  else
    -- first load: the spec's config() runs setup with java on PATH
    local ok, err = pcall(require("lazy.core.loader").load, plugin, { start = "DevEnv" })
    if not ok then
      table.insert(failed, "nvim-java: " .. tostring(err))
      return
    end
  end
  table.insert(avail, "nvim-java (jdtls, spring-boot-tools)")
  -- jdtls only hooks FileType events that come later: start it for open Java buffers
  replay_filetype({ "java" })
  -- debug/test extensions: the devShell's shellHook links them (it does not run here); nvim-java
  -- ships its own copies in stdpath("data"), so only warn when those are missing too
  local pkgs = vim.fs.joinpath(vim.fn.stdpath("data"), "nvim-java", "packages")
  for _, ext in ipairs({ "java-debug", "java-test" }) do
    if vim.fn.isdirectory(vim.fs.joinpath(pkgs, ext)) == 0 then
      warn(ext .. " extension not linked (the devShell shellHook does not run here): debugging/tests may be unavailable until nvim-java installs it or direnv enters the devShell once")
    end
  end
end

late.latex = function(avail, failed)
  if not utils.executable("latex") then
    table.insert(failed, "latex is still not on PATH")
    return
  end
  table.insert(avail, "latex")
  local ok, reason = load_skipped_plugin("vimtex")
  if ok then
    table.insert(avail, "vimtex")
    replay_filetype({ "tex", "plaintex", "latex" })
  else
    table.insert(failed, reason)
  end
end

late.typst = function(avail, failed)
  if not utils.executable("typst") then
    table.insert(failed, "typst is still not on PATH")
    return
  end
  table.insert(avail, "typst")
  local ok, reason = load_skipped_plugin("typst.vim")
  if ok then
    table.insert(avail, "typst.vim")
    replay_filetype({ "typst" })
  else
    table.insert(failed, reason)
  end
end

---@param lang string
local function finish(lang)
  local avail, failed = {}, {}
  -- LSP servers whose binaries are on PATH now (all languages)
  local ok_lsp, lsp = pcall(require, "config.lsp")
  if ok_lsp and lsp.enable_available then
    for _, name in ipairs(lsp.enable_available()) do
      table.insert(avail, "LSP " .. name)
    end
  end
  if late[lang] then
    late[lang](avail, failed)
  end
  if #avail > 0 then
    notify(lang .. " ready: " .. table.concat(avail, ", "))
  elseif #failed == 0 then
    notify(lang .. " environment applied (no new language server or plugin was waiting)")
  end
  for _, msg in ipairs(failed) do
    warn(lang .. ": " .. msg)
  end
end

local running = {} ---@type table<string, boolean>

--- activate a language devShell
---@param lang string
function M.enter(lang)
  if lang == nil or lang == "" then
    warn("usage :DevEnv <lang> (" .. table.concat(M.languages(), ", ") .. ")")
    return
  end
  local dir = vim.fs.joinpath(M.base(), lang)
  if not vim.list_contains(M.languages(), lang) then
    warn(("no devShell '%s' in %s (known: %s)"):format(lang, M.base(), table.concat(M.languages(), ", ")))
    return
  end
  if running[lang] then
    warn(lang .. ": already evaluating, please wait")
    return
  end

  -- cached result for this flake.lock?
  local cache = cache_path(dir, lang)
  local cached = cache and read_file(cache)
  if cached then
    local ok, vars = pcall(vim.json.decode, cached)
    if ok and type(vars) == "table" and still_valid(vars) then
      M.apply(vars)
      finish(lang)
      return
    end
  end

  if not utils.executable("nix") then
    warn("nix not found on PATH, cannot enter the " .. lang .. " devShell")
    return
  end
  running[lang] = true
  notify(("evaluating the %s devShell (about 10 s) ..."):format(lang))
  local spawned, err = pcall(vim.system, {
    "nix",
    "--extra-experimental-features",
    "nix-command flakes",
    "print-dev-env",
    "--json",
    dir,
  }, { text = true, timeout = TIMEOUT_MS, stdin = false }, function(res)
    vim.schedule(function()
      running[lang] = nil
      if res.code ~= 0 then
        local lines = vim.split(vim.trim(res.stderr or ""), "\n", { plain = true })
        warn(("%s: nix print-dev-env failed (%s): %s"):format(lang, res.signal ~= 0 and "timeout/killed" or res.code, lines[#lines] or ""))
        return
      end
      local ok, json = pcall(vim.json.decode, res.stdout or "")
      if not ok or type(json) ~= "table" then
        warn(lang .. ": could not parse the nix print-dev-env output")
        return
      end
      local vars = M.extract(json)
      if not vars.PATH then
        warn(lang .. ": the devShell has no PATH, nothing applied")
        return
      end
      if cache then
        pcall(function()
          local f = assert(io.open(cache, "wb"))
          f:write(vim.json.encode(vars))
          f:close()
        end)
      end
      M.apply(vars)
      finish(lang)
    end)
  end)
  if not spawned then
    running[lang] = nil
    warn("could not start nix: " .. tostring(err))
  end
end

vim.api.nvim_create_user_command("DevEnv", function(opts)
  M.enter(opts.fargs[1])
end, {
  nargs = 1,
  desc = "Enter a language devShell (java, latex, ...) from this Neovim session",
  complete = function(arglead)
    return vim.tbl_filter(function(n)
      return vim.startswith(n, arglead)
    end, M.languages())
  end,
})

-- One hint per session when a Java/LaTeX file is opened and its toolchain is missing
local hints = { java = "java", tex = "latex" } ---@type table<string, string> filetype -> binary (and :DevEnv name)
local hinted = {}
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("devenv_hint", { clear = true }),
  pattern = vim.tbl_keys(hints),
  desc = "Hint at :DevEnv when the Java/LaTeX toolchain is missing",
  callback = function(ev)
    local bin = hints[ev.match]
    if hinted[bin] or utils.executable(bin) or not utils.executable("nix") or not vim.list_contains(M.languages(), bin) then
      return
    end
    hinted[bin] = true
    vim.notify(("%s not found on PATH: run :DevEnv %s to enter its devShell"):format(bin, bin), vim.log.levels.WARN)
  end,
})

return M
