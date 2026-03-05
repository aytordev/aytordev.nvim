{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./packages
    ./devshells
    ./formatter
    ./checks
    ./overlays
    ./home-manager
  ];

  systems = import inputs.systems;
}
