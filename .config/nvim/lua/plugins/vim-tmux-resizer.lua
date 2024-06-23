local keymap = vim.keymap

return {
	"RyanMillerC/better-vim-tmux-resizer",
	config = function()
		keymap.set("n", "<S-M-h>", "<cmd>TmuxResizeLeft<CR>")
		keymap.set("n", "<S-M-j>", "<cmd>TmuxResizeDown<CR>")
		keymap.set("n", "<S-M-k>", "<cmd>TmuxResizeUp<CR>")
		keymap.set("n", "<S-M-l>", "<cmd>TmuxResizeRight<CR>")
	end,
}
