# nvim-autopairs auto-close brackets
# https://github.com/windwp/nvim-autopairs
{lib, ...}: {
  vim.autopairs.nvim-autopairs.enable = lib.mkDefault true;
}
