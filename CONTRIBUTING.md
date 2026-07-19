# Contributing to aytordev.nvim

Contributions should keep the distro reproducible, focused, and easy to
review. Open or reference an issue before starting a substantial change.

## Setup

Clone the repository and enter the development shell:

```bash
git clone git@github.com:aytordev/aytordev.nvim.git
cd aytordev.nvim
nix develop
```

The shell provides `just`, Alejandra, and `nil`.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `modules/aytordev/` | Public `aytordev.*` options. |
| `modules/nvf/options/` | Core Neovim and wrapper settings. |
| `modules/nvf/plugins/` | Plugin-specific modules. |
| `flake/` | Packages, modules, checks, formatter, and dev shell outputs. |
| `.github/` | CI and collaboration templates. |

Each plugin belongs in its own `modules/nvf/plugins/<name>/default.nix`
directory. Plugin directories are discovered automatically and receive a
default-enabled `aytordev.plugins.<name>` option. Guard the module configuration
with `lib.mkIf config.aytordev.plugins.<name>`, and keep each module limited to
one plugin or tightly related capability. Infrastructure modules must be added
to `infrastructureModules` in `modules/nvf/plugins/discovery.nix` instead.

Nix flakes ignore untracked files. If a new Nix file is not visible during
evaluation, stage it or mark it as intent-to-add before testing:

```bash
git add -N path/to/new-file.nix
```

## Workflow

1. Create a focused branch such as `feat/add-plugin` or `fix/lsp-startup`.
2. Make the smallest change that solves the issue.
3. Add or update checks when behavior changes.
4. Update documentation for public options, keymaps, or workflows.
5. Run the required validation before opening a pull request.

## Validation

Format and test the current system:

```bash
just fmt
just check
```

Evaluate every supported system when changing flake wiring, packages, or
platform-specific behavior:

```bash
nix flake check --all-systems --no-build
```

Run the editor manually when changing runtime behavior:

```bash
nix run .
```

Do not update `flake.lock` unless the dependency change is intentional. Keep
dependency updates separate from unrelated code changes.

## Commit Messages

Use Conventional Commits prefixed with a Gitmoji code:

```text
:sparkles: feat(plugins): add example plugin
:bug: fix(lsp): handle missing project root
:memo: docs: document Home Manager options
:white_check_mark: test(runtime): cover plugin startup
:wrench: chore(deps): update flake.lock
```

Keep each commit to one reviewable work unit. Use an imperative, lowercase
subject without a trailing period.

## Pull Requests

A pull request should explain:

- Why the change is needed
- What behavior changes
- How the change was validated
- Whether the public API or supported systems are affected

AI-assisted contributions are welcome, but contributors remain responsible
for understanding, testing, and reviewing every submitted change.
