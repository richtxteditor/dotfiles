return {
    {
        "stevearc/overseer.nvim",
        opts = {
            task_list = {
                direction = "bottom",
                min_height = 25,
                max_height = 25,
                default_detail = 1,
            },
        },
        keys = {
            { "<leader>r", "<cmd>OverseerRun<cr>",       desc = "Run Task" },
            { "<leader>to", "<cmd>OverseerToggle<cr>",    desc = "Toggle Task Output" },
            { "<leader>tc", "<cmd>OverseerRunCmd<cr>",    desc = "Run Command" },
        },
    },
}
