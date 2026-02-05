local M = {}

-- 지연 로딩을 위한 모듈 참조
local buffer, watcher, git, highlight, float

-- 모듈 레벨 상태
local git_graph_tabs = {}
local DEBOUNCE_DELAY_MS = 100
local update_scheduled = {}
local resize_scheduled = false

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
			buffer.render_git_log(tab_info.graph_buf, INITIAL_LOAD_COUNT, 0)
			-- 로드된 개수 초기화
			tab_info.loaded_count = INITIAL_LOAD_COUNT
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

	-- 추가 로그 로드
	local success = buffer.append_git_log(tab_info.graph_buf, LOAD_MORE_COUNT, tab_info.loaded_count)

	if success then
		tab_info.loaded_count = tab_info.loaded_count + LOAD_MORE_COUNT
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

	-- 초기 렌더링 (500개 로드)
	buffer.render_git_log(graph_buf, INITIAL_LOAD_COUNT, 0)

	-- 탭 정보 저장
	git_graph_tabs[tab_id] = {
		graph_win = graph_win,
		graph_buf = graph_buf,
		git_root = git_root,
		loaded_count = INITIAL_LOAD_COUNT,
		loading = false,
		terminal = {
			buf = nil,
			float_win = nil,
			visible = false,
			initialized = false,
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
		end

		resize_scheduled = false
	end, DEBOUNCE_DELAY_MS)
end

return M
