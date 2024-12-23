return {
	"stevearc/oil.nvim",
	opts = {
		default_file_explorer = true,
		columns = { "icon", "size" },
		watch_for_chagnes = true,
		view_options = {
			show_hidden = true,
		},
	},
	keys = {
		{ "<leader>o", ":Oil<CR>", desc = "Open File Explorer" },
	},
}
