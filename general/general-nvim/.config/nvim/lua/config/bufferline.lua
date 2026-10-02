require("bufferline").setup {
  options = {
    numbers = "none",
    -- refuses buffers with unsaved changes: one short warning instead of the raw E89 error
    close_command = function(bufnr)
      -- with 'confirm' a cancelled prompt does not raise: the buffer simply survives (still modified).
      -- Closing the last buffer leaves a listed, unmodified empty buffer behind: that is a success.
      local ok = pcall(vim.cmd.bdelete, bufnr)
      if not ok or (vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted and vim.bo[bufnr].modified) then
        local running = false
        if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "terminal" then
          local job = vim.b[bufnr].terminal_job_id
          running = job ~= nil and vim.fn.jobwait({ job }, 0)[1] == -1
        end
        vim.notify(running and "running terminal, buffer kept" or "unsaved changes, buffer kept", vim.log.levels.WARN)
      end
    end,
    right_mouse_command = false,
    left_mouse_command = "buffer %d",
    middle_mouse_command = nil,
    indicator = {
      icon = "▎", -- this should be omitted if indicator style is not 'icon'
      style = "icon",
    },
    buffer_close_icon = "",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 18,
    max_prefix_length = 15,
    tab_size = 10,
    diagnostics = false,
    custom_filter = function(bufnr)
      -- return true to show the buffer, false to hide it

      -- filter out filetypes you don't want to see
      local exclude_ft = { "qf", "fugitive", "git" }
      local cur_ft = vim.bo[bufnr].filetype
      local should_filter = vim.tbl_contains(exclude_ft, cur_ft)

      if should_filter then
        return false
      end

      return true
    end,
    show_buffer_icons = false,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    separator_style = "thin",
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    sort_by = "id",
  },
}

vim.keymap.set("n", "<space>bp", "<cmd>BufferLinePick<CR>", {
  desc = "pick a buffer",
})
