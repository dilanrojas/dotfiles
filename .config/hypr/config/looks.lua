-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,

		border_size = 2,

		col = {
			active_border = { colors = { "rgba(2aa198ff)" } },
			inactive_border = "rgba(283c42ff)",
		},

		resize_on_border = false,

		allow_tearing = true,

		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		dim_inactive = false,
		dim_strength = 0.06,

		shadow = {
			enabled = false,
			range = 15,
			render_power = 2,
			color = "rgba(00000018)",
		},

		blur = {
			enabled = true,
			size = 1,
			passes = 4,
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
		enabled = false,
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
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 1.0, bezier = "almostLinear" })
hl.animation({ leaf = "windows", enabled = true, speed = 2.6, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.8, bezier = "easeOutQuint", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.0, bezier = "linear", style = "popin 92%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.0, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.1, bezier = "quick" })
hl.animation({ leaf = "fadeSwitch", enabled = false })
hl.animation({ leaf = "layers", enabled = true, speed = 2.6, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2.8, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.0, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.9, bezier = "almostLinear" })
hl.animation({
	leaf = "workspaces",
	enabled = false,
	speed = 2.4,
	bezier = "easeOutQuint",
	style = "fade",
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
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
