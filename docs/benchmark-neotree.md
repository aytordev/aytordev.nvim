# Neo-tree first-visible benchmark

Local recipe that measures how long it takes Neo-tree to make a known file
visible, across fresh sessions of the packaged Neovim build. It is a
diagnostic tool, not a gate: there is no CI time budget, and no step enforces
a threshold on the measured median.

## Usage

```console
just bench-neotree              # 7 runs, binary from result/bin/nvim
just bench-neotree 11           # more samples for a stabler median
just bench-neotree 7 /path/to/nvim
```

`just` passes recipe arguments positionally, so a custom binary requires
passing `runs` first: `just bench-neotree 7 /path/to/nvim`. There is no named
or keyword argument syntax; `just bench-neotree nvim_bin=/path` would set
`runs` to that string. Scripts can also skip the recipe and call
`scripts/bench-neotree.sh --runs 11 --nvim /path/to/nvim` directly.

The recipe always runs `nix build .#default` first so the benchmark uses a
fresh packaged Neovim binary, then invokes
`scripts/bench-neotree.sh --runs <runs> --nvim <binary>`.

What one run measures:

1. A fresh packaged Neovim process starts with `--headless`.
2. Startup time (`t0`) is captured by a `--cmd` hook that runs before any
   configuration, so the measurement covers config load, plugin setup, the
   Neo-tree window open, and the first render showing the target.
3. A Lua poller (`scripts/bench-neotree-poll.lua`) checks every 10 ms for a
   window on the current tabpage whose buffer is named `neo-tree` and whose
   **on-screen lines** (`w0` through `w$`) contain the known filename. A
   hidden neo-tree buffer, or a target scrolled outside the window, never
   counts as visible; such a run keeps polling until the timeout.
4. The elapsed milliseconds are recorded and the session exits with `qa!`.

## Fixture

Each invocation creates an isolated, reproducible Git fixture in a fresh
system temp directory (`mktemp -d "${TMPDIR:-/tmp}/bench-neotree.XXXXXX"`):

- `repo/` — a fresh `git init` repository with three directories
  (`alpha/`, `beta/`, `gamma/`), each with eight deterministic text files,
  plus the known target file `bench-known-target.md` at the repository root.
- The tree is identical on every invocation, so run-to-run differences come
  from Neovim and Neo-tree, not from the file set.

## Output

Human-readable, one line per run plus the median:

```text
Neo-tree first-visible benchmark
  nvim: result/bin/nvim
  runs: 7 (per-run timeout: 120s)
  fixture: /var/folders/.../bench-neotree.XXXXXX/repo (temporary, deleted on exit)
  run 1: 402.1 ms
  run 2: 398.7 ms
  ...
  median: 401.5 ms over 7 runs
```

The median is the middle value (odd run counts) or the mean of the two middle
values (even counts). A slow median is still a successful run: the recipe
never compares the result against a budget, so it is safe to run locally and
in CI without flaking.

## Tests

`scripts/bench-neotree-test.sh [nvim-binary]` exercises the poller through
packaged Neovim sessions:

- `hidden` — a neo-tree-named buffer containing the target but shown in no
  window must not count: the run times out and records no value.
- `offscreen` — the target rendered in the tree buffer but scrolled outside
  the window's visible lines must not count: timeout, no value.
- `visible` — the target shown on-screen in the tree window records a value
  and exits 0 (control).

## Errors

The script fails (non-zero exit) only on real errors:

- The Neovim binary is missing or not executable
  (`run 'just build' first, or pass --nvim <path>`).
- A session produces no result because it crashed before recording anything.
- A session times out (default 120 s, `--timeout SECS`) without Neo-tree
  showing the known file; the timeout is a hang guard, not a performance
  budget.

## Cleanup

All scratch state — the Git fixture, the embedded poller, and the raw result
lines — lives inside the single temporary directory created at startup. A
trap removes it on every exit path, including errors and Ctrl-C. The script
never writes inside the repository; the only repository-visible side effect is
the `result` symlink that `nix build .#default` refreshes, which Git ignores.
