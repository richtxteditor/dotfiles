#!/usr/bin/env bash

set -euo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$dir/shell/shared/platform.sh"

DRY_RUN=""
SKIP_DEPS=""
timestamp="$(date +%Y%m%d_%H%M%S)"
olddir="$HOME/dotfiles_backup_$timestamp"
link_specs=()

run_cmd() {
    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: $*"
    else
        "$@"
    fi
}

parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --dry-run|-n) DRY_RUN=1 ;;
            --skip-deps) SKIP_DEPS=1 ;;
        esac
    done
}

platform_label() {
    case "$(dotfiles_platform)" in
        macos) printf '%s\n' "macOS" ;;
        linux) printf '%s\n' "Linux" ;;
        *) printf '%s\n' "unknown platform" ;;
    esac
}

print_linux_package_workaround() {
    echo "Ubuntu package install command:"
    echo "  sudo apt-get update && sudo apt-get install -y git curl zsh tmux fzf ripgrep fd-find bat xclip build-essential zoxide eza zsh-autosuggestions zsh-syntax-highlighting python3 python3-venv python3-pip nodejs npm ruby-full golang-go clangd php-cli php-mbstring php-xml composer default-jdk luarocks locales texlive-latex-base"
    echo "Latest Neovim stable is installed separately from upstream into ~/.local."
    echo "Rustup is installed separately into ~/.cargo for Rust-based Neovim plugins."
    echo "tree-sitter-cli is installed separately via npm."
    echo "If you are not on Ubuntu or Debian, install equivalent packages manually."
}

should_manage_dependencies() {
    [[ -z "$SKIP_DEPS" ]]
}

confirm_proceed() {
    local step=1

    echo "--------------------------------------------------"
    echo "Detected platform: $(platform_label)"
    echo "This script will:"
    if should_manage_dependencies; then
        if dotfiles_is_macos; then
            echo "$step. Install Homebrew (if missing)."
            ((step++))
            echo "$step. Install dependencies via 'brew bundle'."
        elif dotfiles_is_linux; then
            echo "$step. Skip Homebrew on Linux."
            ((step++))
            echo "$step. Install dependencies via Ubuntu apt."
            ((step++))
            echo "$step. Install latest Neovim stable from upstream."
        else
            echo "$step. Skip dependency installation."
        fi
    else
        echo "$step. Skip dependency installation."
    fi
    ((step++))
    echo "$step. Backup existing dotfiles to $olddir."
    ((step++))
    echo "$step. Create symlinks for zsh, tmux, nvim, etc."
    ((step++))
    echo "$step. Set default shell to zsh when available."
    ((step++))
    echo "$step. Install Oh My Zsh and shell plugins."
    ((step++))
    echo "$step. Install Neovim host providers and runtime helpers."
    ((step++))
    echo "$step. Install Tmux Plugin Manager (TPM)."
    ((step++))
    echo "$step. Bootstrap Neovim plugins, parsers, and Mason tooling."
    echo "--------------------------------------------------"

    if [[ -n "$DRY_RUN" ]]; then
        echo "Running in dry-run mode (no changes will be made)."
        return
    fi

    read -r -p "Do you want to proceed? (y/n) " REPLY
    echo
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Installation aborted."
        exit 1
    fi
}

prepare_backup_dir() {
    echo "Creating backup directory at $olddir"
    run_cmd mkdir -p "$olddir"
}

check_and_install_lldb() {
    if ! dotfiles_is_macos; then
        return
    fi

    if ! command -v lldb >/dev/null 2>&1; then
        echo "---------------------------------------------------------------------"
        echo "WARNING: 'lldb' command not found."
        echo "CodeLLDB requires LLDB to be installed on your system."
        echo "Please install the Xcode Command Line Tools by running:"
        echo ""
        echo "    xcode-select --install"
        echo ""
        echo "After installation, re-run this script."
        echo "---------------------------------------------------------------------"
        if [[ -n "$DRY_RUN" ]]; then
            echo "DRY RUN: would exit due to missing LLDB."
            return
        fi
        exit 1
    fi

    echo "LLDB is already installed."
}

configure_brew_shellenv() {
    if dotfiles_is_macos; then
        if [[ -d /opt/homebrew ]]; then
            if [[ -n "$DRY_RUN" ]]; then
                echo "DRY RUN: eval \"$(/opt/homebrew/bin/brew shellenv)\""
            else
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        elif [[ -d /usr/local/Homebrew ]]; then
            if [[ -n "$DRY_RUN" ]]; then
                echo "DRY RUN: eval \"$(/usr/local/bin/brew shellenv)\""
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        return
    fi

}

ensure_homebrew() {
    if dotfiles_is_linux; then
        echo "Skipping Homebrew on Linux."
        return
    fi

    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew is already installed."
        return
    fi

    echo "Homebrew not found. Installing..."
    run_cmd /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    configure_brew_shellenv
}

run_with_optional_sudo() {
    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: $*"
        return
    fi

    if [[ "${EUID:-$(id -u)}" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        "$@"
    fi
}

install_linux_dependencies() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "Ubuntu-focused setup: apt-get not found."
        echo "Install equivalent packages manually on your distro."
        exit 1
    fi

    print_linux_package_workaround
    run_with_optional_sudo apt-get update
    run_with_optional_sudo apt-get install -y git curl zsh tmux fzf ripgrep fd-find bat xclip build-essential zoxide eza zsh-autosuggestions zsh-syntax-highlighting python3 python3-venv python3-pip nodejs npm ruby-full golang-go clangd php-cli php-mbstring php-xml composer default-jdk luarocks locales texlive-latex-base
}

linux_neovim_arch() {
    case "$(uname -m)" in
        x86_64|amd64) printf '%s\n' "x86_64" ;;
        aarch64|arm64) printf '%s\n' "arm64" ;;
        *)
            echo "Unsupported Linux architecture for upstream Neovim tarball: $(uname -m)" >&2
            return 1
            ;;
    esac
}

current_nvim_version() {
    if ! command -v nvim >/dev/null 2>&1; then
        return 1
    fi

    NVIM_LOG_FILE=/dev/null nvim --version 2>/dev/null | awk 'NR==1 { gsub(/^v/, "", $2); print $2 }'
}

version_ge() {
    [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n 1)" == "$2" ]]
}

install_latest_neovim_linux() {
    local desired_version="${NVIM_LINUX_VERSION:-stable}"
    local arch archive_name archive_url temp_dir archive_path extracted_dir install_dir current_version

    if ! dotfiles_is_linux; then
        return
    fi

    arch="$(linux_neovim_arch)" || exit 1
    archive_name="nvim-linux-${arch}.tar.gz"
    if [[ "$desired_version" == "stable" ]]; then
        archive_url="https://github.com/neovim/neovim/releases/latest/download/$archive_name"
        install_dir="$HOME/.local/opt/nvim-stable"
        echo "Installing latest Neovim stable from upstream release ($archive_name)..."
    else
        current_version="$(current_nvim_version || true)"
        if [[ -n "$current_version" ]] && version_ge "$current_version" "$desired_version"; then
            echo "Neovim $current_version already satisfies Linux target version $desired_version."
            return
        fi

        archive_url="https://github.com/neovim/neovim/releases/download/v${desired_version}/$archive_name"
        install_dir="$HOME/.local/opt/nvim-${desired_version}"
        echo "Installing Neovim $desired_version from upstream release ($archive_name)..."
    fi

    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: download $archive_url"
        echo "DRY RUN: extract archive into $install_dir"
        echo "DRY RUN: symlink $HOME/.local/bin/nvim -> $install_dir/bin/nvim"
        return
    fi

    temp_dir="$(mktemp -d)"
    archive_path="$temp_dir/$archive_name"
    extracted_dir="$temp_dir/extracted"

    mkdir -p "$extracted_dir" "$HOME/.local/bin" "$(dirname "$install_dir")"
    curl -fsSL "$archive_url" -o "$archive_path"
    tar -xzf "$archive_path" -C "$extracted_dir"

    rm -rf "$install_dir"
    mv "$extracted_dir/nvim-linux-${arch}" "$install_dir"
    ln -snf "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
    rm -rf "$temp_dir"
}

install_starship() {
    if ! dotfiles_is_linux; then
        return
    fi

    run_cmd mkdir -p "$HOME/.local/bin"

    if command -v starship >/dev/null 2>&1; then
        echo "starship is already installed."
        return
    fi

    echo "Installing starship..."
    run_cmd bash -c "curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b \"$HOME/.local/bin\""
}

install_rustup() {
    if ! dotfiles_is_linux; then
        return
    fi

    if command -v rustup >/dev/null 2>&1; then
        echo "rustup is already installed."
        return
    fi

    echo "Installing rustup..."
    run_cmd bash -c "curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal"
}

install_tree_sitter_cli() {
    local npm_prefix="$HOME/.local"

    if ! dotfiles_is_linux; then
        return
    fi

    if command -v tree-sitter >/dev/null 2>&1; then
        echo "tree-sitter-cli is already installed."
        return
    fi

    if ! command -v npm >/dev/null 2>&1; then
        echo "Skipping tree-sitter-cli install: npm not found."
        return
    fi

    echo "Installing tree-sitter-cli via npm..."
    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: npm install -g --prefix $npm_prefix tree-sitter-cli"
        return
    fi

    mkdir -p "$npm_prefix"
    npm install -g --prefix "$npm_prefix" tree-sitter-cli
}

ensure_utf8_locale_linux() {
    if ! dotfiles_is_linux; then
        return
    fi

    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"

    if ! command -v locale-gen >/dev/null 2>&1 || ! command -v update-locale >/dev/null 2>&1; then
        echo "Skipping locale setup: locale-gen/update-locale not available."
        return
    fi

    echo "Ensuring UTF-8 locale (en_US.UTF-8)..."
    run_with_optional_sudo locale-gen en_US.UTF-8
    run_with_optional_sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
}

install_oh_my_zsh() {
    local omz_dir="$HOME/.oh-my-zsh"

    if [[ -d "$omz_dir" ]]; then
        echo "Oh My Zsh is already installed."
        return
    fi

    echo "Installing Oh My Zsh..."
    run_cmd git clone https://github.com/ohmyzsh/ohmyzsh.git "$omz_dir"
}

install_omz_plugin() {
    local plugin_name="$1"
    local repo_url="$2"
    local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"

    if [[ -d "$plugin_dir" ]]; then
        echo "Oh My Zsh plugin '$plugin_name' is already installed."
        return
    fi

    echo "Installing Oh My Zsh plugin '$plugin_name'..."
    run_cmd git clone "$repo_url" "$plugin_dir"
}

install_zsh_extras() {
    install_oh_my_zsh
    install_omz_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    install_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    install_omz_plugin "fzf-tab" "https://github.com/Aloxaf/fzf-tab"
}

install_node_neovim_host() {
    local npm_prefix="$HOME/.local"

    if ! command -v npm >/dev/null 2>&1; then
        echo "Skipping Node.js Neovim host install: npm not found."
        return
    fi

    echo "Installing Node.js Neovim host..."
    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: npm install -g --prefix $npm_prefix neovim"
        return
    fi

    mkdir -p "$npm_prefix"
    npm install -g --prefix "$npm_prefix" neovim
}

install_ruby_neovim_host() {
    local gem_bindir

    if ! command -v ruby >/dev/null 2>&1 || ! command -v gem >/dev/null 2>&1; then
        echo "Skipping Ruby Neovim host install: ruby/gem not found."
        return
    fi

    echo "Installing Ruby Neovim host..."
    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: gem install --user-install neovim"
        echo "DRY RUN: symlink neovim-ruby-host into $HOME/.local/bin"
        return
    fi

    gem install --user-install neovim
    gem_bindir="$(ruby -r rubygems -e 'print Gem.bindir(Gem.user_dir)')"
    mkdir -p "$HOME/.local/bin"
    if [[ -x "$gem_bindir/neovim-ruby-host" ]]; then
        ln -snf "$gem_bindir/neovim-ruby-host" "$HOME/.local/bin/neovim-ruby-host"
    fi
}

install_dependencies() {
    if ! should_manage_dependencies; then
        echo "Skipping dependency installation (--skip-deps)."
        return
    fi

    if dotfiles_is_linux; then
        install_linux_dependencies
        install_latest_neovim_linux
        return
    fi

    echo "Installing core dependencies from Brewfile..."
    run_cmd brew bundle --file="$dir/Brewfile"
}

ensure_default_shell_is_zsh() {
    local zsh_path="${ZSH_PATH:-}"

    if [[ -z "$DRY_RUN" && ! -t 0 ]]; then
        echo "Skipping default shell change: non-interactive session."
        return
    fi

    if [[ "${SHELL:-}" == *zsh ]]; then
        echo "Default shell already uses zsh."
        return
    fi

    if [[ -z "$zsh_path" ]]; then
        zsh_path="$(command -v zsh 2>/dev/null || true)"
    fi

    if [[ -z "$zsh_path" ]]; then
        echo "Skipping default shell change: zsh not found yet."
        return
    fi

    if [[ -f /etc/shells ]] && ! grep -qx "$zsh_path" /etc/shells; then
        echo "Skipping default shell change: $zsh_path not listed in /etc/shells."
        echo "Add it to /etc/shells, then run: chsh -s $zsh_path"
        return
    fi

    if ! command -v chsh >/dev/null 2>&1; then
        echo "Skipping default shell change: chsh not available."
        echo "Set it manually with: chsh -s $zsh_path"
        return
    fi

    echo "Setting default shell to zsh ($zsh_path)..."
    run_cmd chsh -s "$zsh_path"
}

install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ -d "$tpm_dir" ]]; then
        echo "TPM is already installed."
        return
    fi

    echo "Installing Tmux Plugin Manager (TPM)..."
    run_cmd git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

add_link_spec() {
    link_specs+=("$1|$2|$3")
}

platform_source_file() {
    local macos_source="$1"
    local linux_source="$2"

    if dotfiles_is_macos; then
        printf '%s\n' "$macos_source"
        return
    fi

    if dotfiles_is_linux; then
        printf '%s\n' "$linux_source"
        return
    fi

    printf '%s\n' "$macos_source"
}

platform_variant() {
    if dotfiles_is_macos; then
        printf '%s\n' "macos"
        return
    fi

    if dotfiles_is_linux; then
        printf '%s\n' "ubuntu"
        return
    fi

    printf '%s\n' "macos"
}

build_link_specs() {
    local tmux_source ghostty_source platform_dir
    tmux_source="$(platform_source_file ".tmux.conf" ".tmux.conf")"
    ghostty_source="$(platform_source_file "ghostty/config.macos" "ghostty/config.linux")"
    platform_dir="platforms/$(platform_variant)"

    link_specs=(
        "$platform_dir/.zshrc|$HOME/.zshrc|.zshrc in home directory"
        "$tmux_source|$HOME/.tmux.conf|.tmux.conf in home directory"
        "tmux/common.conf|$HOME/.tmux/common.conf|tmux common config"
        "tmux/macos.conf|$HOME/.tmux/macos.conf|tmux macOS config"
        "tmux/linux.conf|$HOME/.tmux/linux.conf|tmux Linux config"
        "$platform_dir/.bash_profile|$HOME/.bash_profile|.bash_profile in home directory"
        ".fzf.zsh|$HOME/.fzf.zsh|.fzf.zsh in home directory"
        ".gitconfig|$HOME/.gitconfig|.gitconfig in home directory"
        ".gitignore_global|$HOME/.gitignore_global|.gitignore_global in home directory"
        "nvim|$HOME/.config/nvim|nvim in ~/.config directory"
        "$platform_dir/starship.toml|$HOME/.config/starship.toml|starship.toml in ~/.config directory"
        "claude/CLAUDE.md|$HOME/.claude/CLAUDE.md|Claude Code config"
    )

    local ghostty_target
    if ghostty_target="$(dotfiles_ghostty_config_target 2>/dev/null)"; then
        add_link_spec "$ghostty_source" "$ghostty_target" "Ghostty config"
    fi
}

ensure_symlink() {
    local relative_source="$1"
    local target_link="$2"
    local label="$3"
    local source_file="$dir/$relative_source"
    local target_dir current_link=""

    target_dir="$(dirname "$target_link")"
    run_cmd mkdir -p "$target_dir"

    if [[ -e "$target_link" && ! -L "$target_link" ]]; then
        echo "Backing up existing $label to $olddir"
        run_cmd mv "$target_link" "$olddir/"
    fi

    if [[ -L "$target_link" ]]; then
        current_link="$(readlink "$target_link")"
    fi

    if [[ "$current_link" != "$source_file" ]]; then
        echo "Creating symlink for $label."
        run_cmd ln -snf "$source_file" "$target_link"
    else
        echo "Symlink for $label is already correctly set up."
    fi
}

install_links() {
    local spec relative_source target_link label
    for spec in "${link_specs[@]}"; do
        IFS='|' read -r relative_source target_link label <<< "$spec"
        ensure_symlink "$relative_source" "$target_link" "$label"
    done
}

install_pynvim_provider() {
    local debugpy_pip="$HOME/.local/share/nvim/mason/packages/debugpy/venv/bin/pip"

    if [[ ! -x "$debugpy_pip" ]]; then
        echo "Note: debugpy venv not found yet. Open Neovim and let Mason install debugpy,"
        echo "then re-run this script to set up the Python provider."
        return
    fi

    echo "Installing/updating pynvim in debugpy venv for Neovim Python provider..."
    run_cmd "$debugpy_pip" install --upgrade pynvim
}

bootstrap_neovim_environment() {
    local treesitter_languages lua_list devdocs_entries devdocs_args
    treesitter_languages=(
        python javascript typescript tsx
        html css json yaml bash
        php java c cpp rust ruby go sql htmldjango regex
        markdown markdown_inline latex
    )
    devdocs_entries=(
        bash
        c
        cpp
        css
        "django~5.2"
        html
        javascript
        markdown
        react
        tailwindcss
        typescript
    )

    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: bootstrap Neovim plugins, Mason tools, and treesitter parsers"
        return
    fi

    if ! command -v nvim >/dev/null 2>&1; then
        echo "Skipping Neovim bootstrap: nvim not found."
        return
    fi

    if ! [[ -t 0 ]]; then
        echo "Skipping Neovim bootstrap: non-interactive session."
        return
    fi

    echo "Bootstrapping Neovim plugins..."
    nvim --headless "+Lazy! sync" +qa

    echo "Bootstrapping Mason tooling..."
    nvim --headless "+MasonUpdate" "+MasonToolsInstallSync" +qa

    lua_list="$(printf '"'"'"%s",'"'"' "${treesitter_languages[@]}")"
    lua_list="${lua_list%,}"

    echo "Bootstrapping treesitter parsers..."
    nvim --headless "+lua require('nvim-treesitter').install({${lua_list}}):wait(300000)" "+TSUpdateSync" +qa

    devdocs_args="$(printf '%s ' "${devdocs_entries[@]}")"
    devdocs_args="${devdocs_args% }"

    echo "Bootstrapping DevDocs offline docs..."
    nvim --headless "+DevdocsFetch" "+DevdocsInstall ${devdocs_args}" +qa
}

main() {
    parse_args "$@"
    confirm_proceed
    prepare_backup_dir
    ensure_homebrew
    install_dependencies
    echo "Checking for required dependencies..."
    check_and_install_lldb
    build_link_specs
    install_links
    ensure_default_shell_is_zsh
    install_starship
    install_rustup
    install_tree_sitter_cli
    ensure_utf8_locale_linux
    install_zsh_extras
    install_node_neovim_host
    install_ruby_neovim_host
    install_tpm
    install_pynvim_provider
    bootstrap_neovim_environment
    echo "Dotfiles installation complete!"
    echo "If you saw any errors, your original files are safe in $olddir"
}

main "$@"
