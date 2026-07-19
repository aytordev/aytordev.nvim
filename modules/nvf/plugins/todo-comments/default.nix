# Todo-comments highlight and search TODOs
# https://github.com/folke/todo-comments.nvim
{lib, ...}: {
  vim.notes.todo-comments.enable = lib.mkDefault true;
}
