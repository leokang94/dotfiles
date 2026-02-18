return {
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				-- lsp
				"lua-language-server",
				"vtsls",
				"eslint-lsp",
				"glsl_analyzer",
				"html-lsp",
				"json-lsp",
				"mdx-analyzer",
				"tailwindcss-language-server",
				"taplo",
				"yaml-language-server",
				"emmet-ls",
				"css-variables-language-server",
				"cssmodules-language-server",
				"css-lsp",

				-- linter
				"oxlint",
				"stylelint",
				"luacheck",
				"yamllint",
				"markdownlint-cli2",
				"shellcheck",
				"cspell",
				"biome",

				-- formatter
				"prettier",
				"markdown-toc",
				"stylua",
				"yamlfmt",
			},
		},
	},
	-- auto formatter
	{
		"stevearc/conform.nvim",
		opts = {
			default_format_opts = {
				stop_after_first = true,
			},
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "biome-check", "prettier" },
				typescript = { "biome-check", "prettier" },
				javascriptreact = { "biome-check", "prettier" },
				typescriptreact = { "biome-check", "prettier" },
				yaml = { "yamlfmt" },
				json = { "biome-check", "prettier" },
				jsonc = { "biome-check", "prettier" },
				mdx = { "prettier", "markdownlint-cli2", "markdown-toc" },
				toml = { "taplo" },
				-- sh = { "shfmt" },
				-- zsh = { "shfmt" },
			},
		},
	},
	-- auto lint
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufWritePost", "BufEnter", "InsertLeave", "BufNewFile" },
		opts = {
			linters_by_ft = {
				-- lua = { "luacheck" },
				yaml = { "yamllint" },
				javascript = { "cspell" },
				typescript = { "cspell" },
				javascriptreact = { "cspell" },
				typescriptreact = { "cspell" },
			},
		},
	},
	-- for diagnostics visualization
	-- {
	-- 	"rachartier/tiny-inline-diagnostic.nvim",
	-- 	event = "LspAttach", -- Or `LspAttach`
	-- 	priority = 1000, -- needs to be loaded in first
	-- 	config = function()
	-- 		require("tiny-inline-diagnostic").setup({
	-- 			preset = "ghost",
	-- 			transparent_bg = true,
	-- 			options = {
	-- 				multilines = true,
	-- 				format = function(diagnostic)
	-- 					return "[" .. diagnostic.source .. "] " .. diagnostic.message
	-- 				end,
	-- 			},
	-- 		})
	-- 	end,
	-- },
	{
		"ray-x/lsp_signature.nvim",
		event = "InsertEnter",
		opts = {
			floating_window = false,
			hint_prefix = {
				above = "↙ ",
				current = "← ",
				below = "↖ ",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		keys = {
			{ "[[", false },
			{ "]] ", false },
			-- code
			{
				"<leader>ca",
				function()
					vim.lsp.buf.code_action()
				end,
				desc = "Code Action",
			},
			{
				"<leader>ci",
				function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				end,
				desc = "Toggle Inlay Hints",
			},
		},
		opts = {
			diagnostics = {
				signs = {
					Error = " ",
					Warn = " ",
					Hint = "󰠠 ",
					Info = " ",
				},
				virtual_lines = {
					current_line = true,
					format = function(diagnostic)
						return "[" .. diagnostic.source .. "] " .. diagnostic.message
					end,
				},
				virtual_text = false,
				underline = true,
				update_in_insert = true,
				severity_sort = true,
				float = {
					border = "rounded",
				},
			},

			inlay_hints = {
				enabled = false,
			},
		},
	},
}
