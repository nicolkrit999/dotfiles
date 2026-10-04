<!-- chapter: Java -->
[Back to the guide index](../README.md)

# 78. Java (nvim-java, jdtls, tests, debugging)

This section is one complete walk through everything that is specific to Java in this config: the tools, why each one is there, how it works, how to use it, and what to do when it does not work. It covers only Java-only things (nvim-java and its parts, the language servers, the test runner, the debugger, the Java keys, commands and snippets). Global tools with global keys (`gd`, `K`, `<Space>rn`, git, fzf, ...) get only a pointer to their own section. Sections 35 and 54 hold the short key lists and section 56 the debugging basics; this section puts everything in one order.

Everything marked "tested" below was tried with real keys in a Maven test project (JDK 25 devShell, `Main`, `Calc`, `CalcTest`).

## 1. What You Get And Why

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
| **Snippets** | Typing the same loops and switches over and over | See part 9 below | `my_snippets/java.snippets` |

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
| Where you see it | The statusline shows `jdtls (+2)` and the attached clients are `jdtls,spring-boot,typos_lsp` (see "2. Quick Start") |
| Caveat | It attaches in every Java buffer, even in a project without Spring; that is harmless (see section 5) |

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

### Outside the devShell

`java` is not on PATH, so jdtls and spring-boot do not start. `.java` files still open with syntax highlighting, snippets and typos_lsp, but without Java language features. Every `<Space>j...` key shows ONE warning, `Java: jdtls not attached (open nvim inside the Java devShell)`. These global keys are fallbacks: without them `<Space>jrr` would fall through to plain Vim keys (`<Space>`, `j`, `rr`). The universal run key `<Space>rr` (section 19) then runs plain `java <file>` if `java` exists, otherwise gives one warning.

## 2. Quick Start

1. In a terminal: `cd` into the project folder (the one with `pom.xml`). direnv loads the devShell and prints `Java Environment Active (JDK 25)`. First time: `direnv allow`.
2. `nvim src/main/java/demo/Main.java`
3. Wait about 10 seconds. The statusline shows `jdtls (+2)` (jdtls, spring-boot, typos_lsp). Tested: all three attach: `jdtls,spring-boot,typos_lsp`. Before that the `<Space>j` keys only show the warning. A big project's first start is slower.
4. Run: `<Space>jrr`. A full-width, 15-line terminal split opens at the bottom with the program output.
5. Test: open `CalcTest.java` and press `<Space>jtc`, then `<Space>jtr` for the result tree.
6. Debug: `:DapToggleBreakpoint` on a line, then `<Space>jtC`. The window stops at the line with a `→` sign.

## 3. Project Layout Rules

### The root folder

jdtls needs one root folder per project. nvim-java decides it with these markers (`lua/java-core/ls/servers/jdtls/root.lua`), two groups, the first group that matches wins:

| Group | Markers | Meaning |
| --- | --- | --- |
| 1 | `mvnw`, `gradlew`, `settings.gradle`, `settings.gradle.kts`, `.git` | multi-module projects; the git root is the last resort on purpose |
| 2 | `build.xml`, `pom.xml`, `build.gradle`, `build.gradle.kts` | single-module projects |

Consequences:

- The git root wins over a `pom.xml` below it, by design: in a multi-module Maven project you cannot tell the parent from a submodule, and jdtls does not break when the root is higher than the real parent `pom.xml`.
- A Maven project nested in a bigger git repository (`repo/java/pom.xml`) still works: the root is the git root and jdtls finds the `pom.xml` below it. `<Space>jrr` works in this layout (tested by the user's real layout).
- No git folder: the folder with `pom.xml` is the root. A loose `.java` file with neither: jdtls has no project (create a `pom.xml` or run `git init`).
- Maven and Gradle projects are both imported by jdtls.
- Expected layout: code in `src/main/java/...`, tests in `src/test/java/...`.

### First start and where files appear

- The first start of a project is slower: jdtls imports the project, runs Maven or Gradle and builds an index. The statusline and notifications show progress.
- Compiled classes go to `target/` (Maven) next to `pom.xml`. jdtls also writes Eclipse files into the project (`.project`, `.classpath`, `.settings/`). In the test project `.gitignore` contains only `target/` and `.direnv/`, so `.project`, `.classpath` and `.settings/` show up in `git status`; add them to the project's `.gitignore` if you do not want them in git.
- jdtls workspace data goes to `~/.cache/nvim/jdtls/` (`config_<hash>` and `workspace/proj_<hash>`), never into the project. The workspace folder name is a hash of the folder where Neovim was STARTED (`vim.fn.getcwd()` at startup), not of the jdtls root. Always start Neovim from the same project folder, otherwise jdtls builds a second workspace.
- Saving: the auto-save plugin saves a buffer when you leave it or when Neovim loses focus. Refactor results and edits are therefore written to disk without `:w` once you switch windows (tested: a refactor was saved this way).

## 4. Keys And Commands

All `<Space>j` keys are normal mode only. The real maps are created per buffer when jdtls attaches and removed when it detaches (`LspAttach` / `LspDetach` in `lua/mappings.lua`); before that, the global fallback shows the warning. which-key shows the groups `j` Java, `jb` build, `jr` runner, `jt` test, `je` extract.

### Build (`<Space>jb`)

| Key | Command | What it does | Mode |
| --- | --- | --- | --- |
| `<Space>jbb` | `:JavaBuildBuildWorkspace` | Compile the whole workspace; a "Background task" notification shows while it runs (tested) | n |
| `<Space>jbc` | `:JavaBuildCleanWorkspace` | Delete the jdtls workspace cache of the project after a Yes/No question, then restart jdtls (see below) | n |

### Runner (`<Space>jr`)

| Key | Command | What it does | Mode |
| --- | --- | --- | --- |
| `<Space>jrr` | `:JavaRunnerRunMain` | Run the main class | n |
| `<Space>jrs` | `:JavaRunnerStopMain` | Stop the running program (tested: the java process is gone and the runner shows `Process finished with exit code::129`); with nothing running it does nothing visible | n |
| `<Space>jrl` | `:JavaRunnerToggleLogs` | Show or hide the runner log window (tested: toggles between 1 and 2 windows) | n |
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
| `<Space>jem` | `:JavaRefactorExtractMethod` | Extract a method | n |
| `<Space>jef` | `:JavaRefactorExtractField` | Extract a field | n |

### Settings and debugger setup

| Key | Command | What it does | Mode |
| --- | --- | --- | --- |
| `<Space>jd` | `:JavaDapConfig` | Configure the debug adapter again (it is done automatically when jdtls starts) | n |
| `<Space>jj` | `:JavaSettingsChangeRuntime` | Pick another JDK runtime for jdtls; only works if runtimes are configured, see below | n |

### The `:Java*` commands

Tested with `:command Java` after jdtls attached:

- Existing at that point: `JavaBuildBuildWorkspace`, `JavaBuildCleanWorkspace`, `JavaRefactorExtract...` (five), `JavaRunnerRunMain`, `JavaRunnerStopMain`, `JavaRunnerToggleLogs`, `JavaRunnerSwitchLogs`, `JavaTestRunCurrentClass`, `JavaTestRunCurrentMethod`, `JavaTestRunAllTests`, `JavaTestDebugCurrentClass`, `JavaTestDebugCurrentMethod`, `JavaTestDebugAllTests`, `JavaTestViewLastReport`, `JavaDapConfig`, `JavaProfile`, `JavaSettingsChangeRuntime`.
- Three have no key: `:JavaRunnerSwitchLogs`, `:JavaTestRunAllTests` (all tests of the project) and `:JavaTestDebugAllTests`.
- Only `:JavaBuild*` and `:JavaRefactor*` appear after jdtls attached; the other `:Java*` commands exist as soon as nvim-java is loaded but do nothing useful without jdtls.
- `:JavaRefactor...` commands accept a range, so `:'<,'>JavaRefactorExtractMethod` is valid.

### The runner window

`<Space>jrr` opens the runner as a full-width terminal split at the bottom (tested: 14 text rows plus the status line, 200 columns wide at 200 columns). It prints the real command, then the program output, then the exit code. Tested output for `Main`:

```
/nix/store/...-openjdk-25.0.2+10/lib/openjdk/bin/java -cp .../target/classes demo.Main Picked up JAVA_TOOL_OPTIONS: -javaagent:.../lombok.jar
result: 20
Process finished with exit code::0
```

(The `Picked up JAVA_TOOL_OPTIONS` line comes from the devShell's Lombok setting; it is harmless.) `<Space>jrl` hides and shows this window again. To go back to the code: `<Esc>`, then `<Ctrl-w>k` or `<Up>`.

### Profiles window (`<Space>jrp`)

A profile stores VM arguments and program arguments for the runner of one main class. Tested flow:

1. `<Space>jrp` opens a window `Profiles` with the entry `New Profile` and the hint `[a]ctivate [d]elete [b]ack [q]uit`.
2. `<Enter>` on `New Profile` opens a form with three boxes: `Name`, `VM arguments`, `Program arguments`, and the hint `[s]ave [b]ack [q]uit`.
3. In the form (normal mode): `i` types in the box, `<Esc>` leaves it, `<Tab>` or `j` goes to the next box, `k` to the previous one, `s` saves.
4. Saved example: name `prof1`, program arguments `hello`. The profile is stored in `~/.local/share/nvim/nvim-java-profiles.json`, keyed by project folder and main class, and marked active:

```json
{"/path/to/project": {"nvim-java-test -> demo.Main": [{"name": "prof1", "is_active": true, "prog_args": "hello", "vm_args": ""}]}}
```

5. The next `<Space>jrr` uses it. Tested: the runner printed `... demo.Main hello`.
6. To switch or remove profiles: `<Space>jrp`, choose the profile, `a` activates it, `d` deletes it, `q` closes.

### Clean workspace (`<Space>jbc`)

1. `<Space>jbc` opens a Yes/No list with the question `Do you want to delete ".../.cache/nvim/jdtls/workspace/proj_<hash>"`.
2. `<Enter>` on `1. Yes` deletes that folder and restarts jdtls (tested: the folder was recreated fresh a moment later with a new timestamp, jdtls came back). `No` does nothing.
3. Your source files and `target/` are not touched.
4. The folder named in the question is computed from jdtls's root folder, while jdtls really uses a folder named from the folder where Neovim was started. They are the same when you start Neovim in the project root (the case of a project that is its own git root). If your git root is above the folder where you start Neovim, the question may name a folder that does not exist; then delete the real one by hand: `rm -r ~/.cache/nvim/jdtls/workspace` (from the nvim-java source, not tested in a nested layout).

### Change runtime (`<Space>jj`)

Tested: in the test project it only shows a notification: `No configured runtimes available` plus a link to the nvim-java README. The list of JDKs comes from jdtls setting `java.configuration.runtimes`, which this config does not set (only `java.home = $JAVA_HOME`). So `<Space>jj` is a no-op here; the JDK in use is the devShell JDK.

## 5. Language Server Features In A Java Buffer

All need jdtls attached. The general keys are described elsewhere (section 13 for LSP); here is what they do in Java.

| Key / command | What it does in Java |
| --- | --- |
| `gd` | Go to definition; several results open the location list |
| `K` | Hover: type and Javadoc. Tested: a hover float shows a "java" progress bar while loading |
| `<Space>rn` | Rename a class, method or variable in all files |
| `<Space>ca` | Code actions: quick fix, organize imports, generate getters, constructors, `toString`; also the way to extract with a selection (see Refactoring) |
| `<Space>fm` | Format the file with the jdtls formatter (Eclipse style). Tested: `calc.add(2,3)*4` became `calc.add(2, 3) * 4`. Formatting is never automatic |
| `:LspInlayHints enable` / `disable` | Inlay hints (parameter names, types); off by default (tested: enable turns hints on) |
| `<Space>t` | Symbol outline (aerial); tested in Java: shows `Main` and `main` |
| diagnostics | Compile errors and warnings appear while you type, without running anything |

Other notes:

- **illuminate**: other uses of the word under the cursor are highlighted (Java is in its filetype list).
- **typos_lsp**: attaches to Java buffers too (root markers include `.gitignore`), also outside the devShell. If `<Space>rn` or `<Space>ca` only warn "no attached language server supports it", only typos_lsp is attached and jdtls is missing.
- **Completion** and **snippets** work as in other languages (sections 14 and 15).
- The coloured line marker (`colorcolumn`) is at 100 for Java.
- spring-boot attaches next to jdtls in every Java buffer, even in a project without Spring; it is harmless.

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

1. `<Space>jtc` anywhere in the class runs both tests; with the cursor inside one method, `<Space>jtm` runs only that one.
2. A terminal window named `[dap-terminal] Launch All Java Tests` opens at the bottom (the tab line also shows it). Tested content: only the start lines (`Picked up JAVA_TOOL_OPTIONS...`) and `[Process exited 0]`. The terminal does NOT print pass or fail text.
3. The results are in the report: `<Space>jtr` opens a floating window with a tree. Tested, all passing:

```
 demo.CalcTest
   addWorks(demo.CalcTest)
   multiplyWorks(demo.CalcTest)
```

Each line has a status icon in front (a different icon for pass and fail). Tested with a wrong expected value (`assertEquals(7, ...)`): the failing method gets the failure message and stack below it:

```
   multiplyWorks(demo.CalcTest)
     org.opentest4j.AssertionFailedError: expected: <7> but was: <6>
     at org.junit.jupiter.api.Assertions.assertEquals(Assertions.java:531)
     at demo.CalcTest.multiplyWorks(CalcTest.java:15)
```

4. Close the report with `<Esc>` or `q` (both tested). `<Space>jtr` again after a new run shows the new result. The exit code in the terminal is 0 even when tests fail; trust the report.

### Needs

- A JUnit dependency in `pom.xml` (the test project: `junit-jupiter` 5.10.2 and `maven-surefire-plugin` 3.2.5, release 21).
- jdtls attached and the `java-test` extension linked by the devShell (see section 1).
- Network the first time Maven has to download the JUnit jars into `~/.m2`.

## 7. Debugging

### Why and how

nvim-dap is the debugger client; java-debug is the adapter that talks to the JVM; nvim-java registers the Java configurations for you. This config has NO dap keymaps and NO dap-ui panel (no variables or stack window). You work with `:Dap*` commands, the sign column and small floating windows. Tested end to end:

| Step | How | Tested result |
| --- | --- | --- |
| Breakpoint on / off | `:DapToggleBreakpoint` on the line (put it on a line with code, e.g. the `assertEquals` line, not on the `void addWorks() {` line) | A `B` sign in the sign column |
| Debug a test class | `:DapToggleBreakpoint`, then `<Space>jtC` | After a few seconds the window shows a `→` sign on the breakpoint line; the program is paused |
| Debug one test method | `<Space>jtM` with the cursor in the method | same, only that method |
| Debug the program (`main`) | `:DapToggleBreakpoint` in `Main.java`, then `:DapContinue` | A picker "Configuration" opens (tested: 5 identical entries `nvim-java-test -> demo.Main`); press `<Enter>` on the first: the program stops at the breakpoint with `→` |
| Step over | `:DapStepOver` | `→` moves to the next line |
| Step into | `:DapStepInto` | On a call to your own method it opens that file (tested: `calc.add(2, 3)` opens `Calc.java` at `int sum = a + b;`). On a line without a call, or into library code, it opens an empty `unknown` buffer and a DAP warning "Adapter reported frame ... Invalid cursor line" |
| Step out | `:DapStepOut` | Back to the caller |
| Look at a value | put the cursor on the variable, `:lua require("dap.ui.widgets").hover()` | A small float with the value (tested: `sum` shows `5`). `<Esc>` closes it |
| Continue | `:DapContinue` while paused | Runs to the next breakpoint or to the end (tested: the test terminal shows `[Process exited 0]`) |
| Debug console | `:DapToggleRepl` | A `[dap-repl-N]` window; run again to hide |
| Stop | `:DapTerminate` | The session ends (tested: no session afterwards) |

Notes:

- Without a breakpoint, `<Space>jtC` simply runs the tests to the end.
- The debugged program's output goes to the `[dap-terminal]` window.
- `<Space>jrr` runs without a debugger; to debug `main` use `:DapContinue` as above.
- If a debug window stays open after `:DapTerminate`, close it with `<Space>q` in that window.
- See section 36 and section 56 for the general DAP notes.

## 8. Refactoring (Extract)

How it works: each `<Space>je...` key runs `vim.lsp.buf.code_action` filtered to one kind (`refactor.extract.variable`, `.constant`, `.function`, `.field`). So `<Space>je...` and `<Space>ca` use the same jdtls actions; the keys just pick the right one for you.

The cursor or selection decides what is extracted. After the action a small `New Name` window opens with a proposed name (tested: `i`, `_4`, `extracted`). The change is ALREADY applied; the window renames it:

- `<Enter>` accepts the name in the box (to rename, delete the text with `<BS>` first, then type the new name; it must be a valid Java identifier or you get "is not a valid Java identifier").
- `<Esc>` closes the window and keeps the proposed name.

Undo needs `u` twice (once for the rename step, once for the extraction; tested).

Try-it code (`Main.java`), tested results with the cursor on the shown part:

```java
Calc calc = new Calc();
int total = calc.add(2, 3) * 4;
String label = "result";
System.out.println(label + ": " + total);
```

| Key | Cursor | Tested result |
| --- | --- | --- |
| `<Space>jev` | on `calc.add(2, 3)` | `int i = calc.add(2, 3);` and `int total = i * 4;` (the `New Name` box proposes `i`) |
| `<Space>jeo` | on an expression that appears several times | same, but every identical occurrence uses the new variable |
| `<Space>jec` | on the `4` | `private static final int _4 = 4;` above the method and `... * _4;` (rename to `FACTOR` gives `private static final int FACTOR = 4;`) |
| `<Space>jem` | on the identifier `calc` (no selection) | extracts only that identifier: `extracted(calc).add(2, 3)` and `private static Calc extracted(Calc calc) { return calc; }` |
| `<Space>jem` | selection, see below | extracts the selected statements into a method |
| `<Space>jef` | on an expression | extracts to a field (same flow, not tested separately) |

Extracting a whole statement or block into a method needs a selection, and the key is normal mode only:

1. Select with `v` (characterwise), for example `v$` on the `System.out.println(...)` line (tested; `V` linewise gave a worse result: only `System.out` was extracted).
2. Press `<Esc>` (the selection marks stay).
3. `<Space>jem`

Tested result:

```java
        extracted(total, label);
    }

    private static void extracted(int total, String label) {
        System.out.println(label + ": " + total);
    }
```

Pressing `<Space>jem` while the selection is still active does NOT work (visual mode has no such key; `<Space>ca` there would even run `c`, change, on the selection).

## 9. Snippets

Source: `my_snippets/java.snippets`. Type the trigger in insert mode in a Java buffer and expand it with `<Ctrl-j>` (section 15); `<Ctrl-j>` / `<Ctrl-k>` jump to the next / previous placeholder.

| Trigger | Result |
| --- | --- |
| `fdijscanner` | `package fondamentidiinformatica.X;`, the Scanner import and a class with `main` reading one line from `System.in` |
| `jarr` | `int[] arrayName = new int[size];` |
| `jarrlit` | `int[] arrayName = {value1, value2, value3};` |
| `jdict` | `HashMap<String, Integer> mapName = new HashMap<>();` |
| `jdictfull` | The same with `import java.util.HashMap;` and a `put(key, value)` line |
| `jfor` | `for (int i = 0; i < length; i++) { }` |
| `jforeach` | `for (String item : collection) { }` |
| `jwhile` | `while (condition) { }` |
| `jdowhile` | `do { } while (condition);` |
| `jif` | `if (condition) { }` |
| `jifelse` | `if ... else ...` |
| `jifelif` | `if ... else if ... else ...` |
| `jswitchtraditional` | Classic `switch` with `case`, `break`, `default` |
| `jswitchmulti` | Classic `switch`, several `case` labels per result (months to seasons) |
| `jswitcharrow` | `switch` with `case x -> result;` |
| `jswitcharrowmulti` | Arrow `switch`, several values per case |
| `jswitchyield` | Switch expression assigned to a variable |
| `jswitchyieldblock` | Switch expression with a `default -> { ...; yield ...; }` block |
| `jtrycatch` | `try { } catch (Exception e) { }` |
| `jtryfinally` | `try / catch / finally` |
| `jwhilescannerbreak` | `Scanner` loop that reads values until a stop value, then closes the scanner |

## 10. Windows While Running, Testing And Debugging

| Keys | What it does |
| --- | --- |
| `<Ctrl-w>h` `j` `k` `l` | Move between windows: code, the runner or test terminal at the bottom, the report |
| `<Left>` `<Down>` `<Up>` `<Right>` | The same with arrow keys (normal mode) |
| `<Esc>` first | In a terminal window press `<Esc>` to get to normal mode, then use a window key. `i` types in the terminal again |
| `<Space>q` | Save if modified and close the current window (use it in a runner, test or debug terminal) |
| `<Ctrl-w>o` | Keep only the current window |
| `<Esc>` in a float | Closes the report float, the Profiles window, `New Name` box and hover floats (section 7 lists `<Esc>` closing floats) |

See section 7 (windows) and the cheat sheet in section 2 for the same rows.

## 11. Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `<Space>j...` shows `Java: jdtls not attached (open nvim inside the Java devShell)` | `java` is not on PATH (not in the devShell) or jdtls has not finished starting | Quit, `cd` into the project, check `direnv allow` and `which java`, start nvim again; inside the devShell wait about 10 s and check `:LspAttached` |
| jdtls never attaches | Neovim started before direnv loaded; jdtls crashed | `:LspLog`, `:checkhealth vim.lsp`, `:edit` the file; check `which java` |
| Tests or debugger do not start, adapter not found | The devShell was not entered since the extensions were linked, or the links broke | Enter the project with direnv once (the shell hook relinks `~/.local/share/nvim/nvim-java/packages/java-debug-adapter/extension` and `java-test/extension`), restart nvim |
| `<Space>jrr` prints nothing | jdtls not finished importing, or the file is not under `src/main/java`, or no `main` method | Wait for the first import, `<Space>jbb`, then `<Space>jrr` again; a project that is its own git root and one nested in a bigger git repo both work |
| Old errors or deleted classes still shown | Stale jdtls workspace | `<Space>jbc` then Yes (jdtls restarts); if it stays wrong: `rm -r ~/.cache/nvim/jdtls/workspace` |
| A different, empty workspace appears after starting from another folder | The workspace folder name is a hash of the START folder of Neovim | Always start nvim in the same project folder |
| Test terminal shows no pass/fail | By design: results are in the report | `<Space>jtr` |
| First test run fails with a download error | Maven offline: JUnit jars not in `~/.m2`. Tested in a shell with an empty repo: `mvn -o test` stops with `Cannot access central (https://repo.maven.apache.org/maven2) in offline mode and the artifact org.apache.maven.plugins:maven-resources-plugin:jar:3.3.1 has not been downloaded from it before` | Connect once, run `<Space>jtc` again (or `mvn test` in a shell) |
| `Java version mismatch: JDTLS ... requires Java ...` | The JDK on PATH is too old or too new for jdtls 1.54.0 | Use the devShell JDK (25) |
| "release version N not supported" when compiling | `maven.compiler.release` in `pom.xml` is higher than the JDK | Lower it (the test project uses 21 on JDK 25) |
| `.java` file in a scratch folder: no Java features | No project root (no `pom.xml`, `.git`) | Create `pom.xml` or `git init` |
| Debugger does not stop | No breakpoint, or the breakpoint is on a line without code | `:DapToggleBreakpoint` on a code line, then `<Space>jtC` |
| `:DapStepInto` opens an empty `unknown` buffer | The step went into library code without source | `:DapStepOut`; step into your own methods only |
| `<Space>rn` or `<Space>ca` warn "no attached language server supports it" | Only typos_lsp attached, jdtls missing | Same as "jdtls never attaches" |
| Spelling squiggles on valid names | typos_lsp does not know the word | Put a `typos.toml` with `[default.extend-words]` in the project root |
| `.project`, `.classpath`, `.settings/` in `git status` | jdtls writes Eclipse files into the project | Add them to the project's `.gitignore` |
| Refactor made a mess | The edit was applied before the rename step | `u` twice, then redo |
| `<Space>jj` says `No configured runtimes available` | No `java.configuration.runtimes` set | Expected here; nothing to fix |


## Related Sections

Section 35 (Java keys), 54 (Java in depth), 36 and 56 (debugging), 19 and 55 (running code, `<Space>rr`), 13 (LSP), 14 (completion), 15 (snippets), 7 (windows), 8 (terminal), 20 (git; the git root decides the jdtls root), 2 (quick reference and cheat sheet).


---
