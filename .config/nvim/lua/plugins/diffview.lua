return {
	"sindrets/diffview.nvim",
	lazy = false,
	keys = {
		{ "<leader>do", "<cmd>DiffviewOpen<CR>", desc = "Diffview open" },
		{ "<leader>dO", "<cmd>DiffviewOpen HEAD^<CR>", desc = "Diffview open HEAD^..HEAD" },
		{ "<leader>dc", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
		{ "<leader>dh", ":DiffviewFileHistory", desc = "Diffview File history" },
		{ "<leader>dl", ":.DiffviewFileHistory --follow<CR>", desc = "File history for the current line" },
		{
			mode = "v",
			"<leader>dr",
			"<Esc>:'<,'>DiffviewFileHistory --follow<CR>",
			desc = "File history for the visual selection",
		},
	},
	opts = function(_, opts)
		opts.view = {
			default = {
				disable_diagnostics = true,
				winbar_info = true,
			},
			merge_tool = {
				layout = "diff3_mixed",
				disable_diagnostics = true,
				winbar_info = true,
			},
			file_history = {
				disable_diagnostics = true,
				winbar_info = true,
			},
		}

		opts.signs = {
			fold_closed = "",
			fold_open = "󰅀",
		}

		opts.file_panel = {
			win_config = { -- See |diffview-config-win_config|
				position = "right",
				width = 35,
				win_opts = {},
			},
		}

		local actions = require("diffview.actions")
		opts.keymaps = {
			file_panel = {
				{
					"n",
					"x",
					actions.restore_entry,
					{ desc = "Restore entry to the state on the left side" },
				},
				{
					"n",
					"X",
					function()
						vim.cmd("!git restore .")
					end,
					{ desc = "Restore all entries" },
				},
			},
		}

		opts.hooks = {
			view_opened = function()
				vim.cmd("VimadeDisable")
			end,

			view_enter = function()
				vim.cmd("VimadeDisable")
			end,

			view_leave = function()
				vim.cmd("VimadeEnable")
			end,

			view_closed = function()
				vim.cmd("VimadeEnable")
			end,

			diff_buf_win_enter = function(bufnr, winid, ctx)
				vim.treesitter.start()

				-- Highlight 'DiffChange' as 'DiffDelete' on the left, and 'DiffAdd' on
				-- the right.
				if ctx.layout_name:match("^diff2") then
					if ctx.symbol == "a" then
						vim.wo[winid].winhl = table.concat({
							"DiffAdd:DiffviewDiffAddAsDelete",
							"DiffDelete:DiffviewDiffDelete",
							"DiffChange:DiffAddAsDelete",
							"DiffText:DiffDeleteText",
						}, ",")
					elseif ctx.symbol == "b" then
						vim.wo[winid].winhl = table.concat({
							"DiffDelete:DiffviewDiffDelete",
							"DiffChange:DiffAdd",
							"DiffText:DiffAddText",
						}, ",")
					end
				end
			end,
		}
	end,
}
