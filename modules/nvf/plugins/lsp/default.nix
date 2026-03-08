# LSP infrastructure
# https://github.com/neovim/nvim-lspconfig
{...}: {
  config.vim.lsp = {
    enable = true;
    formatOnSave = true;
    trouble.enable = true;
  };
}
