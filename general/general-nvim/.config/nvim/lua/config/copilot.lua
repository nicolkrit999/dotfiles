-- Protect against missing plugin
local status, copilot = pcall(require, "copilot")
if not status then return end

copilot.setup({
  suggestion = {
    enabled = true,
    auto_trigger = true, -- Suggest as you type
    keymap = {
      accept = "<Tab>",   -- Only Tab accepts
      accept_word = false,
      accept_line = false,
      -- You can unbind other keys if you want
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  panel = { enabled = false }, -- Disable the side panel if you don't use it
})
