{inputs, ...}: let
  desiredSystems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];
  nixpkgsSystems = builtins.attrNames inputs.nixpkgs.legacyPackages;
  supportedSystems = builtins.filter (system: builtins.elem system nixpkgsSystems) desiredSystems;
  unsupportedSystems =
    builtins.filter (
      system: !(builtins.elem system nixpkgsSystems)
    )
    desiredSystems;

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
  _module.args = {
    inherit mkAytordevNeovim;
    profiles = import ./profiles.nix;
  };

  imports = [
    inputs.treefmt-nix.flakeModule
    ./packages
    ./devshells
    ./formatter
    ./checks
    ./overlays
    ./home-manager
  ];

  systems =
    if unsupportedSystems == []
    then supportedSystems
    else throw "aytordev.nvim: nixpkgs does not expose: ${builtins.concatStringsSep ", " unsupportedSystems}";
}
