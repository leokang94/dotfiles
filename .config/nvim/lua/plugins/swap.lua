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
	"tigion/swap.nvim",
	-- event = { 'BufReadPost', 'BufNewFile' },
	keys = {
		{
			"<Leader>i",
			function()
				require("swap").switch()
			end,
			desc = "Swap word",
		},
		-- { '<Leader>I', function() require('swap').opposites.switch() end, desc = 'Swap to opposite word' },
		-- { '<Leader>I', function() require('swap').chains.switch() end, desc = 'Swap to next word' },
		-- { '<Leader>I', function() require('swap').cases.switch() end, desc = 'Swap naming convention' },
		-- { '<Leader>I', function() require('swap').todos.switch() end, desc = 'Swap todo state' },
	},
	---@type swap.Config
	opts = {
		opposites = {
			words_by_ft = {
				["javascript"] = javascript_opposites,
				["typescript"] = javascript_opposites,
				["typescriptreact"] = javascript_opposites,
				["javascriptreact"] = javascript_opposites,
			},
		},
	},
}
