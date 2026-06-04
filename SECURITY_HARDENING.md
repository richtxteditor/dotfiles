# Security Hardening Status

The current installer avoids network execution during `--dry-run`, tracks the Neovim plugin lockfile, pins GitHub Actions by commit SHA, scans CI with Gitleaks, and verifies pinned bootstrap downloads before execution or extraction.

Handled supply-chain surfaces:

- Homebrew bootstrap script is pinned to a commit and SHA256.
- Linux Neovim release tarball is pinned to a version and SHA256 per supported architecture.
- Starship and Rustup no longer execute live shell installers; pinned release binaries are SHA256-verified first.

Remaining supply-chain surfaces to review before adding stricter enforcement:

- Oh My Zsh, zsh plugin, and TPM `git clone` bootstrap steps.
- Global npm and gem installs for helper tools and Neovim providers.
- Lazy.nvim bootstrap and plugin-managed build/download hooks such as `fff.nvim` and markdown-preview.

Prefer upstream-published checksums or pinned immutable release artifacts. Keep dynamic install flows documented when upstream does not provide stable checksums. Refresh pins in `config/toolchain.sh` by updating the version/ref and checksum in the same change.
