-- ~/.config/nvim/init.lua
--
-- This is the main entry point for the Neovim configuration.
-- Its only role is to load the other configuration modules in the correct order.
-- All detailed settings are located in the `lua/` directory.

-- Set leader key (MUST be done before loading other modules that use it)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim (plugin manager)
-- This line finds, installs (if necessary), and initializes the plugin manager.
require('core.lazy')

-- Load core editor options
-- This loads all the 'vim.opt' settings from lua/core/options.lua.
require('core.options')

-- Load custom key mappings
-- This loads all custom shortcuts from lua/core/keymaps.lua.
require('core.keymaps')

-- not writing in Perl at the moment.
vim.g.loaded_perl_provider = 0

-- Python Virtual Environment Executable
vim.g.python3_host_prog = vim.fn.stdpath("config") .. "/python-venv/bin/python"