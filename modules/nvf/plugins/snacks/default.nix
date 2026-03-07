# Snacks.nvim utility suite (picker, bigfile, quickfile)
# https://github.com/folke/snacks.nvim
{...}: {
  config.vim.utility.snacks-nvim = {
    enable = true;
    setupOpts = {
      picker = {
        enabled = true;
      };
      bigfile = {
        enabled = true;
      };
      quickfile = {
        enabled = true;
      };
    };
  };
}
