{ ... }:
{
  imports =
    let
      entries = builtins.readDir ./.;
      moduleNames = builtins.filter
        (name: entries.${name} == "directory")
        (builtins.attrNames entries);
    in
    map (name: ./. + "/${name}") moduleNames;
}
