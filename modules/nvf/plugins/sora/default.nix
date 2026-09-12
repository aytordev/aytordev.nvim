# Sora theme plugin
# https://github.com/Aejkatappaja/sora
#
# Sora is a single dark colorscheme (no light counterpart).
{
  config,
  pkgs,
  lib,
  ...
}: {
  vim.extraPlugins = lib.mkIf (config.aytordev.colorscheme == "sora") (
    assert lib.assertMsg (config.aytordev.style == "dark")
    "aytordev.nvim: colorscheme 'sora' is dark-only; set aytordev.style = \"dark\" (got '${config.aytordev.style}')"; {
      sora = {
        # Not in nixpkgs: package the upstream repository directly.
        package = pkgs.vimUtils.buildVimPlugin {
          name = "sora-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "Aejkatappaja";
            repo = "sora";
            rev = "504df4913c55dd9ad658e331b172f86b0537b439";
            hash = "sha256-uMfo36xLYMdafru4/eRE3o+MkuNVY1b+lPo+Ky4r3u8=";
          };
        };
        setup = ''
          require('sora').setup({
            transparent = ${lib.boolToString config.aytordev.transparent},
          })
          vim.cmd("colorscheme sora")
        '';
      };
    }
  );
}
