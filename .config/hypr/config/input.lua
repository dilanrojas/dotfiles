---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us,latam",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,
		repeat_rate = 38,
		repeat_delay = 400,

		scroll_factor = 1.0,
		accel_profile = "flat",

		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
			scroll_factor = 1.0,
		},
	},

	cursor = {
		hide_on_key_press = false,
		warp_on_change_workspace = 0,
		no_hardware_cursors = 0,
		no_break_fs_vrr = 0,
		inactive_timeout = 0,
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Per-device config
hl.device({
	name = "elan06fa:00-04f3:327e-touchpad",
	accel_profile = "adaptive",
	sensitivity = 0.15,
})
