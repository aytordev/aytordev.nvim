# Noice UI replacement for messages, cmdline, and popupmenu
# https://github.com/folke/noice.nvim
{lib, ...}: {
  vim.ui.noice.enable = lib.mkDefault true;
}
