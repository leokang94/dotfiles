return {
	-- NOTE :: mason 2.0 으로 올라가면서, LazyVim 에서 아직 호환되지 않는 부분에 대한 workaround. mason, mason-lspconfig 버전을 우선 고정함.
	-- ref : https://www.reddit.com/r/neovim/comments/1kgu748/comment/mr41tkr/
	{ "mason-org/mason.nvim", version = "1.11.0" },
	{ "mason-org/mason-lspconfig.nvim", version = "1.32.0" },
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

				-- linter
				"luacheck",
				"yamllint",
				"markdownlint-cli2",
				"shellcheck",
				"cspell",

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
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				yaml = { "yamlfmt" },
				json = { "prettier" },
				jsonc = { "prettier" },
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
	{
		"yioneko/nvim-vtsls",
		config = function()
			require("vtsls").config({})
		end,
	},
	-- for diagnostics visualization
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "LspAttach", -- Or `LspAttach`
		priority = 1000, -- needs to be loaded in first
		config = function()
			require("tiny-inline-diagnostic").setup({
				preset = "ghost",
				transparent_bg = true,
				options = {
					multilines = true,
					format = function(diagnostic)
						return "[" .. diagnostic.source .. "] " .. diagnostic.message
					end,
				},
			})
		end,
	},
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
		opts = function()
			local keys = require("lazyvim.plugins.lsp.keymaps").get()

			keys[#keys + 1] = { "[[", false }
			keys[#keys + 1] = { "]]", false }

			-- keys[#keys + 1] = { "gr", ":FzfLua lsp_references jump1=true ignore_current_line=true<CR>" }
			-- keys[#keys + 1] = { "gd", ":FzfLua lsp_definitions jump1=true ignore_current_line=true<CR>" }
			-- keys[#keys + 1] = { "gt", ":FzfLua lsp_typedefs jump1=true ignore_current_line=true<CR>" }
			-- keys[#keys + 1] = { "gi", ":FzfLua lsp_implementations jump1=true ignore_current_line=true<CR>" }
			keys[#keys + 1] = {
				"<leader>ca",
				function()
					require("fzf-lua").lsp_code_actions({
						winopts = {
							relative = "cursor",
							width = 0.8,
							height = 0.8,
							row = 1,
							preview = { vertical = "up:70%" },
						},
					})
				end,
				"Code Actions",
				{ "n", "v" },
			}
			keys[#keys + 1] = { "<leader>cd", ":FzfLua lsp_document_diagnostics<CR>", desc = "Open Code Diagnostics" }

			return {
				diagnostics = {
					signs = {
						Error = " ",
						Warn = " ",
						Hint = "󰠠 ",
						Info = " ",
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
				codelens = { enabled = false },
				document_highlight = { enabled = true },
				capabilities = {
					workspace = {
						fileOperations = {
							didRename = true,
							willRename = true,
						},
					},
				},

				format = {
					formatting_options = nil,
					timeout_ms = nil,
				},
				servers = {},
				setup = {},
			}
		end,
	},
}
