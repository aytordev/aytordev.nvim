# Mini.ai extended text objects
# https://github.com/echasnovski/mini.ai
{pkgs, ...}: {
  config.vim.extraPlugins.mini-ai = {
    package = pkgs.vimPlugins.mini-ai;
    setup = "require('mini.ai').setup()";
  };
}
