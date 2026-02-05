local M = {}

local FLOAT_SIZE = {
	WIDTH_RATIO = 0.8,
	HEIGHT_RATIO = 0.8,
}

--- Float window 설정 계산 (화면 중앙 80%x80%)
---@return table float window config
function M.get_float_config()
	local width = vim.o.columns
	local height = vim.o.lines

	local float_width = math.floor(width * FLOAT_SIZE.WIDTH_RATIO)
	local float_height = math.floor(height * FLOAT_SIZE.HEIGHT_RATIO)

	local row = math.floor((height - float_height) / 2)
	local col = math.floor((width - float_width) / 2)

	return {
		relative = "editor",
		width = float_width,
		height = float_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}
end

--- Float window 생성
---@param buf number 버퍼 번호
---@return number|nil float window ID
function M.open_float_window(buf)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return nil
	end

	local config = M.get_float_config()
	local win = vim.api.nvim_open_win(buf, true, config)

	return win
end

--- Float window 닫기
---@param win number 윈도우 ID
function M.close_float_window(win)
	if M.is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
end

--- 윈도우 유효성 검사
---@param win number|nil 윈도우 ID
---@return boolean
function M.is_valid(win)
	return win ~= nil and vim.api.nvim_win_is_valid(win)
end

--- Float window 크기 재조정
---@param win number 윈도우 ID
function M.resize_float_window(win)
	if not M.is_valid(win) then
		return
	end

	local config = M.get_float_config()
	vim.api.nvim_win_set_config(win, config)
end

return M
