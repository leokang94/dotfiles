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
				end,

				on_highlights = function(hl, c)
					hl.LineNrAbove = { fg = c.comment, bold = true }
					hl.LineNrBelow = { fg = c.comment, bold = true }
					hl.WinSeparator = { fg = c.bright_blue, bold = true }
					hl.Cursor = { bg = c.purple }
					hl.lCursor = { bg = c.purple }
					hl.CursorIM = { bg = c.purple }

					hl.DiffDelete = { bg = util.blend_bg(c.diff.delete, 0.2) }
					hl.DiffAdd = { bg = util.blend_bg(c.diff.add, 0.3) }
					hl.DiffChange = { bg = util.blend_bg(c.diff.change, 0.2) }
					hl.DiffText = { bg = util.blend_bg(c.diff.change, 0.8) }
					hl.DiffAddAsDelete = { bg = util.blend_bg(c.diff.delete, 0.2) }
					hl.DiffviewDiffAddAsDelete = { bg = util.blend_bg(c.diff.delete, 0.2) }
					hl.DiffviewDiffDelete = { bg = "none", fg = util.blend_fg(c.black, 0.8) }
					hl.DiffDeleteText = { bg = util.blend_bg(c.diff.delete, 0.7) }
					-- hl.DiffDeleteText = { bg = c.diff.delete }
					hl.DiffAddText = { bg = util.blend_bg(c.diff.add, 0.9) }
					-- hl.DiffAddText = { bg = c.diff.add }

					local types = { "Error", "Warn", "Info", "Hint" }
					for _, type in pairs(types) do
						local virtual_text_hl = "DiagnosticVirtualText" .. type
						local virtual_text_new_values =
							vim.tbl_extend("force", vim.api.nvim_get_hl(0, { name = virtual_text_hl }), { bg = "NONE" })

						hl[virtual_text_hl] = virtual_text_new_values
					end
				end,
			})

			vim.cmd([[colorscheme dracula]])
		end,
	},
}
