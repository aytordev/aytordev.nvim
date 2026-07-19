# Treesitter syntax highlighting and code understanding
# https://github.com/nvim-treesitter/nvim-treesitter
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.treesitter {
    vim.treesitter = {
      enable = lib.mkDefault true;
      context.enable = lib.mkDefault true;
      textobjects.enable = lib.mkDefault true;
    };
  };
}
