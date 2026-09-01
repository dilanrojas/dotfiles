-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("mpris-proxy")
	hl.exec_cmd("swayosd-server")
	hl.exec_cmd("dunst")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("systemctl --user start --ignore-dependencies xdg-desktop-portal")
	hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
	hl.exec_cmd("bash ~/.config/hypr/scripts/power-monitor.sh &")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	-- night light: ensure hyprsunset for auto 19:00 schedule, and protect hypridle
	hl.exec_cmd("systemctl --user enable --now hypridle 2>/dev/null || systemctl --user start hypridle 2>/dev/null || true")
	hl.exec_cmd("systemctl --user enable --now hyprsunset 2>/dev/null || systemctl --user start hyprsunset 2>/dev/null || true")
end)
