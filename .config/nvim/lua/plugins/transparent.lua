return {
	"xiyaowong/transparent.nvim",
	enabled = false,
	priority = 1000,
	init = function()
		require("transparent").clear_prefix("BufferLine")
		require("transparent").clear_prefix("NvimTree")
		require("transparent").clear_prefix("notify")
	end,
	-- opts = {
	-- 	exclude_groups = {
	-- 		"CursorLine",
	-- 	},
	-- },
}
