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

	-- position = "1920x0", -- Right
	-- position = "-1920x0", -- Left
	position = "0x-1200", -- Top
	-- position = "0x1200",  -- Bottom

	-- mirror = "eDP-1",
	scale = "1",
})

-- Assign workspaces
for i = 1, 5 do
	hl.workspace_rule({
		workspace = tostring(i),
		monitor = "eDP-1",
		default = (i == 1),
	})
end

for i = 6, 10 do
	hl.workspace_rule({
		workspace = tostring(i),
		monitor = "HDMI-A-1",
		default = (i == 6),
	})
end
