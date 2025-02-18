return {
	"stevearc/oil.nvim",
	opts = {
		default_file_explorer = true,
		columns = { "icon", "size" },
		watch_for_chagnes = true,
		view_options = {
			show_hidden = true,
		},

		keymaps = {
			["g?"] = { "actions.show_help", mode = "n" },
			["<S-h>"] = { "actions.parent", mode = "n" },
			["<S-l>"] = "actions.select",
			["<CR>"] = "actions.select",
			["<C-v>"] = { "actions.select", opts = { vertical = true } },
			["<C-s>"] = { "actions.select", opts = { horizontal = true } },
			["<C-t>"] = { "actions.select", opts = { tab = true } },
			["<C-p>"] = "actions.preview",
			["<C-c>"] = { "actions.close", mode = "n" },
			-- ["<C-l>"] = "actions.refresh",
			["<leader>cd"] = { "actions.cd", mode = "n" },
			["<leader>cD"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
			["gs"] = { "actions.change_sort", mode = "n" },
			["gx"] = "actions.open_external",
			["g."] = { "actions.toggle_hidden", mode = "n" },
			["g\\"] = { "actions.toggle_trash", mode = "n" },
		},
		use_default_keymaps = false,
	},
	keys = {
		{
			"<leader>o",
			function()
				local oil = require("oil")
				oil.open_float(nil, {
					preview = {},
				})

				-- Wait until oil has opened, for a maximum of 1 second.
				vim.wait(1000, function()
					return oil.get_cursor_entry() ~= nil
				end)
			end,
			desc = "Open File Explorer",
		},
	},
}
