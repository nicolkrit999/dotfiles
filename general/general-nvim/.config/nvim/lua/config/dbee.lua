-- nvim-dbee: SQL database client inside Neovim (Go backend, Lua/nui.nvim frontend).
-- https://github.com/kndndrj/nvim-dbee
local dbee = require("dbee")

dbee.setup {
  sources = {
    -- PUBLIC REPO: real connection strings/credentials must NEVER be hardcoded
    -- here. EnvSource reads a JSON array of connections from the
    -- $DBEE_CONNECTIONS environment variable at runtime instead. Set it in an
    -- untracked shell file, direnv, or via sops -- never commit it. Example:
    --
    --   export DBEE_CONNECTIONS='[
    --     {
    --       "name": "local-postgres",
    --       "type": "postgres",
    --       "url": "postgres://user:password@localhost:5432/mydb?sslmode=disable"
    --     }
    --   ]'
    --
    -- If $DBEE_CONNECTIONS is unset, this source is simply empty -- no error.
    require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
  },
}

-- Global entry points for the UI. Per-connection actions (execute statement,
-- store result, navigate the drawer tree, etc.) use dbee's own buffer-local
-- keymaps inside the Dbee UI, configurable via the `mappings` table passed to
-- setup() above if you want to change them from the plugin's defaults.
local keymap = vim.keymap
keymap.set("n", "<leader>Dt", function() dbee.toggle() end, { desc = "Dbee: Toggle UI" })
keymap.set("n", "<leader>Do", function() dbee.open() end, { desc = "Dbee: Open UI" })
keymap.set("n", "<leader>Dc", function() dbee.close() end, { desc = "Dbee: Close UI" })
