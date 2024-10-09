if vim.g.neovide then
	-- font size change dynamically at runtime.
	local scale_unit = 1.1
	local change_scale_factor = function(delta)
		vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
	end
	vim.keymap.set("n", "<C-=>", function()
		change_scale_factor(scale_unit)
	end)
	vim.keymap.set("n", "<C-->", function()
		change_scale_factor(1 / scale_unit)
	end)

	vim.g.neovide_input_ime = true

	-- transparency
	-- Helper function for transparency formatting
	-- local alpha = function()
	-- 	return string.format("%x", math.floor(255 * vim.g.neovide_transparency_point or 0.8))
	-- end
	-- Set transparency and background color (title bar color)
	vim.g.neovide_transparency = 0.9
	-- vim.g.neovide_transparency_point = 0.8
	-- vim.g.neovide_background_color = vim.g.color.bg .. alpha()
	-- Add keybinds to change transparency
	local change_transparency = function(delta)
		vim.g.neovide_transparency = vim.g.neovide_transparency + delta
		-- vim.g.neovide_background_color = vim.g.color.bg .. alpha()
	end
	vim.keymap.set({ "n", "v", "o" }, "<D-]>", function()
		change_transparency(0.01)
	end)
	vim.keymap.set({ "n", "v", "o" }, "<D-[>", function()
		change_transparency(-0.01)
	end)

	vim.g.neovide_underline_stroke_scale = 1.2

	-- vim.g.neovide_transparency = 0.8
	-- vim.g.neovide_window_blurred = true
	vim.g.neovide_input_macos_option_key_is_meta = "only_left"

	vim.g.neovide_remember_window_size = true

	vim.g.neovide_cursor_vfx_mode = "railgun"

	vim.g.neovide_refresh_rate = 120
	vim.g.neovide_detach_on_quit = "always_quit"
	vim.g.neovide_cursor_antialiasing = true

	-- keymapping
	vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
	vim.keymap.set("v", "<D-c>", '"+y') -- Copy
	vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
	vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
	vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
	vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode

	-- Allow clipboard copy paste in neovim
	vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
end
