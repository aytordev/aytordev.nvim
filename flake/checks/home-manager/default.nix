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
          aytordev = {
            tabWidth = 4;
            colorscheme = "none";
            style = "dragon";
            languages = [
              "nix"
              "lua"
            ];
          };
          programs.nvf.settings.vim = {
            options.scrolloff = 4;
            lsp.formatOnSave = false;
            filetree.neo-tree.setupOpts.window.width = 40;
            utility.surround.enable = false;
          };
        }
      ];
    };

    vim = home.config.programs.nvf.settings.vim;
    assertions = [
      {
        assertion = vim.options.tabstop == 4;
        message = "Home Manager did not apply tabWidth";
      }
      {
        assertion = vim.lsp.enable;
        message = "Home Manager did not enable LSP";
      }
      {
        assertion = vim.filetree.neo-tree.enable;
        message = "Home Manager did not enable default plugins";
      }
      {
        assertion = vim.languages.nix.enable;
        message = "Home Manager did not enable Nix support";
      }
      {
        assertion = vim.languages.lua.enable;
        message = "Home Manager did not enable Lua support";
      }
      {
        assertion = !vim.languages.typescript.enable;
        message = "Home Manager enabled an unselected language";
      }
      {
        assertion = vim.clipboard.enable;
        message = "Home Manager did not enable the clipboard";
      }
      {
        assertion = vim.clipboard.registers == "unnamedplus";
        message = "Home Manager applied the wrong clipboard register";
      }
      {
        assertion = vim.clipboard.providers.wl-copy.enable == pkgs.stdenv.isLinux;
        message = "wl-copy enablement does not match the platform";
      }
      {
        assertion = vim.clipboard.providers.xclip.enable == pkgs.stdenv.isLinux;
        message = "xclip enablement does not match the platform";
      }
      {
        assertion = !(builtins.hasAttr "kanagawa" vim.extraPlugins);
        message = "Kanagawa was installed while colorscheme is none";
      }
      {
        assertion = vim.options.scrolloff == 4;
        message = "direct nvf scrolloff override was ignored";
      }
      {
        assertion = vim.options.sidescrolloff == 8;
        message = "unrelated nvf defaults were lost";
      }
      {
        assertion = !vim.lsp.formatOnSave;
        message = "direct nvf LSP override was ignored";
      }
      {
        assertion = vim.filetree.neo-tree.setupOpts.window.width == 40;
        message = "direct plugin override was ignored";
      }
      {
        assertion = vim.filetree.neo-tree.setupOpts.window.position == "right";
        message = "plugin defaults were lost after an override";
      }
      {
        assertion = !vim.utility.surround.enable;
        message = "direct plugin disable override was ignored";
      }
    ];
    assertionsPass =
      builtins.all (
        check: pkgs.lib.assertMsg check.assertion "aytordev.nvim: ${check.message}"
      )
      assertions;
  in {
    checks.home-manager = assert assertionsPass;
      home.activationPackage;
  };
}
