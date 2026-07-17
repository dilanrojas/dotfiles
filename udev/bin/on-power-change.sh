#!/bin/bash

STATE_FILE="/run/ac-online.state"

SESSION=$(loginctl show-seat seat0 -p ActiveSession --value)

if [ -z "$SESSION" ] || [ "$SESSION" = "no-session" ]; then
  exit 0
fi

USER_NAME=$(loginctl show-session "$SESSION" -p Name --value)
USER_ID=$(loginctl show-session "$SESSION" -p User --value)

export SWAYSOCK=$(find /run/user/"$USER_ID" -maxdepth 1 -name "sway-ipc.$USER_ID*.sock" | head -n 1)

if [ -z "$SWAYSOCK" ]; then
  exit 0
fi

if [ -n "$POWER_SUPPLY_ONLINE" ]; then
  AC_STATE="$POWER_SUPPLY_ONLINE"
else
  sleep 0.2

  AC_STATE=""

  for ps in /sys/class/power_supply/*; do
    [ -r "$ps/type" ] || continue

    if [ "$(cat "$ps/type")" = "Mains" ]; then
      AC_STATE=$(cat "$ps/online" 2>/dev/null)
      break
    fi
  done

  if [ -z "$AC_STATE" ] && [ -r /sys/class/power_supply/ADP0/online ]; then
    AC_STATE=$(cat /sys/class/power_supply/ADP0/online)
  fi
fi

if [ -f "$STATE_FILE" ]; then
  PREVIOUS_STATE=$(cat "$STATE_FILE")
else
  PREVIOUS_STATE=""
fi

if [ "$AC_STATE" = "$PREVIOUS_STATE" ]; then
  exit 0
fi

echo "$AC_STATE" >"$STATE_FILE"

if [ "$AC_STATE" = "1" ]; then
  # === PLUGGED IN ===
  powerprofilesctl set balanced

  runuser -u "$USER_NAME" -- \
    bash -c "/home/$USER_NAME/.config/sway/scripts/toggle_effects.sh on"

  runuser -u "$USER_NAME" -- env \
    XDG_RUNTIME_DIR="/run/user/$USER_ID" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
    pw-play /usr/share/sounds/freedesktop/stereo/power-plug.oga >/dev/null 2>&1 &
else
  # === ON BATTERY ===
  powerprofilesctl set power-saver

  runuser -u "$USER_NAME" -- \
    bash -c "/home/$USER_NAME/.config/sway/scripts/toggle_effects.sh off"

  runuser -u "$USER_NAME" -- env \
    XDG_RUNTIME_DIR="/run/user/$USER_ID" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
    pw-play /usr/share/sounds/freedesktop/stereo/power-unplug.oga >/dev/null 2>&1 &
fi

exit 0
