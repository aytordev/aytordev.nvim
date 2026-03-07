# Dropbar breadcrumb navigation
# https://github.com/Bekaboo/dropbar.nvim
{pkgs, ...}: {
  config.vim.extraPlugins.dropbar = {
    package = pkgs.vimPlugins.dropbar-nvim;
    setup = "require('dropbar').setup()";
  };
}
