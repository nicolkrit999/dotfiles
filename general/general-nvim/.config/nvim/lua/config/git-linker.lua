local keymap = vim.keymap
local gitlinker = require("gitlinker")

gitlinker.setup {
  callbacks = {
    ["dev.azure.com"] = function(url_data)
      local url = require("gitlinker.hosts").get_base_https_url(url_data)

      if url_data.lstart then
        if url_data.lend == nil then
          url_data.lend = url_data.lstart
        end
        url = url
          .. "?path=/"
          .. url_data.file
          .. "&version=GC"
          .. url_data.rev
          .. "&line="
          .. url_data.lstart
          .. "&lineEnd="
          .. url_data.lend
          .. "&lineStartColumn=1"
          .. "&lineEndColumn=120"
      end
      return url
    end,
  },
  -- gitlinker has no option to skip its default maps (nil = "<leader>gy" in n + v),
  -- so they are deleted right below: <leader>gl is the only permalink key
  mappings = nil,
}
pcall(keymap.del, "n", "<leader>gy")
pcall(keymap.del, "v", "<leader>gy")

keymap.set({ "n", "x" }, "<leader>gl", function()
  -- any visual mode (v, V, blockwise) is a range: only normal mode stays 'n'
  local mode = vim.fn.mode() == "n" and "n" or "v"
  gitlinker.get_buf_range_url(mode)
end, {
  silent = true,
  desc = "Git: get permalink",
})

keymap.set("n", "<leader>gbr", function()
  gitlinker.get_repo_url {
    action_callback = gitlinker.actions.open_in_browser,
  }
end, {
  silent = true,
  desc = "Git: browse repo in browser",
})
