return {
    {
        "abecodes/tabout.nvim",
        lazy = false, -- Needs to load immediately to hook into keypresses
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "hrsh7th/nvim-cmp", -- Integrates with your completion engine
        },
        config = function()
            require("tabout").setup({
                tabkey = "<Tab>",             -- Key to trigger the jump
                backwards_tabkey = "<S-Tab>", -- Shift+Tab to jump backwards
                act_as_tab = true,            -- If not at a bracket, do normal Tab stuff (indent)
                act_as_shift_tab = false,     -- If not at a bracket, do normal Shift+Tab stuff
                enable_backwards = true,
                completion = true,            -- Use this if you use nvim-cmp
                tabouts = {
                    { open = "'", close = "'" },
                    { open = '"', close = '"' },
                    { open = "`", close = "`" },
                    { open = "(", close = ")" },
                    { open = "[", close = "]" },
                    { open = "{", close = "}" },
                    { open = "<", close = ">" },
                },
                ignore_beginning = true, -- Don't tabout if cursor is at the start of the line
                exclude = {},            -- Filetypes to ignore
            })
        end,
    },
}
