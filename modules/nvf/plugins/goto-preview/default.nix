# goto-preview - preview LSP definitions in popup
# https://github.com/rmagatti/goto-preview
{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."goto-preview" {
    vim.extraPlugins.goto-preview = {
      package = pkgs.vimPlugins.goto-preview;
      setup = ''
        require('goto-preview').setup({
          default_mappings = false,
          ${lib.optionalString config.aytordev.plugins.snacks ''
          references = {
            provider = "snacks",
          },
        ''}
        })
      '';
    };
  };
}
