return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        require("mason-tool-installer").setup({
            ensure_installed = {
                -- LSP servers
                "pyright",
                "eslint",
                "html",
                "cssls",
                "tailwindcss",
                "jsonls",
                "yamlls",
                "lua_ls",
                "bashls",
                "clangd",
                "ts_ls",
                "sqlls",
                "djlsp",

                -- Formatters
                "prettier",
                "stylua",
                "isort",
                "black",
                "clang-format",
                "google-java-format",
                "shfmt",
                "sql-formatter",
                "djlint",
                "php-cs-fixer",

                -- Linters
                "flake8",
                "rubocop",
                "shellcheck",
                "sqlfluff",
                "cpplint",

                -- Go
                "goimports",
                "gofumpt",
            },
            auto_update = true,
            run_on_start = true,
        })
    end,
}
