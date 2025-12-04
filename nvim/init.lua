vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('core.lazy')
require('core.options')
require('core.keymaps')

-- not writing in Perl at the moment.
vim.g.loaded_perl_provider = 0

-- Python Virtual Environment Executable
vim.g.python3_host_prog = vim.fn.stdpath("config") .. "/python-venv/bin/python"
