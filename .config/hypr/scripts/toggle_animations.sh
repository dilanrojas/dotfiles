#!/usr/bin/env bash
# toggle_animations.sh — toggle Hyprland window animations on/off by flipping
# the `enabled` flag inside the `animations = { ... }` block in looks.lua.
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [on|off]" >&2
  echo "  on   - enable animations"
  echo "  off  - disable animations"
  echo "  (no argument) - toggle"
  exit 1
}

MODE_ARG=""

if [[ $# -gt 1 ]]; then
  usage
elif [[ $# -eq 1 ]]; then
  case "$1" in
  on | off)
    MODE_ARG="$1"
    ;;
  -h | --help)
    usage
    ;;
  *)
    echo "Invalid argument: $1" >&2
    usage
    ;;
  esac
fi

LOOKS_FILE="$HOME/.config/hypr/config/looks.lua"
HYPRLOCK_FILE="$HOME/.config/hypr/hyprlock.conf"

[[ -f "$LOOKS_FILE" ]] || {
  echo "Missing file: $LOOKS_FILE" >&2
  exit 1
}

# Determine current state inside the animations block.
CUR_STATE="$(awk '
  /^[[:space:]]*animations[[:space:]]*=[[:space:]]*\{/ { in_block=1; next }
  in_block && /^[[:space:]]*\},/ { in_block=0 }
  in_block && /^[[:space:]]*enabled[[:space:]]*=[[:space:]]*[a-zA-Z]+/ {
    print $0
    exit
  }
' "$LOOKS_FILE")"

if [[ -z "$CUR_STATE" ]]; then
  echo "Could not find an enabled flag inside the animations block in $LOOKS_FILE" >&2
  exit 1
fi

if [[ "$CUR_STATE" =~ enabled[[:space:]]*=[[:space:]]*true ]]; then
  CURRENT="on"
else
  CURRENT="off"
fi

if [[ -z "$MODE_ARG" ]]; then
  MODE_ARG="$([[ "$CURRENT" == "on" ]] && echo off || echo on)"
fi

if [[ "$MODE_ARG" == "on" ]]; then
  NEW_VALUE="true"
else
  NEW_VALUE="false"
fi

# Flip the enabled flag only within the animations block, preserving indentation.
awk -v val="$NEW_VALUE" '
  /^[[:space:]]*animations[[:space:]]*=[[:space:]]*\{/ { in_block=1 }
  in_block && /^[[:space:]]*\},/ { in_block=0 }
  in_block && /^[[:space:]]*enabled[[:space:]]*=[[:space:]]*[a-zA-Z]+/ {
    match($0, /^[[:space:]]*/)
    indent = substr($0, 1, RLENGTH)
    print indent "enabled = " val ","
    next
  }
  { print }
' "$LOOKS_FILE" > "${LOOKS_FILE}.tmp" && mv "${LOOKS_FILE}.tmp" "$LOOKS_FILE"

# Also toggle animations in hyprlock.conf, if present.
if [[ -f "$HYPRLOCK_FILE" ]]; then
  awk -v val="$NEW_VALUE" '
    /^[[:space:]]*animations[[:space:]]*\{/ { in_block=1 }
    in_block && /^[[:space:]]*\}/ { in_block=0 }
    in_block && /^[[:space:]]*enabled[[:space:]]*=[[:space:]]*[a-zA-Z]+/ {
      match($0, /^[[:space:]]*/)
      indent = substr($0, 1, RLENGTH)
      print indent "enabled = " val
      next
    }
    { print }
  ' "$HYPRLOCK_FILE" > "${HYPRLOCK_FILE}.tmp" && mv "${HYPRLOCK_FILE}.tmp" "$HYPRLOCK_FILE"
fi

hyprctl reload

echo "Animations $([[ "$MODE_ARG" == "on" ]] && echo enabled || echo disabled)"
