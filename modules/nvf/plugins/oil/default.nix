# Oil.nvim - edit filesystem like a buffer
# https://github.com/stevearc/oil.nvim
{...}: {
  config.vim.utility.oil-nvim = {
    enable = true;
    setupOpts = {
      default_file_explorer = true;
      skip_confirm_for_simple_edits = false;
      view_options = {
        show_hidden = true;
        natural_order = true;
      };
      float = {
        padding = 2;
        max_width = 100;
        max_height = 30;
        border = "rounded";
      };
    };
  };
}
