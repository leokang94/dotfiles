local M = {}

-- 지연 로딩을 위한 모듈 참조
local buffer, watcher, window, git, highlight
local get_is_vsplit = require("utils.screen").is_vsplit

-- 모듈 레벨 상태
local git_graph_tabs = {}
local DEBOUNCE_DELAY_MS = 100
local update_scheduled = {}
local resize_scheduled = false

--- 모듈 지연 로딩
local function load_modules()
	if not buffer then
		highlight = require("config.my.git-graph.highlight")
		buffer = require("config.my.git-graph.buffer")
		watcher = require("config.my.git-graph.watcher")
		window = require("config.my.git-graph.window")
		git = require("config.my.git-graph.git")
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

	-- WinEnter/BufEnter 이벤트로 윈도우 크기 유지
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		pattern = "*",
		callback = function()
			local current_tab = vim.api.nvim_get_current_tabpage()
			local tab_info = git_graph_tabs[current_tab]

			if tab_info then
				local current_win = vim.api.nvim_get_current_win()
				local current_buf = vim.api.nvim_win_get_buf(current_win)

				if current_buf == tab_info.terminal_buf or current_buf == tab_info.graph_buf then
					window.apply_window_sizes(tab_info, tab_info.is_vsplit)
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
			buffer.render_git_log(tab_info.graph_buf)
		end
		update_scheduled[tab_id] = nil
	end, DEBOUNCE_DELAY_MS)
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
	local is_vsplit = get_is_vsplit()
	local split_cmd = is_vsplit and "vsplit" or "split"

	-- 터미널 생성
	vim.cmd("terminal")
	vim.cmd("startinsert")
	local terminal_buf = vim.api.nvim_get_current_buf()
	local terminal_win = vim.api.nvim_get_current_win()

	-- git graph 버퍼 생성
	vim.cmd(split_cmd)
	local graph_buf = buffer.create_buffer()
	local graph_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(graph_win, graph_buf)

	-- 초기 렌더링
	buffer.render_git_log(graph_buf)

	-- 탭 정보 저장
	git_graph_tabs[tab_id] = {
		is_vsplit = is_vsplit,
		terminal_win = terminal_win,
		terminal_buf = terminal_buf,
		graph_win = graph_win,
		graph_buf = graph_buf,
		git_root = git_root,
	}

	-- .git 디렉토리 감시 시작
	git_graph_tabs[tab_id].watcher = watcher.watch_git_dir(git_root, function()
		M.update_git_log(tab_id)
	end)

	-- 윈도우 크기 적용
	window.apply_window_sizes(git_graph_tabs[tab_id], is_vsplit)

	-- 터미널 윈도우로 포커스 이동
	if is_vsplit then
		vim.cmd("wincmd h")
	else
		vim.cmd("wincmd k")
	end
	vim.api.nvim_set_current_win(terminal_win)
end

--- 탭 정리
---@param tab_id number 탭 ID
function M.cleanup_tab(tab_id)
	local tab_info = git_graph_tabs[tab_id]
	if not tab_info then
		return
	end

	-- watcher 정리
	if tab_info.watcher then
		tab_info.watcher:stop()
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
			-- git-graph 탭이면 윈도우 크기 조정
			window.handle_screen_resize(git_graph_tabs, current_tab)
		end

		resize_scheduled = false
	end, DEBOUNCE_DELAY_MS)
end

return M
