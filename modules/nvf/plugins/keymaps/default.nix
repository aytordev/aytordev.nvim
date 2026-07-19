# Global keymaps for plugins that don't auto-register them
{
  config,
  lib,
  ...
}: {
  config.vim.keymaps =
    lib.optionals config.vim.filetree.neo-tree.enable [
      {
        key = "<leader>e";
        mode = "n";
        action = "<cmd>Neotree toggle<CR>";
        desc = "Toggle file tree";
      }
    ]
    ++ lib.optionals config.vim.utility.oil-nvim.enable [
      {
        key = "-";
        mode = "n";
        action = "<cmd>Oil<CR>";
        desc = "Open parent directory (Oil)";
      }
      {
        key = "<leader>E";
        mode = "n";
        action = "<cmd>Oil --float<CR>";
        desc = "Open Oil (floating)";
      }
    ]
    ++ lib.optionals config.vim.utility.snacks-nvim.enable [
      {
        key = "<leader><space>";
        mode = "n";
        action = "<cmd>lua Snacks.picker.files()<CR>";
        desc = "Find files";
      }
      {
        key = "<leader>ff";
        mode = "n";
        action = "<cmd>lua Snacks.picker.files()<CR>";
        desc = "Find files";
      }
      {
        key = "<leader>fg";
        mode = "n";
        action = "<cmd>lua Snacks.picker.grep()<CR>";
        desc = "Live grep";
      }
      {
        key = "<leader>/";
        mode = "n";
        action = "<cmd>lua Snacks.picker.grep()<CR>";
        desc = "Grep";
      }
      {
        key = "<leader>fb";
        mode = "n";
        action = "<cmd>lua Snacks.picker.buffers()<CR>";
        desc = "Buffers";
      }
      {
        key = "<leader>fr";
        mode = "n";
        action = "<cmd>lua Snacks.picker.recent()<CR>";
        desc = "Recent files";
      }
      {
        key = "<leader>fh";
        mode = "n";
        action = "<cmd>lua Snacks.picker.help()<CR>";
        desc = "Help tags";
      }
    ]
    ++ lib.optionals config.aytordev.plugins."goto-preview" [
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
    ++ lib.optionals (config.aytordev.plugins."goto-preview" && config.aytordev.plugins.snacks) [
      {
        key = "<leader>pr";
        mode = "n";
        action = "<cmd>lua require('goto-preview').goto_preview_references()<CR>";
        desc = "Preview references";
      }
    ]
    ++ lib.optionals config.vim.utility.grug-far-nvim.enable [
      {
        key = "<leader>sr";
        mode = "n";
        action = "<cmd>GrugFar<CR>";
        desc = "Search and replace";
      }
    ]
    ++ lib.optionals config.vim.utility.diffview-nvim.enable [
      {
        key = "<leader>gd";
        mode = "n";
        action = "<cmd>DiffviewOpen<CR>";
        desc = "Open diff view";
      }
      {
        key = "<leader>gh";
        mode = "n";
        action = "<cmd>DiffviewFileHistory %<CR>";
        desc = "File history";
      }
      {
        key = "<leader>gq";
        mode = "n";
        action = "<cmd>DiffviewClose<CR>";
        desc = "Close diff view";
      }
    ]
    ++ lib.optionals config.aytordev.plugins."zen-mode" [
      {
        key = "<leader>z";
        mode = "n";
        action = "<cmd>ZenMode<CR>";
        desc = "Toggle zen mode";
      }
    ];
}
