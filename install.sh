#!/usr/bin/env bash

set -euo pipefail

dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "$dir/shell/shared/platform.sh"
# shellcheck disable=SC1091
. "$dir/config/toolchain.sh"

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
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run|-n)
                DRY_RUN=1
                ;;
            --skip-deps)
                SKIP_DEPS=1
                ;;
            *)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
        esac
        shift
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
    local apt_packages
    apt_packages="$(dotfiles_join_by ' ' "${DOTFILES_APT_PACKAGES[@]}")"

    echo "Ubuntu package install command:"
    echo "  sudo apt-get update && sudo apt-get install -y $apt_packages"
    echo "Pinned Neovim $DOTFILES_NEOVIM_LINUX_VERSION is installed separately from upstream into ~/.local."
    echo "Rustup is installed separately into ~/.cargo for Rust-based Neovim plugins."
    echo "tree-sitter-cli is installed separately via npm."
    echo "If you are not on Ubuntu or Debian, install equivalent packages manually."
}

should_manage_dependencies() {
    [[ -z "$SKIP_DEPS" ]]
}

is_ci_smoke_install() {
    [[ "${DOTFILES_CI_SMOKE_INSTALL:-}" == "1" ]]
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
            echo "$step. Install macOS dependencies via 'brew bundle' from Brewfile."
        elif dotfiles_is_linux; then
            echo "$step. Skip Homebrew on Linux."
            ((step++))
            echo "$step. Install dependencies via Ubuntu apt."
            ((step++))
            echo "$step. Install pinned Neovim release from upstream."
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

run_downloaded_script() {
    local label="$1"
    local url="$2"
    local expected_sha256="$3"
    local interpreter="$4"
    local temp_dir script_path status
    shift 4

    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: download $url, verify sha256 $expected_sha256, and run $interpreter $* ($label)"
        return
    fi

    temp_dir="$(mktemp -d)"
    script_path="$temp_dir/install.sh"

    status=0
    download_verified_file "$label" "$url" "$script_path" "$expected_sha256" || status=$?
    if [[ "$status" -eq 0 ]]; then
        "$interpreter" "$script_path" "$@" || status=$?
    fi

    rm -rf "$temp_dir"
    return "$status"
}

sha256_file() {
    local file_path="$1"

    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file_path" | awk '{ print $1 }'
        return
    fi

    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file_path" | awk '{ print $1 }'
        return
    fi

    echo "No SHA256 tool found. Install shasum or sha256sum." >&2
    return 1
}

verify_sha256() {
    local label="$1"
    local file_path="$2"
    local expected_sha256="$3"
    local actual_sha256

    actual_sha256="$(sha256_file "$file_path")"
    if [[ "$actual_sha256" != "$expected_sha256" ]]; then
        echo "SHA256 mismatch for $label." >&2
        echo "Expected: $expected_sha256" >&2
        echo "Actual:   $actual_sha256" >&2
        return 1
    fi
}

download_verified_file() {
    local label="$1"
    local url="$2"
    local output_path="$3"
    local expected_sha256="$4"

    curl -fsSL "$url" -o "$output_path"
    verify_sha256 "$label" "$output_path" "$expected_sha256"
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
                echo "DRY RUN: eval \"\$(/opt/homebrew/bin/brew shellenv)\""
            else
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        elif [[ -d /usr/local/Homebrew ]]; then
            if [[ -n "$DRY_RUN" ]]; then
                echo "DRY RUN: eval \"\$(/usr/local/bin/brew shellenv)\""
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        return
    fi

}

ensure_homebrew() {
    local install_url

    if dotfiles_is_linux; then
        echo "Skipping Homebrew on Linux."
        return
    fi

    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew is already installed."
        return
    fi

    echo "Homebrew not found. Installing..."
    install_url="https://raw.githubusercontent.com/Homebrew/install/${DOTFILES_HOMEBREW_INSTALL_COMMIT}/install.sh"
    run_downloaded_script "Homebrew installer" "$install_url" "$DOTFILES_HOMEBREW_INSTALL_SHA256" /bin/bash
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
    run_with_optional_sudo apt-get install -y "${DOTFILES_APT_PACKAGES[@]}"
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
    dotfiles_version_ge "$1" "$2"
}

install_latest_neovim_linux() {
    local desired_version="${NVIM_LINUX_VERSION:-stable}"
    local arch archive_name archive_url temp_dir archive_path extracted_dir install_dir current_version expected_sha256 version_label status

    if ! dotfiles_is_linux; then
        return
    fi

    arch="$(linux_neovim_arch)" || exit 1
    archive_name="nvim-linux-${arch}.tar.gz"
    if [[ "$desired_version" == "stable" ]]; then
        version_label="$DOTFILES_NEOVIM_LINUX_VERSION"
        expected_sha256="$(dotfiles_neovim_linux_sha256_for_arch "$arch")"
        archive_url="https://github.com/neovim/neovim/releases/download/v${version_label}/$archive_name"
        install_dir="$HOME/.local/opt/nvim-stable"
        echo "Installing pinned Neovim $version_label from upstream release ($archive_name)..."
    else
        current_version="$(current_nvim_version || true)"
        if [[ -n "$current_version" ]] && version_ge "$current_version" "$desired_version"; then
            echo "Neovim $current_version already satisfies Linux target version $desired_version."
            return
        fi

        version_label="$desired_version"
        if [[ "$desired_version" == "$DOTFILES_NEOVIM_LINUX_VERSION" ]]; then
            expected_sha256="$(dotfiles_neovim_linux_sha256_for_arch "$arch")"
        elif [[ -n "${NVIM_LINUX_SHA256:-}" ]]; then
            expected_sha256="$NVIM_LINUX_SHA256"
        else
            echo "NVIM_LINUX_VERSION=$desired_version requires NVIM_LINUX_SHA256 for verified install." >&2
            exit 1
        fi

        archive_url="https://github.com/neovim/neovim/releases/download/v${desired_version}/$archive_name"
        install_dir="$HOME/.local/opt/nvim-${desired_version}"
        echo "Installing Neovim $desired_version from upstream release ($archive_name)..."
    fi

    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: download $archive_url"
        echo "DRY RUN: verify sha256 $expected_sha256 for Neovim $version_label"
        echo "DRY RUN: extract archive into $install_dir"
        echo "DRY RUN: symlink $HOME/.local/bin/nvim -> $install_dir/bin/nvim"
        return
    fi

    temp_dir="$(mktemp -d)"
    archive_path="$temp_dir/$archive_name"
    extracted_dir="$temp_dir/extracted"

    status=0
    mkdir -p "$extracted_dir" "$HOME/.local/bin" "$(dirname "$install_dir")" || status=$?
    if [[ "$status" -eq 0 ]]; then
        download_verified_file "Neovim $version_label" "$archive_url" "$archive_path" "$expected_sha256" || status=$?
    fi
    if [[ "$status" -eq 0 ]]; then
        tar -xzf "$archive_path" -C "$extracted_dir" || status=$?
    fi
    if [[ "$status" -eq 0 ]]; then
        rm -rf "$install_dir" || status=$?
    fi
    if [[ "$status" -eq 0 ]]; then
        mv "$extracted_dir/nvim-linux-${arch}" "$install_dir" || status=$?
    fi
    if [[ "$status" -eq 0 ]]; then
        ln -snf "$install_dir/bin/nvim" "$HOME/.local/bin/nvim" || status=$?
    fi

    rm -rf "$temp_dir"
    return "$status"
}

install_starship() {
    local arch target expected_sha256 archive_name archive_url temp_dir archive_path extracted_dir status

    if ! dotfiles_is_linux; then
        return
    fi

    if is_ci_smoke_install; then
        echo "Skipping starship install: CI smoke mode."
        return
    fi

    run_cmd mkdir -p "$HOME/.local/bin"

    if command -v starship >/dev/null 2>&1; then
        echo "starship is already installed."
        return
    fi

    arch="$(linux_neovim_arch)" || exit 1
    target="$(dotfiles_starship_target_for_arch "$arch")"
    expected_sha256="$(dotfiles_starship_sha256_for_target "$target")"
    archive_name="starship-${target}.tar.gz"
    archive_url="https://github.com/starship/starship/releases/download/v${DOTFILES_STARSHIP_VERSION}/${archive_name}"

    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: download $archive_url"
        echo "DRY RUN: verify sha256 $expected_sha256 for starship $DOTFILES_STARSHIP_VERSION"
        echo "DRY RUN: install starship into $HOME/.local/bin/starship"
        return
    fi

    echo "Installing starship $DOTFILES_STARSHIP_VERSION..."
    temp_dir="$(mktemp -d)"
    archive_path="$temp_dir/$archive_name"
    extracted_dir="$temp_dir/extracted"

    status=0
    mkdir -p "$extracted_dir" "$HOME/.local/bin" || status=$?
    if [[ "$status" -eq 0 ]]; then
        download_verified_file "starship $DOTFILES_STARSHIP_VERSION" "$archive_url" "$archive_path" "$expected_sha256" || status=$?
    fi
    if [[ "$status" -eq 0 ]]; then
        tar -xzf "$archive_path" -C "$extracted_dir" || status=$?
    fi
    if [[ "$status" -eq 0 ]]; then
        mv "$extracted_dir/starship" "$HOME/.local/bin/starship" || status=$?
    fi
    if [[ "$status" -eq 0 ]]; then
        chmod 0755 "$HOME/.local/bin/starship" || status=$?
    fi

    rm -rf "$temp_dir"
    return "$status"
}

install_rustup() {
    local arch target expected_sha256 rustup_url temp_dir rustup_init status

    if ! dotfiles_is_linux; then
        return
    fi

    if is_ci_smoke_install; then
        echo "Skipping rustup install: CI smoke mode."
        return
    fi

    if command -v rustup >/dev/null 2>&1; then
        echo "rustup is already installed."
        return
    fi

    arch="$(linux_neovim_arch)" || exit 1
    target="$(dotfiles_rustup_target_for_arch "$arch")"
    expected_sha256="$(dotfiles_rustup_sha256_for_target "$target")"
    rustup_url="https://static.rust-lang.org/rustup/archive/${DOTFILES_RUSTUP_VERSION}/${target}/rustup-init"

    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: download $rustup_url"
        echo "DRY RUN: verify sha256 $expected_sha256 for rustup $DOTFILES_RUSTUP_VERSION"
        echo "DRY RUN: run rustup-init -y --profile minimal"
        return
    fi

    echo "Installing rustup $DOTFILES_RUSTUP_VERSION..."
    temp_dir="$(mktemp -d)"
    rustup_init="$temp_dir/rustup-init"

    status=0
    download_verified_file "rustup $DOTFILES_RUSTUP_VERSION" "$rustup_url" "$rustup_init" "$expected_sha256" || status=$?
    if [[ "$status" -eq 0 ]]; then
        chmod 0755 "$rustup_init" || status=$?
    fi
    if [[ "$status" -eq 0 ]]; then
        "$rustup_init" -y --profile minimal || status=$?
    fi

    rm -rf "$temp_dir"
    return "$status"
}

install_tree_sitter_cli() {
    local npm_prefix="$HOME/.local"

    if ! dotfiles_is_linux; then
        return
    fi

    if is_ci_smoke_install; then
        echo "Skipping tree-sitter-cli install: CI smoke mode."
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

    if is_ci_smoke_install; then
        echo "Skipping locale setup: CI smoke mode."
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
    if is_ci_smoke_install; then
        echo "Skipping Oh My Zsh extras install: CI smoke mode."
        return
    fi

    install_oh_my_zsh
    install_omz_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    install_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    install_omz_plugin "fzf-tab" "https://github.com/Aloxaf/fzf-tab"
}

install_hunkdiff() {
    local npm_prefix="$HOME/.local"

    if is_ci_smoke_install; then
        echo "Skipping hunkdiff install: CI smoke mode."
        return
    fi

    if command -v hunk >/dev/null 2>&1; then
        echo "hunkdiff is already installed."
        return
    fi

    if ! command -v npm >/dev/null 2>&1; then
        echo "Skipping hunkdiff install: npm not found."
        return
    fi

    echo "Installing hunkdiff for Git Hunk aliases..."
    if [[ -n "$DRY_RUN" ]]; then
        echo "DRY RUN: npm install -g --prefix $npm_prefix hunkdiff"
        return
    fi

    mkdir -p "$npm_prefix"
    npm install -g --prefix "$npm_prefix" hunkdiff
}

install_node_neovim_host() {
    local npm_prefix="$HOME/.local"

    if is_ci_smoke_install; then
        echo "Skipping Node.js Neovim host install: CI smoke mode."
        return
    fi

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

    if is_ci_smoke_install; then
        echo "Skipping Ruby Neovim host install: CI smoke mode."
        return
    fi

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

    if [[ ! -f "$dir/Brewfile" ]]; then
        echo "Missing Brewfile: $dir/Brewfile" >&2
        exit 1
    fi

    echo "Installing macOS dependencies from Brewfile..."
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

    if is_ci_smoke_install; then
        echo "Skipping Tmux Plugin Manager install: CI smoke mode."
        return
    fi

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
    treesitter_languages=("${DOTFILES_NVIM_TREESITTER_LANGUAGES[@]}")
    devdocs_entries=("${DOTFILES_DEVDOCS_ENTRIES[@]}")

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

    lua_list="$(printf '"%s",' "${treesitter_languages[@]}")"
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
    install_hunkdiff
    install_node_neovim_host
    install_ruby_neovim_host
    install_tpm
    install_pynvim_provider
    bootstrap_neovim_environment
    echo "Dotfiles installation complete!"
    echo "If you saw any errors, your original files are safe in $olddir"
}

main "$@"
