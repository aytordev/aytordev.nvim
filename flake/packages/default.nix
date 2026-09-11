{
  mkAytordevNeovim,
  profiles,
  ...
}: {
  perSystem = {pkgs, ...}: let
    package = mkAytordevNeovim (profiles.full // {inherit pkgs;});
    corePackage = mkAytordevNeovim (profiles.core // {inherit pkgs;});
  in {
    packages = {
      aytordev-nvim = package;
      aytordev-nvim-core = corePackage;
      default = package;
      core = corePackage;
    };
  };
}
