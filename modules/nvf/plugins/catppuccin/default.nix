# Catppuccin theme plugin
# https://github.com/catppuccin/nvim
#
# Flavours: latte (light), frappe, macchiato, mocha (default dark)
{
  config,
  pkgs,
  lib,
  ...
}: let
  flavours = [
    "latte"
    "frappe"
    "macchiato"
    "mocha"
  ];
in {
  vim.extraPlugins = lib.mkIf (config.aytordev.colorscheme == "catppuccin") (
    assert lib.assertMsg (builtins.elem config.aytordev.style flavours)
    "aytordev.nvim: colorscheme 'catppuccin' requires style to be one of [${lib.concatStringsSep " " flavours}], got '${config.aytordev.style}'"; {
      catppuccin = {
        package = pkgs.vimPlugins.catppuccin-nvim;
        setup = ''
          require('catppuccin').setup({
            flavour = "${config.aytordev.style}",
            transparent_background = ${lib.boolToString config.aytordev.transparent},
          })
          vim.cmd("colorscheme catppuccin-${config.aytordev.style}")
        '';
      };
    }
  );
}
