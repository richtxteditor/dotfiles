return {
	"dmtrKovalenko/fff.nvim",
	build = "cargo build --release -p fff-nvim",
	opts = {
		debug = {
			enabled = false,
			show_scores = false,
		},
	},
	lazy = true,
	cmd = {
		"FFFFind",
		"FFFScan",
		"FFFRefreshGit",
		"FFFClearCache",
		"FFFHealth",
		"FFFDebug",
		"FFFOpenLog",
	},
	keys = {
		{
			"<leader>ff",
			function()
				require("fff").find_files()
			end,
			desc = "Find files",
		},
		{
			"<leader>fg",
			function()
				require("fff").live_grep()
			end,
			desc = "Live grep",
		},
		{
			"<leader>fz",
			function()
				require("fff").live_grep({
					grep = {
						modes = { "fuzzy", "plain" },
					},
				})
			end,
			desc = "Fuzzy grep",
		},
		{
			"<leader>fc",
			function()
				require("fff").live_grep({ query = vim.fn.expand("<cword>") })
			end,
			desc = "Search current word",
		},
	},
}
