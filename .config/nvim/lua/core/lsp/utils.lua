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

return M
