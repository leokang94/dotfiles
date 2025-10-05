local get_is_vsplit = require("utils.screen").is_vsplit

-- Module-local state management
local M = {}
local channel_buf_map = {}
local git_tab_windows = {}

-- Constants
local WINDOW_SIZE = {
	VSPLIT_WIDTH_RATIO = 0.7,
	HSPLIT_HEIGHT_RATIO = 0.8,
}
local DEBOUNCE_DELAY_MS = 100

local function apply_window_sizes(tab_id, is_vsplit)
	local width = vim.o.columns
	local height = vim.o.lines

	local tab_info = git_tab_windows[tab_id or vim.api.nvim_get_current_tabpage()]
	if not tab_info then
		return
	end

	if vim.api.nvim_win_is_valid(tab_info.terminal_2_win) then
		-- Use Neovim API to directly set window size
		if is_vsplit then
			-- Set width of terminal_2_win (right window)
			vim.api.nvim_win_set_width(tab_info.terminal_2_win, math.floor(width * WINDOW_SIZE.VSPLIT_WIDTH_RATIO))
		else
			-- Set height of terminal_2_win (bottom window)
			vim.api.nvim_win_set_height(tab_info.terminal_2_win, math.floor(height * WINDOW_SIZE.HSPLIT_HEIGHT_RATIO))
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
	channel_buf_map[current_channel] = { terminal_1_buf, terminal_2_buf }

	-- Store window information for this tab
	git_tab_windows[tab_id] = {
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

	vim.api.nvim_set_current_win(terminal_1_win)
end

M.open_terminals = open_terminals

vim.api.nvim_set_keymap(
	"n",
	"<leader>gt",
	":lua require('config.my.git-tab').open_terminals()<CR>",
	{ desc = "git-tab", noremap = true, silent = true }
)

-- Function to handle screen resize and maintain window proportions
local function handle_screen_resize()
	local current_tab = vim.api.nvim_get_current_tabpage()
	local tab_info = git_tab_windows[current_tab]

	-- Only handle resize if current tab is a git-tab
	if not tab_info then
		-- Clean up any tabs that no longer exist
		local existing_tabs = vim.api.nvim_list_tabpages()
		for tab_id in pairs(git_tab_windows) do
			if not vim.tbl_contains(existing_tabs, tab_id) then
				git_tab_windows[tab_id] = nil
			end
		end
		return
	end

	-- Check if we need to change split orientation based on new screen size
	local new_is_vsplit = get_is_vsplit()

	-- If split orientation should change, reorganize the windows
	if new_is_vsplit ~= tab_info.is_vsplit then
		-- Save which buffer/window currently has focus
		local current_win = vim.api.nvim_get_current_win()
		local current_buf = vim.api.nvim_win_get_buf(current_win)
		local was_in_terminal_1 = (current_buf == tab_info.terminal_1_buf)

		-- Close all windows except one
		local windows = vim.api.nvim_tabpage_list_wins(current_tab)
		for i = 2, #windows do
			vim.api.nvim_win_close(windows[i], false)
		end

		-- Make sure we're in the first terminal window
		local first_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(first_win, tab_info.terminal_1_buf)

		-- Create new split with correct orientation
		local split_cmd = new_is_vsplit and "vsplit" or "split"
		vim.cmd(split_cmd)

		-- Set the second terminal buffer in the new window
		local second_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(second_win, tab_info.terminal_2_buf)

		-- Update the stored information
		tab_info.is_vsplit = new_is_vsplit
		tab_info.terminal_1_win = first_win
		tab_info.terminal_2_win = second_win

		-- Restore focus to the original window
		vim.api.nvim_set_current_win(was_in_terminal_1 and first_win or second_win)
	end

	-- Apply window sizes regardless of orientation change
	apply_window_sizes(current_tab, tab_info.is_vsplit)
end

-- Function to maintain window sizes when they get reset
local function maintain_window_sizes()
	local current_tab = vim.api.nvim_get_current_tabpage()
	local tab_info = git_tab_windows[current_tab]

	if tab_info then
		-- Check if current window is one of our git-tab terminals
		local current_win = vim.api.nvim_get_current_win()
		local current_buf = vim.api.nvim_win_get_buf(current_win)

		if current_buf == tab_info.terminal_1_buf or current_buf == tab_info.terminal_2_buf then
			apply_window_sizes(current_tab, tab_info.is_vsplit)
		end
	end
end

-- Cleanup function for terminal channels and tab tracking
local function cleanup_terminal(buf)
	-- Clean up channel map
	for channel, buffers in pairs(channel_buf_map) do
		if vim.tbl_contains(buffers, buf) then
			local jobstop_result = vim.fn.jobstop(channel)
			if jobstop_result == 1 then
				channel_buf_map[channel] = nil
			end
			break
		end
	end

	-- Clean up git tab windows tracking
	for tab_id, tab_info in pairs(git_tab_windows) do
		if buf == tab_info.terminal_1_buf or buf == tab_info.terminal_2_buf then
			git_tab_windows[tab_id] = nil
			break
		end
	end
end

vim.api.nvim_create_autocmd("TabClosed", {
	pattern = "*",
	callback = function(ev)
		cleanup_terminal(ev.buf)
	end,
})

-- Debounced resize handler using vim.defer_fn
local resize_scheduled = false

local function debounced_resize_handler()
	if resize_scheduled then
		return
	end

	resize_scheduled = true
	vim.defer_fn(function()
		handle_screen_resize()
		resize_scheduled = false
	end, DEBOUNCE_DELAY_MS)
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

-- Maintain window sizes when entering windows or buffers
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	pattern = "*",
	callback = maintain_window_sizes,
})

-- Manual command to fix window sizes
vim.api.nvim_create_user_command("GitTabFix", function()
	local current_tab = vim.api.nvim_get_current_tabpage()
	local tab_info = git_tab_windows[current_tab]
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

return M
