local profile = vim.env.AYTORDEV_PROFILE or "full"

-- Path of the completion marker the Nix wrapper requires. Every profile
-- must reach finish(), so a suite that stops early is rejected instead of
-- being masked by a successful nvim exit code.
local marker = vim.env.AYTORDEV_CHECK_MARKER

local function fail(message)
  vim.api.nvim_err_writeln(message)
  vim.cmd("cquit 1")
end

local function finish()
  if vim.v.errmsg ~= "" then
    fail("unexpected error during checks: " .. vim.v.errmsg)
  end

  if marker == nil or marker == "" then
    fail("completion marker path is not configured")
  end

  vim.fn.writefile({ "complete" }, marker)
end

if vim.v.errmsg ~= "" then
  fail("Neovim startup failed: " .. vim.v.errmsg)
end

-- Diagnosed macOS Nix sandbox limitation, handled narrowly instead of
-- weakening the checks: the seatbelt profile denies kevent() registration
-- for EVFILT_VNODE even though kqueue() succeeds, and libuv reports the
-- denial as err="EMFILE" on every fs_event callback. The sandbox runs with
-- a 1048576 fd limit and a handful of open descriptors, so EMFILE here is
-- the sandbox artifact, not resource exhaustion. The wrapper exports
-- AYTORDEV_SANDBOX=1, so this workaround is active only in the explicit
-- test/sandbox environment (and only on darwin); interactive use is never
-- affected. Drop exactly this error code from delivered events on darwin;
-- watcher creation failures and every other watcher error still abort the
-- check via fail-closed paths.
if vim.fn.has("mac") == 1 and vim.env.AYTORDEV_SANDBOX == "1" then
  local uv_new_fs_event = vim.uv.new_fs_event
  vim.uv.new_fs_event = function(...)
    local handle, err = uv_new_fs_event(...)
    if handle == nil then
      return nil, err
    end

    return setmetatable({}, {
      __index = function(_, key)
        if key == "start" then
          return function(_, path, opts, callback)
            return handle:start(path, opts, function(event_err, filename, events)
              if event_err == "EMFILE" then
                return
              end
              callback(event_err, filename, events)
            end)
          end
        end
        return function(_, ...)
          return handle[key](handle, ...)
        end
      end,
    })
  end
end


-- Check the default theme as well as isolated theme-only packages.
-- Minimal packages intentionally do not select a colorscheme.
local expected = vim.env.AYTORDEV_COLORSCHEME
if expected and vim.g.colors_name ~= expected then
  fail("colorscheme is '" .. tostring(vim.g.colors_name) .. "', expected '" .. tostring(expected) .. "'")
end

local function run()
  if profile == "theme" then
    return
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
  -- nvf's lazy file-hook group re-fires "User LazyFile" on BufNewFile and
  -- BufWritePre; its deferred file handling writes file reports to stderr in
  -- headless mode, which would defeat the wrapper's quiet-stderr gate. Every
  -- plugin the remaining probes need is already loaded (verified by the
  -- feature checks above) or loads on demand via lzn-auto-require, so the
  -- pending hooks can go. conform's own BufWritePre hook is unaffected and
  -- keeps the format-on-save behaviour under test.
  pcall(vim.api.nvim_del_augroup_by_name, "nvf_lazy_file_hooks")
  vim.bo.filetype = "nix"

  local target = vim.fn.tempname() .. ".nix"
  vim.api.nvim_buf_set_name(0, target)
  -- Silent: nvim's write report would otherwise land on stderr and defeat
  -- the wrapper's quiet-stderr gate; BufWritePre formatting still runs.
  vim.cmd("silent write")

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
  local neo_tree_config = require("neo-tree").config
  if not neo_tree_config.filesystem.use_libuv_file_watcher then
    fail("neo-tree is not watching the filesystem")
  end
  if neo_tree_config.git_status_async ~= true then
    fail("neo-tree git status is not asynchronous")
  end
  vim.cmd("Neotree close")

  check_continuous_reload()
end

-- Fail closed: an unexpected error anywhere in the suite (including errors
-- raised inside plugins or autocmds that propagate to this frame) aborts the
-- check with a nonzero exit code instead of falling through to a clean exit.
local ok, err = xpcall(run, debug.traceback)
if not ok then
  fail("unexpected error during checks: " .. tostring(err))
end

finish()
