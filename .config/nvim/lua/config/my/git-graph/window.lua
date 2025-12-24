local M = {}
local get_is_vsplit = require("utils.screen").is_vsplit

local WINDOW_SIZE = {
	VSPLIT_WIDTH_RATIO = 0.7,
	HSPLIT_HEIGHT_RATIO = 0.8,
}

--- 윈도우 크기를 설정된 비율로 조정
---@param tab_info table 탭 정보 테이블
---@param is_vsplit boolean vsplit 여부
function M.apply_window_sizes(tab_info, is_vsplit)
	local width = vim.o.columns
	local height = vim.o.lines

	if not tab_info or not vim.api.nvim_win_is_valid(tab_info.graph_win) then
		return
	end

	if is_vsplit then
		vim.api.nvim_win_set_width(tab_info.graph_win, math.floor(width * WINDOW_SIZE.VSPLIT_WIDTH_RATIO))
	else
		vim.api.nvim_win_set_height(tab_info.graph_win, math.floor(height * WINDOW_SIZE.HSPLIT_HEIGHT_RATIO))
	end
end

--- 화면 크기 변경 처리 (split 방향 변경 포함)
---@param git_graph_tabs table 모든 git graph 탭 정보
---@param tab_id number 탭 ID
function M.handle_screen_resize(git_graph_tabs, tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	local new_is_vsplit = get_is_vsplit()

	-- split 방향 변경이 필요한 경우
	if new_is_vsplit ~= tab_info.is_vsplit then
		-- 현재 포커스 저장
		local current_win = vim.api.nvim_get_current_win()
		local current_buf = vim.api.nvim_win_get_buf(current_win)
		local was_in_terminal = (current_buf == tab_info.terminal_buf)

		-- 모든 윈도우 닫기 (하나만 남기기)
		local windows = vim.api.nvim_tabpage_list_wins(tab_id)
		for i = 2, #windows do
			if vim.api.nvim_win_is_valid(windows[i]) then
				vim.api.nvim_win_close(windows[i], false)
			end
		end

		-- 첫 번째 윈도우에 터미널 버퍼 설정
		local first_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(first_win, tab_info.terminal_buf)

		-- 새로운 split 생성
		local split_cmd = new_is_vsplit and "vsplit" or "split"
		vim.cmd(split_cmd)

		-- 두 번째 윈도우에 graph 버퍼 설정
		local second_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(second_win, tab_info.graph_buf)

		-- 탭 정보 업데이트
		tab_info.is_vsplit = new_is_vsplit
		tab_info.terminal_win = first_win
		tab_info.graph_win = second_win

		-- 포커스 복원
		vim.api.nvim_set_current_win(was_in_terminal and first_win or second_win)
	end

	-- 윈도우 크기 적용
	M.apply_window_sizes(tab_info, tab_info.is_vsplit)
end

return M
