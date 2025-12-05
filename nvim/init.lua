vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('core.lazy')
require('core.options')
require('core.keymaps')

-- not writing in Perl at the moment.
vim.g.loaded_perl_provider = 0

-- Set Python 3 host to the Mason-managed debugpy environment
-- This prevents Neovim from relying on your local pyenv version
vim.g.python3_host_prog = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
