ZSHRC_DIR="${${(%):-%N}:P:h}"
export DOTFILES_ROOT="${ZSHRC_DIR:h:h}"
export DOTFILES_PLATFORM="linux"

source "$DOTFILES_ROOT/shell/zsh/entrypoint.zsh"
