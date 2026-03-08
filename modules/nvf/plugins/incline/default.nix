# Incline - floating filename labels per window
# https://github.com/b0o/incline.nvim
{pkgs, ...}: {
  config.vim.extraPlugins.incline = {
    package = pkgs.vimPlugins.incline-nvim;
    setup = ''
      require('incline').setup({
        hide = {
          cursorline = true,
        },
      })
    '';
  };
}
