# Kanagawa theme plugin
# https://github.com/rebelot/kanagawa.nvim
#
# Styles: wave (default dark), dragon (darker muted), lotus (light)
{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.aytordev.colorscheme == "kanagawa") {
    vim.extraPlugins = {
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
    };
  };
}
