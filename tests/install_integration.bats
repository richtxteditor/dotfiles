#!/usr/bin/env bats

setup() {
  export TEST_HOME="$BATS_TEST_TMPDIR/home"
  export HOME="$TEST_HOME"
  mkdir -p "$TEST_HOME/.config"
  mkdir -p "$TEST_HOME/bin"

  # Create mock bin directory
  export PATH="$TEST_HOME/bin:$PATH"

  # Mock `brew` to echo commands and succeed
  cat << 'EOF' > "$TEST_HOME/bin/brew"
#!/bin/bash
echo "Mock brew $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/brew"

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
echo "Mock curl $@"
exit 0
EOF
  chmod +x "$TEST_HOME/bin/curl"

  # Mock `lldb` so macOS check doesn't fail/warn
  cat << 'EOF' > "$TEST_HOME/bin/lldb"
#!/bin/bash
exit 0
EOF
  chmod +x "$TEST_HOME/bin/lldb"

}

@test "install.sh creates symlinks when run interactively (mocked 'y')" {
  # Pipe "y" to install.sh
  run bash -c 'echo "y" | ./install.sh'
  
  [ "$status" -eq 0 ]
  
  # Assert symlinks were created and point to correct targets
  local dir="$(pwd)"

  [ -L "$HOME/.zshrc" ]
  [[ "$(readlink "$HOME/.zshrc")" == "$dir/.zshrc" ]]
  [ -L "$HOME/.tmux.conf" ]
  [[ "$(readlink "$HOME/.tmux.conf")" == "$dir/.tmux.conf" ]]
  [ -L "$HOME/.bash_profile" ]
  [[ "$(readlink "$HOME/.bash_profile")" == "$dir/.bash_profile" ]]
  [ -L "$HOME/.fzf.zsh" ]
  [[ "$(readlink "$HOME/.fzf.zsh")" == "$dir/.fzf.zsh" ]]
  [ -L "$HOME/.config/nvim" ]
  [[ "$(readlink "$HOME/.config/nvim")" == "$dir/nvim" ]]
  [ -L "$HOME/.config/starship.toml" ]
  [[ "$(readlink "$HOME/.config/starship.toml")" == "$dir/starship.toml" ]]
  [ -L "$HOME/.gitconfig" ]
  [[ "$(readlink "$HOME/.gitconfig")" == "$dir/.gitconfig" ]]
  [ -L "$HOME/.gitignore_global" ]
  [[ "$(readlink "$HOME/.gitignore_global")" == "$dir/.gitignore_global" ]]
}

@test "install.sh backups existing files correctly" {
  # Create a real file at ~/.zshrc before running
  echo "dummy zshrc" > "$HOME/.zshrc"
  
  run bash -c 'echo "y" | ./install.sh'
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
  
  run bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]
  
  # Symlink should be overwritten to point to real .zshrc
  link_target=$(readlink "$HOME/.zshrc")
  [[ "$link_target" == *"/dotfiles/.zshrc" ]]
  
  # Backup dir should either be empty or contain nothing for .zshrc
  backup_dir=$(ls -d "$HOME"/dotfiles_backup_* 2>/dev/null | head -n 1 || true)
  if [ -n "$backup_dir" ]; then
    [ ! -f "$backup_dir/.zshrc" ]
  fi
}

@test "install.sh runs brew bundle" {
  run bash -c 'echo "y" | ./install.sh'
  [[ "$output" == *"Mock brew bundle --file="* ]]
}

@test "install.sh backs up existing .config files correctly" {
  # Create a real file at ~/.config/starship.toml before running
  echo "dummy starship config" > "$HOME/.config/starship.toml"

  run bash -c 'echo "y" | ./install.sh'
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
  run bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]

  # Backup dir may be created (mkdir -p) but should contain no files
  backup_dir=$(ls -d "$HOME"/dotfiles_backup_* 2>/dev/null | head -n 1 || true)
  if [ -n "$backup_dir" ]; then
    local file_count
    file_count=$(find "$backup_dir" -type f | wc -l | tr -d ' ')
    [ "$file_count" -eq 0 ]
  fi
}
