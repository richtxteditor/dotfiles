return {
    "luckasRanarison/nvim-devdocs",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
        "DevdocsFetch",
        "DevdocsInstall",
        "DevdocsOpen",
        "DevdocsOpenFloat",
        "DevdocsOpenCurrent",
        "DevdocsOpenCurrentFloat",
        "DevdocsUpdate",
    },
    keys = {
        { "<leader>K", "<cmd>DevdocsOpenCurrentFloat<cr>", desc = "Open current file docs" },
    },
    opts = {
        filetypes = {
            python = { "python~3.12", "django~5.2" },
            javascript = { "javascript", "typescript" },
            javascriptreact = { "javascript", "typescript", "html", "css", "tailwindcss" },
            typescript = { "typescript", "javascript" },
            typescriptreact = { "typescript", "javascript", "html", "css", "tailwindcss" },
            html = { "html", "css", "tailwindcss" },
            css = { "css", "tailwindcss" },
            scss = { "css", "tailwindcss" },
            sql = "postgresql~18",
            htmldjango = { "django~5.2", "html", "css", "tailwindcss" },
        },
        ensure_installed = {
            "python~3.12",
            "javascript",
            "typescript",
            "html",
            "css",
            "tailwindcss",
            "django~5.2",
            "c",
            "cpp",
            "postgresql~18",
        },
        float_win = {
            relative = "editor",
            height = 35,
            width = 120,
            border = "rounded",
        },
        after_open = function(bufnr)
            vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":close<cr>", { silent = true })
        end,
    },
}
