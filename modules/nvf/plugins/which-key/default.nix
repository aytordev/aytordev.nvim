# Which-key keymap discovery
# https://github.com/folke/which-key.nvim
{lib, ...}: {
  vim.binds.whichKey.enable = lib.mkDefault true;
}
