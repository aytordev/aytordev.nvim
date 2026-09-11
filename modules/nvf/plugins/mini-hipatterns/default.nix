# Mini.hipatterns - highlight color patterns inline
# https://github.com/echasnovski/mini.hipatterns
{lib, ...}: {
  vim.mini.hipatterns = {
    enable = lib.mkDefault true;
    setupOpts.highlighters.hex_color = lib.mkLuaInline ''
      require("mini.hipatterns").gen_highlighter.hex_color()
    '';
  };
}
