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

    local function confirm_then(msg, fn)
      return function()
        if vim.fn.confirm(msg, "&Yes\n&No", 2) == 1 then
          fn()
        end
      end
    end
    local function visual_range()
      return { vim.fn.line("."), vim.fn.line("v") }
    end

    map("n", "<leader>hs", gs.stage_hunk, { desc = "Git: stage hunk" })
    map("x", "<leader>hs", function()
      gs.stage_hunk(visual_range())
    end, { desc = "Git: stage selected lines" })
    map("n", "<leader>hr", confirm_then("Reset this hunk (discard the change)?", gs.reset_hunk), { desc = "Git: reset hunk (confirm)" })
    map("x", "<leader>hr", confirm_then("Reset the selected lines (discard the change)?", function()
      gs.reset_hunk(visual_range())
    end), { desc = "Git: reset selected lines (confirm)" })
    map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Git: unstage last staged hunk" })
    map("n", "<leader>hS", gs.stage_buffer, { desc = "Git: stage whole buffer" })
    map("n", "<leader>hR", confirm_then("Reset the whole buffer (discard all changes in this file)?", gs.reset_buffer), { desc = "Git: reset whole buffer (confirm)" })
    map("n", "<leader>hd", gs.diffthis, { desc = "Git: diff file against index" })
    map("n", "<leader>ht", gs.toggle_deleted, { desc = "Git: toggle deleted lines" })
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
