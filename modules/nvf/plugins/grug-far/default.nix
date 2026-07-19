# grug-far.nvim - project-wide find and replace
# https://github.com/MagicDuck/grug-far.nvim
{
  config,
  lib,
  ...
}: {
  vim.utility.grug-far-nvim.enable = lib.mkDefault true;

  vim.keymaps = lib.optionals config.vim.utility.grug-far-nvim.enable [
    {
      key = "<leader>sr";
      mode = "n";
      action = "<cmd>GrugFar<CR>";
      desc = "Search and replace";
    }
  ];
}
