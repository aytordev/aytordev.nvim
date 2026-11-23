#!/usr/bin/env bash
# Local benchmark: median time until a known file becomes visible in Neo-tree,
# measured across fresh packaged Neovim sessions.
#
# This is a local diagnostic tool only. It reports a human-readable median and
# never enforces a CI time budget: a slow result prints a slow median and still
# exits 0. The script fails only on real errors (missing binary, failed fixture
# setup, a run that times out).
#
# Usage: scripts/bench-neotree.sh [--runs N] [--nvim PATH] [--timeout SECS]
set -euo pipefail

usage() {
  echo "usage: $0 [--runs N] [--nvim PATH] [--timeout SECS]" >&2
  echo "  --runs N      number of fresh Neovim sessions (default: 7)" >&2
  echo "  --nvim PATH   packaged Neovim binary (default: result/bin/nvim)" >&2
  echo "  --timeout SECS  per-run visibility timeout in seconds (default: 120)" >&2
}

runs=7
nvim_bin=""
timeout_secs=120

while [[ $# -gt 0 ]]; do
  case "$1" in
    --runs)
      [[ $# -ge 2 ]] || { usage; exit 1; }
      runs="$2"
      shift 2
      ;;
    --nvim)
      [[ $# -ge 2 ]] || { usage; exit 1; }
      nvim_bin="$2"
      shift 2
      ;;
    --timeout)
      [[ $# -ge 2 ]] || { usage; exit 1; }
      timeout_secs="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "bench-neotree: unknown argument '$1'" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$runs" -lt 1 ]] || [[ "$timeout_secs" -lt 1 ]]; then
  echo "bench-neotree: --runs and --timeout must be >= 1" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -z "$nvim_bin" ]]; then
  nvim_bin="$script_dir/../result/bin/nvim"
fi

if [[ ! -x "$nvim_bin" ]]; then
  echo "bench-neotree: Neovim binary not found or not executable: '$nvim_bin'" >&2
  echo "bench-neotree: run 'just build' first, or pass --nvim <path>" >&2
  exit 1
fi

# Scratch state lives only in a fresh system temp directory, never in the
# worktree. The trap removes it on every exit path.
fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/bench-neotree.XXXXXX")"
results_file="$fixture_root/results.txt"
cleanup() {
  rm -rf "$fixture_root"
}
trap cleanup EXIT

# Reproducible Git fixture: the same tree on every invocation, so run-to-run
# differences come from Neovim/Neo-tree, not from the file set.
repo="$fixture_root/repo"
git init -q "$repo"
git -C "$repo" config user.email "bench@example.invalid"
git -C "$repo" config user.name "bench-fixture"
mkdir -p "$repo/alpha" "$repo/beta" "$repo/gamma"
for dir in alpha beta gamma; do
  for i in 1 2 3 4 5 6 7 8; do
    printf 'deterministic fixture content %s/%s\n' "$dir" "$i" > "$repo/$dir/file-$i.txt"
  done
done
known_file="bench-known-target.md"
printf 'known benchmark target visible in Neo-tree\n' > "$repo/$known_file"
git -C "$repo" add -A
git -C "$repo" commit -qm "benchmark fixture"

# Poller loaded into each fresh session via -c luafile. Startup t0 is captured
# by --cmd before any configuration runs, so the measurement covers config load,
# plugin setup, the Neo-tree window open, and the first on-screen render of the
# known file in the current tab's Neo-tree window. A hidden neo-tree buffer or
# a target scrolled outside the window never counts (see
# scripts/bench-neotree-test.sh).
echo "Neo-tree first-visible benchmark"
echo "  nvim: $nvim_bin"
echo "  runs: $runs (per-run timeout: ${timeout_secs}s)"
echo "  fixture: $repo (temporary, deleted on exit)"

run_index=0
while [[ "$run_index" -lt "$runs" ]]; do
  run_index=$((run_index + 1))
  before=0
  if [[ -f "$results_file" ]]; then
    before="$(wc -l < "$results_file")"
  fi
  # Each iteration is a fresh packaged Neovim process with its own config load.
  # A timeout run exits non-zero via :cq! but is recorded, not silent.
  env \
    BENCH_KNOWN_FILE="$known_file" \
    BENCH_RESULTS="$results_file" \
    BENCH_TIMEOUT_MS="$((timeout_secs * 1000))" \
    "$nvim_bin" --headless \
    --cmd 'lua _G.__bench_t0 = vim.uv.hrtime()' \
    "$repo" \
    -c "luafile $script_dir/bench-neotree-poll.lua" >/dev/null 2>&1 || true
  after="$(wc -l < "$results_file")"
  if [[ "$after" -le "$before" ]]; then
    echo "bench-neotree: run $run_index produced no result (session crashed before recording)" >&2
    exit 1
  fi
  last="$(tail -n 1 "$results_file")"
  if [[ "$last" == "timeout" ]]; then
    echo "bench-neotree: run $run_index timed out after ${timeout_secs}s without showing '$known_file'" >&2
    exit 1
  fi
  echo "  run $run_index: $last ms"
done

median="$(sort -g "$results_file" | awk '
  { values[NR] = $1 }
  END {
    if (NR % 2 == 1) {
      printf "%.1f", values[(NR + 1) / 2]
    } else {
      printf "%.1f", (values[NR / 2] + values[NR / 2 + 1]) / 2
    }
  }')"

echo "  median: $median ms over $runs runs"
