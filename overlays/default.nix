{mkAytordevNeovim}: final: _prev: {
  aytordev-nvim = mkAytordevNeovim {
    pkgs = final;
    name = "aytordev-nvim";
  };
  aytordev-nvim-core = mkAytordevNeovim {
    pkgs = final;
    name = "aytordev-nvim-core";
    languages = [
      "nix"
      "lua"
    ];
  };
}
