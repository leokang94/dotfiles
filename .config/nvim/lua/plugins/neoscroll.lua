return {
	"karb94/neoscroll.nvim",
	config = function()
		local neoscroll = require("neoscroll")

		neoscroll.setup({
			hide_cursor = false,
			easing = "circular",
		})

		local keymap = {
			-- When no value is passed the `easing` option supplied in `setup()` is used
			["<C-y>"] = function()
				neoscroll.scroll(-0.1, { move_cursor = false, duration = 100 })
			end,
			["<C-e>"] = function()
				neoscroll.scroll(0.1, { move_cursor = false, duration = 100 })
			end,
		}

		local modes = { "n", "v", "x" }
		for key, func in pairs(keymap) do
			vim.keymap.set(modes, key, func)
		end
	end,
}
