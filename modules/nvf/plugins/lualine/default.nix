# Lualine statusline
# https://github.com/nvim-lualine/lualine.nvim
{lib, ...}: {
  vim.statusline.lualine = {
    enable = lib.mkDefault true;
    setupOpts.options = {
      theme = lib.mkDefault "auto";
      globalstatus = lib.mkDefault true;
    };
  };
}
