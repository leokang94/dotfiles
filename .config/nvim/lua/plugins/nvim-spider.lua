return {
	"chrisgrieser/nvim-spider",
	lazy = true,
	keys = {
		{
			mode = { "n", "o", "x" },
			"w",
			"<cmd>lua require('spider').motion('w')<CR>",
			desc = "Spider-w",
		},
		{
			mode = { "n", "o", "x" },
			"e",
			"<cmd>lua require('spider').motion('e')<CR>",
			desc = "Spider-e",
		},
		{
			mode = { "n", "o", "x" },
			"b",
			"<cmd>lua require('spider').motion('b')<CR>",
			desc = "Spider-b",
		},
	},
}
