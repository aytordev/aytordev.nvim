# Snacks.nvim utility suite (picker, bigfile, quickfile)
# https://github.com/folke/snacks.nvim
{
  config,
  lib,
  ...
}: {
  vim.utility.snacks-nvim = {
    enable = lib.mkDefault true;
    setupOpts = {
      picker.enabled = lib.mkDefault true;
      bigfile.enabled = lib.mkDefault true;
      quickfile.enabled = lib.mkDefault true;
    };
  };

  vim.keymaps = lib.optionals config.vim.utility.snacks-nvim.enable [
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
  ];
}
