return {
	"akinsho/toggleterm.nvim",
	config = function()
		require("toggleterm").setup({
			open_mapping = [[<c-t>]],
			direction = "horizontal",
		})

		local Terminal = require("toggleterm.terminal").Terminal
		local git_graph = Terminal:new({
			hidden = true,
			display_name = "git_command",
			direction = "horizontal",
		})
		local git = Terminal:new({
			hidden = true,
			display_name = "git_command",
			direction = "tab",
		})

		function _git_toggle()
			git:toggle()
			git_graph:toggle()
		end

		vim.api.nvim_set_keymap("n", "<leader>tg", "<cmd>lua _git_toggle()<CR>", { noremap = true, silent = true })
	end,
}
