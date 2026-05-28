# Security Hardening Backlog

The current installer avoids network execution during `--dry-run`, tracks the Neovim plugin lockfile, pins GitHub Actions by commit SHA, and scans CI with Gitleaks.

Remaining supply-chain surfaces to review before adding stricter enforcement:

- Homebrew bootstrap script from `raw.githubusercontent.com`.
- Linux Neovim release tarball from GitHub releases.
- Starship and Rustup installer scripts.
- Oh My Zsh, zsh plugin, and TPM `git clone` bootstrap steps.
- Global npm and gem installs for helper tools and Neovim providers.
- Lazy.nvim bootstrap and plugin-managed build/download hooks such as `fff.nvim` and markdown-preview.

Prefer upstream-published checksums or pinned immutable release artifacts. Keep dynamic install flows documented when upstream does not provide stable checksums.
