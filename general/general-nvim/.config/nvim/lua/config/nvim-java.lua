-- nvim-java setup. Called by the lazy.nvim spec's config() (first .java file) and again by
-- :DevEnv java (lua/devenv.lua) once the Java devShell environment is in vim.env: a first run
-- without `java` leaves jdtls and spring-boot-tools disabled, so the later run enables them.
local M = {}

function M.setup()
  local is_nix_managed = vim.uv.fs_stat("/etc/nixos") or vim.uv.fs_stat("/etc/nix")
  -- java (JDK) only exists inside the Java devShell (or after :DevEnv java): without it, stay silent
  -- (no spring-boot LS spawn, no jdtls start -> no ENOENT 'java' warnings on .java files)
  local has_java = vim.fn.executable("java") == 1

  require("java").setup({
    -- nix: never download a JDK (no nix-ld); the devShell provides JAVA_HOME (jdk25) and java on PATH
    jdk = { auto_install = not is_nix_managed },
    java_test = { enable = true },
    java_debug_adapter = { enable = true },
    spring_boot_tools = { enable = has_java },
    -- jdtls.path intentionally unset: nvim-java uses its own jdtls 1.54.0 from
    -- ~/.local/share/nvim/nvim-java/packages (the devShell's `jdtls` is a bin/ wrapper, not a jdtls root)
  })

  -- jdtls settings go through vim.lsp.config (NOT java.setup{jdtls.settings}).
  -- Only scalar/dict values here: lists would REPLACE nvim-java's values (e.g. init_options.bundles).
  vim.lsp.config("jdtls", {
    settings = {
      java = { home = vim.env.JAVA_HOME },
    },
  })
  if has_java then
    vim.lsp.enable("jdtls")
  end
  return has_java
end

return M
