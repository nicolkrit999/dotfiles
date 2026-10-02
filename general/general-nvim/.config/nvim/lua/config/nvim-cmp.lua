-- 1. Protect against crash if cmp isn't loaded yet
local status_cmp, cmp = pcall(require, "cmp")
if not status_cmp then return end

-- 2. Protect against crash if mini.icons isn't loaded yet
local status_icons, MiniIcons = pcall(require, "mini.icons")

-- 3. colorful-menu: completion labels highlighted like code (optional)
local status_colorful, colorful_menu = pcall(require, "colorful-menu")

-- Standard source loading (pcall wrapped to be extra safe)
pcall(require, "cmp_nvim_lsp")
pcall(require, "cmp_path")
pcall(require, "cmp_buffer")
pcall(require, "cmp_omni")
pcall(require, "cmp_nvim_ultisnips")
pcall(require, "cmp_cmdline")

-- UltiSnips triggers (<C-j> expand/jump forward, <C-k> jump back) are set only
-- in the ultisnips spec init (lua/plugin_specs.lua): single source of truth.

cmp.setup {
  -- nvim-cmp default + `vim.b.completion = false` turns completion off for a buffer
  -- (set by the Snacks.bigfile setup in lua/config/bigfile.lua)
  enabled = function()
    if vim.b.completion == false then return false end
    if vim.bo.buftype == "prompt" then return false end
    return vim.fn.reg_recording() == "" and vim.fn.reg_executing() == ""
  end,
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        -- 1. If the autocomplete menu is open, Tab scrolls the menu
        cmp.select_next_item()
      else
        -- 2. Otherwise, do a normal Tab (or indent)
        fallback()
      end
    end, { "i", "s" }),

    -- confirm only an item picked with <Tab>/<C-n>; nothing selected -> plain newline
    ["<CR>"] = cmp.mapping.confirm { select = false },

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
    format = function(entry, vim_item)
      -- Only use MiniIcons if the plugin was successfully loaded
      if status_icons then
        local icon, hl = MiniIcons.get("lsp", vim_item.kind)
        vim_item.kind = icon .. " " .. vim_item.kind
        vim_item.kind_hl_group = hl
      end
      if status_colorful then
        local highlights_info = colorful_menu.cmp_highlights(entry)
        if highlights_info ~= nil then
          vim_item.abbr_hl_group = highlights_info.highlights
          vim_item.abbr = highlights_info.text
        end
      end
      return vim_item
    end,
  },
}

-- [Filetype and Cmdline configurations]

cmp.setup.filetype("tex", {
  sources = {
    { name = "omni" },
    { name = "nvim_lsp" }, -- texlab (LaTeX devShell); no-op when no LSP is attached
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

-- Visual highlighting: every colour comes from the ACTIVE colorscheme's groups (no fixed hex),
-- re-applied on :colorscheme (which clears all highlights)
local function first_fg(groups)
  for _, name in ipairs(groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl.fg then
      return hl.fg
    end
  end
end

-- fg only (bg stays NONE so the menu background shows through); a group missing in the theme
-- falls back to a plain link to the first source group
local function fg_from(target, groups, extra)
  local fg = first_fg(groups)
  if fg then
    vim.api.nvim_set_hl(0, target, vim.tbl_extend("force", { fg = fg }, extra or {}))
  else
    vim.api.nvim_set_hl(0, target, { link = groups[1] })
  end
end

local function apply_highlights()
  vim.api.nvim_set_hl(0, "CmpItemMenu", { link = "Comment" })
  fg_from("CmpItemAbbrDeprecated", { "Comment" }, { strikethrough = true })
  fg_from("CmpItemAbbrMatch", { "Function", "Special" }, { bold = true })
  fg_from("CmpItemAbbrMatchFuzzy", { "Function", "Special" }, { bold = true })
  fg_from("CmpItemKindVariable", { "Identifier" })
  fg_from("CmpItemKindInterface", { "Type" })
  fg_from("CmpItemKindText", { "Normal" })
  fg_from("CmpItemKindFunction", { "Function" })
  fg_from("CmpItemKindMethod", { "Function" })
  fg_from("CmpItemKindKeyword", { "Keyword", "Statement" })
  fg_from("CmpItemKindProperty", { "@property", "Identifier" })
  fg_from("CmpItemKindUnit", { "Number" })
end

apply_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("cmp_theme_highlights", { clear = true }),
  callback = apply_highlights,
  desc = "cmp: derive completion menu colours from the new colorscheme",
})
