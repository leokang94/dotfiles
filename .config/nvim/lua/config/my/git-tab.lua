_G.git_watch_job_id_list = _G.git_watch_job_id_list or {}

local function open_terminals()
	vim.cmd("tabnew")

	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")
	local is_vsplit = width > height * 3
	local split_cmd = is_vsplit and "vsplit" or "split"

	vim.cmd("terminal")
	vim.cmd("startinsert")

	vim.cmd(split_cmd)
	vim.cmd("terminal")
	vim.cmd("startinsert")

	local current_job_id = vim.b.terminal_job_id
	table.insert(_G.git_watch_job_id_list, current_job_id)
	vim.api.nvim_chan_send(current_job_id, "git watch\n")

	if is_vsplit then
		vim.cmd("vertical resize " .. math.floor(width * 0.8))
	else
		vim.cmd("resize " .. math.floor(height * 0.8))
	end

	if is_vsplit then
		vim.cmd("wincmd h")
	else
		vim.cmd("wincmd k")
	end
end

_G.open_terminals = open_terminals

vim.api.nvim_set_keymap(
	"n",
	"<leader>gt",
	":lua _G.open_terminals()<CR>",
	{ desc = "git-tab", noremap = true, silent = true }
)

vim.api.nvim_create_autocmd("TabClosed", {
	pattern = "*",
	callback = function()
		print("tab closed")
		for _, job_id in ipairs(_G.git_watch_job_id_list) do
			local jobstop_result = vim.fn.jobstop(job_id)
			print("Stopped job ID:", job_id, "Result:", (jobstop_result == 1 and "Success" or "Failed"))
		end

		-- 리스트 초기화
		_G.git_watch_job_id_list = {}
	end,
})
