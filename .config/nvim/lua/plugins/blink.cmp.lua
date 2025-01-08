return {
	{
		"saghen/blink.cmp",
		opts = {
			enabled = function()
				local disabled = false

				disabled = disabled or vim.bo.filetype == "NvimTree"

				return not disabled
			end,
			sources = {
				default = {
					"lsp",
					"path",
					"buffer",
				},
				transform_items = function(_, items)
					return vim.tbl_filter(function(item)
						return item.kind ~= require("blink.cmp.types").CompletionItemKind.Snippet
					end, items)
				end,
			},

			keymap = {
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
			},

			completion = {
				menu = {
					border = "single",
					scrollbar = false,
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
								text = function(ctx)
									return ctx.kind_icon .. ctx.icon_gap
								end,
								highlight = function(ctx)
									return (
										require("blink.cmp.completion.windows.render.tailwind").get_hl(ctx)
										or "BlinkCmpKind"
									) .. ctx.kind
								end,
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
				documentation = {
					window = {
						border = "single",
					},
				},
			},

			signature = {
				window = {
					border = "single",
				},
			},
		},
	},
}
