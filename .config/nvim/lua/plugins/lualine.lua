return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"DaikyXendo/nvim-material-icon",
		{ "justinhj/battery.nvim", config = true },
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
			lualine_y = {
				{ "progress", separator = " ", padding = { left = 1, right = 0 } },
				{ "location", padding = { left = 0, right = 1 } },
				function()
					return require("battery").get_status_line()
				end,
			},
		},
	},
}
