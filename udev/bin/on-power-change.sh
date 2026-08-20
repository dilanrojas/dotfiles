#!/bin/bash

STATE_FILE="/run/ac-online.state"

# Get the currently active graphical session
SESSION=$(loginctl show-seat seat0 -p ActiveSession --value)

if [ -z "$SESSION" ] || [ "$SESSION" = "no-session" ]; then
  exit 0
fi

USER_NAME=$(loginctl show-session "$SESSION" -p Name --value)
USER_ID=$(loginctl show-session "$SESSION" -p User --value)

if [ -z "$USER_NAME" ] || [ -z "$USER_ID" ]; then
  exit 0
fi

# ------------------------------------------------------------
# Detect AC power state
# ------------------------------------------------------------

if [ -n "$POWER_SUPPLY_ONLINE" ]; then
  AC_STATE="$POWER_SUPPLY_ONLINE"
else
  # Give udev/kernel a moment to update /sys
  sleep 0.2

  AC_STATE=""

  for ps in /sys/class/power_supply/*; do
    [ -r "$ps/type" ] || continue
    [ -r "$ps/online" ] || continue

    if [ "$(cat "$ps/type")" = "Mains" ]; then
      AC_STATE=$(cat "$ps/online")
      break
    fi
  done

  # Fallback for systems using ADP0
  if [ -z "$AC_STATE" ] && [ -r /sys/class/power_supply/ADP0/online ]; then
    AC_STATE=$(cat /sys/class/power_supply/ADP0/online)
  fi
fi

# Couldn't determine power state
if [ -z "$AC_STATE" ]; then
  exit 0
fi

# ------------------------------------------------------------
# Check whether the state actually changed
# ------------------------------------------------------------

if [ -f "$STATE_FILE" ]; then
  PREVIOUS_STATE=$(cat "$STATE_FILE")
else
  PREVIOUS_STATE=""
fi

if [ "$AC_STATE" = "$PREVIOUS_STATE" ]; then
  exit 0
fi

echo "$AC_STATE" >"$STATE_FILE"

# ------------------------------------------------------------
# AC connected
# ------------------------------------------------------------

if [ "$AC_STATE" = "1" ]; then

  powerprofilesctl set balanced

  # Hyprland effects
  # runuser -u "$USER_NAME" -- \
  #     bash -c "/home/$USER_NAME/.config/hypr/scripts/toggle_effects.sh on"

  # Plug-in sound
  runuser -u "$USER_NAME" -- env \
    XDG_RUNTIME_DIR="/run/user/$USER_ID" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
    pw-play /usr/share/sounds/freedesktop/stereo/power-plug.oga \
    >/dev/null 2>&1 &

# ------------------------------------------------------------
# On battery
# ------------------------------------------------------------

else

  powerprofilesctl set power-saver

  # Hyprland effects
  # runuser -u "$USER_NAME" -- \
  #     bash -c "/home/$USER_NAME/.config/hypr/scripts/toggle_effects.sh off"

  # Unplug sound
  runuser -u "$USER_NAME" -- env \
    XDG_RUNTIME_DIR="/run/user/$USER_ID" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
    pw-play /usr/share/sounds/freedesktop/stereo/power-unplug.oga \
    >/dev/null 2>&1 &

fi

exit 0
