if vim.g.neovide then
	-- vim.o.guifont = "MonaspiceKr Nerd Font,D2Coding ligature:h14"

	vim.g.neovide_transparency = 0.8
	vim.g.neovide_window_blurred = true
	vim.g.neovide_floating_blur_amount_x = 2.0
	vim.g.neovide_floating_blur_amount_y = 2.0
	vim.g.neovide_input_macos_option_key_is_meta = "only_left"

	vim.g.neovide_remember_window_size = true
	vim.g.neovide_fullscreen = true

	vim.g.neovide_cursor_vfx_mode = "railgun"

	-- Normal mode yank to system clipboard
	vim.api.nvim_set_keymap("n", "<D-c>", '"+y', { noremap = true, silent = true })

	-- Visual mode yank to system clipboard
	vim.api.nvim_set_keymap("v", "<D-c>", '"+y', { noremap = true, silent = true })

	-- Normal mode paste from system clipboard
	vim.api.nvim_set_keymap("n", "<D-v>", '"+p', { noremap = true, silent = true })

	-- Insert mode paste from system clipboard
	vim.api.nvim_set_keymap("i", "<D-v>", "<C-r>+", { noremap = true, silent = true })

	-- Command-line mode paste from system clipboard
	vim.api.nvim_set_keymap("c", "<D-v>", "<C-r>+", { noremap = true, silent = true })
end
