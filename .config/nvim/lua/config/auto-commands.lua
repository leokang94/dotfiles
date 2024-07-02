-- 현재 디렉토리 변경 시 알림을 설정하는 함수
local function notify_directory_change(event)
	local new_dir = event["file"] -- 변경된 새로운 디렉토리 경로
	vim.notify("Current directory changed to: " .. new_dir, vim.log.levels.INFO)
end

-- Neovim이 시작할 때 현재 디렉토리에 대한 알림을 설정
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local current_dir = vim.fn.getcwd()
		vim.notify("Current directory: " .. current_dir, vim.log.levels.INFO)
	end,
})

-- 디렉토리 변경 이벤트를 설정
vim.api.nvim_create_autocmd("DirChanged", {
	callback = function(event)
		notify_directory_change(event)
	end,
})
