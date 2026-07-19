{self, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    overlaidPkgs = pkgs.extend self.overlays.default;
  in {
    checks = {
      build = assert pkgs.lib.assertMsg (
        config.packages.default.drvPath == config.packages.aytordev-nvim.drvPath
      ) "aytordev.nvim: packages.default does not reference aytordev-nvim";
        config.packages.default;

      core = assert pkgs.lib.assertMsg (
        config.packages.core.drvPath == config.packages.aytordev-nvim-core.drvPath
      ) "aytordev.nvim: packages.core does not reference aytordev-nvim-core";
        config.packages.core;

      overlay = assert pkgs.lib.assertMsg (
        overlaidPkgs.aytordev-nvim.drvPath == config.packages.aytordev-nvim.drvPath
      ) "aytordev.nvim: overlay aytordev-nvim differs from the package output";
      assert pkgs.lib.assertMsg (
        overlaidPkgs.aytordev-nvim-core.drvPath == config.packages.aytordev-nvim-core.drvPath
      ) "aytordev.nvim: overlay aytordev-nvim-core differs from the package output";
        overlaidPkgs.aytordev-nvim;
    };
  };
}
