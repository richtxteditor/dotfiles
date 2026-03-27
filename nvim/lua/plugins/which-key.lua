return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
        end,
        opts = {
            spec = {
                { "<leader>f", group = "Find" },
                { "<leader>c", group = "Code" },
                { "<leader>d", group = "Debug" },
                { "<leader>g", group = "Git" },
                { "<leader>n", group = "Neotest" },
                { "<leader>t", group = "Tasks" },
            },
        },
    },
}
