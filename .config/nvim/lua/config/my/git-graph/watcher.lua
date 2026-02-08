local M = {}
local watchers = {}


--- 단일 경로를 감시하는 watcher 생성
---@param path string 감시할 경로
---@param callback function 변경 감지 시 실행할 콜백 함수
---@param uv table libuv 객체
---@return table|nil fs_event 파일 시스템 이벤트 객체
local function create_watcher(path, callback, uv)
	local fs_event = uv.new_fs_event()
	if not fs_event then
		return nil
	end

	-- recursive 옵션으로 하위 디렉토리도 감시
	local success, err = fs_event:start(
		path,
		{ recursive = true },
		vim.schedule_wrap(function(err_msg, filename, events)
			if err_msg then
				-- 오류 무시 (파일이 없을 수 있음)
				return
			end

			-- 변화 감지 시 콜백 실행
			if filename then
				callback()
			end
		end)
	)

	if not success then
		-- 실패해도 계속 진행 (해당 경로가 없을 수 있음)
		return nil
	end

	return fs_event
end

--- .git 디렉토리의 여러 경로를 감시하고 변경 시 콜백 실행
--- git worktree 환경에서도 올바른 경로를 감시함
---@param git_root string Git 저장소 루트 경로
---@param callback function 변경 감지 시 실행할 콜백 함수
---@return table watchers_list 생성된 watcher 목록
function M.watch_git_dir(git_root, callback)
	local git = require("config.my.git-graph.git")
	local git_dir = git.get_git_dir() or (git_root .. "/.git")
	local git_common_dir = git.get_git_common_dir() or git_dir
	local watcher_key = git_dir

	-- 기존 watcher 정리
	if watchers[watcher_key] then
		for _, watcher in ipairs(watchers[watcher_key]) do
			if watcher then
				watcher:stop()
			end
		end
		watchers[watcher_key] = nil
	end

	-- vim.uv (또는 vim.loop) 사용 (Neovim 0.9+ 호환성)
	local uv = vim.uv or vim.loop
	if not uv then
		print("Git watcher error: libuv not available")
		return nil
	end

	-- 감시할 경로 목록
	-- worktree-specific 경로와 공유 경로를 분리
	local watch_paths = {
		git_common_dir .. "/refs/heads", -- 로컬 브랜치 (공유)
		git_common_dir .. "/refs/remotes", -- 리모트 브랜치 (공유)
		git_common_dir .. "/refs/tags", -- 태그 (공유)
		git_dir, -- index, HEAD, FETCH_HEAD 등 (디렉토리 감시로 rename도 감지)
		git_common_dir .. "/logs", -- reflog (공유)
	}

	local watcher_list = {}

	-- 각 경로에 대해 watcher 생성
	for _, path in ipairs(watch_paths) do
		local watcher = create_watcher(path, callback, uv)
		if watcher then
			table.insert(watcher_list, watcher)
		end
	end

	-- 최소 1개의 watcher가 생성되었는지 확인
	if #watcher_list == 0 then
		print("Git watcher error: failed to create any watchers")
		return nil
	end

	watchers[watcher_key] = watcher_list

	return watcher_list
end

--- 모든 watcher 정지
function M.stop_all()
	for _, watcher_list in pairs(watchers) do
		if type(watcher_list) == "table" then
			for _, watcher in ipairs(watcher_list) do
				if watcher then
					watcher:stop()
				end
			end
		end
	end
	watchers = {}
end

return M
