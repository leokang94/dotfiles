-- picker {win, action} options :: inspired by https://github.com/gibfahn/dot/blob/bf37585f4376ac098c4b33f6ea4cf2a6b7944d32/dotfiles/.config/nvim/lua/plugins/init.lua

return {
	"folke/snacks.nvim",
	---@type snacks.Config
	opts = {
		statuscolumn = { enabled = true },
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
		input = { enabled = true },
		picker = {
			enabled = true,
			ui_select = true,

			sources = {
				files = {
					hidden = true,
				},
				grep = {
					hidden = true,
					-- args = {
					-- 	"--glob",
					-- 	"!*-lock.json",
					-- },
				},
				explorer = {
					hidden = true,
					ignored = true,
					layout = {
						preset = "right",
					},
				},
			},

			layout = {
				preset = function()
					return require("utils.screen").is_vsplit() and "default" or "vertical"
				end,
				layout = {
					width = 0.9,
				},
			},

			win = {
				-- Make file truncation consider window width.
				-- <https://github.com/folke/snacks.nvim/issues/1217#issuecomment-2661465574>
				list = {
					on_buf = function(self)
						self:execute("calculate_file_truncate_width")
					end,
				},
				preview = {
					on_buf = function(self)
						self:execute("calculate_file_truncate_width")
					end,
					on_close = function(self)
						self:execute("calculate_file_truncate_width")
					end,
				},
			},
			actions = {
				-- Make file truncation consider window width.
				-- <https://github.com/folke/snacks.nvim/issues/1217#issuecomment-2661465574>
				calculate_file_truncate_width = function(self)
					local width = self.list.win:size().width
					self.opts.formatters.file.truncate = width - 6
				end,
			},
		},

		notifier = {
			top_down = false,
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
	config = function(_, opts)
		require("snacks").setup(opts)

		---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
		local progress = vim.defaulttable()
		vim.api.nvim_create_autocmd("LspProgress", {
			---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
				if not client or type(value) ~= "table" then
					return
				end
				local p = progress[client.id]

				for i = 1, #p + 1 do
					if i == #p + 1 or p[i].token == ev.data.params.token then
						p[i] = {
							token = ev.data.params.token,
							msg = ("[%3d%%] %s%s"):format(
								value.kind == "end" and 100 or value.percentage or 100,
								value.title or "",
								value.message and (" **%s**"):format(value.message) or ""
							),
							done = value.kind == "end",
						}
						break
					end
				end

				local msg = {} ---@type string[]
				progress[client.id] = vim.tbl_filter(function(v)
					return table.insert(msg, v.msg) or not v.done
				end, p)

				local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
				vim.notify(table.concat(msg, "\n"), "info", {
					id = "lsp_progress",
					title = client.name,
					opts = function(notif)
						notif.icon = #progress[client.id] == 0 and " "
							or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
					end,
				})
			end,
		})
	end,
}
