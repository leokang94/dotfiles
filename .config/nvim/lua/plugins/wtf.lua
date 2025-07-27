local is_vsplit = require("utils.screen").is_vsplit

return {
	"piersolenski/wtf.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	opts = {
		popup_type = "horizontal",
		provider = "anthropic",
		providers = {
			anthropic = {
				-- Your preferred model
				model_id = "claude-sonnet-4-20250514",
			},
		},
		language = "korean",
	},
	keys = {
		{
			"<leader>wa",
			mode = { "n", "x" },
			function()
				local wtf_config = require("wtf.config")
				wtf_config.options.popup_type = is_vsplit() and "vertical" or "horizontal"

				require("wtf").ai()
			end,
			desc = "[WTF] Debug diagnostic with AI",
		},
		{
			"<leader>wf",
			mode = { "n", "x" },
			function()
				require("wtf").fix()
			end,
			desc = "[WTF] Fix diagnostic with AI",
		},
		{
			"<leader>wp",
			mode = { "n", "x" },
			function()
				require("wtf").search()
			end,
			desc = "[WTF] Search diagnostic with Perplexity",
		},
		{
			mode = { "n" },
			"<leader>wh",
			function()
				require("wtf").history()
			end,
			desc = "[WTF] Populate the quickfix list with previous chat history",
		},
	},
}
