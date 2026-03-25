#!/bin/bash

# Configuration
WARN_LEVEL=20
CRIT_LEVEL=10

# Tracking states
NOTIFIED_20=false
NOTIFIED_10=false

while true; do
  CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity)
  STATUS=$(cat /sys/class/power_supply/BAT0/status)

  if [ "$STATUS" == "Discharging" ]; then

    # Level 2: Critical Warning (10%)
    if [ "$CAPACITY" -le "$CRIT_LEVEL" ] && [ "$NOTIFIED_10" = false ]; then
      notify-send -u critical "Battery Critical" "Plug in immediately! ${CAPACITY}% remaining."
      NOTIFIED_10=true
      NOTIFIED_20=true # Ensure the 20% alert doesn't fire if we somehow skip to 10%

    # Level 1: Low Alert (20%)
    elif [ "$CAPACITY" -le "$WARN_LEVEL" ] && [ "$CAPACITY" -gt "$CRIT_LEVEL" ] && [ "$NOTIFIED_20" = false ]; then
      notify-send -u normal "Low Battery" "Battery is at ${CAPACITY}%."
      NOTIFIED_20=true
    fi

  else
    # Reset both flags when charging so it's ready for the next drain
    NOTIFIED_20=false
    NOTIFIED_10=false
  fi

  sleep 120
done
