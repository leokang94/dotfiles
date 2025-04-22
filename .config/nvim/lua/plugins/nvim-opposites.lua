local javascript_opposites = {
	["==="] = "!==",
	["!=="] = "===",
	["=="] = "!=",
	["!="] = "==",
	[">"] = "<",
	["<"] = ">",
	[">="] = "<=",
	["<="] = ">=",
	["&"] = "|",
	["|"] = "&",
	["&&"] = "||",
	["||"] = "&&",
	["&&="] = "||=",
	["||="] = "&&=",
	["+"] = "-",
	["-"] = "+",
	["++"] = "--",
	["--"] = "++",
	["+="] = "-=",
	["-="] = "+=",
	["*="] = "/=",
	["/="] = "*=",
	["*"] = "/",
	["/"] = "*",
}

return {
	"tigion/nvim-opposites",
	-- event = { 'BufReadPost', 'BufNewFile' },
	keys = {
		{
			"<Leader>i",
			function()
				require("opposites").switch()
			end,
			desc = "Switch to opposite word",
		},
	},
	---@type opposites.Config
	opts = {
		opposites_by_ft = {
			["typescript"] = javascript_opposites,
			["typescriptreact"] = javascript_opposites,
			["javascript"] = javascript_opposites,
			["javascriptreact"] = javascript_opposites,
		},
	},
}
