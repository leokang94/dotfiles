return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"DaikyXendo/nvim-material-icon",
		-- "nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("lualine").setup({
			options = {
				theme = "dracula",
			},
		})
	end,
}
