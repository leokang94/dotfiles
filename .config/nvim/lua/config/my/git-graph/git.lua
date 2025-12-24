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
---@return table lines Git log 라인들의 배열
function M.get_graph_log()
	-- git graph-log alias를 그대로 실행
	local cmd = [[git log --all --graph --date-order --date=format-local:'%Y-%m-%d %H:%M:%S %Z' --format=format:'%C(yellow)%h%C(reset)%C(reset) %C(brightblack)%cN (%cd) /%C(reset) %C(brightblack)%aN (%ad)%C(reset)%n%C(auto)%(decorate:prefix=        ,suffix=
,pointer= 󰁔 )        %C(brightwhite)%s%C(reset)%n']]

	-- stash hash도 포함 (별도 명령어로)
	local stash_cmd = "git reflog show --format=%h stash 2>/dev/null"
	local stash_hashes = vim.fn.systemlist(stash_cmd)

	if vim.v.shell_error == 0 and #stash_hashes > 0 then
		-- stash hash를 명령어에 추가
		cmd = cmd .. " " .. table.concat(stash_hashes, " ")
	end

	local result = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		return { "Error: Not a git repository or git command failed" }
	end

	return result
end

return M
