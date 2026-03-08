# goto-preview - preview LSP definitions in popup
# https://github.com/rmagatti/goto-preview
{pkgs, ...}: {
  config.vim.extraPlugins.goto-preview = {
    package = pkgs.vimPlugins.goto-preview;
    setup = "require('goto-preview').setup({})";
  };
}
