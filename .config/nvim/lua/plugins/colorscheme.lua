return {
	{
		"binhtran432k/dracula.nvim",
		lazy = false,
		priority = 1000,

		config = function()
			vim.g.dracula_colorterm = 0

			local util = require("dracula.util")

			---@diagnostic disable-next-line: missing-fields
			require("dracula").setup({
				transparent = true,
				dim_inactive = true,
				lualine_bold = true,
				on_colors = function(colors)
					vim.g.color = colors

					vim.api.nvim_set_hl(0, "LineNrAbove", { fg = colors.comment, bold = true })
					vim.api.nvim_set_hl(0, "LineNrBelow", { fg = colors.comment, bold = true })
					vim.api.nvim_set_hl(0, "WinSeparator", { fg = colors.bright_blue, bold = true })
					vim.api.nvim_set_hl(0, "Cursor", { bg = colors.purple })
					vim.api.nvim_set_hl(0, "lCursor", { bg = colors.purple })
					vim.api.nvim_set_hl(0, "CursorIM", { bg = colors.purple })

					vim.api.nvim_set_hl(0, "DiffDelete", { bg = util.blend_bg(colors.diff.delete, 0.7) })
					vim.api.nvim_set_hl(0, "DiffAdd", { bg = util.blend_bg(colors.diff.add, 0.7) })
					vim.api.nvim_set_hl(0, "DiffChange", { bg = util.blend_bg(colors.diff.change, 0.7) })
					vim.api.nvim_set_hl(0, "DiffText", { bg = util.blend_bg(colors.pink, 0.4) })

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
