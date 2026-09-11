# Neo-tree file explorer
# https://github.com/nvim-neo-tree/neo-tree.nvim
{
  config,
  lib,
  ...
}: {
  vim.filetree.neo-tree = {
    enable = lib.mkDefault true;
    setupOpts = {
      window = {
        position = lib.mkDefault "right";
        width = lib.mkDefault 30;
      };
      close_if_last_window = lib.mkDefault true;
      filesystem.use_libuv_file_watcher = lib.mkDefault true;
    };
  };

  vim.keymaps = lib.optionals config.vim.filetree.neo-tree.enable [
    {
      key = "<leader>e";
      mode = "n";
      action = "<cmd>Neotree toggle<CR>";
      desc = "Toggle file tree";
    }
  ];
}
