return {
	"akinsho/toggleterm.nvim",
	config = function()
		require("toggleterm").setup({})

		-- 터미널 방향을 동적으로 설정하는 함수
		local function determine_direction()
			local width = vim.api.nvim_win_get_width(0)
			if width > 200 then
				return "horizontal"
			else
				return "vertical"
			end
		end

		local Terminal = require("toggleterm.terminal").Terminal

		-- default
		local default_term = Terminal:new({
			hidden = true,
			direction = "horizontal",
			dir = "./",
			size = 20,
		})

		function _default_toggle()
			default_term:toggle()
		end

		vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>lua _default_toggle()<CR>", { noremap = true, silent = true })

		-- git
		local git_graph_term = Terminal:new({
			hidden = true,
			display_name = "git_command",
			direction = determine_direction(),
			dir = "./",
		})
		local git_term = Terminal:new({
			hidden = true,
			display_name = "git_command",
			direction = "tab",
			dir = "./",
		})

		function _git_toggle()
			git_graph_term.direction = determine_direction()

			git_term:toggle()
			git_graph_term:toggle()
		end

		vim.api.nvim_set_keymap("n", "<leader>tg", "<cmd>lua _git_toggle()<CR>", { noremap = true, silent = true })
	end,
}
