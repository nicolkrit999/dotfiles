local utils = require("utils")

local plugin_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
local lazypath = vim.fs.joinpath(plugin_dir, "lazy.nvim")

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
  -- treesitter-colored completion labels (used by lua/config/nvim-cmp.lua)
  {
    "xzbdmw/colorful-menu.nvim",
    lazy = true,
    config = function()
      require("config.colorful_menu")
    end,
  },
  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },

  {
    "nvim-java/nvim-java",
    -- nvim-java's own lazy.lua already declares nui.nvim, nvim-dap and JavaHello/spring-boot.nvim
    dependencies = {
      "MunifTanjim/nui.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      local is_nix_managed = vim.uv.fs_stat("/etc/nixos") or vim.uv.fs_stat("/etc/nix")
      -- java (JDK) only exists inside the Java devShell: outside it, stay silent
      -- (no spring-boot LS spawn, no jdtls start -> no ENOENT 'java' warnings on .java files)
      local has_java = vim.fn.executable("java") == 1

      require("java").setup({
        -- nix: never download a JDK (no nix-ld); the devShell provides JAVA_HOME (jdk25) and java on PATH
        jdk = { auto_install = not is_nix_managed },
        java_test = { enable = true },
        java_debug_adapter = { enable = true },
        spring_boot_tools = { enable = has_java },
        -- jdtls.path intentionally unset: nvim-java uses its own jdtls 1.54.0 from
        -- ~/.local/share/nvim/nvim-java/packages (the devShell's `jdtls` is a bin/ wrapper, not a jdtls root)
      })

      -- jdtls settings go through vim.lsp.config (NOT java.setup{jdtls.settings}).
      -- Only scalar/dict values here: lists would REPLACE nvim-java's values (e.g. init_options.bundles).
      vim.lsp.config("jdtls", {
        settings = {
          java = { home = vim.env.JAVA_HOME },
        },
      })
      if has_java then
        vim.lsp.enable("jdtls")
      end
    end,
  },

  -- Core LSP Config (Loads your lua/config/lsp.lua); LSP binaries come from nix
  {
    "neovim/nvim-lspconfig",
    dependencies = { "nvim-java/nvim-java" },
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
    branch = "main",
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
  -- highlight other occurrences of the word under the cursor (LSP references)
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require("config.vim-illuminate")
    end,
  },

  -- split/join tables, argument lists, arrays (gS)
  {
    "Wansmer/treesj",
    keys = { { "gS", desc = "Toggle split join" } },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("config.treesj")
    end,
  },

  -- dim inactive windows
  {
    "tadaa/vimade",
    event = "VeryLazy",
    config = function()
      require("config.vimade")
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

  -- symbol outline sidebar (treesitter/LSP, no ctags needed)
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = { { "<space>t", "<cmd>AerialToggle!<CR>", desc = "Toggle symbol outline (aerial)" } },
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    config = function()
      require("config.aerial")
    end,
  },

  -- Snippet engine and snippet template
  {
    "SirVer/ultisnips",
    dependencies = {
      "honza/vim-snippets",
    },
    event = "VeryLazy",
    ft = "snippets",
    init = function()
      vim.cmd([[
        " Trigger configuration. Do not use <tab> if you use YouCompleteMe
        let g:UltiSnipsExpandTrigger='<c-j>'

        " Do not look for SnipMate snippets
        let g:UltiSnipsEnableSnipMate = 0

        " Shortcut to jump forward and backward in tabstop positions
        let g:UltiSnipsJumpForwardTrigger='<c-j>'
        let g:UltiSnipsJumpBackwardTrigger='<c-k>'

        " Configuration for custom snippets directory, see
        let g:UltiSnipsSnippetDirectories=['UltiSnips', 'my_snippets']
      ]])
    end,
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

  {
    "nvim-zh/better-escape.vim",
    event = { "InsertEnter" },
    init = function()
      vim.g.better_escape_interval = 200
    end,
  },

  {
    "lyokha/vim-xkbswitch",
    enabled = function()
      return vim.g.is_mac and utils.executable("xkbswitch")
    end,
    event = { "InsertEnter" },
    init = function()
      vim.g.XkbSwitchEnabled = 1
    end,
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
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    config = function()
      require("config.diffview")
    end,
  },

  -- syntax/treesitter highlighting inside fugitive/neogit/gitsigns diff buffers
  -- (vim.g.diffs is read when the plugin is sourced, so it is set in init)
  {
    "https://forge.barrettruth.com/barrettruth/diffs.nvim",
    init = function()
      vim.g.diffs = {
        integrations = {
          fugitive = true,
          neogit = true,
          gitsigns = true,
        },
      }
    end,
  },

  -- VSCode-style side-by-side diff (:CodeDiff); downloads a native lib on first use
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
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
    init = function()
      -- Only setting this for suitable platforms
      if vim.g.is_win or vim.g.is_mac then
        -- Do not close the preview tab when switching to other buffers
        vim.g.mkdp_auto_close = 0
      end
    end,
  },

  -- Debugger adapter protocol client
  {
    "mfussenegger/nvim-dap",
    lazy = true,
  },

  -- SQL database client (browse connections/schema, run queries, view results).
  -- Requires nvim>=0.10. The build step downloads a small Go backend binary via
  -- install() (auto-detects curl/wget/go on $PATH -- if none are present on the
  -- host, add one of those to the nix profile and rerun :Lazy build nvim-dbee).
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      require("dbee").install()
    end,
    cmd = { "Dbee" },
    -- lazy key triggers: the maps work before :Dbee was ever run
    keys = {
      { "<leader>Dt", function() require("dbee").toggle() end, desc = "Dbee: Toggle UI" },
      { "<leader>Do", function() require("dbee").open() end, desc = "Dbee: Open UI" },
      { "<leader>Dc", function() require("dbee").close() end, desc = "Dbee: Close UI" },
    },
    config = function()
      require("config.dbee")
    end,
  },

  -- SQL database client (interactive :DB console / run buffer or range as a
  -- query). Bare vim-dadbod has no UI of its own -- vim-dadbod-ui below adds
  -- the browsable connection tree / saved queries / results pane. Does not
  -- conflict with nvim-dbee above (different commands: :DB/:DBUI vs :Dbee),
  -- both stay installed side by side.
  {
    "tpope/vim-dadbod",
    cmd = { "DB" },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      require("config.dadbod")
    end,
  },










  {
    "chrisbra/unicode.vim",
    -- the plugin loads on the first `ga`; no separate `nmap ga` (it would overwrite lazy's key stub)
    -- <leader>cu: our own lhs for the swap map. Lazy sets the real <leader>cu map before the plugin is
    -- sourced, so unicode.vim's hasmapto() check skips its default <leader>un (which made <leader>u wait).
    keys = {
      { "ga", "<Plug>(UnicodeGA)", remap = true, desc = "unicode info of char under cursor" },
      { "<leader>cu", "<Plug>(UnicodeSwapCompleteName)", remap = true, desc = "unicode: swap <C-x><C-z> completion (name/char)" },
    },
    cmd = { "UnicodeSearch" },
  },

  -- Additional powerful text object for vim, this plugin should be studied
  -- carefully to use its full power
  { "wellle/targets.vim",     event = "VeryLazy" },

  -- Plugin to manipulate character pairs quickly
  {
    "machakann/vim-sandwich",
    event = "VeryLazy",
    init = function()
      vim.cmd([[
        " Map s to nop since s in used by vim-sandwich. Use cl instead of s.
        nmap s <Nop>
        omap s <Nop>
      ]])
    end,
    config = function()
      -- let targets.vim own ab/ib (`:checkhealth targets` conflict)
      for _, mode in ipairs({ "x", "o" }) do
        pcall(vim.keymap.del, mode, "ab")
        pcall(vim.keymap.del, mode, "ib")
      end
    end,
  },

  -- Only use these plugin on Windows and Mac and when LaTeX is installed
  {
    "lervag/vimtex",
    enabled = function()
      return utils.executable("latex")
    end,
    ft = { "tex" },
    init = function()
      vim.g.vimtex_view_method = (utils.executable("zathura") and "zathura") or "general"
      vim.cmd([[
        if executable('latex')
          " Hacks for inverse search to work semi-automatically,
          function! s:write_server_name() abort
            let nvim_server_file = (has('win32') ? $TEMP : '/tmp') . '/vimtexserver.txt'
            call writefile([v:servername], nvim_server_file)
          endfunction

          augroup vimtex_common
            autocmd!
            autocmd FileType tex call s:write_server_name()
            autocmd FileType tex nmap <buffer> <F9> <plug>(vimtex-compile)
          augroup END

          let g:vimtex_compiler_latexmk = {
                \ 'build_dir' : 'build',
                \ }

          " TOC settings
          let g:vimtex_toc_config = {
                \ 'name' : 'TOC',
                \ 'layers' : ['content', 'todo', 'include'],
                \ 'resize' : 1,
                \ 'split_width' : 30,
                \ 'todo_sorted' : 0,
                \ 'show_help' : 1,
                \ 'show_numbers' : 1,
                \ 'mode' : 2,
                \ }

          " Viewer settings for different platforms
          if g:is_win
            let g:vimtex_view_general_viewer = 'SumatraPDF'
            let g:vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
          endif

          if g:is_mac
            " let g:vimtex_view_method = "skim"
            let g:vimtex_view_general_viewer = '/Applications/Skim.app/Contents/SharedSupport/displayline'
            let g:vimtex_view_general_options = '-r @line @pdf @tex'

            augroup vimtex_mac
              autocmd!
              autocmd User VimtexEventCompileSuccess call UpdateSkim()
            augroup END

            " The following code is adapted from https://gist.github.com/skulumani/7ea00478c63193a832a6d3f2e661a536.
            function! UpdateSkim() abort
              let l:out = b:vimtex.out()
              let l:src_file_path = expand('%:p')
              let l:cmd = [g:vimtex_view_general_viewer, '-r']

              if !empty(system('pgrep Skim'))
                call extend(l:cmd, ['-g'])
              endif

              call jobstart(l:cmd + [line('.'), l:out, l:src_file_path])
            endfunction
          endif
        endif
      ]])
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
  {
    "andymass/vim-matchup",
    event = "BufRead",
    init = function()
      -- Improve performance
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_timeout = 100
      vim.g.matchup_matchparen_insert_timeout = 30

      -- Enhanced matching with matchup plugin
      vim.g.matchup_override_vimtex = 1

      -- Whether to enable matching inside comment or string
      vim.g.matchup_delim_noskips = 0

      -- Show offscreen match pair in popup window
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  { "tpope/vim-scriptease",     cmd = { "Scriptnames", "Messages", "Verbose" } },

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
      local firenvim_path = vim.fs.joinpath(plugin_dir, "firenvim")
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
    init = function()
      vim.cmd([[
        if exists('g:started_by_firenvim') && g:started_by_firenvim
          if g:is_mac
            set guifont=Iosevka\ Nerd\ Font:h18
          else
            set guifont=Consolas
          endif

          " general config for firenvim
          let g:firenvim_config = {
              \ 'globalSettings': {
                  \ 'alt': 'all',
              \  },
              \ 'localSettings': {
                  \ '.*': {
                      \ 'cmdline': 'neovim',
                      \ 'priority': 0,
                      \ 'selector': 'textarea',
                      \ 'takeover': 'never',
                  \ },
              \ }
          \ }

          function s:setup_firenvim() abort
            set signcolumn=no
            set noruler
            set noshowcmd
            set laststatus=0
            set showtabline=0
          endfunction

          augroup firenvim
            autocmd!
            autocmd BufEnter * call s:setup_firenvim()
            autocmd BufEnter sqlzoo*.txt set filetype=sql
            autocmd BufEnter github.com_*.txt set filetype=markdown
            autocmd BufEnter stackoverflow.com_*.txt set filetype=markdown
          augroup END
        endif
      ]])
    end,
  },
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
      vim.keymap.set("n", "<leader>dp", [[:<C-U>GdbStartPDB python -m pdb %<CR>]], { desc = "start pdb on current file (nvim-gdb)" })
    end,
    config = function()
      -- nvim-gdb's setup() maps cmdline <c-e> globally (cmake executable picker); keep the builtin <C-e>
      pcall(vim.keymap.del, "c", "<c-e>")
    end,
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
      -- light mode for big files (> 1.5 MB, or average line length > 5000 = minified bundles):
      -- filetype `bigfile`, no treesitter/ftplugin maps; LSP of the real filetype starts after a short
      -- delay without semantic tokens or completion (no typos_lsp/ltex_plus/lua_ls), see
      -- lua/config/bigfile.lua. `:lsp stop` to drop the LSP; `:set ft=json` (etc.) for full mode.
      bigfile = {
        enabled = true,
        line_length = 5000,
        setup = function(ctx)
          require("config.bigfile").setup(ctx)
        end,
      },
    },
  },
  -- show and trim trailing whitespaces
  { "nvim-zh/whitespace.nvim", event = "VeryLazy" },

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
        -- types for `vim.lsp.Config` / lspconfig settings (used in after/lsp/*.lua)
        { path = "nvim-lspconfig", words = { "lspconfig" } },
      },
    },
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
    opts = {
      options = {
        parsers = {
          -- do not color plain color words such as "red" or "Black"
          names = { enable = false },
        },
      },
    },
  },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      edit = {
        enabled = false,
      },
      max_filename_width = function()
        return math.floor(math.min(40, vim.o.columns / 2))
      end,
    },
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
          -- Disable for filetypes with external watchers (typst watch, vimtex)
          -- to avoid re-triggering the watcher process on every auto-save event.
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          if ft == "typst" or ft == "tex" then
            return false
          end

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
          position = "vsplit",
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
  -- limit parallel git jobs to avoid GitHub rate limits
  concurrency = 5,
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

-- lazy.nvim's `performance.reset_packpath` (on by default) sets &packpath to just $VIMRUNTIME, and
-- `performance.rtp.reset` rebuilds &rtp from scratch - both skip Nvim's native pack/*/start/* loading
-- (which never runs anyway: lazy also turns 'loadplugins' off). That's how home-manager wires
-- Nix-provided plugins/grammars onto ~/.local/share/nvim/site/pack/hm/start/ (neovim.nix's
-- programs.neovim.plugins), so append any such start packages to &rtp ourselves, after lazy is done
-- rewriting it.
for _, dir in ipairs(vim.fn.globpath(vim.fs.joinpath(vim.fn.stdpath("data"), "site/pack/*/start/*"), "", false, true)) do
  vim.opt.rtp:append(dir)
end

-- Use short names for common plugin manager commands to simplify typing.
-- To use these shortcuts: first activate command line with `:`, then input the
-- short alias, e.g., `pi`, then press <space>, the alias will be expanded to
-- the full command automatically.
vim.fn["utils#Cabbrev"]("pi", "Lazy install")
vim.fn["utils#Cabbrev"]("pud", "Lazy update")
vim.fn["utils#Cabbrev"]("pc", "Lazy clean")
vim.fn["utils#Cabbrev"]("ps", "Lazy sync")
