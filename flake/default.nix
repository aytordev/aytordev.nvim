{inputs, ...}: let
  mkAytordevNeovim = {
    pkgs,
    name,
    extraModules ? [],
    languages ? null,
  }:
    (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules =
        [
          ../modules/nvf
        ]
        ++ inputs.nixpkgs.lib.optional (languages != null) {
          config.aytordev.languages = languages;
        }
        ++ extraModules;
    }).neovim.overrideAttrs
    (_: {
      inherit name;
    });
in {
  _module.args = {inherit mkAytordevNeovim;};

  imports = [
    inputs.treefmt-nix.flakeModule
    ./packages
    ./devshells
    ./formatter
    ./checks
    ./overlays
    ./home-manager
  ];

  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];
}
