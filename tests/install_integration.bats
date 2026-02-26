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
  
  # Assert symlinks were created
  [ -L "$HOME/.zshrc" ]
  [ -L "$HOME/.tmux.conf" ]
  [ -L "$HOME/.bash_profile" ]
  [ -L "$HOME/.fzf.zsh" ]
  [ -L "$HOME/.config/nvim" ]
  [ -L "$HOME/.config/starship.toml" ]
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
