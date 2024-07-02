return {
	"chrisgrieser/nvim-rip-substitute",
	-- keys = {
	-- 	{
	-- 		"<leader>rn",
	-- 		function()
	-- 			return ":IncRename " .. vim.fn.expand("<cword>")
	-- 		end,
	-- 		mode = { "n" },
	-- 		desc = " IncRename",
	-- 	},
	--
	-- 	{
	-- 		"<leader>rn",
	-- 		function()
	-- 			require("rip-substitute").sub()
	-- 		end,
	-- 		mode = { "x" },
	-- 		desc = " rip substitute",
	-- 	},
	-- },
	opts = {
		popupWin = {
			position = "top",
		},
	},
}
