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
| `aytordev.colorscheme` | enum | `"kanagawa"` | Colorscheme. |
| `aytordev.style` | enum | `"wave"` | Colorscheme style. |
| `aytordev.transparent` | boolean | `false` | Transparent background. |
| `aytordev.plugins.<name>` | boolean | `true` | Enable an individual plugin module. |

Clipboard accepts `unnamedplus`, `unnamed`, or `none`. On Linux, the wrapper
includes the selected `wl-copy`, `xclip`, or `xsel` providers; no host-installed
provider is required. Selecting `none` disables clipboard integration and its
providers.

Colorscheme accepts `kanagawa` or `none`. The supported Kanagawa styles are
`wave`, `dragon`, and `lotus`; `style` and `transparent` only affect Kanagawa.
The editor uses the native clipboard provider available on macOS.

## Advanced nvf Configuration

The `aytordev.*` options are the stable public interface. Advanced consumers
can also add nvf settings directly:

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
require `lib.mkForce`.

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
also add an LSP server, formatter, or diagnostics tool.

Select an exact language set through Home Manager:

```nix
aytordev.languages = ["nix" "lua" "rust"];
```

The `core` package enables only Nix and Lua:

```bash
nix run github:aytordev/aytordev.nvim#core
```

## Plugins

Plugin modules are discovered automatically from `modules/nvf/plugins/`. Every
plugin is enabled by default and exposed under `aytordev.plugins` using its
directory name. Available names are:

- `autopairs`
- `blink-cmp`
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
- `surround`
- `todo-comments`
- `treesitter`
- `which-key`
- `zen-mode`

Disable any combination through Home Manager:

```nix
aytordev.plugins = {
  dropbar = false;
  neo-tree = false;
  zen-mode = false;
};
```

Disabling a plugin also removes its plugin-specific keymaps. The `keymaps`,
`languages`, and `lsp` directories are infrastructure modules and therefore do
not have entries under `aytordev.plugins`.

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
| `modules/nvf/plugins/` | One module per plugin or capability. |
| `flake/packages/` | Standalone package output. |
| `overlays/` | Packages built against a consumer's nixpkgs. |
| `flake/home-manager/` | Home Manager integration and option bridge. |
| `flake/checks/` | Build, integration, and runtime checks. |

Directories under `modules/nvf/plugins/` are imported automatically.
