{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./packages
    ./devshells
    ./formatter
    ./checks
    ./overlays
  ];

  systems = import inputs.systems;
}
