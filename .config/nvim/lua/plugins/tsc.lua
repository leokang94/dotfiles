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

local function notify_directory_change(event)
	vim.notify("Current directory changed, tsc => " .. M.find_tsc_bin(), vim.log.levels.INFO)
end

-- -- Neovim이 시작할 때 현재 디렉토리에 대한 알림을 설정
-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	callback = function()
-- 		local current_dir = vim.fn.getcwd()
-- 		vim.notify("Current directory: " .. current_dir, vim.log.levels.INFO)
-- 	end,
-- })

-- 디렉토리 변경 이벤트를 설정
vim.api.nvim_create_autocmd("DirChanged", {
	callback = function(event)
		-- notify_directory_change(event)
		-- vim.cmd("Lazy reload tsc.nvim")
	end,
})

return {
	"dmmulroy/tsc.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("tsc").setup({
			bin_path = M.find_tsc_bin(),
			auto_start_watch_mode = true,
			use_trouble_qflist = true,
			auto_open_qflist = true,
			auto_close_qflist = true,
			use_diagnostics = true,
			flags = {
				watch = true,
			},
		})
	end,
}
