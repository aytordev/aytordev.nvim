# Dropbar breadcrumb navigation
# https://github.com/Bekaboo/dropbar.nvim
{pkgs, ...}: {
  vim.extraPlugins.dropbar = {
    package = pkgs.vimPlugins.dropbar-nvim;
    setup = "require('dropbar').setup()";
  };
}
