return {
	"folke/snacks.nvim",
	---@type snacks.Config
	opts = {
		-- statuscolumn = {},
		bigfile = { enabled = true, line_length = 100 },
		scope = {},
		indent = { enabled = false },
		scroll = {
			animate = {
				easing = "outExpo",
				-- duration = 100,
				fps = 240,
			},
		},
		picker = {
			sources = {
				files = {
					hidden = true,
					layout = {
						preset = function()
							return require("utils.screen").is_vsplit() and "default" or "vertical"
						end,
						layout = {
							width = 0.8,
						},
					},
				},
				buffers = {
					layout = {
						preset = function()
							return require("utils.screen").is_vsplit() and "default" or "vertical"
						end,
						layout = {
							width = 0.8,
						},
					},
				},
				grep = {
					hidden = true,
					layout = {
						preset = function()
							return require("utils.screen").is_vsplit() and "default" or "vertical"
						end,
						layout = {
							width = 0.8,
						},
					},
				},
				explorer = {
					hidden = true,
					ignored = true,
					layout = {
						preset = "right",
					},
				},
			},
		},
		dashboard = {
			enabled = true,
			preset = {
				-- Used by the `header` section
				header = [[
                                                       
             ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒            
         ▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒         
       ▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒       
      ▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒      
     ▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒     
      ▒▒▓▓▓▓▓▓▓███▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓███▓▓▓▓▓▓▓▒▒      
     ▒▒▓▓▓▓▓▓█████▓▓███████████████▓▓█████▓▓▓▓▓▓▒▒     
   ▒▒▒▓▓▓▓▓▓████▓█████████████████████▓████▓▓▓▓▓▓▒▒▒   
  ▒▒▒▓▓▓▓▓▓▓▓█▓█████████████████████████▓█▓▓▓▓▓▓▓▓▒▒▒  
  ▒▒▓▓▓▓▓▓▓▓▓▓███████████████████████████▓▓▓▓▓▓▓▓▓▓▒▒  
 ▒▒▒▓▓▓▓▓▓▓▓▓█████████████████████████████▓▓▓▓▓▓▓▓▓▓▒▒ 
 ▒▒▒▒▒▓▓▓▓▓▓█████▓▒▒▒▓████████████▓▒▒▓█████▓▓▓▓▓▓▒▒▒▒▒ 
   ▒▒▒▓▓▓▓▓▓████▓▒▒▒▒▓███████████▓▒▒▒▒▓████▓▓▓▓▓▓▓▒▒   
  ▒▒▒▓▓▓▓▓▓██████▓▒▒▒▓███████████▓▒▒▒▓▓█████▓▓▓▓▓▓▒▒▒  
  ▒▒▒▓▓▓▓▓▓██████████████▓▓▓▓▓██████████████▓▓▓▓▓▓▒▒▒  
 ▒▒▒▒▒▒▒▒▒▓▓████████████▓▒▒▒▒▒▓████████████▓▓▒▒▒▒▒▒▒▒▒ 
 ▒▒▒▒▒▒▒▒▒▓▓██████████████▓▒▓██████████████▓▓▒▒▒▒▒▒▒▒▒ 
 ▒▒▒▒▒▒▒▒▒▒▓▓█████████████████████████████▓▓▒▒▒▒▒▒▒▒▒▒ 
  ▒▒▒▒▒▒▒▒▒▓▓█████████████████████████████▓▓▒▒▒▒▒▒▒▒▒  
  ▒▒▒▒▒▒▒▒▒▒▒▓▓█████████████████████████▓▓▓▒▒▒▒▒▒▒▒▒▒  
      ▒▒▒▒▒▒▒▒▓▓▓████████▓▓▒▓▓████████▓▓▓▒▒▒▒▒▒▒▒      
       ▒▒▒▒▒▒▒▒▒▓▓▓▓▓██▓▒▒▓▓▓▒▒▓██▓▓▓▓▓▒▒▒▒▒▒▒▒▒       
         ▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒        
           ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▒▒           
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒               
                  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒                  
                    ▒▒▒▒▒▒▒▒▒▒▒▒▒▒                     
                        ▒▒▒▒▒▒▒                        
                                                       
                                        
    __    __________     ____  _______    __
   / /   / ____/ __ \   / __ \/ ____/ |  / /
  / /   / __/ / / / /  / / / / __/  | | / / 
 / /___/ /___/ /_/ /  / /_/ / /___  | |/ /  
/_____/_____/\____/  /_____/_____/  |___/   
    ]],
				-- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
				---@type fun(cmd:string, opts:table)|nil
				pick = nil,
				-- Used by the `keys` section to show keymaps.
				-- Set your custom keymaps here.
				-- When using a function, the `items` argument are the default keymaps.
				---@type snacks.dashboard.Item[]
				keys = {
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					-- { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = "<leader>fR",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{
						icon = "󰒲 ",
						key = "L",
						desc = "Lazy",
						action = ":Lazy",
						enabled = package.loaded.lazy ~= nil,
					},
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header" },
				{ pane = 2, section = "keys", gap = 1, padding = 4 },
				{ pane = 2, section = "startup" },
			},
		},
	},
}
