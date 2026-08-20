#!/usr/bin/env bash
if dunstctl is-paused | grep -q "true"; then
  echo '{"text":"","alt":"dnd-on","tooltip":"Do Not Disturb: On"}'
else
  echo '{"text":"","alt":"dnd-off","tooltip":"Do Not Disturb: Off"}'
fi
