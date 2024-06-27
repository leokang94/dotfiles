return {
	{
		"binhtran432k/dracula.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = true,
		},
		config = function()
			require("dracula").setup({
				on_colors = function(colors)
					vim.g.color = colors

					vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.bright_blue, bold = true })
					vim.api.nvim_set_hl(0, "LineNrAbove", { fg = colors.comment, bold = true })
					vim.api.nvim_set_hl(0, "LineNrBelow", { fg = colors.comment, bold = true })

					local types = { "Error", "Warn", "Info", "Hint" }
					for _, type in pairs(types) do
						local virtual_text_hl = "DiagnosticVirtualText" .. type
						local virtual_text_new_values =
							vim.tbl_extend("force", vim.api.nvim_get_hl(0, { name = virtual_text_hl }), { bg = "NONE" })

						vim.api.nvim_set_hl(0, virtual_text_hl, virtual_text_new_values)
					end
				end,
				on_highlights = function(highlight)
					vim.g.highlight = highlight
				end,
			})
		end,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "dracula",
		},
	},
}
