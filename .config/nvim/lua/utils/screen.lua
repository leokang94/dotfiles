local function is_vsplit()
	local width = vim.o.columns
	local height = vim.o.lines
	return width > height * 3
end

return {
	is_vsplit = is_vsplit,
}
