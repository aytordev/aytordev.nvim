# Treesitter syntax highlighting and code understanding
# https://github.com/nvim-treesitter/nvim-treesitter
{lib, ...}: {
  vim.treesitter = {
    enable = lib.mkDefault true;
    context.enable = lib.mkDefault true;
    textobjects.enable = lib.mkDefault true;
  };
}
