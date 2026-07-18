{inputs, ...}: {
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
