if [ -d /usr/local/bin ]; then
    case ":$PATH:" in
        *:/usr/local/bin:*) ;;
        *) export PATH="/usr/local/bin:$PATH" ;;
    esac
fi

update() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "Ubuntu-focused setup: apt-get not found."
        return 1
    fi    

    sudo apt-get update && sudo apt-get upgrade -y
    echo "Updates complete."
}
