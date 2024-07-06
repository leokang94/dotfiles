local mapKey = require("utils.keyMapper").mapKey

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
			ensure_installed = { "lua_ls", "vtsls", "tsserver", "eslint", "yamlls", "jsonls" },
		},
	},
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()
		end,
	},
	{
		"yioneko/nvim-vtsls",
		config = function()
			require("vtsls").config({})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		-- dependencies = {
		-- 	{
		-- 		"folke/neoconf.nvim",
		-- 		cmd = "Neoconf",
		-- 		opts = {},
		-- 	},
		-- 	{ "hrsh7th/cmp-nvim-lsp" },
		-- },
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
					virtual_text = false,
					underline = true,
					update_in_insert = true,
					severity_sort = true,
					virtual_lines = {
						only_current_line = true,
					},
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
									importModuleSpecifier = "non-relative",
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
				},
				setup = {},
			}
		end,
		-- config = function()
		-- 	-- require("neoconf").setup()
		-- 	-- local lspconfig = require("lspconfig")
		-- 	local lspconfig_util = require("lspconfig.util")
		--
		-- 	-- local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		-- 	-- for type, icon in pairs(signs) do
		-- 	-- 	local hl = "DiagnosticSign" .. type
		-- 	-- 	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		-- 	-- end
		-- 	--
		-- 	-- vim.diagnostic.config({
		-- 	-- 	float = { border = "rounded" },
		-- 	-- 	severity_sort = true,
		-- 	-- 	update_in_insert = true,
		-- 	-- 	virtual_text = false,
		-- 	-- 	virtual_lines = {
		-- 	-- 		only_current_line = true,
		-- 	-- 	},
		-- 	-- 	underline = true,
		-- 	-- })
		--
		-- 	--------------- SERVER CONFIGURATIONS ---------------
		-- 	local on_attach = function(_, bufnr)
		-- 		-- local function map(mode, keys, func, description)
		-- 		-- 	vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc(description) })
		-- 		-- end
		-- 		--
		-- 		-- map("n", "K", vim.lsp.buf.hover)
		-- 		-- map("n", "[d", vim.diagnostic.goto_prev)
		-- 		-- map("n", "]d", vim.diagnostic.goto_next)
		-- 		-- map("n", "gr", ":Telescope lsp_references<CR>")
		-- 		-- -- map('n',"gd", ":Telescope lsp_definitions<CR>")
		-- 		-- map("n", "gD", ":Lspsaga peek_definition<CR>")
		-- 		-- map("n", "gd", ":Lspsaga goto_definition<CR>")
		-- 		-- map("n", "gT", ":Lspsaga peek_type_definition<CR>")
		-- 		-- map("n", "gt", ":Lspsaga goto_type_definition<CR>")
		-- 		--
		-- 		-- map("n", "gi", ":Telescope lsp_implementations<CR>")
		-- 		-- map("n", "<leader>ca", ":Lspsaga code_action<CR>")
		-- 		-- map("n", "<leader>cd", vim.diagnostic.open_float)
		-- 		-- map("n", "<leader>cD", ":Telescope diagnostics bufnr=0<CR>")
		-- 		-- map("n", "<leader>s", ":Telescope lsp_document_symbols<CR>")
		-- 		-- -- map("<leader>rn", vim.lsp.buf.rename)
		-- 		-- map("n", "<leader>th", function()
		-- 		-- 	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
		-- 		-- end, "Toggle inlay hints")
		-- 	end
		--
		-- 	local capabilities = require("cmp_nvim_lsp").default_capabilities()
		-- 	capabilities.textDocument.completion.completionItem.snippetSupport = true
		-- 	capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
		--
		-- 	lspconfig.lua_ls.setup({
		-- 		capabilities = capabilities,
		-- 		on_attach = on_attach,
		--
		-- 		settings = {
		-- 			Lua = {
		-- 				diagnostics = {
		-- 					globals = { "vim" },
		-- 				},
		-- 			},
		-- 		},
		-- 	})
		--
		--
		-- 	lspconfig.vtsls.setup({
		-- 		capabilities = capabilities,
		-- 		init_options = {
		-- 			hostInfo = "neovim",
		-- 		},
		-- 		root_dir = lspconfig_util.find_git_ancestor,
		-- 		settings = {
		-- 			complete_function_calls = true,
		-- 			vtsls = {
		-- 				enableMoveToFileCodeAction = false,
		-- 				autoUseWorkspaceTsdk = true,
		-- 				experimental = {
		-- 					completion = {
		-- 						enableServerSideFuzzyMatch = true,
		-- 					},
		-- 				},
		-- 			},
		-- 			typescript = {
		-- 				preferences = {
		-- 					importModuleSpecifier = "non-relative",
		-- 				},
		-- 				updateImportsOnFileMove = { enabled = "always" },
		-- 				suggest = {
		-- 					completeFunctionCalls = true,
		-- 				},
		-- 				inlayHints = {
		-- 					enumMemberValues = { enabled = true },
		-- 					functionLikeReturnTypes = { enabled = true },
		-- 					parameterNames = { enabled = "literals" },
		-- 					parameterTypes = { enabled = true },
		-- 					propertyDeclarationTypes = { enabled = true },
		-- 					variableTypes = { enabled = false },
		-- 				},
		-- 			},
		-- 		},
		-- 	})
		--
		-- 	lspconfig.eslint.setup({
		-- 		capabilities = capabilities,
		-- 		root_dir = lspconfig_util.find_git_ancestor,
		-- 		settings = {
		-- 			packageManager = "yarn",
		-- 		},
		-- 		on_attach = function(_, bufnr)
		-- 			on_attach(_, bufnr)
		-- 			vim.api.nvim_create_autocmd("BufWritePre", {
		-- 				buffer = bufnr,
		-- 				command = "EslintFixAll",
		-- 			})
		-- 		end,
		-- 	})
		--
		-- 	lspconfig.yamlls.setup({
		-- 		capabilities = capabilities,
		-- 		on_attach = on_attach,
		-- 	})
		--
		-- 	lspconfig.html.setup({
		-- 		capabilities = capabilities,
		-- 		on_attach = on_attach,
		-- 	})
		--
		-- 	lspconfig.jsonls.setup({
		-- 		capabilities = capabilities,
		-- 		on_attach = on_attach,
		-- 		settings = {
		-- 			json = {
		-- 				schemas = {
		-- 					{
		-- 						fileMatch = { "package.json" },
		-- 						url = "https://json.schemastore.org/package.json",
		-- 					},
		-- 					{
		-- 						fileMatch = { "tsconfig.json", "tsconfig.*.json" },
		-- 						url = "http://json.schemastore.org/tsconfig",
		-- 					},
		-- 					{
		-- 						fileMatch = { ".eslintrc.json" },
		-- 						url = "https://json.schemastore.org/eslintrc",
		-- 					},
		-- 					{
		-- 						fileMatch = { ".prettierrc.json" },
		-- 						url = "https://json.schemastore.org/prettierrc",
		-- 					},
		-- 				},
		-- 			},
		-- 		},
		-- 	})
		--
		-- 	lspconfig.taplo.setup({
		-- 		capabilities = capabilities,
		-- 		on_attach = on_attach,
		-- 	})
		--
		-- 	vim.api.nvim_create_autocmd("LspAttach", {
		-- 		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		-- 		callback = function(args)
		-- 			mapKey("K", vim.lsp.buf.hover)
		-- 			mapKey("[d", vim.diagnostic.goto_prev)
		-- 			mapKey("]d", vim.diagnostic.goto_next)
		-- 			mapKey("gr", ":Telescope lsp_references<CR>")
		-- 			mapKey("gD", ":Lspsaga peek_definition<CR>")
		-- 			mapKey("gd", ":Lspsaga goto_definition<CR>")
		-- 			mapKey("gT", ":Lspsaga peek_type_definition<CR>")
		-- 			mapKey("gt", ":Lspsaga goto_type_definition<CR>")
		--
		-- 			mapKey("gi", ":Telescope lsp_implementations<CR>")
		-- 			mapKey("<leader>ca", ":Lspsaga code_action<CR>")
		-- 			mapKey("<leader>cd", vim.diagnostic.open_float)
		-- 			mapKey("<leader>cD", ":Telescope diagnostics bufnr=0<CR>")
		-- 			mapKey("<leader>s", ":Telescope lsp_document_symbols<CR>")
		--
		-- 			mapKey("<leader>it", function()
		-- 				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		-- 			end)
		-- 		end,
		-- 	})
		-- end,
	},
}
