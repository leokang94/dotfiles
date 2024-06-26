return {
	"folke/edgy.nvim",
	event = "VeryLazy",
	init = function()
		vim.opt.laststatus = 3
		vim.opt.splitkeep = "screen"
	end,
	opts = {
		options = {
			right = { size = 40 },
		},
		right = {
			{
				title = "NvimTree",
				ft = "NvimTree",
				pinned = true,
				open = "NvimTreeOpen",
			},
		},
		animate = {
			enabled = false,
		},
	},
}
