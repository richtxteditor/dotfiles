source "$DOTFILES_ROOT/shell/zsh/platform/common.zsh"

case "${DOTFILES_PLATFORM:-}" in
  macos)
    source "$DOTFILES_ROOT/shell/zsh/platform/macos.zsh"
    ;;
  linux)
    source "$DOTFILES_ROOT/shell/zsh/platform/linux.zsh"
    ;;
esac
