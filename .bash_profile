# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:$HOME/.juliaup/bin:*)
        ;;

    *)
        export PATH=$HOME/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<

# --- conda (lazy-load for faster shell startup) ---
conda() {
    unset -f conda
    __conda_setup="$('$HOME/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
            . "$HOME/anaconda3/etc/profile.d/conda.sh"
        else
            export PATH="$HOME/anaconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    conda "$@"
}
