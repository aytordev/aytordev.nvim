{...}: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        actionlint
        just
        nil
      ];
    };
  };
}
