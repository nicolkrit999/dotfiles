local keymap = vim.keymap
local hop = require("hop")
hop.setup {
  case_insensitive = true,
  quit_key = "<Esc>",
}

keymap.set({ "n", "x", "o" }, "f", "", {
  silent = true,
  noremap = true,
  callback = function()
    hop.hint_char2()
  end,
  desc = "nvim-hop char2",
})

-- Hint keys: colours from the ACTIVE colorscheme (no fixed hex): the theme's search
-- highlight (Search, else IncSearch) in bold, so the keys read like a search match.
local function get(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and hl or {}
end

local function apply_highlights()
  local search = get("Search")
  local src = search.bg and search or get("IncSearch")
  local spec
  if src.bg then
    -- the theme's own fg for that bg is the readable pair; else the editor background
    spec = { bg = src.bg, fg = src.fg or get("Normal").bg, bold = true, cterm = { bold = true } }
  else
    -- theme without a search background: use its search group as is
    spec = { link = "IncSearch" }
  end
  for _, name in ipairs { "HopNextKey", "HopNextKey1", "HopNextKey2" } do
    vim.api.nvim_set_hl(0, name, spec)
  end
end

-- once now (hop was just set up) and after every :colorscheme
apply_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("hop_theme_highlights", { clear = true }),
  callback = apply_highlights,
  desc = "hop: derive hint key colours from the new colorscheme",
})
