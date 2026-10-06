<!-- chapter: Git -->
[Back to the guide index](README.md)

# 20. Git integration

## vim-fugitive (plugin)

The fugitive keys (and the [gitlinker keys](#gitlinkernvim-plugin) below) exist only inside a git repository: nvim started in one, or a file of one opened. Outside a repository these keys are not mapped: `<Space>` just moves the cursor one column right and the next keys run as their normal Vim/plugin meaning (`<Space>gs` becomes `l` plus vim-swap's `gs`). `<Space>gbl` works everywhere (fzf-lua).

`<Space>gn` (Neogit) and `<Space>gD` (Diffview) belong to the same group: both are defined in `lua/config/fugitive.lua`, which loads together with fugitive when git is detected, so they exist only in a git repository too (once defined they stay for the rest of the session, even after `:cd` out of the repository). The plugins behind them are not repo-limited: `:Neogit` and `:DiffviewOpen` load on demand from any directory (Neogit itself still needs a repository to show anything).

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>gs` | n | Git status window |
| `<Space>gw` | n | Git add current file |
| `<Space>ga` | n | Git add all changes (whole repository: new, modified and deleted files, `git add -A`) |
| `<Space>gu` | n | Unstage the current file (`git restore --staged`) |
| `<Space>gx` | n | Discard the changes in the current file (`git restore`). Asks Yes/No first, the default is No |
| `<Space>gv` | n | Vertical diff of the current file against the index (`:Gvdiffsplit`) |
| `<Space>gL` | n | Git log of the current file (`:Git log --oneline -- %`) |
| `<Space>gc` | n | Git commit |
| `<Space>gA` | n | Amend the last commit (`:Git commit --amend`) |
| `<Space>gz` / `<Space>gZ` | n | Stash the changes / pop the stash (`:Git stash`, `:Git stash pop`) |
| `<Space>gm` / `<Space>gR` | n | Puts `:Git merge ` / `:Git rebase ` on the command line: type the rest and press Enter |
| `<Space>gn` | n | Open Neogit (`:Neogit`) |
| `<Space>gD` | n | Open Diffview (`:DiffviewOpen`) |
| `<Space>gp` | n | Git pull |
| `<Space>gP` | n | Git push (opens terminal split) |
| `<Space>gb` | x | Git blame selected lines |
| `<Space>gbn` | n | Create new branch (prompts for name) |
| `<Space>gbd` | n | Puts `:Git branch -D ` on the command line: type the branch name and press Enter (force delete) |
| `<Space>gf` | n | Puts `:Git fetch ` on the command line (add arguments, then Enter) |
| `<Space>gbl` | n | Fuzzy-search git branches and check one out (fzf-lua) |

Example: in a repository with one changed tracked file and one new file, `<Space>gs` opens the status window:

```
Head: main
Push: origin/main
Help: g?

Untracked (1)
? notes.txt

Unstaged (1)
M lua/mappings.lua
```

Close the window again with `gq`. `<Space>gw` in the `mappings.lua` buffer moves it from "Unstaged" to "Staged" (the header becomes `Staged (1)`), `<Space>gu` moves it back.

`<Space>gd`, `<Space>gr` and `<Space>gi` are not git keys: they are Glance (peek at definitions, references, implementations, see "[Peeking Without Jumping (Glance)](07-code.md#peeking-without-jumping-glancenvim)" in the code chapter). For a git diff use `<Space>gv`, for restoring use `<Space>gx`.

Clicking the branch name in the statusline also opens a branch picker (`git checkout` of the chosen local or remote branch).

## gitsigns.nvim (plugin)

Shows `+` `~` `_` signs in the gutter for added/changed/deleted lines.

The gitsigns keys exist only in buffers of git-tracked files. In any other buffer they are not mapped.

A **hunk** is a contiguous block of changed lines. With the hunk keys you can stage (or discard) just one part of a file instead of the whole file.

| Keymap | Mode | Description |
| --- | --- | --- |
| `]c` | n | Jump to next git change (hunk) |
| `[c` | n | Jump to previous git change |
| `<Space>hp` | n | Preview the hunk in a floating window |
| `<Space>hb` | n | Show git blame for current line |
| `<Space>hs` | n, x | Stage the hunk; in visual mode stages the selected lines |
| `<Space>hr` | n, x | Reset the hunk (discards the change). Asks Yes/No first, the default is No; in visual mode resets the selected lines |
| `<Space>hu` | n | Unstage the last staged hunk |
| `<Space>hS` | n | Stage the whole buffer |
| `<Space>hR` | n | Reset the whole buffer (discards all changes in the file). Asks Yes/No first |
| `<Space>hd` | n | Diff the file against the index |
| `<Space>ht` | n | Toggle showing deleted lines |

Example: compared with the last commit, `b = 2,` was changed to `b = 20,`, the line `d = 4,` was deleted and two lines were added at the end. The gutter shows:

```
   1  return {
   2    a = 1,
 ~ 3    b = 20,      <- changed line
 _ 4    c = 3,       <- one or more lines were deleted below this line
   5    e = 5,
 + 6    f = 6,       <- added line
 + 7    g = 7,       <- added line
   8  }
```

The cursor on the `b = 20,` line and `<Space>hs` stages only that hunk: `git diff --staged` then contains just the `b` change, while the deleted and added lines are still unstaged, and the sign of that hunk changes to `┃`. `<Space>hu` unstages it again. `<Space>hr` asks `Reset this hunk (discard the change)? (Y)es, [N]o:`; with `y` the line is `b = 2,` again.

## gitlinker.nvim (plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>gl` | n, x | Copy permalink for current line(s) |
| `<Space>gbr` | n | Open repository in browser |

Example (with the placeholder remote `https://github.com/user/repo.git`): select lines 3 to 5 of `lua/mappings.lua` (`Vjj`) and press `<Space>gl`; the link is
`https://github.com/user/repo/blob/<full commit hash>/lua/mappings.lua#L3-L5`.
The link needs the current commit to exist on the remote branch (the local `origin/<branch>` has to contain it): without that nothing is copied and no message appears.

## Neogit (plugin)

Neogit is a full-screen git interface in the style of Emacs Magit: one status buffer shows the branch, the unstaged and staged changes and recent commits, and short keys act on the item under the cursor. It uses diffview.nvim for diff views and fzf-lua for pickers; both load with it. It loads on its first command and needs a git repository to be useful.

| Key / command | Effect |
| --- | --- |
| `<Space>gn` | Open Neogit (`:Neogit`); the key exists only in a git repository, see the note at the top of [section 20](#20-git-integration) |
| `:Neogit` | Open the status buffer (a new tab) from any directory inside a repository |
| `:NeogitCommit [<sha>]` | Open the commit view of a commit (`HEAD` when no argument) |
| `:NeogitLogCurrent [<file>]` | Log of a file (the current file when no argument; with a visual range, the history of those lines) |
| `:NeogitResetState` | Reset the flags Neogit remembers for its popups |

Inside the status buffer the keys are Neogit's own defaults (this config does not change them; see `:help neogit`): `?` opens a popup that lists the available keys, `s` stages and `u` unstages the item under the cursor, `x` discards it (with a confirmation), `<Tab>` folds or unfolds it, `<CR>` opens the file, `c` opens the commit popup, `q` closes the window. These keys were read from the plugin's help, not tried here.

## vim-flog (plugin)

vim-flog shows the history of the repository as a graph: one line per commit, with lines joining the branches and merges. It is a viewer; commits themselves are made with fugitive.

| Command / key | Effect |
| --- | --- |
| `:Flog` | Open the commit graph of the current repository in a new tab (the first run asks git to write a commit-graph file) |
| `g?` (inside Flog) | Show Flog's own list of keys |
| `<CR>` (inside Flog) | Open the commit under the cursor in a side window |
| `dd` (inside Flog) | Diff the commit under the cursor against the current `HEAD` |
| `u` (inside Flog) | Reload the graph |
| `gq` or `ZZ` (inside Flog) | Quit Flog |

Example (a merge of two branches, hashes shortened):

```
   • [0ed345a] (HEAD -> main) Merge branch 'feature'
 1 ├─╮
 2 │ • [4bf2d52] (feature) feature b
 3 • │ [3c36aff] main b
 4 ├─╯
 5 • [fe7ed82] (origin/main) w2
 6 • [f3c1cbb] wip
```

Each row also shows the date and the author; the lines on the left are the branches and the merge.

There is no key for `:Flog` in this config. Flog requires vim-fugitive (it is a documented prerequisite, and fugitive is loaded in a git repository), so open it inside a repository. Inside the Flog window any fugitive command can be used, and Flog's `gs` / `gu` / `gU` (show staged / untracked / unstaged changes) apply there instead of vim-swap's `gs`. The in-window keys are the plugin's defaults from its help (`:help flog-mappings`), not tried here.

## diffs.nvim (plugin)

diffs.nvim makes diffs easier to read. It works on its own, without keys.

| What | Effect |
| --- | --- |
| Automatic highlighting | Code inside the diffs shown by fugitive, neogit and gitsigns gets syntax highlighting, with intra-line changes marked; the integrations are switched on in `lua/plugin_specs.lua` |
| Conflict markers | Inline merge conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) in working files are detected and highlighted; its resolve keymaps are off by default and this config does not turn them on (use the diffview keys above); diagnostics are switched off in a buffer while it has conflicts |
| `:Diff` | Diff of the current file against git. Without arguments it compares the index with the working file, so it shows unstaged changes only; `:Diff <revision>` (for example `HEAD~3` or a branch) compares the current file at that revision with the working file; `:Diff review` opens a review of the whole repository; `:vertical Diff` splits vertically |

This plugin is not fetched from GitHub but from forge.barrettruth.com. The argument forms of `:Diff` come from the plugin's help (`:help diffs.nvim-commands`) and were not tried here.

## codediff.nvim (plugin)

codediff.nvim shows two versions of a file side by side with VSCode-like highlighting of the changed words inside each line.

| Command | Effect |
| --- | --- |
| `:CodeDiff` | Open an explorer of the changed files of the repository; pick a file to see its side-by-side diff |
| `:CodeDiff <revision>` | Compare a branch, commit or `HEAD~N` with the working tree |
| `:CodeDiff <revision> <revision>` | Compare two revisions |
| `:CodeDiff --staged` | Only the changes in the git index |

There is no key for it in this config. The first use downloads a small native diff library (network needed once; `:CodeDiff install` does it explicitly). More forms exist (pull requests, history, other repositories): see the plugin's README. The forms above come from that README and were not tried here.

## Other Git tools

| Plugin | Command / Trigger | Description |
| --- | --- | --- |
| neogit | `:Neogit` | Full git UI (magit-like; loads on the first `:Neogit*` command, in any directory; also `:NeogitCommit`, `:NeogitLogCurrent`, `:NeogitResetState`) |
| diffview.nvim | `:DiffviewOpen`, `:DiffviewFileHistory` (`:DiffviewClose` once a view was opened) | Side-by-side diff viewer and 3-way merge tool; file history panel |
| vim-flog | `:Flog` | Visual git log graph |
| diffs.nvim | `:Diff` (and automatic) | Unified diff of the current file against the index (unstaged changes; details in its section above); also colours the diffs shown by fugitive, neogit and gitsigns, and conflict markers |
| codediff.nvim | `:CodeDiff` | VSCode-style side-by-side diff (downloads a small native library on first use) |

## Resolving merge conflicts (diffview.nvim)

During a merge, `:DiffviewOpen` opens the 3-way merge tool. Inside a diffview view:

| Keymap | Description |
| --- | --- |
| `<Space>gCo` / `<Space>gCt` | Choose OURS / THEIRS for the conflict |
| `<Space>gCb` / `<Space>gCa` | Choose BASE / BOTH |
| `]C` / `[C` | Next / previous conflict (capital C; `]c` / `[c` stay the gitsigns hunk keys) |

Example (`main` and `feature` both changed the line `b = 2,`): `:DiffviewOpen` shows OURS and THEIRS side by side at the top and the working file (LOCAL) below, with the conflict markers in it. In the LOCAL window `]C` jumps to the conflict, then:

```
<<<<<<< HEAD                 <Space>gCo (ours)    <Space>gCt (theirs)    <Space>gCa (both)
  b = "ours",                  b = "ours",          b = "theirs",          b = "ours",
=======                                                                    b = "theirs",
  b = "theirs",
>>>>>>> feature
```

`<Space>gCb` (BASE) gives the part between the `|||||||` and `=======` markers; with git's default conflict style that part does not exist, so the conflicting lines simply disappear. `u` undoes a choice.

`<Space>cb` and `<Space>ca` keep their normal meaning inside diffview. fugitive's `:Gvdiffsplit!` is the other way to resolve a conflict.

---

# 48. Git workflow in depth

## The Git plugin ecosystem

This config includes several git-related plugins that each handle a different aspect:

| Plugin | What it does | How to use |
| --- | --- | --- |
| **vim-fugitive** | Run git commands from inside Neovim. The core git plugin. | `<Space>gs` for status, `<Space>gc` for commit, etc. |
| **gitsigns.nvim** | Shows which lines changed in the gutter. Navigate between changes. | `]c` / `[c` to jump between hunks, `<Space>hp` to preview. |
| **gitlinker.nvim** | Generate shareable URLs to specific lines of code. | `<Space>gl` to copy a permalink. |
| **neogit** | A full git UI inside Neovim (like Magit for Emacs). | `:Neogit` to open (loads on that command; also `:NeogitCommit`, `:NeogitLogCurrent`, `:NeogitResetState`). |
| **diffview.nvim** | Side-by-side diff viewer for comparing branches, commits, etc. | `:DiffviewOpen` to open. |
| **vim-flog** | Visual git log/graph showing branch history. | `:Flog` to open. |
| **diffs.nvim** | Syntax highlighting inside the diffs of fugitive, neogit and gitsigns; conflict markers. `:Diff` shows the file against the index. | Automatic, `:Diff`. |
| **codediff.nvim** | VSCode-style side-by-side diff. | `:CodeDiff`. |

Merge conflicts: `:DiffviewOpen` is the merge tool (keys in [section 20](#20-git-integration), "[Resolving Merge Conflicts](#resolving-merge-conflicts-diffviewnvim)").

## Daily Git workflow

A typical workflow entirely from within Neovim:

1. **Check status**: `<Space>gs` opens the fugitive status window
2. **Stage**: `<Space>gw` stages the current file, `<Space>ga` stages everything in the repository, `<Space>hs` stages only the hunk under the cursor (or use `s` in the status window); `<Space>gu` unstages the current file
3. **Review changes**: `<Space>hp` to preview hunks, or `]c`/`[c` to navigate between them
4. **Commit**: `<Space>gc` opens a commit message buffer. Write message, then `:wq`
5. **Push**: `<Space>gP` pushes (opens a terminal split showing progress)
6. **Pull**: `<Space>gp` pulls latest changes
   (`<Space>gz` stashes your changes first, `<Space>gZ` pops the stash)
7. **Blame**: Select lines in visual mode, then `<Space>gb` to see who wrote them
8. **Create branch**: `<Space>gbn` prompts for a branch name
9. **Share code**: `<Space>gl` copies a permalink to the current line

## Understanding gitsigns.nvim

The gutter signs mean:
- `+` : This line was **added** (new code)
- `~` : This line was **modified** (changed from last commit)
- `_` : A line was **deleted below** this line
- `‾` : A line was **deleted above** this line
- `│` : This line has both additions and deletions (change-delete)

**Hunk navigation**: `]c` jumps to the next changed block (hunk), `[c` jumps to the previous. This is very useful during code review.

---
