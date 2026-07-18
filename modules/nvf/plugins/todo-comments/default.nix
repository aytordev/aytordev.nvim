# Todo-comments highlight and search TODOs
# https://github.com/folke/todo-comments.nvim
{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aytordev.plugins."todo-comments" {
    vim.notes.todo-comments.enable = lib.mkDefault true;
  };
}
