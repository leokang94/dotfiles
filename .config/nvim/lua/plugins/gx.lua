return {
	"chrishrb/gx.nvim",
	keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
	cmd = { "Browse" },
	init = function()
		vim.g.netrw_nogx = 1 -- disable netrw gx
	end,
	dependencies = { "nvim-lua/plenary.nvim" }, -- Required for Neovim < 0.10.0
	submodules = false, -- not needed, submodules are required only for tests

	-- you can specify also another config if you want
	config = function()
		require("gx").setup({
			open_browser_app = "open",
			open_browser_args = { "--background" },
			handlers = {
				plugin = true, -- open plugin links in lua (e.g. packer, lazy, ..)
				github = true, -- open github issues
				brewfile = true, -- open Homebrew formulaes and casks
				package_json = true, -- open dependencies from package.json
				search = true, -- search the web/selection on the web if nothing else is found
				go = true, -- open pkg.go.dev from an import statement (uses treesitter)
				jira = { -- custom handler to open Jira tickets (these have higher precedence than builtin handlers)
					name = "jira", -- set name of handler
					handle = function(mode, line, _)
						local ticket = require("gx.helper").find(line, mode, "(%u+-%d+)")
						if ticket and #ticket < 20 then
							-- Bunjang
							return "https://quicket.atlassian.net/browse/" .. ticket
						end
					end,
				},
				rust = { -- custom handler to open rust's cargo packages
					name = "rust", -- set name of handler
					filetype = { "toml" }, -- you can also set the required filetype for this handler
					filename = "Cargo.toml", -- or the necessary filename
					handle = function(mode, line, _)
						local crate = require("gx.helper").find(line, mode, "(%w+)%s-=%s")

						if crate then
							return "https://crates.io/crates/" .. crate
						end
					end,
				},
				js_jsx_ts_tsx = {
					name = "js_jsx_ts_tsx",
					filetype = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
					handle = function(mode, line, _)
						local npm_domain = "https://www.npmjs.com/package/"
						local esm_package = require("gx.helper").find(line, mode, ".*from.+['\"](.+)['\"]")
						local cjs_package = require("gx.helper").find(line, mode, ".*require%(['\"](.+)['\"]%)")

						if esm_package then
							return npm_domain .. esm_package
						end

						if cjs_package then
							return npm_domain .. cjs_package
						end
					end,
				},
			},
			handler_options = {
				search_engine = "google", -- you can select between google, bing, duckduckgo, ecosia and yandex
				select_for_search = false, -- if your cursor is e.g. on a link, the pattern for the link AND for the word will always match. This disables this behaviour for default so that the link is opened without the select option for the word AND link
				git_remotes = { "upstream", "origin" }, -- list of git remotes to search for git issue linking, in priority
				git_remote_push = false, -- use the push url for git issue linking,
			},
		})
	end,
}
