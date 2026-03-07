# LSP configuration with language support
# https://github.com/neovim/nvim-lspconfig
{...}: {
  config.vim = {
    lsp = {
      enable = true;
      formatOnSave = true;
      trouble.enable = true;
    };
    languages = {
      nix.enable = true;
      lua.enable = true;
    };
  };
}
