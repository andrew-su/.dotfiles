local wezterm = require("wezterm")
local config = wezterm.config_builder()
local action = wezterm.action

config.set_environment_variables = {
	PATH = "/opt/homebrew/bin:" .. os.getenv("PATH"),
}

config.font = wezterm.font({
	family = "JetBrains Mono",
	weight = "Medium",
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
})
config.font_size = 12.0
config.line_height = 1.0
config.bold_brightens_ansi_colors = true
-- config.color_scheme = "Ciapre"
-- config.color_scheme = "Monokai (dark) (terminal.sexy)"
-- config.color_scheme = "Rosé Pine (base16)"
config.color_scheme = "GruvboxDarkHard"
-- config.color_scheme = "Solarized Dark - Patched"
config.window_decorations = "RESIZE|INTEGRATED_BUTTONS"
config.window_padding = { left = "0.5cell", right = "0.5cell", top = "0.5cell", bottom = "0.5cell" }
config.window_background_opacity = 0.96
config.macos_window_background_blur = 20
config.default_cursor_style = "BlinkingBar"

config.window_frame = {
	border_left_width = "0.25cell",
	border_right_width = "0.25cell",
	border_bottom_height = "0.1cell",
	border_top_height = "0.1cell",
	border_left_color = "orange",
	border_right_color = "orange",
	border_bottom_color = "orange",
	border_top_color = "orange",
}

-- https://github.com/wez/wezterm/issues/3299#issuecomment-2145712082
wezterm.on("gui-startup", function(cmd)
	local active = wezterm.gui.screens().active
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():set_position(active.x, active.y)
	window:gui_window():set_inner_size(active.width, active.height)
end)

config.keys = {
	{ key = "d", mods = "CMD|SHIFT", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "k", mods = "CMD", action = action.ClearScrollback("ScrollbackAndViewport") },
	{ key = "w", mods = "CMD", action = action.CloseCurrentPane({ confirm = false }) },
	{ key = "w", mods = "CMD|SHIFT", action = action.CloseCurrentTab({ confirm = false }) },
	{ key = "LeftArrow", mods = "CMD", action = action.SendKey({ key = "Home" }) },
	{ key = "RightArrow", mods = "CMD", action = action.SendKey({ key = "End" }) },
	{ key = "p", mods = "CMD|SHIFT", action = action.ActivateCommandPalette },
	{
		key = ",",
		mods = "CMD",
		action = action.SpawnCommandInNewTab({ cwd = wezterm.home_dir, args = { "zed", wezterm.config_file } }),
	},
}

-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
	-- regex = "\\b\\d\\{1,3\\}\\.\\d\\{1,3\\}\\.\\d\\{1,3\\}\\.\\d\\{1,3\\}\\b",
	-- regex = "(\\b25[0-5]|\\b2[0-4][0-9]|\\b[01]?[0-9][0-9]?)(\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}",
	regex = "\\b((25[0-5])|(2[0-4][0-9])|([01]?[0-9]?[0-9]))(?:\\.((25[0-5])|(2[0-4][0-9])|([01]?[0-9]?[0-9]))){3}\\b",
	format = "ip:$0",
})

local uri_handlers = {
	["mailto:"] = function(window, pane, content)
		window:copy_to_clipboard(content)
	end,
	["ip:"] = function(window, pane, content)
		window:copy_to_clipboard(content)
	end,
}

wezterm.on("open-uri", function(window, pane, uri)
	for prefix, handler in pairs(uri_handlers) do
		local start, match_end = uri:find(prefix)
		if start == 1 then
			local content = uri:sub(match_end + 1)
			handler(window, pane, content)
			-- prevent the default action from opening in a browser
			return false
		end
	end
	-- otherwise, by not specifying a return value, we allow later
	-- handlers and ultimately the default action to caused the
	-- URI to be opened in the browser
end)

return config
