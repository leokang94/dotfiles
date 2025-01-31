local M = {}

function M.is_vsplit()
	local width = vim.o.columns
	local height = vim.o.lines
	return width > height * 3
end

return M
