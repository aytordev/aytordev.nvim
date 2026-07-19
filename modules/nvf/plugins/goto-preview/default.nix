# goto-preview - preview LSP definitions in popup
# https://github.com/rmagatti/goto-preview
{
  config,
  lib,
  pkgs,
  ...
}: {
  vim.extraPlugins.goto-preview = {
    package = pkgs.vimPlugins.goto-preview;
    setup = ''
      require('goto-preview').setup({
        default_mappings = false,
        ${lib.optionalString config.vim.utility.snacks-nvim.enable ''
        references = {
          provider = "snacks",
        },
      ''}
      })
    '';
  };

  vim.keymaps =
    [
      {
        key = "<leader>pd";
        mode = "n";
        action = "<cmd>lua require('goto-preview').goto_preview_definition()<CR>";
        desc = "Preview definition";
      }
      {
        key = "<leader>pt";
        mode = "n";
        action = "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>";
        desc = "Preview type definition";
      }
      {
        key = "<leader>pi";
        mode = "n";
        action = "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>";
        desc = "Preview implementation";
      }
      {
        key = "<leader>pD";
        mode = "n";
        action = "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>";
        desc = "Preview declaration";
      }
      {
        key = "<leader>pc";
        mode = "n";
        action = "<cmd>lua require('goto-preview').close_all_win()<CR>";
        desc = "Close preview windows";
      }
    ]
    ++ lib.optionals config.vim.utility.snacks-nvim.enable [
      {
        key = "<leader>pr";
        mode = "n";
        action = "<cmd>lua require('goto-preview').goto_preview_references()<CR>";
        desc = "Preview references";
      }
    ];
}
