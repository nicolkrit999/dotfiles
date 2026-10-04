# Documenting plugins in the guide (two places, always)

Applies whenever a plugin is added, removed, renamed, enabled or disabled, or when a plugin is found that the guide does not cover. Followed by `nvim-guide-maintainer`, by `auditing-neovim-config` (as a check) and by whoever edits `plugin_specs.lua` (via the guide brief).

## The rule

Every plugin the config DECLARES needs BOTH, including conditional ones that are disabled on this machine (`enabled`/`cond`: vimtex and typst.vim need latex/typst on PATH, vim-xkbswitch is macOS only). `require("lazy").plugins()` alone is NOT the list: it omits disabled plugins, so the count changes with the environment. `build-pdf.py` uses `lazy.core.config` `spec.plugins` plus `spec.disabled`:

1. **A brief catalog entry** in `user-guide/11-plugins.md`, in the right category group (create a group, or a subsection inside a group such as Java, only when none fits): the plugin name, what it is and what it is used for in this config, and a clickable link to the in-depth section. Nothing more; no keys tables, no troubleshooting.
2. **An in-depth section** in a chapter YOU choose: extend the existing subsection that owns the topic first; otherwise add a subsection in the most fitting chapter or `languages/` file (find it through the README table of contents and file names, never from memory). Libraries and dependencies (plenary, devicons, promise-async, ...) need only a short "what these are" mention in the section the catalog links to.

Never decide that some plugins get in-depth coverage and others do not: a plugin without an in-depth section is a gap to fill, not a reason to skip the link.

## Catalog entry format (machine-checked)

One bullet per plugin, starting with the plugin name exactly as lazy.nvim names it, in backticks, then the description, then the link(s) (links may continue on following lines until the next bullet or heading):

```
- `plugin-name.nvim`: what it is and what it is used for here. In depth: [Section heading](NN-chapter.md#anchor)
```

**Startup label.** An entry of a plugin that is loaded in every session without any trigger (`lazy = false`, `event = "VeryLazy"`, a startup `BufEnter`, or a dependency of such a plugin) starts its description with `**Loaded at startup.**`; the intro of `11-plugins.md` explains the label. Plugins that need a trigger (key, command, filetype, git repo, Insert mode) get no label, so the absence of the label means "lazy". Do not add text about how each lazy plugin is triggered. Measure instead of guessing: `./measuring-startup-loaded-plugins.lua` (usage in its header). Colorscheme plugins are not labelled.

**Restriction wording.** Beyond the startup label, mention a loading condition only when it changes what the reader can do: a plugin restricted to a git repository (`event = "User InGitRepo"`: its keys do not exist outside one), to a file type (`ft`: "Only in Markdown files"), or enabled only on some machines (`enabled`/`cond`: "Only loaded when `latex` is on PATH", "macOS only"). One short sentence before "In depth:". Do not describe plain `cmd`, `keys` or generic event triggers.

**Declared but unverifiable plugins** (for example macOS-only ones on a Linux machine) still get a catalog entry and an in-depth section, written as a best effort from the spec and the plugin's documentation, with an explicit "Unverified" disclaimer in both places.

`11-plugins.md` also carries `<!-- plugin-count: N -->` with the current total. `build-pdf.py --check` FAILS when: a plugin has no entry; an entry has no link outside `11-plugins.md`; a link does not resolve; the linked section (heading plus its subsections) never mentions the plugin name; an entry names a plugin that is not in the config; or the count is wrong. So "every plugin has an in-depth description" is enforced, not a convention. Shared sections (colorschemes, libraries) are fine as long as each plugin is named inside them.

## Steps

1. Get the real plugin list and the facts: spec in `lua/plugin_specs.lua` or `lua/config/*.lua` (`enabled`, `cond`, `ft`, `cmd`, `keys`), its keymap `desc`s, its commands. Document only behavior you verified; never invent keys. Say so when a plugin is disabled or conditional.
2. Write or extend the in-depth section first (fix wrong text before adding; existing format; no renumbering; "tested" only because the user confirmed).
3. Add the catalog entry with a link to that section. Link form: relative `NN-name.md#anchor`, anchor per the slug rules of `build-pdf.py`.
4. Removed or renamed plugin: delete or rename its catalog entry and every guide mention in the same change.
5. `./build-pdf.py` then `./build-pdf.py --check` must print `OK`. `--check` compares `11-plugins.md` with that declared list and fails on a missing or extra plugin or a broken link; fix the markdown, never the PDF.
6. Report: the catalog entry (group), the in-depth section (file and heading), previous state, `--check` result. The count in the catalog (`<!-- plugin-count: N -->`) must match the new total.

## Audit view (for `auditing-neovim-config`)

Flag as MISSING a plugin that is absent from `11-plugins.md`, as WRONG a catalog entry for a plugin that no longer exists or whose description or link target is wrong, and as MISSING a catalog link that points at a section which does not actually explain the plugin. `lazy-lock.json` entries that lazy.nvim does not know are a separate stale-lockfile finding (report, do not edit).
