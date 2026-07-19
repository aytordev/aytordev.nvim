{
  config,
  lib,
  pkgs,
  ...
}: let
  clipboardEnabled = config.aytordev.clipboard != "none";
  providerEnabled = provider:
    clipboardEnabled
    && pkgs.stdenv.hostPlatform.isLinux
    && builtins.elem provider config.aytordev.clipboardProviders;
in {
  config.vim = {
    viAlias = lib.mkDefault config.aytordev.viAlias;
    vimAlias = lib.mkDefault config.aytordev.vimAlias;

    extraPackages = [
      pkgs.fd
      pkgs.gitMinimal
      pkgs.ripgrep
    ];

    clipboard = {
      enable = lib.mkDefault clipboardEnabled;
      registers = lib.mkDefault (
        if clipboardEnabled
        then config.aytordev.clipboard
        else ""
      );
      providers = {
        wl-copy.enable = lib.mkDefault (providerEnabled "wl-copy");
        xclip.enable = lib.mkDefault (providerEnabled "xclip");
        xsel.enable = lib.mkDefault (providerEnabled "xsel");
      };
    };

    searchCase = lib.mkDefault "smart";
    undoFile.enable = lib.mkDefault true;

    globals = lib.mapAttrs (_: value: lib.mkDefault value) {
      maplocalleader = " ";
      markdown_recommended_style = 0;
    };

    options = lib.mapAttrs (_: value: lib.mkDefault value) {
      autoread = true;
      autowrite = true;
      confirm = true;
      mouse = "a";
      showmode = false;
      formatoptions = "jcroqlnt";

      tabstop = config.aytordev.tabWidth;
      shiftwidth = config.aytordev.tabWidth;
      shiftround = true;
      smartindent = true;
      copyindent = true;
      breakindent = true;

      cursorline = true;
      laststatus = 3;
      conceallevel = 2;
      linebreak = true;
      wrap = false;
      pumblend = 10;
      pumheight = 10;
      fillchars = "eob: ";

      inccommand = "split";
      grepprg = "rg --vimgrep";
      grepformat = "%f:%l:%c:%m";
      infercase = true;

      scrolloff = 8;
      sidescrolloff = 8;
      smoothscroll = true;
      virtualedit = "block";
      splitkeep = "screen";

      tm = 300;
      updatetime = 200;

      undolevels = 10000;
      sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds";

      winminwidth = 5;
      wildmode = "longest:full,full";
      spelllang = "en";
    };

    luaConfigRC.editorShortmess = lib.nvim.dag.entryAfter ["optionsScript"] ''
      vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
    '';

    luaConfigRC.editorAutoread = lib.nvim.dag.entryAfter ["optionsScript"] ''
      vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
        command = "checktime",
      })
    '';
  };
}
