vim.lsp.config("*", {
	capabilities = {
		workspace = {
			fileOperations = { didRename = true, willRename = true },
		},
		textDocument = {
			semanticTokens = { multilineTokenSupport = true },
		},
	},
	root_markers = { ".git" },
})

-- Automatically enable all LSP servers found in lsp/ directory
local function get_lsp_servers()
	local lsp_dir = vim.fn.stdpath("config") .. "/lsp"
	local servers = {}

	-- Check if lsp directory exists
	if vim.fn.isdirectory(lsp_dir) == 0 then
		return servers
	end

	-- Get all .lua files in lsp directory
	local files = vim.fn.glob(lsp_dir .. "/*.lua", false, true)

	for _, file in ipairs(files) do
		-- Extract filename without extension
		local server_name = vim.fn.fnamemodify(file, ":t:r")
		table.insert(servers, server_name)
	end

	return servers
end

-- Enable all discovered LSP servers
local lsp_servers = get_lsp_servers()
if #lsp_servers > 0 then
	vim.lsp.enable(lsp_servers)
end

-- vim.diagnostic.config({
-- 	signs = {
-- 		Error = " ",
-- 		Warn = " ",
-- 		Hint = "󰠠 ",
-- 		Info = " ",
-- 	},
-- 	virtual_lines = true,
-- 	virtual_text = false,
-- 	underline = true,
-- 	update_in_insert = true,
-- 	severity_sort = true,
-- 	float = {
-- 		border = "rounded",
-- 	},
-- })
