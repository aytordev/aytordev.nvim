# nvim-surround for surround operations
# https://github.com/kylechui/nvim-surround
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.surround {
    vim.utility.surround.enable = lib.mkDefault true;
  };
}
