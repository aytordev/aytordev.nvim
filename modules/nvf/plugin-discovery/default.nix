let
  pluginDir = ../plugins;
  entries = builtins.readDir pluginDir;
  pluginNames = builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
  invalidNames =
    builtins.filter (
      name: builtins.match "[a-z0-9]+(-[a-z0-9]+)*" name == null
    )
    pluginNames;
  missingDefaults =
    builtins.filter (
      name: !builtins.pathExists (pluginDir + "/${name}/default.nix")
    )
    pluginNames;
in
  if invalidNames != []
  then throw "aytordev.nvim: invalid plugin directory names: ${builtins.concatStringsSep ", " invalidNames}"
  else if missingDefaults != []
  then throw "aytordev.nvim: plugin directories without default.nix: ${builtins.concatStringsSep ", " missingDefaults}"
  else pluginNames
