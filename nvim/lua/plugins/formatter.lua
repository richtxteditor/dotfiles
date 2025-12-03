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
                javascript = { { "prettierd", "prettier" } },
                typescript = { { "prettierd", "prettier" } },
                php = { "php-cs-fixer" },
                typescriptreact = { "prettier" },
                javascriptreact = { "prettier" },
                json = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                markdown = { "prettier" },

            },
            -- Optional: Run formatter automatically on save
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        })
    end,
}

