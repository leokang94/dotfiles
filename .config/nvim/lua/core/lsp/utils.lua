local M = {}

M.get_monorepo_root = function(startpath)
	return vim.fs.dirname(
		vim.fs.find(
			{ ".git", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb" },
			{ path = startpath, upward = true }
		)[1]
	)
end

---@type fun(bufnr: number, on_dir: fun(dir: string))
M.get_root_dir = function(bufnr, on_dir)
	local full_path = vim.api.nvim_buf_get_name(bufnr)
	local root_path = M.get_monorepo_root(full_path)

	if root_path and vim.fn.isdirectory(root_path) == 1 then
		on_dir(root_path)
	else
		on_dir(vim.fs.dirname(full_path))
	end
end

-- Function to read VSCode settings and extract configurations
M.get_vscode_settings = function(root_dir, extract_target)
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

	-- Extract settings based on target prefix
	local target_pattern = "^" .. extract_target:gsub("%.", "%%.") .. "%."
	local extracted_settings = {}

	for key, value in pairs(vscode_settings) do
		if key:match(target_pattern) then
			local parts = vim.split(key, "%.")
			if #parts >= 2 then
				local current = extracted_settings
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

	return extracted_settings
end

--- Resolve project-local binary, with Yarn PnP support.
--- Priority: node_modules/.bin → Yarn PnP (yarn exec) → PATH (Mason fallback)
---@param bin_name string The binary name (e.g. "biome", "oxlint")
---@param root_dir string? The project root directory
---@return string[] cmd_prefix Command prefix; caller appends tool-specific args
M.resolve_local_cmd = function(bin_name, root_dir)
	if root_dir then
		-- 1. node_modules/.bin (npm, pnpm, yarn classic, yarn berry node_modules linker)
		local local_bin = root_dir .. "/node_modules/.bin/" .. bin_name
		if vim.uv.fs_stat(local_bin) then
			return { local_bin }
		end

		-- 2. Yarn PnP (.pnp.cjs or .pnp.js)
		if vim.uv.fs_stat(root_dir .. "/.pnp.cjs") or vim.uv.fs_stat(root_dir .. "/.pnp.js") then
			return { "yarn", "exec", bin_name }
		end
	end

	-- 3. Fallback to PATH (Mason-installed)
	return { bin_name }
end

return M
