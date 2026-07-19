# LSP infrastructure
# https://github.com/neovim/nvim-lspconfig
{lib, ...}: {
  config.vim.lsp = {
    enable = lib.mkDefault true;
    formatOnSave = lib.mkDefault true;
    trouble.enable = lib.mkDefault true;
  };
}
