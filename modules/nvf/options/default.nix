{
  config,
  lib,
  ...
}: {
  config.vim = {
    viAlias = config.aytordev.viAlias;
    vimAlias = config.aytordev.vimAlias;

    searchCase = "smart";
    undoFile.enable = true;

    globals = {
      maplocalleader = " ";
      markdown_recommended_style = 0;
    };

    options =
      {
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
      }
      // lib.optionalAttrs (config.aytordev.clipboard != "none") {
        clipboard = config.aytordev.clipboard;
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
