# Harpoon2 quick file navigation
# https://github.com/ThePrimeagen/harpoon/tree/harpoon2
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.harpoon {
    vim.navigation.harpoon.enable = lib.mkDefault true;
  };
}
