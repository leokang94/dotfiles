local is_vsplit = require("utils.screen").is_vsplit

return {
	"piersolenski/wtf.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		popup_type = "horizontal",
		openai_api_key = vim.env.OPENAI_API_KEY,
		openai_model_id = "gpt-4o",
		language = "korean",
		search_engine = "perplexity",
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
