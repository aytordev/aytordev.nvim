{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.default =
      (inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          ../modules/aytordev
          ../modules/nvf
        ];
      }).neovim;
  };
}
