return {
	"svampkorg/moody.nvim",
	event = { "ModeChanged", "BufWinEnter", "WinEnter" },
	dependencies = {
		"binhtran432k/dracula.nvim",
	},
	opts = {
		blends = { visual = 0.5 },
		-- colors = {
		-- 	normal = "#00BFFF",
		-- 	insert = "#70CF67",
		-- 	visual = "#AD6FF7",
		-- 	command = "#EB788B",
		-- 	operator = "#FF8F40",
		-- 	replace = "#E66767",
		-- 	select = "#AD6FF7",
		-- 	terminal = "#4CD4BD",
		-- 	terminal_n = "#00BBCC",
		-- },
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
		extend_to_linenr = true,
		extend_to_linenr_visual = true,
	},
}
