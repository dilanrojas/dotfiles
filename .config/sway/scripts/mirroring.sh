#!/usr/bin/env bash

# 1. If wl-mirror is already running, kill it and exit (Toggle off)
if pgrep -f wl-mirror &>/dev/null; then
  killall wl-mirror
  notify-send "wl-mirror" "Mirroring stopped" -i video-display
  exit 0
fi

# 2. Get active outputs using swaymsg and jq
# (Requires 'jq' to parse the JSON output from swaymsg)
outputs=$(swaymsg -t get_outputs | jq -r '.[] | select(.active == true) | .name')
num_outputs=$(echo "$outputs" | grep -v '^$' | wc -l)

# 3. If there's only one monitor, alert the user and exit
if [ "$num_outputs" -lt 2 ]; then
  notify-send "wl-mirror" "Only one active monitor detected. Cannot mirror." -u critical -i dialog-error
  exit 1
fi

# 4. Prompt user to select which monitor to MIRROR (the source)
source_monitor=$(echo "$outputs" | rofi -dmenu -p "Select monitor to mirror (Source)")
# Exit if the user escapes/cancels rofi
[ -z "$source_monitor" ] && exit 0

# 5. Prompt user for where to DISPLAY the mirror (the target)
# We filter out the source monitor so they don't select the same one
target_monitor=$(echo "$outputs" | grep -v "^$source_monitor$" | rofi -dmenu -p "Select target monitor (Output)")
[ -z "$target_monitor" ] && exit 0

# 6. Start mirroring in the background
wl-mirror --fullscreen-output "$target_monitor" "$source_monitor" &
notify-send "wl-mirror" "Mirroring $source_monitor onto $target_monitor" -i video-display
