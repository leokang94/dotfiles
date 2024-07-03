return {
	"dmmulroy/tsc.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = true,
	opts = {
		auto_start_watch_mode = true,
		run_as_monorepo = true,
		use_trouble_qflist = true,
		auto_open_qflist = true,
		auto_close_qflist = true,
		use_diagnostics = true,
		flags = {
			watch = true,
		},
	},
}
