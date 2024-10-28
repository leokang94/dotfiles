local M = {}

local blends = {
	normal = 0.5,
	insert = 0.5,
	visual = 0.6,
	command = 0.5,
	operator = 0.5,
	replace = 0.5,
	select = 0.5,
	terminal = 0.5,
	terminal_n = 0.5,
}

local function setup_hl_namespaces()
	M.ns_normal = vim.api.nvim_create_namespace("Moody_NORMAL_NS")
	M.ns_insert = vim.api.nvim_create_namespace("Moody_INSERT_NS")
	M.ns_visual = vim.api.nvim_create_namespace("Moody_VISUAL_NS")
	M.ns_command = vim.api.nvim_create_namespace("Moody_COMMAND_NS")
	M.ns_operator = vim.api.nvim_create_namespace("Moody_OPERATOR_NS")
	M.ns_replace = vim.api.nvim_create_namespace("Moody_REPLACE_NS")
	M.ns_select = vim.api.nvim_create_namespace("Moody_SELECT_NS")
	M.ns_terminal = vim.api.nvim_create_namespace("Moody_TERMINAL_NS")
	M.ns_terminal_n = vim.api.nvim_create_namespace("Moody_TERMINAL_N_NS")
end

return {
	"svampkorg/moody.nvim",
	event = { "ModeChanged", "BufWinEnter", "WinEnter" },
	dependencies = {
		"binhtran432k/dracula.nvim",
	},
	opts = {
		blends = blends,
		bold_nr = true,
		disabled_filetypes = { "TelescopePrompt" },
		recording = {
			enabled = true,
			icon = "󰑋",
			-- you can set some text to surround the recording registry char with
			-- or just set one to empty to maybe have just one letter, an arrow
			-- perhaps! For example recording to q, you could have! "󰑋    q" :D
			pre_registry_text = "[",
			post_registry_text = "]",
		},
	},

	config = function()
		local utils = require("moody.utils")

		setup_hl_namespaces()

		local hl_blended = utils.hl_blended(blends)

		vim.api.nvim_set_hl(M.ns_normal, "CursorLineNr", { bg = hl_blended.normal })

		vim.api.nvim_set_hl(M.ns_insert, "CursorLineNr", { bg = hl_blended.insert })

		vim.api.nvim_set_hl(M.ns_visual, "CursorLineNr", { bg = hl_blended.visual })

		vim.api.nvim_set_hl(M.ns_command, "CursorLineNr", { bg = hl_blended.command })

		vim.api.nvim_set_hl(M.ns_operator, "CursorLineNr", { bg = hl_blended.operator })

		vim.api.nvim_set_hl(M.ns_replace, "CursorLineNr", { bg = hl_blended.replace })

		vim.api.nvim_set_hl(M.ns_select, "CursorLineNr", { bg = hl_blended.select })

		vim.api.nvim_set_hl(M.ns_terminal, "CursorLineNr", { bg = hl_blended.terminal })

		vim.api.nvim_set_hl(M.ns_terminal_n, "CursorLineNr", { bg = hl_blended.terminal_n })
	end,
}
