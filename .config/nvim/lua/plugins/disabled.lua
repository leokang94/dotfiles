return {
	-- { "nvim-neo-tree/neo-tree.nvim", enabled = false },
	{
		"nvim-neo-tree/neo-tree.nvim",
		enabled = false,
		-- keys = {"<leader>e", },
		opts = {
			window = {
				position = "right",
			},
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignore = false,
					hide_hiddden = false,
					hide_by_name = {},
				},
			},
		},
	},
}
