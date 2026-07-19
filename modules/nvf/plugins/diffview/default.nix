# Diffview - multi-file git diff viewer
# https://github.com/sindrets/diffview.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.diffview {
    vim.utility.diffview-nvim.enable = lib.mkDefault true;
  };
}
