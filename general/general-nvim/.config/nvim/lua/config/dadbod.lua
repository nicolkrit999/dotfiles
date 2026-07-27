-- vim-dadbod-ui: browsable UI (connection tree, saved queries, results pane)
-- for vim-dadbod. https://github.com/kristijanhusak/vim-dadbod-ui
-- Bare vim-dadbod itself needs no setup -- it just provides the :DB command
-- (e.g. `:DB sqlite:myfile.sqlite3 select count(*) from widgets`, or
-- `:%DB mysql://root@localhost/bazquux` to run the current buffer/range as
-- a query). This file only configures the UI layer.

-- PUBLIC REPO: real connection strings/credentials must NEVER be hardcoded
-- into g:dbs. Populate it at runtime from the $DADBOD_CONNECTIONS
-- environment variable instead (kept distinct from nvim-dbee's
-- $DBEE_CONNECTIONS to avoid confusion between the two plugins -- see
-- lua/config/dbee.lua for that convention). Set it in an untracked shell
-- file, direnv, or via sops -- never commit it. Expected format is a JSON
-- object mapping connection name -> URL, e.g.:
--
--   export DADBOD_CONNECTIONS='{
--     "local-postgres": "postgres://user:password@localhost:5432/mydb?sslmode=disable"
--   }'
--
-- If $DADBOD_CONNECTIONS is unset or fails to parse, g:dbs stays empty and
-- you can add connections interactively at runtime with :DBUIAddConnection,
-- or edit them by hand for a single session only (never commit real values).
local raw = vim.env.DADBOD_CONNECTIONS
if raw then
  local ok, decoded = pcall(vim.json.decode, raw)
  if ok and type(decoded) == "table" then
    vim.g.dbs = decoded
  else
    vim.notify("dadbod: failed to parse $DADBOD_CONNECTIONS as JSON", vim.log.levels.WARN)
  end
end

-- Save query results/snippets under nvim's data dir rather than a
-- hardcoded home-relative path, so this stays portable across machines.
vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

-- Use nerdfont-style icons to match the rest of the UI (nvim-tree, etc.).
vim.g.db_ui_use_nerd_fonts = 1

-- Global entry points for the UI. vim-dadbod-ui also sets its own
-- buffer-local keymaps inside the DBUI drawer/result buffers (execute
-- query, toggle details, etc.) -- see `:help db_ui` for the full list.
local keymap = vim.keymap
keymap.set("n", "<leader>Du", "<cmd>DBUIToggle<cr>", { desc = "Dadbod: Toggle UI" })
keymap.set("n", "<leader>Da", "<cmd>DBUIAddConnection<cr>", { desc = "Dadbod: Add connection" })
keymap.set("n", "<leader>Df", "<cmd>DBUIFindBuffer<cr>", { desc = "Dadbod: Find buffer" })
