return {
	"ibhagwan/fzf-lua",
	opts = function(_, opts)
		opts.winopts = {
			width = 0.9,
			height = 0.8,
			preview = {
				layout = "flex",
				flip_columns = 150,
				wrap = "wrap",
			},
		}

		opts.lsp = {
			code_actions = {
				previewer = "codeaction_native",
				preview_pager = "delta --side-by-side --width=$FZF_PREVIEW_COLUMNS",
			},
		}

		return opts
	end,
	keys = {
		{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
	},
}
