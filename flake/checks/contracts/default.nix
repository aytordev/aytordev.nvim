# Fixtures that pin the public configuration contract: option propagation,
# precedence, and feature toggles that the other checks do not exercise.
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

    base = {
      aytordev.languages = selectedLanguages;
    };

    defaultsHome = mkHome [base];

    disabledHome = mkHome [
      {
        aytordev = {
          languages = selectedLanguages;
          format = false;
          extraDiagnostics = false;
        };
      }
    ];

    treesitterOffHome = mkHome [
      (
        base
        // {
          aytordev =
            base.aytordev
            // {
              plugins.treesitter = false;
            };
        }
      )
    ];

    clipboardNoneHome = mkHome [
      (
        base
        // {
          aytordev =
            base.aytordev
            // {
              clipboard = "none";
            };
        }
      )
    ];

    nestedOverrideHome = mkHome [
      (
        base
        // {
          programs.nvf.settings.aytordev.tabWidth = 4;
        }
      )
    ];

    gotoPreviewNoSnacksHome = mkHome [
      (
        base
        // {
          aytordev =
            base.aytordev
            // {
              plugins.snacks = false;
            };
        }
      )
    ];

    vimOf = home: home.config.programs.nvf.settings.vim;

    defaultsVim = vimOf defaultsHome;
    disabledVim = vimOf disabledHome;
    treesitterOffVim = vimOf treesitterOffHome;
    clipboardNoneVim = vimOf clipboardNoneHome;
    nestedOverrideVim = vimOf nestedOverrideHome;
    gotoPreviewNoSnacksVim = vimOf gotoPreviewNoSnacksHome;

    keymapped = vim: key: builtins.any (mapping: mapping.key == key) vim.keymaps;

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
      {
        assertion = !treesitterOffVim.treesitter.enable;
        message = "aytordev.plugins.treesitter = false did not disable treesitter";
      }
      {
        assertion = !treesitterOffVim.languages.nix.treesitter.enable;
        message = "aytordev.plugins.treesitter = false left the Nix treesitter enabled";
      }
      {
        assertion = !treesitterOffVim.languages.lua.treesitter.enable;
        message = "aytordev.plugins.treesitter = false left the Lua treesitter enabled";
      }
      {
        assertion = !clipboardNoneVim.clipboard.enable;
        message = "aytordev.clipboard = none did not disable the clipboard";
      }
      {
        assertion = clipboardNoneVim.clipboard.registers == "";
        message = "aytordev.clipboard = none kept a clipboard register";
      }
      {
        assertion = !clipboardNoneVim.clipboard.providers.wl-copy.enable;
        message = "aytordev.clipboard = none kept the wl-copy provider";
      }
      {
        assertion = !clipboardNoneVim.clipboard.providers.xclip.enable;
        message = "aytordev.clipboard = none kept the xclip provider";
      }
      {
        assertion = nestedOverrideVim.options.tabstop == 4;
        message = "nested aytordev.tabWidth override was ignored";
      }
      {
        assertion = nestedOverrideVim.options.shiftwidth == 4;
        message = "nested aytordev.tabWidth override did not reach shiftwidth";
      }
      {
        assertion = !gotoPreviewNoSnacksVim.utility.snacks-nvim.enable;
        message = "aytordev.plugins.snacks = false did not disable snacks";
      }
      {
        assertion = !keymapped gotoPreviewNoSnacksVim "<leader>pr";
        message = "goto-preview references stayed mapped without snacks";
      }
      {
        assertion = keymapped gotoPreviewNoSnacksVim "<leader>pd";
        message = "goto-preview definition mapping disappeared without snacks";
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
