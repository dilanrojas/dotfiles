#!/usr/bin/env bash
STATUS_FILE="/tmp/screenrecording.status"

if [[ -f "$STATUS_FILE" ]]; then
  start="$(cut -d: -f2 "$STATUS_FILE")"
  now="$(date +%s)"
  elapsed=$((now - start))
  printf -v t '%02d:%02d' $((elapsed / 60)) $((elapsed % 60))
  echo "{\"text\":\" 󰑊 ${t} \",\"alt\":\"recording\",\"tooltip\":\"Recording — click to stop\",\"class\":\"recording\"}"
else
  echo "{\"text\":\"\",\"alt\":\"idle\",\"tooltip\":\"\",\"class\":\"idle\"}"
fi
