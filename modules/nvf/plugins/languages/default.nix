# Language support (LSP, formatter, linter, treesitter per language)
{...}: {
  config.vim.languages = {
    enableTreesitter = true;

    # Nix and Lua (moved from lsp/default.nix)
    nix.enable = true;
    lua.enable = true;

    # Universal (config files, docs, scripting)
    markdown.enable = true;
    bash.enable = true;
    json.enable = true;
    yaml.enable = true;
    toml.enable = true;

    # Programming languages
    ts.enable = true;
    python.enable = true;
    go.enable = true;
    rust.enable = true;
  };
}
