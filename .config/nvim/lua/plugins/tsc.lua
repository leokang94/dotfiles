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

local has_executed_once = false

-- 자동 명령 그룹을 생성합니다 (선택 사항이지만 추천됨)
local ts_augroup = vim.api.nvim_create_augroup("TsFilesGroup", { clear = true })

return {
	"dmmulroy/tsc.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("tsc").setup({
			bin_path = M.find_tsc_bin(),
			-- auto_start_watch_mode = true,
			use_trouble_qflist = true,
			auto_open_qflist = true,
			auto_close_qflist = true,
			use_diagnostics = true,
			-- flags = {
			-- 	watch = true,
			-- },
		})

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*.{ts,tsx}",
			group = ts_augroup,
			callback = function()
				if not has_executed_once then
					vim.cmd("TSC")

					has_executed_once = true
				end
			end,
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.{ts,tsx}",
			group = ts_augroup,
			callback = function()
				vim.cmd("TSC")
			end,
		})
	end,
}
