local nvim_notify = require("notify")

-- Fade animations need a solid colour behind the popups. It comes from the ACTIVE colorscheme
-- (no fixed hex): the first of these groups that defines a background.
local bg_sources = { "Normal", "NormalFloat", "StatusLine", "CursorLine" }

local function apply_background()
  for _, name in ipairs(bg_sources) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl.bg then
      vim.api.nvim_set_hl(0, "NotifyBackground", { bg = hl.bg })
      return
    end
  end
  -- fully transparent theme: none of them has a background. Nothing is invented here:
  -- NotifyBackground keeps nvim-notify's own default (link Normal), so nvim-notify shows
  -- its one-time "no background" warning and falls back to its built-in colour.
  vim.api.nvim_set_hl(0, "NotifyBackground", { link = "Normal" })
end

nvim_notify.setup {
  -- Animation style
  stages = "fade_in_slide_out",
  -- Default timeout for notifications
  timeout = 1500,
  -- read on every popup, so it follows :colorscheme (set by apply_background below)
  background_colour = "NotifyBackground",
}

apply_background()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("notify_theme_background", { clear = true }),
  callback = apply_background,
  desc = "notify: background colour from the new colorscheme",
})

vim.notify = nvim_notify
