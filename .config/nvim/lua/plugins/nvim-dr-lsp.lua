return { -- lsp definitions & references count in the status line
	"chrisgrieser/nvim-dr-lsp",
	event = "LspAttach",
	config = function()
		vim.g.lualine_add("sections", "lualine_c", {
			require("dr-lsp").lspCount,
			fmt = function(str)
				-- return str:gsub("R", ""):gsub("D", " 󰄾"):gsub("LSP:", "󰈿")
				return str:gsub("LSP:", "󰈿")
			end,
		})
	end,
}
