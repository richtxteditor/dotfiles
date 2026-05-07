-- lua/plugins/formatter.lua

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" }, -- Run formatter before saving
	cmd = { "ConformInfo" },
	config = function()
		local function project_root(filename)
			return vim.fs.root(filename, { ".venv", "venv", "pyproject.toml", "setup.py", "setup.cfg", ".git" })
		end

		local function local_python_tool(tool)
			return function(_, ctx)
				local root = project_root(ctx.filename)
				if root then
					for _, venv in ipairs({ ".venv", "venv" }) do
						local candidate = root .. "/" .. venv .. "/bin/" .. tool
						if vim.fn.executable(candidate) == 1 then
							return candidate
						end
					end
				end

				return tool
			end
		end

		require("conform").setup({
			-- Configure formatters for different file types
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				php = { "php_cs_fixer" },
				typescriptreact = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				markdown = { "prettier" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				java = { "google_java_format" },
				ruby = { "rubocop" },
				go = { "goimports", "gofumpt" },
				sql = { "sql_formatter" },
				htmldjango = { "djlint" },
			},
			formatters = {
				black = {
					command = local_python_tool("black"),
				},
				isort = {
					command = local_python_tool("isort"),
				},
				rubocop = {
					condition = function()
						return vim.fn.executable("rubocop") == 1
					end,
				},
			},
			-- Optional: Run formatter automatically on save
			format_on_save = {
				timeout_ms = 2000,
				lsp_format = "fallback",
			},
		})
	end,
}
