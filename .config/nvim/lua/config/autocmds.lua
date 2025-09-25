vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuOpen",
	callback = function()
		require("copilot.suggestion").dismiss()
		vim.b.copilot_suggestion_hidden = true
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuClose",
	callback = function()
		vim.b.copilot_suggestion_hidden = false
	end,
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	callback = function()
		vim.treesitter.start()
		vim.defer_fn(function()
			vim.cmd("TSContext enable")
		end, 100) -- 100ms 딜레이
	end,
})
