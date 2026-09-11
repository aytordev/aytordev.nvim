{...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    mkRuntimeCheck = name: package:
      pkgs.runCommand "aytordev-nvim-${name}-runtime-check" {} ''
        export HOME="$TMPDIR"
        export XDG_CACHE_HOME="$TMPDIR/cache"
        export XDG_STATE_HOME="$TMPDIR/state"
        export PATH="${
          pkgs.lib.makeBinPath [
            pkgs.bash
            pkgs.coreutils
          ]
        }"

        mkdir -p "$TMPDIR/project"
        printf '{}\n' > "$TMPDIR/project/flake.nix"

        ${package}/bin/nvim --headless "$TMPDIR/project/flake.nix" \
          "+luafile ${./check.lua}" \
          "+qa"

        touch "$out"
      '';
  in {
    checks = {
      runtime = mkRuntimeCheck "default" config.packages.default;
      runtime-core = mkRuntimeCheck "core" config.packages.core;
    };
  };
}
