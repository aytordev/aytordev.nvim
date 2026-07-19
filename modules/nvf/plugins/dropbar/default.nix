# Dropbar breadcrumb navigation
# https://github.com/Bekaboo/dropbar.nvim
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.dropbar {
    vim.extraPlugins.dropbar = {
      package = pkgs.vimPlugins.dropbar-nvim;
      setup = "require('dropbar').setup()";
    };
  };
}
