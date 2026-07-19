{inputs, ...}: {
  flake.homeManagerModules.aytordev = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.nvf.homeManagerModules.nvf
      ../../modules/aytordev
    ];

    config = {
      programs.nvf = {
        enable = lib.mkDefault true;
        settings = {
          imports = [../../modules/nvf];
          aytordev = lib.mkDefault config.aytordev;
        };
      };
    };
  };
}
