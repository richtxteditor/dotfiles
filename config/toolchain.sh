#!/usr/bin/env bash
# shellcheck shell=bash disable=SC2034

DOTFILES_APT_PACKAGES=(
    git curl zsh tmux fzf ripgrep fd-find bat xclip
    build-essential zoxide eza zsh-autosuggestions zsh-syntax-highlighting
    python3 python3-venv python3-pip
    nodejs npm ruby-full golang-go clangd
    php-cli php-mbstring php-xml composer
    default-jdk luarocks locales texlive-latex-base
)

DOTFILES_BREW_REQUIRED_PACKAGES=(
    neovim node php composer lua luarocks go ruby tree-sitter-cli
    tmux ripgrep fd eza fzf shellcheck starship openjdk
)

DOTFILES_LINUX_VERIFY_TOOLS=(
    zsh tmux tree-sitter node npm ruby go php composer javac luarocks
)

DOTFILES_MACOS_VERIFY_TOOLS=(
    brew zsh tmux nvim lua
)

DOTFILES_MIN_VERSION_nvim="0.12.1"
DOTFILES_MIN_VERSION_node="18.19.0"
DOTFILES_MIN_VERSION_npm="9.2.0"
DOTFILES_MIN_VERSION_go="1.22.0"
DOTFILES_MIN_VERSION_php="8.2.0"
DOTFILES_MIN_VERSION_composer="2.0.0"
DOTFILES_MIN_VERSION_tree_sitter="0.26.0"

DOTFILES_HOMEBREW_INSTALL_COMMIT="5753984d1eb214c40e86489416be2d38972f836a"
DOTFILES_HOMEBREW_INSTALL_SHA256="f3e91784ffeda32bc397de7acc1154724cc47522a459c9ac656cca176eeba457"

DOTFILES_NEOVIM_LINUX_VERSION="0.12.2"
DOTFILES_NEOVIM_LINUX_X86_64_SHA256="31cf85945cb600d96cdf69f88bc68bec814acbff50863c5546adef3a1bcef260"
DOTFILES_NEOVIM_LINUX_ARM64_SHA256="f697d4e4582b6e4b5c3c26e76e06ce26efa08ba1768e03fd2733fcc422bb0490"

DOTFILES_STARSHIP_VERSION="1.25.1"
DOTFILES_STARSHIP_X86_64_UNKNOWN_LINUX_MUSL_SHA256="c6ddd3ecb9c0071a2ad38d98cee748160066b7c4f197421268058f4a5d6f8504"
DOTFILES_STARSHIP_AARCH64_UNKNOWN_LINUX_MUSL_SHA256="01517aab398959ea9ea73bdb4f032ea4dbb51dff5c8e5eb05b4a1b9b7ab872b8"

DOTFILES_RUSTUP_VERSION="1.29.0"
DOTFILES_RUSTUP_X86_64_UNKNOWN_LINUX_GNU_SHA256="4acc9acc76d5079515b46346a485974457b5a79893cfb01112423c89aeb5aa10"
DOTFILES_RUSTUP_AARCH64_UNKNOWN_LINUX_GNU_SHA256="9732d6c5e2a098d3521fca8145d826ae0aaa067ef2385ead08e6feac88fa5792"

DOTFILES_NVIM_LSP_SERVERS=(
    pyright eslint html cssls tailwindcss jsonls yamlls lua_ls
    bashls clangd ts_ls sqlls djlsp marksman texlab
)

DOTFILES_NVIM_MASON_TOOLS=(
    pyright eslint html cssls tailwindcss jsonls yamlls lua_ls
    bashls ts_ls sqlls djlsp marksman texlab
    prettier stylua isort black clang-format google-java-format
    shfmt sql-formatter djlint php-cs-fixer
    flake8 rubocop shellcheck sqlfluff cpplint
    goimports gofumpt
)

DOTFILES_NVIM_TREESITTER_LANGUAGES=(
    python javascript typescript tsx
    html css json yaml bash
    php java c cpp rust ruby go sql htmldjango regex
    markdown markdown_inline latex
)

DOTFILES_DEVDOCS_ENTRIES=(
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

DOTFILES_VERIFY_LINKS_COMMON=(
    ".zshrc"
    ".bash_profile"
    ".tmux.conf"
    ".config/nvim"
    ".config/starship.toml"
)

dotfiles_join_by() {
    local sep="$1"
    shift
    local out=""
    local item

    for item in "$@"; do
        if [[ -n "$out" ]]; then
            out+="$sep"
        fi
        out+="$item"
    done

    printf '%s\n' "$out"
}

dotfiles_version_ge() {
    local have="$1"
    local need="$2"

    awk -v have="$have" -v need="$need" '
        function part(value, idx, items, count, n, i) {
            count = split(value, items, /[^0-9]+/)
            n = 0
            for (i = 1; i <= count; i++) {
                if (items[i] == "") {
                    continue
                }
                n++
                if (n == idx) {
                    return items[i] + 0
                }
            }
            return 0
        }
        BEGIN {
            for (i = 1; i <= 6; i++) {
                have_part = part(have, i)
                need_part = part(need, i)
                if (have_part > need_part) {
                    exit 0
                }
                if (have_part < need_part) {
                    exit 1
                }
            }
            exit 0
        }
    '
}

dotfiles_min_version_for() {
    local tool_name="$1"
    local normalized="${tool_name//-/_}"
    local var_name="DOTFILES_MIN_VERSION_${normalized}"

    printf '%s\n' "${!var_name:-}"
}

dotfiles_neovim_linux_sha256_for_arch() {
    case "$1" in
        x86_64) printf '%s\n' "$DOTFILES_NEOVIM_LINUX_X86_64_SHA256" ;;
        arm64) printf '%s\n' "$DOTFILES_NEOVIM_LINUX_ARM64_SHA256" ;;
        *) return 1 ;;
    esac
}

dotfiles_starship_target_for_arch() {
    case "$1" in
        x86_64) printf '%s\n' "x86_64-unknown-linux-musl" ;;
        arm64) printf '%s\n' "aarch64-unknown-linux-musl" ;;
        *) return 1 ;;
    esac
}

dotfiles_starship_sha256_for_target() {
    case "$1" in
        x86_64-unknown-linux-musl) printf '%s\n' "$DOTFILES_STARSHIP_X86_64_UNKNOWN_LINUX_MUSL_SHA256" ;;
        aarch64-unknown-linux-musl) printf '%s\n' "$DOTFILES_STARSHIP_AARCH64_UNKNOWN_LINUX_MUSL_SHA256" ;;
        *) return 1 ;;
    esac
}

dotfiles_rustup_target_for_arch() {
    case "$1" in
        x86_64) printf '%s\n' "x86_64-unknown-linux-gnu" ;;
        arm64) printf '%s\n' "aarch64-unknown-linux-gnu" ;;
        *) return 1 ;;
    esac
}

dotfiles_rustup_sha256_for_target() {
    case "$1" in
        x86_64-unknown-linux-gnu) printf '%s\n' "$DOTFILES_RUSTUP_X86_64_UNKNOWN_LINUX_GNU_SHA256" ;;
        aarch64-unknown-linux-gnu) printf '%s\n' "$DOTFILES_RUSTUP_AARCH64_UNKNOWN_LINUX_GNU_SHA256" ;;
        *) return 1 ;;
    esac
}
