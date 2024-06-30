return {
	"echasnovski/mini.animate",
	config = function()
		local animate = require("mini.animate")
		animate.setup({
			scroll = { enable = false },
			resize = { enable = false },
		})
	end,
}
