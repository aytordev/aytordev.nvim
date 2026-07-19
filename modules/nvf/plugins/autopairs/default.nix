# nvim-autopairs auto-close brackets
# https://github.com/windwp/nvim-autopairs
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins.autopairs {
    vim.autopairs.nvim-autopairs.enable = lib.mkDefault true;
  };
}
