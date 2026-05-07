return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		local ensure_installed = {
			-- LSP servers
			"pyright",
			"eslint",
			"html",
			"cssls",
			"tailwindcss",
			"jsonls",
			"yamlls",
			"lua_ls",
			"bashls",
			"gopls",
			"rust_analyzer",
			"intelephense",
			"ts_ls",
			"sqlls",
			"djlsp",
			"marksman",
			"texlab",

			-- Formatters
			"prettier",
			"stylua",
			"isort",
			"black",
			"clang-format",
			"google-java-format",
			"shfmt",
			"sql-formatter",
			"djlint",
			"php-cs-fixer",

			-- Linters
			"flake8",
			"shellcheck",
			"sqlfluff",
			"cpplint",

			-- Go
			"goimports",
			"gofumpt",
		}

		if vim.fn.executable("clangd") == 0 then
			table.insert(ensure_installed, "clangd")
		end

		require("mason-tool-installer").setup({
			ensure_installed = ensure_installed,
			auto_update = false,
			run_on_start = false,
		})
	end,
}
