return {
	"folke/trouble.nvim",
	dependencies = {
		"DaikyXendo/nvim-material-icon",
		-- "nvim-tree/nvim-web-devicons",
	},
	cmd = "Trouble",
	keys = {
		{
			"<leader>xx",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics (Trouble)",
		},
		{
			"<leader>xX",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Buffer Diagnostics (Trouble)",
		},
		{
			"<leader>xe",
			"<cmd>Trouble diagnostics_only_error_with_float_preview toggle<CR>",
			desc = "Diagnostics (Trouble)",
		},

		{
			"<leader>cs",
			"<cmd>Trouble symbols toggle focus=false<cr>",
			desc = "Symbols (Trouble)",
		},
		{
			"<leader>cl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP Definitions / references / ... (Trouble)",
		},
		{
			"<leader>xL",
			"<cmd>Trouble loclist toggle<cr>",
			desc = "Location List (Trouble)",
		},
		{
			"<leader>xQ",
			"<cmd>Trouble qflist toggle<cr>",
			desc = "Quickfix List (Trouble)",
		},
	},
	opts = {
		modes = {
			diagnostics_only_error_with_float_preview = {
				mode = "diagnostics",
				focus = true,
				preview = {
					type = "float",
					relative = "editor",
					border = "rounded",
					title = "Preview",
					title_pos = "center",
					size = { width = 0.8, height = 0.8 },
					zindex = 200,
				},
				filter = {
					any = {
						{
							severity = vim.diagnostic.severity.ERROR, -- errors only
							-- limit to files in the current project
							-- function(item)
							-- 	return item.filename:find((vim.loop or vim.uv).cwd(), 1, true)
							-- end,
						},
					},
				},
			},
		},
	}, -- for default options, refer to the configuration section for custom setup.
}
