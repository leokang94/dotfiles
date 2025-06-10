local get_is_vsplit = require("utils.screen").is_vsplit

_G.channel_buf_map = {}
_G.git_tab_windows = {}

local function apply_window_sizes(tab_id, is_vsplit)
	local width = vim.o.columns
	local height = vim.o.lines

	local tab_info = _G.git_tab_windows[tab_id or vim.api.nvim_get_current_tabpage()]
	if not tab_info then
		return
	end

	if vim.api.nvim_win_is_valid(tab_info.terminal_2_win) then
		-- Use Neovim API to directly set window size
		if is_vsplit then
			-- Set width of terminal_2_win (right window)
			vim.api.nvim_win_set_width(tab_info.terminal_2_win, math.floor(width * 0.7))
		else
			-- Set height of terminal_2_win (bottom window)
			vim.api.nvim_win_set_height(tab_info.terminal_2_win, math.floor(height * 0.8))
		end

		-- Move cursor to the first terminal window
		if vim.api.nvim_win_is_valid(tab_info.terminal_1_win) then
			vim.api.nvim_set_current_win(tab_info.terminal_1_win)
		end
	end
end

local function open_terminals()
	vim.cmd("tabnew")
	local tab_id = vim.api.nvim_get_current_tabpage()

	-- local is_vsplit = width > height * 3
	local is_vsplit = get_is_vsplit()
	local split_cmd = is_vsplit and "vsplit" or "split"

	vim.cmd("terminal")
	vim.cmd("startinsert")
	local terminal_1_buf = vim.api.nvim_get_current_buf()
	local terminal_1_win = vim.api.nvim_get_current_win()

	vim.cmd(split_cmd)
	vim.cmd("terminal")
	vim.cmd("startinsert")
	local terminal_2_buf = vim.api.nvim_get_current_buf()
	local terminal_2_win = vim.api.nvim_get_current_win()
	local current_channel = vim.bo.channel
	_G.channel_buf_map[current_channel] = { terminal_1_buf, terminal_2_buf }

	-- Store window information for this tab
	_G.git_tab_windows[tab_id] = {
		is_vsplit = is_vsplit,
		terminal_1_win = terminal_1_win,
		terminal_2_win = terminal_2_win,
		terminal_1_buf = terminal_1_buf,
		terminal_2_buf = terminal_2_buf,
		channel = current_channel,
	}

	vim.api.nvim_chan_send(current_channel, "git watch\n")

	apply_window_sizes(tab_id, is_vsplit)

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

-- Function to handle screen resize and maintain window proportions
local function handle_screen_resize()
	local current_tab = vim.api.nvim_get_current_tabpage()
	local tab_info = _G.git_tab_windows[current_tab]

	-- Only handle resize if current tab is a git-tab
	if tab_info then
		-- Check if we need to change split orientation based on new screen size
		local new_is_vsplit = get_is_vsplit()

		-- If split orientation should change, reorganize the windows
		if new_is_vsplit ~= tab_info.is_vsplit then
			-- Close all windows except one
			local windows = vim.api.nvim_tabpage_list_wins(current_tab)
			for i = 2, #windows do
				vim.api.nvim_win_close(windows[i], false)
			end

			-- Make sure we're in the first terminal window
			vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), tab_info.terminal_1_buf)
			local terminal_1_win = vim.api.nvim_get_current_win()

			-- Create new split with correct orientation
			local split_cmd = new_is_vsplit and "vsplit" or "split"
			vim.cmd(split_cmd)

			-- Set the second terminal buffer in the new window
			vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), tab_info.terminal_2_buf)
			local terminal_2_win = vim.api.nvim_get_current_win()

			-- Update the stored information
			tab_info.is_vsplit = new_is_vsplit
			tab_info.terminal_1_win = terminal_1_win
			tab_info.terminal_2_win = terminal_2_win
		end

		-- Apply window sizes regardless of orientation change
		apply_window_sizes(current_tab, tab_info.is_vsplit)
	end

	-- Clean up any tabs that no longer exist
	local existing_tabs = vim.api.nvim_list_tabpages()
	for tab_id, _ in pairs(_G.git_tab_windows) do
		if not vim.tbl_contains(existing_tabs, tab_id) then
			_G.git_tab_windows[tab_id] = nil
		end
	end
end

-- Function to maintain window sizes when they get reset
local function maintain_window_sizes()
	local current_tab = vim.api.nvim_get_current_tabpage()
	local tab_info = _G.git_tab_windows[current_tab]

	if tab_info then
		-- Check if current window is one of our git-tab terminals
		local current_win = vim.api.nvim_get_current_win()
		local current_buf = vim.api.nvim_win_get_buf(current_win)

		if current_buf == tab_info.terminal_1_buf or current_buf == tab_info.terminal_2_buf then
			apply_window_sizes(current_tab, tab_info.is_vsplit)
		end
	end
end

vim.api.nvim_create_autocmd("TabClosed", {
	pattern = "*",
	callback = function(ev)
		-- Clean up channel map
		for channel, buffers in pairs(_G.channel_buf_map) do
			if vim.tbl_contains(buffers, ev.buf) then
				local jobstop_result = vim.fn.jobstop(channel)
				print("Stopped channel:", channel, "Result:", (jobstop_result == 1 and "Success" or "Failed"))
				_G.channel_buf_map[channel] = nil
				break
			end
		end

		-- Clean up git tab windows tracking
		for tab_id, tab_info in pairs(_G.git_tab_windows) do
			if ev.buf == tab_info.terminal_1_buf or ev.buf == tab_info.terminal_2_buf then
				_G.git_tab_windows[tab_id] = nil
				break
			end
		end
	end,
})

-- Debounce timer for resize events
local resize_timer = nil

-- Debounced resize handler
local function debounced_resize_handler()
	if resize_timer then
		vim.fn.timer_stop(resize_timer)
	end

	resize_timer = vim.fn.timer_start(100, function()
		handle_screen_resize()
		resize_timer = nil
	end)
end

-- Handle screen resize events
vim.api.nvim_create_autocmd("VimResized", {
	pattern = "*",
	callback = debounced_resize_handler,
})

-- Handle window resize events (for cmd + etc.)
vim.api.nvim_create_autocmd("WinResized", {
	pattern = "*",
	callback = debounced_resize_handler,
})

-- Maintain window sizes when entering windows
vim.api.nvim_create_autocmd("WinEnter", {
	pattern = "*",
	callback = maintain_window_sizes,
})

-- Maintain window sizes when buffers are entered
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = maintain_window_sizes,
})

-- Manual command to fix window sizes
vim.api.nvim_create_user_command("GitTabFix", function()
	local current_tab = vim.api.nvim_get_current_tabpage()
	local tab_info = _G.git_tab_windows[current_tab]
	if tab_info then
		apply_window_sizes(current_tab, tab_info.is_vsplit)
		print("Git-tab window sizes fixed!")
	else
		print("No git-tab found in current tab")
	end
end, { desc = "Fix git-tab window sizes" })

-- vim.api.nvim_create_autocmd("TabEnter", {
-- 	pattern = "*",
-- 	callback = function(ev)
-- 		print("TabEnter event ->", vim.inspect(ev))
-- 	end,
-- })
