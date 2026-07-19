# Language support (LSP, formatter, linter, treesitter per language)
{
  config,
  lib,
  ...
}: {
  config.vim.languages =
    {
      enableTreesitter = lib.mkDefault config.aytordev.plugins.treesitter;
    }
    // builtins.listToAttrs (
      map (name: {
        inherit name;
        value.enable = lib.mkDefault true;
      })
      config.aytordev.languages
    );
}
