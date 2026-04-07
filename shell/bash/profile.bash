# >>> juliaup initialize >>>
# !! Contents within this block are managed by juliaup !!
case ":$PATH:" in
    *:"$HOME/.juliaup/bin":*) ;;
    *) export PATH="$HOME/.juliaup/bin${PATH:+:${PATH}}" ;;
esac
# <<< juliaup initialize <<<

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
