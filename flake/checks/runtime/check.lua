local profile = vim.env.AYTORDEV_PROFILE or "full"

local function fail(message)
  vim.api.nvim_err_writeln(message)
  vim.cmd("cquit 1")
end

if vim.v.errmsg ~= "" then
  fail("Neovim startup failed: " .. vim.v.errmsg)
end

for _, command in ipairs({ "git", "rg", "fd" }) do
  if vim.fn.executable(command) ~= 1 then
    fail(command .. " is unavailable")
  end

  if vim.system({ command, "--version" }):wait().code ~= 0 then
    fail(command .. " failed to execute")
  end
end

if vim.fn.has("linux") == 1 then
  for _, command in ipairs({ "wl-copy", "xclip" }) do
    if vim.fn.executable(command) ~= 1 then
      fail(command .. " is unavailable")
    end
  end
end

local function check_continuous_reload()
  local watched = vim.fn.tempname() .. ".txt"
  vim.fn.writefile({ "before" }, watched)
  vim.cmd.edit(vim.fn.fnameescape(watched))
  vim.fn.writefile({ "after" }, watched)

  local reloaded = vim.wait(3000, function()
    return vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "after"
  end)

  if not reloaded then
    fail("files changed on disk are not reloaded continuously")
  end

  vim.cmd("bwipeout!")
end

if profile == "minimal" then
  for _, command in ipairs({ "Neotree", "GrugFar" }) do
    if vim.fn.exists(":" .. command) == 2 then
      fail(command .. " is still available with plugins disabled")
    end
  end

  if rawget(_G, "Snacks") ~= nil then
    fail("Snacks is still loaded with plugins disabled")
  end

  local disabled_plugins = { "snacks", "goto-preview", "conform", "lint" }
  for _, plugin in ipairs(disabled_plugins) do
    if pcall(require, plugin) then
      fail(plugin .. " is still installed with no plugins or languages enabled")
    end
  end

  if vim.opt.tabstop:get() ~= 2 then
    fail("editor options were not applied with plugins disabled")
  end

  check_continuous_reload()

  return
end

local lsp_attached = vim.wait(10000, function()
  return #vim.lsp.get_clients({ bufnr = 0 }) > 0
end)

if not lsp_attached then
  fail("No LSP client attached to a Nix file")
end

local features = {
  ["Neotree command"] = vim.fn.exists(":Neotree") == 2,
  ["GrugFar command"] = vim.fn.exists(":GrugFar") == 2,
  ["Snacks API"] = type(rawget(_G, "Snacks")) == "table",
}

for feature, available in pairs(features) do
  if not available then
    fail(feature .. " is unavailable")
  end
end

local hipatterns = require("mini.hipatterns")
if type(hipatterns.config.highlighters.hex_color) ~= "table" then
  fail("mini.hipatterns hex color highlighter is not configured")
end

local autoread_ok, autoread = pcall(vim.api.nvim_get_autocmds, {
  group = "aytordev_editor_autoread",
  event = "FocusGained",
})
if not autoread_ok or #autoread ~= 1 then
  fail("checktime autocommand is missing or duplicated")
end

local goto_preview = require("goto-preview")
if goto_preview.conf.references.provider ~= "snacks" then
  fail("goto-preview references provider is not Snacks")
end

for _, mapping in ipairs({ "pd", "pt", "pi", "pD", "pr", "pc" }) do
  if vim.fn.maparg("<leader>" .. mapping, "n") == "" then
    fail("<leader>" .. mapping .. " is not mapped")
  end
end

local conform = require("conform")
if vim.fn.executable(conform.formatters.alejandra.command) ~= 1 then
  fail("the configured Nix formatter command is not executable")
end

vim.cmd("enew")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "{a=1;}" })
vim.bo.filetype = "nix"

local target = vim.fn.tempname() .. ".nix"
vim.api.nvim_buf_set_name(0, target)
vim.cmd("write")

local saved = table.concat(vim.fn.readfile(target), "\n")
if not saved:find("a = 1", 1, true) then
  fail("format on save did not format the Nix buffer: " .. saved)
end

local lint = require("lint")
local nix_linters = lint.linters_by_ft.nix or {}
if #nix_linters == 0 then
  fail("nvim-lint has no Nix linters configured")
end

for _, name in ipairs(nix_linters) do
  if lint.linters[name] == nil then
    fail("nvim-lint is missing the " .. name .. " linter")
  end
end

vim.cmd("Neotree show")
if not require("neo-tree").config.filesystem.use_libuv_file_watcher then
  fail("neo-tree is not watching the filesystem")
end
vim.cmd("Neotree close")

check_continuous_reload()
