return {
	"petertriho/nvim-scrollbar",
	config = function()
		local color = vim.g.color

		require("scrollbar").setup({
			handle = {
				blend = 30,
				color = color.bright_blue,
			},
			marks = {
				Search = { color = color.orange },
				Error = { color = color.red },
				Warn = { color = color.yellow },
				Info = { color = color.green },
				Hint = { color = color.cyan },
				Misc = { color = color.purple },
			},
		})
	end,
}
