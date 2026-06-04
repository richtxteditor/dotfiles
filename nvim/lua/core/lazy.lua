-- lua/core/lazy.lua

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
	print("Installing lazy.nvim...")
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})

	if vim.v.shell_error ~= 0 or not uv.fs_stat(lazypath) then
		vim.api.nvim_err_writeln("Failed to install lazy.nvim. Check git/network access and restart Neovim.")
		return
	end
end
vim.opt.rtp:prepend(lazypath)

local ci_smoke_nvim = vim.env.DOTFILES_CI_SMOKE_NVIM == "1"

if ci_smoke_nvim then
	-- CI smoke validates startup without allowing Lazy to rewrite tracked pins.
	local ok, lock = pcall(require, "lazy.manage.lock")
	if ok then
		lock.update = function() end
	end
end

-- Setup lazy.nvim with your plugins
require("lazy").setup({
	-- Define your plugins as a list of specs.
	-- lazy.nvim will automatically load files from the `lua/plugins/` directory.
	{ import = "plugins" },
}, {
	install = { missing = not ci_smoke_nvim },
	ui = { border = "rounded" },
	checker = { enabled = not ci_smoke_nvim, notify = false },
	change_detection = { notify = false },
	rocks = { enabled = false },
})
