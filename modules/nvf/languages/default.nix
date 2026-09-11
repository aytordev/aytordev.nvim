# Language support (LSP, formatter, linter, treesitter per language)
{
  config,
  lib,
  ...
}: {
  config.vim.languages =
    {
      enableTreesitter = lib.mkDefault config.aytordev.plugins.treesitter;
      enableFormat = lib.mkDefault config.aytordev.format;
      enableExtraDiagnostics = lib.mkDefault config.aytordev.extraDiagnostics;
    }
    // builtins.listToAttrs (
      map (name: {
        inherit name;
        value.enable = lib.mkDefault true;
      })
      config.aytordev.languages
    );
}
