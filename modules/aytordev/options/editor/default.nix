{
  lib,
  pkgs,
  ...
}: {
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

    tabWidth = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2;
      description = "Number of spaces for indentation (controls tabstop and shiftwidth).";
    };

    clipboard = lib.mkOption {
      type = lib.types.enum [
        "unnamedplus"
        "unnamed"
        "none"
      ];
      default = "unnamedplus";
      description = "Clipboard integration mode. 'unnamedplus' syncs with system clipboard, 'unnamed' uses selection register, 'none' disables.";
    };

    clipboardProviders = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "wl-copy"
          "xclip"
          "xsel"
        ]
      );
      default = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        "wl-copy"
        "xclip"
      ];
      apply = lib.unique;
      description = "Clipboard provider packages to include on Linux.";
    };
  };
}
