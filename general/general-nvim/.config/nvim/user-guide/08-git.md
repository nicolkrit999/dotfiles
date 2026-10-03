<!-- chapter: Git -->
[Back to the guide index](README.md)

# 20. Git Integration

## vim-fugitive (Plugin)

The fugitive keys (and the gitlinker keys below) exist only inside a git repository: nvim started in one, or a file of one opened. Outside a repository these keys are not mapped: `<Space>` just moves the cursor one column right and the next keys run as their normal Vim/plugin meaning (`<Space>gs` becomes `l` plus vim-swap's `gs`). `<Space>gbl` works everywhere (fzf-lua).

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>gs` | n | Git status window |
| `<Space>gw` | n | Git add current file |
| `<Space>gc` | n | Git commit |
| `<Space>gpl` | n | Git pull |
| `<Space>gpu` | n | Git push (opens terminal split) |
| `<Space>gb` | x | Git blame selected lines |
| `<Space>gbn` | n | Create new branch (prompts for name) |
| `<Space>gbd` | n | Puts `:Git branch -D ` on the command line: type the branch name and press Enter (force delete) |
| `<Space>gf` | n | Puts `:Git fetch ` on the command line (add arguments, then Enter) |
| `<Space>gbl` | n | Fuzzy-search git branches and check one out (fzf-lua) |

Clicking the branch name in the statusline also opens a branch picker (`git checkout` of the chosen local or remote branch).

## gitsigns.nvim (Plugin)

Shows `+` `~` `_` signs in the gutter for added/changed/deleted lines.

| Keymap | Description |
| --- | --- |
| `]c` | Jump to next git change (hunk) |
| `[c` | Jump to previous git change |
| `<Space>hp` | Preview the hunk in a floating window |
| `<Space>hb` | Show git blame for current line |

## gitlinker.nvim (Plugin)

| Keymap | Mode | Description |
| --- | --- | --- |
| `<Space>gl` | n, x | Copy permalink for current line(s) |
| `<Space>gbr` | n | Open repository in browser |

## Other Git Tools

| Plugin | Command / Trigger | Description |
| --- | --- | --- |
| neogit | `:Neogit` | Full git UI (magit-like; loads on the first `:Neogit*` command, in any directory; also `:NeogitCommit`, `:NeogitLogCurrent`, `:NeogitResetState`) |
| diffview.nvim | `:DiffviewOpen`, `:DiffviewFileHistory` (`:DiffviewClose` once a view was opened) | Side-by-side diff viewer and 3-way merge tool; file history panel |
| vim-flog | `:Flog` | Visual git log graph |
| diffs.nvim | `:Diff` (and automatic) | Unified diff of the current file against git; also colours the diffs shown by fugitive, neogit and gitsigns, and conflict markers |
| codediff.nvim | `:CodeDiff` | VSCode-style side-by-side diff (downloads a small native library on first use) |

## Resolving Merge Conflicts (diffview.nvim)

During a merge, `:DiffviewOpen` opens the 3-way merge tool. Inside a diffview view:

| Keymap | Description |
| --- | --- |
| `<Space>gCo` / `<Space>gCt` | Choose OURS / THEIRS for the conflict |
| `<Space>gCb` / `<Space>gCa` | Choose BASE / BOTH |
| `]C` / `[C` | Next / previous conflict (capital C; `]c` / `[c` stay the gitsigns hunk keys) |

`<Space>cb` and `<Space>ca` keep their normal meaning inside diffview. fugitive's `:Gvdiffsplit!` is the other way to resolve a conflict.

---

# 48. Git Workflow In Depth

## The Git Plugin Ecosystem

This config includes several git-related plugins that each handle a different aspect:

| Plugin | What it does | How to use |
| --- | --- | --- |
| **vim-fugitive** | Run git commands from inside Neovim. The core git plugin. | `<Space>gs` for status, `<Space>gc` for commit, etc. |
| **gitsigns.nvim** | Shows which lines changed in the gutter. Navigate between changes. | `]c` / `[c` to jump between hunks, `<Space>hp` to preview. |
| **gitlinker.nvim** | Generate shareable URLs to specific lines of code. | `<Space>gl` to copy a permalink. |
| **neogit** | A full git UI inside Neovim (like Magit for Emacs). | `:Neogit` to open (loads on that command; also `:NeogitCommit`, `:NeogitLogCurrent`, `:NeogitResetState`). |
| **diffview.nvim** | Side-by-side diff viewer for comparing branches, commits, etc. | `:DiffviewOpen` to open. |
| **vim-flog** | Visual git log/graph showing branch history. | `:Flog` to open. |
| **diffs.nvim** | Syntax highlighting inside the diffs of fugitive, neogit and gitsigns; conflict markers. `:Diff` shows the file against git. | Automatic, `:Diff`. |
| **codediff.nvim** | VSCode-style side-by-side diff. | `:CodeDiff`. |

Merge conflicts: `:DiffviewOpen` is the merge tool (keys in section 20, "Resolving Merge Conflicts").

## Daily Git Workflow

A typical workflow entirely from within Neovim:

1. **Check status**: `<Space>gs` opens the fugitive status window
2. **Stage a file**: `<Space>gw` stages the current file (or use `s` in the status window)
3. **Review changes**: `<Space>hp` to preview hunks, or `]c`/`[c` to navigate between them
4. **Commit**: `<Space>gc` opens a commit message buffer. Write message, then `:wq`
5. **Push**: `<Space>gpu` pushes (opens a terminal split showing progress)
6. **Pull**: `<Space>gpl` pulls latest changes
7. **Blame**: Select lines in visual mode, then `<Space>gb` to see who wrote them
8. **Create branch**: `<Space>gbn` prompts for a branch name
9. **Share code**: `<Space>gl` copies a permalink to the current line

## Understanding Gitsigns

The gutter signs mean:
- `+` : This line was **added** (new code)
- `~` : This line was **modified** (changed from last commit)
- `_` : A line was **deleted below** this line
- `‾` : A line was **deleted above** this line
- `│` : This line has both additions and deletions (change-delete)

**Hunk navigation**: `]c` jumps to the next changed block (hunk), `[c` jumps to the previous. This is very useful during code review.

---
