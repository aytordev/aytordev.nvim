# Which-key keymap discovery
# https://github.com/folke/which-key.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."which-key" {
    vim.binds.whichKey.enable = lib.mkDefault true;
  };
}
