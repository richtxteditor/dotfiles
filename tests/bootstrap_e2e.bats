#!/usr/bin/env bats

setup() {
  export TEST_HOME="$BATS_TEST_TMPDIR/home"
  export HOME="$TEST_HOME"
  mkdir -p "$TEST_HOME/.config" "$TEST_HOME/bin" "$TEST_HOME/.oh-my-zsh"
  export PATH="$TEST_HOME/bin:$PATH"

  cat << 'EOF' > "$TEST_HOME/bin/uname"
#!/bin/bash
if [ "$1" = "-m" ]; then
  echo x86_64
else
  printf '%s\n' "${DOTFILES_TEST_UNAME:-Darwin}"
fi
EOF
  chmod +x "$TEST_HOME/bin/uname"

  for cmd in brew git lldb npm gem locale-gen update-locale apt-get chsh; do
    cat > "$TEST_HOME/bin/$cmd" <<'MOCK'
#!/bin/bash
echo "Mock $0 $@"
exit 0
MOCK
    chmod +x "$TEST_HOME/bin/$cmd"
  done

  cat << 'EOF' > "$TEST_HOME/bin/sudo"
#!/bin/bash
exec "$@"
EOF
  chmod +x "$TEST_HOME/bin/sudo"

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
echo "Mock $0 $@"
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

  cat << 'EOF' > "$TEST_HOME/.oh-my-zsh/oh-my-zsh.sh"
#!/bin/bash
return 0
EOF
  chmod +x "$TEST_HOME/.oh-my-zsh/oh-my-zsh.sh"
}

install_for_platform() {
  local platform="$1"
  local uname_value="$2"
  env DOTFILES_PLATFORM="$platform" DOTFILES_TEST_UNAME="$uname_value" bash -c 'echo "y" | ./install.sh'
}

prepare_lazy_stub() {
  export XDG_DATA_HOME="$BATS_TEST_TMPDIR/xdg-data"
  mkdir -p "$XDG_DATA_HOME/nvim/lazy/lazy.nvim/lua/lazy"

  cat << 'EOF' > "$XDG_DATA_HOME/nvim/lazy/lazy.nvim/lua/lazy/init.lua"
local M = {}

function M.setup()
  return nil
end

return M
EOF
}

@test "installed zsh entrypoint bootstraps from symlinked home" {
  run install_for_platform macos Darwin
  [ "$status" -eq 0 ]

  run env HOME="$HOME" DOTFILES_TEST_UNAME=Darwin APPLE_INTERFACE_STYLE=Light zsh -c 'source "$HOME/.zshrc" 2>"$HOME/zsh.err"; alias gs; alias icloud; typeset -f update; which node; type _noarg_hl; printf "platform:%s\n" "$DOTFILES_PLATFORM"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"gs='git status -sb'"* ]]
  [[ "$output" == *"icloud='cd ~/Library/Mobile\\ Documents/com~apple~CloudDocs'"* ]]
  [[ "$output" == *"softwareupdate -i -a"* ]]
  [[ "$output" == *"node ()"* ]]
  [[ "$output" == *"_noarg_hl is a shell function"* ]]
  [[ "$output" == *"platform:macos"* ]]
}

@test "installed linux zsh entrypoint bootstraps from symlinked home" {
  run install_for_platform linux Linux
  [ "$status" -eq 0 ]

  run env HOME="$HOME" DOTFILES_TEST_UNAME=Linux zsh -c 'source "$HOME/.zshrc" 2>"$HOME/zsh.err"; alias gs; typeset -f update; which node; type _noarg_hl; if alias icloud >/dev/null 2>&1; then echo "icloud:present"; else echo "icloud:missing"; fi; printf "platform:%s\n" "$DOTFILES_PLATFORM"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"gs='git status -sb'"* ]]
  [[ "$output" == *"apt-get update"* ]]
  [[ "$output" == *"node ()"* ]]
  [[ "$output" == *"_noarg_hl is a shell function"* ]]
  [[ "$output" == *"icloud:missing"* ]]
  [[ "$output" == *"platform:linux"* ]]
}

@test "installed macOS bash entrypoint bootstraps from symlinked home" {
  run install_for_platform macos Darwin
  [ "$status" -eq 0 ]

  run env HOME="$HOME" DOTFILES_TEST_UNAME=Darwin APPLE_INTERFACE_STYLE=Light bash -lc 'source "$HOME/.bash_profile"; alias icloud; type update; printf "platform:%s\nPATH:%s\n" "$DOTFILES_PLATFORM" "$PATH"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"icloud="* ]]
  [[ "$output" == *"update is a function"* ]]
  [[ "$output" == *"softwareupdate -i -a"* ]]
  [[ "$output" == *"platform:macos"* ]]
  [[ "$output" == *"/opt/homebrew/bin"* ]]
}

@test "installed linux bash entrypoint bootstraps from symlinked home" {
  run install_for_platform linux Linux
  [ "$status" -eq 0 ]

  run env HOME="$HOME" DOTFILES_TEST_UNAME=Linux bash -lc 'source "$HOME/.bash_profile"; type update; printf "platform:%s\nPATH:%s\n" "$DOTFILES_PLATFORM" "$PATH"; if alias icloud >/dev/null 2>&1; then echo "icloud:present"; else echo "icloud:missing"; fi'
  [ "$status" -eq 0 ]
  [[ "$output" == *"update is a function"* ]]
  [[ "$output" == *"apt-get update"* ]]
  [[ "$output" == *"platform:linux"* ]]
  [[ "$output" == *".local/bin"* ]]
  [[ "$output" == *"icloud:missing"* ]]
}

@test "installed tmux config parses after install" {
  if ! command -v tmux >/dev/null 2>&1; then
    skip "tmux is not installed"
  fi

  run install_for_platform macos Darwin
  [ "$status" -eq 0 ]

  local socket="bats_tmux_e2e_$$"
  local tmux_tmpdir
  tmux_tmpdir="$(mktemp -d /tmp/dotfiles-tmux.XXXXXX)"
  run env HOME="$HOME" DOTFILES_TEST_UNAME=Darwin TMUX_TMPDIR="$tmux_tmpdir" tmux -L "$socket" -f "$HOME/.tmux.conf" start-server \; show -g prefix \; kill-server
  if [ "$status" -ne 0 ] && [[ "$output" == *"Operation not permitted"* ]]; then
    skip "tmux socket creation blocked by sandbox"
  fi
  [ "$status" -eq 0 ]
}

@test "installed linux tmux config parses after install" {
  if ! command -v tmux >/dev/null 2>&1; then
    skip "tmux is not installed"
  fi

  run install_for_platform linux Linux
  [ "$status" -eq 0 ]

  local socket="bats_tmux_e2e_linux_$$"
  local tmux_tmpdir
  tmux_tmpdir="$(mktemp -d /tmp/dotfiles-tmux.XXXXXX)"
  run env HOME="$HOME" DOTFILES_TEST_UNAME=Linux TMUX_TMPDIR="$tmux_tmpdir" tmux -L "$socket" -f "$HOME/.tmux.conf" start-server \; show -g prefix \; kill-server
  if [ "$status" -ne 0 ] && [[ "$output" == *"Operation not permitted"* ]]; then
    skip "tmux socket creation blocked by sandbox"
  fi
  [ "$status" -eq 0 ]
}

@test "installed neovim config loads headless with stub lazy bootstrap" {
  if ! command -v nvim >/dev/null 2>&1; then
    skip "nvim is not installed"
  fi

  run install_for_platform macos Darwin
  [ "$status" -eq 0 ]

  prepare_lazy_stub

  run env HOME="$HOME" DOTFILES_TEST_UNAME=Darwin XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$XDG_DATA_HOME" nvim --headless '+quitall'
  [ "$status" -eq 0 ]
}

@test "installed linux neovim config loads headless with stub lazy bootstrap" {
  if ! command -v nvim >/dev/null 2>&1; then
    skip "nvim is not installed"
  fi

  run install_for_platform linux Linux
  [ "$status" -eq 0 ]

  prepare_lazy_stub

  run env HOME="$HOME" DOTFILES_TEST_UNAME=Linux XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$XDG_DATA_HOME" nvim --headless '+quitall'
  [ "$status" -eq 0 ]
}
