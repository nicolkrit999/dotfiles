-- Prints which plugins lazy.nvim has loaded right after startup and which load at VeryLazy.
-- Run in an isolated state dir so the real lazy-lock.json and state stay untouched:
--   XDG_STATE_HOME=$T/st XDG_CACHE_HOME=$T/ca nvim --headless -u <nvim dir>/init.lua \
--     -c "luafile measuring-startup-loaded-plugins.lua" -c "qa!"
-- Entries of user-guide/11-plugins.md that load in every session carry the label "**Loaded at startup.**":
-- STARTUP list + VERYLAZY list, plus dashboard-nvim (bare `nvim` start) and vimtex (lazy = false, needs latex).
-- Not labelled: anything that needs a trigger (key, command, filetype, git repo, Insert mode, file open),
-- and colorscheme plugins (which theme loads depends on the machine).
local c = require("lazy.core.config")
local function snap()
  local t = {}
  for k, p in pairs(c.spec.plugins) do if p._.loaded then t[#t + 1] = k end end
  table.sort(t)
  return t
end
vim.cmd("sleep 800m")
local a = snap()
vim.cmd("doautocmd User VeryLazy")
vim.cmd("sleep 800m")
local b = snap()
local seen = {}
for _, k in ipairs(a) do seen[k] = true end
local d = {}
for _, k in ipairs(b) do if not seen[k] then d[#d + 1] = k end end
io.stdout:write("STARTUP " .. table.concat(a, " ") .. "\nVERYLAZY " .. table.concat(d, " ") .. "\n")
