require("which-key").setup {
  preset = "modern",
  icons = {
    mappings = false,
  },
}

-- group labels only (no mappings are created here)
require("which-key").add {
  { "<leader>j", group = "Java" },
  { "<leader>jb", group = "Java build" },
  { "<leader>jr", group = "Java runner" },
  { "<leader>jt", group = "Java test" },
  { "<leader>je", group = "Java extract" },
}
