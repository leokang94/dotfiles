local LspUtils = require("core.lsp.utils")

local inlay_hints = {
	enumMemberValues = { enabled = true },
	functionLikeReturnTypes = { enabled = true },
	parameterNames = { enabled = "literals" },
	parameterTypes = { enabled = true },
	propertyDeclarationTypes = { enabled = true },
	variableTypes = { enabled = false },
}

local settings = {
	updateImportsOnFileMove = { enabled = "always" },
	suggest = { completeFunctionCalls = true },
	inlayHints = inlay_hints,
}

---@type vim.lsp.Config
return {
	cmd = { "vtsls", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},

	root_dir = LspUtils.get_root_dir,

	init_options = {
		hostInfo = "neovim",
	},

	settings = {
		complete_function_calls = true,
		vtsls = {
			enableMoveToFileCodeAction = false,
			autoUseWorkspaceTsdk = true,
			experimental = {
				maxInlayHintLength = 30,
				completion = {
					enableServerSideFuzzyMatch = true,
				},
			},
		},
		typescript = vim.tbl_deep_extend("keep", settings, {
			enablePromptUseWorkspaceTsdk = true,
			tsdk = ".yarn/sdks/typescript/lib",
		}),
		javascript = settings,
	},

	on_attach = function(client, bufnr)
		require("twoslash-queries").attach(client, bufnr)

		vim.keymap.set("n", "<leader>co", LazyVim.lsp.action["source.organizeImports"], {
			buffer = bufnr,
			desc = "[O]rganize Imports",
		})

		vim.keymap.set("n", "<leader>cu", LazyVim.lsp.action["source.removeUnused.ts"], {
			buffer = bufnr,
			desc = "Remove [U]nused Imports",
		})

		vim.keymap.set("n", "gD", function()
			local params = vim.lsp.util.make_position_params()
			LazyVim.lsp.execute({
				command = "typescript.goToSourceDefinition",
				arguments = { params.textDocument.uri, params.position },
				open = true,
			})
		end, { buffer = bufnr, desc = "Goto Source Definition" })

		vim.keymap.set("n", "gR", function()
			LazyVim.lsp.execute({
				command = "typescript.findAllFileReferences",
				arguments = { vim.uri_from_bufnr(0) },
				open = true,
			})
		end, { buffer = bufnr, desc = "File References" })

		vim.keymap.set("n", "<leader>cV", function()
			LazyVim.lsp.execute({
				command = "typescript.selectTypeScriptVersion",
			})
		end, { buffer = bufnr, desc = "Select TypeScript Version" })
	end,
}
