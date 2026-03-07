{lib, ...}: {
  options.aytordev = {
    colorscheme = lib.mkOption {
      type = lib.types.enum ["kanagawa"];
      default = "kanagawa";
      description = "The colorscheme to use.";
    };

    style = lib.mkOption {
      type = lib.types.str;
      default = "wave";
      description = "The colorscheme variant/style to use.";
    };

    transparent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable transparent background.";
    };
  };
}
