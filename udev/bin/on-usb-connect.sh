#!/bin/bash

# Debounce: If the script ran in the last 2 seconds, exit quietly
LOCKFILE="/tmp/usb-added-sound.lock"
if [ -f "$LOCKFILE" ]; then
  exit 0
fi

# Create lockfile and set it to auto-delete after 2 seconds
touch "$LOCKFILE"
(sleep 2 && rm -f "$LOCKFILE") &

exec >>/tmp/usb-added-debug.log 2>&1
echo "---- $(date) ----"

SESSION=$(loginctl show-seat seat0 -p ActiveSession --value)

if [ -z "$SESSION" ] || [ "$SESSION" = "no-session" ]; then
  echo "No active session found on seat0"
  exit 0
fi

USER_ID=$(loginctl show-session "$SESSION" -p User --value)
USER_NAME=$(loginctl show-session "$SESSION" -p Name --value)

echo "Detected user: $USER_NAME (UID: $USER_ID)"

runuser -u "$USER_NAME" -- env \
  XDG_RUNTIME_DIR="/run/user/$USER_ID" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
  pw-play /usr/share/sounds/freedesktop/stereo/device-added.oga >/dev/null 2>&1 &

exit 0
