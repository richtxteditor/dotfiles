BASH_PROFILE_SOURCE="${BASH_SOURCE[0]}"
while [ -L "$BASH_PROFILE_SOURCE" ]; do
    BASH_PROFILE_DIR="$(cd -P "$(dirname "$BASH_PROFILE_SOURCE")" && pwd)"
    BASH_PROFILE_SOURCE="$(readlink "$BASH_PROFILE_SOURCE")"
    case "$BASH_PROFILE_SOURCE" in
        /*) ;;
        *) BASH_PROFILE_SOURCE="$BASH_PROFILE_DIR/$BASH_PROFILE_SOURCE" ;;
    esac
done

BASH_PROFILE_DIR="$(cd -P "$(dirname "$BASH_PROFILE_SOURCE")" && pwd)"

# shellcheck disable=SC1091
. "$BASH_PROFILE_DIR/shell/shared/platform.sh"
# shellcheck disable=SC1091
. "$BASH_PROFILE_DIR/shell/bash/profile.bash"
