#!/usr/bin/env bash

# Parse Dunst's specific type/data JSON structure
chosen=$(dunstctl history | jq -r '.data[][] | "[\(.appname.data)] \(.summary.data): \(.body.data)"' | "$(dirname "${BASH_SOURCE[0]}")/rofi.sh" -p "Notifications:" -w 600px)

# Extract just the raw text after the app name/summary and copy it to Wayland clipboard
if [ -n "$chosen" ]; then
  # Removes the prefix '[App] Summary: ' to only copy the actual message body
  echo -n "$chosen" | sed -E 's/^\[.*\] .*: //' | wl-copy
fi
