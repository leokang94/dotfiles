---@type vim.lsp.Config
return {
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_markers = {
		".oxlintrc.json",
		"oxlint.json",
		"package.json",
	},
}
