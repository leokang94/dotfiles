local M = {}
local watchers = {}

--- .git 디렉토리를 감시하고 변경 시 콜백 실행
---@param git_root string Git 저장소 루트 경로
---@param callback function 변경 감지 시 실행할 콜백 함수
---@return table|nil fs_event 파일 시스템 이벤트 객체
function M.watch_git_dir(git_root, callback)
	local git_dir = git_root .. "/.git"

	-- 기존 watcher 정리
	if watchers[git_dir] then
		watchers[git_dir]:stop()
		watchers[git_dir] = nil
	end

	-- vim.uv (또는 vim.loop) 사용 (Neovim 0.9+ 호환성)
	local uv = vim.uv or vim.loop
	if not uv then
		print("Git watcher error: libuv not available")
		return nil
	end

	local fs_event = uv.new_fs_event()
	if not fs_event then
		print("Git watcher error: failed to create fs_event")
		return nil
	end

	-- .git 디렉토리 감시 시작
	local success, err = fs_event:start(
		git_dir,
		{},
		vim.schedule_wrap(function(err_msg, filename, events)
			if err_msg then
				print("Git watcher error:", err_msg)
				return
			end

			-- 변화 감지 시 콜백 실행 (debounce는 상위 레벨에서 처리)
			if filename then
				callback()
			end
		end)
	)

	if not success then
		print("Git watcher error: failed to start watching", err)
		return nil
	end

	watchers[git_dir] = fs_event

	return fs_event
end

--- 모든 watcher 정지
function M.stop_all()
	for _, watcher in pairs(watchers) do
		if watcher then
			watcher:stop()
		end
	end
	watchers = {}
end

return M
