local keymap = vim.keymap

keymap.set("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git: show status" })
keymap.set("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git: add file" })
keymap.set("n", "<leader>ga", "<cmd>Git add -A<cr>", { desc = "Git: add all changes" })
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
