# grug-far.nvim - project-wide find and replace
# https://github.com/MagicDuck/grug-far.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."grug-far" {
    vim.utility.grug-far-nvim.enable = lib.mkDefault true;
  };
}
