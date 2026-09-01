#!/usr/bin/env bash
# Waybar module for hyprsunset night light - works with new night_light.sh
# Shows correct state for both automatic schedule (19:00-07:30) and manual toggle
STATE_FILE="/tmp/nightlight.state"
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/nightlight.state"

is_manual_fresh() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  local mtime now today_0730 today_1900 last_trans
  mtime=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || echo 0)
  now=$(date +%s)
  today_0730=$(date -d "today 07:30" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M" "$(date +%Y-%m-%d) 07:30" +%s 2>/dev/null || echo 0)
  today_1900=$(date -d "today 19:00" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M" "$(date +%Y-%m-%d) 19:00" +%s 2>/dev/null || echo 0)

  if (( now >= today_1900 )); then
    last_trans=$today_1900
  elif (( now >= today_0730 )); then
    last_trans=$today_0730
  else
    last_trans=$(date -d "yesterday 19:00" +%s 2>/dev/null || echo $((today_1900 - 86400)))
  fi
  (( mtime >= last_trans ))
}

scheduled_state() {
  local h m now
  h=$(date +%H)
  m=$(date +%M)
  now=$((10#$h * 60 + 10#$m))
  if (( now >= 1140 || now < 450 )); then
    echo on
  else
    echo off
  fi
}

state=""

# Prefer fresh manual state files
if is_manual_fresh "$STATE_FILE"; then
  state=$(cat "$STATE_FILE" 2>/dev/null | tr -d '[:space:]')
elif is_manual_fresh "$CACHE_FILE"; then
  state=$(cat "$CACHE_FILE" 2>/dev/null | tr -d '[:space:]')
else
  # No fresh manual override - infer from schedule + service status
  if systemctl --user is-active --quiet hyprsunset 2>/dev/null; then
    state=$(scheduled_state)
  else
    if pgrep -x hyprsunset >/dev/null 2>&1; then
      # unmanaged hyprsunset running (fallback) - assume scheduled
      state=$(scheduled_state)
    else
      state="off"
    fi
  fi
fi

# Normalize
state=$(echo "$state" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
if [[ "$state" != "on" ]]; then
  state="off"
fi

if [[ "$state" == "on" ]]; then
  echo '{"text":"","alt":"night-on","tooltip":"Night Light: On"}'
else
  echo '{"text":"","alt":"night-off","tooltip":"Night Light: Off"}'
fi
