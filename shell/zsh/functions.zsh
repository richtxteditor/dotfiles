mkcd() { mkdir -p "$1" && builtin cd "$1"; }

if dotfiles_is_macos; then
  ic() { builtin cd ~/Library/Mobile\ Documents/com~apple~CloudDocs; }
fi

ta() {
  if tmux has-session 2>/dev/null; then
    tmux attach-session -t "$(tmux list-sessions -F '#S' | head -n 1)"
  else
    tmux new-session
  fi
}

nom() {
    local config
    config="$(dotfiles_nom_config_path)"
    if [[ -f "$config" ]]; then
        local style
        style="$(dotfiles_read_interface_style)"
        if [[ "$style" == "Dark" ]]; then
            perl -pi -e 's/glamour: light/glamour: dark/' "$config"
        else
            perl -pi -e 's/glamour: dark/glamour: light/' "$config"
        fi
    fi
    command nom "$@"
}

gemini() {
    local config="$HOME/.gemini/settings.json"
    if [[ -f "$config" ]]; then
        local style
        style="$(dotfiles_read_interface_style)"
        if [[ "$style" == "Dark" ]]; then
            perl -pi -e 's/"theme": "[^"]*"/"theme": "Atom One"/' "$config"
        else
            perl -pi -e 's/"theme": "[^"]*"/"theme": "Google Code"/' "$config"
        fi
    fi
    command gemini "$@"
}

# Quick repo diagnostics inspired by piechowski.io/post/git-commands-before-reading-code/.
gchurn() {
    local since="${1:-1 year ago}"
    local limit="${2:-20}"
    local output

    output="$(command git log --format=format: --name-only --since="$since" | sed '/^$/d' | sort | uniq -c | sort -nr | head -n "$limit")"

    printf '%-8s %s\n' "changes" "file"
    if [[ -n "$output" ]]; then
        printf '%s\n' "$output" | awk '{count=$1; $1=""; sub(/^[ \t]+/, "", $0); printf "%-8s %s\n", count, $0}'
    fi
}

gauthors() {
    local shortlog_output

    if [[ $# -gt 0 ]]; then
        shortlog_output="$(command git shortlog -sn --no-merges --since="$1" HEAD)"
    else
        shortlog_output="$(command git shortlog -sn --no-merges HEAD)"
    fi

    printf '%-8s %s\n' "commits" "author"
    if [[ -n "$shortlog_output" ]]; then
        printf '%s\n' "$shortlog_output" | awk '{count=$1; $1=""; sub(/^[ \t]+/, "", $0); printf "%-8s %s\n", count, $0}'
    fi
}

gbugs() {
    local since="${1:-1 year ago}"
    local limit="${2:-20}"
    local pattern="${3:-fix|bug|broken}"
    local output

    output="$(command git log -i -E --since="$since" --grep="$pattern" --name-only --format='' | sed '/^$/d' | sort | uniq -c | sort -nr | head -n "$limit")"

    printf '%-8s %s\n' "matches" "file"
    if [[ -n "$output" ]]; then
        printf '%s\n' "$output" | awk '{count=$1; $1=""; sub(/^[ \t]+/, "", $0); printf "%-8s %s\n", count, $0}'
    fi
}

gvelocity() {
    local output

    output="$(command git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c)"

    printf '%-8s %s\n' "commits" "month"
    if [[ -n "$output" ]]; then
        printf '%s\n' "$output" | awk '{printf "%-8s %s\n", $1, $2}'
    fi
}

gfire() {
    local since="${1:-1 year ago}"
    local pattern="${2:-revert|hotfix|emergency|rollback}"
    local output

    output="$(command git log --oneline --since="$since" | grep -iE "$pattern")"

    printf '%-8s %s\n' "commit" "message"
    if [[ -n "$output" ]]; then
        printf '%s\n' "$output"
    fi
}

gscan() {
    local since="${1:-1 year ago}"
    local limit="${2:-20}"

    printf '== Churn Hotspots (%s, top %s) ==\n' "$since" "$limit"
    gchurn "$since" "$limit"
    printf '\n== Authors ==\n'
    gauthors
    printf '\n== Recent Authors (%s) ==\n' "$since"
    gauthors "$since"
    printf '\n== Bug Hotspots (%s, top %s) ==\n' "$since" "$limit"
    gbugs "$since" "$limit"
    printf '\n== Commit Velocity ==\n'
    gvelocity
    printf '\n== Firefighting Signals (%s) ==\n' "$since"
    gfire "$since"
}

_noarg_hl() {
    local cmd="$1"
    shift
    local wants_help=0
    local wants_verbose=0

    if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
        wants_help=1
    elif [[ $# -eq 1 && ( "$1" == "-v" || "$1" == "--verbose" ) ]]; then
        wants_verbose=1
    elif [[ $# -eq 2 ]]; then
        if [[ ( "$1" == "-h" || "$1" == "--help" ) && ( "$2" == "-v" || "$2" == "--verbose" ) ]]; then
            wants_help=1
            wants_verbose=1
        elif [[ ( "$2" == "-h" || "$2" == "--help" ) && ( "$1" == "-v" || "$1" == "--verbose" ) ]]; then
            wants_help=1
            wants_verbose=1
        fi
    fi

    if [[ -z "${_HAS_BAT+x}" ]]; then
        if command -v bat >/dev/null 2>&1; then
            _HAS_BAT=1
        else
            _HAS_BAT=0
        fi
    fi

    if [[ ( $# -eq 0 || $wants_help -eq 1 || $wants_verbose -eq 1 ) && -t 1 && $_HAS_BAT -eq 1 ]]; then
        command "$cmd" "$@" | bat -l help -p
        local -a ps=(${pipestatus[@]})
        return $ps[1]
    fi

    command "$cmd" "$@"
}

if ! alias ssh >/dev/null 2>&1 && ! (( $+functions[ssh] )); then
  ssh() { _noarg_hl ssh "$@"; }
fi
if ! alias tldr >/dev/null 2>&1 && ! (( $+functions[tldr] )); then
  tldr() { _noarg_hl tldr "$@"; }
fi
if ! alias git >/dev/null 2>&1 && ! (( $+functions[git] )); then
  git() { _noarg_hl git "$@"; }
fi
if ! alias rg >/dev/null 2>&1 && ! (( $+functions[rg] )); then
  rg() { _noarg_hl rg "$@"; }
fi
if ! alias curl >/dev/null 2>&1 && ! (( $+functions[curl] )); then
  curl() { _noarg_hl curl "$@"; }
fi
if ! alias jq >/dev/null 2>&1 && ! (( $+functions[jq] )); then
  jq() { _noarg_hl jq "$@"; }
fi
if ! alias docker >/dev/null 2>&1 && ! (( $+functions[docker] )); then
  docker() { _noarg_hl docker "$@"; }
fi
if ! alias kubectl >/dev/null 2>&1 && ! (( $+functions[kubectl] )); then
  kubectl() { _noarg_hl kubectl "$@"; }
fi
