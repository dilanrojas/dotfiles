#!/usr/bin/env bash
STATUS_FILE="/tmp/screenrecording.status"
echo "$(date +%s.%N) WAYBAR_EXEC pid=$$ ppid=$PPID status_exists=$(test -f "$STATUS_FILE" && echo yes || echo no)" >>/tmp/waybar-trace.log
if [[ -f "$STATUS_FILE" ]]; then
  echo "{\"text\":\" 󰑊 Rec\",\"alt\":\"recording\",\"tooltip\":\"Recording — click to stop\",\"class\":\"recording\"}"
else
  echo "{\"text\":\"\",\"alt\":\"idle\",\"tooltip\":\"\",\"class\":\"idle\"}"
fi
