return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"DaikyXendo/nvim-material-icon",
		-- "nvim-tree/nvim-web-devicons",
	},
	opts = {
		sections = {
			lualine_b = {
				function()
					return string.match(vim.fn.getcwd(), [[/([^/]+)$]])
				end,
				"branch",
			},
			lualine_c = { "filename", "filetype" },
		},
	},
}
