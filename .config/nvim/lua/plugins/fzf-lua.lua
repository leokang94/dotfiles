return {
	"ibhagwan/fzf-lua",
	opts = function(_, opts)
		local config = require("fzf-lua.config")
		local actions = require("fzf-lua.actions")
		config.defaults.actions.files["alt-t"] = actions.file_tabedit
		config.defaults.actions.files["alt-\\"] = actions.file_vsplit
		config.defaults.actions.files["alt--"] = actions.file_split

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
