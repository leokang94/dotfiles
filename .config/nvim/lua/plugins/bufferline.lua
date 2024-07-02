local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

return {
	{ "famiu/bufdelete.nvim" },
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = {
			"DaikyXendo/nvim-material-icon",
			-- "nvim-tree/nvim-web-devicons",
		},

		config = function()
			vim.opt.termguicolors = true
			require("bufferline").setup({
				options = {
					hover = {
						enabled = true,
						delay = 200,
						reveal = { "close" },
					},
					close_command = "Bdelete",
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							highlight = "Directory",
							separator = true, -- use a "true" to enable the default, or set your own character
						},
					},
					diagnostics = "nvim_lsp",
				},
			})

			map("n", "<A-,>", ":BufferLineCyclePrev<CR>", opts)
			map("n", "<A-.>", ":BufferLineCycleNext<CR>", opts)

			map("n", "<A-<>", ":BufferLineMovePrev<CR>", opts)
			map("n", "<A->>", ":BufferLineMoveNext<CR>", opts)
			-- for neovide
			map("n", "<A-D-,>", ":BufferLineMovePrev<CR>", opts)
			map("n", "<A-D-.>", ":BufferLineMoveNext<CR>", opts)

			map("n", "<A-Right>", ":tabnext<CR>", opts)
			map("n", "<A-Left>", ":tabprevious<CR>", opts)

			map("n", "<A-1>", ":BufferLineGoToBuffer 1<CR>", opts)
			map("n", "<A-2>", ":BufferLineGoToBuffer 2<CR>", opts)
			map("n", "<A-3>", ":BufferLineGoToBuffer 3<CR>", opts)
			map("n", "<A-4>", ":BufferLineGoToBuffer 4<CR>", opts)
			map("n", "<A-5>", ":BufferLineGoToBuffer 5<CR>", opts)
			map("n", "<A-6>", ":BufferLineGoToBuffer 6<CR>", opts)
			map("n", "<A-7>", ":BufferLineGoToBuffer 7<CR>", opts)
			map("n", "<A-8>", ":BufferLineGoToBuffer 8<CR>", opts)
			map("n", "<A-9>", ":BufferLineGoToBuffer 9<CR>", opts)
			map("n", "<A-0>", ":BufferLineGoToBuffer -1<CR>", opts)
			map("n", "<A-c>", ":Bdelete<CR>", opts)
		end,
	},
}
