# Flash motion/jump enhancement
# https://github.com/folke/flash.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.flash {
    vim.utility.motion.flash-nvim.enable = lib.mkDefault true;
  };
}
