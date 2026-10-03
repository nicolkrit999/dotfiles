require("colorful-menu").setup {
  ls = {
    lua_ls = { arguments_hl = "@comment" },
    clangd = {
      extra_info_hl = "@comment",
      align_type_to_right = true,
      import_dot_hl = "@comment",
      preserve_type_when_truncate = true,
    },
    -- also applies to pyright (colorful-menu routes it through the same branch)
    basedpyright = { extra_info_hl = "@comment" },
    pylsp = { extra_info_hl = "@comment", arguments_hl = "@comment" },
    fallback = true,
    fallback_extra_info_hl = "@comment",
  },
  fallback_highlight = "@variable",
  max_width = 60,
}
