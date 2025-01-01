return {
	"stevearc/oil.nvim",
	opts = {
		default_file_explorer = true,
		columns = { "icon", "size" },
		watch_for_chagnes = true,
		view_options = {
			show_hidden = true,
		},
	},
	keys = {
		{
			"<leader>o",
			function()
				local oil = require("oil")
				oil.open()

				-- Wait until oil has opened, for a maximum of 1 second.
				vim.wait(1000, function()
					return oil.get_cursor_entry() ~= nil
				end)
				if oil.get_cursor_entry() then
					oil.open_preview()
				end
			end,
			desc = "Open File Explorer",
		},
	},
}
