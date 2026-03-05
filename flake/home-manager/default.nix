{inputs, ...}: {
  flake.homeManagerModules.aytordev = {lib, ...}: {
    imports = [
      inputs.nvf.homeManagerModules.nvf
      ../../modules/aytordev
    ];

    config = {
      programs.nvf = {
        enable = lib.mkDefault true;
        settings.vim = {
          # Bridge from aytordev.* options to vim.*
          # This block grows as modules/aytordev/ grows.
        };
      };
    };
  };
}
