{mkAytordevNeovim, ...}: {
  perSystem = {pkgs, ...}: let
    package = mkAytordevNeovim {
      inherit pkgs;
      name = "aytordev-nvim";
    };
    corePackage = mkAytordevNeovim {
      inherit pkgs;
      name = "aytordev-nvim-core";
      languages = [
        "nix"
        "lua"
      ];
    };
  in {
    packages = {
      aytordev-nvim = package;
      aytordev-nvim-core = corePackage;
      default = package;
      core = corePackage;
    };
  };
}
