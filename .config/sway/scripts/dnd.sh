#!/bin/bash

# Toggle DND mode directly using swaync-client
swaync-client -d

# Check if DND is now false (meaning notifications are turned back ON)
if [ "$(swaync-client -D)" = "false" ]; then
  notify-send "Notifications Enabled" "Do Not Disturb is off."
fi
