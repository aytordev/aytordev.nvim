# Oil.nvim - edit filesystem like a buffer
# https://github.com/stevearc/oil.nvim
{
  config,
  lib,
  ...
}: {
  vim.utility.oil-nvim = {
    enable = lib.mkDefault true;
    setupOpts = {
      default_file_explorer = lib.mkDefault false;
      skip_confirm_for_simple_edits = lib.mkDefault false;
      view_options = {
        show_hidden = lib.mkDefault true;
        natural_order = lib.mkDefault true;
      };
      float = {
        padding = lib.mkDefault 2;
        max_width = lib.mkDefault 100;
        max_height = lib.mkDefault 30;
        border = lib.mkDefault "rounded";
      };
    };
  };

  vim.keymaps = lib.optionals config.vim.utility.oil-nvim.enable [
    {
      key = "-";
      mode = "n";
      action = "<cmd>Oil<CR>";
      desc = "Open parent directory (Oil)";
    }
    {
      key = "<leader>E";
      mode = "n";
      action = "<cmd>Oil --float<CR>";
      desc = "Open Oil (floating)";
    }
  ];
}
