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
				tabkey = "<A-l>", -- Leave <Tab> to nvim-cmp/LuaSnip
				backwards_tabkey = "<A-h>", -- Leave <S-Tab> to nvim-cmp/LuaSnip
				act_as_tab = false,
				act_as_shift_tab = false,
				enable_backwards = true,
				completion = true, -- Use this if you use nvim-cmp
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
				exclude = {}, -- Filetypes to ignore
			})
		end,
	},
}
