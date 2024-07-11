return {
	"folke/persistence.nvim",
	-- enabled = false,
	event = "BufReadPre", -- this will only start session saving when an actual file was opened
	opts = {
		options = vim.opt.sessionoptions:get(),
	},
}
