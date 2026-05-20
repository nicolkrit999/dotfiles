-- 1. Protect against crash if cmp isn't loaded yet
local status_cmp, cmp = pcall(require, "cmp")
if not status_cmp then return end

-- 2. Protect against crash if mini.icons isn't loaded yet
local status_icons, MiniIcons = pcall(require, "mini.icons")

-- Standard source loading (pcall wrapped to be extra safe)
pcall(require, "cmp_nvim_lsp")
pcall(require, "cmp_path")
pcall(require, "cmp_buffer")
pcall(require, "cmp_omni")
pcall(require, "cmp_nvim_ultisnips")
pcall(require, "cmp_cmdline")

-- Copilot suggestion helper (for the Smart Tab logic)
local has_copilot, copilot_suggestion = pcall(require, "copilot.suggestion")

-- UltiSnips configuration
vim.g.UltiSnipsExpandTrigger = "<Tab>"
vim.g.UltiSnipsJumpForwardTrigger = "<C-j>"
vim.g.UltiSnipsJumpBackwardTrigger = "<C-k>"

cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<Tab>"] = cmp.mapping(function(fallback)
      local copilot_suggestion = require("copilot.suggestion")

      if cmp.visible() then
        -- 1. If the autocomplete menu is open, Tab scrolls the menu
        cmp.select_next_item()
      elseif copilot_suggestion.is_visible() then
        -- 2. If the "Grey Thing" (Ghost text) is visible, Tab accepts it
        copilot_suggestion.accept()
      else
        -- 3. Otherwise, do a normal Tab (or indent)
        fallback()
      end
    end, { "i", "s" }),

    ["<CR>"] = cmp.mapping.confirm { select = true },

    ["<C-e>"] = cmp.mapping.abort(),
    ["<Esc>"] = cmp.mapping.close(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "ultisnips" },
    { name = "path" },
    { name = "buffer",   keyword_length = 2 },
  },
  completion = {
    keyword_length = 1,
    completeopt = "menu,noselect",
  },
  view = {
    entries = "custom",
  },
  formatting = {
    format = function(_, vim_item)
      -- Only use MiniIcons if the plugin was successfully loaded
      if status_icons then
        local icon, hl = MiniIcons.get("lsp", vim_item.kind)
        vim_item.kind = icon .. " " .. vim_item.kind
        vim_item.kind_hl_group = hl
      end
      return vim_item
    end,
  },
}

-- [Filetype and Cmdline configurations]

cmp.setup.filetype("tex", {
  sources = {
    { name = "omni" },
    { name = "ultisnips" },
    { name = "buffer",   keyword_length = 2 },
    { name = "path" },
  },
})

cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = "buffer" } },
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
  matching = { disallow_symbol_nonprefix_matching = false },
})

-- Visual highlighting
vim.cmd([[
  highlight! link CmpItemMenu Comment
  highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
  highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6
  highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
  highlight! CmpItemKindVariable guibg=NONE guifg=#9CDCFE
  highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE
  highlight! CmpItemKindText guibg=NONE guifg=#9CDCFE
  highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0
  highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0
  highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
  highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4
  highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4
]])
