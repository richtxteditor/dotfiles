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
        {
            "<leader>K",
            function()
                local ft = vim.bo.filetype
                if (ft == "tex" or ft == "plaintex" or ft == "bib") and vim.fn.executable("texdoc") == 1 then
                    local topic = vim.fn.expand("<cword>")
                    if topic == nil or topic == "" then
                        topic = "latex"
                    end
                    vim.cmd("botright split")
                    vim.cmd("terminal texdoc " .. vim.fn.shellescape(topic))
                    return
                end

                vim.cmd("DevdocsOpenCurrentFloat")
            end,
            desc = "Open current file docs",
        },
    },
    opts = {
        filetypes = {
            bash = "bash",
            sh = "bash",
            zsh = "bash",
            c = "c",
            cpp = { "cpp", "c" },
            python = { "python~3.12", "django~5.2" },
            javascript = { "javascript", "typescript" },
            javascriptreact = { "react", "javascript", "typescript", "html", "css", "tailwindcss" },
            typescript = { "typescript", "javascript" },
            typescriptreact = { "react", "typescript", "javascript", "html", "css", "tailwindcss" },
            html = { "html", "css", "tailwindcss" },
            css = { "css", "tailwindcss" },
            scss = { "css", "tailwindcss" },
            markdown = "markdown",
            sql = "postgresql~18",
            htmldjango = { "django~5.2", "html", "css", "tailwindcss" },
        },
        ensure_installed = {
            "bash",
            "c",
            "cpp",
            "markdown",
            "python~3.12",
            "javascript",
            "typescript",
            "react",
            "html",
            "css",
            "tailwindcss",
            "django~5.2",
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
