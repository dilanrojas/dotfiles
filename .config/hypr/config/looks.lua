-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 6,

		border_size = 2,

		col = {
			active_border = { colors = { "rgba(549e6aff)" } },
			inactive_border = "rgba(394a44ff)",
		},

		resize_on_border = false,

		allow_tearing = true,

		layout = "dwindle",
	},

	decoration = {
		rounding = 8,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		dim_inactive = false,
		dim_strength = 0.1,

		shadow = {
			enabled = true,
			range = 48,
			render_power = 3,
			sharp = false,
			color = "rgba(0000004d)",
			color_inactive = "rgba(00000026)",
			offset = "0 10",
			scale = 0.97,
		},

		blur = {
			enabled = false,
			size = 7,
			passes = 3,
			vibrancy = 0.0,
			noise = 0.04,
			popups = false,
			brightness = 1.0,
			contrast = 1.0,
			new_optimizations = true,
			xray = false,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Smart gaps
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
-- 	name = "no-gaps-wtv1",
-- 	match = { float = false, workspace = "w[tv1]" },
-- 	border_size = 0,
-- 	rounding = 0,
-- })
-- hl.window_rule({
-- 	name = "no-gaps-f1",
-- 	match = { float = false, workspace = "f[1]" },
-- 	border_size = 0,
-- 	rounding = 0,
-- })

-- Default animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("macOpen", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("macIn", { type = "bezier", points = { { 0.4, 0 }, { 0.8, 0.2 } } })
hl.curve("macEase", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })
hl.curve("macTrack", { type = "bezier", points = { { 0.3, 0.3 }, { 0.3, 1 } } })
hl.curve("macWorkspace", { type = "bezier", points = { { 0.25, 0.7 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 3.4, bezier = "macEase" })
hl.animation({ leaf = "border", enabled = true, speed = 3.4, bezier = "macEase" })
hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "windows", enabled = true, speed = 2.7, bezier = "macOpen" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.3, bezier = "macOpen", style = "popin 95%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.9, bezier = "macIn", style = "popin 97%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.3, bezier = "macTrack" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "macEase" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.3, bezier = "macEase" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.8, bezier = "macEase" })
hl.animation({ leaf = "fadeSwitch", enabled = false })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 2.5, bezier = "macEase" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2.5, bezier = "macEase" })
hl.animation({ leaf = "layers", enabled = true, speed = 2.5, bezier = "macOpen" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2.3, bezier = "macOpen", style = "popin 96%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.8, bezier = "macIn", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2.3, bezier = "macEase" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.8, bezier = "macEase" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.4, bezier = "macWorkspace", style = "slide" })

-- Animations fix
for _, ns in ipairs({ "rofi", "selection", "hyprpicker" }) do
	hl.layer_rule({
		match = { namespace = ns },
		animation = "fade",
	})
end

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true,
		force_split = 2,
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		new_status = "master",
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})
