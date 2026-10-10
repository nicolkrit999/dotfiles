local utils = require("utils")

local plugin_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy")
local lazypath = vim.fs.joinpath(plugin_dir, "lazy.nvim")

if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    -- one error with git's output, then stop loading the plugin specs (nothing below works without lazy)
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, { err = true })
    return
  end
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
  -- ASCII art headers for the dashboard; loaded by lua/config/dashboard-nvim.lua (require("ascii"))
  {
    "MaximilianLloyd/ascii.nvim",
    lazy = true,
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },

  {
    "nvim-java/nvim-java",
    -- loads on the first Java file (not at startup, not an nvim-lspconfig dependency): its
    -- config() ends with vim.lsp.enable("jdtls"), which attaches jdtls to the already open buffer
    ft = "java",
    -- nvim-java's own lazy.lua already declares nui.nvim, nvim-dap and JavaHello/spring-boot.nvim
    dependencies = {
      "MunifTanjim/nui.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- body lives in lua/config/nvim-java.lua so :DevEnv java can run it again after the devShell
      -- environment arrives (a java-less first run leaves jdtls and spring-boot-tools off)
      require("config.nvim-java").setup()
    end,
  },

  -- Core LSP Config (Loads your lua/config/lsp.lua); LSP binaries come from nix
  {
    "neovim/nvim-lspconfig",
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
  {
    "machakann/vim-swap",
    event = "VeryLazy",
    init = function()
      -- no plugin defaults: they also map g< / g>, and g< would shadow the builtin
      -- "show the last command output again". Only the interactive swap on gs is kept.
      vim.g.swap_no_default_key_mappings = 1
    end,
    config = function()
      vim.keymap.set({ "n", "x" }, "gs", "<Plug>(swap-interactive)", { desc = "Swap items interactively (vim-swap)" })
    end,
  },
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
    keys = { { "f", mode = { "n", "x", "o" }, desc = "Hop: jump to a 2-char match" } },
    config = function()
      require("config.nvim_hop")
    end,
  },

  -- Show match number and index for searching
  {
    "kevinhwang91/nvim-hlslens",
    branch = "main",
    keys = {
      { "*", desc = "Search: word under cursor forward (with lens)" },
      { "#", desc = "Search: word under cursor backward (with lens)" },
      { "n", desc = "Search: next match (with lens)" },
      { "N", desc = "Search: previous match (with lens)" },
    },
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
      render_modes = { "n", "c" },

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
  -- all colorschemes are lazy: lazy.nvim loads the plugin providing a colorscheme on
  -- `:colorscheme <name>` (nix uses nix_colorscheme() -> base16; non-nix picks a random one)
  {
    "rockyzhang24/arctic.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    name = "arctic",
    branch = "v2",
    lazy = true,
  },
  { "rebelot/kanagawa.nvim",        lazy = true },
  { "miikanissi/modus-themes.nvim", lazy = true },
  { "wtfox/jellybeans.nvim",        lazy = true },
  { "projekt0n/github-nvim-theme",  name = "github-theme", lazy = true },
  { "ficcdaf/ashen.nvim",           lazy = true },
  { "savq/melange-nvim",            lazy = true },
  { "Skardyy/makurai-nvim",         lazy = true },
  { "vague2k/vague.nvim",           lazy = true },
  { "webhooked/kanso.nvim",         lazy = true },
  { "zootedb0t/citruszest.nvim",    lazy = true },
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

  -- fancy start screen: loaded only for a bare `nvim` (no file/dir argument, no stdin) or by :Dashboard
  {
    "nvimdev/dashboard-nvim",
    cond = firenvim_not_active,
    -- :Dashboard keeps working after `nvim file` (a cond with argc() would remove the command too)
    cmd = "Dashboard",
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("dashboard_lazy_start", { clear = true }),
        once = true,
        desc = "Load dashboard-nvim on a bare start (it then opens itself on UIEnter)",
        callback = function()
          -- same test as the plugin's own UIEnter autocmd; stdin is checked here because the
          -- plugin's VimEnter stdin detector does not run when it is loaded during VimEnter
          if vim.fn.argc() ~= 0 or vim.api.nvim_buf_get_name(0) ~= "" or vim.tbl_contains(vim.v.argv, "-") then
            return
          end
          require("lazy").load { plugins = { "dashboard-nvim" } }
        end,
      })
    end,
    config = function()
      require("config.dashboard-nvim")
    end,
  },

  {
    "nvim-mini/mini.indentscope",
    version = false,
    event = "VeryLazy", -- the scope line only draws on CursorMoved; ii/ai exist after the first screen
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
    config = function()
      require("config.nvim-statuscol")
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "VeryLazy",
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
  { "itchyny/vim-highlighturl", event = { "BufReadPost", "BufNewFile" } },

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
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" }, desc = "Open URL or file under cursor (gx.nvim)" } },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = 1 -- disable netrw gx
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
        " Single source of truth for the UltiSnips triggers (nvim-cmp.lua must not set them):
        " <C-j> = expand or jump forward, <C-k> = jump back
        let g:UltiSnipsExpandTrigger='<c-j>'

        " Do not look for SnipMate snippets
        let g:UltiSnipsEnableSnipMate = 0

        " Shortcut to jump forward and backward in tabstop positions
        let g:UltiSnipsJumpForwardTrigger='<c-j>'
        let g:UltiSnipsJumpBackwardTrigger='<c-k>'

        " Configuration for custom snippets directory
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
    -- also at VeryLazy so :Commentary / :5,9Commentary, the dgc/ygc text object and gcu exist
    -- without first typing gc (the keys below stay as stubs for the first moments)
    event = "VeryLazy",
    keys = {
      { "gc", mode = "n", desc = "Comment operator (vim-commentary)" },
      { "gc", mode = "x", desc = "Comment selection (vim-commentary)" },
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
    -- load right after the first screen (not on the first p/P) so EVERY yank of the session is
    -- recorded in the yank history; config.yanky then owns p/P/[y/]y
    event = "VeryLazy",
    cmd = "YankyRingHistory",
  },

  -- Handy unix command inside Vim (Rename, Move etc.)
  -- (every command plugin/eunuch.vim defines, so each one works from a fresh start)
  {
    "tpope/vim-eunuch",
    cmd = {
      "Mkdir", "Unlink", "Remove", "Delete", "Copy", "Move", "Duplicate", "Rename", "Chmod",
      "Cfind", "Clocate", "Lfind", "Llocate", "SudoEdit", "SudoWrite", "Wall", "W",
    },
  },

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
    -- only used through its commands (no map or autocmd needs it earlier); diffview, fzf-lua
    -- and plenary are loaded as its dependencies on the first use
    cmd = { "Neogit", "NeogitCommit", "NeogitLogCurrent", "NeogitResetState" },
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
  { "godlygeek/tabular",                ft = { "markdown" }, cmd = { "Tabularize" } },

  -- Markdown previewing in the browser
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install && git restore .",
    ft = { "markdown" },
    init = function()
      -- Do not close the preview tab when switching to other buffers (all platforms)
      vim.g.mkdp_auto_close = 0
    end,
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
      -- Map s to nop since s in used by vim-sandwich. Use cl instead of s.
      -- (vim.keymap.set, not `nmap`/`omap`, so the maps carry a desc; remap = true like nmap)
      vim.keymap.set("n", "s", "<Nop>", { remap = true, desc = "Disabled (s is the vim-sandwich prefix, use cl)" })
      -- operator-pending: `gcs`, pause, `s` must not leave the operator pending (the next motion
      -- would run it): cancel it. Instant because nothing longer starts with o-mode `s` (the
      -- o-mode `sa` is unmapped in config() below).
      vim.keymap.set("o", "s", "<Esc>", { remap = true, desc = "Cancel the pending operator (s is the vim-sandwich prefix)" })
      -- do not let vim-sandwich define its default text-object maps (ib/ab auto, is/as query):
      -- the builtin sentence objects keep is/as, targets.vim keeps ib/ab, and the query objects
      -- are mapped below on iS/aS. (Operator maps sa/sd/sr are a separate flag, untouched.)
      vim.g.textobj_sandwich_no_default_key_mappings = 1
    end,
    config = function()
      -- vim-sandwich's o-mode `sa` (<Plug>(sandwich-add)) has no user-facing use (adding is the
      -- normal/visual `sa`); drop it so o-mode `s` (= cancel) is not a prefix of it and which-key
      -- stops reporting "<s> overlaps with <sa>"
      pcall(vim.keymap.del, "o", "sa")
      -- sandwich's query objects on iS/aS ("S" = Sandwich; capital, so builtin is/as stay sentences)
      for _, mode in ipairs({ "x", "o" }) do
        vim.keymap.set(mode, "iS", "<Plug>(textobj-sandwich-query-i)", { desc = "Sandwich: inner surrounding (query)" })
        vim.keymap.set(mode, "aS", "<Plug>(textobj-sandwich-query-a)", { desc = "Sandwich: around surrounding (query)" })
      end
    end,
  },

  -- LaTeX support: loaded on every platform whenever `latex` is on PATH (on Linux via the LaTeX devShell)
  {
    "lervag/vimtex",
    -- Not lazy on purpose when latex exists: the PDF viewer's Ctrl+click starts a separate headless nvim
    -- (no tex file) that needs the :VimtexInverseSearch command, which only exists once vimtex is loaded.
    -- Without latex it is lazy with no trigger (stays installed, never loads) until :DevEnv latex loads it
    -- (lua/devenv.lua). Not `enabled`/`cond`: lazy.nvim drops such plugins from the loadable list.
    lazy = not utils.executable("latex"),
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
            " buffer-local like the old nmap, via Lua so the map can carry a desc
            autocmd FileType tex lua for _, lhs in ipairs({ "<F9>", "<leader>rf" }) do vim.keymap.set("n", lhs, "<Plug>(vimtex-compile)", { buffer = true, remap = true, desc = "LaTeX: start/stop compiling (vimtex)" }) end
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
    -- no typst at startup: lazy with no trigger (stays installed) until :DevEnv typst loads it
    -- (lua/devenv.lua); not `enabled`/`cond`, which lazy.nvim drops from the loadable list
    lazy = true,
    ft = utils.executable("typst") and { "typst" } or nil,
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
    event = { "BufReadPost", "BufNewFile" },
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

  -- Auto-save a session per cwd on exit (never auto-restored; restore from the dashboard items
  -- "Restore session (this folder)" / "Restore last session").
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- only start saving once a real file was opened
    opts = {},
    config = function(_, opts)
      require("persistence").setup(opts)
      -- Keep transient/panel windows out of saved sessions: close them just before the save
      -- (PersistenceSavePre fires on VimLeavePre) and drop terminals/help from sessionoptions.
      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        group = vim.api.nvim_create_augroup("persistence_exclude", { clear = true }),
        desc = "Exclude claude-code, nvim-tree, aerial, help, quickfix windows from the session",
        callback = function()
          vim.opt.sessionoptions:remove { "terminal", "help" }
          local claude = {}
          local ok, cc = pcall(require, "claude-code")
          if ok and cc.claude_code then
            for _, b in pairs(cc.claude_code.instances or {}) do claude[b] = true end
          end
          local skip_ft = { qf = true, help = true, aerial = true, NvimTree = true, dashboard = true }
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if skip_ft[vim.bo[buf].filetype] or vim.bo[buf].buftype == "terminal" or claude[buf] then
              if #vim.api.nvim_list_wins() > 1 then pcall(vim.api.nvim_win_close, win, true) end
            end
          end
          for b in pairs(claude) do
            if vim.api.nvim_buf_is_valid(b) then pcall(vim.api.nvim_buf_delete, b, { force = true }) end
          end
        end,
      })
    end,
  },

  -- Session management plugin
  -- event: after `nvim -S Session.vim` the session keeps being tracked without typing :Obsession
  { "tpope/vim-obsession",   cmd = "Obsession", event = "VeryLazy" },

  {
    "ojroques/vim-oscyank",
    enabled = function()
      return vim.g.is_linux
    end,
    cmd = { "OSCYank", "OSCYankVisual", "OSCYankRegister" },
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
      -- db: frecency/history in sqlite. The nix nvim wrapper exports SNACKS_SQLITE3_PATH (full libsqlite3
      -- path); unset elsewhere -> nil -> snacks falls back to its default loader.
      -- select layout: wide dialog (default max_width 100 cut long Java main-class lists); the large
      -- max_width is clamped to the screen width by snacks.win
      picker = {
        enabled = true,
        db = { sqlite3_path = vim.env.SNACKS_SQLITE3_PATH },
        sources = { select = { layout = { layout = { width = 0.95, max_width = 1000 } } } },
      },
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
  {
    "nvim-zh/whitespace.nvim",
    event = "VeryLazy",
    init = function()
      -- plugin default list + markdown: trailing spaces there are hard line breaks, not errors
      vim.g.trailing_whitespace_exclude_filetypes = { "alpha", "git", "floggraph", "dashboard", "markdown" }
    end,
  },

  -- file explorer
  {
    "nvim-tree/nvim-tree.lua",
    keys = { { "<space>s", desc = "toggle nvim-tree" } },
    -- the :NvimTree* commands (e.g. :NvimTreeFindFile) also load it
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeFindFileToggle" },
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
    opts = {},
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
      -- quicker adds 3 columns (the "…" and 2 more) to this width: -3 shows a 40 column name
      max_filename_width = function()
        return math.floor(math.min(40, vim.o.columns / 2)) - 3
      end,
    },
  },

  {
    "maskudo/devdocs.nvim",
    -- only used through :DevDocs (needs jq, curl and pandoc); picker is vim.ui.select (snacks)
    cmd = { "DevDocs" },
    opts = {},
  },


  {
    -- formatter front end: format on explicit save + <Space>fm (config: lua/config/conform.lua)
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo", "FormatDisable", "FormatEnable" }, -- the last two are defined by the config
    init = function()
      -- auto-save.nvim fires these two events around its (synchronous) :write; format on save skips
      -- writes made in between. Registered at startup because conform itself loads lazily on BufWritePre.
      local group = vim.api.nvim_create_augroup("conform_skip_autosave", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSaveWritePre",
        group = group,
        desc = "Conform: mark an auto-save write (no format on save)",
        callback = function() vim.g.autosave_writing = true end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSaveWritePost",
        group = group,
        desc = "Conform: auto-save write finished",
        callback = function() vim.g.autosave_writing = false end,
      })
    end,
    config = function()
      require("config.conform")
    end,
  },

  {
    -- maintained fork of the archived Pocco81/auto-save.nvim
    "okuuva/auto-save.nvim",
    event = "VeryLazy", -- its triggers (BufLeave/FocusLost) cannot happen before the first screen
    config = function()
      require("auto-save").setup {
        -- save when leaving a buffer or when nvim loses focus; no saves while typing
        -- (the fork's defaults also save on QuitPre/VimSuspend and after InsertLeave/TextChanged)
        trigger_events = {
          immediate_save = { "BufLeave", "FocusLost" },
          defer_save = {},
          cancel_deferred_save = {},
        },
        condition = function(buf)
          -- Skip buffers that cannot be written (unnamed, readonly, not modifiable);
          -- otherwise auto-save reports "saved" although :write failed (E32/E45).
          if vim.api.nvim_buf_get_name(buf) == "" or vim.bo[buf].readonly or not vim.bo[buf].modifiable then
            return false
          end

          -- Disable for filetypes with external watchers (typst watch, vimtex)
          -- to avoid re-triggering the watcher process on every auto-save event.
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          if ft == "typst" or ft == "tex" then
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

      -- the fork dropped the built-in "saved" message. Shown as an nvim-notify popup (not an echo: the
      -- redraw of the buffer switch wiped the echo, and a "file is not formatted" warning of
      -- lua/custom-autocmd.lua can follow right after). nvim-notify stacks popups, so the two never overlap.
      vim.api.nvim_create_autocmd("User", {
        pattern = "AutoSaveWritePost",
        group = vim.api.nvim_create_augroup("auto_save_message", { clear = true }),
        desc = "AutoSave: show 'saved at' message",
        callback = function()
          local msg = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S")
          vim.schedule(function() -- outside the `silent! write` of the plugin
            vim.notify(msg, vim.log.levels.INFO, { title = "AutoSave" })
          end)
        end,
      })
    end,
  },
  {
    "jbyuki/instant.nvim",
    -- loaded on its first command (full list from plugin/instant.vim)
    cmd = {
      "InstantStartServer", "InstantStopServer", "InstantStartSession", "InstantJoinSession",
      "InstantStartSingle", "InstantJoinSingle", "InstantStop", "InstantStatus", "InstantFollow",
      "InstantStopFollow", "InstantOpenAll", "InstantSaveAll", "InstantMark", "InstantMarkClear",
    },
    init = function()
      vim.g.instant_username = vim.env.USER or vim.env.USERNAME or "krit"
      -- host and port are not options: pass them to :InstantStartServer / :InstantStartSession /
      -- :InstantJoinSession (e.g. `:InstantStartSession 127.0.0.1 8081`)
    end,
  },

  -- Claude Code AI assistant integration
  {
    "greggh/claude-code.nvim",
    event = "VeryLazy", -- <Space>cc/cR/cV and :ClaudeCode* exist right after the first screen
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
          -- off: lua/custom-autocmd.lua (FileChangedShellPost) gives the one reload/deleted message
          show_notifications = false,
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
            -- no terminal-mode toggle: a global `t <Space>ct` map made every terminal wait on a
            -- typed space and toggled Claude on text like " ctags". Leave the terminal with
            -- <C-\><C-n>, then toggle with <Space>cc.
            terminal = false,
            variants = {
              continue = "<leader>cR",
              verbose = "<leader>cV",
            },
          },
          window_navigation = true,
          scrolling = true,
        },
      })

      -- <Esc> inside the Claude Code terminal goes to Claude (e.g. to interrupt it) instead of
      -- the global `t <Esc>` map (leave terminal mode, lua/mappings.lua). Buffer-local, so other
      -- terminals keep the global map; <C-\><C-n> still leaves terminal mode here.
      -- claude-code.nvim tracks its terminal buffers in claude_code.instances (git root -> bufnr).
      local function is_claude_buf(buf)
        for _, b in pairs(require("claude-code").claude_code.instances or {}) do
          if b == buf then return true end
        end
        return false
      end
      vim.api.nvim_create_autocmd("TermEnter", {
        group = vim.api.nvim_create_augroup("claude_code_esc", { clear = true }),
        desc = "Claude Code terminal: <Esc> passes through to Claude",
        callback = function(ev)
          if vim.b[ev.buf].claude_esc_passthrough or not is_claude_buf(ev.buf) then return end
          -- noremap <Esc> in terminal mode = send Esc to the terminal job
          vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = ev.buf, nowait = true, desc = "Esc to Claude Code" })
          -- since <Esc> no longer leaves terminal mode, <C-w>h/j/k/l must work from terminal mode
          -- (else they are typed into Claude and only the mouse gets you back to the code)
          for _, dir in ipairs({ "h", "j", "k", "l" }) do
            vim.keymap.set("t", "<C-w>" .. dir, [[<C-\><C-n><C-w>]] .. dir,
              { buffer = ev.buf, desc = "Claude Code: move to the window " .. dir })
          end
          -- <Esc> cannot leave terminal mode here, so <C-q> does it (same as <C-\><C-n>): then :q, <Space>q ...
          vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { buffer = ev.buf, desc = "Claude Code: leave terminal mode" })
          vim.b[ev.buf].claude_esc_passthrough = true
        end,
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
