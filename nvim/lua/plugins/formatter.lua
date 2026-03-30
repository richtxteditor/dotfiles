-- lua/plugins/formatter.lua

return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- Run formatter before saving
    cmd = { "ConformInfo" },
    config = function()
        require("conform").setup({
            -- Configure formatters for different file types
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "isort", "black" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                php = { "php_cs_fixer" },
                typescriptreact = { "prettier" },
                javascriptreact = { "prettier" },
                json = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                markdown = { "prettier" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                c = { "clang_format" },
                cpp = { "clang_format" },
                java = { "google-java-format" },
                ruby = { "rubocop" },
                go = { "goimports", "gofumpt" },
                sql = { "sql_formatter" },
                htmldjango = { "djlint" },
            },
            -- Optional: Run formatter automatically on save
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
        })
    end,
}

