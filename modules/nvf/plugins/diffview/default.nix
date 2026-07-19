# Diffview - multi-file git diff viewer
# https://github.com/sindrets/diffview.nvim
{
  config,
  lib,
  ...
}: {
  vim.utility.diffview-nvim.enable = lib.mkDefault true;

  vim.keymaps = lib.optionals config.vim.utility.diffview-nvim.enable [
    {
      key = "<leader>gd";
      mode = "n";
      action = "<cmd>DiffviewOpen<CR>";
      desc = "Open diff view";
    }
    {
      key = "<leader>gh";
      mode = "n";
      action = "<cmd>DiffviewFileHistory %<CR>";
      desc = "File history";
    }
    {
      key = "<leader>gq";
      mode = "n";
      action = "<cmd>DiffviewClose<CR>";
      desc = "Close diff view";
    }
  ];
}
