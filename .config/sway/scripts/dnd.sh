#!/usr/bin/env bash

if dunstctl is-paused | grep -q "true"; then
  dunstctl set-paused false
  notify-send "Dunst" "Notifications Enabled"
else
  dunstctl set-paused true
fi
