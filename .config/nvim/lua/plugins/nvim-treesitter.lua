return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"glsl",
				"bash",
				"c",
				"css",
				"diff",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"toml",
				"typescript",
				"tsx",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
		},
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

			local TS = require("nvim-treesitter")

			TS.install(opts.ensure_installed)
		end,
	},
	{
		"MeanderingProgrammer/treesitter-modules.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		---@module 'treesitter-modules'
		---@type ts.mod.UserConfig
		opts = {},
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				separator = "",
				multiwindow = true,
				max_lines = 5,
				multiline_threshold = 5,
				trim_scope = "inner",
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
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{
		"chrisgrieser/nvim-various-textobjs",
		lazy = false,
		opts = { keymaps = { useDefaults = true } },
	},
}
