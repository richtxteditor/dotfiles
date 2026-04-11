if [[ -z "${DOTFILES_ROOT:-}" ]]; then
  DOTFILES_ENTRY_DIR="${${(%):-%N}:P:h}"
  export DOTFILES_ROOT="${DOTFILES_ENTRY_DIR:h:h}"
fi

source "$DOTFILES_ROOT/shell/shared/platform.sh"
export DOTFILES_PLATFORM="${DOTFILES_PLATFORM:-$(dotfiles_platform)}"
export DOTFILES_EZA_ICONS="${DOTFILES_EZA_ICONS:-1}"

if dotfiles_is_wsl && dotfiles_is_windows_mount_path; then
  builtin cd "$HOME"
fi

source "$DOTFILES_ROOT/shell/zsh/path.zsh"
source "$DOTFILES_ROOT/shell/zsh/environment.zsh"
source "$DOTFILES_ROOT/shell/zsh/platform.zsh"
source "$DOTFILES_ROOT/shell/zsh/plugins.zsh"
source "$DOTFILES_ROOT/shell/zsh/options.zsh"
source "$DOTFILES_ROOT/shell/zsh/aliases.zsh"
source "$DOTFILES_ROOT/shell/zsh/functions.zsh"
source "$DOTFILES_ROOT/shell/zsh/integrations.zsh"
source "$DOTFILES_ROOT/shell/zsh/lang-managers.zsh"
