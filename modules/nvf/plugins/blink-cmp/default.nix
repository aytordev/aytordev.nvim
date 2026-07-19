# Blink.cmp completion engine
# https://github.com/Saghen/blink.cmp
{lib, ...}: {
  vim.autocomplete.blink-cmp = {
    enable = lib.mkDefault true;
    friendly-snippets.enable = lib.mkDefault true;
  };
}
