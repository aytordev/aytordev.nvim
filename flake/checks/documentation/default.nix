{
  inputs,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: let
    home = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        self.homeManagerModules.aytordev
        {
          home = {
            username = "test";
            homeDirectory = "/tmp/test";
            stateVersion = "25.05";
          };
        }
      ];
    };

    documentation = builtins.readFile ../../../docs/index.md;
    publicOptionNames = builtins.attrNames home.options.aytordev;
    undocumented =
      builtins.filter (
        name: !(pkgs.lib.hasInfix "aytordev.${name}" documentation)
      )
      publicOptionNames;
  in {
    checks.documentation = assert pkgs.lib.assertMsg (undocumented == [])
    "aytordev.nvim: docs/index.md does not document these public options: ${pkgs.lib.concatStringsSep ", " undocumented}";
      pkgs.runCommand "aytordev-nvim-documentation-check" {} ''
        touch "$out"
      '';
  };
}
