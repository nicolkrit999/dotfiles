local ok, diffview = pcall(require, "diffview")
if not ok then
  return
end

local actions = require("diffview.actions")

diffview.setup {
  enhanced_diff_hl = true,
  view = {
    default = {
      -- no diagnostics signs inside :DiffviewOpen
      disable_diagnostics = true,
    },
    merge_tool = {
      layout = "diff3_mixed",
    },
  },
  file_history_panel = {
    win_config = {
      type = "split",
      position = "bottom",
      height = 10,
    },
  },
  keymaps = {
    view = {
      -- merge conflicts (buffer-local inside a diffview view)
      { "n", "<leader>gCt", actions.conflict_choose("theirs"), { desc = "Conflict choose theirs" } },
      { "n", "<leader>gCo", actions.conflict_choose("ours"), { desc = "Conflict choose ours" } },
      { "n", "<leader>gCa", actions.conflict_choose("all"), { desc = "Conflict choose both" } },
      { "n", "<leader>gCb", actions.conflict_choose("base"), { desc = "Conflict choose base" } },
      -- diffview defaults replaced by <leader>gC*; disabled so the user's global
      -- <leader>cb (show cursor) and LSP <leader>ca (code action) keep working inside diffview
      { "n", "<leader>co", false },
      { "n", "<leader>ct", false },
      { "n", "<leader>cb", false },
      { "n", "<leader>ca", false },
      { "n", "]C", actions.next_conflict, { desc = "Next conflict" } },
      { "n", "[C", actions.prev_conflict, { desc = "Previous conflict" } },
    },
  },
}
