# Global keymaps for plugins that don't auto-register them
{...}: {
  config.vim.keymaps = [
    # Neo-tree
    {
      key = "<leader>e";
      mode = "n";
      action = "<cmd>Neotree toggle<CR>";
      desc = "Toggle file tree";
    }

    # Oil
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

    # Snacks picker
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

    # Grug-far (search & replace)
    {
      key = "<leader>sr";
      mode = "n";
      action = "<cmd>GrugFar<CR>";
      desc = "Search and replace";
    }

    # Diffview
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

    # Zen mode
    {
      key = "<leader>z";
      mode = "n";
      action = "<cmd>ZenMode<CR>";
      desc = "Toggle zen mode";
    }
  ];
}
