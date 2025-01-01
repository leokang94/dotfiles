local wezterm = require("wezterm")

-- Settings
local config = {}
-- Use config builder object if possible
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- 안녕하세요

config.term = "wezterm"
config.color_scheme = "Dracula (Official)"
config.hide_tab_bar_if_only_one_tab = true

config.front_end = "WebGpu"
config.max_fps = 240

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"

local fontScale = 1.2
config.font = wezterm.font_with_fallback({
	{ family = "MonaspiceXe Nerd Font Mono", weight = "ExtraLight", scale = fontScale },
	-- { family = "MonaspiceKr Nerd Font", weight = "ExtraLight", scale = fontScale },
	{ family = "SF Pro Text", weight = "ExtraLight", scale = fontScale },
	{ family = "D2Coding ligature", scale = fontScale },
})
config.harfbuzz_features = { "calt", "liga", "dlig" }

-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
	regex = [[(BUN-\d+)]],
	format = "https://quicket.atlassian.net/browse/$1",
})
table.insert(config.hyperlink_rules, {
	regex = [[(TECH-\d+)]],
	format = "https://quicket.atlassian.net/browse/$1",
})

-- config.enable_scroll_bar = false
config.window_background_opacity = 0.95
config.text_background_opacity = 1
config.macos_window_background_blur = 10

wezterm.on("opacity-up", function(window)
	local overrides = window:get_config_overrides() or {}

	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 1
	else
		local prevOpacity = overrides.window_background_opacity
		local nextOpacity = prevOpacity + 0.05
		if nextOpacity > 1 then
			nextOpacity = 1
		end

		overrides.window_background_opacity = nextOpacity
	end

	window:set_config_overrides(overrides)
end)

wezterm.on("opacity-down", function(window)
	local overrides = window:get_config_overrides() or {}

	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 1
	else
		local prevOpacity = overrides.window_background_opacity
		local nextOpacity = prevOpacity - 0.05
		if nextOpacity < 0 then
			nextOpacity = 0
		end

		overrides.window_background_opacity = nextOpacity
	end

	window:set_config_overrides(overrides)
end)

local resizeValue = 10
local action = wezterm.action

config.leader = { key = "0", mods = "CTRL|CMD", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "\\", -- HACK :: "|" replace
		mods = "CTRL|CMD",
		action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "CTRL|CMD",
		action = action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{ key = "h", mods = "CTRL|CMD", action = action({ ActivatePaneDirection = "Left" }) },
	{ key = "j", mods = "CTRL|CMD", action = action({ ActivatePaneDirection = "Down" }) },
	{ key = "k", mods = "CTRL|CMD", action = action({ ActivatePaneDirection = "Up" }) },
	{ key = "l", mods = "CTRL|CMD", action = action({ ActivatePaneDirection = "Right" }) },
	{ key = "h", mods = "SHIFT|CMD", action = action.AdjustPaneSize({ "Left", resizeValue }) },
	{ key = "j", mods = "SHIFT|CMD", action = action.AdjustPaneSize({ "Down", resizeValue }) },
	{ key = "k", mods = "SHIFT|CMD", action = action.AdjustPaneSize({ "Up", resizeValue }) },
	{ key = "l", mods = "SHIFT|CMD", action = action.AdjustPaneSize({ "Right", resizeValue }) },
	{ key = "w", mods = "CTRL|CMD", action = action.CloseCurrentPane({ confirm = true }) },
	{ key = "n", mods = "CTRL|CMD", action = action.RotatePanes("Clockwise") },
	{ key = "b", mods = "CTRL|CMD", action = action.RotatePanes("CounterClockwise") },
	{
		key = "m",
		mods = "CTRL|CMD",
		action = action.TogglePaneZoomState,
	},
	{
		key = "o",
		mods = "CTRL|OPT",
		action = action.EmitEvent("opacity-down"),
	},
	{
		key = "O",
		mods = "CTRL|OPT",
		action = action.EmitEvent("opacity-up"),
	},

	{
		key = "/",
		mods = "CTRL|CMD",
		action = action.QuickSelect,
	},
	{ key = "{", mods = "SHIFT|ALT", action = action.MoveTabRelative(-1) },
	{ key = "}", mods = "SHIFT|ALT", action = action.MoveTabRelative(1) },
	{ key = "LeftArrow", mods = "CTRL|ALT", action = action.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "CTRL|ALT", action = action.ActivateTabRelative(1) },
	-- detach pane to window
	{
		key = "w",
		mods = "LEADER",
		---@diagnostic disable-next-line: unused-local
		action = wezterm.action_callback(function(win, pane)
			---@diagnostic disable-next-line: unused-local
			local tab, window = pane:move_to_new_window()
		end),
	},
	-- detach pane to tab
	{
		key = "t",
		mods = "LEADER",
		---@diagnostic disable-next-line: unused-local
		action = wezterm.action_callback(function(win, pane)
			---@diagnostic disable-next-line: unused-local
			local tab, window = pane:move_to_new_tab()
		end),
	},
	{
		key = "i",
		mods = "LEADER",
		action = action.InputSelector({
			---@diagnostic disable-next-line: unused-local
			action = wezterm.action_callback(function(window, pane, id, label)
				if not id and not label then
					wezterm.log_info("cancelled")
				else
					wezterm.log_info("you selected ", id, label)
					pane:send_text(id)
				end
			end),
			title = "I am title",
			choices = {
				{
					-- Here we're using wezterm.format to color the text.
					-- You can just use a string directly if you don't want
					-- to control the colors
					label = wezterm.format({
						{ Foreground = { AnsiColor = "Red" } },
						{ Text = "No" },
						{ Foreground = { AnsiColor = "Green" } },
						{ Text = " thanks" },
					}),
					-- This is the text that we'll send to the terminal when
					-- this entry is selected
					id = "Regretfully, I decline this offer.",
				},
				-- This is the second entry
				{
					label = "WTF?",
					id = "An interesting idea, but I have some questions about it.",
				},
				-- This is the third entry
				{
					label = "LGTM",
					id = "This sounds like the right choice",
				},
			},
		}),
	},
}

config.window_padding = {
	left = 5,
	right = 5,
	top = 5,
	bottom = 5,
}

-- and finally, return the configuration to wezterm
return config
