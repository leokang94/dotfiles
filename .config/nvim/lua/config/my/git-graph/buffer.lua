local M = {}
local git = require("config.my.git-graph.git")
local highlight = require("config.my.git-graph.highlight")

--- 라인에서 커밋 해시 추출
---@param line string 라인 텍스트
---@return string|nil hash 커밋 해시 (7자리 이상)
local function extract_hash_from_line(line)
	-- graph 문자들 후에 나오는 7-40자리 hex 문자열을 찾음
	-- 예: "* abc1234 ..." 또는 "| * abc1234 ..."
	local hash = line:match("[%*|/\\%s]+([0-9a-f]+)%s")
	if hash and #hash >= 7 then
		return hash
	end
	return nil
end

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
---@param limit? number 가져올 커밋 개수
---@param skip? number 건너뛸 커밋 개수
function M.render_git_log(buf, limit, skip)
	if not vim.api.nvim_buf_is_valid(buf) then
		return {}
	end

	-- git log 가져오기
	local lines = git.get_graph_log(limit, skip)

	-- modifiable 설정
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

	-- ANSI 색상 코드 파싱 및 하이라이트 정보 수집
	local clean_lines = {}
	local all_highlights = {}
	local line_to_hash = {}
	local current_hash = nil

	for i, line in ipairs(lines) do
		local clean_line, highlights = highlight.parse_ansi_line(line)
		table.insert(clean_lines, clean_line)
		all_highlights[i] = highlights

		-- 해시 추출 및 매핑
		local hash = extract_hash_from_line(clean_line)
		if hash then
			current_hash = hash
		end
		if current_hash then
			line_to_hash[i] = current_hash
		end
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

	return line_to_hash
end

--- Git log를 버퍼 끝에 추가
---@param buf number 렌더링할 버퍼 번호
---@param limit number 가져올 커밋 개수
---@param skip number 건너뛸 커밋 개수
---@param prev_last_hash? string 이전 마지막 해시 (연속성 유지)
---@return boolean success 추가 성공 여부
function M.append_git_log(buf, limit, skip, prev_last_hash)
	if not vim.api.nvim_buf_is_valid(buf) then
		return false, {}
	end

	-- git log 가져오기
	local lines = git.get_graph_log(limit, skip)

	-- 더 이상 로그가 없으면 false 반환
	if #lines == 0 then
		return false, {}
	end

	-- 현재 버퍼의 마지막 라인 번호
	local last_line = vim.api.nvim_buf_line_count(buf)

	-- modifiable 설정
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

	-- ANSI 색상 코드 파싱 및 하이라이트 정보 수집
	local clean_lines = {}
	local all_highlights = {}
	local line_to_hash = {}
	local current_hash = prev_last_hash

	for i, line in ipairs(lines) do
		local clean_line, highlights = highlight.parse_ansi_line(line)
		table.insert(clean_lines, clean_line)
		all_highlights[last_line + i] = highlights

		-- 해시 추출 및 매핑
		local hash = extract_hash_from_line(clean_line)
		if hash then
			current_hash = hash
		end
		if current_hash then
			line_to_hash[last_line + i] = current_hash
		end
	end

	-- 버퍼 끝에 내용 추가
	vim.api.nvim_buf_set_lines(buf, last_line, last_line, false, clean_lines)

	-- 하이라이트 적용
	local ns_id = vim.api.nvim_create_namespace("git-graph-highlight")

	for line_num, highlights in pairs(all_highlights) do
		for _, hl in ipairs(highlights) do
			vim.api.nvim_buf_add_highlight(buf, ns_id, hl.group, line_num - 1, hl.col_start, hl.col_end)
		end
	end

	-- 읽기 전용 설정
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	vim.api.nvim_set_option_value("readonly", true, { buf = buf })

	return true, line_to_hash
end

return M
