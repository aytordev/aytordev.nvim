# nvim-surround for surround operations
# https://github.com/kylechui/nvim-surround
{lib, ...}: {
  vim.utility.surround.enable = lib.mkDefault true;
}
