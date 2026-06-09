local utils = require("utils")

local plugin_dir = vim.fn.stdpath("data") .. "/lazy"
local lazypath = plugin_dir .. "/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- check if firenvim is active
local firenvim_not_active = function()
  return not vim.g.started_by_firenvim
end

local plugin_specs = {
  -- auto-completion engine
  { "hrsh7th/cmp-nvim-lsp",                lazy = true },
  { "hrsh7th/cmp-path",                    lazy = true },
  { "hrsh7th/cmp-buffer",                  lazy = true },
  { "hrsh7th/cmp-omni",                    lazy = true },
  { "hrsh7th/cmp-cmdline",                 lazy = true },
  { "quangnguyen30192/cmp-nvim-ultisnips", lazy = true },
  {
    "hrsh7th/nvim-cmp",
    name = "nvim-cmp",
    event = "VeryLazy",
    config = function()
      require("config.nvim-cmp")
    end,
  },
  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },

  -- 1. Unified Mason Setup
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        registries = {
          "github:nvim-java/mason-registry",
          "github:mason-org/mason-registry",
        },
      })
    end,
  },

-- 2. Unified Mason-LSPConfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local is_nix_managed = vim.uv.fs_stat("/etc/nixos") or vim.uv.fs_stat("/etc/nix")

      require("mason-lspconfig").setup({
        ensure_installed = is_nix_managed and {} or {
          "lua_ls",
          "pyright",
          "ruff",
          "bashls",
          "spring_boot",
        },
      })
    end,
  },
{
    "nvim-java/nvim-java",
    dependencies = {
      "nvim-java/lua-async-await",
      "nvim-java/nvim-java-core",
      "nvim-java/nvim-java-test",
      "nvim-java/nvim-java-dap",
      "MunifTanjim/nui.nvim",
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- 1. Consistent Nix Check (Same as mason-lspconfig)
      local is_nix_managed = vim.uv.fs_stat("/etc/nixos") or vim.uv.fs_stat("/etc/nix")

      -- 2. Setup nvim-java
      require('java').setup({
        jdk = { auto_install = not is_nix_managed },

        java_test = { enable = true },
        java_debug_adapter = { enable = true },
        spring_boot_tools = { enable = true },
        jdtls = {
          path = vim.env.JDTLS_BIN or vim.fn.exepath('jdtls'),
          settings = {
            java = { home = vim.env.JAVA_HOME }
          },
        },
      })

      -- 3. Helper to find jars (Updated to use is_nix_managed)
      local function get_bundles()
        -- On Mac (not managed), we usually let nvim-java handle bundles automatically,
        -- so we return empty table here.
        if not is_nix_managed then return {} end

        -- On NixOS, if we have manually installed jars, we try to find them:
        local bundles = {}
        local debug_path = vim.fn.expand("~/.local/share/nvim/nvim-java/packages/java-debug-adapter/extension/server")
        local test_path = vim.fn.expand("~/.local/share/nvim/nvim-java/packages/java-test/extension/server")

        local debug_jar = vim.fn.glob(debug_path .. "/*.jar")
        if debug_jar ~= "" then table.insert(bundles, debug_jar) end

        local test_jars = vim.fn.glob(test_path .. "/*.jar", true, true)
        for _, jar in ipairs(test_jars) do table.insert(bundles, jar) end

        return bundles
      end

      -- 3. Setup JDTLS (Wrapped in Silence)
      -- We save the original notifier, mute it, run the setup, and restore it.
      local old_notify = vim.notify
      vim.notify = function() end -- Total silence

      -- Using pcall ensures we restore notification even if setup crashes
      pcall(function()
        require('lspconfig').jdtls.setup({
          init_options = {
            bundles = get_bundles()
          }
        })
      end)

      vim.notify = old_notify -- Restore functionality

      -- 4. Force-trigger DAP configuration
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          vim.defer_fn(function()
            pcall(vim.cmd, "JavaDapConfig")
          end, 1000)
        end
      })
    end,
  },



  -- 4. Core LSP Config (Loads your lua/config/lsp.lua)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim", "nvim-java/nvim-java" },
    -- No config function here anymore.
    -- We load our own lsp config file separately.
    init = function()
      -- This ensures our lua/config/lsp.lua runs after the plugin is added to RTP
      require("config.lsp")
    end,
  },
  {
    "dnlhc/glance.nvim",
    config = function()
      require("config.glance")
    end,
    event = "VeryLazy",
  },
  { "machakann/vim-swap",          event = "VeryLazy" },
{
    "nvim-treesitter/nvim-treesitter",
    build = function()
      if not (vim.uv.fs_stat("/etc/nixos") or vim.uv.fs_stat("/etc/nix")) then
        vim.cmd(":TSUpdate")
      end
    end,
    config = function()
      require("config.treesitter")
    end,
  },
  {
    "vlime/vlime",
    enabled = function()
      return utils.executable("sbcl")
    end,
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/vim")
    end,
    ft = { "lisp" },
  },

  {
    "smoka7/hop.nvim",
    keys = { "f" },
    config = function()
      require("config.nvim_hop")
    end,
  },

  -- Show match number and index for searching
  {
    "kevinhwang91/nvim-hlslens",
    branch = "main",
    keys = { "*", "#", "n", "N" },
    config = function()
      require("config.hlslens")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-telescope/telescope-symbols.nvim",
    },
  },
  {
    "ibhagwan/fzf-lua",
    config = function()
      require("config.fzf-lua")
    end,
    event = "VeryLazy",
  },
{
    "MeanderingProgrammer/render-markdown.nvim",
    main = "render-markdown",
    ft = { "markdown" },
    opts = {
      -- 1. Increase update delay (Default is 100ms).
      -- Waits half a second after you stop typing before recalculating graphics.
      debounce = 500,

      -- 2. Strict Mode Limits.
      -- Ensures it ONLY renders in Normal ('n') and Command ('c') mode.
      -- When you enter Insert ('i') mode to type, rendering pauses completely.
      render_modes = { 'n', 'c' },

      -- 3. Limit processing on huge files.
      -- Stops trying to render if a markdown file is over 1.5MB.
      max_file_size = 1.5,

      -- 4. Anti-conceal tuning.
      -- Anti-conceal hides graphical elements on the exact line your cursor is on.
      -- If the UI still feels slow when moving the cursor up/down, change enabled to `false`.
      anti_conceal = {
        enabled = true,
      },
    },
  },
  -- A list of colorscheme plugin you may want to try. Find what suits you.
  { "navarasu/onedark.nvim",       lazy = true },
  { "sainnhe/edge",                lazy = true },
  { "sainnhe/sonokai",             lazy = true },
  { "sainnhe/gruvbox-material",    lazy = true },
  { "sainnhe/everforest",          lazy = true },
  { "EdenEast/nightfox.nvim",      lazy = true },
  { "catppuccin/nvim",             name = "catppuccin", lazy = true },
  { "olimorris/onedarkpro.nvim",   lazy = true },
  { "marko-cerovac/material.nvim", lazy = true },
  {
    "rockyzhang24/arctic.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    name = "arctic",
    branch = "v2",
  },
  { "rebelot/kanagawa.nvim",        lazy = true },
  { "miikanissi/modus-themes.nvim", priority = 1000 },
  { "wtfox/jellybeans.nvim",        priority = 1000 },
  { "projekt0n/github-nvim-theme",  name = "github-theme" },
  { "e-ink-colorscheme/e-ink.nvim", priority = 1000 },
  { "ficcdaf/ashen.nvim",           priority = 1000 },
  { "savq/melange-nvim",            priority = 1000 },
  { "Skardyy/makurai-nvim",         priority = 1000 },
  { "vague2k/vague.nvim",           priority = 1000 },
  { "webhooked/kanso.nvim",         priority = 1000 },
  { "zootedb0t/citruszest.nvim",    priority = 1000 },
  { "RRethy/nvim-base16",           lazy = true },

  -- plugins to provide nerdfont icons
  {
    "nvim-mini/mini.icons",
    version = false,
    config = function()
      -- this is the compatibility fix for plugins that only support nvim-web-devicons
      require("mini.icons").mock_nvim_web_devicons()
      require("mini.icons").tweak_lsp_kind()
    end,
    lazy = true,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    cond = firenvim_not_active,
    config = function()
      require("config.lualine")
    end,
  },

  {
    "akinsho/bufferline.nvim",
    event = { "BufEnter" },
    cond = firenvim_not_active,
    config = function()
      require("config.bufferline")
    end,
  },

  -- fancy start screen
  {
    "nvimdev/dashboard-nvim",
    cond = firenvim_not_active,
    config = function()
      require("config.dashboard-nvim")
    end,
  },

  {
    "nvim-mini/mini.indentscope",
    version = false,
    config = function()
      local mini_indent = require("mini.indentscope")
      mini_indent.setup {
        draw = {
          animation = mini_indent.gen_animation.none(),
        },
        symbol = "▏",
      }
    end,
  },
  {
    "luukvbaal/statuscol.nvim",
    opts = {},
    config = function()
      require("config.nvim-statuscol")
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "VeryLazy",
    opts = {},
    init = function()
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function()
      require("config.nvim_ufo")
    end,
  },
  -- Highlight URLs inside vim
  { "itchyny/vim-highlighturl", event = "BufReadPost" },

  -- notification plugin
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("config.nvim-notify")
    end,
  },

  { "nvim-lua/plenary.nvim",    lazy = true },

  {
    "chrishrb/gx.nvim",
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    enabled = function()
      return vim.g.is_win or vim.g.is_mac or vim.g.is_linux
    end,
    config = true,      -- default settings
    submodules = false, -- not needed, submodules are required only for tests
  },

  {
    "liuchengxu/vista.vim",
    enabled = function()
      return utils.executable("ctags")
    end,
    cmd = "Vista",
  },

  -- Snippet engine and snippet template
  {
    "SirVer/ultisnips",
    dependencies = {
      "honza/vim-snippets",
    },
    event = "InsertEnter",
  },

  -- Automatic insertion and deletion of a pair of characters
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Comment plugin
  {
    "tpope/vim-commentary",
    keys = {
      { "gc", mode = "n" },
      { "gc", mode = "v" },
    },
  },

  -- Multiple cursor plugin like Sublime Text?
  -- 'mg979/vim-visual-multi'

  -- Show undo history visually
  { "simnalamburt/vim-mundo",    cmd = { "MundoToggle", "MundoShow" } },

  -- Manage your yank history
  {
    "gbprod/yanky.nvim",
    config = function()
      require("config.yanky")
    end,
    cmd = "YankyRingHistory",
  },

  -- Handy unix command inside Vim (Rename, Move etc.)
  { "tpope/vim-eunuch",          cmd = { "Rename", "Delete" } },

  -- Repeat vim motions
  { "tpope/vim-repeat",          event = "VeryLazy" },

  { "nvim-zh/better-escape.vim", event = { "InsertEnter" } },

  {
    "lyokha/vim-xkbswitch",
    enabled = function()
      return vim.g.is_mac and utils.executable("xkbswitch")
    end,
    event = { "InsertEnter" },
  },

  {
    "Neur1n/neuims",
    enabled = function()
      return vim.g.is_win
    end,
    event = { "InsertEnter" },
  },

  -- Git command inside vim
  {
    "tpope/vim-fugitive",
    event = "User InGitRepo",
    config = function()
      require("config.fugitive")
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",  -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      -- Only one of these is needed.
      "ibhagwan/fzf-lua",       -- optional
    },
    event = "User InGitRepo",
  },

  -- Better git log display
  { "rbong/vim-flog",                   cmd = { "Flog" } },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("config.git-conflict")
    end,
  },
  {
    "ruifm/gitlinker.nvim",
    event = "User InGitRepo",
    config = function()
      require("config.git-linker")
    end,
  },

  -- Show git change (change, delete, add) signs in vim sign column
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("config.gitsigns")
    end,
    event = "VeryLazy",
    version = "*",
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen" },
  },

  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      require("config.bqf")
    end,
  },

  -- Faster footnote generation
  { "vim-pandoc/vim-markdownfootnotes", ft = { "markdown" } },

  -- Vim tabular plugin for manipulate tabular, required by markdown plugins
  { "godlygeek/tabular",                ft = { "markdown" } },

  -- Markdown previewing (only for Mac and Windows)
  {
    "iamcco/markdown-preview.nvim",
    enabled = function()
      return vim.g.is_win or vim.g.is_mac or vim.g.is_linux
    end,
    build = "cd app && npm install && git restore .",
    ft = { "markdown" },
  },

  {
    "rhysd/vim-grammarous",
    enabled = function()
      return vim.g.is_mac
    end,
    ft = { "markdown" },
  },






  -- Debugger adapter protocol client
  {
    "mfussenegger/nvim-dap",
    lazy = true,
  },










  { "chrisbra/unicode.vim",   keys = { "ga" },   cmd = { "UnicodeSearch" } },

  -- Additional powerful text object for vim, this plugin should be studied
  -- carefully to use its full power
  { "wellle/targets.vim",     event = "VeryLazy" },

  -- Plugin to manipulate character pairs quickly
  { "machakann/vim-sandwich", event = "VeryLazy" },

  -- Only use these plugin on Windows and Mac and when LaTeX is installed
  {
    "lervag/vimtex",
    enabled = function()
      return utils.executable("latex")
    end,
    ft = { "tex" },
    init = function()
      vim.g.vimtex_view_method = (utils.executable("zathura") and "zathura") or "general"
    end,
  },

  -- Typst syntax highlighting, :TypstWatch, and :make support.
  -- Requires the `typst` CLI on PATH (add pkgs.typst to your nix env).
  {
    "kaarmu/typst.vim",
    enabled = function()
      return utils.executable("typst")
    end,
    ft = { "typst" },
    init = function()
      -- Conceal features are off by default; enable per-user if desired.
      vim.g.typst_conceal       = 0
      vim.g.typst_conceal_math  = 0
      vim.g.typst_conceal_emoji = 0
      -- Folding is off; enable by setting typst_folding = 1 locally.
      vim.g.typst_folding       = 0
      -- Auto-open quickfix window on compile errors.
      vim.g.typst_auto_open_quickfix = 1
      -- Use zathura for auto-reloading PDF preview; fall back to env var or system default.
      vim.g.typst_pdf_viewer = vim.env.TYPST_PDF_VIEWER or (utils.executable("zathura") and "zathura") or ""
    end,
  },

  -- Since tmux is only available on Linux and Mac, we only enable these plugins
  -- for Linux and Mac
  -- .tmux.conf syntax highlighting and setting check
  {
    "tmux-plugins/vim-tmux",
    enabled = function()
      return utils.executable("tmux")
    end,
    ft = { "tmux" },
  },

  -- Modern matchit implementation
  { "andymass/vim-matchup",     event = "BufRead" },
  { "tpope/vim-scriptease",     cmd = { "Scriptnames", "Messages", "Verbose" } },

  -- Asynchronous command execution
  { "skywind3000/asyncrun.vim", lazy = true,                                   cmd = { "AsyncRun" } },
  { "cespare/vim-toml",         ft = { "toml" },                               branch = "main" },

  -- Edit text area in browser using nvim
  {
    "glacambre/firenvim",
    enabled = function()
      return vim.g.is_win or vim.g.is_mac or vim.g.is_linux
    end,
    -- it seems that we can only call the firenvim function directly.
    -- Using vim.fn or vim.cmd to call this function will fail.
    build = function()
      local firenvim_path = plugin_dir .. "/firenvim"
      vim.opt.runtimepath:append(firenvim_path)
      vim.cmd("runtime! firenvim.vim")

      -- macOS will reset the PATH when firenvim starts a nvim process, causing the PATH variable to change unexpectedly.
      -- Here we are trying to get the correct PATH and use it for firenvim.
      -- See also https://github.com/glacambre/firenvim/blob/master/TROUBLESHOOTING.md#make-sure-firenvims-path-is-the-same-as-neovims
      local path_env = vim.env.PATH
      local prologue = string.format('export PATH="%s"', path_env)
      -- local prologue = "echo"
      local cmd_str = string.format(":call firenvim#install(0, '%s')", prologue)
      vim.cmd(cmd_str)
    end,
  },
  -- Debugger plugin
  {
    "sakhnik/nvim-gdb",
    enabled = function()
      return vim.g.is_win or vim.g.is_linux
    end,
    build = { "bash install.sh" },
    lazy = true,
  },

  -- Session management plugin
  { "tpope/vim-obsession",   cmd = "Obsession" },

  {
    "ojroques/vim-oscyank",
    enabled = function()
      return vim.g.is_linux
    end,
    cmd = { "OSCYank", "OSCYankReg" },
  },

  -- showing keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("config.which-key")
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- more beautiful vim.ui.input
      input = {
        enabled = true,
        win = {
          relative = "cursor",
          backdrop = true,
        },
      },
      -- more beautiful vim.ui.select
      picker = { enabled = true },
    },
  },
  -- show and trim trailing whitespaces
  { "jdhao/whitespace.nvim", event = "VeryLazy" },

  -- file explorer
  {
    "nvim-tree/nvim-tree.lua",
    keys = { "<space>s" },
    config = function()
      require("config.nvim-tree")
    end,
  },

  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    config = function()
      require("config.fidget-nvim")
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "VeryLazy",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    event = "VeryLazy",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = true,
    },
    cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle" },
  },
  {
    "smjonas/live-command.nvim",
    -- live-command supports semantic versioning via Git tags
    -- tag = "2.*",
    event = "VeryLazy",
    config = function()
      require("config.live-command")
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = { use_diagnostics_signs = true },
  },
  {
    -- show hint for code actions, the user can also implement code actions themselves,
    -- see discussion here: https://github.com/neovim/neovim/issues/14869
    "kosayoda/nvim-lightbulb",
    config = function()
      require("config.lightbulb")
    end,
    event = "LspAttach",
  },
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = "VeryLazy",
    opts = { -- set to setup table
    },
  },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
  },

  {
    "luckasRanarison/nvim-devdocs",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    config = function()
      require("config.devdocs")
    end,
    event = "VeryLazy", -- or choose a loading event you prefer
  },


  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup {
        trigger_events = { "FocusLost", "BufLeave" },
        condition = function(buf)
          -- If the LSP lock is active, ABORT the auto-save
          if vim.b[buf].is_formatting then
            return false
          end

          -- Standard safety checks
          local fn = vim.fn
          if fn.getbufvar(buf, "&buftype") ~= "" then
            return false
          end
          return true
        end,
      }
    end,
  },
  {
    "jbyuki/instant.nvim",
    config = function()
      vim.g.instant_username = vim.env.USER or vim.env.USERNAME or "krit"
      vim.g.instant_server_host = "127.0.0.1" -- Localhost
      vim.g.instant_server_port = 8081        -- The port you chose above
    end,
  },

  -- Claude Code AI assistant integration
  {
    "greggh/claude-code.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("claude-code").setup({
        window = {
          split_ratio = 0.3,
          position = "botright",
          enter_insert = true,
          hide_numbers = true,
          hide_signcolumn = true,
        },
        refresh = {
          enable = true,
          updatetime = 100,
          timer_interval = 1000,
          show_notifications = true,
        },
        git = {
          use_git_root = true,
        },
        command = "claude",
        command_variants = {
          continue = "--continue",
          resume = "--resume",
          verbose = "--verbose",
        },
        keymaps = {
          toggle = {
            normal = "<leader>cc",
            terminal = "<leader>ct",
            variants = {
              continue = "<leader>cR",
              verbose = "<leader>cV",
            },
          },
          window_navigation = true,
          scrolling = true,
        },
      })
    end,
  },
}

---@diagnostic disable-next-line: missing-fields
require("lazy").setup {
  spec = plugin_specs,
  ui = {
    border = "rounded",
    title = "Plugin Manager",
    title_pos = "center",
  },
  rocks = {
    enabled = false,
    hererocks = false,
  },
}
