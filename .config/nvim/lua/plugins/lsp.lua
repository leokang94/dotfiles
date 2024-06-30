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
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufWritePre", "BufNewFile" },
		dependencies = {
			{
				"folke/neoconf.nvim",
				cmd = "Neoconf",
				opts = {},
			},
			{ "hrsh7th/cmp-nvim-lsp" },
			{
				"yioneko/nvim-vtsls",
				config = function()
					require("vtsls").config({})
				end,
			},
		},
		opts = {},
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

			--------------- SERVER CONFIGURATIONS ---------------
			local on_attach = function(_, bufnr)
				-- local function map(mode, keys, func, description)
				-- 	vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc(description) })
				-- end
				--
				-- map("n", "K", vim.lsp.buf.hover)
				-- map("n", "[d", vim.diagnostic.goto_prev)
				-- map("n", "]d", vim.diagnostic.goto_next)
				-- map("n", "gr", ":Telescope lsp_references<CR>")
				-- -- map('n',"gd", ":Telescope lsp_definitions<CR>")
				-- map("n", "gD", ":Lspsaga peek_definition<CR>")
				-- map("n", "gd", ":Lspsaga goto_definition<CR>")
				-- map("n", "gT", ":Lspsaga peek_type_definition<CR>")
				-- map("n", "gt", ":Lspsaga goto_type_definition<CR>")
				--
				-- map("n", "gi", ":Telescope lsp_implementations<CR>")
				-- map("n", "<leader>ca", ":Lspsaga code_action<CR>")
				-- map("n", "<leader>cd", vim.diagnostic.open_float)
				-- map("n", "<leader>cD", ":Telescope diagnostics bufnr=0<CR>")
				-- map("n", "<leader>s", ":Telescope lsp_document_symbols<CR>")
				-- -- map("<leader>rn", vim.lsp.buf.rename)
				-- map("n", "<leader>th", function()
				-- 	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
				-- end, "Toggle inlay hints")
			end

			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,

				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			lspconfig.vtsls.setup({
				capabilities = capabilities,
				settings = {
					complete_function_calls = true,
					vtsls = {
						enableMoveToFileCodeAction = true,
						autoUseWorkspaceTsdk = true,
						experimental = {
							completion = {
								enableServerSideFuzzyMatch = true,
							},
						},
					},
					typescript = {
						tsdk = "./node_modules/typescript/lib" or "./.yarn/sdks/typescript/lib",
						preferences = {
							importModuleSpecifier = "non-relative",
						},
						updateImportsOnFileMove = { enabled = "always" },
						suggest = {
							completeFunctionCalls = true,
						},
						inlayHints = {
							enumMemberValues = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							variableTypes = { enabled = false },
						},
					},
				},
			})

			lspconfig.eslint.setup({
				capabilities = capabilities,

				settings = {
					packageManager = "yarn",
				},
				on_attach = function(_, bufnr)
					on_attach(_, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			})

			lspconfig.yamlls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.html.setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			lspconfig.jsonls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
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
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(args)
					mapKey("K", vim.lsp.buf.hover)
					mapKey("[d", vim.diagnostic.goto_prev)
					mapKey("]d", vim.diagnostic.goto_next)
					mapKey("gr", ":Telescope lsp_references<CR>")
					mapKey("gD", ":Lspsaga peek_definition<CR>")
					mapKey("gd", ":Lspsaga goto_definition<CR>")
					mapKey("gT", ":Lspsaga peek_type_definition<CR>")
					mapKey("gt", ":Lspsaga goto_type_definition<CR>")

					mapKey("gi", ":Telescope lsp_implementations<CR>")
					mapKey("<leader>ca", ":Lspsaga code_action<CR>")
					mapKey("<leader>cd", vim.diagnostic.open_float)
					mapKey("<leader>cD", ":Telescope diagnostics bufnr=0<CR>")
					mapKey("<leader>s", ":Telescope lsp_document_symbols<CR>")

					mapKey("<leader>it", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
					end)
				end,
			})
		end,
	},
}
