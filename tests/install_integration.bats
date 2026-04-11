#!/usr/bin/env bats

setup() {
  export TEST_HOME="$BATS_TEST_TMPDIR/home"
  export HOME="$TEST_HOME"
  mkdir -p "$TEST_HOME/.config"
  mkdir -p "$TEST_HOME/bin"

  # Create mock bin directory
  export PATH="$TEST_HOME/bin:$PATH"

  cat << 'EOF' > "$TEST_HOME/bin/uname"
#!/bin/bash
if [ "$1" = "-m" ]; then
echo x86_64
else
echo Darwin
fi
EOF
  chmod +x "$TEST_HOME/bin/uname"

  # Mock `brew` to echo commands and succeed
  cat << 'EOF' > "$TEST_HOME/bin/brew"
#!/bin/bash
echo "Mock brew $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/brew"

  cat << 'EOF' > "$TEST_HOME/bin/apt-get"
#!/bin/bash
echo "Mock apt-get $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/apt-get"

  cat << 'EOF' > "$TEST_HOME/bin/sudo"
#!/bin/bash
exec "$@"
EOF
  chmod +x "$TEST_HOME/bin/sudo"

  cat << 'EOF' > "$TEST_HOME/bin/npm"
#!/bin/bash
echo "Mock npm $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/npm"

  cat << 'EOF' > "$TEST_HOME/bin/gem"
#!/bin/bash
echo "Mock gem $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/gem"

  cat << 'EOF' > "$TEST_HOME/bin/locale-gen"
#!/bin/bash
echo "Mock locale-gen $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/locale-gen"

  cat << 'EOF' > "$TEST_HOME/bin/update-locale"
#!/bin/bash
echo "Mock update-locale $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/update-locale"

  # Mock `git`
  cat << 'EOF' > "$TEST_HOME/bin/git"
#!/bin/bash
echo "Mock git $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/git"

  # Mock `curl`
  cat << 'EOF' > "$TEST_HOME/bin/curl"
#!/bin/bash
if [[ "$*" == *"https://starship.rs/install.sh"* ]]; then
cat <<'SCRIPT'
#!/bin/sh
echo "Mock starship installer $@"
exit 0
SCRIPT
exit 0
fi
if [ "$1" = "-fsSL" ] && [[ "$2" == *"github.com/neovim/neovim/releases/latest/download/"* ]] && [ "$3" = "-o" ]; then
  : > "$4"
  echo "Mock curl $2 -> $4"
  exit 0
fi
echo "Mock curl $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/curl"

  cat << 'EOF' > "$TEST_HOME/bin/tar"
#!/bin/bash
dest=""
while [ "$#" -gt 0 ]; do
  if [ "$1" = "-C" ]; then
    dest="$2"
    shift 2
    continue
  fi
  shift
done
mkdir -p "$dest/nvim-linux-x86_64/bin"
touch "$dest/nvim-linux-x86_64/bin/nvim"
echo "Mock tar extracted to $dest"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/tar"

  # Mock `lldb` so macOS check doesn't fail/warn
  cat << 'EOF' > "$TEST_HOME/bin/lldb"
#!/bin/bash
exit 0
EOF
  chmod +x "$TEST_HOME/bin/lldb"

}

@test "install.sh creates symlinks when run interactively (mocked 'y')" {
  # Pipe "y" to install.sh
  run env DOTFILES_PLATFORM=macos bash -c 'echo "y" | ./install.sh'
  
  [ "$status" -eq 0 ]
  
  # Assert symlinks were created and point to correct targets
  local dir="$(pwd)"

  [ -L "$HOME/.zshrc" ]
  [[ "$(readlink "$HOME/.zshrc")" == "$dir/platforms/macos/.zshrc" ]]
  [ -L "$HOME/.tmux.conf" ]
  [[ "$(readlink "$HOME/.tmux.conf")" == "$dir/.tmux.conf" ]]
  [ -L "$HOME/.bash_profile" ]
  [[ "$(readlink "$HOME/.bash_profile")" == "$dir/platforms/macos/.bash_profile" ]]
  [ -L "$HOME/.fzf.zsh" ]
  [[ "$(readlink "$HOME/.fzf.zsh")" == "$dir/.fzf.zsh" ]]
  [ -L "$HOME/.config/nvim" ]
  [[ "$(readlink "$HOME/.config/nvim")" == "$dir/nvim" ]]
  [ -L "$HOME/.config/starship.toml" ]
  [[ "$(readlink "$HOME/.config/starship.toml")" == "$dir/platforms/macos/starship.toml" ]]
  [ -L "$HOME/.gitconfig" ]
  [[ "$(readlink "$HOME/.gitconfig")" == "$dir/.gitconfig" ]]
  [ -L "$HOME/.gitignore_global" ]
  [[ "$(readlink "$HOME/.gitignore_global")" == "$dir/.gitignore_global" ]]
  [ -L "$HOME/Library/Application Support/com.mitchellh.ghostty/config" ]
  [[ "$(readlink "$HOME/Library/Application Support/com.mitchellh.ghostty/config")" == "$dir/ghostty/config.macos" ]]
  [ -L "$HOME/.claude/CLAUDE.md" ]
  [[ "$(readlink "$HOME/.claude/CLAUDE.md")" == "$dir/claude/CLAUDE.md" ]]
}

@test "install.sh backups existing files correctly" {
  # Create a real file at ~/.zshrc before running
  echo "dummy zshrc" > "$HOME/.zshrc"
  
  run env DOTFILES_PLATFORM=macos bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]
  
  # It should now be a symlink
  [ -L "$HOME/.zshrc" ]
  
  # Check if a backup directory was created and contains the backup
  backup_dir=$(ls -d "$HOME"/dotfiles_backup_* | head -n 1)
  [ -n "$backup_dir" ]
  [ -f "$backup_dir/.zshrc" ]
  
  # The backup should contain the content we wrote
  run cat "$backup_dir/.zshrc"
  [ "$output" = "dummy zshrc" ]
}

@test "install.sh does not backup existing symlinks" {
  # Create a dummy symlink
  ln -s /dev/null "$HOME/.zshrc"
  
  run env DOTFILES_PLATFORM=macos bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]
  
  # Symlink should be overwritten to point to real .zshrc
  link_target=$(readlink "$HOME/.zshrc")
  [[ "$link_target" == *"/dotfiles/platforms/macos/.zshrc" ]]
  
  # Backup dir should either be empty or contain nothing for .zshrc
  backup_dir=$(ls -d "$HOME"/dotfiles_backup_* 2>/dev/null | head -n 1 || true)
  if [ -n "$backup_dir" ]; then
    [ ! -f "$backup_dir/.zshrc" ]
  fi
}

@test "install.sh runs brew bundle" {
  run env DOTFILES_PLATFORM=macos bash -c 'echo "y" | ./install.sh'
  [[ "$output" == *"Mock brew bundle --file="* ]]
}

@test "install.sh uses Linux Ghostty path when platform is Linux" {
  run env DOTFILES_PLATFORM=linux bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Skipping Homebrew on Linux."* ]]
  [[ "$output" == *"Mock apt-get update"* ]]
  [[ "$output" == *"Mock apt-get install -y git curl zsh tmux fzf ripgrep fd-find bat xclip build-essential zoxide eza zsh-autosuggestions zsh-syntax-highlighting python3 python3-venv python3-pip nodejs npm ruby-full golang-go clangd php-cli php-mbstring php-xml composer default-jdk luarocks locales texlive-latex-base"* ]]
  [[ "$output" == *"Installing latest Neovim stable from upstream release (nvim-linux-x86_64.tar.gz)"* ]]
  [[ "$output" == *"Mock curl https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"* ]]
  [[ "$output" == *"Mock tar extracted to "* ]]
  [[ "$output" == *"Mock locale-gen en_US.UTF-8"* ]]
  [[ "$output" == *"Mock update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8"* ]]
  [[ "$output" == *"Installing tree-sitter-cli via npm..."* || "$output" == *"tree-sitter-cli is already installed."* ]]
  if [[ "$output" == *"Installing tree-sitter-cli via npm..."* ]]; then
    [[ "$output" == *"Mock npm install -g --prefix $HOME/.local tree-sitter-cli"* ]]
  fi
  [[ "$output" == *"Installing Node.js Neovim host..."* ]]
  [[ "$output" == *"Mock npm install -g --prefix $HOME/.local neovim"* ]]
  [[ "$output" == *"Installing Ruby Neovim host..."* ]]
  [[ "$output" == *"Mock gem install --user-install neovim"* ]]
  [[ "$output" == *"Mock starship installer -y -b $HOME/.local/bin"* || "$output" == *"starship is already installed."* ]]
  [[ "$output" == *"Skipping Neovim bootstrap: non-interactive session."* ]]
  [[ "$output" != *"Mock brew bundle --file="* ]]

  local dir="$(pwd)"
  [ -L "$HOME/.config/ghostty/config" ]
  [[ "$(readlink "$HOME/.config/ghostty/config")" == "$dir/ghostty/config.linux" ]]
  [ -L "$HOME/.zshrc" ]
  [[ "$(readlink "$HOME/.zshrc")" == "$dir/platforms/ubuntu/.zshrc" ]]
  [ -L "$HOME/.bash_profile" ]
  [[ "$(readlink "$HOME/.bash_profile")" == "$dir/platforms/ubuntu/.bash_profile" ]]
  [ -L "$HOME/.config/starship.toml" ]
  [[ "$(readlink "$HOME/.config/starship.toml")" == "$dir/platforms/ubuntu/starship.toml" ]]
}

@test "install.sh backs up existing .config files correctly" {
  # Create a real file at ~/.config/starship.toml before running
  echo "dummy starship config" > "$HOME/.config/starship.toml"

  run env DOTFILES_PLATFORM=macos bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]

  # It should now be a symlink
  [ -L "$HOME/.config/starship.toml" ]

  # Backup directory should contain the original file with original content
  backup_dir=$(ls -d "$HOME"/dotfiles_backup_* | head -n 1)
  [ -n "$backup_dir" ]
  [ -f "$backup_dir/starship.toml" ]

  run cat "$backup_dir/starship.toml"
  [ "$output" = "dummy starship config" ]
}

@test "no backup files created when nothing to back up" {
  # Clean HOME — no pre-existing files to back up
  run env DOTFILES_PLATFORM=macos bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]

  # Backup dir may be created (mkdir -p) but should contain no files
  backup_dir=$(ls -d "$HOME"/dotfiles_backup_* 2>/dev/null | head -n 1 || true)
  if [ -n "$backup_dir" ]; then
    local file_count
    file_count=$(find "$backup_dir" -type f | wc -l | tr -d ' ')
    [ "$file_count" -eq 0 ]
  fi
}
