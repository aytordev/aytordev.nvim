# aytordev.nvim

A reproducible Neovim distribution built with [Nix](https://nixos.org/) and
[nvf](https://github.com/NotAShelf/nvf).

The flake provides a ready-to-run package and a Home Manager module with a
small `aytordev.*` configuration API. Plugins, language servers, formatters,
and command-line dependencies are pinned in `flake.lock`.

## Quick Start

Run the editor without installing it:

```bash
nix run github:aytordev/aytordev.nvim
```

Nix with flakes enabled is the only prerequisite.

Use the smaller Nix and Lua package when the full language set is unnecessary:

```bash
nix run github:aytordev/aytordev.nvim#core
```

## Home Manager

Add the flake to your inputs:

```nix
inputs.aytordev-nvim = {
  url = "github:aytordev/aytordev.nvim";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

Import the module from your Home Manager configuration:

```nix
{inputs, ...}: {
  imports = [
    inputs.aytordev-nvim.homeManagerModules.aytordev
  ];

  aytordev = {
    tabWidth = 2;
    clipboard = "unnamedplus";
    languages = ["nix" "lua" "rust"];
    style = "wave";
    transparent = false;
  };
}
```

The module enables `programs.nvf` and installs the configured editor by
default. Linux builds include `wl-copy` and `xclip` by default, and optional
plugins can be disabled individually through `aytordev.plugins`. See the
[configuration reference](docs/index.md) for every option.

## Package Installation

If you do not use the Home Manager module, install the package directly:

```nix
{inputs, pkgs, ...}: {
  home.packages = [
    inputs.aytordev-nvim.packages.${pkgs.stdenv.hostPlatform.system}.aytordev-nvim
  ];
}
```

Available package attributes:

| Package | Alias | Languages |
| --- | --- | --- |
| `aytordev-nvim` | `default` | Full language set |
| `aytordev-nvim-core` | `core` | Nix and Lua |

## Overlay

Apply the overlay when you want the packages available directly from `pkgs`:

```nix
{inputs, pkgs, ...}: {
  nixpkgs.overlays = [
    inputs.aytordev-nvim.overlays.default
  ];

  home.packages = [pkgs.aytordev-nvim];
}
```

The overlay builds against the consumer's nixpkgs and also exposes
`pkgs.aytordev-nvim-core`.

## Included Capabilities

- LSP, formatting, completion, Treesitter, and diagnostics
- Continuous reload of files changed on disk, plus on terminal focus
- Configurable Nix, Lua, TypeScript, Python, Go, Rust, and configuration languages
- Snacks picker, Neo-tree, Oil, GrugFar, Diffview, Gitsigns, and Harpoon
- Kanagawa themes with transparent background support
- Reproducible `git`, `ripgrep`, and `fd` runtime tools
- Reproducible Wayland and X11 clipboard providers on Linux
- Headless runtime and Home Manager integration checks

## Supported Systems

- `aarch64-darwin`
- `aarch64-linux`
- `x86_64-linux`

Intel macOS is not supported because current nixpkgs unstable no longer
supports `x86_64-darwin`.

## Development

Enter the development shell and inspect the available commands:

```bash
nix develop
just
```

Common workflows:

```bash
just fmt
just check
nix flake check --all-systems --no-build
nix run .
```

See [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## License

[MIT](LICENSE)
