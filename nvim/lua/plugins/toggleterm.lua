return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
        { "<C-\\>", "<cmd>ToggleTerm direction=float<cr>", mode = { "n", "t" }, desc = "Toggle Float Terminal" },
    },
    opts = {
        size = 20,
        open_mapping = false,
        shade_terminals = false,
        float_opts = {
            border = "rounded",
            width = function() return math.floor(vim.o.columns * 0.85) end,
            height = function() return math.floor(vim.o.lines * 0.85) end,
        },
    },
}
