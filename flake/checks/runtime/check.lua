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

local goto_preview = require("goto-preview")
if goto_preview.conf.references.provider ~= "snacks" then
  fail("goto-preview references provider is not Snacks")
end

for _, mapping in ipairs({ "pd", "pt", "pi", "pD", "pr", "pc" }) do
  if vim.fn.maparg("<leader>" .. mapping, "n") == "" then
    fail("<leader>" .. mapping .. " is not mapped")
  end
end
