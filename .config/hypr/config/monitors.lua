------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "eDP-1",
	mode = "1920x1200@60",
	position = "0x0",
	scale = "1",
})

-- External monitor
hl.monitor({
	output = "HDMI-A-1",
	mode = "preferred",

	position = "1920x0", -- Right
	-- position = "-1920x0", -- Left
	-- position = "0x-1200", -- Top
	-- position = "0x1200",  -- Bottom

	-- mirror = "eDP-1",

	scale = "1",
})
