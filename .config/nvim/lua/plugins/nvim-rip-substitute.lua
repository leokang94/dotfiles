return {
	"chrisgrieser/nvim-rip-substitute",
	cmd = "RipSubstitute",
	keys = {
		{
			"<leader>rn",
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
