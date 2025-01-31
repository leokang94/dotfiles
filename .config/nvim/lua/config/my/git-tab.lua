local is_vsplit_func = require("utils.screen").is_vsplit

_G.channel_buf_map = {}

local function open_terminals()
	vim.cmd("tabnew")

	local width = vim.o.columns
	local height = vim.o.lines
	-- local is_vsplit = width > height * 3
	local is_vsplit = is_vsplit_func()
	local split_cmd = is_vsplit and "vsplit" or "split"

	vim.cmd("terminal")
	vim.cmd("startinsert")
	local terminal_1_buf = vim.api.nvim_get_current_buf()

	vim.cmd(split_cmd)
	vim.cmd("terminal")
	vim.cmd("startinsert")
	local terminal_2_buf = vim.api.nvim_get_current_buf()
	local current_channel = vim.bo.channel
	_G.channel_buf_map[current_channel] = { terminal_1_buf, terminal_2_buf }

	vim.api.nvim_chan_send(current_channel, "git watch\n")

	if is_vsplit then
		vim.cmd("vertical resize " .. math.floor(width * 0.7))
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
	callback = function(ev)
		for channel, buffers in pairs(_G.channel_buf_map) do
			if vim.tbl_contains(buffers, ev.buf) then
				local jobstop_result = vim.fn.jobstop(channel)
				print("Stopped channel:", channel, "Result:", (jobstop_result == 1 and "Success" or "Failed"))
				_G.channel_buf_map[channel] = nil
				break
			end
		end
	end,
})

vim.api.nvim_create_autocmd("TabEnter", {
	pattern = "*",
	callback = function(ev)
		print("TabEnter event ->", vim.inspect(ev))
	end,
})
