{...}: {
  imports = let
    pluginDir = ./plugins;
    entries = builtins.readDir pluginDir;
    pluginNames =
      builtins.filter
      (name: entries.${name} == "directory")
      (builtins.attrNames entries);
  in
    map (name: pluginDir + "/${name}") pluginNames
    ++ [
      ./options
    ];
}
