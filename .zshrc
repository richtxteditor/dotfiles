ZSHRC_DIR="${${(%):-%N}:P:h}"
export DOTFILES_ROOT="$ZSHRC_DIR"

source "$DOTFILES_ROOT/shell/shared/platform.sh"

case "${DOTFILES_PLATFORM:-$(dotfiles_platform)}" in
  macos)
    source "$DOTFILES_ROOT/platforms/macos/.zshrc"
    ;;
  linux)
    source "$DOTFILES_ROOT/platforms/ubuntu/.zshrc"
    ;;
esac
