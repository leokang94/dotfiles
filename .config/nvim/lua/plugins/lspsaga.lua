return {
	"nvimdev/lspsaga.nvim",
	config = function()
		require("lspsaga").setup({})
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- optional
	},
}
