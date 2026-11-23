-- bench-reload.lua: repeatable benchmark and verification for the editor's
-- file-change reloading (a one-second uv timer that runs `checktime`, plus
-- focus autocommands; see modules/nvf/options/default.nix).
--
-- Run it with the packaged Neovim so the distribution configuration is active:
--
--   nix run .#default -- --headless "+luafile scripts/bench-reload.lua" "+qa"
--
-- What it does:
--   1. Measures the ACTUAL per-tick cost of the shipped poll callback at the
--      shipped one-second cadence: the watcher handle is taken over and an
--      instrumented timer with the identical callback body (same
--      schedule_wrap dispatch, same `silent checktime`) records the wall time
--      of each real tick, spaced a full second apart. No synchronous burst of
--      back-to-back `checktime` calls is used, because a burst amortizes
--      per-call cost and hides what one isolated tick costs.
--   2. Verifies that unmodified buffers reload after an external direct write
--      and after an external atomic rename, and that unsaved edits survive
--      external changes while the poll loop runs.
--   3. Prints a report and exits non-zero if any verification fails.
--
-- Fixture files live in a temporary directory that is removed before exit.

local uv = vim.uv or vim.loop

local POLL_INTERVAL_MS = 1000 -- matches the shipped watcher interval
local MATERIAL_SHARE = 0.01 -- a tick cost above this share of the interval is material
local REAL_TICKS = 8 -- real watcher ticks timed per scenario (one per second)
-- Calibration: when set, this many milliseconds of busy work are injected
-- INSIDE the measured command of every tick (between the tick firing and the
-- sample being recorded), never before the callback or after the measurement.
-- The public report must detect the injected cost and classify it material.
local CALIBRATION_MS = math.max(0, tonumber(vim.env.AYTORDEV_BENCH_RELOAD_CALIBRATION_MS) or 0)
local FEW_BUFFERS = 5
local MANY_BUFFERS = 200
local FIXTURE_LINES = 200
local RELOAD_TIMEOUT_MS = 3000

local failures = {}
local owned_buffers = {}
local owned_dirs = {}

local function report(message)
  print(message)
end

local function fail(message)
  failures[#failures + 1] = message
  print("FAIL: " .. message)
end

local function buffer_line(bufnr)
  return vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
end

local function make_fixture_dir(name)
  local dir = vim.fn.tempname() .. "-bench-reload-" .. name
  vim.fn.mkdir(dir, "p")
  owned_dirs[#owned_dirs + 1] = dir
  return dir
end

local function write_fixture(dir, index, lines, first_line)
  local path = string.format("%s/%03d.txt", dir, index)
  local content = { first_line or string.format("file %d line 1", index) }
  for i = 2, lines do
    content[#content + 1] = string.format("file %d line %d", index, i)
  end
  vim.fn.writefile(content, path)
  return path
end

local function load_buffer(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  local bufnr = vim.api.nvim_get_current_buf()
  owned_buffers[#owned_buffers + 1] = bufnr
  return bufnr
end

local function count_loaded_listed_buffers()
  local loaded = 0
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if vim.api.nvim_buf_is_loaded(info.bufnr) then
      loaded = loaded + 1
    end
  end
  return loaded
end

-- Spins (does not yield) for `ms` milliseconds: the calibration's injected
-- work, so it lands inside the measured command.
local function busy_sleep(ms)
  local deadline = uv.hrtime() + ms * 1e6
  while uv.hrtime() < deadline do
  end
end

local function percentile(sorted, share)
  local index = math.max(1, math.min(#sorted, math.ceil(share * #sorted)))
  return sorted[index]
end

-- Measures actual shipped-callback ticks at the shipped cadence: stops the
-- shipped watcher and replaces it with an instrumented timer running the
-- identical callback body (schedule_wrap dispatch plus `silent checktime`) at
-- the identical 1000ms interval. Each sample is the wall time from the timer
-- firing to the scheduled body finishing, so the schedule dispatch is
-- included. The instrumented timer keeps running afterwards, so reload
-- verifications below still run through the same callback at the same cadence.
local function take_over_watcher()
  local shipped = _G.aytordev_file_watcher
  if shipped ~= nil then
    -- Stop only, never close: the shipped VimLeavePre autocmd closes this
    -- exact handle through its own upvalue at shutdown, so closing it here
    -- would make teardown error with "handle is already closing".
    shipped:stop()
  end

  local samples = {}
  local timer = uv.new_timer()
  timer:start(POLL_INTERVAL_MS, POLL_INTERVAL_MS, function()
    local fired = uv.hrtime()
    vim.schedule_wrap(function()
      if fired ~= nil then
        -- The measured command spans everything between the tick firing and
        -- the sample being recorded: dispatch latency, injected calibration
        -- work (inside the command, never before the callback or after the
        -- measurement), and the poll body itself.
        if CALIBRATION_MS > 0 then
          busy_sleep(CALIBRATION_MS)
        end
        vim.cmd("silent checktime")
        samples[#samples + 1] = { started = fired, delta = (uv.hrtime() - fired) / 1000 } -- microseconds
        fired = nil
      end
    end)()
  end)

  _G.aytordev_file_watcher = timer
  return samples
end

local function measure_real_ticks(samples, wanted, window_started)
  vim.wait((wanted + 2) * POLL_INTERVAL_MS, function()
    local count = 0
    for _, sample in ipairs(samples) do
      if sample.started >= window_started then
        count = count + 1
      end
    end
    return count >= wanted
  end)
  local sorted = {}
  for _, sample in ipairs(samples) do
    if sample.started >= window_started then
      sorted[#sorted + 1] = sample.delta
    end
  end
  table.sort(sorted)
  local total = 0
  for _, value in ipairs(sorted) do
    total = total + value
  end
  return {
    ticks = #sorted,
    median = percentile(sorted, 0.5),
    p99 = percentile(sorted, 0.99),
    max = sorted[#sorted],
    mean = total / math.max(1, #sorted),
  }
end

local function fmt_us(value)
  if value >= 1000 then
    return string.format("%.2fms", value / 1000)
  end
  return string.format("%.1fus", value)
end

local function report_bench(label, bench)
  report(
    string.format(
      "real watcher tick, %s: median %s  mean %s  p99 %s  max %s  (%d actual ticks at %dms cadence)",
      label,
      fmt_us(bench.median),
      fmt_us(bench.mean),
      fmt_us(bench.p99),
      fmt_us(bench.max),
      bench.ticks,
      POLL_INTERVAL_MS
    )
  )
end

local function wait_for_reload(bufnr, expected, timeout)
  local started = uv.hrtime()
  local ok = vim.wait(timeout, function()
    return buffer_line(bufnr) == expected
  end)
  return ok, (uv.hrtime() - started) / 1e6 -- milliseconds
end

local function verify_direct_write(dir)
  local path = write_fixture(dir, 1, FIXTURE_LINES, "direct-write-before")
  local bufnr = load_buffer(path)
  vim.fn.writefile({ "direct-write-after" }, path)
  local ok, elapsed = wait_for_reload(bufnr, "direct-write-after", RELOAD_TIMEOUT_MS)
  if not ok then
    fail("external direct write did not reload the buffer within " .. RELOAD_TIMEOUT_MS .. "ms")
  else
    report(string.format("external direct write reloaded: yes (observed after %.0fms)", elapsed))
  end
end

local function verify_atomic_rename(dir)
  local path = write_fixture(dir, 2, FIXTURE_LINES, "atomic-rename-before")
  local bufnr = load_buffer(path)
  local staged = path .. ".staged"
  vim.fn.writefile({ "atomic-rename-after" }, staged)
  vim.fn.rename(staged, path)
  local ok, elapsed = wait_for_reload(bufnr, "atomic-rename-after", RELOAD_TIMEOUT_MS)
  if not ok then
    fail("external atomic rename did not reload the buffer within " .. RELOAD_TIMEOUT_MS .. "ms")
  else
    report(string.format("external atomic rename reloaded: yes (observed after %.0fms)", elapsed))
  end
end

local function verify_unsaved_edits_preserved(dir)
  local path = write_fixture(dir, 3, FIXTURE_LINES, "unsaved-before")
  local bufnr = load_buffer(path)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "unsaved-local-edit" })
  if not vim.bo[bufnr].modified then
    fail("the local edit did not mark the buffer modified")
    return
  end

  -- The poll loop runs while the buffer has unsaved changes, and the external
  -- change lands on the unsaved buffer's file too, so the assertions prove the
  -- reload machinery saw the change and still left the buffer alone.
  vim.fn.writefile({ "unsaved-disk-change" }, path)

  -- A sentinel reload proves the poll loop actually ran (a single `checktime`
  -- pass covers every buffer, including the modified one).
  local sentinel_path = write_fixture(dir, 4, FIXTURE_LINES, "sentinel-before")
  local sentinel = load_buffer(sentinel_path)
  vim.fn.writefile({ "sentinel-after" }, sentinel_path)
  local ok = wait_for_reload(sentinel, "sentinel-after", RELOAD_TIMEOUT_MS)
  if not ok then
    fail("the sentinel file was not reloaded, so the poll loop never ran")
    return
  end

  local disk_text = table.concat(vim.fn.readfile(path), "\n")
  if not disk_text:find("unsaved%-disk%-change", 1, false) then
    fail("the external change to the unsaved buffer's file did not reach disk: " .. disk_text)
  elseif buffer_line(bufnr) ~= "unsaved-local-edit" then
    fail("unsaved edits were clobbered by the external change: " .. tostring(buffer_line(bufnr)))
  elseif not vim.bo[bufnr].modified then
    fail("the unsaved buffer lost its modified flag")
  else
    report("unsaved edits preserved: yes (external change reached disk; sentinel reload confirmed the poll loop saw it)")
  end
end

local function cleanup()
  for _, bufnr in ipairs(owned_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      pcall(vim.cmd, "bwipeout! " .. bufnr)
    end
  end
  for _, dir in ipairs(owned_dirs) do
    vim.fn.delete(dir, "rf")
  end
end

local function main()
  report("== aytordev.nvim reload benchmark ==")
  local shipped = _G.aytordev_file_watcher
  if shipped == nil then
    report("warning: the aytordev file watcher is not active; measurement and reload verifications will fail without it")
  end

  local samples = {} -- each entry is { started = hrtime at tick fire, delta = measured microseconds }
  if shipped ~= nil then
    samples = take_over_watcher()
    report("measurement: shipped watcher callback instrumented at the shipped " .. POLL_INTERVAL_MS .. "ms cadence (schedule dispatch included)")
  end

  -- A tick that fires while the script is busy (loading fixtures) is starved
  -- until the loop yields; its sample measures queuing delay, not callback
  -- work. Ticks are only counted from `window_started` onwards.
  local window_started = uv.hrtime()
  local function count_in_window()
    local count = 0
    for _, sample in ipairs(samples) do
      if sample.started >= window_started then
        count = count + 1
      end
    end
    return count
  end

  -- Few loaded buffers.
  local few_dir = make_fixture_dir("few")
  for i = 1, FEW_BUFFERS do
    load_buffer(write_fixture(few_dir, i, FIXTURE_LINES))
  end
  if shipped ~= nil then
    local few_bench = measure_real_ticks(samples, REAL_TICKS, window_started)
    report_bench(string.format("%d loaded buffers", count_loaded_listed_buffers()), few_bench)
  end

  -- Many loaded buffers: all fixtures are ordinary files, actually loaded.
  local many_dir = make_fixture_dir("many")
  for i = 1, MANY_BUFFERS do
    load_buffer(write_fixture(many_dir, i, FIXTURE_LINES))
  end
  local loaded = count_loaded_listed_buffers()
  local many_bench
  if shipped ~= nil then
    window_started = uv.hrtime() -- idle again after the load loop
    many_bench = measure_real_ticks(samples, REAL_TICKS, window_started)
    report_bench(string.format("%d loaded buffers", loaded), many_bench)
  end

  if CALIBRATION_MS > 0 then
    report("calibration: injecting " .. CALIBRATION_MS .. "ms of busy work inside the measured command of every tick")
    if shipped ~= nil then
      local expected_us = CALIBRATION_MS * 1000
      if many_bench.median < expected_us * 0.5 then
        fail(
          string.format(
            "calibration: the injected %dms inside the measured command was not detected (median %s, expected at least %.1fms)",
            CALIBRATION_MS,
            fmt_us(many_bench.median),
            expected_us * 0.5 / 1000
          )
        )
      else
        report(
          string.format(
            "calibration: the injected %dms inside the measured command was detected (median %s)",
            CALIBRATION_MS,
            fmt_us(many_bench.median)
          )
        )
      end
    end
  end

  if shipped ~= nil then
    local worst_share = many_bench.max / (POLL_INTERVAL_MS * 1000)
    if worst_share <= MATERIAL_SHARE then
      report(
        string.format(
          "decision: idle poll cost is not material (worst actual tick %.3f%% of the %dms interval, threshold %.0f%%) — polling retained",
          worst_share * 100,
          POLL_INTERVAL_MS,
          MATERIAL_SHARE * 100
        )
      )
    else
      report(
        string.format(
          "decision: idle poll cost is material (worst actual tick %.3f%% of the %dms interval exceeds the %.0f%% threshold)",
          worst_share * 100,
          POLL_INTERVAL_MS,
          MATERIAL_SHARE * 100
        )
      )
    end
  end

  -- Reload behavior through the real watcher, not a manual `checktime`.
  report("verification:")
  local verify_dir = make_fixture_dir("verify")
  verify_direct_write(verify_dir)
  verify_atomic_rename(verify_dir)
  verify_unsaved_edits_preserved(verify_dir)

  cleanup()

  if #failures > 0 then
    vim.api.nvim_err_writeln("bench-reload: " .. #failures .. " verification failure(s)")
    vim.cmd("cquit 1")
    return
  end
  report("result: PASS (" .. loaded .. " buffers loaded at measurement time)")
end

local ok, err = pcall(main, nil)
if not ok then
  cleanup()
  vim.api.nvim_err_writeln("bench-reload: benchmark crashed: " .. tostring(err))
  vim.cmd("cquit 1")
end
