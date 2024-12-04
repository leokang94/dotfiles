return {
	"rmagatti/gx-extended.nvim",
	keys = { "gx" },
	opts = {
		open_fn = require("lazy.util").open,
		extensions = {
			-- for lazy.nvim plugin
			{
				patterns = { "*/plugins/*.lua", "*/plugins/**/*.lua" },
				name = "neovim plugins",
				match_to_url = function(line_string)
					local line = string.match(line_string, "[\"|'].*/.*[\"|']")
					local repo = vim.split(line, ":")[1]:gsub("[\"|']", "")

					local url = "https://github.com/" .. repo
					return line and repo and url or nil
				end,
			},
			-- for npm package
			{
				patterns = { "*.ts", "*.tsx" },
				name = "npm packages",
				match_to_url = function(line_string)
					local pattern = "import.+from.+['\"](.+)['\"]"
					local package = string.match(line_string, pattern)

					local url = "https://www.npmjs.com/package/" .. package
					return package and url or nil
				end,
			},
		},
	},
}
