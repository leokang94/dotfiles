local LspUtils = require("core.lsp.utils")

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

-- Servers that should prefer project-local node_modules binaries.
-- key: server name (matching lsp/{name}.lua), value: cmd args after the binary
local local_bin_servers = {
	biome = { "lsp-proxy" },
	oxlint = { "--lsp" },
}

-- Automatically enable all LSP servers found in lsp/ directory
-- Local-bin servers are excluded from vim.lsp.enable and handled separately.
local function get_lsp_servers()
	local lsp_dir = vim.fn.stdpath("config") .. "/lsp"
	local auto_servers = {}
	local local_server_configs = {}

	if vim.fn.isdirectory(lsp_dir) == 0 then
		return auto_servers, local_server_configs
	end

	local files = vim.fn.glob(lsp_dir .. "/*.lua", false, true)

	for _, file in ipairs(files) do
		local server_name = vim.fn.fnamemodify(file, ":t:r")

		if local_bin_servers[server_name] then
			local ok, config = pcall(dofile, file)
			if ok and config then
				config._cmd_args = local_bin_servers[server_name]
				local_server_configs[server_name] = config
			end
		else
			table.insert(auto_servers, server_name)
		end
	end

	return auto_servers, local_server_configs
end

local auto_servers, local_server_configs = get_lsp_servers()

-- Enable standard LSP servers (static cmd via vim.lsp.enable)
if #auto_servers > 0 then
	vim.lsp.enable(auto_servers)
end

-- Enable local-bin servers (dynamic cmd via vim.lsp.start)
for name, config in pairs(local_server_configs) do
	if config.filetypes then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = config.filetypes,
			group = vim.api.nvim_create_augroup("lsp_local_" .. name, { clear = true }),
			callback = function(args)
				local fname = vim.api.nvim_buf_get_name(args.buf)
				local root_markers = config.root_markers or { "package.json" }
				local found = vim.fs.find(root_markers, { path = fname, upward = true })[1]

				if not found then
					return
				end

				local root_dir = vim.fs.dirname(found)
				local cmd = vim.list_extend(LspUtils.resolve_local_cmd(name, root_dir), config._cmd_args)

				vim.lsp.start({
					name = name,
					cmd = cmd,
					root_dir = root_dir,
				})
			end,
		})
	end
end
