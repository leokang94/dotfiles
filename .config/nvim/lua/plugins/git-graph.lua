return {
	name = "git-graph",
	dir = vim.fn.stdpath("config") .. "/lua/config/my/git-graph",
	lazy = false,
	keys = {
		{
			"<leader>gt",
			function()
				require("config.my.git-graph").open_git_graph()
			end,
			desc = "git-graph",
		},
	},
	config = function()
		require("config.my.git-graph").setup()
	end,
}
