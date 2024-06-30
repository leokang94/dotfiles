return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"DaikyXendo/nvim-material-icon",
		-- "nvim-tree/nvim-web-devicons",
	},
	init = function()
		-- reference: https://github.com/chrisgrieser/.config/blob/main/nvim/lua/plugins/lualine.lua
		---Adds a component to the lualine after lualine was already set up. Useful for
		---lazyloading. Accessed via `vim.g`, as this file's exports are used by lazy.nvim
		---@param whichBar "tabline"|"winbar"|"inactive_winbar"|"sections"
		---@param whichSection "lualine_a"|"lualine_b"|"lualine_c"|"lualine_x"|"lualine_y"|"lualine_z"
		---@param component function|table the component forming the lualine
		---@param whereInSection? "before"|"after" defaults to "after"
		vim.g.lualine_add = function(whichBar, whichSection, component, whereInSection)
			local ok, lualine = pcall(require, "lualine")
			if not ok then
				return
			end
			local sectionConfig = lualine.get_config()[whichBar][whichSection] or {}

			local componentObj = type(component) == "table" and component or { component }
			if whereInSection == "before" then
				table.insert(sectionConfig, 1, componentObj)
			else
				table.insert(sectionConfig, componentObj)
			end
			lualine.setup({ [whichBar] = { [whichSection] = sectionConfig } })
		end
	end,
	opts = {
		theme = "dracula",
	},
}
