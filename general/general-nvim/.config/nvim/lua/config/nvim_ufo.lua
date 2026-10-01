local handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local foldedLines = endLnum - lnum
  local suffix = (" 󰁂  %d"):format(foldedLines)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0

  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  local rAlignAppndx = math.max(math.min(vim.o.textwidth, width - 1) - curWidth - sufWidth, 0)
  suffix = (" "):rep(rAlignAppndx) .. suffix
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end

require("ufo").setup {
  fold_virt_text_handler = handler,
}

-- Fold level counter (per window). ufo needs 'foldlevel' to stay high, so its zM closes every
-- fold but leaves 'foldlevel' at 99; with builtin zr/zm the first zr after zM would then open
-- ALL folds. Instead track the level in w:ufo_foldlevel and apply it with closeFoldsWith():
-- zM -> 0, zr -> +count, zm -> -count, zR -> deepest (all open). Buffers without ufo fall back
-- to the builtin keys.
local ufo = require("ufo")

local function deepest_level()
  local max = 0
  for lnum = 1, vim.api.nvim_buf_line_count(0) do
    local l = vim.fn.foldlevel(lnum)
    if l > max then
      max = l
    end
  end
  return max
end

local function step_folds(delta, builtin)
  if not ufo.hasAttached() then
    vim.cmd("normal! " .. vim.v.count1 .. builtin)
    return
  end
  local deepest = deepest_level()
  local level = vim.w.ufo_foldlevel
  if level == nil or level > deepest then
    level = deepest
  end
  level = math.max(0, math.min(deepest, level + delta * vim.v.count1))
  vim.w.ufo_foldlevel = level
  ufo.closeFoldsWith(level)
end

vim.keymap.set("n", "zR", function()
  vim.w.ufo_foldlevel = nil -- nil = deepest (all open)
  ufo.openAllFolds()
end, { desc = "Open all folds" })
vim.keymap.set("n", "zM", function()
  vim.w.ufo_foldlevel = 0
  ufo.closeAllFolds()
end, { desc = "Close all folds" })
vim.keymap.set("n", "zr", function()
  step_folds(1, "zr")
end, { desc = "Open one more fold level" })
vim.keymap.set("n", "zm", function()
  step_folds(-1, "zm")
end, { desc = "Close one more fold level" })
vim.keymap.set("n", "<leader>K", function()
  local _ = require("ufo").peekFoldedLinesUnderCursor()
end, {
  desc = "Preview folded lines",
})
