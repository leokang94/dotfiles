require("config.globals")
require("config.keymaps")
require("config.options")

require("core.lsp")

-- my custom plugins(?)
require("config.my.git-tab")

require("config.lazy")

vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = { "*.tsx", "*.ts", "*.jsx", "*.js", "*.html", "*.css" },
	callback = function()
		vim.treesitter.start()
	end,
})
