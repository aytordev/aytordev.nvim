# Neo-tree file explorer
# https://github.com/nvim-neo-tree/neo-tree.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."neo-tree" {
    vim.filetree.neo-tree = {
      enable = lib.mkDefault true;
      setupOpts = {
        window = {
          position = lib.mkDefault "right";
          width = lib.mkDefault 30;
        };
        close_if_last_window = lib.mkDefault true;
      };
    };
  };
}
