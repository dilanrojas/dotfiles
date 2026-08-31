#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [on|off]" >&2
  echo "  on   - enable smart gaps"
  echo "  off  - disable smart gaps"
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

HYPRLAND_CONF="$HOME/.config/hypr/config/looks.lua"

[[ -f "$HYPRLAND_CONF" ]] || {
  echo "Missing file: $HYPRLAND_CONF" >&2
  exit 1
}

# Detect current state by checking if smart gaps rules are uncommented
if [[ -z "$MODE_ARG" ]]; then
  if grep -q '^hl\.workspace_rule({ workspace = "w\[tv1\]"' "$HYPRLAND_CONF"; then
    MODE_ARG="off"
  else
    MODE_ARG="on"
  fi
fi

if [[ "$MODE_ARG" == "on" ]]; then
  # Uncomment smart gaps lines (lines 62-75)
  sed -i -E '62,75s/^-- //' "$HYPRLAND_CONF"
  echo "Smart gaps enabled"
else
  # Comment smart gaps lines (lines 62-75)
  sed -i -E '62,75s/^/-- /' "$HYPRLAND_CONF"
  echo "Smart gaps disabled"
fi

# Reload Hyprland
hyprctl reload

echo "Done."