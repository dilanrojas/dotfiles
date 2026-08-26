#!/usr/bin/env bash

# Parse Dunst's specific type/data JSON structure
chosen=$(dunstctl history | jq -r '.data[][] | "[\(.appname.data)] \(.summary.data): \(.body.data)"' | rofi -theme-str 'window { width: 600px; height: 358px; }' -no-show-icons -dmenu -p "Notifications:")

# Extract just the raw text after the app name/summary and copy it to Wayland clipboard
if [ -n "$chosen" ]; then
  # Removes the prefix '[App] Summary: ' to only copy the actual message body
  echo -n "$chosen" | sed -E 's/^\[.*\] .*: //' | wl-copy
fi
