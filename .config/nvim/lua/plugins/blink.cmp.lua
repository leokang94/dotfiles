return {
	{
		"saghen/blink.cmp",
		dependencies = {
			"avante.nvim",
			"saghen/blink.compat",
			"onsails/lspkind.nvim", -- VSCode-like pictograms
		},
		version = "*",
		opts = function(_, opts)
			opts.enabled = function()
				local disabled = false

				disabled = disabled or vim.bo.filetype == "NvimTree"

				return not disabled
			end

			opts.keymap = {
				preset = "enter",
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
				["<A-1>"] = {
					function(cmp)
						cmp.accept({ index = 1 })
					end,
				},
				["<A-2>"] = {
					function(cmp)
						cmp.accept({ index = 2 })
					end,
				},
				["<A-3>"] = {
					function(cmp)
						cmp.accept({ index = 3 })
					end,
				},
				["<A-4>"] = {
					function(cmp)
						cmp.accept({ index = 4 })
					end,
				},
				["<A-5>"] = {
					function(cmp)
						cmp.accept({ index = 5 })
					end,
				},
				["<A-6>"] = {
					function(cmp)
						cmp.accept({ index = 6 })
					end,
				},
				["<A-7>"] = {
					function(cmp)
						cmp.accept({ index = 7 })
					end,
				},
				["<A-8>"] = {
					function(cmp)
						cmp.accept({ index = 8 })
					end,
				},
				["<A-9>"] = {
					function(cmp)
						cmp.accept({ index = 9 })
					end,
				},
				["<A-0>"] = {
					function(cmp)
						cmp.accept({ index = 10 })
					end,
				},
			}

			opts.completion = {
				menu = {
					border = "single",
					scrollbar = false,
					auto_show = true,
					draw = {
						columns = { { "item_idx" }, { "kind_icon" }, { "label", "label_description", gap = 1 } },
						components = {
							item_idx = {
								text = function(ctx)
									return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
								end,
								highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
							},

							kind_icon = {
								ellipsis = false,
								-- text = function(ctx)
								--   return ctx.kind_icon .. ctx.icon_gap
								-- end,
								text = function(ctx)
									local icon = ctx.kind_icon
									if vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											icon = dev_icon
										end
									else
										icon = require("lspkind").symbolic(ctx.kind, {
											mode = "symbol",
										})
									end

									return icon .. ctx.icon_gap
								end,
								-- Optionally, use the highlight groups from nvim-web-devicons
								-- You can also add the same function for `kind.highlight` if you want to
								-- keep the highlight groups in sync with the icons.
								highlight = function(ctx)
									local hl = "BlinkCmpKind" .. ctx.kind
										or require("blink.cmp.completion.windows.render.tailwind").get_hl(ctx)
									if vim.tbl_contains({ "Path" }, ctx.source_name) then
										local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
										if dev_icon then
											hl = dev_hl
										end
									end
									return hl
								end,
								-- highlight = function(ctx)
								--   return (
								--     require("blink.cmp.completion.windows.render.tailwind").get_hl(ctx)
								--     or "BlinkCmpKind"
								--   ) .. ctx.kind
								-- end,
							},

							kind = {
								ellipsis = false,
								width = { fill = true },
								text = function(ctx)
									return ctx.kind
								end,
								highlight = function(ctx)
									return (
										require("blink.cmp.completion.windows.render.tailwind").get_hl(ctx)
										or "BlinkCmpKind"
									) .. ctx.kind
								end,
							},

							label = {
								width = { fill = true, max = 60 },
								text = function(ctx)
									return ctx.label .. ctx.label_detail
								end,
								highlight = function(ctx)
									vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", {
										fg = vim.g.color.purple,
										bold = true,
									})
									vim.api.nvim_set_hl(0, "BlinkCmpLabelDescription", {
										fg = vim.g.color.comment,
									})

									-- label and label details
									local highlights = {
										{
											0,
											#ctx.label,
											group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
										},
									}
									if ctx.label_detail then
										table.insert(highlights, {
											#ctx.label,
											#ctx.label + #ctx.label_detail,
											group = "BlinkCmpLabelDetail",
										})
									end

									-- characters matched on the label by the fuzzy matcher
									for _, idx in ipairs(ctx.label_matched_indices) do
										table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
									end

									return highlights
								end,
							},

							label_description = {
								width = { max = 30 },
								text = function(ctx)
									return ctx.label_description
								end,
								highlight = "BlinkCmpLabelDescription",
							},

							source_name = {
								width = { max = 30 },
								text = function(ctx)
									return ctx.source_name
								end,
								highlight = "BlinkCmpSource",
							},
						},
					},
				},
				list = {
					selection = {
						preselect = true,
						auto_insert = false,
					},
				},
				documentation = {
					window = {
						border = "single",
					},
				},
			}

			opts.cmdline = {
				enabled = true,
				keymap = nil, -- Inherits from top level `keymap` config when not set
				sources = function()
					local type = vim.fn.getcmdtype()

					-- Search forward and backward
					-- if type == '/' or type == '?' then return { 'buffer' } end

					-- Commands
					if type == ":" then
						return { "cmdline" }
					end
					return {}
				end,
				completion = {
					trigger = {
						show_on_blocked_trigger_characters = {},
						show_on_x_blocked_trigger_characters = nil, -- Inherits from top level `completion.trigger.show_on_blocked_trigger_characters` config when not set
					},
					menu = {
						auto_show = nil, -- Inherits from top level `completion.menu.auto_show` config when not set
						draw = {
							columns = { { "label", "label_description", gap = 1 } },
						},
					},
				},
			}

			opts.sources = {
				default = {
					"lsp",
					"path",
					"buffer",
					"avante_commands",
					"avante_mentions",
				},
				compat = {
					"avante_commands",
					"avante_mentions",
				},
				providers = {
					avante_commands = {
						name = "avante_commands",
						module = "blink.compat.source",
						score_offset = 90,
						opts = {},
					},
					avante_files = {
						name = "avante_commands",
						module = "blink.compat.source",
						score_offset = 100,
						opts = {},
					},
				},
				transform_items = function(_, items)
					return vim.tbl_filter(function(item)
						return item.kind ~= require("blink.cmp.types").CompletionItemKind.Snippet
					end, items)
				end,
			}
		end,
	},
}
