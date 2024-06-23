return {
	"piersolenski/wtf.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		popup_type = "popup",
		openai_api_key = "sk-proj-rbwFc4mi8vfbonKdgeq3T3BlbkFJL9P3AzWSzdny3JttFF0D",
		openai_model_id = "gpt-4o",
		language = "korean",
	},
	keys = {
		{
			"gw",
			mode = { "n", "x" },
			function()
				require("wtf").ai()
			end,
			desc = "Debug diagnostic with AI",
		},
		{
			mode = { "n" },
			"gW",
			function()
				require("wtf").search()
			end,
			desc = "Search diagnostic with Google",
		},
	},
}
