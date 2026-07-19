# Gitsigns git integration
# https://github.com/lewis6991/gitsigns.nvim
{lib, ...}: {
  vim.git.gitsigns.enable = lib.mkDefault true;
}
