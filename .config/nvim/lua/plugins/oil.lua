local is_vsplit = require("utils.screen").is_vsplit

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
			-- ["g?"] = { "actions.show_help", mode = "n" },
			-- ["<CR>"] = "actions.select",
			["<M-h>"] = { "actions.parent", mode = "n" },
			["<M-l>"] = "actions.select",
			["<M-v>"] = { "actions.select", opts = { vertical = true } },
			["<M-s>"] = { "actions.select", opts = { horizontal = true } },
			["<M-t>"] = { "actions.select", opts = { tab = true } },
			-- ["<C-p>"] = "actions.preview",
			-- ["<C-c>"] = { "actions.close", mode = "n" },
			-- ["<C-l>"] = "actions.refresh",
			-- ["-"] = { "actions.parent", mode = "n" },
			-- ["_"] = { "actions.open_cwd", mode = "n" },
			-- ["`"] = { "actions.cd", mode = "n" },
			-- ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
			-- ["gs"] = { "actions.change_sort", mode = "n" },
			-- ["gx"] = "actions.open_external",
			-- ["g."] = { "actions.toggle_hidden", mode = "n" },
			-- ["g\\"] = { "actions.toggle_trash", mode = "n" },
		},
	},
	keys = {
		{
			"<leader>o",
			function()
				local oil = require("oil")
				oil.open(nil, {
					preview = {
						vertical = is_vsplit() and true or false,
					},
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
