local config_files = { ".oxlintrc.json", "oxlint.config.ts" }

---@type vim.lsp.Config
return {
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_markers = {
		".oxlintrc.json",
		"oxlint.config.ts",
		"oxlint.json",
	},
	on_attach = function(client, bufnr)
		-- oxlint LSP has native file watching but TS config hot-reload doesn't
		-- pick up changes (jiti cache issue). LspRestart forces a clean re-evaluation.
		local root_dir = client.root_dir
		if not root_dir then
			return
		end

		local group = vim.api.nvim_create_augroup("oxlint_config_watch_" .. client.id, { clear = true })
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = group,
			pattern = vim.tbl_map(function(f)
				return root_dir .. "/" .. f
			end, config_files),
			callback = function()
				vim.schedule(function()
					vim.cmd("LspRestart oxlint")
				end)
			end,
		})
	end,
}
