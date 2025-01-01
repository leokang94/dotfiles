local function getCWD()
	return string.match(vim.fn.getcwd(), [[/([^/]+)$]])
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"DaikyXendo/nvim-material-icon",
		{ "justinhj/battery.nvim", config = true },
		-- "nvim-tree/nvim-web-devicons",
	},
	opts = {
		tabline = {
			lualine_a = {
				getCWD,
			},
			lualine_b = { "branch" },
			lualine_c = { "filename" },
			lualine_x = {},
			lualine_y = {},
			lualine_z = { "tabs" },
		},
		sections = {
			lualine_b = {
				getCWD,
				"branch",
			},
			lualine_c = { "filename", "filetype" },
			lualine_y = {
				"searchcount",
				{ "progress", separator = " ", padding = { left = 1, right = 0 } },
				{ "location", padding = { left = 0, right = 1 } },
				function()
					return require("battery").get_status_line()
				end,
			},
		},
	},
}
