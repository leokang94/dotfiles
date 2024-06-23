return {
	"pmizio/typescript-tools.nvim",
	-- enabled = false,
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	opts = {},
	ft = {
		"javascriptreact",
		"typescriptreact",
		"javascript.jsx",
		"typescript.tsx",
		"javascript",
		"typescript",
	},
	config = function()
		require("typescript-tools").setup({
			settings = {
				tsserver_file_preferences = {
					includeInlayParameterNameHints = "all",
					includeCompletionsForModuleExports = true,
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayVariableTypeHintsWhenTypeMatchesName = false,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
				tsserver_plugins = {
					-- for Typescript v4.9+
					"@styled/typescript-styled-plugin",
					-- for older Typescript versions
					"typescript-styled-plugin",
				},

				include_completions_with_insert_text = true,
				jsx_close_tag = {
					enable = true,
					filetypes = { "javascriptreact", "typescriptreact" },
				},
			},
		})
	end,
}
