{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./packages
  ];

  systems = import inputs.systems;
}
