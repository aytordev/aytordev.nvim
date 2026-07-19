# Mini.ai extended text objects
# https://github.com/echasnovski/mini.ai
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."mini-ai" {
    vim.extraPlugins.mini-ai = {
      package = pkgs.vimPlugins.mini-ai;
      setup = "require('mini.ai').setup()";
    };
  };
}
