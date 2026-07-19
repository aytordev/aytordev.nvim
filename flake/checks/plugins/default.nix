{
  inputs,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: let
    pluginNames = import ../../../modules/nvf/plugin-discovery;
    pluginsDisabledHome = inputs.home-manager.lib.homeManagerConfiguration {
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
            colorscheme = "none";
            languages = [];
            plugins = pkgs.lib.genAttrs pluginNames (_: false);
          };
        }
      ];
    };

    outerPlugins = pluginsDisabledHome.config.aytordev.plugins;
    innerPlugins = pluginsDisabledHome.config.programs.nvf.settings.aytordev.plugins;
    vim = pluginsDisabledHome.config.programs.nvf.settings.vim;
    documentedPluginList = pkgs.lib.concatMapStringsSep "\n" (name: "- `${name}`") pluginNames;
    expectedPluginSection = ''
      <!-- plugin-list:start -->
      ${documentedPluginList}
      <!-- plugin-list:end -->
    '';
    documentation = builtins.readFile ../../../docs/index.md;
    assertions = [
      {
        assertion = builtins.attrNames outerPlugins == pluginNames;
        message = "discovered plugins and public Home Manager options differ";
      }
      {
        assertion = innerPlugins == outerPlugins;
        message = "Home Manager did not preserve plugin toggles in nvf";
      }
      {
        assertion = builtins.all (name: !outerPlugins.${name}) pluginNames;
        message = "the all-disabled fixture left a plugin toggle enabled";
      }
      {
        assertion = vim.keymaps == [];
        message = "disabling every plugin left plugin keymaps configured";
      }
      {
        assertion = builtins.all (name: !(builtins.hasAttr name vim.extraPlugins)) pluginNames;
        message = "disabling every plugin left an extra plugin configured";
      }
      {
        assertion = pkgs.lib.hasInfix expectedPluginSection documentation;
        message = "docs/index.md plugin list is out of sync with discovery";
      }
    ];
    assertionsPass =
      builtins.all (
        check: pkgs.lib.assertMsg check.assertion "aytordev.nvim: ${check.message}"
      )
      assertions;
  in {
    checks.plugin-toggles = assert assertionsPass;
      pluginsDisabledHome.activationPackage;
  };
}
