local uv = vim.uv
local known = vim.env.BENCH_KNOWN_FILE
local results_path = vim.env.BENCH_RESULTS
local timeout_ms = tonumber(vim.env.BENCH_TIMEOUT_MS) or 120000
local t0 = _G.__bench_t0 or uv.hrtime()

local function record(value)
  local f = assert(io.open(results_path, "a"))
  f:write(value .. "\n")
  f:close()
end

-- A hit requires the target to be inside the on-screen lines (w0..w$) of an
-- actual neo-tree window on the current tabpage. A hidden neo-tree buffer, or
-- a target scrolled outside the window, never counts.
local function window_shows(win, target)
  local buf = vim.api.nvim_win_get_buf(win)
  local ok_first, first = pcall(vim.fn.line, "w0", win)
  local ok_last, last = pcall(vim.fn.line, "w$", win)
  if not (ok_first and ok_last) or last < first then
    return false
  end
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, first - 1, last, false)
  if not ok then
    return false
  end
  for _, line in ipairs(lines) do
    if line:find(target, 1, true) then
      return true
    end
  end
  return false
end

local function known_visible()
  local ok_tab, tabpage = pcall(vim.api.nvim_get_current_tabpage)
  if not ok_tab then
    return false
  end
  local ok_wins, wins = pcall(vim.api.nvim_tabpage_list_wins, tabpage)
  if not ok_wins then
    return false
  end
  for _, win in ipairs(wins) do
    local ok_buf, buf = pcall(vim.api.nvim_win_get_buf, win)
    if ok_buf and vim.api.nvim_buf_get_name(buf):find("neo-tree", 1, true) then
      if window_shows(win, known) then
        return true
      end
    end
  end
  return false
end

local done = false
local timer = uv.new_timer()
timer:start(0, 10, function()
  if done then
    return
  end
  vim.schedule(function()
    if done then
      return
    end
    if known_visible() then
      done = true
      timer:stop()
      record(string.format("%.1f", (uv.hrtime() - t0) / 1e6))
      vim.cmd("qa!")
    elseif (uv.hrtime() - t0) / 1e6 > timeout_ms then
      done = true
      timer:stop()
      record("timeout")
      vim.cmd("cq!")
    end
  end)
end)
