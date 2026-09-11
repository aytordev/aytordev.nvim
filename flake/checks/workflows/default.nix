{...}: {
  perSystem = {pkgs, ...}: let
    workflowDir = ../../../.github/workflows;
    workflowFiles = pkgs.lib.mapAttrsToList (name: _: workflowDir + "/${name}") (
      pkgs.lib.filterAttrs (
        name: type: type == "regular" && (pkgs.lib.hasSuffix ".yml" name || pkgs.lib.hasSuffix ".yaml" name)
      ) (builtins.readDir workflowDir)
    );
  in {
    checks.workflows =
      pkgs.runCommand "aytordev-nvim-workflows-check"
      {
        nativeBuildInputs = [pkgs.actionlint];
      }
      ''
        actionlint ${pkgs.lib.concatMapStringsSep " " (file: "'${file}'") workflowFiles}
        touch "$out"
      '';
  };
}
