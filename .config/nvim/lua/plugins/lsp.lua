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
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "tsserver", "vtsls", "yamlls" },
			})
		end,
	},
	{
		"folke/neodev.nvim",
		config = function()
			require("neodev").setup({})
		end,
	},
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = function()
			require("lsp_lines").setup()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"folke/neoconf.nvim",
				cmd = "Neoconf",
				opts = {},
			},
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		opts = {
			servers = {
				bashls = {},
			},
		},
		config = function()
			require("neoconf").setup()
			local lspconfig = require("lspconfig")

			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			vim.diagnostic.config({
				float = { border = "rounded" },
				severity_sort = true,
				update_in_insert = true,
				virtual_text = false,
				virtual_lines = {
					only_current_line = true,
				},
				underline = true,
			})

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

			--------------- SERVER CONFIGURATIONS ---------------
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			lspconfig.lua_ls.setup({
				capabilities = capabilities,

				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			-- lspconfig.vtsls.setup({
			-- 	capabilities = capabilities,
			-- 	settings = {
			-- 		complete_function_calls = true,
			-- 		vtsls = {
			-- 			enableMoveToFileCodeAction = true,
			-- 			autoUseWorkspaceTsdk = true,
			-- 			experimental = {
			-- 				completion = {
			-- 					enableServerSideFuzzyMatch = true,
			-- 				},
			-- 			},
			-- 			-- typescript = { globalTsdk = "./node_modules/typescript/tsserver" },
			-- 			tsserver = {
			-- 				log = "verbose",
			--
			-- 				globalPlugins = {
			-- 					{
			-- 						name = "@styled/typescript-styled-plugin",
			-- 						-- location = "/Users/leo/.nvm/versions/node/v18.18.0/lib/node_modules",
			-- 						-- -- languages = { "typescript", "javascript", "typescriptreact" },
			-- 						-- enableForWorkspaceTypeScriptVersions = true,
			-- 						-- -- configNamespace = "typescript",
			-- 					},
			-- 				},
			-- 			},
			-- 		},
			-- 		typescript = {
			-- 			preferences = {
			-- 				importModuleSpecifier = "non-relative",
			-- 			},
			-- 			tsserver = {
			-- 				log = "verbose",
			-- 				globalPlugins = {
			-- 					name = "@styled/typescript-styled-plugin",
			-- 					enableForWorkspaceTypeScriptVersions = true,
			-- 				},
			-- 			},
			-- 			updateImportsOnFileMove = { enabled = "always" },
			-- 			suggest = {
			-- 				completeFunctionCalls = true,
			-- 			},
			-- 			inlayHints = {
			-- 				enumMemberValues = { enabled = true },
			-- 				functionLikeReturnTypes = { enabled = true },
			-- 				parameterNames = { enabled = "literals" },
			-- 				parameterTypes = { enabled = true },
			-- 				propertyDeclarationTypes = { enabled = true },
			-- 				variableTypes = { enabled = false },
			-- 			},
			-- 		},
			-- 	},
			-- 	-- settings = {
			-- 	-- 	vtsls = {
			-- 	-- 		autoUseWorkspaceTsdk = true,
			-- 	-- 		tsserver = {
			-- 	--
			-- 	-- 			globalPlugins = {
			-- 	-- 				{
			-- 	-- 					name = "@styled/typescript-styled-plugin",
			-- 	--
			-- 	-- 					location = "/Users/leo/.nvm/versions/node/v18.18.0/lib/node_modules",
			-- 	-- 					enableForWorkspaceTypeScriptVersions = true,
			-- 	-- 				},
			-- 	-- 			},
			-- 	-- 		},
			-- 	-- 	},
			-- 	-- 	typescript = {
			-- 	-- 		tsserver = { log = "verbose" },
			-- 	-- 	},
			-- 	--
			-- 	-- },
			-- })

			lspconfig.eslint.setup({
				settings = {
					packageManager = "yarn",
				},
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			})

			lspconfig.yamlls.setup({
				capabilities = capabilities,
			})

			lspconfig.html.setup({
				capabilities = capabilities,
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function()
					mapKey("K", vim.lsp.buf.hover)
					mapKey("[d", vim.diagnostic.goto_prev)
					mapKey("]d", vim.diagnostic.goto_next)
					mapKey("gr", ":Telescope lsp_references<CR>")
					-- mapKey("gd", ":Telescope lsp_definitions<CR>")
					mapKey("gD", ":Lspsaga peek_definition<CR>")
					mapKey("gd", ":Lspsaga goto_definition<CR>")
					mapKey("gT", ":Lspsaga peek_type_definition<CR>")
					mapKey("gt", ":Lspsaga goto_type_definition<CR>")

					mapKey("gi", ":Telescope lsp_implementations<CR>")
					mapKey("<leader>ca", ":Lspsaga code_action<CR>")
					mapKey("<leader>cd", vim.diagnostic.open_float)
					mapKey("<leader>cD", ":Telescope diagnostics bufnr=0<CR>")
					mapKey("<leader>s", ":Telescope lsp_document_symbols<CR>")
					-- mapKey("<leader>rn", vim.lsp.buf.rename)

					-- mapKey("th", function()
					-- 	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
					-- end)
				end,
			})
		end,
	},
	{
		"yioneko/nvim-vtsls",
		config = function()
			require("vtsls").config({})
		end,
	},
}
