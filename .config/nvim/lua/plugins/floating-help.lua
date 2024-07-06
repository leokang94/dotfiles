local cmd_abbrev = require("utils.keyMapper").cmd_abbrev

return {
	"Tyler-Barham/floating-help.nvim",
	config = function()
		require("floating-help").setup()

		cmd_abbrev("h", "FloatingHelp")
		cmd_abbrev("help", "FloatingHelp")
		cmd_abbrev("helpc", "FloatingHelpClose")
		cmd_abbrev("helpclose", "FloatingHelpClose")
	end,
}
