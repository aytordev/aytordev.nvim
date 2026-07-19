# Lualine statusline
# https://github.com/nvim-lualine/lualine.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.lualine {
    vim.statusline.lualine = {
      enable = lib.mkDefault true;
      theme = lib.mkDefault "auto";
      globalStatus = lib.mkDefault true;
    };
  };
}
