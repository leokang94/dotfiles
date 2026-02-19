local function korean_star()
	-- 현재 커서 위치의 라인과 컬럼 가져오기
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] -- 0-indexed byte offset

	-- 한글 + 영문/숫자/언더스코어를 word 문자로 취급
	-- UTF-8에서 한글은 3바이트이므로 byte 단위로 처리
	local function is_word_char(char)
		-- 한글 완성형 (U+AC00–U+D7A3), 자모 등
		local byte = string.byte(char, 1)
		if byte and byte >= 0x80 then
			return true
		end -- 모든 멀티바이트 문자
		if char:match("[%w_]") then
			return true
		end
		return false
	end

	-- 라인을 UTF-8 문자 배열로 분해
	local chars = {}
	local positions = {} -- 각 문자의 byte offset
	local i = 1
	while i <= #line do
		local byte = string.byte(line, i)
		local char_len = 1
		if byte >= 0xF0 then
			char_len = 4
		elseif byte >= 0xE0 then
			char_len = 3
		elseif byte >= 0xC0 then
			char_len = 2
		end
		table.insert(chars, line:sub(i, i + char_len - 1))
		table.insert(positions, i - 1) -- 0-indexed
		i = i + char_len
	end

	-- 커서가 위치한 문자 인덱스 찾기
	local cursor_idx = nil
	for idx, pos in ipairs(positions) do
		if pos <= col and (positions[idx + 1] == nil or positions[idx + 1] > col) then
			cursor_idx = idx
			break
		end
	end

	if not cursor_idx or not is_word_char(chars[cursor_idx]) then
		-- 한글/word 문자가 아니면 기본 * 동작
		vim.cmd("normal! *")
		return
	end

	-- 앞뒤로 word 경계 찾기
	local start_idx = cursor_idx
	while start_idx > 1 and is_word_char(chars[start_idx - 1]) do
		start_idx = start_idx - 1
	end
	local end_idx = cursor_idx
	while end_idx < #chars and is_word_char(chars[end_idx + 1]) do
		end_idx = end_idx + 1
	end

	-- 단어 추출
	local word = table.concat(chars, "", start_idx, end_idx)

	if word == "" then
		return
	end

	-- 검색 패턴 설정 (특수문자 escape)
	local escaped = vim.fn.escape(word, "\\/.*^$[]~")
	vim.fn.setreg("/", escaped)
	vim.opt.hlsearch = true

	-- 다음 매치로 이동
	local ok, err = pcall(function()
		vim.cmd("normal! n")
	end)
	if not ok then
		vim.notify("Pattern not found: " .. word, vim.log.levels.INFO)
	end

	-- 검색어를 statusline 등에 표시 (선택사항)
	vim.api.nvim_echo({ { "/" .. escaped, "IncSearch" } }, false, {})
end

vim.keymap.set("n", "*", korean_star, { desc = "Korean-aware * search" })
vim.keymap.set("n", "#", function()
	korean_star()
	-- 방향 반전: N 대신 N을 사용
	vim.cmd("normal! N")
end, { desc = "Korean-aware # search" })
