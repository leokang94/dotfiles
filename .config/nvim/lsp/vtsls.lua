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

-- Function to read VSCode settings and extract TypeScript configurations
local function get_vscode_typescript_settings(root_dir)
	local vscode_settings_path = root_dir .. "/.vscode/settings.json"

	-- Check if .vscode/settings.json exists
	if vim.fn.filereadable(vscode_settings_path) == 0 then
		return {}
	end

	-- Read and parse the JSON file
	local ok, content = pcall(vim.fn.readfile, vscode_settings_path)
	if not ok then
		return {}
	end

	local json_str = table.concat(content, "\n")
	local ok_decode, vscode_settings = pcall(vim.json.decode, json_str)
	if not ok_decode then
		return {}
	end

	-- Extract TypeScript related settings
	local typescript_settings = {}
	for key, value in pairs(vscode_settings) do
		if key:match("^typescript%.") then
			-- Convert "typescript.preferences.something" to nested table structure
			local parts = vim.split(key, "%.")
			if #parts >= 2 then
				local current = typescript_settings
				for i = 2, #parts - 1 do
					if not current[parts[i]] then
						current[parts[i]] = {}
					end
					current = current[parts[i]]
				end
				current[parts[#parts]] = value
			end
		end
	end

	return typescript_settings
end

---@type vim.lsp.Config
return {
	before_init = function(_, config)
		-- Read VSCode settings when a new config is created
		local vscode_ts_settings = get_vscode_typescript_settings(config.root_dir)

		vim.notify(vim.inspect(vscode_ts_settings), vim.log.levels.DEBUG, {
			title = "VSCode TypeScript Settings",
		})

		-- Merge VSCode TypeScript settings with default settings
		if next(vscode_ts_settings) then
			config.settings.typescript = vim.tbl_deep_extend("keep", settings, vscode_ts_settings)
		end
	end,

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
		typescript = settings,
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
