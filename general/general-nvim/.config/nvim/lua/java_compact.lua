-- Detection of Java 25 compact source files (JEP 512): no package line, no top-level type.
-- Used by after/ftplugin/java.lua (<leader>jrc) and config/nvim-java.lua (diagnostic filter).
local M = {}

local MODIFIERS = { public = 1, private = 1, protected = 1, abstract = 1, final = 1, sealed = 1, static = 1, strictfp = 1 }
local TYPES = { class = 1, interface = 1, record = 1, enum = 1 }

-- true when an unindented line declares a type (modifiers and @Annotations before the keyword skipped)
local function declares_type(line)
  if line:match("^%s") then
    return false
  end
  for word in line:gmatch("[%w_@-]+") do
    if TYPES[word] then
      return true
    elseif not (MODIFIERS[word] or word == "non-sealed" or word:sub(1, 1) == "@") then
      return false
    end
  end
  return false
end

--- @param lines string[]
function M.lines_are_compact(lines)
  for _, line in ipairs(lines) do
    if line:match("^package%s") or declares_type(line) then
      return false
    end
  end
  return true
end

--- @param bufnr integer
function M.is_compact(bufnr)
  return M.lines_are_compact(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
end

--- like is_compact, for a file URI (loaded buffer text if there is one, else the file on disk)
--- @param uri string
function M.uri_is_compact(uri)
  local bufnr = vim.uri_to_bufnr(uri)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    return M.is_compact(bufnr)
  end
  local ok, lines = pcall(vim.fn.readfile, vim.uri_to_fname(uri))
  return ok and M.lines_are_compact(lines)
end

return M
