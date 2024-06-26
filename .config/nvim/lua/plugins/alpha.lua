return {
	"goolord/alpha-nvim",
	dependencies = {
		"DaikyXendo/nvim-material-icon",
		-- "nvim-tree/nvim-web-devicons",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			"██╗     ███████╗ ██████╗     ██████╗ ███████╗██╗   ██╗",
			"██║     ██╔════╝██╔═══██╗    ██╔══██╗██╔════╝██║   ██║",
			"██║     █████╗  ██║   ██║    ██║  ██║█████╗  ██║   ██║",
			"██║     ██╔══╝  ██║   ██║    ██║  ██║██╔══╝  ╚██╗ ██╔╝",
			"███████╗███████╗╚██████╔╝    ██████╔╝███████╗ ╚████╔╝ ",
			"╚══════╝╚══════╝ ╚═════╝     ╚═════╝ ╚══════╝  ╚═══╝  ",
		}

		dashboard.section.buttons.val = {
			dashboard.button("enter", "󰑐  Restore session", ":lua require('persistence').load()<CR>"),
			dashboard.button("e", "  New file", ":enew<CR>"),
			dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
			dashboard.button("h", "  Recently opened files", ":Telescope oldfiles<CR>"),
			dashboard.button("b", "  Find buffer", ":Telescope buffers<CR>"),
			dashboard.button("q", "  Quit", ":q<CR>"),
		}

		local fortune = require("alpha.fortune")
		dashboard.section.footer.val = fortune()
		dashboard.section.footer.opts.hl = "@alpha.footer"
		table.insert(dashboard.config.layout, 5, {
			type = "padding",
			val = 1,
		})

		vim.cmd([[
        autocmd FileType alpha setlocal nofoldenable
      ]])

		alpha.setup(dashboard.opts)
		vim.api.nvim_create_autocmd("User", {
			callback = function()
				local stats = require("lazy").stats()
				local ms = math.floor(stats.startuptime * 100) / 100
				dashboard.section.footer.val = "󱐋 Lazy-loaded "
					.. stats.loaded
					.. "/"
					.. stats.count
					.. " plugins in "
					.. ms
					.. "ms"
				pcall(vim.cmd.AlphaRedraw)
			end,
		})
	end,
}
