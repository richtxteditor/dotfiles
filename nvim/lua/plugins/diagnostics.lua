return {
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            -- Trouble v3 changed commands from TroubleToggle to Trouble [mode] toggle
            { "<leader>xx", "<cmd>Trouble diagnostics toggle focus=true<cr>",              desc = "Diagnostics (Trouble)" },
            { "<leader>xw", "<cmd>Trouble diagnostics toggle focus=true<cr>",              desc = "Workspace Diagnostics (Trouble)" },
            { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0 focus=true<cr>", desc = "Document Diagnostics (Trouble)" },
            { "<leader>xL", "<cmd>Trouble loclist toggle focus=true<cr>",                  desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle focus=true<cr>",                   desc = "Quickfix List (Trouble)" },
        },
        opts = {
            focus = true,
        },
    },
}