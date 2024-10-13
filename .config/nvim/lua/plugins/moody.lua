return {
	"svampkorg/moody.nvim",
	event = { "ModeChanged", "BufWinEnter", "WinEnter" },
	dependencies = {
		"binhtran432k/dracula.nvim",
	},
	opts = {
		bold_nr = true,
		disabled_filetypes = { "TelescopePrompt" },
		recording = {
			enabled = true,
			icon = "󰑋",
			-- you can set some text to surround the recording registry char with
			-- or just set one to empty to maybe have just one letter, an arrow
			-- perhaps! For example recording to q, you could have! "󰑋    q" :D
			pre_registry_text = "[",
			post_registry_text = "]",
		},
	},
}
