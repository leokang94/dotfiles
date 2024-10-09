return {
	"sindrets/diffview.nvim",
	init = function()
		vim.keymap.set("n", "<leader>do", ":DiffviewOpen<CR>", { desc = "Diffview open" })
		vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>", { desc = "Diffview close" })
		vim.keymap.set("n", "<leader>dh", ":DiffviewFileHistory", { desc = "Diffview File history" })
		vim.keymap.set(
			"n",
			"<leader>dl",
			":.DiffviewFileHistory --follow<CR>",
			{ desc = "File history for the current line" }
		)
		vim.keymap.set(
			"v",
			"<leader>dr",
			"<Esc>:'<,'>DiffviewFileHistory --follow<CR>",
			{ desc = "File history for the visual selection" }
		)
	end,
	opts = {
		view = {
			merge_tool = {
				layout = "diff3_mixed",
				disable_diagnostics = false,
				winbar_info = true,
			},
		},
	},
}
