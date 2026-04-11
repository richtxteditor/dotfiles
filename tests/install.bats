#!/usr/bin/env bats

setup() {
  export TEST_HOME="$BATS_TEST_TMPDIR/home"
  export HOME="$TEST_HOME"
  mkdir -p "$TEST_HOME/.config"
  mkdir -p "$TEST_HOME/bin"

  export PATH="$TEST_HOME/bin:$PATH"

  # Mock brew, git, curl, lldb, apt-get, sudo, tar, zsh, chsh, npm, gem, locale tools
  for cmd in brew git curl lldb apt-get sudo tar zsh chsh npm gem locale-gen update-locale; do
    cat > "$TEST_HOME/bin/$cmd" <<'MOCK'
#!/bin/bash
if [ "$(basename "$0")" = "sudo" ]; then
  exec "$@"
fi
echo "Mock $0 $@"
exit 0
MOCK
    chmod +x "$TEST_HOME/bin/$cmd"
  done

  cat > "$TEST_HOME/bin/uname" <<'MOCK'
#!/bin/bash
if [ "$1" = "-m" ]; then
  echo x86_64
else
  echo Darwin
fi
MOCK
  chmod +x "$TEST_HOME/bin/uname"
}

@test "install.sh runs in dry-run mode without failing" {
  run ./install.sh --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Running in dry-run mode"* ]]
}

@test "install.sh detects LLDB check on macOS" {
  run env DOTFILES_PLATFORM=macos ./install.sh --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"LLDB is already installed"* ]]
}

@test "install.sh skips Homebrew on Linux by default and prints workaround" {
  run env DOTFILES_PLATFORM=linux ./install.sh --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Detected platform: Linux"* ]]
  [[ "$output" == *"Skip Homebrew on Linux"* ]]
  [[ "$output" == *"Ubuntu package install command:"* ]]
  [[ "$output" == *"sudo apt-get update && sudo apt-get install -y git curl zsh tmux fzf ripgrep fd-find bat xclip build-essential zoxide eza zsh-autosuggestions zsh-syntax-highlighting python3 python3-venv python3-pip nodejs npm ruby-full golang-go clangd php-cli php-mbstring php-xml composer default-jdk luarocks locales texlive-latex-base"* ]]
  [[ "$output" == *"Install latest Neovim stable from upstream."* ]]
  [[ "$output" == *"Latest Neovim stable is installed separately from upstream into ~/.local."* ]]
  [[ "$output" == *"tree-sitter-cli is installed separately via npm."* ]]
}

@test "install.sh explains manual zsh shell switch when shell path is not in /etc/shells" {
  run env DOTFILES_PLATFORM=linux SHELL=/bin/bash ZSH_PATH="$TEST_HOME/bin/zsh" ./install.sh --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping default shell change: $TEST_HOME/bin/zsh not listed in /etc/shells."* ]]
  [[ "$output" == *"Add it to /etc/shells, then run: chsh -s $TEST_HOME/bin/zsh"* ]]
}

@test "dry-run makes zero filesystem changes" {
  # Snapshot HOME before
  local before="$BATS_TEST_TMPDIR/snapshot_before"
  local after="$BATS_TEST_TMPDIR/snapshot_after"
  find "$HOME" -not -path "*/bin/*" | sort > "$before"

  run ./install.sh --dry-run
  [ "$status" -eq 0 ]

  # Snapshot HOME after
  find "$HOME" -not -path "*/bin/*" | sort > "$after"

  # Should be identical — dry-run must not touch filesystem
  run diff "$before" "$after"
  [ "$status" -eq 0 ]
}

@test "install.sh aborts on 'n' input" {
  run bash -c 'echo "n" | ./install.sh'
  [ "$status" -eq 1 ]
  [[ "$output" == *"Installation aborted"* ]]

  # No symlinks should have been created
  [ ! -L "$HOME/.zshrc" ]
  [ ! -L "$HOME/.tmux.conf" ]
}

@test "all install entrypoints exist in repo" {
  local expected=(
    ".zshrc"
    ".tmux.conf"
    ".bash_profile"
    ".fzf.zsh"
    ".gitconfig"
    ".gitignore_global"
    "nvim"
    "starship.toml"
    "platforms/macos/.zshrc"
    "platforms/ubuntu/.zshrc"
    "platforms/macos/.bash_profile"
    "platforms/ubuntu/.bash_profile"
    "platforms/macos/starship.toml"
    "platforms/ubuntu/starship.toml"
    "ghostty/config.macos"
    "ghostty/config.linux"
    "tmux/common.conf"
    "tmux/macos.conf"
    "tmux/linux.conf"
    "claude/CLAUDE.md"
  )

  for f in "${expected[@]}"; do
    [ -e "$f" ] || { echo "Missing: $f"; false; }
  done
}

@test "install.sh is idempotent" {
  # First run
  run env DOTFILES_PLATFORM=macos bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]

  # Capture symlink targets after first run
  local first_zshrc second_zshrc
  first_zshrc=$(readlink "$HOME/.zshrc")

  # Second run
  run env DOTFILES_PLATFORM=macos bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]
  [[ "$output" == *"already correctly set up"* ]]

  # Symlinks should be identical
  second_zshrc=$(readlink "$HOME/.zshrc")
  [ "$first_zshrc" = "$second_zshrc" ]
}
