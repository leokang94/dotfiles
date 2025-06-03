return {
	"tadaa/vimade",
	opts = {
		recipe = {
			"default",
			{ animate = true },
		},

		ncmode = "buffers",

		blocklist = {
			custom = {
				highlights = {
					"WinSeparator",
					"EndOfBuffer",
					"WinBar",
					"WinBarNC",
				},
				buf_opts = {
					buftype = {
						"terminal",
						"trouble",
					},
				},
			},
		},
	},
}
