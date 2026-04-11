DOTFILES_PLATFORM="${DOTFILES_PLATFORM:-$(dotfiles_platform)}"
export DOTFILES_PLATFORM

. "$BASH_PROFILE_DIR/shell/bash/common.bash"

case "${DOTFILES_PLATFORM:-}" in
    macos)
        . "$BASH_PROFILE_DIR/shell/bash/macos.bash"
        ;;
    linux)
        . "$BASH_PROFILE_DIR/shell/bash/linux.bash"
        ;;
esac
