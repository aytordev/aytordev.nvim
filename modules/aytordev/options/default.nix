{lib, ...}: let
  pluginNames = import ../../nvf/plugin-discovery;
  supportedLanguages = [
    "bash"
    "go"
    "html"
    "json"
    "lua"
    "markdown"
    "nix"
    "python"
    "rust"
    "toml"
    "typescript"
    "yaml"
  ];
in {
  imports = [
    ./editor
    ./theme
  ];

  options.aytordev.languages = lib.mkOption {
    type = lib.types.listOf (lib.types.enum supportedLanguages);
    default = supportedLanguages;
    apply = lib.unique;
    example = [
      "nix"
      "lua"
      "rust"
    ];
    description = "Languages for which support should be enabled.";
  };

  options.aytordev.plugins = lib.genAttrs pluginNames (
    name:
      lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the ${name} plugin.";
      }
  );
}
