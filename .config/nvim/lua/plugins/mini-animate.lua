return {
	"echasnovski/mini.animate",
	enablned = false,
	config = function()
		local animate = require("mini.animate")
		animate.setup({
			scroll = { enable = false },
			resize = { enable = false },
		})
	end,
}
