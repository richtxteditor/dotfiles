-- Not writing in Perl at the moment.
vim.g.loaded_perl_provider = 0

-- Use the Mason-managed debugpy Python for provider stability.
vim.g.python3_host_prog = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
