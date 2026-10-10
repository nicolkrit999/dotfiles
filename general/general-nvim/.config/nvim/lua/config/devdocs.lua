-- devdocs.nvim registers :DevDocs without completion; this adds Tab completion for the sub-commands and doc names.
local M = {}

local SUBCOMMANDS = { "fetch", "install", "get", "delete" }

local function load_plugin()
  require("lazy").load({ plugins = { "devdocs.nvim" } })
  return package.loaded["devdocs"] ~= nil
end

local function complete(arglead, cmdline)
  local args = vim.split(vim.trim(cmdline), "%s+")
  local typing_sub = #args < 2 or (#args == 2 and not cmdline:match("%s$"))
  local candidates = SUBCOMMANDS
  if not typing_sub then
    candidates = {}
    if not load_plugin() then
      return {}
    end
    local devdocs = require("devdocs")
    if args[2] == "install" then
      local ok, docs = pcall(devdocs.GetAllDocs)
      for _, doc in ipairs(ok and docs or {}) do
        candidates[#candidates + 1] = doc.slug
      end
    elseif args[2] == "get" or args[2] == "delete" then
      local ok, docs = pcall(devdocs.GetInstalledDocs)
      candidates = ok and docs or {}
    end
  end
  return vim.tbl_filter(function(c)
    return vim.startswith(c, arglead)
  end, candidates)
end

-- Before the plugin loads: a stub that loads it (on Tab or on run). The plugin's setup then replaces it.
function M.stub()
  vim.api.nvim_create_user_command("DevDocs", function(o)
    if load_plugin() then
      vim.cmd("DevDocs " .. o.args)
    end
  end, { nargs = "*", complete = complete, desc = "DevDocs: fetch, install, get or delete documentation" })
end

-- The plugin defines :DevDocs inside setup() without completion, so the definition is wrapped once.
function M.setup()
  local create = vim.api.nvim_create_user_command
  vim.api.nvim_create_user_command = function(name, command, opts)
    if name == "DevDocs" then
      opts = vim.tbl_extend("force", opts or {}, { complete = complete })
    end
    return create(name, command, opts)
  end
  local ok, err = pcall(require("devdocs").setup, {})
  vim.api.nvim_create_user_command = create
  if not ok then
    error(err)
  end
end

return M
