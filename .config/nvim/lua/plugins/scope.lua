return {
	"tiagovla/scope.nvim",
	config = function()
		require("scope").setup({
			hooks = {
				pre_tab_enter = function()
					vim.notify("Tab Changed!")
				end,
			},
		})
	end,
}
