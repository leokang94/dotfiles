local mapKey = require("utils.keyMapper").mapKey

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			mapKey("<leader>ff", builtin.find_files)
			mapKey("<leader>fg", builtin.live_grep)
			mapKey("<leader>fb", builtin.buffers)
			mapKey("<leader>fh", builtin.help_tags)

			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			-- for multiple num_selections
			-- ref : https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-993956937
			local telescope_custom_actions = {}

			function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
				local picker = action_state.get_current_picker(prompt_bufnr)
				local num_selections = #picker:get_multi_selection()

				if not num_selections or num_selections <= 1 then
					actions.add_selection(prompt_bufnr)
				end

				actions.send_selected_to_qflist(prompt_bufnr)
				vim.cmd("cfdo " .. open_cmd)
			end
			function telescope_custom_actions.multi_selection_open_vsplit(prompt_bufnr)
				telescope_custom_actions._multiopen(prompt_bufnr, "vsplit")
			end
			function telescope_custom_actions.multi_selection_open_split(prompt_bufnr)
				telescope_custom_actions._multiopen(prompt_bufnr, "split")
			end
			function telescope_custom_actions.multi_selection_open_tab(prompt_bufnr)
				telescope_custom_actions._multiopen(prompt_bufnr, "tabe")
			end
			function telescope_custom_actions.multi_selection_open(prompt_bufnr)
				telescope_custom_actions._multiopen(prompt_bufnr, "edit")
			end

			local key_mapping = {
				["<ESC>"] = actions.close,
				["<C-J>"] = actions.move_selection_next,
				["<C-K>"] = actions.move_selection_previous,
				["<TAB>"] = actions.toggle_selection + actions.move_selection_next,
				["<S-TAB>"] = actions.toggle_selection + actions.move_selection_previous,
				["<C-V>"] = telescope_custom_actions.multi_selection_open_vsplit,
				["<C-S>"] = telescope_custom_actions.multi_selection_open_split,
				["<C-T>"] = telescope_custom_actions.multi_selection_open_tab,
				["<C-DOWN>"] = require("telescope.actions").cycle_history_next,
				["<C-UP>"] = require("telescope.actions").cycle_history_prev,
				["<C-O>"] = telescope_custom_actions.multi_selection_open,
				["<C-o>"] = function(prompt_bufnr)
					require("telescope.actions").select_default(prompt_bufnr)
					require("telescope.builtin").resume()
				end,
			}

			require("telescope").setup({
				defaults = {
					-- preview = {
					--   mime_hook = function(filepath, bufnr, opts)
					--     local is_image = function (filepath)
					--       local image_exntesions = {"png", "jpg", "jpeg", "gif", "ico"}
					--       local split_path = vim.split(filepath)
					--
					--     end
					--
					--   end
					-- },
					mappings = {
						n = key_mapping,
						i = key_mapping,
					},
					sorting_strategy = "ascending",
					path_display = { truncate = 3 },

					-- layout
					layout_strategy = "flex",
					layout_config = {
						horizontal = {
							width = 0.8,
							height = 0.6,
							prompt_position = "top",
							-- mirror = true,
						},
						vertical = {
							width = 0.9,
							height = 0.6,
							prompt_position = "top",
							mirror = true,
						},
						flex = {
							-- https://github.com/nvim-telescope/telescope.nvim/issues/3138#issue-2317392307
							flip_columns = 200,
							flip_lines = 40,
						},
					},
				},
				pickers = {
					find_files = {
						hidden = true,
					},
					buffers = {
						mappings = {
							i = {
								["<C-d>"] = actions.delete_buffer + actions.move_to_top,
							},
						},
					},
					oldfiles = {
						cwd_only = true,
					},
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
		config = function()
			require("telescope").setup({
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
					},
				},
			})

			require("telescope").load_extension("fzf")
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui=select"] = {
						require("telescope.themes").get_dropdown({
							-- even more opts
						}),
					},
				},
			})

			require("telescope").load_extension("ui-select")
		end,
	},
	{
		"smartpde/telescope-recent-files",
		config = function()
			require("telescope").setup({
				extensions = {
					recent_files = {
						only_cwd = true,
					},
				},
			})

			require("telescope").load_extension("recent_files")

			mapKey("<leader>fr", function()
				require("telescope").extensions.recent_files.pick()
			end)
		end,
	},
	{
		"nvim-telescope/telescope-media-files.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					media_files = {
						filetypes = { "png", "webp", "jpg", "jpeg", "ico" },
					},
				},
			})
		end,
	},
}
