return {
	"rachartier/tiny-inline-diagnostic.nvim",
	enabled = false,
	event = "VeryLazy", -- Or `LspAttach`
	priority = 1000, -- needs to be loaded in first
	config = function()
		require("tiny-inline-diagnostic").setup({
			preset = "powerline",
			options = {
				multilines = true,
				format = function(diagnostic)
					return diagnostic.message .. " [" .. diagnostic.source .. "]"
				end,
				break_line = {
					enabled = true,
					after = 100,
				},
				overflow = { mode = "wrap" },
			},
		})
	end,
}
