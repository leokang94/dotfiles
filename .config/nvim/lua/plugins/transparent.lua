return {
	"xiyaowong/transparent.nvim",
	priority = 1000,
	init = function()
		require("transparent").clear_prefix("BufferLine")
		require("transparent").clear_prefix("NeoTree")
		require("transparent").clear_prefix("NvimTree")
		require("transparent").clear_prefix("notify")
	end,
	config = function()
		require("transparent").setup({
			exclude_groups = {
				"CursorLine",
			},
		})
	end,
}
