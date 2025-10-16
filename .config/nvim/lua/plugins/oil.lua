return {
	{
		"stevearc/oil.nvim",
		opts = {
			default_file_explorer = true,
			columns = { "icon", "size" },
			watch_for_chagnes = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
			win_options = {
				signcolumn = "yes:2",
			},
			preview_win = {
				-- 파일 크기가 1MB(1048576 bytes) 이상이면 미리보기 비활성화
				disable_preview = function(filename)
					local stat = vim.loop.fs_stat(filename)
					return stat and stat.size > 1048576
				end,
			},

			float = {
				padding = 4,
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
					oil.open_float(nil)

					-- Wait until oil has opened, for a maximum of 1 second.
					vim.wait(1000, function()
						return oil.get_cursor_entry() ~= nil
					end)
				end,
				desc = "Open File Explorer",
			},
		},
	},
	{
		"refractalize/oil-git-status.nvim",
		dependencies = {
			"stevearc/oil.nvim",
		},
		opts = {
			show_ignored = true, -- show files that match gitignore with !!
			symbols = { -- customize the symbols that appear in the git status columns
				index = {
					["!"] = "!",
					["?"] = "?",
					["A"] = "A",
					["C"] = "C",
					["D"] = "D",
					["M"] = "M",
					["R"] = "R",
					["T"] = "T",
					["U"] = "U",
					[" "] = " ",
				},
				working_tree = {
					["!"] = "!",
					["?"] = "?",
					["A"] = "A",
					["C"] = "C",
					["D"] = "D",
					["M"] = "M",
					["R"] = "R",
					["T"] = "T",
					["U"] = "U",
					[" "] = " ",
				},
			},
		},
	},
	{
		"JezerM/oil-lsp-diagnostics.nvim",
		dependencies = { "stevearc/oil.nvim" },
		opts = {},
	},
}
