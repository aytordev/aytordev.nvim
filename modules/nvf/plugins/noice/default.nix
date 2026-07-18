# Noice UI replacement for messages, cmdline, and popupmenu
# https://github.com/folke/noice.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.noice {
    vim.ui.noice.enable = lib.mkDefault true;
  };
}
