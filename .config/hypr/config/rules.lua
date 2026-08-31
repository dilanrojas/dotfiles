--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	name = "float-float",
	match = { class = "float" },
	size = { 1000, 700 },
	float = true,
})

hl.window_rule({
	name = "float-lunarclient",
	match = { class = "lunarclient" },
	float = true,
})

hl.window_rule({
	name = "float-pavucontrol",
	match = { class = "org.pulseaudio.pavucontrol" },
	float = true,
})

hl.window_rule({
	name = "brave-save-dialog",
	match = {
		class = "brave",
		title = ".*wants to save.*",
	},
	float = true,
})

hl.window_rule({
	name = "brave-default-profile",
	match = {
		class = ".*brave.*Default.*",
	},
	float = true,
})

hl.window_rule({
	name = "float-steam",
	match = { class = "steam" },
	float = true,
})

hl.window_rule({
	name = "float-loupe",
	match = { class = "org.gnome.Loupe" },
	float = true,
})

hl.window_rule({
	name = "float-calendar",
	match = { class = "org.gnome.Calendar" },
	float = true,
})

hl.window_rule({
	name = "float-calculator",
	match = { class = "org.gnome.Calculator" },
	float = true,
})

hl.window_rule({
	name = "float-clocks",
	match = { class = "org.gnome.clocks" },
	float = true,
})

hl.window_rule({
	name = "float-xdg-portal",
	match = { class = "xdg-desktop-portal-gtk" },
	float = true,
})

hl.window_rule({
	name = "float-guvcview-appid",
	match = { class = "guvcview" },
	float = true,
})

hl.window_rule({
	name = "float-imv",
	match = { class = "imv" },
	float = true,
})

hl.window_rule({
	name = "float-oculante",
	match = { class = "oculante" },
	float = true,
})

hl.window_rule({
	name = "float-guvcview-class",
	match = { class = "guvcview" },
	float = true,
})

hl.window_rule({
	name = "float-dbeaver",
	match = {
		class = "java",
		title = "(?i)^DBeaver",
	},
	float = true,
})

hl.window_rule({
	name = "zoom-client-float",
	match = {
		class = "zoom",
	},
	float = true,
})

hl.window_rule({
	name = "zoom-meeting",
	match = {
		class = "zoom",
		title = "Meeting",
	},
	float = true,
})

hl.window_rule({
	name = "zoom-annotate-toolbar",
	match = {
		class = "zoom",
		title = "annotate_toolbar",
	},
	float = true,
})

hl.window_rule({
	name = "gnome-console",
	match = {
		class = "org.gnome.Console",
	},
	float = true,
})

hl.window_rule({
	name = "lunar-client",
	match = {
		class = "Lunar Client 1.8.9 (v2.22.31-2635)",
	},
	float = true,
})

hl.window_rule({
	name = "libreoffice-save",
	match = {
		class = "soffice",
		title = "Save",
	},
	rounding = 12,
})

-- Disable blur globally
hl.window_rule({
	match = { class = ".*" },
	no_blur = true,
})

-- Enable blur only for alacritty
hl.window_rule({
	match = { class = "Alacritty" },
	no_blur = false,
})

hl.window_rule({
	match = { class = "float" },
	no_blur = false,
})

-- Disable rofi animations
hl.layer_rule({
	match = { namespace = "rofi" },
	ignore_alpha = 0.5,
	no_anim = false,
	blur = true,
})

hl.layer_rule({
	match = { namespace = "waybar" },
	ignore_alpha = 0.5,
	blur = true,
})

hl.layer_rule({
	match = { namespace = "swayosd" },
	no_anim = false,
	ignore_alpha = 0.7,
	blur = true,
})

hl.layer_rule({
	match = { namespace = "notifications" },
	ignore_alpha = 0.5,
	blur = true,
})
