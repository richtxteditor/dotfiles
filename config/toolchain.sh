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
    neovim node php composer lua luarocks go ruby tree-sitter
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
        function part(value, index, items, count) {
            count = split(value, items, /[^0-9]+/)
            if (index > count || items[index] == "") {
                return 0
            }
            return items[index] + 0
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
