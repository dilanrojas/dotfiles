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
  # Set global gaps to 0
  sed -i -E 's/^(\s*)gaps_in\s*=\s*[0-9]+,/\1gaps_in = 0,/' "$HYPRLAND_CONF"
  sed -i -E 's/^(\s*)gaps_out\s*=\s*[0-9]+,/\1gaps_out = 0,/' "$HYPRLAND_CONF"
  echo "Smart gaps enabled"
else
  # Comment smart gaps lines (lines 62-75)
  sed -i -E '62,75s/^/-- /' "$HYPRLAND_CONF"
  # Restore default global gaps
  sed -i -E 's/^(\s*)gaps_in\s*=\s*[0-9]+,/\1gaps_in = 4,/' "$HYPRLAND_CONF"
  sed -i -E 's/^(\s*)gaps_out\s*=\s*[0-9]+,/\1gaps_out = 10,/' "$HYPRLAND_CONF"
  echo "Smart gaps disabled"
fi

# Reload Hyprland
hyprctl reload

echo "Done."