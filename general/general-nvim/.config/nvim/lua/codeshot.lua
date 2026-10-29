-- <leader>ss: "code screenshot". Renders the visual selection (or the whole buffer in normal mode) to a
-- PNG with the `freeze` CLI (charmbracelet/freeze, nixpkgs: charm-freeze) in the Catppuccin Mocha theme,
-- saves it under $XDG_PICTURES_DIR (default ~/Pictures)/code-shots/ and copies it to the clipboard as an
-- image via wl-copy (Wayland). freeze is optional: without the binary the call warns and does nothing.
-- wl-copy is optional too: without it only the saved path is reported.
-- <leader>sg: uploads the same text as a SECRET GitHub gist (`gh gist create`) and copies the link.
local M = {}

M.max_lines = 300

-- the stable output dir, created on demand
local function out_dir()
  local pictures = vim.env.XDG_PICTURES_DIR
  if not pictures or pictures == "" then
    pictures = vim.fs.joinpath(vim.env.HOME or vim.fn.expand("~"), "Pictures")
  end
  return vim.fs.joinpath(pictures, "code-shots")
end

-- copy the PNG to the clipboard as an image; calls done(copied)
local function copy_png(path, done)
  if vim.fn.executable("wl-copy") ~= 1 then
    return done(false)
  end
  local ok, err = pcall(function()
    local f = assert(io.open(path, "rb"))
    local data = f:read("*a")
    f:close()
    vim.system({ "wl-copy", "--type", "image/png" }, { stdin = data }, function(res)
      vim.schedule(function()
        done(res.code == 0)
      end)
    end)
  end)
  if not ok then
    vim.notify("codeshot: could not copy to clipboard: " .. tostring(err), vim.log.levels.WARN)
    done(false)
  end
end

--- Render lines of the current buffer; line1/line2 are 1-based inclusive, nil = whole buffer.
--- @param line1 integer?
--- @param line2 integer?
function M.shoot(line1, line2)
  if vim.fn.executable("freeze") ~= 1 then
    vim.notify("codeshot: `freeze` is not installed (nixpkgs: charm-freeze)", vim.log.levels.ERROR)
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, (line1 or 1) - 1, line2 or -1, false)
  if #lines == 0 or (#lines == 1 and lines[1] == "") then
    vim.notify("codeshot: nothing to render", vim.log.levels.WARN)
    return
  end
  -- the image grows ~70px per line: ~400 lines is 27000px / 21MB, and far more makes freeze's PNG
  -- rasterizer panic ("capacity overflow") or crawl, so refuse early with a hint instead
  if #lines > M.max_lines then
    vim.notify(
      ("codeshot: %d lines is too many for one image (max %d); select a smaller range with V"):format(
        #lines,
        M.max_lines
      ),
      vim.log.levels.WARN
    )
    return
  end

  local dir = out_dir()
  if vim.fn.mkdir(dir, "p") == 0 and vim.fn.isdirectory(dir) == 0 then
    vim.notify("codeshot: cannot create " .. dir, vim.log.levels.ERROR)
    return
  end
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t:r")
  name = (name ~= "" and name or "scratch"):gsub("[^%w._-]", "_")
  local png = vim.fs.joinpath(dir, ("%s-%s.png"):format(name, os.date("%Y%m%d-%H%M%S")))

  local cmd = {
    "freeze",
    "--theme",
    "catppuccin-mocha",
    "--window",
    "--show-line-numbers",
    "--padding",
    "20,40",
    "--margin",
    "20",
    "--shadow.blur",
    "20",
    "--shadow.y",
    "10",
    "--output",
    png,
  }
  -- filetype names are close to freeze's (chroma) language names; without it freeze guesses
  local ft = vim.bo[buf].filetype
  if ft ~= "" then
    vim.list_extend(cmd, { "--language", ft })
  end
  -- text goes in via stdin, so the gutter numbers start at 1
  vim.system(cmd, { stdin = table.concat(lines, "\n") .. "\n", text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        vim.notify("codeshot: freeze failed: " .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
        return
      end
      copy_png(png, function(copied)
        if copied then
          vim.notify("codeshot: saved " .. png .. " (copied to clipboard)")
        else
          vim.notify("codeshot: saved " .. png .. " (not copied: wl-copy missing or failed)", vim.log.levels.WARN)
        end
      end)
    end)
  end)
end

--- Upload lines of the current buffer as a secret gist and copy its link; arguments as in M.shoot.
--- Secret means unlisted, not private: anyone with the link can read it.
--- @param line1 integer?
--- @param line2 integer?
function M.gist(line1, line2)
  if vim.fn.executable("gh") ~= 1 then
    vim.notify("codeshot: `gh` is not installed (nixpkgs: gh)", vim.log.levels.ERROR)
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, (line1 or 1) - 1, line2 or -1, false)
  if #lines == 0 or (#lines == 1 and lines[1] == "") then
    vim.notify("codeshot: nothing to upload", vim.log.levels.WARN)
    return
  end
  -- keep the extension so GitHub highlights it; stdin has no name of its own
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
  name = (name ~= "" and name or "snippet.txt"):gsub("[^%w._-]", "_")
  vim.notify("codeshot: uploading " .. #lines .. " lines as a secret gist...")
  vim.system(
    { "gh", "gist", "create", "--filename", name },
    { stdin = table.concat(lines, "\n") .. "\n", text = true },
    function(res)
      vim.schedule(function()
        local url = vim.trim(res.stdout or ""):match("https://%S+$")
        if res.code ~= 0 or not url then
          vim.notify("codeshot: gist failed: " .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
          return
        end
        vim.fn.setreg("+", url)
        vim.notify("codeshot: secret gist " .. url .. " (link copied)")
      end)
    end
  )
end

vim.keymap.set("n", "<leader>ss", function()
  M.shoot()
end, { desc = "Codeshot: screenshot buffer to PNG" })

vim.keymap.set("x", "<leader>ss", function()
  -- leave visual mode first so the '< and '> marks are set, then read them
  vim.cmd("normal! \27")
  M.shoot(vim.fn.line("'<"), vim.fn.line("'>"))
end, { desc = "Codeshot: screenshot selection to PNG" })

vim.keymap.set("n", "<leader>sg", function()
  M.gist()
end, { desc = "Codeshot: upload buffer as secret gist, copy link" })

vim.keymap.set("x", "<leader>sg", function()
  vim.cmd("normal! \27")
  M.gist(vim.fn.line("'<"), vim.fn.line("'>"))
end, { desc = "Codeshot: upload selection as secret gist, copy link" })

return M
