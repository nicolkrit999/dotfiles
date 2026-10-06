<!-- chapter: Nix -->
[Back to the guide index](../README.md)

# 86. Nix (snippets and delib modules)

This chapter covers the custom Nix snippets (file `my_snippets/nix.snippets`, 12 snippets) and the few things the config does for `.nix` files. Only what is stated in "[What you get](#what-you-get)" has been checked in the config. The delib explanation below comes from the session that wrote the snippets, which checked it against the denix source (`lib/configurations/module.nix`) and the NixOS and home-manager option search; it is not re-checked here.

## What you get

| Feature | What it does | Needs |
| --- | --- | --- |
| **nixd** (language server) | The main language server of `nix` buffers: diagnostics, completion, hover, go to definition ([section 44](../07-code.md#44-language-server-protocol-lsp-in-depth)). Started with `--log=error` | `nixd` on PATH ([section 44](../07-code.md#44-language-server-protocol-lsp-in-depth); the nix devShell, [section 43](../07-code.md#43-how-the-development-toolchain-fits-together), has it) |
| **Format file** (`<Space>fm`, and every `:w`) | Runs `nixfmt` through conform.nvim (see [Formatting (conform.nvim)](../07-code.md#formatting-conformnvim)). Without `nixfmt` the LSP formatter of nixd runs instead; the formatter command set for nixd is `nixpkgs-fmt` | `nixfmt` on PATH (nix devShell); otherwise `nixd` attached and `nixpkgs-fmt` on PATH |
| **Word highlight** | In `.nix` files only the identical word is highlighted (text matching or Tree-sitter), because nixd would mark every package of a `with pkgs; [ ... ]` list ([section 3](../02-navigation.md#3-core-navigation-moving-without-the-mouse), "[Word references](../02-navigation.md#word-references-vim-illuminate)") | Nothing |
| **Comments** | The smart comment plugin knows Nix: `#` line comments, `/* */` blocks and `'' ''` strings | Nothing |
| **Line-length marker** | The coloured column marker sits at column 100 for Nix ([section 41](../10-various.md#41-filetype-specific-settings)) | Nothing |
| **Tree-sitter** | Grammars on Nix systems come from the nix store ([section 21](../07-code.md#21-treesitter--text-objects), [section 46](../07-code.md#46-treesitter-in-depth-nvim-treesitter)) | Nothing extra |
| **Snippets** | See [Snippets](#snippets) below | Nothing |

Not stated here because the config does not show it: a Nix filetype plugin under `after/ftplugin` (there is none), any Nix-specific key, and any use of `statix` by the config. The formatter setting for nixd names `nixpkgs-fmt`; conform.nvim prefers `nixfmt` when it is installed.

## The Nix devShell

A Nix devShell already exists and `:DevEnv` already supports it; nothing has to be added to the Nix repo. The template is `~/nix/templates/krit/dev-environments/language-specific/nix/flake.nix` (description "A Nix-flake-based Nix development environment", systems `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`). Its default devShell is `pkgs.mkShellNoCC` with this package list:

```nix
packages = with pkgs; [
  nixd cachix lorri nh niv nixfmt statix vulnix
  haskellPackages.dhall-nix
  inputs.nix-tests.packages.${system}.default
];
```

The last entry is the `nix-tests` flake package (`github:danielefongo/nix-tests`). The guide names the tools and does not describe what each one does, except `nixd` (the language server, see above); [section 43](../07-code.md#43-how-the-development-toolchain-fits-together) lists the same packages in its devShell table.

Which of these the config uses: `nixd` (`lua/config/lsp.lua`: `cmd = { "nixd", "--log=error" }`, formatter `nixpkgs-fmt`) and `nixfmt` (run by conform.nvim for formatting). The config does not call `statix` or the others.

How to enter it, as for the other languages ([section 43](../07-code.md#43-how-the-development-toolchain-fits-together)):

- **In a running Neovim:** `:DevEnv nix` then `<CR>`. `:DevEnv` lists every sub-folder of its base folder (default `~/nix/templates/krit/dev-environments/language-specific`, changeable with `vim.g.devenv_base` or `$NVIM_DEVENV_BASE`) that holds a `flake.nix`, so `nix` is offered automatically (press `<Tab>` after `:DevEnv `). It adds the programs to `PATH` for this session only.
- **With direnv in a project:** the other chapters use one line in the project's `.envrc`, `use_dev_env <name>`; for this devShell that would be `use_dev_env nix` (same mechanism, `direnv allow` once, start Neovim from that shell).

Honest limit: only the flake file was read; whether it builds was not checked.

## What delib is

The author's Nix configuration uses the **denix** module library, called **delib** in the code. These notes explain it in plain words, because the `delibmodule` and `delibalways` snippets create delib modules.

Every `.nix` file under the configured paths is a **delib module**, written like this:

```nix
delib.module {
  name = ...;
  options = ...;
  <target>.<mode> = ...;
}
```

- `name` is a dotted path into the `myconfig` option tree. `"programs.bat"` means `myconfig.programs.bat`.
- `options` declares what that path contains.
- Each `<target>.<mode>` block is a piece of configuration that is applied only when its condition holds.

**Target** (what kind of configuration the block produces). Nothing else is valid:

| Target | Meaning |
| --- | --- |
| `nixos` | System-level NixOS options (ignored on macOS) |
| `darwin` | System-level nix-darwin options (ignored on NixOS) |
| `home` | home-manager options for the user (works on both systems) |
| `myconfig` | Sets values in the repo's own `myconfig.*` option tree, for example constants |

**Mode** (when the block is applied). Nothing else is valid:

| Mode | Meaning |
| --- | --- |
| `ifEnabled` | Only when `myconfig.<name>.enable` is true |
| `ifDisabled` | Only when it is false (rare) |
| `always` | Unconditionally |

**Arguments of a block.** `cfg` is the module's own option subtree, `myconfig.<name>` (so `cfg.enable`). `myconfig` is the whole option tree (read constants such as `myconfig.constants.theme`). Two more arguments exist, `name` and `parent`, but they are rarely needed. The block can be a plain attribute set or a function `{ cfg, myconfig, ... }: { ... }`; take only the arguments you use. `pkgs`, `lib` and `config` also work. `pkgs` is not added to the delib function arguments on purpose: add `pkgs` to the argument set when you need it.

**Why `options` exists for `ifEnabled` and `ifDisabled`.** delib decides "enabled" by reading `cfg.enable`. If the module declares no `enable` option, `ifEnabled` and `ifDisabled` blocks are silently never applied (no error). So for `ifEnabled` the enable option is required; the shortest form is `options = delib.singleEnableOption <default>;`. For `always` it is not needed. A host switches a module on with `myconfig.programs.bat.enable = true;`.

**Examples of the combinations.**

- `home.ifEnabled`: a program setting that exists only when the module is switched on, via home-manager, on both NixOS and macOS.
- `nixos.always`: system configuration that must always apply on NixOS with no switch (it decides internally with `lib.mkIf`).
- Others: `darwin.ifEnabled`, `home.always`. One module can contain several blocks, for example `nixos.ifEnabled` and `home.ifEnabled`.

## Snippets

Source: `my_snippets/nix.snippets` (12 snippets). Type the trigger in insert mode in a Nix buffer and expand it with `<Ctrl-j>` ([section 15](../04-completion-snippets.md#15-snippets-ultisnips)); `<Ctrl-j>` / `<Ctrl-k>` jump to the next / previous placeholder. The text in quotes after each trigger below is its description exactly as the completion menu shows it. Every snippet is a "start of line" snippet (UltiSnips option `b`): it expands only at the beginning of a line. Placeholders are shown in tab-stop order; after the last one the cursor leaves the block (`$0`, or the end of the text). A compact trigger list is in [`04-completion-snippets.md` ("Other snippets")](../04-completion-snippets.md#other-snippets).

Two things apply to all of them:

- The snippets indent with tabs. The repo's Nix files use 2 spaces; the formatter (`<Space>fm`, or saving with `:w`) reindents them.
- Where a snippet uses `pkgs`, it must be in scope (a function argument such as `{ pkgs, ... }:`, or a `let` binding).

**Group: Package lists**

**`homepackages`**: "home-manager package list (home.packages; pkgs must be in scope)". The cursor ends inside the list.

```nix
home.packages = with pkgs; [
	package_names
];
```

**`systempackages`**: "NixOS system package list (environment.systemPackages; pkgs must be in scope)". The same for the system.

```nix
environment.systemPackages = with pkgs; [
	package_names
];
```

To remove an arbitrary package from `systemPackages` there is no option: just do not add it. home-manager has no `excludePackages` option.

**`excludepackages`**: "Exclude default desktop packages on NixOS (desktop: gnome|plasma6|cosmic|cinnamon|budgie|enlightenment|lxqt|mate|pantheon|xfce)". The placeholder `desktop` is the name of the desktop environment.

```nix
environment.desktop.excludePackages = with pkgs; [
	package_names
];
```

Example: `desktop` = `gnome` gives `environment.gnome.excludePackages = with pkgs; [ ... ];`. The valid desktops are `gnome`, `plasma6`, `cosmic`, `cinnamon`, `budgie`, `enlightenment`, `lxqt`, `mate`, `pantheon` and `xfce`. `services.xserver.excludePackages` is the odd one out and is not covered by the snippet.

**Group: delib modules**

Read "[What delib is](#what-delib-is)" above first. Both snippets produce a complete module and leave a valid file (the closing `};` and `}` are included). The first line `{ delib, ... }:` is the argument set of the file.

**`delibmodule`**: "delib module with an enable switch (target: nixos|darwin|home|myconfig; mode: ifEnabled|ifDisabled)". A module that has an `enable` option, so an `ifEnabled` block works. Placeholders: `module_path` (the dotted `name`, for example `programs.bat`), `default_enabled` (`true` or `false`), `target` (`nixos`, `darwin`, `home` or `myconfig`), `mode` (`ifEnabled` or `ifDisabled`), then the body.

```nix
{ delib
, ...
}:
delib.module {
	name = "module_path";
	options = delib.singleEnableOption default_enabled;

	target.mode =
		{ cfg
		, myconfig
		, ...
		}:
		{
			body
		};
}
```

Example: `programs.bat`, `false`, `home`, `ifEnabled` gives `name = "programs.bat";`, `options = delib.singleEnableOption false;` and `home.ifEnabled = ...`. A host then enables it with `myconfig.programs.bat.enable = true;`. The body is the attribute set of home-manager options, for example `programs.bat.enable = true;`.

**`delibalways`**: "delib module applied unconditionally, no enable switch (target: nixos|darwin|home|myconfig)". A module with no `enable` option; its block is always applied and the mode is fixed to `always`. Placeholders: `module_path`, `target`, then the body. Only `myconfig` is in the argument set; add `cfg`, `pkgs` or `lib` when you need them.

```nix
{ delib
, ...
}:
delib.module {
	name = "module_path";

	target.always =
		{ myconfig
		, ...
		}:
		{
			body
		};
}
```

Example: `target` = `nixos` gives `nixos.always = ...`. Because there is no switch, decide inside the body with `lib.mkIf` when the config depends on a condition.

**Group: Language building blocks**

**`let`**: "let ... in block". The body of the `let` first, then the expression after `in`.

```nix
let
	bindings
in
	expression
```

**`mkshell`**: "mkShell development environment (packages = tools, shellHook = commands run on entry)". Needs `pkgs` in scope. `packages` is preferred over `buildInputs` for dev-shell tools.

```nix
pkgs.mkShell {
	packages = with pkgs; [
		tools
	];

	shellHook = ''
		commands
	'';
}
```

**`mkderiv`**: "stdenv.mkDerivation (buildInputs = libraries, nativeBuildInputs = build tools)". Needs `pkgs` in scope. `buildInputs` are libraries, `nativeBuildInputs` are build tools. The install phase is wrapped in `runHook preInstall` and `runHook postInstall`; the last placeholder is between them.

```nix
pkgs.stdenv.mkDerivation {
	pname = "name";
	version = "version";

	src = source;

	buildInputs = with pkgs; [
		libraries
	];

	nativeBuildInputs = with pkgs; [
		build_tools
	];

	installPhase = ''
		runHook preInstall
		install_commands
		runHook postInstall
	'';
}
```

Example: `name` = `hello`, `version` = `1.0`, `source` = `./.`.

**`fetchgithub`**: "fetchFromGitHub boilerplate (hash: use pkgs.lib.fakeHash first, then paste the hash from the error)". Needs `pkgs` in scope. The hash is **unquoted** `pkgs.lib.fakeHash` on purpose: a quoted hash would be a literal string and fail with "invalid SRI hash". Build once, then copy the real hash from the error message (`got: sha256-...`) and replace `pkgs.lib.fakeHash` with it as a quoted string (an empty `""` also works for the first build).

```nix
src = pkgs.fetchFromGitHub {
	owner = "owner";
	repo = "repo";
	rev = "commit_or_tag";
	hash = pkgs.lib.fakeHash;
};
```

Example: `owner` = `octocat`, `repo` = `hello-world`, `rev` = `v1.0`.

**Group: Files and flakes**

**`flake`**: "Basic flake.nix boilerplate (system: x86_64-linux|aarch64-linux|x86_64-darwin|aarch64-darwin)". Placeholders: `description`, `channel` (a nixpkgs branch such as `nixos-unstable`, or a stable `nixos-YY.MM`), `system` (one of `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`). The snippet source writes `\${system}`; the backslash is intentional and the expansion contains a plain `${system}`.

```nix
{
	description = "description";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=channel";
	};

	outputs = { self, nixpkgs, ... }@inputs:
	let
		system = "system";
		pkgs = nixpkgs.legacyPackages.${system};
	in
	{
		outputs
	};
}
```

Example: `channel` = `nixos-unstable`, `system` = `x86_64-linux`.

**`homefile`**: "home.file that generates a text file, path relative to $HOME (a literal ${ inside '' '' must be written ''${)". A home-manager file with literal text. The path is relative to `$HOME`; under `~/.config` `xdg.configFile."..."` is the better choice. Inside the indented string a literal `${` must be written `''${`, because `${` otherwise starts an interpolation.

```nix
home.file."file_path" = {
	text = ''
		content
	'';
};
```

Example: `file_path` = `.config/foo/foo.conf`.

**Group: NixOS services**

**`systemd`**: "NixOS systemd service (restart_policy: no|on-success|on-failure|on-abnormal|on-watchdog|on-abort|always)". Placeholders: `service_name`, `description`, `command` (becomes `ExecStart`), `restart_policy`, `user`. The valid restart policies are `no`, `on-success`, `on-failure`, `on-abnormal`, `on-watchdog`, `on-abort` and `always`. The cursor ends after the block.

```nix
systemd.services.service_name = {
	description = "description";
	wantedBy = [ "multi-user.target" ];
	after = [ "network.target" ];

	serviceConfig = {
		ExecStart = "command";
		Restart = "restart_policy";
		User = "user";
	};
};
```

Example: `service_name` = `backup`, `command` = `/run/current-system/sw/bin/true`, `restart_policy` = `on-failure`, `user` = `root`.

This is NixOS only. Inside a delib module put it in a `nixos.*` block. home-manager user services have a different shape and there is no snippet for them:

```nix
systemd.user.services.name = {
	Unit = { Description = "..."; };
	Service = { ExecStart = "..."; };
	Install.WantedBy = [ "default.target" ];
};
```

## Related sections

Section [15](../04-completion-snippets.md#15-snippets-ultisnips) and [52](../04-completion-snippets.md#52-snippets-for-developers-ultisnips) (snippets), [3](../02-navigation.md#3-core-navigation-moving-without-the-mouse) (word references, in the navigation chapter), [41](../10-various.md#41-filetype-specific-settings) (filetype settings), [43](../07-code.md#43-how-the-development-toolchain-fits-together) (toolchain and devShells), [44](../07-code.md#44-language-server-protocol-lsp-in-depth) (language server in depth), [78](java.md#78-java-nvim-java-jdtls-tests-debugging) (Java chapter, [section 9](java.md#9-snippets) has the same snippet layout).
