# Mini.icons icon provider
# https://github.com/echasnovski/mini.icons
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."mini-icons" {
    vim.mini.icons.enable = lib.mkDefault true;
  };
}
