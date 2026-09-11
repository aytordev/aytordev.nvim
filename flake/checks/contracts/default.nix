# Fixtures that pin the public configuration contract: option propagation and
# feature toggles that the other checks do not exercise.
{
  inputs,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: let
    mkHome = extraModules:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules =
          [
            self.homeManagerModules.aytordev
            {
              home = {
                username = "test";
                homeDirectory = "/tmp/test";
                stateVersion = "25.05";
              };
            }
          ]
          ++ extraModules;
      };

    selectedLanguages = [
      "nix"
      "lua"
    ];

    defaultsHome = mkHome [
      {
        aytordev.languages = selectedLanguages;
      }
    ];

    disabledHome = mkHome [
      {
        aytordev = {
          languages = selectedLanguages;
          format = false;
          extraDiagnostics = false;
        };
      }
    ];

    defaultsVim = defaultsHome.config.programs.nvf.settings.vim;
    disabledVim = disabledHome.config.programs.nvf.settings.vim;

    assertions = [
      {
        assertion = defaultsVim.languages.enableFormat;
        message = "formatting is not enabled by default";
      }
      {
        assertion = defaultsVim.languages.enableExtraDiagnostics;
        message = "extra diagnostics are not enabled by default";
      }
      {
        assertion = defaultsVim.languages.nix.format.enable;
        message = "the default format policy did not reach a selected language";
      }
      {
        assertion = defaultsVim.languages.nix.extraDiagnostics.enable;
        message = "the default diagnostics policy did not reach a selected language";
      }
      {
        assertion = !disabledVim.languages.enableFormat;
        message = "aytordev.format = false did not disable formatting";
      }
      {
        assertion = !disabledVim.languages.enableExtraDiagnostics;
        message = "aytordev.extraDiagnostics = false did not disable extra diagnostics";
      }
      {
        assertion = !disabledVim.languages.nix.format.enable;
        message = "disabling formatting left a formatter enabled";
      }
      {
        assertion = !disabledVim.languages.nix.extraDiagnostics.enable;
        message = "disabling extra diagnostics left a linter enabled";
      }
    ];
    assertionsPass =
      builtins.all (
        check: pkgs.lib.assertMsg check.assertion "aytordev.nvim: ${check.message}"
      )
      assertions;
  in {
    checks.contracts = assert assertionsPass;
      pkgs.runCommand "aytordev-nvim-contracts-check" {} ''
        touch "$out"
      '';
  };
}
