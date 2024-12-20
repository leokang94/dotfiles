return {
	{
		"nvim-treesitter/nvim-treesitter",
		config = function(_, opts)
			vim.filetype.add({
				-- Detect and apply filetypes based on certain patterns of the filenames
				pattern = {
					-- INFO: Match filenames like - ".env.example", ".env.local" and so on
					["%.env%.[%w_.-]+"] = "sh",
				},
			})

			if type(opts.ensure_installed) == "table" then
				opts.ensure_installed = LazyVim.dedup(opts.ensure_installed)
			end
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {},
		config = function()
			require("treesitter-context").setup({
				separator = "",
			})

			local colorUtils = require("dracula.util")
			local colors = vim.g.color
			local bgColor = colorUtils.blend_bg(colors.bright_blue, 0.2)

			vim.api.nvim_set_hl(0, "TreesitterContext", { bg = bgColor })
			vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { bg = bgColor, fg = colors.comment, bold = true })
			vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = colors.bright_blue })
		end,
	},
	{
		"davidmh/mdx.nvim",
		config = true,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{
		"chrisgrieser/nvim-various-textobjs",
		lazy = false,
		opts = { keymaps = { useDefaults = true } },
	},
}
