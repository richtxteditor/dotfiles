-- Not writing in Perl at the moment.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Prefer an explicitly configured Python host, but do not point Neovim at a
-- Mason package that may not exist yet. A missing g:python3_host_prog causes
-- :checkhealth provider errors and can break Python-backed plugins.
local python_candidates = {
	vim.env.NVIM_PYTHON3_HOST_PROG,
	vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
	vim.fn.exepath("python3"),
}

local function supports_pynvim(python)
	if not python or python == "" or vim.fn.executable(python) ~= 1 then
		return false
	end

	vim.fn.system({ python, "-c", "import pynvim" })
	return vim.v.shell_error == 0
end

for _, python in ipairs(python_candidates) do
	if supports_pynvim(python) then
		vim.g.python3_host_prog = python
		break
	end
end

if not vim.g.python3_host_prog then
	vim.g.loaded_python3_provider = 0
end
