local M = {}

-- 지연 로딩을 위한 모듈 참조
local buffer, watcher, git, highlight, float
local get_is_vsplit = require("utils.screen").is_vsplit

-- 모듈 레벨 상태
local git_graph_tabs = {}
local DEBOUNCE_DELAY_MS = 100
local update_scheduled = {}
local resize_scheduled = false

-- Diff 패널 크기 설정
local DIFF_SIZE = {
	VSPLIT_WIDTH_RATIO = 0.7, -- vsplit 시 diff 패널 너비 비율
	HSPLIT_HEIGHT_RATIO = 0.7, -- hsplit 시 diff 패널 높이 비율
}

-- 무한 스크롤 설정
local INITIAL_LOAD_COUNT = 500 -- 초기 로드 개수
local LOAD_MORE_COUNT = 500 -- 추가 로드 개수
local LOAD_MORE_THRESHOLD = 50 -- 끝에서 N줄 전에 로드

--- 모듈 지연 로딩
local function load_modules()
	if not buffer then
		highlight = require("config.my.git-graph.highlight")
		buffer = require("config.my.git-graph.buffer")
		watcher = require("config.my.git-graph.watcher")
		git = require("config.my.git-graph.git")
		float = require("config.my.git-graph.float")
	end
end

--- 플러그인 설정 초기화
function M.setup()
	load_modules()

	-- Highlight 그룹 설정
	highlight.setup()

	-- Autocmd 설정
	vim.api.nvim_create_autocmd("VimResized", {
		pattern = "*",
		callback = function()
			M.debounced_resize()
		end,
	})

	vim.api.nvim_create_autocmd("WinResized", {
		pattern = "*",
		callback = function()
			M.debounced_resize()
		end,
	})

	vim.api.nvim_create_autocmd("TabClosed", {
		pattern = "*",
		callback = function()
			-- TabClosed 이벤트는 탭 ID를 직접 제공하지 않으므로,
			-- 존재하지 않는 탭들을 정리
			local existing_tabs = vim.api.nvim_list_tabpages()
			for tab_id in pairs(git_graph_tabs) do
				if not vim.tbl_contains(existing_tabs, tab_id) then
					M.cleanup_tab(tab_id)
				end
			end
		end,
	})

	-- Vim 종료 전 git-graph 탭 정리 (세션에 빈 탭이 남지 않도록)
	vim.api.nvim_create_autocmd("VimLeavePre", {
		pattern = "*",
		callback = function()
			for tab_id, _ in pairs(git_graph_tabs) do
				if vim.api.nvim_tabpage_is_valid(tab_id) then
					vim.api.nvim_set_current_tabpage(tab_id)
					vim.cmd("tabclose")
				end
				M.cleanup_tab(tab_id)
			end
		end,
	})

	-- 파일 저장 또는 포커스 복귀 시 uncommitted changes 업데이트
	vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
		pattern = "*",
		callback = function()
			for tab_id, _ in pairs(git_graph_tabs) do
				M.update_git_log(tab_id)
			end
		end,
	})

	-- WinEnter 이벤트로 diff 윈도우 focus 시 dim 처리
	vim.api.nvim_create_autocmd("WinEnter", {
		pattern = "*",
		callback = function()
			local current_tab = vim.api.nvim_get_current_tabpage()
			local tab_info = git_graph_tabs[current_tab]

			if tab_info and tab_info.diff.visible then
				local current_win = vim.api.nvim_get_current_win()
				local current_buf = vim.api.nvim_win_get_buf(current_win)

				if current_buf == tab_info.diff.buf then
					-- diff 윈도우로 이동: dim 적용
					M.highlight_current_hash(current_tab)
				elseif current_buf == tab_info.graph_buf then
					-- graph 윈도우로 이동: dim 해제
					M.clear_current_hash_highlight(current_tab)
				end
			end
		end,
	})
end

--- Git log 업데이트 (debounce 적용)
---@param tab_id number 탭 ID
function M.update_git_log(tab_id)
	-- Debounce: 너무 자주 업데이트되지 않도록
	if update_scheduled[tab_id] then
		return
	end

	update_scheduled[tab_id] = true
	vim.defer_fn(function()
		local tab_info = git_graph_tabs[tab_id]
		if tab_info and vim.api.nvim_buf_is_valid(tab_info.graph_buf) then
			-- 초기 로드 개수로 렌더링
			local line_to_hash, uncommitted_line_count = buffer.render_git_log(tab_info.graph_buf, INITIAL_LOAD_COUNT, 0)
			-- 로드된 개수 초기화
			tab_info.loaded_count = INITIAL_LOAD_COUNT
			tab_info.line_to_hash = line_to_hash
			tab_info.uncommitted_line_count = uncommitted_line_count
		end
		update_scheduled[tab_id] = nil
	end, DEBOUNCE_DELAY_MS)
end

--- 추가 로그 로드 (무한 스크롤)
---@param tab_id number 탭 ID
local function load_more_logs(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not vim.api.nvim_buf_is_valid(tab_info.graph_buf) then
		return
	end

	-- 이미 로드 중이면 무시
	if tab_info.loading then
		return
	end

	tab_info.loading = true

	-- 이전 마지막 라인의 해시를 찾아서 전달 (연속성 유지)
	local prev_last_hash = nil
	local total_lines = vim.api.nvim_buf_line_count(tab_info.graph_buf)
	if tab_info.line_to_hash and tab_info.line_to_hash[total_lines] then
		prev_last_hash = tab_info.line_to_hash[total_lines]
	end

	-- 추가 로그 로드
	local success, new_line_to_hash =
		buffer.append_git_log(tab_info.graph_buf, LOAD_MORE_COUNT, tab_info.loaded_count, prev_last_hash)

	if success then
		tab_info.loaded_count = tab_info.loaded_count + LOAD_MORE_COUNT
		-- 매핑 병합
		for line_num, hash in pairs(new_line_to_hash) do
			tab_info.line_to_hash[line_num] = hash
		end
	end

	tab_info.loading = false
end

--- 스크롤 위치 확인 및 추가 로드
---@param tab_id number 탭 ID
---@param buf number 버퍼 번호
local function check_scroll_position(tab_id, buf)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or tab_info.graph_buf ~= buf then
		return
	end

	-- 현재 커서 위치
	local cursor = vim.api.nvim_win_get_cursor(0)
	local current_line = cursor[1]

	-- 버퍼 총 라인 수
	local total_lines = vim.api.nvim_buf_line_count(buf)

	-- 끝에서 THRESHOLD 라인 이내면 추가 로드
	if total_lines - current_line <= LOAD_MORE_THRESHOLD then
		load_more_logs(tab_id)
	end
end

--- 터미널 버퍼 키맵 설정
---@param buf number 터미널 버퍼
---@param tab_id number 탭 ID
local function setup_terminal_keymaps(buf, tab_id)
	-- Terminal 모드에서 <C-t>로 숨기기
	vim.api.nvim_buf_set_keymap(buf, "t", "<C-t>", "", {
		noremap = true,
		silent = true,
		callback = function()
			M.hide_terminal(tab_id)
		end,
	})

	-- Terminal 모드에서 <C-q>로 완전히 닫기
	vim.api.nvim_buf_set_keymap(buf, "t", "<C-q>", "", {
		noremap = true,
		silent = true,
		callback = function()
			M.close_terminal(tab_id)
		end,
	})

	-- Normal 모드에서 <C-t>로 숨기기
	vim.api.nvim_buf_set_keymap(buf, "n", "<C-t>", "", {
		noremap = true,
		silent = true,
		callback = function()
			M.hide_terminal(tab_id)
		end,
	})

	-- Normal 모드에서 <C-q>로 완전히 닫기
	vim.api.nvim_buf_set_keymap(buf, "n", "<C-q>", "", {
		noremap = true,
		silent = true,
		callback = function()
			M.close_terminal(tab_id)
		end,
	})
end

--- Graph 버퍼 키맵 설정
---@param buf number graph 버퍼
---@param tab_id number 탭 ID
local function setup_graph_keymaps(buf, tab_id)
	-- Normal 모드에서 <C-t>로 터미널 토글
	vim.api.nvim_buf_set_keymap(buf, "n", "<C-t>", "", {
		noremap = true,
		silent = true,
		callback = function()
			M.toggle_terminal(tab_id)
		end,
	})

	-- Normal 모드에서 Enter로 커밋 diff 토글
	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
		noremap = true,
		silent = true,
		callback = function()
			M.toggle_diff_at_cursor(tab_id)
		end,
	})

	-- Visual 모드에서 Enter로 선택된 커밋들 diff 표시
	vim.api.nvim_buf_set_keymap(buf, "v", "<CR>", "", {
		noremap = true,
		silent = true,
		callback = function()
			M.show_diff_visual(tab_id)
		end,
	})

	-- Normal 모드에서 q로 diff 닫기 (diff가 열려있을 때) 또는 체크 해제
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		noremap = true,
		silent = true,
		callback = function()
			local tab_info = git_graph_tabs[tab_id]
			if tab_info then
				if tab_info.diff.visible then
					M.hide_diff(tab_id)
				elseif #tab_info.checked_commits > 0 then
					M.clear_checked_commits(tab_id)
				else
					-- diff가 없고 체크도 없으면 탭 닫기
					vim.cmd("tabclose")
				end
			end
		end,
	})

	-- Normal 모드에서 Tab으로 커밋 체크/언체크
	vim.api.nvim_buf_set_keymap(buf, "n", "<Tab>", "", {
		noremap = true,
		silent = true,
		callback = function()
			M.toggle_check_commit(tab_id)
		end,
	})

	-- Normal 모드에서 S-Tab으로 모든 체크 해제
	vim.api.nvim_buf_set_keymap(buf, "n", "<S-Tab>", "", {
		noremap = true,
		silent = true,
		callback = function()
			M.clear_checked_commits(tab_id)
		end,
	})
end

--- Float 터미널 표시
---@param tab_id number 탭 ID
function M.show_terminal(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	local terminal = tab_info.terminal

	-- 터미널 버퍼가 없거나 유효하지 않으면 새로 생성
	if not terminal.buf or not vim.api.nvim_buf_is_valid(terminal.buf) then
		terminal.buf = vim.api.nvim_create_buf(false, true)
		terminal.initialized = false
	end

	-- float window 열기
	terminal.float_win = float.open_float_window(terminal.buf)

	if terminal.float_win then
		-- 터미널이 초기화되지 않았으면 termopen 호출
		if not terminal.initialized then
			vim.fn.termopen(vim.o.shell)
			terminal.initialized = true
			-- 새 터미널에 키맵 설정
			setup_terminal_keymaps(terminal.buf, tab_id)
		end

		terminal.visible = true
		vim.cmd("startinsert")
	end
end

--- Float 터미널 숨기기 (버퍼 유지)
---@param tab_id number 탭 ID
function M.hide_terminal(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	local terminal = tab_info.terminal

	-- float window 닫기 (버퍼는 유지)
	if float.is_valid(terminal.float_win) then
		float.close_float_window(terminal.float_win)
		terminal.float_win = nil
		terminal.visible = false

		-- graph 윈도우로 포커스 이동
		if vim.api.nvim_win_is_valid(tab_info.graph_win) then
			vim.api.nvim_set_current_win(tab_info.graph_win)
		end
	end
end

--- Float 터미널 완전히 닫기 (버퍼 삭제)
---@param tab_id number 탭 ID
function M.close_terminal(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	local terminal = tab_info.terminal

	-- float window 닫기
	if float.is_valid(terminal.float_win) then
		float.close_float_window(terminal.float_win)
	end

	-- 터미널 버퍼 삭제
	if terminal.buf and vim.api.nvim_buf_is_valid(terminal.buf) then
		vim.api.nvim_buf_delete(terminal.buf, { force = true })
	end

	-- 터미널 상태 초기화
	terminal.buf = nil
	terminal.float_win = nil
	terminal.visible = false
	terminal.initialized = false

	-- graph 윈도우로 포커스 이동
	if vim.api.nvim_win_is_valid(tab_info.graph_win) then
		vim.api.nvim_set_current_win(tab_info.graph_win)
	end
end

--- Float 터미널 토글
---@param tab_id number 탭 ID
function M.toggle_terminal(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	if tab_info.terminal.visible then
		M.hide_terminal(tab_id)
	else
		M.show_terminal(tab_id)
	end
end

--- Diff 터미널 버퍼 생성 (delta 적용)
---@param hash string 커밋 해시
---@param tab_id number 탭 ID
---@return number buf 생성된 버퍼 번호
local function create_diff_terminal_buffer(hash, tab_id)
	local buf = vim.api.nvim_create_buf(false, true)

	-- 버퍼 옵션 설정
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

	return buf
end

--- 커서 라인에서 파일 경로 추출
---@param line string 라인 텍스트
---@return string|nil file_path 파일 경로 또는 nil
local function extract_file_path_from_line(line)
	-- ANSI escape 코드 제거 (더 포괄적인 패턴)
	local clean_line = line:gsub("\027%[[\048-\063]*[\032-\047]*[\064-\126]", "")

	-- diff --git a/path b/path 패턴
	local path = clean_line:match("diff %-%-git a/(.-) b/")
	if path then
		return path
	end

	-- +++ b/path 패턴
	path = clean_line:match("%+%+%+ b/(.+)$")
	if path then
		return path
	end

	-- --- a/path 패턴
	path = clean_line:match("%-%-%= a/(.+)$")
	if path then
		return path
	end

	-- delta 파일 헤더 패턴 (파일명만 표시되는 경우)
	-- 예: "file.lua" 또는 "path/to/file.lua"
	path = clean_line:match("^([%w%-%._/]+%.[%w]+)$")
	if path then
		return path
	end

	return nil
end

--- 파일을 새 탭에서 열기 (여러 파일 지원)
---@param file_paths table|string 파일 경로 또는 파일 경로 목록
---@param git_root string git root 경로
local function open_files_in_new_tab(file_paths, git_root)
	-- 단일 파일인 경우 테이블로 변환
	if type(file_paths) == "string" then
		file_paths = { file_paths }
	end

	local opened = false
	for i, file_path in ipairs(file_paths) do
		local full_path = git_root .. "/" .. file_path
		if vim.fn.filereadable(full_path) == 1 then
			if i == 1 then
				-- 첫 번째 파일은 새 탭에서 열기
				vim.cmd("tabnew " .. vim.fn.fnameescape(full_path))
			else
				-- 나머지 파일은 같은 탭에서 버퍼로 열기
				vim.cmd("edit " .. vim.fn.fnameescape(full_path))
			end
			opened = true
		else
			vim.notify("File not found: " .. file_path, vim.log.levels.WARN)
		end
	end

	return opened
end

--- 커서 위치의 파일을 새 탭에서 열기
---@param tab_id number 탭 ID
local function open_file_at_cursor(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not tab_info.diff.visible then
		return
	end

	-- 커밋의 모든 파일 목록 가져오기
	local commit_files = git.get_commit_files(tab_info.diff.current_hash)
	if #commit_files == 0 then
		vim.notify("No files in this commit", vim.log.levels.INFO)
		return
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local current_line = cursor[1]

	-- 현재 라인부터 위로 올라가면서 파일 경로 찾기
	for line_num = current_line, 1, -1 do
		local line = vim.api.nvim_buf_get_lines(tab_info.diff.buf, line_num - 1, line_num, false)[1]
		if line then
			local file_path = extract_file_path_from_line(line)
			if file_path then
				-- 커밋 파일 목록에 있는지 확인
				for _, commit_file in ipairs(commit_files) do
					if commit_file == file_path or commit_file:match(file_path .. "$") then
						open_files_in_new_tab(commit_file, tab_info.git_root)
						return
					end
				end
			end

			-- 커밋 파일 목록에서 라인에 포함된 파일 찾기
			for _, commit_file in ipairs(commit_files) do
				-- ANSI 제거 후 파일명이 라인에 포함되어 있는지 확인
				local clean_line = line:gsub("\027%[[\048-\063]*[\032-\047]*[\064-\126]", "")
				if clean_line:find(commit_file, 1, true) then
					open_files_in_new_tab(commit_file, tab_info.git_root)
					return
				end
			end
		end
	end

	vim.notify("No file path found", vim.log.levels.INFO)
end

--- 커밋의 변경된 파일 목록을 표시하고 선택하여 열기
---@param tab_id number 탭 ID
local function show_commit_files(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not tab_info.diff.visible or not tab_info.diff.current_hash then
		return
	end

	local files = git.get_commit_files(tab_info.diff.current_hash)
	if #files == 0 then
		vim.notify("No files in this commit", vim.log.levels.INFO)
		return
	end

	-- snacks.picker 사용 (multi-select 지원)
	local ok, Snacks = pcall(require, "snacks")
	if ok and Snacks.picker then
		Snacks.picker({
			title = "Select file(s) to open",
			items = vim.tbl_map(function(file)
				return { text = file, file = tab_info.git_root .. "/" .. file }
			end, files),
			format = function(item)
				return { { item.text } }
			end,
			confirm = function(picker, item)
				local selected = picker:selected({ fallback = true })
				picker:close()
				if selected and #selected > 0 then
					local selected_files = vim.tbl_map(function(sel)
						return sel.text
					end, selected)
					open_files_in_new_tab(selected_files, tab_info.git_root)
				end
			end,
		})
	else
		-- fallback to vim.ui.select
		vim.ui.select(files, {
			prompt = "Select file to open:",
			format_item = function(item)
				return item
			end,
		}, function(choice)
			if choice then
				open_files_in_new_tab(choice, tab_info.git_root)
			end
		end)
	end
end

--- diff 버퍼의 커서 위치에서 파일 경로를 추출하고 uncommitted 파일 목록과 매칭
---@param tab_id number 탭 ID
---@param file_type string "staged" 또는 "unstaged"
---@return string|nil file_path 매칭된 파일 경로 또는 nil
local function get_file_at_cursor_in_diff(tab_id, file_type)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not tab_info.diff.visible then
		return nil
	end

	local uncommitted_files = git.get_uncommitted_files(file_type)
	if #uncommitted_files == 0 then
		return nil
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local current_line = cursor[1]

	-- 현재 라인부터 위로 올라가면서 파일 경로 찾기
	for line_num = current_line, 1, -1 do
		local line = vim.api.nvim_buf_get_lines(tab_info.diff.buf, line_num - 1, line_num, false)[1]
		if line then
			local file_path = extract_file_path_from_line(line)
			if file_path then
				for _, f in ipairs(uncommitted_files) do
					if f == file_path or f:match(file_path .. "$") then
						return f
					end
				end
			end

			for _, f in ipairs(uncommitted_files) do
				local clean_line = line:gsub("\027%[[\048-\063]*[\032-\047]*[\064-\126]", "")
				if clean_line:find(f, 1, true) then
					return f
				end
			end
		end
	end

	return nil
end

--- Uncommitted diff에서 액션 후 diff 갱신
---@param tab_id number 탭 ID
local function refresh_diff_after_action(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not tab_info.diff.visible then
		return
	end

	local diff = tab_info.diff
	local hash = diff.current_hash
	local commit_list = diff.commit_list
	local current_index = diff.current_index

	if #commit_list > 1 then
		M.show_diff(tab_id, hash, commit_list, current_index)
	else
		-- hide 후 다시 show (toggle 방지를 위해 먼저 hash를 nil로)
		M.hide_diff(tab_id)
		M.show_diff(tab_id, hash)
	end
end

--- Uncommitted diff 키맵 설정 (staged/unstaged 전용)
---@param buf number diff 버퍼
---@param tab_id number 탭 ID
---@param hash string "uncommitted_staged" 또는 "uncommitted_unstaged"
local function setup_uncommitted_diff_keymaps(buf, tab_id, hash)
	local is_staged = hash == "uncommitted_staged"
	local file_type = is_staged and "staged" or "unstaged"

	-- s: 커서 파일 stage (unstaged에서만)
	vim.api.nvim_buf_set_keymap(buf, "n", "s", "", {
		noremap = true,
		silent = true,
		callback = function()
			if is_staged then
				vim.notify("Already staged", vim.log.levels.INFO)
				return
			end
			local file = get_file_at_cursor_in_diff(tab_id, file_type)
			if file then
				if git.stage_file(file) then
					vim.notify("Staged: " .. file, vim.log.levels.INFO)
					refresh_diff_after_action(tab_id)
				end
			else
				vim.notify("No file found at cursor", vim.log.levels.WARN)
			end
		end,
	})

	-- u: 커서 파일 unstage (staged에서만)
	vim.api.nvim_buf_set_keymap(buf, "n", "u", "", {
		noremap = true,
		silent = true,
		callback = function()
			if not is_staged then
				vim.notify("Already unstaged", vim.log.levels.INFO)
				return
			end
			local file = get_file_at_cursor_in_diff(tab_id, file_type)
			if file then
				if git.unstage_file(file) then
					vim.notify("Unstaged: " .. file, vim.log.levels.INFO)
					refresh_diff_after_action(tab_id)
				end
			else
				vim.notify("No file found at cursor", vim.log.levels.WARN)
			end
		end,
	})

	-- S: 전체 stage (unstaged에서만)
	vim.api.nvim_buf_set_keymap(buf, "n", "S", "", {
		noremap = true,
		silent = true,
		callback = function()
			if is_staged then
				vim.notify("Already staged", vim.log.levels.INFO)
				return
			end
			if git.stage_all() then
				vim.notify("Staged all files", vim.log.levels.INFO)
				refresh_diff_after_action(tab_id)
			end
		end,
	})

	-- U: 전체 unstage (staged에서만)
	vim.api.nvim_buf_set_keymap(buf, "n", "U", "", {
		noremap = true,
		silent = true,
		callback = function()
			if not is_staged then
				vim.notify("Already unstaged", vim.log.levels.INFO)
				return
			end
			if git.unstage_all() then
				vim.notify("Unstaged all files", vim.log.levels.INFO)
				refresh_diff_after_action(tab_id)
			end
		end,
	})

	-- x: 커서 파일 discard
	vim.api.nvim_buf_set_keymap(buf, "n", "x", "", {
		noremap = true,
		silent = true,
		callback = function()
			local file = get_file_at_cursor_in_diff(tab_id, file_type)
			if not file then
				vim.notify("No file found at cursor", vim.log.levels.WARN)
				return
			end
			vim.ui.select({ "Yes", "No" }, {
				prompt = string.format("Discard changes in %s?", file),
			}, function(choice)
				if choice == "Yes" then
					local success
					if is_staged then
						success = git.unstage_file(file)
					else
						success = git.discard_file(file)
					end
					if success then
						vim.notify("Discarded: " .. file, vim.log.levels.INFO)
						refresh_diff_after_action(tab_id)
					end
				end
			end)
		end,
	})

	-- X: 전체 discard
	vim.api.nvim_buf_set_keymap(buf, "n", "X", "", {
		noremap = true,
		silent = true,
		callback = function()
			local label = is_staged and "staged" or "unstaged"
			vim.ui.select({ "Yes", "No" }, {
				prompt = string.format("Discard ALL %s changes?", label),
			}, function(choice)
				if choice == "Yes" then
					local success
					if is_staged then
						success = git.unstage_all()
					else
						success = git.discard_all()
					end
					if success then
						vim.notify("Discarded all " .. label .. " changes", vim.log.levels.INFO)
						refresh_diff_after_action(tab_id)
					end
				end
			end)
		end,
	})
end

--- Diff 버퍼 키맵 설정
---@param buf number diff 버퍼
---@param tab_id number 탭 ID
local function setup_diff_keymaps(buf, tab_id)
	local modes = { "n", "t" }

	for _, mode in ipairs(modes) do
		-- q로 닫기
		vim.api.nvim_buf_set_keymap(buf, mode, "q", "", {
			noremap = true,
			silent = true,
			callback = function()
				M.hide_diff(tab_id)
			end,
		})

		-- C-l 로 다음 커밋
		vim.api.nvim_buf_set_keymap(buf, mode, "<C-l>", "", {
			noremap = true,
			silent = true,
			callback = function()
				M.next_diff(tab_id)
			end,
		})

		-- C-h 로 이전 커밋
		vim.api.nvim_buf_set_keymap(buf, mode, "<C-h>", "", {
			noremap = true,
			silent = true,
			callback = function()
				M.prev_diff(tab_id)
			end,
		})

		-- Esc로 diff 닫기
		vim.api.nvim_buf_set_keymap(buf, mode, "<Esc>", "", {
			noremap = true,
			silent = true,
			callback = function()
				M.hide_diff(tab_id)
			end,
		})

		-- gf로 커서 위치 파일 열기
		vim.api.nvim_buf_set_keymap(buf, mode, "gf", "", {
			noremap = true,
			silent = true,
			callback = function()
				open_file_at_cursor(tab_id)
			end,
		})

		-- C-o로 파일 목록에서 선택하여 열기
		vim.api.nvim_buf_set_keymap(buf, mode, "<C-o>", "", {
			noremap = true,
			silent = true,
			callback = function()
				show_commit_files(tab_id)
			end,
		})

		-- C-w로 side-by-side 토글
		vim.api.nvim_buf_set_keymap(buf, mode, "<C-w>", "", {
			noremap = true,
			silent = true,
			callback = function()
				local tab_info = git_graph_tabs[tab_id]
				if not tab_info then
					return
				end
				tab_info.diff.side_by_side = not tab_info.diff.side_by_side
				refresh_diff_after_action(tab_id)
			end,
		})
	end

	-- Uncommitted diff일 때만 stage/unstage/discard 키맵 추가
	local tab_info = git_graph_tabs[tab_id]
	if tab_info then
		local current_hash = tab_info.diff.current_hash
		if current_hash and current_hash:find("^uncommitted_") then
			setup_uncommitted_diff_keymaps(buf, tab_id, current_hash)
		end
	end
end

--- 해시를 winbar 표시용 텍스트로 변환
---@param hash string
---@return string
local function hash_to_display(hash)
	if hash == "uncommitted_staged" then
		return "Staged Changes"
	elseif hash == "uncommitted_unstaged" then
		return "Unstaged Changes"
	elseif hash == "uncommitted" then
		return "Uncommitted Changes"
	end
	return hash
end

--- Winbar 텍스트 생성
---@param diff table diff 상태
---@return string winbar 텍스트
local function get_diff_winbar(diff)
	local hash = diff.current_hash or ""
	local display_hash = hash_to_display(hash)
	if #diff.commit_list > 1 then
		return string.format(" Diff: %s [%d/%d]", display_hash, diff.current_index, #diff.commit_list)
	else
		return " Diff: " .. display_hash
	end
end

--- Diff 패널 표시 (터미널 버퍼로 delta 적용)
---@param tab_id number 탭 ID
---@param hash string 커밋 해시 또는 "uncommitted"
---@param commit_list? table 커밋 목록 (multi-select 시)
---@param index? number 현재 인덱스 (multi-select 시)
function M.show_diff(tab_id, hash, commit_list, index)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	local diff = tab_info.diff
	local is_vsplit = get_is_vsplit()

	-- 단일 선택이고 이미 같은 커밋의 diff가 열려있으면 숨기기 (toggle)
	if not commit_list and diff.visible and diff.current_hash == hash and #diff.commit_list <= 1 then
		M.hide_diff(tab_id)
		return
	end

	-- 기존 diff 윈도우가 있으면 닫기
	if diff.win and vim.api.nvim_win_is_valid(diff.win) then
		vim.api.nvim_win_close(diff.win, true)
	end

	-- 기존 diff 버퍼가 있으면 삭제
	if diff.buf and vim.api.nvim_buf_is_valid(diff.buf) then
		vim.api.nvim_buf_delete(diff.buf, { force = true })
	end

	-- 새 diff 버퍼 생성 (터미널용)
	diff.buf = create_diff_terminal_buffer(hash, tab_id)
	diff.current_hash = hash

	-- commit_list와 index 설정
	if commit_list then
		diff.commit_list = commit_list
		diff.current_index = index or 1
	else
		diff.commit_list = { hash }
		diff.current_index = 1
	end

	-- graph 윈도우에서 split
	vim.api.nvim_set_current_win(tab_info.graph_win)
	local split_cmd = is_vsplit and "rightbelow vsplit" or "rightbelow split"
	vim.cmd(split_cmd)

	diff.win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(diff.win, diff.buf)

	-- diff 명령어 결정
	local diff_cmd
	local sbs = diff.side_by_side
	if hash == "uncommitted_staged" then
		diff_cmd = git.get_uncommitted_diff_cmd("staged", sbs)
	elseif hash == "uncommitted_unstaged" then
		diff_cmd = git.get_uncommitted_diff_cmd("unstaged", sbs)
	elseif hash == "uncommitted" then
		diff_cmd = git.get_uncommitted_diff_cmd("unstaged", sbs)
	else
		local delta_flags = sbs and "--paging=never --side-by-side" or "--paging=never"
		diff_cmd = string.format("git show %s | delta %s", hash, delta_flags)
	end

	-- 터미널에서 diff 실행
	vim.fn.termopen(diff_cmd, {
		on_exit = function(_, _, _)
			-- 터미널 종료 후 Normal 모드로 전환 + 최상단 이동
			vim.schedule(function()
				if diff.buf and vim.api.nvim_buf_is_valid(diff.buf) then
					-- 터미널 모드 종료 + 최상단 이동 (gg)
					vim.api.nvim_feedkeys(
						vim.api.nvim_replace_termcodes("<C-\\><C-n>gg", true, false, true),
						"n",
						false
					)
				end
			end)
		end,
	})

	-- Winbar 설정
	vim.wo[diff.win].winbar = get_diff_winbar(diff)

	-- 윈도우 크기 설정
	if is_vsplit then
		local width = math.floor(vim.o.columns * DIFF_SIZE.VSPLIT_WIDTH_RATIO)
		vim.api.nvim_win_set_width(diff.win, width)
	else
		local height = math.floor(vim.o.lines * DIFF_SIZE.HSPLIT_HEIGHT_RATIO)
		vim.api.nvim_win_set_height(diff.win, height)
	end

	diff.visible = true
	diff.is_vsplit = is_vsplit

	-- Diff 버퍼 키맵 설정
	setup_diff_keymaps(diff.buf, tab_id)

	-- 항상 diff 윈도우로 포커스
	vim.api.nvim_set_current_win(diff.win)
	-- 현재 해시 강조
	M.highlight_current_hash(tab_id)
	-- 터미널 모드로 진입 (insert mode)
	vim.cmd("startinsert")
end

--- 다음 커밋 diff로 이동
---@param tab_id number 탭 ID
function M.next_diff(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not tab_info.diff.visible then
		return
	end

	local diff = tab_info.diff
	if #diff.commit_list <= 1 then
		return
	end

	local next_index = diff.current_index + 1
	if next_index > #diff.commit_list then
		next_index = 1 -- 순환
	end

	local next_hash = diff.commit_list[next_index]
	M.show_diff(tab_id, next_hash, diff.commit_list, next_index)
end

--- 이전 커밋 diff로 이동
---@param tab_id number 탭 ID
function M.prev_diff(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not tab_info.diff.visible then
		return
	end

	local diff = tab_info.diff
	if #diff.commit_list <= 1 then
		return
	end

	local prev_index = diff.current_index - 1
	if prev_index < 1 then
		prev_index = #diff.commit_list -- 순환
	end

	local prev_hash = diff.commit_list[prev_index]
	M.show_diff(tab_id, prev_hash, diff.commit_list, prev_index)
end

--- Diff 패널 숨기기
---@param tab_id number 탭 ID
function M.hide_diff(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	local diff = tab_info.diff

	-- dim 하이라이트 제거
	M.clear_current_hash_highlight(tab_id)

	-- diff 윈도우 닫기
	if diff.win and vim.api.nvim_win_is_valid(diff.win) then
		vim.api.nvim_win_close(diff.win, true)
	end

	-- diff 버퍼 삭제
	if diff.buf and vim.api.nvim_buf_is_valid(diff.buf) then
		vim.api.nvim_buf_delete(diff.buf, { force = true })
	end

	diff.win = nil
	diff.buf = nil
	diff.visible = false
	diff.current_hash = nil
	diff.commit_list = {}
	diff.current_index = 0
end

--- Visual 선택 범위에서 커밋 해시 목록 추출 (중복 제거, 순서 유지)
---@param tab_id number 탭 ID
---@param start_line number 시작 라인
---@param end_line number 끝 라인
---@return table commit_list 커밋 해시 목록
local function get_commits_in_range(tab_id, start_line, end_line)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not tab_info.line_to_hash then
		return {}
	end

	local seen = {}
	local commit_list = {}

	for line = start_line, end_line do
		local hash = tab_info.line_to_hash[line]
		if hash and not seen[hash] then
			seen[hash] = true
			table.insert(commit_list, hash)
		end
	end

	return commit_list
end

--- commit_list에서 "uncommitted"을 unstaged/staged로 펼치기
---@param commit_list table 커밋 해시 목록
---@return table expanded 펼쳐진 목록
local function expand_uncommitted(commit_list)
	local expanded = {}
	for _, hash in ipairs(commit_list) do
		if hash == "uncommitted" then
			table.insert(expanded, "uncommitted_unstaged")
			table.insert(expanded, "uncommitted_staged")
		else
			table.insert(expanded, hash)
		end
	end
	return expanded
end

--- Visual 선택 범위의 커밋 diff 표시
---@param tab_id number 탭 ID
function M.show_diff_visual(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	-- Visual 모드 선택 범위 가져오기
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")

	-- 시작과 끝 정렬
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	-- Visual 모드 종료
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

	-- 선택 범위에서 커밋 목록 추출
	local commit_list = get_commits_in_range(tab_id, start_line, end_line)
	-- "uncommitted"을 staged/unstaged로 펼치기
	commit_list = expand_uncommitted(commit_list)

	if #commit_list == 0 then
		return
	elseif #commit_list == 1 then
		-- 단일 커밋
		M.show_diff(tab_id, commit_list[1])
	else
		-- 다중 커밋: 첫 번째 커밋 표시
		M.show_diff(tab_id, commit_list[1], commit_list, 1)
	end
end

-- Dim 처리용 namespace
local dim_ns_id = vim.api.nvim_create_namespace("git-graph-current")
local ansi_ns_id = vim.api.nvim_create_namespace("git-graph-highlight") -- ANSI 하이라이트와 같은 namespace

--- 체크된 커밋 시각적 표시 업데이트 (Sign column 사용)
---@param tab_id number 탭 ID
local function update_check_signs(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not vim.api.nvim_buf_is_valid(tab_info.graph_buf) then
		return
	end

	-- 기존 sign 제거
	vim.fn.sign_unplace("GitGraphCheckGroup", { buffer = tab_info.graph_buf })

	-- 각 체크된 해시의 첫 번째 라인만 찾기
	local hash_first_line = {}
	for line_num, hash in pairs(tab_info.line_to_hash) do
		if tab_info.checked_set[hash] then
			if not hash_first_line[hash] or line_num < hash_first_line[hash] then
				hash_first_line[hash] = line_num
			end
		end
	end

	-- 첫 번째 라인에만 sign 배치
	local sign_id = 1
	for _, line_num in pairs(hash_first_line) do
		vim.fn.sign_place(sign_id, "GitGraphCheckGroup", "GitGraphCheck", tab_info.graph_buf, { lnum = line_num })
		sign_id = sign_id + 1
	end
end

--- 현재 diff 커밋 해시를 강조 표시
---@param tab_id number 탭 ID
function M.highlight_current_hash(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not vim.api.nvim_buf_is_valid(tab_info.graph_buf) then
		return
	end

	local diff = tab_info.diff
	if not diff.visible or not diff.current_hash then
		return
	end

	-- 기존 하이라이트 제거
	vim.api.nvim_buf_clear_namespace(tab_info.graph_buf, dim_ns_id, 0, -1)

	-- 현재 해시에 해당하는 모든 라인 찾기
	-- uncommitted_staged/uncommitted_unstaged → line_to_hash의 "uncommitted"과 매칭
	local match_hash = diff.current_hash
	if match_hash:find("^uncommitted_") then
		match_hash = "uncommitted"
	end
	local commit_lines = {}
	for line_num, hash in pairs(tab_info.line_to_hash) do
		if hash == match_hash then
			table.insert(commit_lines, line_num)
		end
	end
	table.sort(commit_lines)

	local target_line = nil

	local is_uncommitted = match_hash == "uncommitted"

	for _, line_num in ipairs(commit_lines) do
		local line_text = vim.api.nvim_buf_get_lines(tab_info.graph_buf, line_num - 1, line_num, false)[1]
		if line_text then
			if is_uncommitted then
				-- uncommitted 라인: "Uncommitted Changes" 텍스트를 빨간색으로
				local uc_start, uc_end = line_text:find("Uncommitted Changes", 1, true)
				if uc_start then
					vim.api.nvim_buf_set_extmark(tab_info.graph_buf, dim_ns_id, line_num - 1, uc_start - 1, {
						virt_text = { { "Uncommitted Changes", "GitGraphCurrentHash" } },
						virt_text_pos = "overlay",
					})
					target_line = line_num
				else
					local content_start = line_text:find("%S")
					if content_start then
						vim.api.nvim_buf_set_extmark(tab_info.graph_buf, dim_ns_id, line_num - 1, 0, {
							line_hl_group = "GitGraphCurrentCommit",
						})
					end
				end
			else
				-- 라인에서 해시 위치 찾기
				local hash_start, hash_end = line_text:find(diff.current_hash, 1, true)
				if hash_start then
					-- 해시가 있는 라인: 해시는 빨간색으로
					-- overlay로 기존 노란색 해시 위에 빨간색 해시 덮어쓰기
					vim.api.nvim_buf_set_extmark(tab_info.graph_buf, dim_ns_id, line_num - 1, hash_start - 1, {
						virt_text = { { diff.current_hash, "GitGraphCurrentHash" } },
						virt_text_pos = "overlay",
					})
					target_line = line_num
				else
					-- 해시가 없는 라인 (커밋 메시지, 데코레이션): bold 처리
					-- 들여쓰기 후의 텍스트 시작 위치 찾기
					local content_start = line_text:find("%S")
					if content_start then
						-- bold는 기존 색상 위에 추가됨
						vim.api.nvim_buf_set_extmark(tab_info.graph_buf, dim_ns_id, line_num - 1, 0, {
							line_hl_group = "GitGraphCurrentCommit",
						})
					end
				end
			end
		end
	end

	-- 해당 라인으로 스크롤
	if target_line and vim.api.nvim_win_is_valid(tab_info.graph_win) then
		-- 현재 윈도우 저장
		local current_win = vim.api.nvim_get_current_win()
		-- graph 윈도우로 이동하여 커서 이동
		vim.api.nvim_win_set_cursor(tab_info.graph_win, { target_line, 0 })
		-- 화면 중앙에 위치시키기
		vim.api.nvim_win_call(tab_info.graph_win, function()
			vim.cmd("normal! zz")
		end)
		-- 원래 윈도우로 복귀
		if current_win ~= tab_info.graph_win and vim.api.nvim_win_is_valid(current_win) then
			vim.api.nvim_set_current_win(current_win)
		end
	end
end

--- 현재 해시 하이라이트 제거
---@param tab_id number 탭 ID
function M.clear_current_hash_highlight(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not vim.api.nvim_buf_is_valid(tab_info.graph_buf) then
		return
	end

	vim.api.nvim_buf_clear_namespace(tab_info.graph_buf, dim_ns_id, 0, -1)
end

--- 현재 커서 위치의 커밋 체크/언체크 토글
---@param tab_id number 탭 ID
function M.toggle_check_commit(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	-- 현재 커서 라인 번호 가져오기
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]

	-- line_to_hash 매핑에서 해시 조회
	local hash = tab_info.line_to_hash and tab_info.line_to_hash[row]
	if not hash then
		return
	end

	if tab_info.checked_set[hash] then
		-- 이미 체크되어 있으면 해제
		tab_info.checked_set[hash] = nil
		for i, h in ipairs(tab_info.checked_commits) do
			if h == hash then
				table.remove(tab_info.checked_commits, i)
				break
			end
		end
	else
		-- 체크되어 있지 않으면 추가
		tab_info.checked_set[hash] = true
		table.insert(tab_info.checked_commits, hash)
	end

	-- 시각적 표시 업데이트
	update_check_signs(tab_id)

	-- winbar에 체크된 개수 표시
	local check_count = #tab_info.checked_commits
	if check_count > 0 then
		vim.wo[tab_info.graph_win].winbar = string.format(" Git Graph [%d checked]", check_count)
	else
		vim.wo[tab_info.graph_win].winbar = " Git Graph"
	end
end

--- 모든 체크 해제
---@param tab_id number 탭 ID
function M.clear_checked_commits(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	tab_info.checked_commits = {}
	tab_info.checked_set = {}

	-- 시각적 표시 업데이트
	update_check_signs(tab_id)

	-- winbar 복원
	vim.wo[tab_info.graph_win].winbar = " Git Graph"
end

--- 현재 커서 위치의 커밋 diff 표시/토글
---@param tab_id number 탭 ID
function M.toggle_diff_at_cursor(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	-- 체크된 커밋이 있으면 multi diff 표시
	if #tab_info.checked_commits > 0 then
		-- graph 순서(라인 번호)로 정렬
		local commit_list = vim.deepcopy(tab_info.checked_commits)
		local hash_to_line = {}
		for line_num, hash in pairs(tab_info.line_to_hash) do
			-- 해시별로 가장 작은 라인 번호 저장 (첫 번째 출현 위치)
			if not hash_to_line[hash] or line_num < hash_to_line[hash] then
				hash_to_line[hash] = line_num
			end
		end
		table.sort(commit_list, function(a, b)
			return (hash_to_line[a] or 0) < (hash_to_line[b] or 0)
		end)
		-- "uncommitted"을 staged/unstaged로 펼치기
		commit_list = expand_uncommitted(commit_list)
		M.show_diff(tab_id, commit_list[1], commit_list, 1)
		-- 체크 해제
		M.clear_checked_commits(tab_id)
		return
	end

	-- 현재 커서 라인 번호 가져오기
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]

	-- line_to_hash 매핑에서 해시 조회
	local hash = tab_info.line_to_hash and tab_info.line_to_hash[row]

	if hash == "uncommitted" then
		-- uncommitted은 unstaged/staged로 분리
		local commit_list = { "uncommitted_unstaged", "uncommitted_staged" }
		M.show_diff(tab_id, commit_list[1], commit_list, 1)
	elseif hash then
		M.show_diff(tab_id, hash)
	end
end

--- Diff 패널 방향 변경 (resize 시)
---@param tab_id number 탭 ID
function M.handle_diff_resize(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info or not tab_info.diff.visible then
		return
	end

	local diff = tab_info.diff
	local new_is_vsplit = get_is_vsplit()

	-- 방향이 변경되었으면 다시 열기
	if new_is_vsplit ~= diff.is_vsplit then
		local hash = diff.current_hash
		local commit_list = diff.commit_list
		local current_index = diff.current_index

		-- hide 호출 전에 상태 저장
		M.hide_diff(tab_id)
		if hash then
			if #commit_list > 1 then
				M.show_diff(tab_id, hash, commit_list, current_index)
			else
				M.show_diff(tab_id, hash)
			end
		end
	else
		-- 같은 방향이면 크기만 조정
		if diff.win and vim.api.nvim_win_is_valid(diff.win) then
			if new_is_vsplit then
				local width = math.floor(vim.o.columns * DIFF_SIZE.VSPLIT_WIDTH_RATIO)
				vim.api.nvim_win_set_width(diff.win, width)
			else
				local height = math.floor(vim.o.lines * DIFF_SIZE.HSPLIT_HEIGHT_RATIO)
				vim.api.nvim_win_set_height(diff.win, height)
			end
		end
	end
end

--- Git graph 탭 열기
function M.open_git_graph()
	load_modules()

	local git_root = git.get_git_root()
	if not git_root then
		print("Not in a git repository")
		return
	end

	-- 새 탭 생성
	vim.cmd("tabnew")
	local tab_id = vim.api.nvim_get_current_tabpage()

	-- git graph 버퍼 생성 (전체 화면)
	local graph_buf = buffer.create_buffer()
	local graph_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(graph_win, graph_buf)

	-- Winbar 설정 (타이틀 표시)
	vim.wo[graph_win].winbar = " Git Graph"

	-- Sign column 활성화 (체크 표시용)
	vim.wo[graph_win].signcolumn = "yes:1"

	-- 초기 렌더링 (500개 로드)
	local line_to_hash, uncommitted_line_count = buffer.render_git_log(graph_buf, INITIAL_LOAD_COUNT, 0)

	-- 탭 정보 저장
	git_graph_tabs[tab_id] = {
		graph_win = graph_win,
		graph_buf = graph_buf,
		git_root = git_root,
		loaded_count = INITIAL_LOAD_COUNT,
		loading = false,
		line_to_hash = line_to_hash,
		uncommitted_line_count = uncommitted_line_count,
		checked_commits = {}, -- 체크된 커밋 목록 (순서 유지)
		checked_set = {}, -- 체크 여부 빠른 조회용
		terminal = {
			buf = nil,
			float_win = nil,
			visible = false,
			initialized = false,
		},
		diff = {
			buf = nil,
			win = nil,
			visible = false,
			current_hash = nil,
			is_vsplit = nil,
			side_by_side = false, -- side-by-side diff 모드
			commit_list = {}, -- 선택된 커밋 목록
			current_index = 0, -- 현재 보고 있는 커밋 인덱스
		},
	}

	-- Graph 버퍼 키맵 설정
	setup_graph_keymaps(graph_buf, tab_id)

	-- 스크롤 감지 autocmd 추가
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = graph_buf,
		callback = function()
			check_scroll_position(tab_id, graph_buf)
		end,
	})

	-- .git 디렉토리 감시 시작
	git_graph_tabs[tab_id].watcher = watcher.watch_git_dir(git_root, function()
		M.update_git_log(tab_id)
	end)
end

--- 탭 정리
---@param tab_id number 탭 ID
function M.cleanup_tab(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	-- watcher 정리 (배열일 수 있음)
	if tab_info.watcher then
		if type(tab_info.watcher) == "table" then
			for _, w in ipairs(tab_info.watcher) do
				if w and w.stop then
					w:stop()
				end
			end
		elseif tab_info.watcher.stop then
			tab_info.watcher:stop()
		end
	end

	-- 터미널 정리
	if tab_info.terminal then
		local terminal = tab_info.terminal

		-- float window 닫기
		if float and float.is_valid(terminal.float_win) then
			float.close_float_window(terminal.float_win)
		end

		-- 터미널 버퍼 삭제
		if terminal.buf and vim.api.nvim_buf_is_valid(terminal.buf) then
			vim.api.nvim_buf_delete(terminal.buf, { force = true })
		end
	end

	-- diff 정리
	if tab_info.diff then
		local diff = tab_info.diff

		-- diff 윈도우 닫기
		if diff.win and vim.api.nvim_win_is_valid(diff.win) then
			vim.api.nvim_win_close(diff.win, true)
		end

		-- diff 버퍼 삭제
		if diff.buf and vim.api.nvim_buf_is_valid(diff.buf) then
			vim.api.nvim_buf_delete(diff.buf, { force = true })
		end
	end

	git_graph_tabs[tab_id] = nil
end

--- 화면 크기 변경 처리 (debounce 적용)
function M.debounced_resize()
	if resize_scheduled then
		return
	end

	resize_scheduled = true
	vim.defer_fn(function()
		local current_tab = vim.api.nvim_get_current_tabpage()
		local tab_info = git_graph_tabs[current_tab]

		-- 현재 탭이 git-graph 탭인지 확인
		if not tab_info then
			-- git-graph가 아닌 탭이면, 존재하지 않는 탭 정리
			local existing_tabs = vim.api.nvim_list_tabpages()
			for tab_id in pairs(git_graph_tabs) do
				if not vim.tbl_contains(existing_tabs, tab_id) then
					git_graph_tabs[tab_id] = nil
				end
			end
		else
			-- float 터미널이 열려있으면 크기 재조정
			if tab_info.terminal and tab_info.terminal.visible then
				if float.is_valid(tab_info.terminal.float_win) then
					float.resize_float_window(tab_info.terminal.float_win)
				end
			end

			-- diff 패널이 열려있으면 방향/크기 조정
			if tab_info.diff and tab_info.diff.visible then
				M.handle_diff_resize(current_tab)
			end
		end

		resize_scheduled = false
	end, DEBOUNCE_DELAY_MS)
end

return M
