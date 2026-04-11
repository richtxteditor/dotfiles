case ":$PATH:" in
    *:/opt/homebrew/bin:*) ;;
    *) export PATH="/opt/homebrew/bin:$PATH" ;;
esac

alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'

update() {
    sudo softwareupdate -i -a

    if command -v brew >/dev/null 2>&1; then
        brew update && brew upgrade && brew cleanup
    fi

    echo "Updates complete."
}
