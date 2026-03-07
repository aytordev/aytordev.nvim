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

    tabWidth = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Number of spaces for indentation (controls tabstop and shiftwidth).";
    };

    clipboard = lib.mkOption {
      type = lib.types.enum ["unnamedplus" "unnamed" "none"];
      default = "unnamedplus";
      description = "Clipboard integration mode. 'unnamedplus' syncs with system clipboard, 'unnamed' uses selection register, 'none' disables.";
    };
  };
}
