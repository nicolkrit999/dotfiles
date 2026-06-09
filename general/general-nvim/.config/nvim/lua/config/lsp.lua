local utils = require("utils")

-- 1. Protect against crash if lspconfig is missing
local status, lspconfig = pcall(require, "lspconfig")
if not status then return end

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
    map("n", "K", function() vim.lsp.buf.hover({ border = "single" }) end)
    map("n", "<space>rn", vim.lsp.buf.rename, { desc = "rename" })
    map("n", "<space>ca", vim.lsp.buf.code_action, { desc = "code action" })
  end,
})
-- 4. Define and Enable Servers
local servers = {
  pyright = { cmd = { "pyright-langserver", "--stdio" } },
  ruff = { cmd = { "ruff", "server" } },
  bashls = { cmd = { "bash-language-server", "start" } },

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
    settings = { yaml = { format = { enable = true } } }
  },


  -- Markdown setup
  marksman = {
    cmd = { "marksman", "server" },
    settings = {
      marksman = {
        formatting = { command = { "prettier", "--parser=markdown" } },
      },
    },
  },

  -- Nix setup
  nixd = {
    cmd = { "nixd" },
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
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  if utils.executable(config.cmd[1]) then
    vim.lsp.enable(name)
  end
end
