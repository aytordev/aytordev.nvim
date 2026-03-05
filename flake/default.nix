{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  systems = import inputs.systems;
}
