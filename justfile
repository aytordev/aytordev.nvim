# Default: show available recipes
default:
    @just --list

# Build the Neovim package
build:
    nix build .#packages.default

# Format all Nix files with alejandra via treefmt
fmt:
    nix fmt

# Update flake.lock
update:
    nix flake update

# Run all checks (format + build)
check:
    nix flake check
