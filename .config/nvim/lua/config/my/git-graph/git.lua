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

return M
