# Neo-tree file explorer
# https://github.com/nvim-neo-tree/neo-tree.nvim
{...}: {
  config.vim.filetree.neo-tree = {
    enable = true;
    setupOpts = {
      window = {
        position = "right";
        width = 30;
      };
      close_if_last_window = true;
    };
  };
}
