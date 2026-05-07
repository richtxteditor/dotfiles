return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		local function project_root(filename)
			return vim.fs.root(filename, { ".venv", "venv", "pyproject.toml", "setup.py", "setup.cfg", ".git" })
		end

		local function local_python_tool(tool)
			return function()
				local filename = vim.api.nvim_buf_get_name(0)
				local root = project_root(filename)
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

		lint.linters_by_ft = {
			python = { "flake8" },
			sql = { "sqlfluff" },
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			htmldjango = { "djlint" },
			c = { "cpplint" },
			cpp = { "cpplint" },
		}

		lint.linters.flake8.cmd = local_python_tool("flake8")

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
