source "$DOTFILES_ROOT/shell/zsh/path/common.zsh"

case "${DOTFILES_PLATFORM:-}" in
  macos)
    source "$DOTFILES_ROOT/shell/zsh/path/macos.zsh"
    ;;
  linux)
    source "$DOTFILES_ROOT/shell/zsh/path/linux.zsh"
    ;;
esac
