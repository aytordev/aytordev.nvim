# Package profiles shared by the flake packages and the overlay, so the
# language set of every variant is defined exactly once.
{
  full = {
    name = "aytordev-nvim";
  };

  core = {
    name = "aytordev-nvim-core";
    languages = [
      "nix"
      "lua"
    ];
  };
}
