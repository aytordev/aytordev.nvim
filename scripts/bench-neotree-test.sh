#!/usr/bin/env bash
# Behaviour tests for the Neo-tree first-visible benchmark poller
# (scripts/bench-neotree-poll.lua), run against the packaged Neovim binary.
#
# Proves at the session level:
#   hidden    - a hidden neo-tree buffer containing the target must NOT count
#               as visible (no tree window shows it): the run must time out
#               and record no value.
#   offscreen - the target present in the tree buffer but scrolled outside the
#               window's on-screen lines must NOT count: timeout, no value.
#   visible   - the target shown in the tree window's on-screen lines records
#               a value and exits 0.
#
# Usage: scripts/bench-neotree-test.sh [nvim-binary]
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
poller="$script_dir/bench-neotree-poll.lua"
nvim_bin="${1:-$script_dir/../result/bin/nvim}"

if [[ ! -x "$nvim_bin" ]]; then
  echo "bench-neotree-test: Neovim binary not found or not executable: '$nvim_bin'" >&2
  echo "bench-neotree-test: run 'just build' first, or pass a binary path" >&2
  exit 1
fi

tmp="$(mktemp -d "${TMPDIR:-/tmp}/bench-neotree-test.XXXXXX")"
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

results="$tmp/results.txt"
timeout_ms=5000
target="bench-known-target.md"
failures=0

make_repo() { # $1 = repo dir, $2 = with-target (1/0)
  local repo="$1"
  git init -q "$repo"
  git -C "$repo" config user.email "test@example.invalid"
  git -C "$repo" config user.name "bench-test"
  mkdir -p "$repo/alpha"
  local i
  # Root-level files keep the tree buffer much longer than the headless
  # window height (24 rows), so scrolling to the last line can genuinely push
  # the alphabetically-first target offscreen. Collapsed folders render only
  # one line each, so subdirectory files do not lengthen the buffer.
  for i in $(seq 1 200); do
    printf 'fixture %s\n' "$i" > "$repo/file-$(printf '%03d' "$i").txt"
  done
  if [[ "$2" == 1 ]]; then
    printf 'known benchmark target visible in Neo-tree\n' > "$repo/$target"
  fi
  git -C "$repo" add -A
  git -C "$repo" commit -qm "fixture"
}

# run_scenario <name> <repo> <wrapper-lua-file> <expect: record|timeout>
run_scenario() {
  local name="$1" repo="$2" wrapper="$3" expect="$4"
  : > "$results"
  local rc=0
  env \
    BENCH_KNOWN_FILE="$target" \
    BENCH_RESULTS="$results" \
    BENCH_TIMEOUT_MS="$timeout_ms" \
    BENCH_POLLER="$poller" \
    "$nvim_bin" --headless \
    --cmd 'lua _G.__bench_t0 = vim.uv.hrtime()' \
    "$repo" \
    -c "luafile $wrapper" >/dev/null 2>&1 || rc=$?

  local recorded
  recorded="$(grep -Ec '^[0-9]+\.[0-9]+$' "$results" || true)"
  if [[ "$expect" == "timeout" ]]; then
    if [[ "$recorded" -gt 0 ]]; then
      echo "FAIL [$name]: recorded a value but target must not be visible (results: $(tr '\n' ' ' < "$results"))" >&2
      failures=$((failures + 1))
    elif [[ "$rc" -eq 0 ]]; then
      echo "FAIL [$name]: exited 0 without a timeout; poller did not run or timed out silently" >&2
      failures=$((failures + 1))
    else
      echo "ok   [$name]: no value recorded, timed out as required (rc=$rc)"
    fi
  else
    if [[ "$recorded" -eq 1 && "$rc" -eq 0 ]]; then
      echo "ok   [$name]: recorded $(cat "$results") ms, exit 0"
    else
      echo "FAIL [$name]: expected one recorded value and exit 0, got rc=$rc results='$(tr '\n' ' ' < "$results")'" >&2
      failures=$((failures + 1))
    fi
  fi
}

# --- hidden: a hidden neo-tree buffer contains the target, but no window ---
# shows it. Repo does NOT contain the target, so a real visible tree could
# never legitimately count; the fake buffer is the only hit.
repo_hidden="$tmp/repo-hidden"
make_repo "$repo_hidden" 0
cat > "$tmp/hidden.lua" <<'EOF'
local uv = vim.uv
-- A buffer named like Neo-tree's, holding the target, never displayed in a
-- window. The old buffer-scan poller counted this as a false positive.
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_name(buf, "neo-tree filesystem [1]")
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
  "alpha/",
  "  " .. vim.env.BENCH_KNOWN_FILE,
  "beta/",
})
dofile(vim.env.BENCH_POLLER)
EOF

# --- offscreen: the real tree window is open with the target rendered, but
# scrolled so the target is outside the window's visible lines.
repo_offscreen="$tmp/repo-offscreen"
make_repo "$repo_offscreen" 1
cat > "$tmp/offscreen.lua" <<'EOF'
local uv = vim.uv
local known = vim.env.BENCH_KNOWN_FILE
-- Wait until the real tree buffer has rendered the target (buffer-level hit
-- is exactly the condition the old poller wrongly accepted), then scroll the
-- tree window to its last line so the target is offscreen, and only then
-- start the poller.
local deadline = uv.hrtime() + 4e9
local function tree_buffer_has_target()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(b):find("neo-tree", 1, true) then
      local ok, lines = pcall(vim.api.nvim_buf_get_lines, b, 0, -1, false)
      if ok then
        for _, line in ipairs(lines) do
          if line:find(known, 1, true) then
            return true
          end
        end
      end
    end
  end
  return false
end
local t = uv.new_timer()
t:start(0, 20, function()
  vim.schedule(function()
    if tree_buffer_has_target() then
      t:stop()
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b = vim.api.nvim_win_get_buf(w)
        if vim.api.nvim_buf_get_name(b):find("neo-tree", 1, true) then
          vim.api.nvim_win_call(w, function()
            vim.cmd("normal! G")
          end)
        end
      end
      -- Guard: the scroll must actually move the window top line below the
      -- target; otherwise the scenario would not exercise offscreen at all.
      local scrolled = false
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b = vim.api.nvim_win_get_buf(w)
        if vim.api.nvim_buf_get_name(b):find("neo-tree", 1, true) then
          if vim.fn.line("w0", w) > 1 then
            scrolled = true
          end
        end
      end
      if not scrolled then
        t:stop()
        io.stderr:write("bench-neotree-test: could not scroll target offscreen (buffer shorter than window?)\n")
        vim.cmd("cq!")
        return
      end
      dofile(vim.env.BENCH_POLLER)
    elseif uv.hrtime() > deadline then
      t:stop()
      io.stderr:write("bench-neotree-test: tree buffer never rendered the target\n")
      vim.cmd("cq!")
    end
  end)
end)
EOF

# --- visible control: plain session; the auto-opened tree shows the target.
repo_visible="$tmp/repo-visible"
make_repo "$repo_visible" 1
cat > "$tmp/visible.lua" <<'EOF'
dofile(vim.env.BENCH_POLLER)
EOF

run_scenario hidden "$repo_hidden" "$tmp/hidden.lua" timeout
run_scenario offscreen "$repo_offscreen" "$tmp/offscreen.lua" timeout
run_scenario visible "$repo_visible" "$tmp/visible.lua" record

if [[ "$failures" -gt 0 ]]; then
  echo "bench-neotree-test: $failures failure(s)" >&2
  exit 1
fi
echo "bench-neotree-test: all scenarios passed"
