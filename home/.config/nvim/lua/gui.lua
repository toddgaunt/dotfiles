-- This file is for configuring Neovide, a nice GUI for neovim written in Rust
local M = {}

function M.setup()
	if vim.g.neovide == nil then
		return
	end

	vim.o.guifont = "GoMono Nerd Font:h12"
	vim.g.neovide_remember_window_size = true
	vim.g.neovide_scroll_animation_length = 0.0
	--vim.g.neovide_cursor_vfx_mode = "railgun"
end

return M
