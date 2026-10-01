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

-- Fold level counter (per window AND buffer). ufo needs 'foldlevel' to stay high, so its zM closes
-- every fold but leaves 'foldlevel' at 99; with builtin zr/zm the first zr after zM would then open
-- ALL folds. Instead track the level in w:ufo_foldlevels[bufnr] and apply it with closeFoldsWith():
-- zM -> 0, zr -> +count, zm -> -count, zR -> deepest (all open). With no stored level (new window,
-- other buffer) the level is read from the folds as they are shown: one below the shallowest closed
-- fold, or the deepest level when none is closed. Buffers without ufo fall back to the builtin keys.
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

-- level as currently visible: shallowest closed fold level - 1 (the lowest foldlevel() inside a
-- closed fold is that fold's own level); nil when no fold is closed
local function visible_level()
  local min
  local lnum, last = 1, vim.api.nvim_buf_line_count(0)
  while lnum <= last do
    local fend = vim.fn.foldclosedend(lnum)
    if fend == -1 then
      lnum = lnum + 1
    else
      for l = lnum, fend do
        local lv = vim.fn.foldlevel(l)
        if min == nil or lv < min then
          min = lv
        end
      end
      lnum = fend + 1
    end
  end
  return min and math.max(0, min - 1)
end

local function set_level(level)
  local levels = vim.w.ufo_foldlevels or {}
  -- string keys: a sparse integer-keyed table cannot be stored in a w: variable
  levels[tostring(vim.api.nvim_get_current_buf())] = level
  vim.w.ufo_foldlevels = levels
end

local function step_folds(delta, builtin)
  if not ufo.hasAttached() then
    -- pcall: a buffer without folds must not raise E490 (and not leave it in v:errmsg)
    local errmsg = vim.v.errmsg
    pcall(vim.cmd, "normal! " .. vim.v.count1 .. builtin)
    vim.v.errmsg = errmsg
    return
  end
  local deepest = deepest_level()
  if deepest == 0 then
    return -- no folds in this buffer: nothing to do (builtin zr/zm would only raise E490)
  end
  local level = (vim.w.ufo_foldlevels or {})[tostring(vim.api.nvim_get_current_buf())]
  if level == nil then
    level = visible_level() or deepest
  end
  level = math.max(0, math.min(deepest, level + delta * vim.v.count1))
  set_level(level)
  ufo.closeFoldsWith(level)
end

vim.keymap.set("n", "zR", function()
  set_level(nil) -- nil = read from the folds next time (all open = deepest)
  ufo.openAllFolds()
end, { desc = "Open all folds" })
vim.keymap.set("n", "zM", function()
  set_level(0)
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
