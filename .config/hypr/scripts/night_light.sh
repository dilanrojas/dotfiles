#!/usr/bin/env bash
# Night light toggle - works with hyprsunset systemd service + automatic schedule
# - Never touches hypridle (protects `systemctl --user enable hypridle`)
# - Automatic: hyprsunset.conf handles 19:00 on / 07:30 off via its service
# - Manual: toggle anytime via `hyprctl hyprsunset temperature/identity`
# Dependencies: hyprsunset, hyprctl, systemctl
set -euo pipefail

WAYBAR_SIGNAL=10
STATE_FILE="/tmp/nightlight.state"
CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/nightlight.state"
TEMPERATURE=4800  # must match hyprsunset.conf profile temperature

mkdir -p "$(dirname "$CACHE_FILE")"

# Ensure hyprsunset service is enabled and running for automatic schedule at 19:00.
ensure_hyprsunset() {
  # ensure enabled for autostart on login (does not affect hypridle)
  systemctl --user is-enabled --quiet hyprsunset 2>/dev/null || systemctl --user enable hyprsunset 2>/dev/null || true
  if ! systemctl --user is-active --quiet hyprsunset 2>/dev/null; then
    systemctl --user start hyprsunset 2>/dev/null || systemctl --user enable --now hyprsunset 2>/dev/null || true
    # wait for socket
    for _ in {1..10}; do
      hyprctl hyprsunset identity >/dev/null 2>&1 && break
      sleep 0.1
    done
  fi
}

# Ensure hypridle stays enabled and running - never kill/disable it
ensure_hypridle() {
  if ! systemctl --user is-active --quiet hypridle 2>/dev/null; then
    systemctl --user enable --now hypridle 2>/dev/null || systemctl --user start hypridle 2>/dev/null || true
  fi
  # also ensure it's enabled (persistent)
  systemctl --user is-enabled --quiet hypridle 2>/dev/null || systemctl --user enable hypridle 2>/dev/null || true
}

# Returns 0 if manual state file is fresh (newer than last schedule transition)
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
    # before 07:30 today, last transition was yesterday 19:00
    last_trans=$(date -d "yesterday 19:00" +%s 2>/dev/null || echo $((today_1900 - 86400)))
  fi

  (( mtime >= last_trans ))
}

# Infer scheduled state based on time (mirrors hyprsunset.conf)
scheduled_state() {
  local h m now
  h=$(date +%H)
  m=$(date +%M)
  now=$((10#$h * 60 + 10#$m))
  # Night: 19:00 (1140) .. 07:29 (449)
  if (( now >= 1140 || now < 450 )); then
    echo on
  else
    echo off
  fi
}

# Get effective current state: manual fresh > scheduled if service active > off
current_state() {
  if is_manual_fresh "$STATE_FILE"; then
    cat "$STATE_FILE"
    return
  fi
  if is_manual_fresh "$CACHE_FILE"; then
    cat "$CACHE_FILE"
    return
  fi
  # No fresh manual override - rely on schedule if hyprsunset running, else check pgrep
  if systemctl --user is-active --quiet hyprsunset 2>/dev/null; then
    scheduled_state
  else
    if pgrep -x hyprsunset >/dev/null 2>&1; then
      scheduled_state
    else
      echo off
    fi
  fi
}

set_state() {
  local target="$1"
  ensure_hyprsunset
  ensure_hypridle

  if [[ "$target" == "on" ]]; then
    if ! hyprctl hyprsunset temperature "$TEMPERATURE" 2>/dev/null; then
      # fallback if hyprctl not ready yet
      sleep 0.3
      hyprctl hyprsunset temperature "$TEMPERATURE" 2>/dev/null || true
    fi
    echo on > "$STATE_FILE"
    echo on > "$CACHE_FILE"
  else
    hyprctl hyprsunset identity 2>/dev/null || true
    echo off > "$STATE_FILE"
    echo off > "$CACHE_FILE"
  fi
  pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null || true
}

clear_manual() {
  rm -f "$STATE_FILE" "$CACHE_FILE"
  # snap back to scheduled state
  local s
  s=$(scheduled_state)
  ensure_hyprsunset
  if [[ "$s" == "on" ]]; then
    hyprctl hyprsunset temperature "$TEMPERATURE" 2>/dev/null || true
  else
    hyprctl hyprsunset identity 2>/dev/null || true
  fi
  pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null || true
}

cmd="${1:-toggle}"
case "$cmd" in
  on) set_state on ;;
  off) set_state off ;;
  auto|clear|scheduled)
    clear_manual
    ;;
  toggle|"")
    cur=$(current_state)
    if [[ "$cur" == "on" ]]; then
      set_state off
    else
      set_state on
    fi
    ;;
  status)
    current_state
    ;;
  *)
    echo "Usage: $0 [on|off|toggle|auto|status]"
    exit 1
    ;;
esac
