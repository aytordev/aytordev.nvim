{...}: let
  pluginDir = ./plugins;
  discovery = import ./plugins/discovery.nix;
in {
  imports =
    [
      ../aytordev
      ./options
    ]
    ++ map (name: pluginDir + "/${name}") discovery.moduleNames;
}
