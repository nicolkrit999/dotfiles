<!-- chapter: Java -->
[Back to the guide index](../README.md)

# 78. Java (nvim-java, jdtls, tests, debugging)

This section is one complete walk through everything that is specific to Java in this config: the tools, why each one is there, how it works, how to use it, and what to do when it does not work. It covers only Java-only things (nvim-java and its parts, the language servers, the test runner, the debugger, the Java keys, commands and snippets). Global tools with global keys (`gd`, `K`, `<Space>rn`, git, fzf, ...) get only a pointer to their own section. Sections [35](../07-code.md#35-java-development-nvim-java) and [54](../07-code.md#54-java-development-in-depth) hold the short key lists and section [56](../07-code.md#56-debugging-in-depth) the debugging basics; this section puts everything in one order.

Unless marked otherwise, everything below was tried with real keys in a Maven test project (JDK 25 devShell, `Main`, `Calc`, `CalcTest`).

## 1. What you get and why

| Part | Why it is in the setup | What it does | Where it comes from |
| --- | --- | --- | --- |
| **nvim-java** | One plugin that wires all the Java pieces together | Starts jdtls, finds the debugger and test extensions, adds the `:Java*` commands | lazy plugin `nvim-java/nvim-java`, loaded on `ft = "java"` |
| **jdtls** | Java has no useful editing without a real compiler front end | Completion, diagnostics (compile errors while you type), go to definition, rename, code actions, formatting, refactoring | nvim-java's own jdtls 1.54.0, in `~/.local/share/nvim/nvim-java/packages/jdtls` |
| **spring-boot** | Understands Spring annotations and `application.properties` | A second language server that attaches next to jdtls | nvim-java, only started when `java` is on PATH |
| **java-debug** (DAP adapter) | Without it the debugger cannot talk to the JVM | Lets nvim-dap debug Java | VS Code extension `vscjava.vscode-java-debug`, linked by the devShell |
| **java-test** | Runs JUnit tests and reports per-test results | `<Space>jt...` keys | VS Code extension `vscjava.vscode-java-test`, linked by the devShell |
| **nvim-dap** | The general debugger client (breakpoints, stepping) | `:Dap*` commands | plugin `mfussenegger/nvim-dap`, a dependency of nvim-java |
| **Lombok** | Many Java projects use it; jdtls must load it as an agent | Annotations like `@Getter` compile | `lombok` package of nvim-java, and `JAVA_TOOL_OPTIONS` of the devShell |
| **typos_lsp** | Spell checker for code (global tool, not Java-only) | Underlines misspelled words in identifiers and comments, also in Java | `typos-lsp` from the Nix system |
| **Snippets** | Typing the same loops and switches over and over | See [part 9](#9-snippets) below | `my_snippets/java.snippets` |

Tools you get only through the devShell: the JDK (25), `mvn`, `gradle`, `lombok`, `jdtls` wrapper, and the two VS Code extensions. The Neovim config itself never installs them.

### How nvim-java is loaded

The real spec (`lua/plugin_specs.lua`):

```lua
{
  "nvim-java/nvim-java",
  ft = "java",
  dependencies = { "MunifTanjim/nui.nvim", "mfussenegger/nvim-dap" },
  config = function()
    local is_nix_managed = vim.uv.fs_stat("/etc/nixos") or vim.uv.fs_stat("/etc/nix")
    local has_java = vim.fn.executable("java") == 1
    require("java").setup({
      jdk = { auto_install = not is_nix_managed },
      java_test = { enable = true },
      java_debug_adapter = { enable = true },
      spring_boot_tools = { enable = has_java },
    })
    vim.lsp.config("jdtls", { settings = { java = { home = vim.env.JAVA_HOME } } })
    if has_java then vim.lsp.enable("jdtls") end
  end,
}
```

In plain words:

- `ft = "java"`: nvim-java loads when you open the first Java file of the session, not at startup. Non-Java sessions pay nothing. The very first Java file of a session opens a little slower.
- On a Nix system `jdk.auto_install` is false: nvim-java never downloads a JDK. The JDK comes from the devShell (`JAVA_HOME`).
- jdtls and spring-boot start only if `java` is on PATH. That is how the config stays silent outside the devShell.
- `java.home = $JAVA_HOME` tells jdtls which JDK to compile with.
- jdtls itself is NOT taken from the devShell (the devShell `jdtls` is only a wrapper script); nvim-java uses its own jdtls 1.54.0.

### spring-boot (Spring Boot tools)

Plugin: **spring-boot.nvim**. It has no spec of its own in the plugin file: nvim-java declares it as a dependency, and nvim-java's setup uses it to start the Spring Boot language server. It has no keys and no commands in this config.

| Item | What it is |
| --- | --- |
| What it starts | A second language server (the Spring Boot tools of VS Code, installed by nvim-java as its `spring-boot-tools` package, default version 1.55.1) that attaches next to jdtls. nvim-java passes the server path to the plugin's setup and registers the client commands the server needs |
| When it starts | Only when `java` is on PATH: the config sets `spring_boot_tools = { enable = has_java }`, so in practice only inside the Java devShell |
| What it offers | Per the plugin's README (not tried here): finding Spring beans and web endpoints through workspace symbols, completion and navigation in `application.properties` and `application.yml`, snippet completion and code actions |
| Where you see it | The statusline shows `jdtls (+2)` and the attached clients are `jdtls,spring-boot,typos_lsp` (see "[2. Quick Start](#2-quick-start)") |
| Caveat | It attaches in every Java buffer, even in a project without Spring; that is harmless (see [section 5](#5-language-server-features-in-a-java-buffer)) |

### The Java devShell (`use_dev_env java`)

A Java project has a `.envrc` with one line:

```
use_dev_env java
```

direnv loads the devShell when you `cd` into the folder. The devShell (template `dev-environments/language-specific/java/flake.nix`) gives you `JAVA_HOME` (JDK 25), `mvn`, `gradle`, Lombok (`JAVA_TOOL_OPTIONS` has a `-javaagent:` for it) and, in its shell hook, links the extensions for Neovim:

```
~/.local/share/nvim/nvim-java/packages/java-debug-adapter/extension -> vscode-java-debug
~/.local/share/nvim/nvim-java/packages/java-test/extension          -> vscode-java-test
./.direnv/tools/jdtls                                               -> jdt-language-server
```

`.direnv/` is ignored by git, so nothing shows up in `git status`. First time in a new folder: `direnv allow`.

**Entering the devShell from a running Neovim (`:DevEnv java`).** If Neovim is already open without the devShell (for example a `.java` file opened from outside the project), run `:DevEnv java` instead of quitting:

1. `:DevEnv java`  then `<CR>`. The first call takes about 10 seconds and shows `DevEnv: evaluating the java devShell (about 10 s) ...`; later calls are instant (cached per flake).
2. A notification `DevEnv: java ready: ...` lists what started (`java`, `nvim-java (jdtls, spring-boot-tools)`, language servers). jdtls attaches to the `.java` buffers that are already open.

It applies only `PATH`, `JAVA_HOME`, `CLASSPATH`, `JAVA_TOOL_OPTIONS` (Lombok) and a few other allowlisted variables, then starts nvim-java. The devShell's shell hook does not run, so the extension links above are not created: jdtls works anyway (nvim-java uses its own copies), but you get a warning when the java-debug or java-test extension is missing from `~/.local/share/nvim/nvim-java/packages`; debugging and tests may then be unavailable until nvim-java installs them or direnv enters the devShell once. Opening a `.java` file without `java` also shows a one-time hint, `java not found on PATH: run :DevEnv java to enter its devShell`. All devShell names and the full description: [section 43](../07-code.md#43-how-the-development-toolchain-fits-together).

The other option is unchanged: quit, `cd` into the project and start `nvim` from there with direnv.

### Outside the devShell

`java` is not on PATH, so jdtls and spring-boot do not start. `.java` files still open with syntax highlighting, snippets and typos_lsp, but without Java language features. Every `<Space>j...` key shows ONE warning, `Java: jdtls not attached (open nvim inside the Java devShell, or run :DevEnv java)`. These global keys are fallbacks: without them `<Space>jrr` would fall through to plain Vim keys (`<Space>`, `j`, `rr`). The universal run key `<Space>rr` ([section 19](../07-code.md#19-code-running)) then runs plain `java <file>` if `java` exists, otherwise gives one warning.

## 2. Quick start

1. In a terminal: `cd` into the project folder (the one with `pom.xml`). direnv loads the devShell and prints `Java Environment Active (JDK 25)`. First time: `direnv allow`.
2. `nvim src/main/java/demo/Main.java`
3. Wait for `jdtls (+2)` in the statusline (jdtls, spring-boot, typos_lsp). All three attach: `jdtls,spring-boot,typos_lsp`. Start times in fresh scratch copies were about 20 to 50 seconds (a cold first start); the owner reports that in his everyday session jdtls starts fast, and that the slow part is a project-wide rename (`<Space>rn`, see [When a rename does nothing](#when-a-rename-does-nothing)). A big project's first start is slower. Before that, keys such as `<Space>jtm` or `:DapContinue` show a warning or do nothing.
4. Run: `<Space>jrr`. A full-width, 15-line terminal split opens at the bottom with the program output. If the project has more than one class with a `main` method, a picker opens first (see [The runner window](#the-runner-window)).
5. Test: open `CalcTest.java` and press `<Space>jtc`, then `<Space>jtr` for the result tree.
6. Debug: `<Space>jp` on a line with code, then `<Space>jtC`. The window stops at the line with a `→` sign. Step by step: [section 7](#7-debugging).

## 3. Project layout rules

### The root folder

jdtls needs one root folder per project. nvim-java decides it with these markers (`lua/java-core/ls/servers/jdtls/root.lua`), two groups, the first group that matches wins:

| Group | Markers | Meaning |
| --- | --- | --- |
| 1 | `mvnw`, `gradlew`, `settings.gradle`, `settings.gradle.kts`, `.git` | multi-module projects; the git root is the last resort on purpose |
| 2 | `build.xml`, `pom.xml`, `build.gradle`, `build.gradle.kts` | single-module projects |

Consequences:

- The git root wins over a `pom.xml` below it, by design: in a multi-module Maven project you cannot tell the parent from a submodule, and jdtls does not break when the root is higher than the real parent `pom.xml`.
- A Maven project nested in a bigger git repository (`repo/java/pom.xml`) still works: the root is the git root and jdtls finds the `pom.xml` below it. `<Space>jrr` works in this layout (in the user's real layout).
- No git folder: the folder with `pom.xml` is the root. A loose `.java` file with neither: jdtls has no project (create a `pom.xml` or run `git init`).
- Maven and Gradle projects are both imported by jdtls.
- Expected layout: code in `src/main/java/...`, tests in `src/test/java/...`.

### First start and where files appear

- The first start of a project is slower: jdtls imports the project, runs Maven or Gradle and builds an index. The statusline and notifications show progress.
- Compiled classes go to `target/` (Maven) next to `pom.xml`. jdtls also writes Eclipse files into the project (`.project`, `.classpath`, `.settings/`). In the test project `.gitignore` contains only `target/` and `.direnv/`, so `.project`, `.classpath` and `.settings/` show up in `git status`; add them to the project's `.gitignore` if you do not want them in git.
- jdtls workspace data goes to `~/.cache/nvim/jdtls/` (`config_<hash>` and `workspace/proj_<hash>`), never into the project. The workspace folder name is a hash of the folder where Neovim was STARTED (`vim.fn.getcwd()` at startup), not of the jdtls root. Always start Neovim from the same project folder, otherwise jdtls builds a second workspace.
- Saving: the auto-save plugin saves a buffer when you leave it or when Neovim loses focus. Refactor results and edits are therefore written to disk without `:w` once you switch windows (a refactor was saved this way). Auto-saves do not format; saving with `:w` does (see `<Space>fm` below).

## 4. Keys and commands

All `<Space>j` keys are normal mode only. The real maps are created per buffer when jdtls attaches and removed when it detaches (`LspAttach` / `LspDetach` in `lua/mappings.lua`); before that, the global fallback shows the warning. Exception: the four debug keys `<Space>jh`, `<Space>jp`, `<Space>jP` and `<Space>jx` (see below) are plain global maps without that warning. which-key shows the groups `j` Java, `jb` build, `jr` runner, `jt` test, `je` extract.

### Build (`<Space>jb`)

| Key | Command | What it does | Mode |
| --- | --- | --- | --- |
| `<Space>jbb` | `:JavaBuildBuildWorkspace` | Compile the whole workspace; a "Background task" notification shows while it runs | n |
| `<Space>jbc` | `:JavaBuildCleanWorkspace` | Delete the jdtls workspace cache of the project after a Yes/No question, then restart jdtls (see below) | n |

### Runner (`<Space>jr`)

| Key | Command | What it does | Mode |
| --- | --- | --- | --- |
| `<Space>jrr` | `:JavaRunnerRunMain` | Run the main class | n |
| `<Space>jrs` | `:JavaRunnerStopMain` | Stop the running program (the java process is gone and the runner shows `Process finished with exit code::129`); with nothing running it does nothing visible | n |
| `<Space>jrl` | `:JavaRunnerToggleLogs` | Show or hide the runner log window (toggles between 1 and 2 windows) | n |
| `<Space>jrp` | `:JavaProfile` | Run profiles window (main class and arguments), see below | n |

### Test (`<Space>jt`)

| Key | Command | What it does | Mode |
| --- | --- | --- | --- |
| `<Space>jtc` | `:JavaTestRunCurrentClass` | Run all tests of the class in the buffer | n |
| `<Space>jtm` | `:JavaTestRunCurrentMethod` | Run only the test method under the cursor | n |
| `<Space>jtr` | `:JavaTestViewLastReport` | Show the result tree of the last run | n |
| `<Space>jtC` | `:JavaTestDebugCurrentClass` | Debug the class (breakpoints stop) | n |
| `<Space>jtM` | `:JavaTestDebugCurrentMethod` | Debug the test method under the cursor | n |

### Refactor / extract (`<Space>je`)

| Key | Command | What it does | Mode |
| --- | --- | --- | --- |
| `<Space>jev` | `:JavaRefactorExtractVariable` | Extract the expression to a local variable | n |
| `<Space>jeo` | `:JavaRefactorExtractVariableAllOccurrence` | Same, and replace ALL occurrences | n |
| `<Space>jec` | `:JavaRefactorExtractConstant` | Extract a constant | n |
| `<Space>jem` | `:JavaRefactorExtractMethod` | Extract a method (a whole statement needs a selection FIRST, see [section 8](#8-refactoring-extract)) | n |
| `<Space>jef` | `:JavaRefactorExtractField` | Extract a field | n |

`<Space>jev`, `<Space>jeo` and `<Space>jec` need no selection (cursor on the expression is enough). To extract a whole statement or several lines with `<Space>jem`, select the code first, press `<Esc>`, then `<Space>jem` (details in [section 8](#8-refactoring-extract)).

### Debug (`<Space>jh`, `<Space>jp`, `<Space>jP`, `<Space>jx`)

Global maps (not buffer-local), so they work in any buffer, also when jdtls is not attached (where the other `<Space>j` keys only show the warning); they load nvim-dap on demand. In a scratch copy of the config: breakpoint sign, debugger paused, value float, session ended; all four keys `<Space>jh`, `<Space>jp`, `<Space>jP` and `<Space>jx` work in the owner's session. Stepping and continuing have no keys on purpose: use the typed commands in [section 7](#7-debugging).

| Key | Same as | What it does | Mode |
| --- | --- | --- | --- |
| `<Space>jp` | `:DapToggleBreakpoint` | Breakpoint on or off on the cursor line (`B` sign). which-key text: `Java debug: toggle breakpoint` | n |
| `<Space>jP` | `:DapClearBreakpoints` | Remove ALL breakpoints in ALL files at once; no undo (set them again with `<Space>jp`). Capital P on purpose: the mirror of `<Space>jp` (one breakpoint), kept apart because it is destructive. Key run headless in a scratch copy (3 breakpoints in 3 files, the list was empty afterwards), as was the command `:DapClearBreakpoints`. which-key text: `Java debug: clear all breakpoints` | n |
| `<Space>jh` | `:lua require("dap.ui.widgets").hover()` | While the debugger is paused: show the value of the variable under the cursor in a float. which-key text: `Java debug: show value under cursor (paused)` | n |
| `<Space>jx` | `:DapTerminate` | End the debug session: the program is stopped. The breakpoints stay where they are (assumption, not tested here: that is how nvim-dap works). which-key text: `Java debug: terminate session` | n |

Note: a Neovim that was already running when these keys were added (`<Space>jP` included) does not have them, because mappings are read at startup. Restart it with `<Space>sv` (writes all buffers and runs `:restart`; terminal buffers such as the Claude panel are not relaunched, see the `<Space>sv` entry in [section 40](../10-various.md#40-configuration-management)).

### Settings and debugger setup

| Key | Command | What it does | Mode |
| --- | --- | --- | --- |
| `<Space>jd` | `:JavaDapConfig` | Configure the debug adapter again (it is done automatically when jdtls starts) | n |
| `<Space>jj` | `:JavaSettingsChangeRuntime` | Pick another JDK runtime for jdtls; only works if runtimes are configured, see below | n |

### The `:Java*` commands

With `:command Java` after jdtls attached:

- Existing at that point: `JavaBuildBuildWorkspace`, `JavaBuildCleanWorkspace`, `JavaRefactorExtract...` (five), `JavaRunnerRunMain`, `JavaRunnerStopMain`, `JavaRunnerToggleLogs`, `JavaRunnerSwitchLogs`, `JavaTestRunCurrentClass`, `JavaTestRunCurrentMethod`, `JavaTestRunAllTests`, `JavaTestDebugCurrentClass`, `JavaTestDebugCurrentMethod`, `JavaTestDebugAllTests`, `JavaTestViewLastReport`, `JavaDapConfig`, `JavaProfile`, `JavaSettingsChangeRuntime`.
- Three have no key: `:JavaRunnerSwitchLogs`, `:JavaTestRunAllTests` (all tests of the project) and `:JavaTestDebugAllTests`.
- Only `:JavaBuild*` and `:JavaRefactor*` appear after jdtls attached; the other `:Java*` commands exist as soon as nvim-java is loaded but do nothing useful without jdtls.
- `:JavaRefactor...` commands accept a range, so `:'<,'>JavaRefactorExtractMethod` is valid.

### The runner window

`<Space>jrr` opens the runner as a full-width terminal split at the bottom (14 text rows plus the status line, 200 columns wide at 200 columns). It prints the real command, then the program output, then the exit code. Output for `Main`:

```
/nix/store/...-openjdk-25.0.2+10/lib/openjdk/bin/java -cp .../target/classes demo.Main Picked up JAVA_TOOL_OPTIONS: -javaagent:.../lombok.jar
result: 20
Process finished with exit code::0
```

(The `Picked up JAVA_TOOL_OPTIONS` line comes from the devShell's Lombok setting; it is harmless.) `<Space>jrl` hides and shows this window again. To go back to the code: `<Esc>`, then `<Ctrl-w>k` or `<Up>`.

Several classes with a `main` method: `<Space>jrr` first opens a picker titled `Select the main class (module -> mainClass)`, with one line per class, for example `1. <project> -> pkg.Main` and `2. <project> -> pkg.Other`. `<C-n>` / `<C-p>` move, `<Enter>` on the wanted line runs that class. The output then appears in the bottom terminal split and ends with `Process finished with exit code::0`. Seen in a practice project with two main classes.

Known quirk (an nvim-java bug): once the program has finished, typing a key in this terminal buffer gives `E900: Invalid channel id`. Press `<Esc>` (or `<Ctrl-\><Ctrl-n>`) first to leave terminal mode, then close the window with `:q` or `<Ctrl-w>c`.

### Profiles window (`<Space>jrp`)

A profile stores VM arguments and program arguments for the runner of one main class. Flow:

1. `<Space>jrp` opens a window `Profiles` with the entry `New Profile` and the hint `[a]ctivate [d]elete [b]ack [q]uit`.
2. `<Enter>` on `New Profile` opens a form with three boxes: `Name`, `VM arguments`, `Program arguments`, and the hint `[s]ave [b]ack [q]uit`.
3. In the form (normal mode): `i` types in the box, `<Esc>` leaves it, `<Tab>` or `j` goes to the next box, `k` to the previous one, `s` saves.
4. Saved example: name `prof1`, program arguments `hello`. The profile is stored in `~/.local/share/nvim/nvim-java-profiles.json`, keyed by project folder and main class, and marked active:

```json
{"/path/to/project": {"nvim-java-test -> demo.Main": [{"name": "prof1", "is_active": true, "prog_args": "hello", "vm_args": ""}]}}
```

5. The next `<Space>jrr` uses it. The runner printed `... demo.Main hello`.
6. To switch or remove profiles: `<Space>jrp`, choose the profile, `a` activates it, `d` deletes it, `q` closes.

### Clean workspace (`<Space>jbc`)

1. `<Space>jbc` opens a Yes/No list with the question `Do you want to delete ".../.cache/nvim/jdtls/workspace/proj_<hash>"`.
2. `<Enter>` on `1. Yes` deletes that folder and restarts jdtls (the folder was recreated fresh a moment later with a new timestamp, jdtls came back). `No` does nothing.
3. Your source files and `target/` are not touched.
4. The folder named in the question is computed from jdtls's root folder, while jdtls really uses a folder named from the folder where Neovim was started. They are the same when you start Neovim in the project root (the case of a project that is its own git root). If your git root is above the folder where you start Neovim, the question may name a folder that does not exist; then delete the real one by hand: `rm -r ~/.cache/nvim/jdtls/workspace` (from the nvim-java source, not tested in a nested layout).

### Change runtime (`<Space>jj`)

In the test project it only shows a notification: `No configured runtimes available` plus a link to the nvim-java README. The list of JDKs comes from jdtls setting `java.configuration.runtimes`, which this config does not set (only `java.home = $JAVA_HOME`). So `<Space>jj` is a no-op here; the JDK in use is the devShell JDK.

## 5. Language server features in a Java buffer

All need jdtls attached. The general keys are described elsewhere ([section 13](../07-code.md#13-lsp-language-server-protocol) for LSP); here is what they do in Java.

| Key / command | What it does in Java |
| --- | --- |
| `gd` | Go to definition; several results open the location list. Opens the target file as a NEW buffer (the previous file stays open in the tab line); `<C-o>` jumps back to the call site, `<C-i>` forward again (default Neovim) |
| `K` | Hover: type and Javadoc. A hover float shows a "java" progress bar for a few seconds while loading; `<Esc>` closes it |
| `<Space>rn` | Rename a class, method or variable in all files. In a scratch copy (steps still to be confirmed): the `New Name` box opens already filled with the old name (delete it with `<BS>` and type the new one; the text behind the box does NOT change while you type); after `<Enter>` the rename appears only after a delay: in the tests the answer took about 10 to 17 s (small project, jdtls started a minute earlier; can be longer), so wait before pressing anything else. If nothing has changed after about a minute, see [When a rename does nothing](#when-a-rename-does-nothing). It applies to ALL files that use the name, the other files are changed only in memory (hidden buffers, `:ls` shows them with `+`) until `:wa` (press `<Enter>` first if a "Press ENTER" prompt is showing); text in comments is not changed. A second `<Space>rn` while the first one is still pending starts from the NEW name (a mistaken second run gave `additaddition`) |
| `<Space>ca` | Code actions: quick fix, organize imports, generate getters, constructors, `toString`; also the way to extract with a selection (see [Refactoring](#8-refactoring-extract)). Which generate entries work and how: see [Generate getters, setters and constructors](#generate-getters-setters-and-constructors) below |
| `<Space>fm` | Format the file (Visual mode: the selection) with google-java-format, run by conform.nvim (see [Formatting (conform.nvim)](../07-code.md#formatting-conformnvim)); the jdtls formatter (Eclipse style) is used only when google-java-format is not installed. Example: `calc.add(2,3)*4` becomes `calc.add(2, 3) * 4`. Saving with `:w` formats too; auto-saves do not, and `<Space>fo` switches format on save off and on. It runs asynchronously: wait a moment. It can re-indent the whole file (the template's 4 spaces became 2) and wrap long lines (`int   x=1+2 ;` became `int x = 1 + 2;`) |
| `:LspInlayHints enable` / `disable` | Inlay hints (parameter names, types); off by default (enable turns hints on) |
| `<Space>t` | Symbol outline (aerial); in Java it shows `Main` and `main` |
| diagnostics | Compile errors and warnings appear while you type, without running anything |

Other notes:

- **illuminate**: other uses of the word under the cursor are highlighted (Java is in its filetype list).
- **typos_lsp**: attaches to Java buffers too (root markers include `.gitignore`), also outside the devShell. If `<Space>rn` or `<Space>ca` only warn "no attached language server supports it", only typos_lsp is attached and jdtls is missing.
- **Completion** and **snippets** work as in other languages (sections [14](../04-completion-snippets.md#14-autocompletion-nvim-cmp) and [15](../04-completion-snippets.md#15-snippets-ultisnips)).
- The coloured line marker (`colorcolumn`) is at 100 for Java.
- spring-boot attaches next to jdtls in every Java buffer, even in a project without Spring; it is harmless.

### Go to definition, back, hover, references

Example: the cursor is on `add` in `calc.add(10, 3)`.

1. `gd`  Opens the file with the definition (`public int add(...)`) as a new buffer; the previous file stays open in the tab line at the top.
2. `<C-o>`  Jumps back to the call site (`<C-i>` goes forward again; default Neovim).
3. `K`  Hover popup with the signature, for example `int pkg.Calc.add(int a, int b)`. It may show a `java` loading bar for a few seconds first. `<Esc>` closes it.
4. `<Space>gr`  Opens Glance ([Peeking without jumping](../07-code.md#peeking-without-jumping-glancenvim)) with a panel `References (N)` listing every use, including the definition itself (in the practice project: 4 files); the preview is on the left. `<C-n>` / `<C-p>` move, `<Esc>` closes.

### When a rename does nothing

Applies to `<Space>rn` and, in the same way, to other project-wide jdtls actions (find references, extract, ...). Symptom: the `New Name` box works, you press `<Enter>`, and nothing changes and no message appears (jdtls fails on the server side and Neovim does not show the error). Seen in scratch copies on 2026-10-05. This is the most likely cause found so far, NOT the only one: other causes exist, and case-specific debugging may still be needed.

1. Wait first. Even when everything works the request took about 10 to 17 s in the tests, and the text does not change while you type; the buffers change only after the answer arrives. Up to about 20 s of nothing can be normal.
2. `:LspAttached`  Check that `jdtls` is in the list; `:LspInfo` (`:checkhealth vim.lsp`) shows the clients and the root folder. Without jdtls, see "jdtls never attaches" in [Troubleshooting](#11-troubleshooting).
3. After about a minute with no change, look at the jdtls log of the project workspace (an Eclipse-style log, one per workspace). In a shell: `ls -t ~/.cache/nvim/jdtls/workspace/*/.metadata/.log | head -3`. The newest one is normally the project you work in; the confirmation box of `<Space>jbc` also names the workspace folder.
4. Search it, with `<log>` replaced by that path: `grep -n "Problem with rename" <log>`, and `grep -n "^!ENTRY .* 4 0 " <log> | tail` (an entry whose number after the plugin name is 4 is an error). Read the lines after a hit with `sed -n '<line>,+12p' <log>`.
5. What the log showed in that case: `Problem with rename for file:///.../Main.java` with `AssertionFailedException: assertion failed: Search for method declaration did not find original element: int add(int, int)`, preceded by `Error filtering index locations based on qualifier.` and `java.io.FileNotFoundException: .../.metadata/.plugins/org.eclipse.jdt.core/<number>.index (No such file or directory)`. Meaning: the search index files of the workspace were missing or stale, so jdtls could not find where the method is used and the rename failed. Reproduced by deleting two `<number>.index` files of a scratch workspace: the rename request then answered with 0 changed files after about 4 s and wrote the same error.
6. `<Space>jbc`  Fix that worked in the scratch copy ([Clean workspace](#clean-workspace-spacejbc)): choose `1. Yes` with `<Enter>`. jdtls restarts and rebuilds the workspace (progress in the lower right; wait about 1 minute; the `.index` files reappear). Then the same rename returned edits for 4 files. It is a cache clean: save unsaved work first, and the first start afterwards is slower. It is NOT guaranteed to fix every failed rename; if the log shows a different error, that error is the lead.
7. After a successful rename the open buffer has changed and the other files are changed in memory only (hidden buffers, `:ls` shows `+`): save them all with `:wa`.

### Rename: `:grep` + `:cfdo` instead of `<Space>rn`?

Not a drop-in replacement. It takes about a second but is plain text: it also changes comments, strings and unrelated same-named methods (`Calc.add` and `List.add`). Use it only for a unique name and only after reviewing the matches with `:copen`; for common names (`add`, `get`, `size`) stay with `<Space>rn`. Details, table and examples: [LSP rename versus `:grep` + `:cfdo`](../05-search-and-files.md#lsp-rename-versus-grep--cfdo-can-the-fast-text-rename-replace-a-slow-spacern).

### Add a missing import (auto-import)

Example: a file contains `List<String> names = new ArrayList<>();` and no imports.

1. Put the cursor ON the unknown word (`List`). If the cursor is elsewhere, the menu does not offer imports at all.
2. `<Space>ca`  Opens the `Code actions` list (fzf-lua) with entries such as `Import 'List' (com.sun.tools.javac.util)`, `Import 'List' (java.awt)`, `Import 'List' (java.util)`, `Add all missing imports`, `Create class 'List<T>'`, `Change to ...`, `Organize imports`.
3. `Import java.util`  Type this to filter the list, then CHECK that the highlighted line is `Import 'List' (java.util)`.
4. `<Enter>`  `import java.util.List;` is added at the top (imports end up sorted, `ArrayList` before `List`).
5. Repeat for `ArrayList`: cursor on it, `<Space>ca`, filter `Import java.util`, `<Enter>`.

Traps:

- The filter order is not the numbering. After typing only `Import`, the first line was the `java.awt` entry: always read the highlighted line.
- Filtering only `java.util` for `ArrayList` put `Change to 'List' (java.util)` on top, and `<Enter>` REPLACED `ArrayList` with `List`. Undo with `u`. Keep the word `Import` in the filter.
- `Add all missing imports` failed in the test with the notification `Failed to choose imports ... java-refactor/action.lua:288: bad argument #1 to 'ipairs' (table expected, got nil)` (a file where `List` had several candidate packages and another name did not exist at all). Do not rely on it; use the single `Import '<Name>' (<package>)` entries.
- `Organize imports` is in the list; not tried.

### Generate getters, setters and constructors

Example class `Person` with the fields `name` and `age`.

1. Put the cursor on a field line inside the class. The cursor must be inside the class, on a field; elsewhere the menu offers fewer generate actions.
2. `<Space>ca` opens the code-action list (an fzf-lua picker): type to filter, `<C-n>` / `<C-p>` or the arrows move, `Enter` runs the entry, `Esc` cancels.

The list shows every generate action twice, and the numbers are only the order. One group has NO trailing dots (`Extract interface...`, `Generate Getters and Setters`, `Generate Getters`, `Generate Setters`, `Generate Constructors...`, `Generate hashCode() and equals()...`, `Generate toString()...`, `Override/Implement Methods...`, `Organize imports`), the other group has dots on the accessor entries too (`Generate Getters and Setters...`, `Generate Getters...`, `Generate Setters...`, `Generate Constructors...`, ...).

| Entry | Result |
| --- | --- |
| `Generate Getters and Setters`, `Generate Getters`, `Generate Setters` (NO dots) | Writes the methods for ALL fields at once, no questions asked (`getName`, `setName`, `getAge`, `setAge`). To get fewer, delete the extra methods afterwards |
| The same three entries WITH dots | Do NOT work. They show the notification `"java.action.generateAccessorsPrompt" is not supported yet!` and the file stays unchanged (nvim-java does not implement that prompt; see `lua/java-refactor/client-command-handlers.lua` in the nvim-java plugin). Use the entries without dots |
| `Generate Constructors...` | Works, opens a `Select Fields` list (see below) |
| `Generate toString()...`, `Generate hashCode() and equals()...`, `Override/Implement Methods...` | Use the same multi-select as the constructor (per the nvim-java source, `lua/java-refactor/action.lua`). Not tried one by one |

The `Select Fields` list (nvim-java's own multi-select) behaves differently from other pickers:

- `Enter` does NOT finish: it TOGGLES the highlighted field (a `*` appears in front of it) and the list reopens.
- `<C-n>` / `<C-p>` move; `Tab` does nothing here.
- `<Esc>` finishes the selection and writes the constructor. The first `<Esc>` sometimes had to be pressed twice.
- Result with both fields marked: `public Person(String name, int age) { this.name = name; this.age = age; }`; with only `name` marked: `public Person(String name) { this.name = name; }`. The constructor is inserted before the fields.

Indentation: the inserted code uses TAB indentation (jdtls does not format what it inserts), so it looks off next to 4-space code. `<Space>fm` formats the file and re-indents it; saving with `:w` does the same.

## 6. Tests (JUnit)

### Why and how

java-test knows JUnit 4 and 5 and TestNG. nvim-java asks jdtls for the test classes and methods, then starts the tests through the debug adapter machinery. That is why the test terminal is called `[dap-terminal]` and why debugging a test works with the same keys.

### Using it

Example test (`src/test/java/demo/CalcTest.java`):

```java
class CalcTest {
    @Test
    void addWorks() {
        assertEquals(5, new Calc().add(2, 3));
    }

    @Test
    void multiplyWorks() {
        assertEquals(6, new Calc().multiply(2, 3));
    }
}
```

1. `<Space>jtc` anywhere in the class runs both tests; with the cursor inside one method, `<Space>jtm` runs only that one. In tmux, real nvim: `<Space>jtm` with the cursor on the assert line of the second method, then `<Space>jtr`, listed only that method (`multiplyWorks`), not `addWorks`; the whole-class run `<Space>jtc` lists all test methods. The cursor must be inside a method that has a test annotation, see [`cursor is not on a test method`](#cursor-is-not-on-a-test-method).
2. A terminal window named `[dap-terminal] Launch All Java Tests` opens at the bottom (the tab line also shows it). Content: only the start lines (`Picked up JAVA_TOOL_OPTIONS...`) and `[Process exited 0]`. The terminal does NOT print pass or fail text. For `<Space>jtm` as well: the terminal shows only the `Picked up JAVA_TOOL_OPTIONS: -javaagent:.../lombok.jar` line and `[Process exited 0]`.
3. The results are in the report: to see it press `<Space>jtr`; it opens a floating window with a tree. (In a tmux test of ours, after `<Space>jtc` only the terminal was visible and no report popup appeared by itself. The user saw the report with a check mark after a `<Space>jtc` class run.) All passing:

```
 demo.CalcTest
   addWorks(demo.CalcTest)
   multiplyWorks(demo.CalcTest)
```

Each line has a status icon in front (a different icon for pass and fail). With a wrong expected value (`assertEquals(7, ...)`): the failing method gets the failure message and stack below it:

```
   multiplyWorks(demo.CalcTest)
     org.opentest4j.AssertionFailedError: expected: <7> but was: <6>
     at org.junit.jupiter.api.Assertions.assertEquals(Assertions.java:531)
     at demo.CalcTest.multiplyWorks(CalcTest.java:15)
```

4. Close the report with `<Esc>` or `q`. `<Space>jtr` again after a new run shows the new result. The exit code in the terminal is 0 even when tests fail; trust the report.

To debug a test (stop at a breakpoint instead of just running it) see [section 7](#7-debugging), "Learning exercise: debug a test".

### `cursor is not on a test method`

`<Space>jtm` can warn `cursor is not on a test method`. The message comes from nvim-java (`java-test/api.lua`): `execute_current_test_method` warns when no test method is found at the cursor; the methods come from jdtls/java-test for the current file. Causes, most likely first:

1. The method has no `@Test` above it (the neighbouring method had one). Add `@Test` (or `@ParameterizedTest` etc.) above the method; after that `<Space>jtm` ran it.
2. From the source code (not tested separately): the cursor is outside a method, for example on the class line or between methods. Put the cursor on a line inside the method.
3. Assumption, not tested: jdtls has not re-read the file after your edit. Wait a few seconds and press `<Space>jtm` again.
4. Assumption, not tested: a syntax error in the file (an extra or missing `}`, for example after typing a block by hand), so the method is not recognized. Fix the braces.

### The test terminal window does not come back after you close it

Scratch copy, tmux, real nvim, 2026-10-05: the first `<Space>jtm` or `<Space>jtc` opens the window `[dap-terminal] Launch All Java Tests` at the bottom; for a tiny test the line `[Process exited 0]` appeared within about 2 seconds. After you close that window (`:q`, `<Space>q`, or any accidental unsplit), further runs do NOT open a new window. Only the notice `INFO::"run current test method"` (or the class variant) appears. `:ls` then still lists the buffer `[dap-terminal] Launch All Java Tests` with the flags `hF` (`h` = hidden). The notice only means the run was STARTED, not that it finished.

Why (read from the source code on 2026-10-05, not tested separately): nvim-java does not create the test terminal. Its runner (`lua/java-dap/runner.lua`, `Runner:run_by_config`) only calls `require('dap').run(config, ...)`, and nvim-dap (`lua/dap/session.lua`, `terminals.acquire`) creates the terminal. nvim-dap first reuses a terminal buffer from a pool of buffers of finished sessions (filled by `terminals.release`) and in that case opens NO window. Only when the pool is empty does it create a new buffer AND a window, with the command from its setting `terminal_win_cmd` (default `belowright new`). So the first run opens the window, later runs write into the same buffer, and nothing reopens the window you closed. This is the default behaviour of nvim-dap, not a choice of this config (the config sets neither `terminal_win_cmd` nor `dap.defaults`). On 2026-10-05 there was no difference between the installed nvim-java and a local clone of the latest nvim-java `main` (the `lua/` folders were identical).

User's observation (tested by the user): the program runner window (`<Space>jrr`) DOES come back after `:q` the next time it runs, while the test terminal does not. Read from the source (the window-opening detail itself was not tested by us beyond that observation): nvim-java's own runner (`lua/java-runner/run.lua`) creates a NEW terminal buffer for every run (`nvim_create_buf` plus `nvim_open_term`) and shows it with its own window logic (`runner.lua`, `set_buffer` / `create`), so a window is opened each run. It does not use nvim-dap's terminal pool.

Assumption, not tested: the nvim-dap setting `dap.defaults.fallback.terminal_win_cmd` (a command string such as `belowright new`, or a function returning a buffer and a window) only applies when a NEW terminal buffer is created. Changing it would therefore not make a closed window come back for a reused buffer. Not recommended or configured here; the way to work with it is the steps below.

To see the test terminal again:

1. `:ls`  Look for the line `[dap-terminal] Launch All Java Tests`; `h` means hidden.
2. `:sbuffer dap-terminal`  Shows it in a new horizontal split below. Or `:vert sbuffer dap-terminal` for side by side. The buffer is listed and shows `[Process exited 0]`. Not tellable by us: whether the content shown came from the LATEST run or from an earlier one. Details of `:sbuffer`: [Put two chosen buffers side by side or one above the other](../06-windows-terminal-sessions.md#put-two-chosen-buffers-side-by-side-or-one-above-the-other).
3. `<Ctrl-w>k` / `<Ctrl-w>j`  Back to the code window. You can keep the terminal in a split permanently to watch the exit line of every run.

Reliable signals that a test run has finished:

- The exit line (`[Process exited 0]`) in the terminal buffer.
- `<Space>jtr` (report). Tested: it shows the LAST finished run only (after `<Space>jtm` on one method it listed only that method, after `<Space>jtc` all methods). Assumption, not tested: a report opened too early may still show the previous run, so wait for the exit line first.

The debug runs `<Space>jtC` and `<Space>jtM` also go through `dap.run` (read from the source: `run_by_config` in `api.lua` is used for both; the debug configuration differs only in `debug = true`), so the same terminal reuse is expected. Assumption, not tested.

### Needs

- A JUnit dependency in `pom.xml` (the test project: `junit-jupiter` 5.10.2 and `maven-surefire-plugin` 3.2.5, release 21).
- jdtls attached and the `java-test` extension linked by the devShell (see [section 1](#1-what-you-get-and-why)).
- Network the first time Maven has to download the JUnit jars into `~/.m2`.

## 7. Debugging

### Why and how

nvim-dap is the debugger client; java-debug is the adapter that talks to the JVM; nvim-java registers the Java configurations for you. This config has four debug keys (`<Space>jp` breakpoint, `<Space>jP` clear all breakpoints, `<Space>jh` value under the cursor, `<Space>jx` stop; see section 4) and NO dap-ui panel (no variables or stack window). Everything else is a typed `:Dap*` command: stepping and continuing deliberately have no keys (`:DapContinue`, `:DapStepOver`, `:DapStepInto`, `:DapStepOut`). You work with the sign column and small floating windows. The commands were run end to end; the four keys in a scratch copy of the config:

| Step | How | Result |
| --- | --- | --- |
| Breakpoint on / off | `<Space>jp` (same as `:DapToggleBreakpoint`) on the line (put it on a line with code, e.g. the `assertEquals` line, not on the `void addWorks() {` line) | A `B` sign in the sign column |
| Debug a test class | `<Space>jp`, then `<Space>jtC` | No picker. A notice `debug current test class` appears; after about 15 seconds the window shows a `→` sign on the breakpoint line; the program is paused (in a scratch copy, 2026-10-05) |
| Debug one test method | `<Space>jtM` with the cursor in the method | same, only that method (same start as `<Space>jtC`, 2026-10-05, together with the class key) |
| Debug the program (`main`) | `<Space>jp` in `Main.java`, then `:DapContinue` | A picker "Configuration" opens (5 identical entries `nvim-java-test -> demo.Main`; why there are several: see [The Configuration picker](#the-configuration-picker)); press `<Enter>` on the first: the program stops at the breakpoint with `→` |
| Step over | `:DapStepOver` | `→` moves to the next line; the line you were on has run |
| Step into | `:DapStepInto` | On a call to your own method it opens that file (`calc.add(2, 3)` opens `Calc.java` at `int sum = a + b;`; the file of your own method opens at its first line inside). On a line without a call, or into library code, it opens an empty `unknown` buffer and a DAP warning "Adapter reported frame ... Invalid cursor line" |
| Step out | `:DapStepOut` | Back to the caller file |
| Look at a value | put the cursor on the variable, `<Space>jh` (same as `:lua require("dap.ui.widgets").hover()`); only while paused | A small float with the value (`sum` shows `5` with the command; the key in a scratch copy: a variable showed `13`; `<Space>jh` on a variable after the breakpoint line showed its value, 2026-10-05). `<Esc>` closes it |
| Continue | `:DapContinue` while paused | Runs to the next breakpoint or to the end (the test terminal shows `[Process exited 0]`; for the program, the terminal shows the rest of the output and `[Process exited 0]`) |
| Debug console | `:DapToggleRepl` | A `[dap-repl-N]` window; run again to hide |
| Stop | `<Space>jx` (same as `:DapTerminate`) | The session ends (no session afterwards; a new session starts cleanly after it) |

### Debug workflow

1. `<Space>jp` on a line with code (not a comment and not the method signature line).
2. `:DapContinue`, then in the picker choose an entry that ends with your main class (for example `... -> tutorial.Main`). For tests `<Space>jtC` / `<Space>jtM` start directly, with no picker.
3. While paused (the `→` sign): `:DapStepOver`, `:DapStepInto` or `:DapStepOut` to move; `<Space>jh` with the cursor on a variable shows its value.
4. `:DapContinue` to run on, to the end or to the next breakpoint.
5. `<Space>jx` to stop the session.
6. Optional: `<Space>jP` removes all breakpoints in all files when you are done.

What the stepping commands do (for beginners):

| Command | Meaning |
| --- | --- |
| `:DapStepOver` | Run THIS line and stop on the next one. Method calls on the line run completely; you do not go inside them. |
| `:DapStepInto` | Go INSIDE the method that is called on this line. Works for your own code that has source; into library code you get an empty `unknown` buffer and a DAP warning (see the step table). |
| `:DapStepOut` | Run the rest of the current method and stop back in the caller. |
| `:DapContinue` | Run until the next breakpoint, or to the end of the program. |

Program output appears only when its line has run: the `→` line has NOT run yet, so a `System.out.println(...)` on it prints nothing until you step over it.

### Learning exercise (try it)

Every step matched (2026-10-05). Use a small `main` method that calls `compute(a, b)` on line A, followed by a few lines that print and use the result.

1. `<Space>jp` on line A, then `:DapContinue` and choose the first entry in the picker: the program stops with `→` on line A.
2. `:DapStepOver`: `→` moves to the next line; line A has run, but a print on the next line has not printed yet.
3. `:DapStepOver` again: the output of the print line appears in the debug terminal (only now, when its line has run) and `→` moves on. Put the cursor on a variable assigned earlier and press `<Space>jh`: a float shows its value; `<Esc>` closes it.
4. `:DapContinue`: the program runs to the end; the terminal shows the rest of the output and `[Process exited 0]`.
5. Start again (`<Space>jx` first if a session is still open, then `<Space>jp` on line A and `:DapContinue` plus picker). On line A, `:DapStepInto` opens the file of `compute` at its first line inside; `:DapStepOver` once there; `:DapStepOut` goes back to the caller file.

### Learning exercise: debug a test

The steps below worked in the owner's own session (2026-10-05; "yes it worked"; he did not report exact screen details), and in a scratch copy (tmux, real nvim, jdtls attached). Use the test class from section 6: a test `multiplyWorks` whose line is `assertEquals(6, new Calc().multiply(2, 3));`.

1. `<Space>jp` on the `assertEquals(...)` line of `multiplyWorks`: a `B` sign appears.
2. `<Space>jtC` (debug the whole test class; `<Space>jtM` with the cursor in the method debugs only that method): there is NO picker. A notice `debug current test class` appears.
3. Wait about 15 seconds: `→` is on the breakpoint line. The debug terminal shows only the `Picked up JAVA_TOOL_OPTIONS` line until the run ends.
4. `:DapStepOver`: the assert line runs and `→` moves on.
5. `:DapContinue`: the tests run to the end; the terminal shows `[Process exited 0]`.
6. `<Space>jtr`: the report shows a check mark per test. Assumption, not tested: if it shows an old result, the run has not finished yet; wait for the exit line and open it again.

Without a breakpoint `<Space>jtC` just runs the tests to the end.

Difference to debugging a program:

| | `:DapContinue` | `<Space>jtC` / `<Space>jtM` |
| --- | --- | --- |
| For | a class with a `main` method | JUnit tests (whole class / the method under the cursor) |
| Picker | yes, the `Configuration` picker; choose the entry that ends with your main class | no, it starts directly |
| Start from | any file | the test file |

Stopping inside the code that the test calls (experiment, reported working by the owner, "yes it worked", no details; our own automated attempt could not verify it):

1. Open the file of the called method (for example `Calc.java`) and put the breakpoint inside it with `<Space>jp`.
2. Go back to the test file and press `<Space>jtC`.
3. The debugger pauses inside the called method when the test reaches it. `<Space>jh` on a parameter shows its value (the exact value shown was not reported).

Practical rule: to stop inside the code that the test calls, set the breakpoint in that file, then start the test debug from the test file.

### The Configuration picker

`:DapContinue` without a running session opens a picker titled `Configuration`. It lists `<project name> -> <main class>` for every class with a `main` method (for example one line for `Main` and one for `Snippets`). The number at the start is only the position in the list. Any entry with the main class you want is identical to the others: pick the first. Many identical entries are normal (5 identical entries in one session; 40 entries in a long session, 4 in a fresh one).

Why the list grows (read from the nvim-java source, `lua/java-dap/init.lua`: `vim.list_extend(nvim_dap.configurations.java, dap_config)`): every time the debug configuration is set up, nvim-java APPENDS the detected main classes and never clears the old ones. A set-up happens each time jdtls attaches and on `<Space>jd` / `:JavaDapConfig`, so the list grows during a long session. The 40 entries were 20 pairs; what caused each of the 20 set-ups was not verified. A restart of Neovim resets the list. Assumption, not tested: `:lua require("dap").configurations.java = {}` followed by `<Space>jd` empties and refills it without a restart.

Notes:

- Without a breakpoint, `<Space>jtC` simply runs the tests to the end.
- The debugged program's output goes to the `[dap-terminal]` window.
- Breakpoints only work when the program is started through the debugger. `<Space>jrr` runs without a debugger: it starts a plain `java` process (read from the nvim-java source, `lua/java-runner/run.lua`: the command is started with `jobstart`, no dap involved), so breakpoints are IGNORED and the whole program runs and prints all its output (the owner saw the complete output after setting a breakpoint and pressing `<Space>jrr`). The `B` sign stays on the line either way. To stop at breakpoints start with `:DapContinue` (and the picker) as above, or `<Space>jtC` / `<Space>jtM` for tests.
- More than one breakpoint (in a scratch copy, tmux, real nvim, 2026-10-05, breakpoints set with `<Space>jp` on two lines of a small `main` method): `:DapContinue` plus the picker stops at the FIRST breakpoint the program reaches (`→` on that line; the terminal shows only the `Picked up JAVA_TOOL_OPTIONS` line). `:DapContinue` while paused runs on and stops at the SECOND one (the terminal now also shows the output printed in between). A third `:DapContinue`, with nothing left to stop at, runs to the end: the terminal shows the rest of the output and `[Process exited 0]`. The order of stops follows the order in which the program reaches the lines, not the order in which you set the breakpoints. `<Space>jx` stops early at any point.
- Remove breakpoints: `<Space>jp` (or `:DapToggleBreakpoint`) on the line that has the `B` removes it. It TOGGLES: with the cursor on a different line it ADDS a breakpoint there (read from nvim-dap `toggle_breakpoint`; removal not separately confirmed by the owner). "I have tons of breakpoints, how do I remove them all?": `<Space>jP` (same as `:DapClearBreakpoints`) clears the breakpoints of all files at once, `<Space>jp` on the line removes only that one. The command and the key `<Space>jP` were both used in the owner's session; the key was also run headless in a scratch copy (3 breakpoints in 3 files, none afterwards). The command was also run headless (2026-10-05, scratch copy: 7 breakpoints in 3 files went to 0 breakpoints in 0 files); there is no undo, set them again with `<Space>jp`. Not tested: the visual `B` signs in a UI, and running it while a debug session is paused. Assumption, not tested: removing a breakpoint while paused does not resume the program.
- If a debug window stays open after `<Space>jx` / `:DapTerminate`, close it with `<Space>q` in that window.
- See [section 36](../07-code.md#36-debugging) and [section 56](../07-code.md#56-debugging-in-depth) for the general DAP notes.

## 8. Refactoring (extract)

How it works: each `<Space>je...` key runs `vim.lsp.buf.code_action` filtered to one kind (`refactor.extract.variable`, `.constant`, `.function`, `.field`). So `<Space>je...` and `<Space>ca` use the same jdtls actions; the keys just pick the right one for you.

**Rule: select first, then act.** To extract a whole statement or several lines into a method, the code MUST BE SELECTED BEFORE you press `<Space>jem`. Without a selection only the small expression under the cursor is extracted. Variable and constant extraction (`<Space>jev`, `<Space>jec`, `<Space>jeo`) are the opposite: they need NO selection, the cursor on the expression is enough.

The cursor or selection decides what is extracted. After the action a small `New Name` window opens with a proposed name (`i`, `_4`, `extracted`). The change is ALREADY applied; the window renames it:

- `<Enter>` accepts the name in the box (to rename, delete the text with `<BS>` first, then type the new name; it must be a valid Java identifier or you get "is not a valid Java identifier").
- `<Esc>` closes the window and keeps the proposed name.

Undo needs `u` twice (once for the rename step, once for the extraction).

Try-it code (`Main.java`), results with the cursor on the shown part:

```java
Calc calc = new Calc();
int total = calc.add(2, 3) * 4;
String label = "result";
System.out.println(label + ": " + total);
```

| Key | Cursor | Result |
| --- | --- | --- |
| `<Space>jev` | on `calc.add(2, 3)` | `int i = calc.add(2, 3);` and `int total = i * 4;` (the `New Name` box proposes `i`) |
| `<Space>jeo` | on an expression that appears several times | same, but every identical occurrence uses the new variable |
| `<Space>jec` | on the `4` | `private static final int _4 = 4;` above the method and `... * _4;` (rename to `FACTOR` gives `private static final int FACTOR = 4;`) |
| `<Space>jem` | on the identifier `calc`, no selection | extracts only that identifier: `extracted(calc).add(2, 3)` and `private static Calc extracted(Calc calc) { return calc; }` |
| `<Space>jem` | selection made first, see below | extracts the selected statement(s) into a method |
| `<Space>jef` | on an expression | extracts to a field (same flow, not tested separately) |

Extracting a whole statement or block into a method needs a selection, and the key is normal mode only. Select first, then leave Visual mode, then press the key. Exact flow (2026-10-05), for the `System.out.println(label + ": " + total);` line:

1. `^` Put the cursor on the first character of the statement (`^` jumps to the first non-blank character).
2. `v` Start a characterwise selection. The bottom line must say `-- VISUAL --`, NOT `-- VISUAL LINE --`.
3. `$` Extend the selection to the end of the line, so the highlight covers the whole statement including the `;` (in this config `$` in Visual mode goes to the last visible character).
4. `<Esc>` Leave Visual mode. The highlight disappears; that is normal, Neovim remembers the selection.
5. `<Space>jem` The `New Name` box appears and the line is already replaced by the call.

Why this order: `<Space>jem` (like all `<Space>j...` keys) is a Normal-mode mapping only (`keymap.set("n", ...)` in `lua/mappings.lua`), so it cannot be pressed while Visual mode is active; there `<Space>` and `j` are Visual-mode keys that move the selection. The command reads the range of the LAST Visual selection (the marks `'<` and `'>`), which Neovim keeps after `<Esc>`. `gv` re-selects the last selection (default Neovim behaviour, not tried here).

What goes wrong:

- Capital `V` (linewise) selection: only a part was extracted. On a longer `println("sum=" + sum + ...)` line only the text `"sum="` was extracted: `System.out.println(extracted() + sum + ...` plus a method returning `"sum="`. On the try-it line only `System.out` was extracted.
- Starting `v` in the middle of the line: partial selection, odd result.
- `<Space>jem` before jdtls is ready: only a warning, nothing is extracted. Wait for jdtls (see section 2).

Result:

```java
        extracted(total, label);
    }

    private static void extracted(int total, String label) {
        System.out.println(label + ": " + total);
    }
```

Another statement: `System.out.println("sum=" + sum + " limited=" + limited + " product=" + product);` became `extracted(sum, limited, product);` plus a new `private static void extracted(int sum, int limited, int product)` method.

Pressing `<Space>jem` while the selection is still active does NOT work (visual mode has no such key; `<Space>ca` there would even run `c`, change, on the selection).

## 9. Snippets

Source: `my_snippets/java.snippets` (71 snippets, grouped below as in the file). Type the trigger in insert mode in a Java buffer and expand it with `<Ctrl-j>` ([section 15](../04-completion-snippets.md#15-snippets-ultisnips)); `<Ctrl-j>` / `<Ctrl-k>` jump to the next / previous placeholder. A compact trigger + description table of all of them is in [`04-completion-snippets.md`](../04-completion-snippets.md) ("[Java snippets](../04-completion-snippets.md#java-snippets)"); this section explains each snippet and shows what it expands to.

Conventions (the same in every snippet):

- Triggers are camelCase and case-sensitive (`promptRead`, not `jpromptread`): pick them from the completion menu instead of typing them whole. Type `j` and read the list.
- Placeholders are generic English words naming the kind of thing to fill in (`type`, `name`, `condition`, `ExceptionType`), never hardcoded values.
- The Scanner variable is always named `input`. `fdiScanner` creates it; the other input snippets use an existing `input`.
- The one-line description is shown by nvim-cmp above the snippet body in the completion menu (scroll it with `<Ctrl-d>` / `<Ctrl-f>`).
- `fdiScanner` uses the file name as the class name by default.
- When a snippet needs an import, its description names the exact import(s). The snippets do not add imports themselves, so check that the import line exists at the top of the file.
- Counterpart snippets name each other in their description (`interface` / `implements`, `equals` / `hashCode`, `comparable` / `comparator`, `twrScanner` / `twrPrintWriter`, `twrObjectOut` / `twrObjectIn`, `minArray` / `maxArray`).

How to read the code blocks below: they show the expansion with the placeholder names, in tab-stop order. When a name appears several times in the real expansion (for example the loop variable `i`), you type it once and every copy follows. Delete the placeholder text you do not need, or overwrite it.

**Group: Program skeleton and input**

**The Scanner `Type` placeholder.** The input snippets end in `input.next` plus a placeholder `Type`. Type the name of what you want to read, with a capital first letter, and it becomes the method:

| You type for `Type` | Method | Reads | Variable type |
| --- | --- | --- | --- |
| `Int` | `nextInt()` | an integer | `int` |
| `Double` | `nextDouble()` | a decimal number | `double` |
| `Boolean` | `nextBoolean()` | `true` / `false` | `boolean` |
| `Line` | `nextLine()` | a whole line, spaces included | `String` |
| (none, just `next`) | `next()` | one word | `String` |

`Int` and `Double` match the Java type name (`int`, `double`). Strings are the odd one out: you do not write `String`, you write `Line` (a whole line) or use `next()` (one word, which you must type by hand because `Type` is part of the placeholder). Other types follow the same idea (`nextLong()`, `hasNextBigInteger()`).

**`fdiScanner`**: whole program skeleton for the course (package `fondamentidiinformatica.<subpackage>`), with a Scanner named `input`, one prompt and one read. The class name defaults to the file name.

```java
package fondamentidiinformatica.subpackage;

import java.util.Scanner;

public class FileName {
    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);

        System.out.print("prompt: ");
        type name = input.nextType();

        // code

        input.close();
    }
}
```

Example: prompt `Enter your age`, type `int`, name `age`, `Type` = `Int` gives `int age = input.nextInt();`.

**`promptRead`**: prints a prompt and reads one value into a new variable. Needs `import java.util.Scanner;` and an existing `input`.

```java
System.out.print("prompt: ");
type name = input.nextType();
```

Example: `double`, `price`, `Double` gives `double price = input.nextDouble();`. For a text line: `String`, `city`, `Line` gives `String city = input.nextLine();`.

**`readValidated`**: asks again until the user types the right kind of value. The `Type` placeholder is used twice, in `hasNext<Type>()` (is the next token of that type?) and in `next<Type>()` (read it), so you type it once.

```java
while (!input.hasNextType()) {
    System.out.print("error message: ");
    input.nextLine();
}
type name = input.nextType();
```

Examples: `Type` = `Int` gives `hasNextInt` / `nextInt`; `Type` = `Double` gives `hasNextDouble` / `nextDouble`. The same pattern works for other types, for instance `hasNextBigInteger`. The type name matches Java (`Int`/`int`, `Double`/`double`), except that a String uses `Line` (`hasNextLine` / `nextLine`), which reads a whole line, while `next` reads one word. The `input.nextLine()` inside the loop throws away the wrong input before asking again.

**`readNumberThenLine`**: reads a number and then a line of text. After `nextInt()` the Enter key is still waiting in the input, so a plain `nextLine()` would return an empty string. The extra `input.nextLine()` consumes that leftover newline. Use it whenever a number read is followed by a line read.

```java
type name = input.nextType();
input.nextLine(); // consume the leftover newline
String text = input.nextLine();
```

Example: `int`, `age`, `Int`, then `text` renamed to `fullName`. `Type` is a number type here (`Int`, `Double`), not `Line`.

**`readUntilInt`**: keeps reading numbers until the user types a stop value (the sentinel), then leaves the loop with `break`. The comparison uses `==`, so it fits numbers and chars, not Strings (use `readUntilString`).

```java
while (true) {
    System.out.print("prompt: ");
    type name = input.nextType();

    if (name == sentinel) {
        break;
    }

    // code
}
```

Example: `int`, `n`, `Int`, sentinel `0` gives `int n = input.nextInt();` and `if (n == 0)`. For a double you would write `double`, `Double`, and a sentinel such as `-1`.

**`readUntilString`**: the same loop for text lines. It compares with `.equals(...)`, never with `==`, because Strings are objects.

```java
while (true) {
    System.out.print("prompt: ");
    String name = input.nextLine();

    if (name.equals("sentinel")) {
        break;
    }

    // code
}
```

Example: sentinel `stop` ends the loop when the user types `stop`.

**`randomInt`**: a random integer from `min` to `min + range - 1`. Example: range `6`, min `1` gives a die roll from 1 to 6.

```java
int name = (int) (Math.random() * range) + min;
```

**Group: Arrays, matrices and collections**

**Arrays.** `arrayNew` makes an empty array of a given size (all zeros, `false` or `null`); `arrayLiteral` makes one from known values. Delete or add values in the braces as needed.

```java
type[] name = new type[size];
type[] name = {value1, value2, value3};
```

Example: `int`, `scores`, `5` gives `int[] scores = new int[5];`.

**`minArray` / `maxArray`**: find the smallest / largest element. The result starts as the first element and the loop compares from index 1. The two snippets are identical except for `<` and `>`.

```java
type min = array[0];
for (int i = 1; i < array.length; i++) {
    if (array[i] < min) {
        min = array[i];
    }
}
```

`maxArray` has the variable named `max` and `>` in the comparison. Example: `type` = `int`, `array` = `scores`.

**`forMatrix` / `foreachMatrix`**: walk every cell of a two-dimensional array. The indexed version gives you the row and column numbers `i` and `j` and a spot after each row (for example to print a newline); the foreach version gives the values directly but no indexes.

```java
for (int i = 0; i < matrix.length; i++) {
    for (int j = 0; j < matrix[i].length; j++) {
        // code
    }
    // end of row
}

for (type[] row : matrix) {
    for (type value : row) {
        // code
    }
}
```

Note the tab-stop order of `forMatrix`: the matrix name comes first, then `i`, `j`, the inner code and the end-of-row spot.

**`arrayAdd` / `arrayRemove`**: methods for a fixed-size array plus a counter. The array never grows: `count` says how many slots are really used, and the free slots are at the end. Put them inside your class, where `array` and `count` are fields. Add stores at position `count` and increments it (it returns `false` if the element is `null` or the array is full). Remove finds the element with `equals`, shifts the following ones left, clears the last used slot and decrements `count` (it returns `false` if not found). Remove works on object arrays (`String`, your own classes), not on `int[]`.

```java
boolean methodName(Type element) {
    if (element == null || count >= array.length) {
        return false;
    }
    array[count++] = element;
    return true;
}

boolean methodName(Type element) {
    for (int i = 0; i < count; i++) {
        if (array[i].equals(element)) {
            for (int j = i; j < count - 1; j++) {
                array[j] = array[j + 1];
            }
            array[--count] = null;
            return true;
        }
    }
    return false;
}
```

Example: `methodName` = `addStudent`, `Type` = `Student`, `element` = `student`, `count` = `numStudents`, `array` = `students`. In `arrayRemove` the order is `methodName`, `Type`, `element`, `i`, `count`, `array`, `j`.

**Collections.** Four declarations. The type names go inside `<>` and must be object types: `Integer` instead of `int`, `Double` instead of `double`, `String`.

| Trigger | Expansion | Imports |
| --- | --- | --- |
| `hashMap` | `HashMap<KeyType, ValueType> name = new HashMap<>();` | `java.util.HashMap` |
| `treeMap` | `TreeMap<KeyType, ValueType> name = new TreeMap<>();` (keys kept sorted) | `java.util.TreeMap` |
| `arrayList` | `List<Type> name = new ArrayList<>();` | `java.util.List`, `java.util.ArrayList` |
| `hashSet` | `Set<Type> name = new HashSet<>();` (no duplicates) | `java.util.Set`, `java.util.HashSet` |

Examples: `HashMap<String, Integer> ages`, `List<String> names`, `Set<Integer> seen`.

**`forMapEntry`**: loops over a map one entry (key and value) at a time. Needs `import java.util.Map;`. Inside the loop call `entry.getKey()` and `entry.getValue()`.

```java
for (Map.Entry<KeyType, ValueType> entry : map.entrySet()) {
    // entry.getKey(), entry.getValue()
}
```

Example: `String`, `Integer`, `entry`, `ages` gives `for (Map.Entry<String, Integer> entry : ages.entrySet())`.

**Group: Control flow**

Plain loops and conditions. Tab stops go top to bottom (loop header, then body; for `ifelif` each condition and body in turn).

```java
for (int i = start; i < end; i++) { /* code */ }        // for
for (Type item : collection) { /* code */ }              // foreach
while (condition) { /* code */ }                         // while
do { /* code */ } while (condition);                     // dowhile
if (condition) { /* code */ }                            // if
if (condition) { /* code */ } else { /* code */ }        // ifelse
if (c1) { /* code */ } else if (c2) { /* code */ } else { /* code */ }  // ifelif
```

(The real expansions are multi-line with one statement per line; they are compressed here.) `for` loops from `start` up to but not including `end`; use `foreach` when you do not need the index. `dowhile` runs the body at least once.

**`tern`**: ternary conditional assigned to a variable.

```java
type name = condition ? valueIfTrue : valueIfFalse;
```

Example: `String`, `label`, `age >= 18`, `"adult"`, `"minor"`.

**Switch.** Six forms of the same idea; choose by style. `variable` is what you test; the case values are constants (numbers, chars, Strings, enum constants).

| Trigger | Style | Use it when |
| --- | --- | --- |
| `switchtraditional` | `case v:` with `break;` | the classic form; forgetting `break` makes execution fall through to the next case |
| `switchmulti` | `case a: case b:` | two values share one body |
| `switcharrow` | `case v -> statement;` | no `break` needed, no fall-through |
| `switcharrowmulti` | `case a, b -> statement;` | arrow form with two values per case |
| `switchyield` | `Type result = switch (...) {...};` | the switch produces a value you assign |
| `switchyieldblock` | same, with a `{ ... yield ...; }` block | one case needs several statements before giving its value |

```java
switch (variable) {                       // switchtraditional
    case value1:
        // code
        break;
    case value2:
        // code
        break;
    default:
        // code
        break;
}

switch (variable) {                       // switcharrow
    case value1 -> statement;
    case value2 -> statement;
    default -> statement;
}

Type result = switch (variable) {         // switchyield
    case value1 -> "result1";
    case value2 -> "result2";
    default -> "defaultResult";
};

Type result = switch (variable) {         // switchyieldblock
    case value1, value2 -> "result1";
    case value3, value4 -> {
        // statements
        yield "result2";
    }
    default -> "defaultResult";
};
```

`switchmulti` and `switcharrowmulti` are the same as the two first forms with `value1`..`value4` (two labels in each case). The switch-expression forms need `Type` to match what the cases return (`String` for the quoted texts; change the quotes if you return numbers) and a `default` case. Arrow switches need Java 14 or later.

**Group: Methods**

Both are `private static`, the form used in `main` programs where methods sit next to `main` in one class.

```java
private static returnType name(type param) {      // staticMethod
    // code
}

private static returnType name(type param) {      // recursive
    if (baseCondition) {
        return baseValue;
    }
    return recursiveCase;
}
```

`recursive` is a method that calls itself: the base case stops the recursion and the last line is the recursive call. Example for a factorial: `int`, `factorial`, `int n`, base `n <= 1`, value `1`, recursive case `n * factorial(n - 1)`. Delete or add parameters as needed.

**Group: Classes**

**`class` / `publicClass`**: a class with three fields and a constructor that assigns them. `class` is package-private with plain fields; `publicClass` is `public`, with `private final` fields (cannot change after construction) and a `public` constructor. Delete the field lines and constructor parts you do not need; the field names repeat in the constructor, so rename them in one place.

```java
public class ClassName {
    private final type field1;
    private final type field2;
    private final type field3;

    public ClassName(type field1, type field2, type field3) {
        this.field1 = field1;
        this.field2 = field2;
        this.field3 = field3;
    }
}
```

Example: `Student`, `String name`, `int age`.  `class` is the same without `public` and `private final`.

**`subclass`**: a class that extends another and calls its constructor with `super(...)`. Example: `Student`, `Person`, parameters `String name`, arguments `name`.

```java
public class SubClass extends SuperClass {
    public SubClass(type param) {
        super(arguments);
    }
}
```

**`abstractClass`** / **`interface`** / **`implements`**: an abstract class cannot be instantiated and has methods without a body that subclasses must write; an interface lists methods only; `implements` is the class that fulfils an interface (it already includes `@Override`). Use `interface` first, then `implements` in another file with the same interface and method names.

```java
public abstract class ClassName {
    // fields and constructor

    public abstract returnType method(type param);
}

public interface InterfaceName {
    returnType method(type param);
}

public class ClassName implements InterfaceName {
    @Override
    public returnType method(type param) {
        // code
    }
}
```

Example: interface `Shape` with `double area()`, class `Circle implements Shape`.

**`toString` / `toStringSuper`**: `toString()` is what `System.out.println(object)` prints. `toString` writes the class name and two fields (delete or copy the `+ ", field=" + this.field` part for other counts); `toStringSuper` is for a subclass and appends one extra field to the text of the superclass.

```java
@Override
public String toString() {
    return "ClassName[field1=" + this.field1 + ", field2=" + this.field2 + "]";
}

@Override
public String toString() {
    return super.toString() + ", label: " + this.field;
}
```

**`equals` / `hashCode`**: they go together. `equals` says when two objects count as equal (same field values rather than same memory address); `hashCode` must give the same number for equal objects, and hash collections (`HashMap`, `HashSet`) rely on that. If you override one, override the other with the same fields. `hashCode` needs `import java.util.Objects;`.

```java
@Override
public boolean equals(Object obj) {
    if (this == obj) {
        return true;
    }
    if (obj == null || getClass() != obj.getClass()) {
        return false;
    }
    ClassName other = (ClassName) obj;
    return comparison;
}

@Override
public int hashCode() {
    return Objects.hash(field1, field2);
}
```

Example for `comparison`: `name.equals(other.name) && age == other.age` (use `.equals` for objects, `==` for primitives). Then `hashCode` takes `name, age`.

**`defaultIfBlank` / `defaultIfBelowMin`**: one-line field assignments for a constructor that validates its arguments instead of throwing. The first replaces a `null` or blank String with a default; the second replaces a number below a minimum. They use the constructor parameter named like the field.

```java
this.field = field == null || field.isBlank() ? defaultValue : field;   // defaultIfBlank
this.field = field < minimum ? defaultValue : field;                    // defaultIfBelowMin
```

Examples: `this.name = name == null || name.isBlank() ? "unknown" : name;` and `this.age = age < 0 ? 0 : age;`. To reject bad values with an exception instead, use `throwIf`.

**`record` / `recordCompact`**: a record is a short class for plain data; the compiler writes the constructor, getters (`point.x()`), `equals`, `hashCode` and `toString`. The compact form adds validation code that runs in the constructor (throw an exception there, or normalise a value).

```java
public record RecordName(type component1, type component2) {}

public record RecordName(type component) {
    public RecordName {
        // validation
    }
}
```

Example: `public record Point(int x, int y) {}`; compact validation: `if (x < 0) throw new IllegalArgumentException("negative");`.

**`enum` / `enumFields`**: a fixed set of named values. `enumFields` lets each constant carry a value, with a private constructor and a getter.

```java
public enum EnumName { CONSTANT1, CONSTANT2, CONSTANT3 }

public enum EnumName {
    CONSTANT1(value1), CONSTANT2(value2);

    private final type field;

    private EnumName(type field) {
        this.field = field;
    }

    public type getField() {
        return field;
    }
}
```

Example: `public enum Size { SMALL(1), LARGE(3); ... private final int weight; ... getWeight() }`.

**`instanceOf`**: tests the type of an object and gives you a variable of that type in the same step (no cast). Example: `object` = `shape`, `Type` = `Circle`, variable `circle`.

```java
if (object instanceof Type variable) {
    // code
}
```

**`comparable` / `comparator`**: both define an order for sorting. `comparable` is the natural order, written inside the class itself, so the class must also say `implements Comparable<ClassName>` (add it by hand; the snippet does not). `comparator` is a separate class for an alternative order, used as `Collections.sort(list, new ByAge())` or `list.sort(new ByAge())`. Both return a negative number, zero or a positive number. `comparator` needs `import java.util.Comparator;`.

```java
@Override
public int compareTo(ClassName other) {
    return comparison;
}

public class ComparatorName implements Comparator<Type> {
    @Override
    public int compare(Type first, Type second) {
        return comparison;
    }
}
```

Example for `comparison`: `Integer.compare(age, other.age)` in `compareTo`, and `first.getName().compareTo(second.getName())` in `compare`.

**Group: Exceptions**

**`exception` / `exceptionData`**: your own checked exception (a method that throws it must declare `throws` or catch it). Type the name once without the word `Exception`: the snippet adds it. The first has a fixed message; the second keeps a value and builds the message from it.

```java
public class NameException extends Exception {
    public NameException() {
        super("message");
    }
}

public class NameException extends Exception {
    private final type field;

    public NameException(final type field) {
        super(messageExpression);
        this.field = field;
    }

    public type getField() {
        return field;
    }
}
```

Example: `Name` = `InvalidAge`, message `"Age is not valid"` gives `InvalidAgeException`. For the data version: `int`, `age`, message expression `"Invalid age: " + age`, getter `Age`.

**`throwIf`**: guard at the start of a method that throws when the condition holds. Common `ExceptionType` values: `IllegalArgumentException` (bad argument), `NullPointerException` (unexpected null); or one of your own exceptions.

```java
if (condition) {
    throw new ExceptionType("message");
}
```

Example: `age < 0`, `IllegalArgumentException`, `"age must not be negative"`.

**`trycatch` / `tryfinally` / `trywith`**: `try` runs the code, `catch` handles the named exception, `finally` always runs afterwards (cleanup). `trywith` is try-with-resources: the resource declared in the parentheses is closed automatically at the end, with or without an error. Common `ExceptionType` choices: `InputMismatchException`, `NumberFormatException`, `FileNotFoundException`, `IOException`, or just `Exception`.

```java
try {
    // code
} catch (ExceptionType e) {
    // handle exception
}

try {
    // code
} catch (ExceptionType e) {
    // handle exception
} finally {
    // cleanup code
}

try (ResourceType resource = initializer) {
    // code
} catch (ExceptionType e) {
    // handle exception
}
```

Example for `trywith`: `Scanner`, `fileScanner`, `new Scanner(new File("data.txt"))`, `FileNotFoundException`. The ready-made file versions are in the next group.

**Group: File I/O and serialization**

The `twr*` snippets are try-with-resources: the reader or writer is closed automatically at the end of the block, so you never call `close()`. Replace `path` with the file name, relative to where the program runs (for example `data.txt`). Each has a catch clause with the exception the file operation can throw.

**`twrScanner` / `twrPrintWriter`**: read a text file line by line with a Scanner; write to a text file with a PrintWriter. Imports: for reading `java.util.Scanner`, `java.io.File`, `java.io.FileNotFoundException`; for writing `java.io.PrintWriter`, `java.io.FileOutputStream`, `java.io.FileNotFoundException`. The `true` in the writer turns on automatic flushing. `FileOutputStream` overwrites an existing file.

```java
try (Scanner fileScanner = new Scanner(new File("path"))) {
    while (fileScanner.hasNextLine()) {
        String line = fileScanner.nextLine();
        // code
    }
} catch (FileNotFoundException e) {
    // handle exception
}

try (PrintWriter writer = new PrintWriter(new FileOutputStream("path"), true)) {
    writer.println(content);
} catch (FileNotFoundException e) {
    // handle exception
}
```

Example: path `data.txt`; content `name + " " + age`. Use `writer.println` in a loop for several lines (put the snippet's `println` line inside your own `for`).

**`twrBufferedReader`**: reads a file line by line with `BufferedReader.readLine()`, which returns `null` at the end of the file. Imports: `java.io.BufferedReader`, `java.io.FileReader`, `java.io.IOException`. Same job as `twrScanner` with a different class and exception (`IOException`).

```java
try (BufferedReader reader = new BufferedReader(new FileReader("path"))) {
    String line;
    while ((line = reader.readLine()) != null) {
        // code
    }
} catch (IOException e) {
    // handle exception
}
```

**`twrObjectOut` / `twrObjectIn` / `serialUID`**: serialization saves a whole object to a binary file and reads it back. The class of the object must say `implements Serializable` (`import java.io.Serializable;`), and so must the classes of its fields. `serialUID` adds the version field inside that class; give it any number, change it when the class changes shape. Imports for writing: `java.io.ObjectOutputStream`, `java.io.FileOutputStream`, `java.io.IOException`; for reading: `java.io.ObjectInputStream`, `java.io.FileInputStream`, `java.io.IOException`. Reading needs a cast to the real type and also catches `ClassNotFoundException`.

```java
try (ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream("path"))) {
    out.writeObject(object);
} catch (IOException e) {
    // handle exception
}

try (ObjectInputStream in = new ObjectInputStream(new FileInputStream("path"))) {
    Type name = (Type) in.readObject();
} catch (IOException | ClassNotFoundException e) {
    // handle exception
}

private static final long serialVersionUID = 1L;
```

Example: write `student` to `student.dat`, then read with `Type` = `Student`, `name` = `loaded`.

**Group: JavaFX**

JavaFX is the graphical interface library of the course.

**`fxApp`**: skeleton of a JavaFX program: a class extending `Application`, a `start` method that builds the window, and `main` that calls `launch`. Imports: `javafx.application.Application`, `javafx.stage.Stage`, `javafx.scene.Scene`, `javafx.scene.layout.BorderPane`. The `BorderPane` placeholder is the root layout (change it, for example to `VBox`, and add the matching import); width and height are in pixels.

```java
public class ClassName extends Application {
    @Override
    public void start(Stage primaryStage) {
        BorderPane root = new BorderPane();
        primaryStage.setTitle("title");
        primaryStage.setScene(new Scene(root, width, height));
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
```

Example: title `My app`, width `400`, height `300`.

**`fxProperty`**: the usual JavaFX model field: a property plus its getter, setter and `nameProperty()` accessor (used for binding). The snippet only declares the field and the three methods; you must create the property yourself in the constructor, for example `this.name = new SimpleStringProperty(name);`. `PropertyType` is the property class and `valueType` the plain Java type it holds; they go in pairs:

| `PropertyType` | `valueType` | Create with |
| --- | --- | --- |
| `StringProperty` | `String` | `new SimpleStringProperty(...)` |
| `IntegerProperty` | `int` | `new SimpleIntegerProperty(...)` |

Imports: `javafx.beans.property.StringProperty` (or the property type you chose) and the matching `Simple...Property` class.

```java
private final PropertyType name;

public valueType getName() {
    return name.get();
}

public void setName(valueType value) {
    name.set(value);
}

public PropertyType nameProperty() {
    return name;
}
```

Example: `StringProperty`, `title`, `String`, `Title` gives `getTitle()`, `setTitle(...)` and `titleProperty()`.

**`fxAlert`**: a pop-up dialog that waits for the user to close it. Imports: `javafx.scene.control.Alert`, `javafx.scene.control.Alert.AlertType`. `AlertType` examples: `INFORMATION` (a notice), `ERROR` (something failed); `WARNING` and `CONFIRMATION` also exist.

```java
Alert alert = new Alert(AlertType.alertType);
alert.setTitle("title");
alert.setHeaderText("headerText");
alert.setContentText("content");
alert.showAndWait();
```

Example: `INFORMATION`, title `Saved`, header `Done`, content `The file was saved.`. For a confirmation, `showAndWait()` returns the button the user pressed.

**`fxOnAction`**: runs code when a button is clicked. Example: `button` = `saveButton`, `event` = `e`.

```java
button.setOnAction((event) -> {
    // code
});
```

## 10. Windows while running, testing and debugging

| Keys | What it does |
| --- | --- |
| `<Ctrl-w>h` `j` `k` `l` | Move between windows: code, the runner or test terminal at the bottom, the report |
| `<Left>` `<Down>` `<Up>` `<Right>` | The same with arrow keys (normal mode) |
| `<Esc>` first | In a terminal window press `<Esc>` to get to normal mode, then use a window key. `i` types in the terminal again |
| `<Space>q` | Save if modified and close the current window (use it in a runner, test or debug terminal) |
| `<Ctrl-w>o` | Keep only the current window |
| `<Esc>` in a float | Closes the report float, the Profiles window, `New Name` box and hover floats ([section 7](../06-windows-terminal-sessions.md#7-windows-splits-and-buffers) lists `<Esc>` closing floats) |

See [section 7](../06-windows-terminal-sessions.md#7-windows-splits-and-buffers) (windows) and the cheat sheet in [section 2](../README.md#2-day-to-day-cheat-sheet) for the same rows.

## 11. Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `<Space>j...` shows `Java: jdtls not attached (open nvim inside the Java devShell, or run :DevEnv java)` | `java` is not on PATH (not in the devShell) or jdtls has not finished starting | Quit, `cd` into the project, check `direnv allow` and `which java`, start nvim again; inside the devShell wait about 10 s and check `:LspAttached` |
| jdtls never attaches | Neovim started before direnv loaded; jdtls crashed | `:LspLog`, `:checkhealth vim.lsp`, `:edit` the file; check `which java` |
| Tests or debugger do not start, adapter not found | The devShell was not entered since the extensions were linked, or the links broke | Enter the project with direnv once (the shell hook relinks `~/.local/share/nvim/nvim-java/packages/java-debug-adapter/extension` and `java-test/extension`), restart nvim |
| `<Space>jrr` prints nothing | jdtls not finished importing, or the file is not under `src/main/java`, or no `main` method | Wait for the first import, `<Space>jbb`, then `<Space>jrr` again; a project that is its own git root and one nested in a bigger git repo both work |
| Old errors or deleted classes still shown | Stale jdtls workspace | `<Space>jbc` then Yes (jdtls restarts); if it stays wrong: `rm -r ~/.cache/nvim/jdtls/workspace` |
| A different, empty workspace appears after starting from another folder | The workspace folder name is a hash of the START folder of Neovim | Always start nvim in the same project folder |
| Test terminal shows no pass/fail | By design: results are in the report (for `<Space>jtm`: only the `Picked up JAVA_TOOL_OPTIONS` line and `[Process exited 0]`) `<Space>jtr`; no terminal window appears at all after you closed it once: see [The test terminal window does not come back after you close it](#the-test-terminal-window-does-not-come-back-after-you-close-it) |
| `<Space>jtm` warns `cursor is not on a test method` | Cause: no `@Test` above the method. Other causes (cursor outside a method: from the source code; jdtls not yet updated, syntax error: assumptions) | Add `@Test`, cursor inside the method; see [`cursor is not on a test method`](#cursor-is-not-on-a-test-method) |
| First test run fails with a download error | Maven offline: JUnit jars not in `~/.m2`. In a shell with an empty repo: `mvn -o test` stops with `Cannot access central (https://repo.maven.apache.org/maven2) in offline mode and the artifact org.apache.maven.plugins:maven-resources-plugin:jar:3.3.1 has not been downloaded from it before` | Connect once, run `<Space>jtc` again (or `mvn test` in a shell) |
| `Java version mismatch: JDTLS ... requires Java ...` | The JDK on PATH is too old or too new for jdtls 1.54.0 | Use the devShell JDK (25) |
| "release version N not supported" when compiling | `maven.compiler.release` in `pom.xml` is higher than the JDK | Lower it (the test project uses 21 on JDK 25) |
| `.java` file in a scratch folder: no Java features | No project root (no `pom.xml`, `.git`) | Create `pom.xml` or `git init` |
| Debugger does not stop | No breakpoint, or the breakpoint is on a line without code | `<Space>jp` on a code line, then `<Space>jtC` |
| `:DapStepInto` opens an empty `unknown` buffer | The step went into library code without source | `:DapStepOut`; step into your own methods only |
| `<Space>rn` or `<Space>ca` warn "no attached language server supports it" | Only typos_lsp attached, jdtls missing | Same as "jdtls never attaches" |
| `<Space>rn` (or another project-wide action such as references) does nothing after `<Enter>`, no message | Most likely (not guaranteed): the jdtls search index files of the workspace are missing or stale and the server fails silently; other causes exist. Slow answers (10 to 17 s or more) are normal | Wait, check `:LspAttached`, read the jdtls log, then `<Space>jbc` + Yes if it shows index errors; steps in [When a rename does nothing](#when-a-rename-does-nothing) |
| `<Space>ca` shows no `Import ...` entries | The cursor is not on the unknown word | Put the cursor ON the word (`List`), then `<Space>ca` ([Add a missing import](#add-a-missing-import-auto-import)) |
| `Add all missing imports` shows `Failed to choose imports ... bad argument #1 to 'ipairs'` | nvim-java error when a name has several candidate packages or does not exist | Use the single `Import '<Name>' (<package>)` entries one by one |
| `"java.action.generateAccessorsPrompt" is not supported yet!` | You picked a generate entry WITH trailing dots | Use the entry without dots ([Generate getters, setters and constructors](#generate-getters-setters-and-constructors)) |
| Spelling squiggles on valid names | typos_lsp does not know the word | Put a `typos.toml` with `[default.extend-words]` in the project root |
| `.project`, `.classpath`, `.settings/` in `git status` | jdtls writes Eclipse files into the project | Add them to the project's `.gitignore` |
| Refactor made a mess | The edit was applied before the rename step | `u` twice, then redo |
| `<Space>jj` says `No configured runtimes available` | No `java.configuration.runtimes` set | Expected here; nothing to fix |


## Related sections

Section [35](../07-code.md#35-java-development-nvim-java) (Java keys), [54](../07-code.md#54-java-development-in-depth) (Java in depth), [36](../07-code.md#36-debugging) and [56](../07-code.md#56-debugging-in-depth) (debugging), [19](../07-code.md#19-code-running) and [55](../07-code.md#55-code-running-in-depth) (running code, `<Space>rr`), [13](../07-code.md#13-lsp-language-server-protocol) (LSP), [14](../04-completion-snippets.md#14-autocompletion-nvim-cmp) (completion), [15](../04-completion-snippets.md#15-snippets-ultisnips) (snippets), [7](../06-windows-terminal-sessions.md#7-windows-splits-and-buffers) (windows), [8](../06-windows-terminal-sessions.md#8-terminal-integration) (terminal), [20](../08-git.md#20-git-integration) (git; the git root decides the jdtls root), [2](../README.md#2-day-to-day-cheat-sheet) (quick reference and cheat sheet).


---
