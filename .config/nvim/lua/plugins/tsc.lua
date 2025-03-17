local M = {}

M.find_tsc_bin = function()
	local node_modules_tsc_binary = vim.fn.findfile("node_modules/.bin/tsc", ".;")

	if node_modules_tsc_binary == "" then
		node_modules_tsc_binary = vim.fn.findfile(".yarn/sdks/typescript/bin/tsc", ".;")
	end

	if node_modules_tsc_binary ~= "" then
		return node_modules_tsc_binary
	end

	return "tsc"
end

return {
	"dmmulroy/tsc.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		bin_path = M.find_tsc_bin(),
		auto_start_watch_mode = true,
		use_trouble_qflist = true,
		auto_open_qflist = true,
		auto_close_qflist = true,
		use_diagnostics = true,
		flags = {
			watch = true,
		},
	},
}
