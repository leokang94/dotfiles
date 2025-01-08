return {
	"shellRaining/hlchunk.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local util = require("dracula.util")

		local function get_blank_bg_color(color)
			return util.blend_bg(color, 0.115)
		end

		require("hlchunk").setup({
			chunk = {
				enable = true,
				delay = 100,
				style = { { fg = vim.g.color.purple, bold = true } },
				chars = {
					horizontal_line = "─",
					vertical_line = "│",
					left_top = "┌",
					left_bottom = "└",
					right_arrow = "─",
				},
			},
			indent = {
				enable = true,
				chars = {
					"│",
					"¦",
					"┆",
					"┊",
				},
			},
			-- blank = {
			-- 	enable = true,
			-- 	chars = {
			-- 		" ",
			-- 	},
			-- 	style = {
			-- 		{ bg = get_blank_bg_color(vim.g.color.green) },
			-- 		{ bg = get_blank_bg_color(vim.g.color.yellow) },
			-- 		{ bg = get_blank_bg_color(vim.g.color.pink) },
			-- 		{ bg = get_blank_bg_color(vim.g.color.white) },
			-- 	},
			-- },
		})
	end,
}
