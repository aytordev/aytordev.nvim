# Mini.hipatterns - highlight color patterns inline
# https://github.com/echasnovski/mini.hipatterns
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."mini-hipatterns" {
    vim.mini.hipatterns.enable = lib.mkDefault true;
  };
}
