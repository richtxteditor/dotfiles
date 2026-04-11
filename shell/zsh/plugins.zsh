source "$DOTFILES_ROOT/shell/zsh/plugins/common.zsh"

case "${DOTFILES_PLATFORM:-}" in
  macos)
    source "$DOTFILES_ROOT/shell/zsh/plugins/macos.zsh"
    ;;
  linux)
    source "$DOTFILES_ROOT/shell/zsh/plugins/linux.zsh"
    ;;
esac

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi
