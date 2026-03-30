return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
        require("mason-tool-installer").setup({
            ensure_installed = {
                -- Formatters
                "prettier", -- JS/TS/CSS/HTML
                "stylua", -- Lua
                "isort", -- Python
                "black", -- Python
                "clang-format", -- C/C++
                "google-java-format", -- Java
                "shfmt", -- Bash
                "sql-formatter", -- SQL
                "djlint", -- Django/Jinja
                "php-cs-fixer", -- PHP

                -- Linters
                "flake8", -- Python
                "rubocop", -- Ruby formatter (linting handled by solargraph LSP)
                "shellcheck", -- Bash
                "sqlfluff", -- SQL
                "cpplint", -- C/C++

                -- Go
                "goimports", -- Go imports
                "gofumpt", -- Go (stricter gofmt)
            },
            auto_update = true,
            run_on_start = true,
        })
    end,
}
