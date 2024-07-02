return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"DaikyXendo/nvim-material-icon",
		-- "nvim-tree/nvim-web-devicons",
	},
	opts = {
		sections = {
			lualine_c = { "filename", "filetype" },
		},
	},
}
