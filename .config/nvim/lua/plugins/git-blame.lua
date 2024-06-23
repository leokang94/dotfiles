return {
	"f-person/git-blame.nvim",
	config = function()
		require("gitblame").setup({})

		vim.g.gitblame_date_format = "%Y-%m-%d %H:%M"
		vim.g.gitblame_schedule_event = "CursorHold"
		vim.g.gitblame_clear_event = "CursorHoldI"
	end,
}
