BASH_ENTRY_SOURCE="${BASH_SOURCE[0]}"
while [ -L "$BASH_ENTRY_SOURCE" ]; do
    BASH_ENTRY_DIR="$(cd -P "$(dirname "$BASH_ENTRY_SOURCE")" && pwd)"
    BASH_ENTRY_SOURCE="$(readlink "$BASH_ENTRY_SOURCE")"
    case "$BASH_ENTRY_SOURCE" in
        /*) ;;
        *) BASH_ENTRY_SOURCE="$BASH_ENTRY_DIR/$BASH_ENTRY_SOURCE" ;;
    esac
done

BASH_ENTRY_DIR="$(cd -P "$(dirname "$BASH_ENTRY_SOURCE")" && pwd)"

if [ -z "${DOTFILES_ROOT:-}" ]; then
    export DOTFILES_ROOT="$(cd -P "$BASH_ENTRY_DIR/../.." && pwd)"
fi

# shellcheck disable=SC1091
. "$DOTFILES_ROOT/shell/shared/platform.sh"
# shellcheck disable=SC1091
. "$DOTFILES_ROOT/shell/bash/profile.bash"

if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1090
    . "$HOME/.cargo/env"
fi
