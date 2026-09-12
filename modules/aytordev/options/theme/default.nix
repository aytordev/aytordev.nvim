{lib, ...}: {
  options.aytordev = {
    colorscheme = lib.mkOption {
      type = lib.types.enum [
        "kanagawa"
        "catppuccin"
        "sora"
        "none"
      ];
      default = "kanagawa";
      description = "The colorscheme family to use.";
    };

    style = lib.mkOption {
      type = lib.types.enum [
        # Kanagawa
        "wave"
        "dragon"
        "lotus"
        # Catppuccin
        "latte"
        "frappe"
        "macchiato"
        "mocha"
        # Sora (dark-only)
        "dark"
      ];
      default = "wave";
      description = ''
        The variant of the selected colorscheme family. Valid values depend on
        `aytordev.colorscheme`:

        - `kanagawa`: `wave`, `dragon`, `lotus`
        - `catppuccin`: `latte`, `frappe`, `macchiato`, `mocha`
        - `sora`: `dark`
      '';
    };

    transparent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable transparent background.";
    };
  };
}
