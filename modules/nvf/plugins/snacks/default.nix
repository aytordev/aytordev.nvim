# Snacks.nvim utility suite (picker, bigfile, quickfile)
# https://github.com/folke/snacks.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.snacks {
    vim.utility.snacks-nvim = {
      enable = lib.mkDefault true;
      setupOpts = {
        picker = {
          enabled = lib.mkDefault true;
        };
        bigfile = {
          enabled = lib.mkDefault true;
        };
        quickfile = {
          enabled = lib.mkDefault true;
        };
      };
    };
  };
}
