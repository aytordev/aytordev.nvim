# Kanagawa theme plugin
# https://github.com/rebelot/kanagawa.nvim
#
# Styles: wave (default dark), dragon (darker muted), lotus (light)
{
  config,
  pkgs,
  lib,
  ...
}: let
  styles = [
    "wave"
    "dragon"
    "lotus"
  ];
in {
  vim.extraPlugins = lib.mkIf (config.aytordev.colorscheme == "kanagawa") (
    assert lib.assertMsg (builtins.elem config.aytordev.style styles)
    "aytordev.nvim: colorscheme 'kanagawa' requires style to be one of [${lib.concatStringsSep " " styles}], got '${config.aytordev.style}'"; {
      kanagawa = {
        package = pkgs.vimPlugins.kanagawa-nvim;
        setup = ''
          require('kanagawa').setup({
            transparent = ${lib.boolToString config.aytordev.transparent},
            theme = "${config.aytordev.style}",
            background = {
              dark = "wave",
              light = "lotus",
            },
          })
          vim.cmd("colorscheme kanagawa-${config.aytordev.style}")
        '';
      };
    }
  );
}
