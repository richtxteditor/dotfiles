# >>> juliaup initialize >>>
# !! Contents within this block are managed by juliaup !!
case ":$PATH:" in
    *:"$HOME/.juliaup/bin":*) ;;
    *) export PATH="$HOME/.juliaup/bin${PATH:+:${PATH}}" ;;
esac
# <<< juliaup initialize <<<

case ":$PATH:" in
    *:"$HOME/.local/bin":*) ;;
    *) export PATH="$HOME/.local/bin${PATH:+:${PATH}}" ;;
esac

case ":$PATH:" in
    *:"$HOME/.cargo/bin":*) ;;
    *) export PATH="$HOME/.cargo/bin${PATH:+:${PATH}}" ;;
esac

case ":$PATH:" in
    *:"$HOME/.composer/vendor/bin":*) ;;
    *) export PATH="$HOME/.composer/vendor/bin:$PATH" ;;
esac

case ":$PATH:" in
    *:"$HOME/.opencode/bin":*) ;;
    *) export PATH="$HOME/.opencode/bin:$PATH" ;;
esac

case ":$PATH:" in
    *:"$HOME/.antigravity/antigravity/bin":*) ;;
    *) export PATH="$HOME/.antigravity/antigravity/bin:$PATH" ;;
esac

export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

conda() {
    unset -f conda

    local conda_root="$HOME/anaconda3"
    local conda_setup
    conda_setup="$("$conda_root/bin/conda" 'shell.bash' 'hook' 2>/dev/null)"
    if [ $? -eq 0 ]; then
        eval "$conda_setup"
    elif [ -f "$conda_root/etc/profile.d/conda.sh" ]; then
        . "$conda_root/etc/profile.d/conda.sh"
    else
        export PATH="$conda_root/bin:$PATH"
    fi

    unset conda_setup
    conda "$@"
}
