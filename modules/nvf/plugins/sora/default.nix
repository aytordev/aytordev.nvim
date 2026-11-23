# Sora theme plugin
# https://github.com/Aejkatappaja/sora
#
# Sora is a single dark colorscheme (no light counterpart).
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Sora is pinned as a non-flake input in the repository's flake.lock. Deriving
  # the source from the lock keeps flake and raw-module consumers on the same
  # revision, and the scheduled lock update refreshes both together.
  flakeLock = builtins.fromJSON (builtins.readFile ../../../../flake.lock);
  soraLock = flakeLock.nodes.${flakeLock.nodes.${flakeLock.root}.inputs.sora}.locked;
  soraSrc = pkgs.fetchFromGitHub {
    owner = soraLock.owner;
    repo = soraLock.repo;
    rev = soraLock.rev;
    hash = soraLock.narHash;
  };
in {
  vim.extraPlugins = lib.mkIf (config.aytordev.colorscheme == "sora") (
    assert lib.assertMsg (config.aytordev.style == "dark")
    "aytordev.nvim: colorscheme 'sora' is dark-only; set aytordev.style = \"dark\" (got '${config.aytordev.style}')"; {
      sora = {
        # Not in nixpkgs: package the upstream repository directly.
        package = pkgs.vimUtils.buildVimPlugin {
          name = "sora-nvim";
          src = soraSrc;
        };
        setup = ''
          require('sora').setup({
            transparent = ${lib.boolToString config.aytordev.transparent},
          })
          vim.cmd("colorscheme sora")
        '';
      };
    }
  );
}
