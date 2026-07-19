# Lualine statusline
# https://github.com/nvim-lualine/lualine.nvim
{lib, ...}: {
  vim.statusline.lualine = {
    enable = lib.mkDefault true;
    theme = lib.mkDefault "auto";
    globalStatus = lib.mkDefault true;
  };
}
