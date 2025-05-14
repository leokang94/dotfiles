return {
	"ravitemer/mcphub.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
	},
	cmd = "MCPHub", -- lazily start the hub when `MCPHub` is called
	build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
	-- build = "bundled_build.lua",
	-- use_bundleed_binary = true,
	opts = {
		auto_approve = true,
	},
}
