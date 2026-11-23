-- Independent, reproducible calibration runner for scripts/bench-reload.lua.
--
-- It injects 12ms of busy work INSIDE the measured command of every tick
-- (between the tick firing and the sample being recorded, never before the
-- callback and never after the measurement), then executes the normal
-- benchmark. The public report must detect the injected cost (median jumps to
-- about 12ms) and classify the poll cost as material; the benchmark's own
-- calibration self-check exits non-zero if the measurement misses it.
--
-- Run with the packaged Neovim:
--
--   nix run .#default -- --headless "+luafile scripts/bench-reload-calibration.lua" "+qa"

vim.env.AYTORDEV_BENCH_RELOAD_CALIBRATION_MS = "12"

local here = (debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]+$") or ".")
dofile(here .. "/bench-reload.lua")
