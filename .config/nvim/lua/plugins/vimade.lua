return {
	"tadaa/vimade",
	opts = {
		fadelevel = 0.6,
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
					},
					filetype = {
						"trouble",
					},
				},
			},
		},

		link = {
			custom = function(win, active)
				local link_filetype_list = { "rip-substitute" }

				for _, filetype in ipairs(link_filetype_list) do
					if active.buf_opts.filetype == filetype then
						return true
					end
				end

				return false
			end,
		},
	},
}
