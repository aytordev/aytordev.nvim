{...}: let
  pluginDir = ./.;
  pluginNames = import ../plugin-discovery;
  moduleKeys = [
    "_module"
    "config"
    "imports"
    "options"
  ];

  mkPluginModule = name: moduleArgs @ {
    config,
    lib,
    pkgs,
    ...
  }: let
    moduleFile = pluginDir + "/${name}/default.nix";
    pluginConfig = import moduleFile moduleArgs;
    invalidKeys = builtins.filter (key: builtins.hasAttr key pluginConfig) moduleKeys;
  in {
    _file = toString moduleFile;
    config = assert lib.assertMsg (builtins.isAttrs pluginConfig)
    "aytordev.nvim: ${name} must return a configuration attribute set";
    assert lib.assertMsg (
      builtins.attrNames pluginConfig != []
    ) "aytordev.nvim: ${name} returned an empty configuration fragment";
    assert lib.assertMsg (invalidKeys == [])
    "aytordev.nvim: ${name} returned module keys instead of a configuration fragment: ${builtins.concatStringsSep ", " invalidKeys}";
      lib.mkIf config.aytordev.plugins.${name} pluginConfig;
  };
in {
  imports = map mkPluginModule pluginNames;
}
