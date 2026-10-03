local keymap = vim.keymap

keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git: show status" })
keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git: add current file" })
keymap.set("n", "<leader>ga", "<cmd>Git add -A<cr>", { desc = "Git: add all changes" })
keymap.set("n", "<leader>gu", "<cmd>Git restore --staged -- %<cr>", { desc = "Git: unstage current file" })
keymap.set("n", "<leader>gx", function()
  if vim.fn.confirm("Discard all changes in this file (git restore)?", "&Yes\n&No", 2) == 1 then
    vim.cmd("Git restore -- %")
    vim.cmd("checktime")
  end
end, { desc = "Git: discard changes in file (confirm)" })
keymap.set("n", "<leader>gv", "<cmd>Gvdiffsplit<cr>", { desc = "Git: vertical diff against index" })
keymap.set("n", "<leader>gL", "<cmd>Git log --oneline -- %<cr>", { desc = "Git: log of current file" })
keymap.set("n", "<leader>gA", "<cmd>Git commit --amend<cr>", { desc = "Git: amend last commit" })
keymap.set("n", "<leader>gz", "<cmd>Git stash<cr>", { desc = "Git: stash changes" })
keymap.set("n", "<leader>gZ", "<cmd>Git stash pop<cr>", { desc = "Git: pop stash" })
keymap.set("n", "<leader>gm", ":Git merge ", { desc = "Git: merge (type branch)" })
keymap.set("n", "<leader>gR", ":Git rebase ", { desc = "Git: rebase (type args)" })
keymap.set("n", "<leader>gn", "<cmd>Neogit<cr>", { desc = "Git: open Neogit" })
keymap.set("n", "<leader>gD", "<cmd>DiffviewOpen<cr>", { desc = "Git: open Diffview" })
keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git: commit changes" })
keymap.set("n", "<leader>gpl", "<cmd>Git pull<cr>", { desc = "Git: pull changes" })
keymap.set("n", "<leader>gpu", "<cmd>15 split|term git push<cr>", { desc = "Git: push changes" })
keymap.set("x", "<leader>gb", ":Git blame<cr>", { desc = "Git: blame selected line" })

-- convert git to Git in command line mode
vim.fn["utils#Cabbrev"]("git", "Git")

keymap.set("n", "<leader>gbn", function()
  vim.ui.input({ prompt = "Enter a new branch name" }, function(user_input)
    if user_input == nil or user_input == "" then
      return
    end

    -- whitespace, `|` (Ex command separator), `"` and `\` can never be part of the name here:
    -- refuse instead of letting :Git parse them as extra arguments / commands
    if user_input:find('[%s|"\\]') then
      vim.notify("Invalid branch name (no spaces, |, \" or \\)", vim.log.levels.WARN)
      return
    end
    -- :Git expands %, # and <cword>-style tokens in its arguments: escape them so the name is literal
    local name = user_input:gsub("[%%#<]", "\\%0")
    vim.cmd { cmd = "Git", args = { "checkout -b " .. name } }
  end)
end, {
  desc = "Git: create new branch",
})

keymap.set("n", "<leader>gf", ":Git fetch ", { desc = "Git: fetch (type args)" })
keymap.set("n", "<leader>gbd", ":Git branch -D ", { desc = "Git: delete branch (type name)" })
