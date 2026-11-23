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

    # Shared fail-closed runner for every headless runtime check. The
    # wrapper boundary rejects a nonzero nvim exit, a missing completion
    # marker (suite stopped early), and nonempty stderr: shutdown-time
    # errors (e.g. a VimLeavePre echoerr) exit zero after the suite already
    # finished and the marker was written, so stderr is the boundary that
    # still catches them. Every rejection prints the captured stderr for
    # diagnostics.
    runHeadlessCheck = {
      name,
      nvim,
      luaFile,
      env ? {},
    }: ''
      export HOME="$TMPDIR"
      export XDG_CACHE_HOME="$TMPDIR/cache"
      export XDG_STATE_HOME="$TMPDIR/state"
      export AYTORDEV_CHECK_MARKER="$TMPDIR/aytordev-check-complete"
      # Explicit test/sandbox environment marker, consumed by check.lua
      # to scope darwin-only workarounds to Nix sandboxed builds.
      export AYTORDEV_SANDBOX=1
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (envName: envValue: "export ${envName}=\"${envValue}\"") env)}
      export PATH="${
        lib.makeBinPath [
          pkgs.bash
          pkgs.coreutils
        ]
      }"

      mkdir -p "$TMPDIR/project"
      printf '{}\n' > "$TMPDIR/project/flake.nix"

      stderr="$TMPDIR/nvim-stderr"
      if ! ${nvim} --headless "$TMPDIR/project/flake.nix" \
        "+luafile ${luaFile}" \
        "+qa" 2>"$stderr"
      then
        echo "aytordev-nvim ${name} runtime check failed" >&2
        cat "$stderr" >&2
        exit 1
      fi

      # Fail closed: the suite must have run to completion. A missing
      # marker means the headless session exited before finishing every
      # probe, even if nvim itself exited successfully.
      if ! test -f "$AYTORDEV_CHECK_MARKER"; then
        echo "aytordev-nvim ${name} runtime check did not complete: no completion marker" >&2
        cat "$stderr" >&2
        exit 1
      fi

      # Fail closed at the wrapper boundary: these checks are quiet, so
      # any stderr output is an unexpected error, including shutdown-time
      # errors that nvim still exits zero on.
      if test -s "$stderr"; then
        echo "aytordev-nvim ${name} runtime check wrote unexpected stderr" >&2
        cat "$stderr" >&2
        exit 1
      fi
    '';

    mkRuntimeCheck = name: profile: package:
      pkgs.runCommand "aytordev-nvim-${name}-runtime-check" {} ((runHeadlessCheck {
          inherit name;
          nvim = "${package}/bin/nvim";
          luaFile = ./check.lua;
          env =
            {AYTORDEV_PROFILE = profile;}
            // lib.optionalAttrs (profile != "minimal") {AYTORDEV_COLORSCHEME = "sora";};
        })
        + ''
          touch "$out"
        '');

    # Lean package that enables only the selected colorscheme plugin, so the
    # theme loads without the rest of the distribution.
    mkThemePackage = colorscheme: style:
      (inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          ../../../modules/nvf
          {
            config.aytordev = {
              inherit colorscheme style;
              languages = [];
              plugins = lib.genAttrs pluginNames (name: name == colorscheme);
            };
          }
        ];
      }).neovim;

    mkThemeCheck = name: colorscheme: style: colorsName:
      pkgs.runCommand "aytordev-nvim-theme-${name}-runtime-check" {} ((runHeadlessCheck {
          inherit name;
          nvim = "${mkThemePackage colorscheme style}/bin/nvim";
          luaFile = ./check.lua;
          env = {
            AYTORDEV_PROFILE = "theme";
            AYTORDEV_COLORSCHEME = colorsName;
          };
        })
        + ''
          touch "$out"
        '');
    # Durable regression for the wrapper boundary: the clean control must
    # pass, and a suite that finishes cleanly but then hits an unexpected
    # shutdown error (zero exit, marker written, stderr written) must be
    # rejected by the same shared gate the real checks use.
    harnessSelftestLua = pkgs.writeText "aytordev-selftest-fault.lua" ''
      -- Finishes the suite cleanly, then raises an unexpected error at
      -- shutdown: zero exit code, marker written, stderr written.
      vim.fn.writefile({"complete"}, vim.env.AYTORDEV_CHECK_MARKER)
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          vim.cmd('echoerr "audit-leave"')
        end,
      })
    '';
    harnessSelftest = pkgs.runCommand "aytordev-nvim-runtime-harness-selftest" {} ''
      ${runHeadlessCheck {
        name = "selftest-control";
        nvim = "${minimalPackage}/bin/nvim";
        luaFile = ./check.lua;
        env = {AYTORDEV_PROFILE = "minimal";};
      }}

      if ! (
        ${runHeadlessCheck {
        name = "selftest-fault";
        nvim = "${minimalPackage}/bin/nvim";
        luaFile = harnessSelftestLua;
        env = {AYTORDEV_PROFILE = "minimal";};
      }}
      )
      then
        echo "harness selftest: shutdown-time error was correctly rejected" >&2
      else
        echo "harness selftest: shutdown-time error was NOT rejected" >&2
        exit 1
      fi

      touch "$out"
    '';
  in {
    checks = {
      runtime = mkRuntimeCheck "default" "full" config.packages.default;
      runtime-core = mkRuntimeCheck "core" "full" config.packages.core;
      runtime-minimal = mkRuntimeCheck "minimal" "minimal" minimalPackage;
      theme-kanagawa = mkThemeCheck "kanagawa" "kanagawa" "wave" "kanagawa";
      theme-catppuccin = mkThemeCheck "catppuccin" "catppuccin" "mocha" "catppuccin-mocha";
      theme-sora = mkThemeCheck "sora" "sora" "dark" "sora";
      runtime-harness-selftest = harnessSelftest;
    };
  };
}
