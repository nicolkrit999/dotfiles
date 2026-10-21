-- Highlights of the floating cmdline are derived from the active colorscheme (on Nix that is the
-- base16 theme from NVIM_BASE16_THEME, see colorschemes.lua), once now and after every :colorscheme.
-- A theme that leaves the needed colours unset keeps tiny-cmdline's own default links.

local function get(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and hl or {}
end

local function apply_highlights()
  local normal = get("Normal")
  local bg = get("NormalFloat").bg or normal.bg
  local accent = get("FloatBorder").fg or get("Special").fg or get("Function").fg

  if bg and normal.fg then
    vim.api.nvim_set_hl(0, "TinyCmdlineNormal", { bg = bg, fg = normal.fg })
  else
    vim.api.nvim_set_hl(0, "TinyCmdlineNormal", { link = "MsgArea" })
  end

  if accent then
    vim.api.nvim_set_hl(0, "TinyCmdlineBorder", { fg = accent, bg = bg })
    vim.api.nvim_set_hl(0, "TinyCmdlineTitle", { fg = accent, bg = bg, bold = true })
  else
    vim.api.nvim_set_hl(0, "TinyCmdlineBorder", { link = "FloatBorder" })
    vim.api.nvim_set_hl(0, "TinyCmdlineTitle", { link = "FloatTitle" })
  end
end

require("tiny-cmdline").setup {}

apply_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("tiny_cmdline_theme_highlights", { clear = true }),
  callback = apply_highlights,
  desc = "tiny-cmdline: derive window colours from the new colorscheme",
})

-- nvim-cmp anchors its menu to the bottom row, but the cmdline is now a centred window. tiny-cmdline
-- publishes the spot just below that window in vim.g.ui_cmdline_pos (the blink.cmp/nvim-cmp anchor);
-- nvim-cmp ignores it, so its cmdline cursor position is shifted there. Done on the first CmdlineEnter,
-- when nvim-cmp is certainly loaded; without nvim-cmp or with the anchor unset nothing changes.
vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = vim.api.nvim_create_augroup("tiny_cmdline_cmp_anchor", { clear = true }),
  once = true,
  callback = function()
    local ok, cmp_api = pcall(require, "cmp.utils.api")
    if not ok or type(cmp_api.get_screen_cursor) ~= "function" then
      return
    end
    local screen_cursor = cmp_api.get_screen_cursor
    cmp_api.get_screen_cursor = function()
      local pos = screen_cursor()
      local anchor = vim.g.ui_cmdline_pos
      if anchor and cmp_api.is_cmdline_mode() then
        return { anchor[1], anchor[2] + pos[2] }
      end
      return pos
    end
  end,
  desc = "tiny-cmdline: place the nvim-cmp menu under the centred cmdline",
})
