-- Functional inventory dump. Run:
--   INV_OUT=<outdir> nvim --headless "+lua dofile('<path>/capture.lua')" +qa
-- Writes one sorted text file per category so `diff -r before after` shows gained/lost functionality.
local out = vim.env.INV_OUT or ((vim.env.AUDIT_OUT or "/tmp/nvim-audit") .. "/out")
vim.fn.mkdir(out, "p")

local function write(name, lines)
  table.sort(lines)
  local f = assert(io.open(out .. "/" .. name .. ".txt", "w"))
  f:write(table.concat(lines, "\n"), "\n")
  f:close()
end

-- give lazy.nvim time to finish startup (VeryLazy etc.)
vim.wait(3000, function() return false end)

-- plugins (lazy.nvim)
local plugins = {}
local ok, lazy = pcall(require, "lazy")
if ok then
  for _, p in ipairs(lazy.plugins()) do
    table.insert(plugins, string.format("%s\tenabled=%s\tlazy=%s", p.name, tostring(p.enabled ~= false), tostring(p.lazy == true)))
  end
end
write("plugins", plugins)

-- keymaps, all modes, global (lazy `keys` stubs included)
local maps = {}
for _, mode in ipairs({ "n", "v", "x", "s", "o", "i", "c", "t" }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    local lhs = m.lhs:gsub(" ", "<Space>")
    table.insert(maps, string.format("%s\t%s\t%s", mode, lhs, m.desc or m.rhs or (m.callback and "<lua fn>") or ""))
  end
end
write("keymaps", maps)

-- user commands
local cmds = {}
for name, c in pairs(vim.api.nvim_get_commands({})) do
  table.insert(cmds, name .. "\tnargs=" .. tostring(c.nargs))
end
write("commands", cmds)

-- autocmd groups + events
local au = {}
for _, a in ipairs(vim.api.nvim_get_autocmds({})) do
  if a.group_name then
    table.insert(au, string.format("%s\t%s\t%s", a.group_name, a.event, a.pattern or ""))
  end
end
local seen, uniq = {}, {}
for _, l in ipairs(au) do if not seen[l] then seen[l] = true; table.insert(uniq, l) end end
write("autocmds", uniq)

-- LSP configs enabled via vim.lsp.enable / config
local lsp = {}
for name, _ in pairs(vim.lsp._enabled_configs or {}) do table.insert(lsp, name) end
write("lsp_enabled", lsp)

-- selected options
local opts = {}
for _, o in ipairs({ "number", "relativenumber", "clipboard", "mouse", "undofile", "signcolumn", "completeopt",
  "diffopt", "foldmethod", "foldexpr", "spelllang", "wrap", "expandtab", "shiftwidth", "tabstop", "scrolloff",
  "termguicolors", "laststatus", "showtabline", "cmdheight", "updatetime", "timeoutlen", "winborder", "pumborder" }) do
  local okk, v = pcall(function() return vim.o[o] end)
  table.insert(opts, o .. "=" .. (okk and tostring(v) or "<n/a>"))
end
write("options", opts)

write("meta", { "colorscheme=" .. (vim.g.colors_name or ""), "leader=" .. vim.inspect(vim.g.mapleader),
  "nvim=" .. tostring(vim.version()) })
