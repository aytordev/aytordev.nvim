{...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    checks.runtime = pkgs.runCommand "aytordev-nvim-runtime-check" {} ''
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

      ${config.packages.default}/bin/nvim --headless "$TMPDIR/project/flake.nix" \
        "+luafile ${./check.lua}" \
        "+qa"

      touch "$out"
    '';
  };
}
