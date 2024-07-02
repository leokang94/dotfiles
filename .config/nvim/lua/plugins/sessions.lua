return {
	"natecraddock/sessions.nvim",
	config = function()
		require("sessions").setup({
			events = { "VimLeavePre", "WinEnter" },
			session_filepath = vim.fn.stdpath("data") .. "/sessions",
			absolute = true,
		})
	end,
}
