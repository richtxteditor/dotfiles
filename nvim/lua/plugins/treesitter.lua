return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- List of language parsers to install
                ensure_installed = {
                    "python", "javascript", "typescript", "tsx",
                    "html", "css", "json", "yaml", "bash",
                    "php", "java", "c", "cpp", "rust", "ruby", "go", "sql", "htmldjango", "regex",
                    "markdown", "markdown_inline",
                },
                auto_install = true,
                highlight = {
                    enable = true,
                    disable = { "markdown", "markdown_inline" },
                },
                indent = {
                    enable = true,
                    disable = { "markdown", "markdown_inline" },
                },
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("treesitter-context").setup({
                enable = true,            -- Enable this plugin
                max_lines = 0,            -- 0 means no limit
                trim_scope = "inner",      -- Or "outer"
                -- Avoid the 'range' nil value error in Neovim 0.12 nightly for markdown
                on_attach = function(buf)
                    local ft = vim.bo[buf].filetype
                    return ft ~= "markdown" and ft ~= "markdown_inline"
                end,
            })
        end,
    },
}
