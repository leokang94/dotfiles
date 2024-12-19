return {
	"ibhagwan/fzf-lua",
	opts = function(_, opts)
		local config = require("fzf-lua.config")
		local actions = require("fzf-lua.actions")
		config.defaults.actions.files["alt-t"] = actions.file_tabedit
		config.defaults.actions.files["alt-\\"] = actions.file_vsplit
		config.defaults.actions.files["alt--"] = actions.file_split
	end,
	keys = {
		{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
	},
}
