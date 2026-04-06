# Thin entrypoint: source the real shell modules from the repo root.
ZSHRC_DIR="${${(%):-%N}:P:h}"
export DOTFILES_ROOT="$ZSHRC_DIR"

source "$DOTFILES_ROOT/shell/shared/platform.sh"
export DOTFILES_PLATFORM="$(dotfiles_platform)"

source "$DOTFILES_ROOT/shell/zsh/path.zsh"
source "$DOTFILES_ROOT/shell/zsh/environment.zsh"
source "$DOTFILES_ROOT/shell/zsh/platform.zsh"
source "$DOTFILES_ROOT/shell/zsh/plugins.zsh"
source "$DOTFILES_ROOT/shell/zsh/options.zsh"
source "$DOTFILES_ROOT/shell/zsh/aliases.zsh"
source "$DOTFILES_ROOT/shell/zsh/functions.zsh"
source "$DOTFILES_ROOT/shell/zsh/integrations.zsh"
source "$DOTFILES_ROOT/shell/zsh/lang-managers.zsh"
