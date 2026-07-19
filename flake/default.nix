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
in {
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
