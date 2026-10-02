local utils = require("utils")

-- 2. Configure Global Native LSP behavior
vim.lsp.config("*", {
  capabilities = require("lsp_utils").get_default_capabilities(),
})

-- 3. Create the Attachment Logic (Keymaps + Format on Save)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_buf_conf", { clear = true }),
  callback = function(event_context)
    local client = vim.lsp.get_client_by_id(event_context.data.client_id)
    if not client then return end

    local bufnr = event_context.buf
    local map = function(mode, l, r, opts)
      opts = vim.tbl_extend("force", { silent = true, buffer = bufnr }, opts or {})
      vim.keymap.set(mode, l, r, opts)
    end

    -- Custom Go-To-Definition logic
    map("n", "gd", function()
      vim.lsp.buf.definition {
        on_list = function(options)
          local unique_defs, def_loc_hash = {}, {}
          for _, def_location in pairs(options.items) do
            local key = def_location.filename .. def_location.lnum
            if not def_loc_hash[key] then
              def_loc_hash[key] = true
              table.insert(unique_defs, def_location)
            end
          end
          options.items = unique_defs
          vim.fn.setloclist(0, {}, " ", options)
          if #options.items > 1 then vim.cmd.lopen() else vim.cmd([[silent! lfirst]]) end
        end,
      }
    end, { desc = "unique definition" })

    -- Standard Mappings
    map("n", "K", function()
      vim.lsp.buf.hover {
        border = "single",
        max_height = 40,
        max_width = 100,
      }
    end, { desc = "LSP hover" })
    map("n", "<space>rn", vim.lsp.buf.rename, { desc = "rename" })
    map("n", "<space>ca", vim.lsp.buf.code_action, { desc = "code action" })
  end,
})
-- 4. Define and Enable Servers
---@type table<string, vim.lsp.Config>
local servers = {
  pyright = { cmd = { "pyright-langserver", "--stdio" } },
  ruff = { cmd = { "ruff", "server" } },
  bashls = { cmd = { "bash-language-server", "start" } },

  -- C/C++ (clang-tools: c-cpp devShell or a global install); filetypes in after/lsp/clangd.lua
  clangd = { cmd = { "clangd" } },

  -- Lua setup
  lua_ls = {
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        format = { enable = true },
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

  -- YAML setup
  yamlls = {
    cmd = { "yaml-language-server", "--stdio" },
    -- only plain yaml: nothing here sets yaml.docker-compose/gitlab/helm-values
    filetypes = { "yaml" },
    settings = { yaml = { format = { enable = true } } }
  },


  -- Markdown setup
  marksman = {
    cmd = { "marksman", "server" },
    -- only plain markdown: nothing here sets markdown.mdx (lspconfig's default list has it, and
    -- :checkhealth vim.lsp warns "Unknown filetype 'markdown.mdx'")
    filetypes = { "markdown" },
    -- no formatting here: marksman has no formatting provider; <Space>fm in markdown runs
    -- prettier (after/ftplugin/markdown.lua)
  },

  -- Grammar/spell checking (LanguageTool) for prose filetypes
  ltex_plus = { cmd = { "ltex-ls-plus" } },

  -- Source-code spell checker (typos); attaches to every filetype
  typos_lsp = { cmd = { "typos-lsp" } },

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

  -- Typst setup
  tinymist = {
    cmd = { "tinymist" },
    filetypes = { "typst" },
    root_dir = function(bufnr, on_dir)
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local root = vim.fs.dirname(vim.fs.find({ "typst.toml", ".git" }, { path = fname, upward = true })[1])
        or vim.fs.dirname(fname)
      on_dir(root)
    end,
    settings = {
      exportPdf = "never",
      outputPath = "$root/out/$name",
      formatterMode = "typstyle",
    },
  },

  -- LaTeX (texlab comes from the LaTeX devShell; enabled only when executable)
  texlab = { cmd = { "texlab" } },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  if utils.executable(config.cmd[1]) then
    vim.lsp.enable(name)
  end
end

-- LSP related commands (nvim-lspconfig no longer defines these on nvim 0.12)
vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", { desc = "Show LSP Info" })

vim.api.nvim_create_user_command("LspLog", function(_)
  vim.cmd(string.format("edit %s", vim.fn.fnameescape(vim.lsp.log.get_filename())))
end, { desc = "Show LSP log" })

-- :LspRestart / :LspStop [name...] -> :lsp restart|stop [name...] (no name = the clients of this
-- buffer; completion = running clients, as :lsp itself offers)
for _, sub in ipairs { "restart", "stop" } do
  local cmd_name = "Lsp" .. sub:sub(1, 1):upper() .. sub:sub(2)
  vim.api.nvim_create_user_command(cmd_name, function(opts)
    -- :lsp reports e.g. "No active clients named 'x'" as an error; show it without a Lua traceback
    local ok, err = pcall(vim.cmd, vim.trim("lsp " .. sub .. " " .. opts.args))
    if not ok then
      vim.notify(cmd_name .. ": " .. tostring(err):gsub("^.*Vim%(lsp%):", ""), vim.log.levels.ERROR)
    end
  end, {
    nargs = "*",
    desc = cmd_name:sub(4) .. " LSP clients (this buffer's, or the given names)",
    complete = function(_, line)
      local args = line:gsub("^%s*%S+%s*", "", 1)
      return vim.fn.getcompletion("lsp " .. sub .. " " .. args, "cmdline")
    end,
  })
end

--- enabled configs that apply to the buffer's filetype and have no live client attached to it
--- (a stopped client can stay listed until its server exits)
---@param bufnr integer
---@return string[]
local function startable_names(bufnr)
  local ft, names = vim.bo[bufnr].filetype, {}
  for _, config in ipairs(vim.lsp.get_configs { enabled = true }) do
    local live = vim.tbl_filter(function(c) return not c:is_stopped() end, vim.lsp.get_clients { bufnr = bufnr, name = config.name })
    if (config.filetypes == nil or vim.list_contains(config.filetypes, ft)) and #live == 0 then
      table.insert(names, config.name)
    end
  end
  table.sort(names)
  return names
end

-- :LspStart [name...]: Nvim 0.12 has no `:lsp start`. No name: start every enabled config that
-- applies to this buffer and is not running (e.g. after :LspStop), via Nvim's own enable logic.
-- With names: start just those configs for this buffer.
vim.api.nvim_create_user_command("LspStart", function(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  if #opts.fargs == 0 then
    if #startable_names(bufnr) == 0 then
      vim.notify("LspStart: no enabled language server left to start for this buffer", vim.log.levels.WARN)
      return
    end
    vim.api.nvim_exec_autocmds("FileType", { group = "nvim.lsp.enable", buffer = bufnr })
    return
  end
  local ft = vim.bo[bufnr].filetype
  for _, name in ipairs(opts.fargs) do
    local config = not name:find("*", 1, true) and vim.lsp.config[name] or nil
    local cmd = config and config.cmd
    if not config then
      vim.notify(("LspStart: no config named '%s'"):format(name), vim.log.levels.WARN)
    elseif config.filetypes and not vim.list_contains(config.filetypes, ft) then
      vim.notify(("LspStart: %s does not handle filetype '%s'"):format(name, ft), vim.log.levels.WARN)
    elseif type(cmd) == "table" and not utils.executable(cmd[1]) then
      vim.notify(("LspStart: %s: %s not found on PATH"):format(name, cmd[1]), vim.log.levels.WARN)
    else
      config = vim.deepcopy(config)
      local function start(root)
        config.root_dir = root
        vim.lsp.start(config, { bufnr = bufnr, reuse_client = config.reuse_client })
      end
      if type(config.root_dir) == "function" then
        config.root_dir(bufnr, function(root) vim.schedule(function() start(root) end) end)
      else
        start(config.root_dir or (config.root_markers and vim.fs.root(bufnr, config.root_markers)) or nil)
      end
    end
  end
end, {
  nargs = "*",
  desc = "Start LSP clients for this buffer (enabled ones not running, or the given names)",
  complete = function(arglead)
    return vim.tbl_filter(function(n) return vim.startswith(n, arglead) end, startable_names(0))
  end,
})

-- Runtime toggle for LSP inlay hints (off by default)
vim.g.lsp_inlay_hint_enabled = false

vim.api.nvim_create_user_command("LspInlayHints", function(context)
  if context.args == "enable" then
    vim.g.lsp_inlay_hint_enabled = true
  elseif context.args == "disable" then
    vim.g.lsp_inlay_hint_enabled = false
  end
  -- some servers also need hints enabled in their own settings (lua_ls: settings.Lua.hint.enable = true)
  vim.lsp.inlay_hint.enable(vim.g.lsp_inlay_hint_enabled)
end, {
  nargs = 1,
  force = true,
  desc = "Enable/disable LSP inlay hints globally",
  complete = function()
    return { "enable", "disable" }
  end,
})

vim.api.nvim_create_user_command("LspAttached", function()
  local size = { width = 40, height = 10 }
  local win_width, win_height = vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0)
  local position = {
    col = math.max(0, math.floor((win_width - size.width) / 2)),
    row = math.max(0, math.floor((win_height - size.height) / 2)),
  }
  require("lsp_utils").show_lsp_menu(size, position)
end, { desc = "Show LSP attached to current buffer" })
