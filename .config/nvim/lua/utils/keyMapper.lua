local keyMapper = function(from, to, opts, mode)
	local options = { noremap = true, silent = true }
	mode = mode or "n"

	if opts then
		options = vim.tbl_extend("force", options, opts)
	end

	vim.keymap.set(mode, from, to, options)
end

-- Only replace cmds, not search; only replace the first instance
local function cmd_abbrev(abbrev, expansion)
	local cmd = "cabbr "
		.. abbrev
		.. ' <c-r>=(getcmdpos() == 1 && getcmdtype() == ":" ? "'
		.. expansion
		.. '" : "'
		.. abbrev
		.. '")<CR>'
	vim.cmd(cmd)
end

return { mapKey = keyMapper, cmd_abbrev = cmd_abbrev }
