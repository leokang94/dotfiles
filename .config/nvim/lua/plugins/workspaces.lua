local cmd_abbrev = require("utils.keyMapper").cmd_abbrev

cmd_abbrev("wo", "WorkspacesOpen")
cmd_abbrev("wa", "WorkspacesAdd")

return {
	"natecraddock/workspaces.nvim",
	config = true,
	opts = {
		hooks = {
			open_pre = function()
				require("sessions").stop_autosave()
				vim.cmd("silent %bdelete!")
			end,
			open = function()
				require("sessions").load(nil, { silent = true })
				require("sessions").save()
			end,
		},
	},
}
