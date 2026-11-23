# Default: show available recipes
default:
    @just --list

# Build the Neovim package
build:
    nix build .#default

# Format all Nix files with alejandra via treefmt
fmt:
    nix fmt

# Update flake.lock
update:
    nix flake update

# Run all checks (format + build)
check:
    nix flake check

# Benchmark Neo-tree: median time until a known file is visible in fresh packaged sessions (local only, no CI budget)
bench-neotree runs="7" nvim_bin="":
    nix build .#default
    ./scripts/bench-neotree.sh --runs {{runs}} --nvim {{ if nvim_bin != "" { nvim_bin } else { "result/bin/nvim" } }}
