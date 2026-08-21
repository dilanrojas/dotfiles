-------------------
---- VARIABLES ----
-------------------

-- Programs
local terminal = "alacritty"
local fileManager = "nautilus -w"
local browser = "brave"
local menu = "rofi -show drun"
local term_float = "alacritty --class float -e"
local opencode = terminal .. " -e opencode"

-- Scripts
local osd = "~/.config/hypr/scripts/osd.sh"
local reload = "~/.config/hypr/scripts/reload.sh"
local power_change = "~/.config/hypr/scripts/power_profile.sh"
local power_menu = "~/.config/hypr/scripts/power_menu.sh"
local screenshot = "~/.config/hypr/scripts/screenshot.sh"
local system_theme = "~/.config/hypr/scripts/system_theme.sh"
local hypr_theme = "~/.config/hypr/scripts/hypr_theme.sh"
local dnd = "~/.config/hypr/scripts/dnd.sh"
local system_menu = "~/.config/hypr/scripts/system_menu.sh"
local wallpaper_picker = "~/.config/hypr/scripts/wallpaper_picker.sh"
local notification_history = "~/.config/hypr/scripts/notification_history.sh"
local night_light = "~/.config/hypr/scripts/night_light.sh"
local clipboard =
	"cliphist list | rofi -no-show-icons -dmenu -theme-str 'window { width: 600px; height: 354px; }' | cliphist decode | wl-copy"

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Programs
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(reload))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(power_menu))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(term_float .. " bluetui"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(term_float .. " wlctl"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(term_float .. " wlctl"))

-- Scripts
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(power_change))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(screenshot .. " crop"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshot))
hl.bind("PRINT", hl.dsp.exec_cmd(screenshot .. " full"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(system_theme))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(hypr_theme))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(dnd))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(system_menu))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(clipboard))
hl.bind(mainMod .. " + CONTROL + W", hl.dsp.exec_cmd(wallpaper_picker))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(notification_history))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(night_light))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(opencode))

-- Windows
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Y", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + I", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + W", function()
	local active = hl.get_active_window()

	if not active then
		return
	end

	local action

	if active.floating then
		action = hl.dsp.window.cycle_next({ tiled = true })
	else
		action = hl.dsp.window.cycle_next({ floating = true })
	end

	if action then
		hl.dispatch(action)
	end
end)

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -35, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.resize({ x = 35, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.resize({ x = 0, y = 35, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.resize({ x = 0, y = -35, relative = true }), { repeating = true })

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + U", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Monitor key
hl.bind("XF86Display", hl.dsp.exec_cmd(term_float .. " + nvim ~/.config/hypr/config/monitors.lua"))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osd .. " volume increase"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osd .. " volume decrease"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osd .. " volume toggle-mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(osd .. " mic toggle-mute"), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(osd .. " brightness increase"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osd .. " brightness decrease"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd(osd .. " playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(osd .. " playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(osd .. " playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(osd .. " playerctl previous"), { locked = true })

-- Keyboard media
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd(osd .. " volume toggle-mute"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd(osd .. " volume decrease"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F3", hl.dsp.exec_cmd(osd .. " volume increase"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F4", hl.dsp.exec_cmd(osd .. " mic toggle-mute"), { locked = true, repeating = true })

hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd(osd .. " brightness decrease"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd(osd .. " brightness increase"), { locked = true, repeating = true })

hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd(osd .. " playerctl next"), { locked = true })
hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd(osd .. " playerctl play-pause"), { locked = true })
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd(osd .. " playerctl play-pause"), { locked = true })
hl.bind(mainMod .. " + F9", hl.dsp.exec_cmd(osd .. " playerctl previous"), { locked = true })

-- Media keys
-- hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
-- hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
-- hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true, repeating = true })
-- hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"), { locked = true, repeating = true })
--
-- hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
--
-- hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
-- hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
--
-- -- Keyboard media
-- hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("pamixer -t"), { locked = true, repeating = true })
-- hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
-- hl.bind(mainMod .. " + F3", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
-- hl.bind(mainMod .. " + F4", hl.dsp.exec_cmd("pamixer --default-source -t"), { locked = true, repeating = true })
--
-- hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
-- hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
--
-- hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd("playerctl next"), { locked = true })
-- hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind(mainMod .. " + F9", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
