{
  mkAytordevNeovim,
  profiles,
  ...
}: {
  flake.overlays.default = import ../../overlays {
    inherit mkAytordevNeovim profiles;
  };
}
