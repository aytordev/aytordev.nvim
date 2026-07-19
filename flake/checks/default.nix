{
  inputs,
  self,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    pluginNames = (import ../../modules/nvf/plugins/discovery.nix).pluginNames;

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
            plugins = {
              dropbar = false;
              goto-preview = false;
              incline = false;
              mini-ai = false;
              zen-mode = false;
            };
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

    runtimeCheck = pkgs.writeText "aytordev-nvim-runtime-check.lua" ''
      local function fail(message)
        vim.api.nvim_err_writeln(message)
        vim.cmd("cquit 1")
      end

      if vim.v.errmsg ~= "" then
        fail("Neovim startup failed: " .. vim.v.errmsg)
      end

      for _, command in ipairs({ "git", "rg", "fd" }) do
        if vim.fn.executable(command) ~= 1 then
          fail(command .. " is unavailable")
        end

        if vim.system({ command, "--version" }):wait().code ~= 0 then
          fail(command .. " failed to execute")
        end
      end

      if vim.fn.has("linux") == 1 then
        for _, command in ipairs({ "wl-copy", "xclip" }) do
          if vim.fn.executable(command) ~= 1 then
            fail(command .. " is unavailable")
          end
        end
      end

      local lsp_attached = vim.wait(10000, function()
        return #vim.lsp.get_clients({ bufnr = 0 }) > 0
      end)

      if not lsp_attached then
        fail("No LSP client attached to a Nix file")
      end

      local features = {
        ["Neotree command"] = vim.fn.exists(":Neotree") == 2,
        ["GrugFar command"] = vim.fn.exists(":GrugFar") == 2,
        ["Snacks API"] = type(Snacks) == "table",
      }

      for feature, available in pairs(features) do
        if not available then
          fail(feature .. " is unavailable")
        end
      end

      local goto_preview = require("goto-preview")
      if goto_preview.conf.references.provider ~= "snacks" then
        fail("goto-preview references provider is not Snacks")
      end

      for _, mapping in ipairs({ "pd", "pt", "pi", "pD", "pr", "pc" }) do
        if vim.fn.maparg("<leader>" .. mapping, "n") == "" then
          fail("<leader>" .. mapping .. " is not mapped")
        end
      end
    '';

    overlaidPkgs = pkgs.extend self.overlays.default;
    homeHasKeymap = key: builtins.any (mapping: mapping.key == key) home.config.programs.nvf.settings.vim.keymaps;
    pluginsDisabledVim = pluginsDisabledHome.config.programs.nvf.settings.vim;
    pluginsDisabledHasKeymap = key: builtins.any (mapping: mapping.key == key) pluginsDisabledVim.keymaps;
  in {
    checks = {
      build = assert config.packages.default.drvPath == config.packages.aytordev-nvim.drvPath;
        config.packages.default;
      core = assert config.packages.core.drvPath == config.packages.aytordev-nvim-core.drvPath;
        config.packages.core;
      home-manager = assert home.config.programs.nvf.settings.vim.options.tabstop == 4;
      assert home.config.programs.nvf.settings.vim.lsp.enable;
      assert home.config.programs.nvf.settings.vim.filetree.neo-tree.enable;
      assert home.config.programs.nvf.settings.vim.languages.nix.enable;
      assert home.config.programs.nvf.settings.vim.languages.lua.enable;
      assert !home.config.programs.nvf.settings.vim.languages.typescript.enable;
      assert home.config.programs.nvf.settings.vim.clipboard.enable;
      assert home.config.programs.nvf.settings.vim.clipboard.registers == "unnamedplus";
      assert home.config.programs.nvf.settings.vim.clipboard.providers.wl-copy.enable == pkgs.stdenv.isLinux;
      assert home.config.programs.nvf.settings.vim.clipboard.providers.xclip.enable == pkgs.stdenv.isLinux;
      assert !(builtins.hasAttr "dropbar" home.config.programs.nvf.settings.vim.extraPlugins);
      assert !(builtins.hasAttr "goto-preview" home.config.programs.nvf.settings.vim.extraPlugins);
      assert !(builtins.hasAttr "incline" home.config.programs.nvf.settings.vim.extraPlugins);
      assert !(builtins.hasAttr "mini-ai" home.config.programs.nvf.settings.vim.extraPlugins);
      assert !(builtins.hasAttr "zen-mode" home.config.programs.nvf.settings.vim.extraPlugins);
      assert !(builtins.hasAttr "kanagawa" home.config.programs.nvf.settings.vim.extraPlugins);
      assert !(homeHasKeymap "<leader>pd");
      assert !(homeHasKeymap "<leader>z");
      assert home.config.programs.nvf.settings.vim.options.scrolloff == 4;
      assert home.config.programs.nvf.settings.vim.options.sidescrolloff == 8;
      assert !home.config.programs.nvf.settings.vim.lsp.formatOnSave;
      assert home.config.programs.nvf.settings.vim.filetree.neo-tree.setupOpts.window.width == 40;
      assert home.config.programs.nvf.settings.vim.filetree.neo-tree.setupOpts.window.position == "right";
      assert !home.config.programs.nvf.settings.vim.utility.surround.enable;
        home.activationPackage;
      plugin-toggles = assert builtins.all (name: !pluginsDisabledHome.config.aytordev.plugins.${name}) pluginNames;
      assert !pluginsDisabledVim.autopairs.nvim-autopairs.enable;
      assert !pluginsDisabledVim.autocomplete.blink-cmp.enable;
      assert !pluginsDisabledVim.utility.diffview-nvim.enable;
      assert !pluginsDisabledVim.utility.motion.flash-nvim.enable;
      assert !pluginsDisabledVim.git.gitsigns.enable;
      assert !pluginsDisabledVim.utility.grug-far-nvim.enable;
      assert !pluginsDisabledVim.navigation.harpoon.enable;
      assert !pluginsDisabledVim.statusline.lualine.enable;
      assert !pluginsDisabledVim.mini.hipatterns.enable;
      assert !pluginsDisabledVim.mini.icons.enable;
      assert !pluginsDisabledVim.filetree.neo-tree.enable;
      assert !pluginsDisabledVim.ui.noice.enable;
      assert !pluginsDisabledVim.utility.oil-nvim.enable;
      assert !pluginsDisabledVim.utility.snacks-nvim.enable;
      assert !pluginsDisabledVim.utility.surround.enable;
      assert !pluginsDisabledVim.notes.todo-comments.enable;
      assert !pluginsDisabledVim.treesitter.enable;
      assert !pluginsDisabledVim.binds.whichKey.enable;
      assert builtins.all (name: !(builtins.hasAttr name pluginsDisabledVim.extraPlugins)) [
        "dropbar"
        "goto-preview"
        "incline"
        "kanagawa"
        "mini-ai"
        "zen-mode"
      ];
      assert builtins.all (key: !(pluginsDisabledHasKeymap key)) [
        "<leader>e"
        "-"
        "<leader>ff"
        "<leader>pd"
        "<leader>sr"
        "<leader>gd"
        "<leader>z"
      ];
        pluginsDisabledHome.activationPackage;
      runtime = pkgs.runCommand "aytordev-nvim-runtime-check" {} ''
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
          "+luafile ${runtimeCheck}" \
          "+qa"

        touch "$out"
      '';
      overlay = assert overlaidPkgs.aytordev-nvim.drvPath == config.packages.aytordev-nvim.drvPath;
      assert overlaidPkgs.aytordev-nvim-core.drvPath == config.packages.aytordev-nvim-core.drvPath;
        overlaidPkgs.aytordev-nvim;
    };
  };
}
