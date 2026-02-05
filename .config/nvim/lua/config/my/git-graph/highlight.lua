local M = {}

-- ANSI 색상 코드 -> Highlight 그룹 매핑
local ansi_to_hl = {
	["0"] = nil, -- reset
	["33"] = "GitGraphYellow", -- yellow
	["90"] = "GitGraphBrightBlack", -- bright black (gray)
	["97"] = "GitGraphBrightWhite", -- bright white
	["36"] = "GitGraphCyan", -- cyan
	["32"] = "GitGraphGreen", -- green
	["31"] = "GitGraphRed", -- red
	["35"] = "GitGraphMagenta", -- magenta
	["34"] = "GitGraphBlue", -- blue
	["91"] = "GitGraphBrightRed", -- bright red
	["92"] = "GitGraphBrightGreen", -- bright green
	["93"] = "GitGraphBrightYellow", -- bright yellow
	["94"] = "GitGraphBrightBlue", -- bright blue
	["95"] = "GitGraphBrightMagenta", -- bright magenta
	["96"] = "GitGraphBrightCyan", -- bright cyan
}

--- Highlight 그룹 정의
function M.setup()
	-- Dracula 테마 색상 사용
	vim.api.nvim_set_hl(0, "GitGraphYellow", { fg = "#f1fa8c", ctermfg = 228 })
	vim.api.nvim_set_hl(0, "GitGraphBrightBlack", { fg = "#6272a4", ctermfg = 243 })
	vim.api.nvim_set_hl(0, "GitGraphBrightWhite", { fg = "#f8f8f2", ctermfg = 231 })
	vim.api.nvim_set_hl(0, "GitGraphCyan", { fg = "#8be9fd", ctermfg = 51 })
	vim.api.nvim_set_hl(0, "GitGraphGreen", { fg = "#50fa7b", ctermfg = 46 })
	vim.api.nvim_set_hl(0, "GitGraphRed", { fg = "#ff5555", ctermfg = 203 })
	vim.api.nvim_set_hl(0, "GitGraphMagenta", { fg = "#ff79c6", ctermfg = 212 })
	vim.api.nvim_set_hl(0, "GitGraphBlue", { fg = "#bd93f9", ctermfg = 141 })
	vim.api.nvim_set_hl(0, "GitGraphBrightRed", { fg = "#ff6e6e", ctermfg = 203 })
	vim.api.nvim_set_hl(0, "GitGraphBrightGreen", { fg = "#69ff94", ctermfg = 46 })
	vim.api.nvim_set_hl(0, "GitGraphBrightYellow", { fg = "#ffffa5", ctermfg = 229 })
	vim.api.nvim_set_hl(0, "GitGraphBrightBlue", { fg = "#d6acff", ctermfg = 141 })
	vim.api.nvim_set_hl(0, "GitGraphBrightMagenta", { fg = "#ff92df", ctermfg = 213 })
	vim.api.nvim_set_hl(0, "GitGraphBrightCyan", { fg = "#a4ffff", ctermfg = 51 })

	-- 체크 표시용 하이라이트
	vim.api.nvim_set_hl(0, "GitGraphCheck", { fg = "#50fa7b", ctermfg = 46 })

	-- 현재 보고있는 커밋 해시 강조 (빨간색 + bold + 배경)
	-- 배경색을 지정해서 기존 ANSI 노란색을 완전히 덮어쓰기
	vim.api.nvim_set_hl(0, "GitGraphCurrentHash", { fg = "#ff5555", bg = "#282a36", bold = true, ctermfg = 203 })
	-- 현재 보고있는 커밋 메시지/데코레이션 강조 (bold)
	vim.api.nvim_set_hl(0, "GitGraphCurrentCommit", { bold = true })

	-- 체크 Sign 정의
	vim.fn.sign_define("GitGraphCheck", { text = "✓", texthl = "GitGraphCheck" })
end

--- ANSI 이스케이프 시퀀스를 파싱하고 하이라이트 정보 반환
---@param line string 원본 라인 (ANSI 코드 포함)
---@return string clean_line ANSI 코드가 제거된 라인
---@return table highlights 하이라이트 정보 배열 {group, col_start, col_end}
function M.parse_ansi_line(line)
	local highlights = {}
	local clean_line = ""
	local col = 0
	local current_hl = nil
	local hl_start = 0

	-- ANSI 이스케이프 시퀀스와 일반 텍스트를 분리
	local i = 1
	while i <= #line do
		-- ANSI 이스케이프 시퀀스 찾기: ESC[...m
		local esc_start, esc_end, codes = line:find("\27%[([0-9;]*)m", i)

		if esc_start then
			-- 이스케이프 시퀀스 전의 텍스트 추가
			if esc_start > i then
				local text = line:sub(i, esc_start - 1)
				clean_line = clean_line .. text

				-- 현재 하이라이트가 있으면 적용
				if current_hl then
					table.insert(highlights, {
						group = current_hl,
						col_start = hl_start,
						col_end = col + #text,
					})
				end

				col = col + #text
			end

			-- ANSI 코드 파싱
			if codes == "" or codes == "0" then
				-- Reset
				current_hl = nil
			else
				-- 세미콜론으로 구분된 코드 처리
				for code in codes:gmatch("[^;]+") do
					local hl_group = ansi_to_hl[code]
					if hl_group then
						current_hl = hl_group
						hl_start = col
						break -- 첫 번째 유효한 색상 코드만 사용
					end
				end
			end

			i = esc_end + 1
		else
			-- 남은 텍스트 처리
			local text = line:sub(i)
			clean_line = clean_line .. text

			if current_hl and #text > 0 then
				table.insert(highlights, {
					group = current_hl,
					col_start = hl_start,
					col_end = col + #text,
				})
			end

			break
		end
	end

	return clean_line, highlights
end

return M
