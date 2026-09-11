{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    lib = pkgs.lib;
    pluginNames = import ../../../modules/nvf/plugin-discovery;
    minimalPackage =
      (inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          ../../../modules/nvf
          {
            config.aytordev = {
              colorscheme = "none";
              languages = [];
              plugins = lib.genAttrs pluginNames (_: false);
            };
          }
        ];
      }).neovim;

    mkRuntimeCheck = name: profile: package:
      pkgs.runCommand "aytordev-nvim-${name}-runtime-check" {} ''
        export HOME="$TMPDIR"
        export XDG_CACHE_HOME="$TMPDIR/cache"
        export XDG_STATE_HOME="$TMPDIR/state"
        export AYTORDEV_PROFILE=${profile}
        export PATH="${
          lib.makeBinPath [
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
      runtime = mkRuntimeCheck "default" "full" config.packages.default;
      runtime-core = mkRuntimeCheck "core" "full" config.packages.core;
      runtime-minimal = mkRuntimeCheck "minimal" "minimal" minimalPackage;
    };
  };
}
