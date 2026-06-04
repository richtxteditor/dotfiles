# Dotfiles

Terminal-focused dotfiles for macOS and Ubuntu/Linux. Includes Zsh, Bash,
tmux, Neovim, Ghostty, Starship, Git config, installer scripts, and CI checks.

## Install

```bash
git clone https://github.com/richtxteditor/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Useful modes:

```bash
./install.sh --dry-run    # show planned changes only
./install.sh --skip-deps  # skip core dependency installation
```

The installer backs up replaced files to `~/dotfiles_backup_<timestamp>` and
then creates symlinks for the tracked configs.

## Platforms

- macOS: installs Homebrew dependencies from `Brewfile`.
- Ubuntu/Linux: installs core packages with `apt` and a pinned upstream Neovim
  release into `~/.local`.

Linux support is Ubuntu/Debian-first. Other distributions should install
equivalent packages manually, then use `./install.sh --skip-deps`.

## What Is Managed

- Shell: `.zshrc`, `.bash_profile`, shared modules in `shell/`
- tmux: `.tmux.conf`, platform overrides in `tmux/`
- Neovim: `nvim/`, plugin pins in `nvim/lazy-lock.json`
- Ghostty: platform configs in `ghostty/`
- Starship: platform configs under `platforms/`
- Git: `.gitconfig`, `.gitignore_global`
- Claude Code: `claude/CLAUDE.md`

`config/toolchain.sh` is the source of truth for package lists, minimum tool
versions, pinned installer URLs, and SHA256 checksums.

## Verify

```bash
./scripts/doctor.sh
./scripts/verify-nvim.sh
./test.sh
```

`./test.sh` runs Bats coverage for installer behavior, syntax checks, repo
consistency, bootstrap smoke tests, and CI smoke flows.

## CI

GitHub Actions runs tests on Ubuntu and macOS, runs Gitleaks, and performs
cross-platform smoke installs. A separate full-bootstrap workflow covers the
heavier install path.

Actions are pinned to immutable SHAs. Refresh an action by resolving the
desired tag with `git ls-remote`, updating the SHA, and keeping the inline
version comment accurate.

## Updates

Refresh Homebrew state:

```bash
bbu
```

`bbu` writes an ignored `Brewfile.snapshot`. Review it and manually move
intentional package changes into `Brewfile`.

Refresh Neovim plugins through Lazy, then commit the resulting
`nvim/lazy-lock.json` changes when the pin updates are intentional.

Refresh pinned bootstrap artifacts by updating the version/URL and matching
SHA256 together in `config/toolchain.sh`.

## Key Commands

- `ta`: attach to or create a tmux session
- `Prefix + I`: install tmux plugins
- `Prefix + r`: reload tmux config
- `<Space>`: Neovim leader key
- `<Leader>ff`: find files
- `<Leader>fg`: live grep
- `<Leader>e`: toggle file explorer
- `<Leader>gg`: open LazyGit
- `<Leader>cf`: format current buffer
- `update`: platform-specific system update helper
- `bbu`: write ignored Homebrew snapshot

## License

MIT
