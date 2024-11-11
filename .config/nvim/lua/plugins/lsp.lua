return {
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "shellcheck" })
		end,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "lua_ls", "vtsls", "eslint", "yamlls", "jsonls" },
		},
	},
	{
		"yioneko/nvim-vtsls",
		config = function()
			require("vtsls").config({})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = function()
			local lspconfig_util = require("lspconfig.util")

			local keys = require("lazyvim.plugins.lsp.keymaps").get()

			keys[#keys + 1] = { "[[", false }
			keys[#keys + 1] = { "]]", false }

			keys[#keys + 1] = { "K", vim.lsp.buf.hover }
			keys[#keys + 1] = { "[d", vim.diagnostic.goto_prev }
			keys[#keys + 1] = { "]d", vim.diagnostic.goto_next }
			keys[#keys + 1] = { "gr", ":Telescope lsp_references<CR>" }
			keys[#keys + 1] = { "gD", ":Lspsaga peek_definition<CR>" }
			keys[#keys + 1] = { "gd", ":Lspsaga goto_definition<CR>" }
			keys[#keys + 1] = { "gT", ":Lspsaga peek_type_definition<CR>" }
			keys[#keys + 1] = { "gt", ":Lspsaga goto_type_definition<CR>" }
			keys[#keys + 1] = { "gi", ":Telescope lsp_implementations<CR>" }
			keys[#keys + 1] = { "<leader>ca", ":Lspsaga code_action<CR>" }
			keys[#keys + 1] = { "<leader>cd", vim.diagnostic.open_float }
			keys[#keys + 1] = { "<leader>cD", ":Telescope diagnostics bufnr=0<CR>" }
			keys[#keys + 1] = { "<leader>s", ":Telescope lsp_document_symbols<CR>" }
			-- keys[#keys + 1] = {
			-- 	"<leader>it",
			-- 	function()
			-- 		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			-- 	end,
			-- }

			return {
				diagnostics = {
					signs = {
						Error = " ",
						Warn = " ",
						Hint = "󰠠 ",
						Info = " ",
					},
					virtual_text = true,
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
				servers = {
					lua_ls = {
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
							},
						},
					},

					tsserver = { enabled = false },
					ts_ls = { enabled = false },
					vtsls = {
						init_options = {
							hostInfo = "neovim",
						},
						root_dir = lspconfig_util.find_git_ancestor,
						settings = {
							complete_function_calls = true,
							vtsls = {
								enableMoveToFileCodeAction = false,
								autoUseWorkspaceTsdk = true,
								experimental = {
									completion = {
										enableServerSideFuzzyMatch = true,
									},
								},
							},
							typescript = {
								preferences = {
									-- importModuleSpecifier = "non-relative",
								},
								updateImportsOnFileMove = { enabled = "always" },
								suggest = {
									completeFunctionCalls = true,
								},
								-- inlayHints = {
								-- 	enumMemberValues = { enabled = true },
								-- 	functionLikeReturnTypes = { enabled = true },
								-- 	parameterNames = { enabled = "literals" },
								-- 	parameterTypes = { enabled = true },
								-- 	propertyDeclarationTypes = { enabled = true },
								-- 	variableTypes = { enabled = false },
								-- },
							},
						},
						on_attach = function(client, bufnr)
							require("twoslash-queries").attach(client, bufnr)
						end,
					},

					eslint = {
						root_dir = lspconfig_util.find_git_ancestor,
						settings = {
							packageManager = "yarn",
						},
						on_attach = function(_, bufnr)
							vim.api.nvim_create_autocmd("BufWritePre", {
								buffer = bufnr,
								command = "EslintFixAll",
							})
						end,
					},

					tailwindCSS = {},

					yamlls = {},
					html = {},
					taplo = {},
					jsonls = {
						settings = {
							json = {
								schemas = {
									{
										fileMatch = { "package.json" },
										url = "https://json.schemastore.org/package.json",
									},
									{
										fileMatch = { "tsconfig.json", "tsconfig.*.json" },
										url = "http://json.schemastore.org/tsconfig",
									},
									{
										fileMatch = { ".eslintrc.json" },
										url = "https://json.schemastore.org/eslintrc",
									},
									{
										fileMatch = { ".prettierrc.json" },
										url = "https://json.schemastore.org/prettierrc",
									},
								},
							},
						},
					},
					mdx_analyzer = {},
				},
				setup = {},
			}
		end,
	},
}
