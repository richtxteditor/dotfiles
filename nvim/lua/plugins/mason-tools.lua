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

                -- Linters
                "eslint_d", -- JS/TS
                "flake8", -- Python
                "rubocop", -- Ruby
                "shellcheck", -- Bash
                "sqlfluff", -- SQL
                "cpplint", -- C/C++
            },
            auto_update = true,
            run_on_start = true,
        })
    end,
}
