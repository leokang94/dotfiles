return {
	"folke/edgy.nvim",
	event = "VeryLazy",
	init = function()
		vim.opt.laststatus = 3
		vim.opt.splitkeep = "screen"
	end,
	opts = {
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
