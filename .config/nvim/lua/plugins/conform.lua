return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			yaml = { "yamlfmt" },
			json = { "prettier" },
			jsonc = { "prettier" },
		},
	},
}
