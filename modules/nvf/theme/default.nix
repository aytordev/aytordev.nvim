# Theme bridge — reads aytordev.colorscheme and activates the matching plugin.
#
# To add a new theme, create a file in plugins/ named after the colorscheme.
# Each plugin is a function {config, pkgs, lib} -> { extraPlugins = { ... }; }
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.aytordev;

  pluginDir = ./plugins;
  pluginFiles = lib.filterAttrs (_: type: type == "regular") (builtins.readDir pluginDir);
  plugins =
    lib.mapAttrs'
    (name: _: {
      name = lib.removeSuffix ".nix" name;
      value = import (pluginDir + "/${name}") {inherit config pkgs lib;};
    })
    pluginFiles;

  availableThemes = builtins.attrNames plugins;
in {
  config = {
    assertions = [
      {
        assertion = builtins.hasAttr cfg.colorscheme plugins;
        message = "Colorscheme '${cfg.colorscheme}' is not available. Available: ${toString availableThemes}";
      }
    ];

    vim = plugins.${cfg.colorscheme};
  };
}
