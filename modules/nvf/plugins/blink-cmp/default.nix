# Blink.cmp completion engine
# https://github.com/Saghen/blink.cmp
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."blink-cmp" {
    vim.autocomplete.blink-cmp = {
      enable = lib.mkDefault true;
      friendly-snippets.enable = lib.mkDefault true;
    };
  };
}
