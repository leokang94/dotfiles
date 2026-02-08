local M = {}

--- Git 저장소의 루트 디렉토리를 반환
---@return string|nil git_root Git 저장소 루트 경로, 실패 시 nil
function M.get_git_root()
	local result = vim.fn.systemlist("git rev-parse --show-toplevel")
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return result[1]
end

--- Git graph log를 가져옴 (gitconfig의 graph-log alias와 동일한 형식)
---@param limit? number 가져올 커밋 개수 (기본값: 30)
---@param skip? number 건너뛸 커밋 개수 (기본값: 0)
---@return table lines Git log 라인들의 배열
function M.get_graph_log(limit, skip)
	limit = limit or 30
	skip = skip or 0

	-- git graph-log alias를 그대로 실행
	local cmd = string.format(
		[[git log -n %d --skip=%d --all --graph --date-order --date=format-local:'%%Y-%%m-%%d %%H:%%M:%%S %%Z' --format=format:'%%C(yellow)%%h%%C(reset)%%C(reset) %%C(brightblack)%%cN (%%cd) /%%C(reset) %%C(brightblack)%%aN (%%ad)%%C(reset)%%n%%C(auto)%%(decorate:prefix=        ,suffix=
,pointer= 󰁔 )        %%C(brightwhite)%%s%%C(reset)%%n']],
		limit,
		skip
	)

	-- stash hash는 skip=0일 때만 포함
	if skip == 0 then
		local stash_cmd = "git reflog show --format=%h stash 2>/dev/null"
		local stash_hashes = vim.fn.systemlist(stash_cmd)

		if vim.v.shell_error == 0 and #stash_hashes > 0 then
			-- stash hash를 명령어에 추가
			cmd = cmd .. " " .. table.concat(stash_hashes, " ")
		end
	end

	local result = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		return { "Error: Not a git repository or git command failed" }
	end

	return result
end

--- 현재 worktree의 git 디렉토리 경로를 반환 (worktree-specific)
---@return string|nil git_dir Git 디렉토리 경로, 실패 시 nil
function M.get_git_dir()
	local result = vim.fn.systemlist("git rev-parse --git-dir")
	if vim.v.shell_error ~= 0 then
		return nil
	end
	local dir = result[1]
	-- 상대 경로일 수 있으므로 절대 경로로 변환
	if not vim.startswith(dir, "/") then
		local root = M.get_git_root()
		if root then
			dir = root .. "/" .. dir
		end
	end
	return dir
end

--- 공유 git 디렉토리 경로를 반환 (refs, objects 등)
---@return string|nil git_common_dir 공유 Git 디렉토리 경로, 실패 시 nil
function M.get_git_common_dir()
	local result = vim.fn.systemlist("git rev-parse --git-common-dir")
	if vim.v.shell_error ~= 0 then
		return nil
	end
	local dir = result[1]
	if not vim.startswith(dir, "/") then
		local root = M.get_git_root()
		if root then
			dir = root .. "/" .. dir
		end
	end
	return dir
end

--- 커밋의 diff를 가져옴
---@param hash string 커밋 해시
---@return table lines diff 라인들의 배열
function M.get_commit_diff(hash)
	local cmd = string.format("git show --color=always --stat --patch %s", hash)
	local result = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		return { "Error: Failed to get diff for commit " .. hash }
	end
	return result
end

--- 커밋에서 변경된 파일 목록을 가져옴
---@param hash string 커밋 해시
---@return table files 변경된 파일 경로 목록
function M.get_commit_files(hash)
	local cmd = string.format("git show --name-only --pretty=format: %s", hash)
	local result = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		return {}
	end
	-- 빈 줄 제거
	local files = {}
	for _, line in ipairs(result) do
		if line ~= "" then
			table.insert(files, line)
		end
	end
	return files
end

--- Uncommitted changes 상태 가져오기
---@return table status { staged: number, unstaged: number, untracked: number }
function M.get_uncommitted_status()
	local status = { staged = 0, unstaged = 0, untracked = 0 }
	local git_root = M.get_git_root()
	if not git_root then
		return status
	end
	-- --no-optional-locks: index.lock 파일 생성 방지 (watcher 무한 루프 방지)
	-- -C: git root 디렉토리 지정
	local cmd = string.format("git -C %s --no-optional-locks status --porcelain", vim.fn.shellescape(git_root))
	local result = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		return status
	end
	for _, line in ipairs(result) do
		local index = line:sub(1, 1)
		local worktree = line:sub(2, 2)
		if index == "?" then
			status.untracked = status.untracked + 1
		else
			if index ~= " " then
				status.staged = status.staged + 1
			end
			if worktree ~= " " then
				status.unstaged = status.unstaged + 1
			end
		end
	end
	return status
end

--- Uncommitted changes diff 명령어 가져오기
---@return string cmd diff 명령어
function M.get_uncommitted_diff_cmd()
	return "git diff HEAD --color=always | delta --paging=never"
end

return M
