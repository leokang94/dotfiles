return {
	"chrisgrieser/nvim-rip-substitute",
	cmd = "RipSubstitute",
	keys = {
		{
			"<leader>rs",
			function()
				require("rip-substitute").sub()
			end,
			mode = { "n", "x" },
			desc = " rip substitute",
		},
	},
	opts = {
		popupWin = {
			position = "top",
		},
	},
}
