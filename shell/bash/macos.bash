case ":$PATH:" in
    *:/opt/homebrew/bin:*) ;;
    *) export PATH="/opt/homebrew/bin:$PATH" ;;
esac

alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'

update() {
    sudo softwareupdate -i -a

    if command -v brew >/dev/null 2>&1; then
        brew update && HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade && brew cleanup
    fi

    echo "Updates complete."
}
