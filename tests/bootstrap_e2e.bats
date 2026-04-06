#!/usr/bin/env bats

setup() {
  export TEST_HOME="$BATS_TEST_TMPDIR/home"
  export HOME="$TEST_HOME"
  mkdir -p "$TEST_HOME/.config" "$TEST_HOME/bin" "$TEST_HOME/.oh-my-zsh"
  export PATH="$TEST_HOME/bin:$PATH"

  cat << 'EOF' > "$TEST_HOME/bin/uname"
#!/bin/bash
echo Darwin
EOF
  chmod +x "$TEST_HOME/bin/uname"

  for cmd in brew git curl lldb; do
    cat > "$TEST_HOME/bin/$cmd" <<'MOCK'
#!/bin/bash
echo "Mock $0 $@"
exit 0
MOCK
    chmod +x "$TEST_HOME/bin/$cmd"
  done

  cat << 'EOF' > "$TEST_HOME/.oh-my-zsh/oh-my-zsh.sh"
#!/bin/bash
return 0
EOF
  chmod +x "$TEST_HOME/.oh-my-zsh/oh-my-zsh.sh"
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
  run bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]

  run env HOME="$HOME" APPLE_INTERFACE_STYLE=Light zsh -c 'source "$HOME/.zshrc" 2>"$HOME/zsh.err"; alias gs; which node; type _noarg_hl'
  [ "$status" -eq 0 ]
  [[ "$output" == *"gs='git status -sb'"* ]]
  [[ "$output" == *"node ()"* ]]
  [[ "$output" == *"_noarg_hl is a shell function"* ]]
}

@test "installed tmux config parses after install" {
  if ! command -v tmux >/dev/null 2>&1; then
    skip "tmux is not installed"
  fi

  run bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]

  local socket="bats_tmux_e2e_$$"
  run env HOME="$HOME" tmux -L "$socket" -f "$HOME/.tmux.conf" start-server \; show -g prefix \; kill-server
  [ "$status" -eq 0 ]
}

@test "installed neovim config loads headless with stub lazy bootstrap" {
  if ! command -v nvim >/dev/null 2>&1; then
    skip "nvim is not installed"
  fi

  run bash -c 'echo "y" | ./install.sh'
  [ "$status" -eq 0 ]

  prepare_lazy_stub

  run env HOME="$HOME" XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$XDG_DATA_HOME" nvim --headless '+quitall'
  [ "$status" -eq 0 ]
}
