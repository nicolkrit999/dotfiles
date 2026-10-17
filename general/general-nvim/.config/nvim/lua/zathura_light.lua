-- Every zathura window started from Neovim (user guide <Space>?, vimtex, typst watch) opens light
-- (Catppuccin Latte), whatever the host's zathurarc says (here Mocha with recolor). A throw-away
-- config dir includes the user's own zathurarc (keys, font) and then overrides only the colours.
local M = {}

local light_rc = {
  'set recolor "false"',
  'set default-bg "#eff1f5"',
  'set default-fg "#4c4f69"',
  'set statusbar-bg "#ccd0da"',
  'set statusbar-fg "#4c4f69"',
  'set inputbar-bg "#e6e9ef"',
  'set inputbar-fg "#4c4f69"',
  'set notification-bg "#e6e9ef"',
  'set notification-fg "#4c4f69"',
  'set notification-error-bg "#e6e9ef"',
  'set notification-error-fg "#d20f39"',
  'set notification-warning-bg "#e6e9ef"',
  'set notification-warning-fg "#df8e1d"',
  'set completion-bg "#e6e9ef"',
  'set completion-fg "#4c4f69"',
  'set completion-group-bg "#ccd0da"',
  'set completion-group-fg "#1e66f5"',
  'set completion-highlight-bg "#bcc0cc"',
  'set completion-highlight-fg "#4c4f69"',
  'set index-bg "#eff1f5"',
  'set index-fg "#4c4f69"',
  'set index-active-bg "#ccd0da"',
  'set index-active-fg "#4c4f69"',
  'set highlight-color "rgba(223,142,29,0.4)"',
  'set highlight-active-color "rgba(30,102,245,0.4)"',
}

---@return string dir for `zathura --config-dir=`
function M.config_dir()
  local dir = vim.fn.stdpath("cache") .. "/zathura-light"
  vim.fn.mkdir(dir, "p")
  local lines = {}
  local user_rc = vim.fn.expand("~/.config/zathura/zathurarc")
  if vim.fn.filereadable(user_rc) == 1 then table.insert(lines, "include " .. user_rc) end
  vim.list_extend(lines, light_rc)
  vim.fn.writefile(lines, dir .. "/zathurarc")
  return dir
end

--- Executable wrapper named like a viewer, for tools that only take a program name
--- (typst's `--open <app>` cannot pass arguments).
---@return string path
function M.wrapper()
  local dir = M.config_dir()
  local path = dir .. "/zathura-light"
  vim.fn.writefile({ "#!/bin/sh", 'exec zathura --config-dir="' .. dir .. '" "$@"' }, path)
  vim.uv.fs_chmod(path, 493) -- 0755
  return path
end

--- Catch-all: a shim called `zathura` first on Neovim's PATH, so ANY zathura started from Neovim
--- (plugins, `:!zathura`, a devShell's copy) is light. The shim drops its own folder from PATH to
--- find the real zathura. Call again after PATH changes (lua/devenv.lua does).
function M.shim_path()
  if vim.fn.has("unix") == 0 then return end
  local dir = vim.fn.stdpath("cache") .. "/zathura-shim"
  local cfg = M.config_dir()
  vim.fn.mkdir(dir, "p")
  local path = dir .. "/zathura"
  vim.fn.writefile({
    "#!/bin/sh",
    'self="' .. dir .. '"',
    'PATH=$(printf %s "$PATH" | tr ":" "\\n" | grep -vxF "$self" | paste -sd: -)',
    'exec zathura --config-dir="' .. cfg .. '" "$@"',
  }, path)
  vim.uv.fs_chmod(path, 493)
  local cur = vim.env.PATH or ""
  if vim.split(cur, ":", { plain = true })[1] ~= dir then
    vim.env.PATH = dir .. ":" .. cur
  end
end

return M
