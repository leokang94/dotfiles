return {
	"pteroctopus/faster.nvim",
	-- https://github.com/pteroctopus/faster.nvim/issues/2
	opts = function()
		vim.api.nvim_create_autocmd("BufReadPost", {
			pattern = "*.js",
			group = vim.api.nvim_create_augroup("faster_bigfile_custom", {}),
			callback = function(args)
				local line_count = vim.api.nvim_buf_line_count(args.buf)
				---@diagnostic disable-next-line: undefined-field
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))

				-- if file is at least 10k and the average bytes per line is > 250, then disable everything
				if ok and stats and (stats.size > (10 * 1024)) and (stats.size / line_count) > 250 then
					vim.notify(
						"Disabling for long js file, bytes: "
							.. stats.size
							.. ", lines: "
							.. line_count
							.. ", bytes / lines: "
							.. math.floor(stats.size / line_count)
					)
					vim.cmd("FasterDisableAllFeatures")
					vim.b[args.buf].trouble_lualine = false
				end
			end,
			desc = "[faster.nvim] Performance rule for handling js file with long lines",
		})

		return {}
	end,
}
