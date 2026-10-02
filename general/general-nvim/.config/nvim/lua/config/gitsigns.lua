local gs = require("gitsigns")

gs.setup {
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "│" },
  },
  word_diff = false,
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.nav_hunk("next")
      end)
      return "<Ignore>"
    end, { expr = true, desc = "next hunk" })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.nav_hunk("prev")
      end)
      return "<Ignore>"
    end, { expr = true, desc = "previous hunk" })

    -- Actions
    map("n", "<leader>hp", gs.preview_hunk, { desc = "preview hunk" })
    map("n", "<leader>hb", function()
      gs.blame_line { full = true }
    end, { desc = "blame line (full)" })
  end,
}

local function apply_inline_hl()
  vim.cmd([[
    hi GitSignsChangeInline gui=reverse
    hi GitSignsAddInline gui=reverse
    hi GitSignsDeleteInline gui=reverse
  ]])
end

-- the colorscheme is already loaded when this file runs, so apply once now
-- and again after every later :colorscheme
apply_inline_hl()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("gitsigns_inline_hl", { clear = true }),
  pattern = "*",
  callback = apply_inline_hl,
})
