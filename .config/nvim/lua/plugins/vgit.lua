return {
	"tanvirtin/vgit.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
	-- Lazy loading on 'VimEnter' event is necessary.
	event = "VimEnter",
	keys = {
		{
			"[h",
			function()
				require("vgit").hunk_up()
			end,
			desc = "Previous Hunk",
		},
		{
			"]h",
			function()
				require("vgit").hunk_down()
			end,
			desc = "Next Hunk",
		},
		{
			"<leader>ghs",
			function()
				require("vgit").buffer_hunk_stage()
			end,
			desc = "Stage Hunk",
		},
		{
			"<leader>ghr",
			function()
				require("vgit").buffer_hunk_reset()
			end,
			desc = "Reset Hunk",
		},
		{
			"<leader>gbs",
			function()
				require("vgit").buffer_stage()
			end,
			desc = "Stage Buffer",
		},
		{
			"<leader>gbu",
			function()
				require("vgit").buffer_unstage()
			end,
			desc = "Unstage Buffer",
		},
		{
			"<leader>gbr",
			function()
				require("vgit").buffer_reset()
			end,
			desc = "Reset Buffer",
		},
		{
			"<leader>ghp",
			function()
				require("vgit").buffer_hunk_preview()
			end,
			desc = "Preview Hunk",
		},
		{
			"<leader>gbp",
			function()
				require("vgit").buffer_blame_preview()
			end,
			desc = "Preview Blame",
		},
		{
			"<leader>gdp",
			function()
				require("vgit").buffer_diff_preview()
			end,
			desc = "Preview Buffer Diff",
		},
	},
	opts = {},
}
