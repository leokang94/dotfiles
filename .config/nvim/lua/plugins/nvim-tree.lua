return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"DaikyXendo/nvim-material-icon",
		-- "nvim-tree/nvim-web-devicons",
	},
	config = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		require("nvim-tree").setup({
			hijack_cursor = true,
			sync_root_with_cwd = true,
			respect_buf_cwd = true,
			view = { side = "right" },
			sort = {
				sorter = "case_sensitive",
			},
			renderer = {
				group_empty = true,
			},
			filters = {
				exclude = {
					"dist",
					"build",
					"node_modules",
				},
			},
			update_focused_file = {
				enable = true,
			},
		})
	end,
}
