# Configuration Reference

This page documents the public configuration and the most important editor
bindings. See the project [README](../README.md) for installation.

## Options

The Home Manager module exposes these options at the top-level `aytordev`
namespace.

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `aytordev.viAlias` | boolean | `true` | Alias `vi` to Neovim. |
| `aytordev.vimAlias` | boolean | `true` | Alias `vim` to Neovim. |
| `aytordev.tabWidth` | positive integer | `2` | Set indentation width. |
| `aytordev.clipboard` | enum | `"unnamedplus"` | Clipboard mode. |
| `aytordev.clipboardProviders` | list | Linux: `["wl-copy" "xclip"]` | Linux clipboard providers to include. |
| `aytordev.languages` | list | All supported | Enabled languages. |
| `aytordev.format` | boolean | `true` | Per-language formatters and format on save. |
| `aytordev.extraDiagnostics` | boolean | `true` | Per-language linters and extra diagnostics. |
| `aytordev.colorscheme` | enum | `"kanagawa"` | Colorscheme family: `kanagawa`, `catppuccin`, `sora`, or `none`. |
| `aytordev.style` | enum | `"wave"` | Variant of the selected colorscheme family. |
| `aytordev.transparent` | boolean | `false` | Transparent background. |
| `aytordev.plugins.<name>` | boolean | `true` | Enable an individual plugin module. |

Clipboard accepts `unnamedplus`, `unnamed`, or `none`. On Linux, the wrapper
includes the selected `wl-copy`, `xclip`, or `xsel` providers; no host-installed
provider is required. Selecting `none` disables clipboard integration and its
providers.

Colorscheme accepts `kanagawa`, `catppuccin`, `sora`, or `none`. Valid styles
depend on the family: `wave`/`dragon`/`lotus` for Kanagawa,
`latte`/`frappe`/`macchiato`/`mocha` for Catppuccin, and `dark` for Sora.
`transparent` applies to all three families. The editor uses the native
clipboard provider available on macOS.

## Configuration Contract

The `aytordev.*` options are the stable public interface and are authoritative
for the features the distribution coordinates. Advanced consumers can also set
nvf options directly:

```nix
programs.nvf.settings.vim = {
  options = {
    relativenumber = true;
    scrolloff = 4;
  };
  lsp.formatOnSave = false;
  utility.surround.enable = false;
};
```

Distro opinions managed through nvf are defaults, so these overrides do not
require `lib.mkForce`. Direct nvf options keep following nvf's own rules,
dependencies, and defaults.

Some distro features span several nvf options, so disabling them through a
single nvf option can conflict. Treesitter is one example: every enabled
language turns its grammar on, so this override conflicts with the language
set:

```nix
# Conflicts with the enabled languages.
programs.nvf.settings.vim.treesitter.enable = false;
```

Use the public toggle instead, which coordinates the whole feature:

```nix
aytordev.plugins.treesitter = false;
```

An explicit nested value can override the public default when necessary:

```nix
programs.nvf.settings.aytordev.tabWidth = 4;
```

## Languages

The default package enables:

- Bash
- Go
- HTML
- JSON
- Lua
- Markdown
- Nix
- Python
- Rust
- TOML
- TypeScript
- YAML

Each nvf language module provides its associated Treesitter grammar and may
also add an LSP server, formatter, or diagnostics tool. Formatters and extra
diagnostics are enabled for every selected language by default; disable them
globally with `aytordev.format` or `aytordev.extraDiagnostics`.

Select an exact language set through Home Manager:

```nix
aytordev.languages = ["nix" "lua" "rust"];
```

The `core` package enables only Nix and Lua:

```bash
nix run github:aytordev/aytordev.nvim#core
```

## Plugins

Plugin configuration fragments are discovered automatically from
`modules/nvf/plugins/`. The loader derives the option name from each directory
and guards the complete fragment behind that option. Every plugin is enabled by
default and exposed under `aytordev.plugins`. Available names are:

<!-- plugin-list:start -->
- `autopairs`
- `blink-cmp`
- `catppuccin`
- `diffview`
- `dropbar`
- `flash`
- `gitsigns`
- `goto-preview`
- `grug-far`
- `harpoon`
- `incline`
- `kanagawa`
- `lualine`
- `mini-ai`
- `mini-hipatterns`
- `mini-icons`
- `neo-tree`
- `noice`
- `oil`
- `snacks`
- `sora`
- `surround`
- `todo-comments`
- `treesitter`
- `which-key`
- `zen-mode`
<!-- plugin-list:end -->

Disable any combination through Home Manager:

```nix
aytordev.plugins = {
  dropbar = false;
  neo-tree = false;
  zen-mode = false;
};
```

Disabling a plugin also removes its plugin-specific keymaps. Language and LSP
infrastructure live outside the discovered plugin collection and therefore do
not have entries under `aytordev.plugins`. Setting `aytordev.plugins.<name> =
false` removes the configuration fragment the distribution contributes for
that plugin; it does not prevent another module from enabling the plugin.

Plugin directory names map directly to public option names, so renaming a
directory also renames a public option. Treat these names as stable API, and
review whether a newly added plugin should be enabled by default.

## Editor Behavior

- Files changed on disk are reloaded automatically: every second, and when
  the terminal regains focus. Buffers with unsaved changes are left untouched.
- Neo-tree watches the filesystem, so files created, renamed, or deleted
  outside Neovim appear in the tree without a manual refresh.

## Keymaps

The leader and local leader keys are both `Space`.

| Key | Action |
| --- | --- |
| `<leader>e` | Toggle Neo-tree. |
| `-` | Open the parent directory with Oil. |
| `<leader>E` | Open Oil in a floating window. |
| `<leader><space>` or `<leader>ff` | Find files with Snacks. |
| `<leader>fg` or `<leader>/` | Search project text with Snacks. |
| `<leader>fb` | List open buffers. |
| `<leader>fr` | List recent files. |
| `<leader>fh` | Search help. |
| `<leader>pd` | Preview the LSP definition. |
| `<leader>pt` | Preview the LSP type definition. |
| `<leader>pi` | Preview the LSP implementation. |
| `<leader>pD` | Preview the LSP declaration. |
| `<leader>pr` | Preview LSP references when goto-preview and Snacks are enabled. |
| `<leader>pc` | Close all LSP preview windows. |
| `<leader>sr` | Open project-wide search and replace. |
| `<leader>gd` | Open Diffview. |
| `<leader>gh` | Open file history. |
| `<leader>gq` | Close Diffview. |
| `<leader>z` | Toggle Zen mode. |

Which-key exposes additional mappings provided by nvf modules such as
Gitsigns and Harpoon.

## Module Layout

| Path | Responsibility |
| --- | --- |
| `modules/aytordev/` | Public distro options. |
| `modules/nvf/options/` | Core editor and wrapper configuration. |
| `modules/nvf/plugins/` | Auto-discovered configuration fragment per plugin. |
| `modules/nvf/languages/` | Language support integration. |
| `modules/nvf/lsp/` | Shared LSP infrastructure. |
| `flake/packages/` | Standalone package output. |
| `overlays/` | Packages built against a consumer's nixpkgs. |
| `flake/home-manager/` | Home Manager integration and option bridge. |
| `flake/checks/` | Build, integration, and runtime checks. |

Directories under `modules/nvf/plugins/` are loaded automatically and guarded
by the option derived from their directory name.
