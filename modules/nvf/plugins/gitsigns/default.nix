# Gitsigns git integration
# https://github.com/lewis6991/gitsigns.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.gitsigns {
    vim.git.gitsigns.enable = lib.mkDefault true;
  };
}
