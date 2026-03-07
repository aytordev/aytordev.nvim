{lib, ...}: {
  options.aytordev = {
    viAlias = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Create a `vi` alias for Neovim.";
    };

    vimAlias = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Create a `vim` alias for Neovim.";
    };
  };
}
