local handler = function(virtText, lnum, endLnum, width, truncate, ctx)
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
      -- the text (plus padding) now fills targetWidth: no extra right-align padding below
      curWidth = targetWidth
      break
    end
    curWidth = curWidth + chunkWidth
  end
  -- align the suffix to textwidth of the FOLDED buffer; textwidth 0 -> the window edge
  local tw = (ctx and ctx.bufnr and vim.api.nvim_buf_is_valid(ctx.bufnr)) and vim.bo[ctx.bufnr].textwidth or vim.bo.textwidth
  local alignTo = tw > 0 and math.min(tw, width - 1) or (width - 1)
  local rAlignAppndx = math.max(alignTo - curWidth - sufWidth, 0)
  suffix = (" "):rep(rAlignAppndx) .. suffix
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end

require("ufo").setup {
  fold_virt_text_handler = handler,
}

-- Fold level stepping. ufo needs 'foldlevel' to stay high, so its zM closes every fold but leaves
-- 'foldlevel' at 99; with builtin zr/zm the first zr after zM would then open ALL folds. Instead zr/zm
-- read the level from the folds as they are shown (one below the shallowest closed fold, or the
-- deepest level when none is closed) and apply level +/- count with closeFoldsWith(). Nothing is
-- stored, so a reload, another buffer, a new window or a manual zo/zc can never leave a stale level.
-- Buffers without ufo fall back to the builtin keys.
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
  local level = visible_level() or deepest
  ufo.closeFoldsWith(math.max(0, math.min(deepest, level + delta * vim.v.count1)))
end

-- ufo runs "silent! %foldopen!" / "%foldclose!": silent! still leaves E490 in v:errmsg in a buffer
-- without folds, so keep v:errmsg as it was
local function keep_errmsg(fn)
  local errmsg = vim.v.errmsg
  fn()
  vim.v.errmsg = errmsg
end

vim.keymap.set("n", "zR", function()
  keep_errmsg(ufo.openAllFolds)
end, { desc = "Open all folds" })
vim.keymap.set("n", "zM", function()
  keep_errmsg(ufo.closeAllFolds)
end, { desc = "Close all folds" })
vim.keymap.set("n", "zr", function()
  step_folds(1, "zr")
end, { desc = "Open one more fold level" })
vim.keymap.set("n", "zm", function()
  step_folds(-1, "zm")
end, { desc = "Close one more fold level" })
vim.keymap.set("n", "<leader>K", function()
  require("ufo").peekFoldedLinesUnderCursor()
end, {
  desc = "Preview folded lines",
})
