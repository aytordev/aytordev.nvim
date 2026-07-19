# Zen-mode - distraction-free coding
# https://github.com/folke/zen-mode.nvim
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."zen-mode" {
    vim.extraPlugins.zen-mode = {
      package = pkgs.vimPlugins.zen-mode-nvim;
      setup = ''
        require('zen-mode').setup({
          window = {
            width = 120,
            backdrop = 0.7,
          },
        })
      '';
    };
  };
}
