# Flash motion/jump enhancement
# https://github.com/folke/flash.nvim
{lib, ...}: {
  vim.utility.motion.flash-nvim.enable = lib.mkDefault true;
}
