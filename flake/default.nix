{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./packages
    ./devshells
    ./formatter
    ./checks
  ];

  systems = import inputs.systems;
}
