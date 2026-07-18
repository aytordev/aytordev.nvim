let
  entries = builtins.readDir ./.;
  infrastructureModules = [
    "keymaps"
    "languages"
    "lsp"
  ];
  moduleNames = builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
in {
  inherit infrastructureModules moduleNames;
  pluginNames = builtins.filter (name: !(builtins.elem name infrastructureModules)) moduleNames;
}
