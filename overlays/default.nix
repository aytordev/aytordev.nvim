{
  mkAytordevNeovim,
  profiles,
}: final: _prev: {
  aytordev-nvim = mkAytordevNeovim (profiles.full // {pkgs = final;});
  aytordev-nvim-core = mkAytordevNeovim (profiles.core // {pkgs = final;});
}
