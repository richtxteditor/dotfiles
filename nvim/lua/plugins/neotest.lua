return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-jest",
            "fredrikaverpil/neotest-golang",
            "rouge8/neotest-rust",
        },
        keys = {
            { "<leader>nt", function() require("neotest").run.run() end,                     desc = "Run Nearest Test" },
            { "<leader>nf", function() require("neotest").run.run(vim.fn.expand("%")) end,   desc = "Run File Tests" },
            { "<leader>ns", function() require("neotest").summary.toggle() end,              desc = "Toggle Test Summary" },
            { "<leader>no", function() require("neotest").output.open({ enter = true }) end, desc = "Show Test Output" },
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        runner = "pytest",
                    }),
                    require("neotest-jest")({
                        jestCommand = "npx jest",
                    }),
                    require("neotest-golang")(),
                    require("neotest-rust"),
                },
                status = { virtual_text = true },
                output = { open_on_run = false },
            })
        end,
    },
}
