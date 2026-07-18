# Oil.nvim - edit filesystem like a buffer
# https://github.com/stevearc/oil.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.oil {
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
  };
}
