local M = {}
local git = require("config.my.git-graph.git")
local highlight = require("config.my.git-graph.highlight")

--- 새로운 scratch 버퍼 생성
---@return number buf 생성된 버퍼 번호
function M.create_buffer()
	local buf = vim.api.nvim_create_buf(false, true) -- nofile, scratch buffer

	-- 버퍼 옵션 설정
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("filetype", "git-graph", { buf = buf })

	return buf
end

--- Git log를 버퍼에 렌더링
---@param buf number 렌더링할 버퍼 번호
function M.render_git_log(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	-- git log 가져오기
	local lines = git.get_graph_log()

	-- modifiable 설정
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

	-- ANSI 색상 코드 파싱 및 하이라이트 정보 수집
	local clean_lines = {}
	local all_highlights = {}

	for i, line in ipairs(lines) do
		local clean_line, highlights = highlight.parse_ansi_line(line)
		table.insert(clean_lines, clean_line)
		all_highlights[i] = highlights
	end

	-- 버퍼에 내용 설정
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, clean_lines)

	-- 하이라이트 적용
	local ns_id = vim.api.nvim_create_namespace("git-graph-highlight")
	vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

	for line_num, highlights in pairs(all_highlights) do
		for _, hl in ipairs(highlights) do
			vim.api.nvim_buf_add_highlight(buf, ns_id, hl.group, line_num - 1, hl.col_start, hl.col_end)
		end
	end

	-- 읽기 전용 설정
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	vim.api.nvim_set_option_value("readonly", true, { buf = buf })
end

return M
