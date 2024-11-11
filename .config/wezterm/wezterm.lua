local wezterm = require("wezterm")

-- Settings
local config = {}
-- Use config builder object if possible
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.term = "wezterm"
config.color_scheme = "Dracula (Official)"
config.hide_tab_bar_if_only_one_tab = true

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"

config.font = wezterm.font_with_fallback({
	{ family = "MonaspiceKr Nerd Font", weight = "ExtraLight" },
	{ family = "D2Coding ligature" },
})
config.harfbuzz_features = { "calt", "liga", "dlig" }

-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
	regex = [[(BUN-\d+)]],
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
}

config.window_padding = {
	left = 5,
	right = 5,
	top = 5,
	bottom = 5,
}

-- and finally, return the configuration to wezterm
return config
