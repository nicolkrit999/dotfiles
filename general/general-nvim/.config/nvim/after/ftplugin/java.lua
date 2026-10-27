-- <leader>jrc: run a Java 25 compact source file (JEP 512: no package line, no top-level type) with the
-- source launcher (`java File.java`) in a terminal split. jdtls cannot run such a file (it compiles a
-- stub class and fails with 'declared package "" does not match the expected package'), so
-- <leader>jrr (JavaRunnerRunMain) stays for normal classes. The terminal inherits vim.env, so
-- JAVA_HOME/JAVA_TOOL_OPTIONS (lombok agent) from the devShell (:DevEnv java) apply.

local is_compact = require("java_compact").is_compact

vim.keymap.set("n", "<leader>jrc", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    vim.notify("Java: save the buffer to a file first", vim.log.levels.WARN)
    return
  end
  if vim.fn.executable("java") ~= 1 then
    vim.notify("Java: java not on PATH (open nvim inside the Java devShell, or run :DevEnv java)", vim.log.levels.WARN)
    return
  end
  if not is_compact(bufnr) then
    vim.notify("Java: not a compact source file (has a package line or a top-level type); use <leader>jrr", vim.log.levels.WARN)
    return
  end
  if vim.bo[bufnr].modified then
    vim.cmd("silent write")
  end
  vim.cmd("botright 12split")
  vim.cmd("terminal java " .. vim.fn.shellescape(path))
end, { buffer = true, desc = "Java: run compact source file (java File.java)" })
