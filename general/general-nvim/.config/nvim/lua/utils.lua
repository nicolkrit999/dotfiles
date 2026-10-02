local fn = vim.fn
local version = vim.version

local M = {}

--- Check if an executable exists
--- @param name string An executable name/path
--- @return boolean
function M.executable(name)
  return fn.executable(name) > 0
end

--- check whether a feature exists in Nvim
--- @param feat string the feature name, like `nvim-0.7` or `unix`.
--- @return boolean
M.has = function(feat)
  if fn.has(feat) == 1 then
    return true
  end

  return false
end

--- Create a dir if it does not exist
function M.may_create_dir(dir)
  local res = fn.isdirectory(dir)

  if res == 0 then
    fn.mkdir(dir, "p")
  end
end

--- Generate random integers in the range [Low, High], inclusive,
--- adapted from https://stackoverflow.com/a/12739441/6064933
--- @param low integer the lower value for this range
--- @param high integer the upper value for this range
--- @return integer
function M.rand_int(low, high)
  -- Use lua to generate random int, see also: https://stackoverflow.com/a/20157671/6064933
  math.randomseed(os.time())

  return math.random(low, high)
end

--- Select a random element from a sequence/list.
--- @param seq any[] the sequence to choose an element
function M.rand_element(seq)
  local idx = M.rand_int(1, #seq)

  return seq[idx]
end

--- check if the current nvim version is compatible with the allowed version
--- @param expected_version string
--- @return boolean
function M.is_compatible_version(expected_version)
  -- check if we have the latest stable version of nvim
  local expect_ver = version.parse(expected_version)
  local actual_ver = vim.version()

  if expect_ver == nil then
    local msg = string.format("Unsupported version string: %s", expected_version)
    vim.api.nvim_echo({ { msg } }, true, { err = true })
    return false
  end

  local result = version.cmp(expect_ver, actual_ver)
  if result ~= 0 then
    local _ver = string.format("%s.%s.%s", actual_ver.major, actual_ver.minor, actual_ver.patch)
    local msg = string.format(
      "Expect nvim version %s, but your current nvim version is %s. Use at your own risk!",
      expected_version,
      _ver
    )
    vim.api.nvim_echo({ { msg } }, true, { err = true })
  end

  return true
end

--- check if we are inside a git repo
--- @return boolean
function M.inside_git_repo()
  if fn.executable("git") ~= 1 then
    return false
  end
  local ok, result = pcall(function()
    return vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { text = true }):wait()
  end)
  if not ok or result.code ~= 0 then
    return false
  end

  -- Manually trigger a special user autocmd InGitRepo (used lazyloading.
  vim.cmd([[doautocmd User InGitRepo]])

  return true
end

--- Get custom title string for the window title.
--- Shows hostname (on Linux), buffer path, and last modified time.
--- @return string
function M.get_titlestr()
  local title_str = ""
  if vim.g.is_linux then
    title_str = vim.fn.hostname() .. "  "
  end

  local buf_path = vim.fn.expand("%:p:~")
  title_str = title_str .. buf_path .. "  "
  if vim.bo.buflisted and buf_path ~= "" then
    local mod_time = vim.fn.strftime("%Y-%m-%d %H:%M:%S%z", vim.fn.getftime(vim.fn.expand("%")))
    title_str = title_str .. mod_time
  end

  return title_str
end

---Put element to the front of a list if it exists in the list
---@param items string[]
---@param ele string|nil
---@return string[]
function M.reorder_list_element(items, ele)
  if ele == nil or not vim.list_contains(items, ele) then
    return items
  end
  local new_items = { ele }
  for _, v in ipairs(items) do
    if v ~= ele then
      table.insert(new_items, v)
    end
  end
  return new_items
end

--- Get the current virtual env name ("" if none) and its kind
--- @return string venv_name
--- @return string|nil kind "venv" | "conda" | nil (no env)
function M.get_virtual_env()
  local conda_env = os.getenv("CONDA_DEFAULT_ENV")
  local venv_path = os.getenv("VIRTUAL_ENV")
  if venv_path ~= nil then
    return vim.fn.fnamemodify(venv_path, ":t"), "venv"
  end
  if conda_env ~= nil then
    return conda_env, "conda"
  end
  return "", nil
end

--- Project root for python files
--- @return string|nil
function M.get_proj_root()
  return vim.fs.root(0, { ".git", "pyproject.toml" })
end

--- Python env kind of the current project
--- @return "plain_venv"|"uv"|""|nil (nil = no project root)
function M.get_py_env()
  local project_root = M.get_proj_root()
  if project_root == nil then
    return nil
  end
  if M.get_virtual_env() ~= "" then
    return "plain_venv"
  end
  if vim.fn.filereadable(vim.fs.joinpath(project_root, "uv.lock")) == 1 then
    return "uv"
  end
  return ""
end

---@param is_local boolean
---@return string[]
function M._get_branch(is_local)
  local git_cmd
  if is_local then
    git_cmd = { "git", "branch", "--list", "--format=%(refname:short)" }
  else
    git_cmd = { "git", "for-each-ref", "--exclude=refs/remotes/*/HEAD", "--format=%(refname:short)", "refs/remotes/" }
  end
  if fn.executable("git") ~= 1 then
    return {}
  end
  local ok, result = pcall(function()
    return vim.system(git_cmd, { text = true }):wait()
  end)
  if not ok or result.code ~= 0 then
    vim.notify("error fetching git branch", vim.log.levels.WARN)
    return {}
  end
  return vim.split(result.stdout, "\n", { trimempty = true })
end

--- Get local and remote branches
---@return {local: string[], remote: string[]}
function M.get_git_branches()
  return { ["local"] = M._get_branch(true), remote = M._get_branch(false) }
end

return M
