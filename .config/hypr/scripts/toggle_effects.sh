#!/usr/bin/env bash
# toggle_effects.sh — toggle transparency/blur on/off.
# State lives in ~/.config/hypr/themes/current_theme (EFFECTS=on|off).
set -uo pipefail

source "$HOME/.config/hypr/themes/lib.sh"

usage() {
  echo "Usage: $(basename "$0") [on|off]" >&2
  echo "  on   - enable transparency, blur and animations"
  echo "  off  - disable transparency, blur and animations"
  echo "  (no argument) - toggle"
  exit 1
}

MODE_ARG=""
if [[ $# -gt 1 ]]; then usage
elif [[ $# -eq 1 ]]; then
  case "$1" in on|off) MODE_ARG="$1" ;; -h|--help) usage ;; *) echo "Invalid argument: $1" >&2; usage ;; esac
fi

load_current
[ -n "$CUR_THEME" ] || { echo "No current theme set"; exit 1; }

if [[ -z "$MODE_ARG" ]]; then
  case "$CUR_EFFECTS" in
    ON) MODE_ARG="off" ;;
    OFF) MODE_ARG="on" ;;
    *) MODE_ARG="on" ;;
  esac
fi

if [[ "$MODE_ARG" == "on" ]]; then
  CUR_EFFECTS="ON"; NEW_MODE="transparent"
else
  CUR_EFFECTS="OFF"; NEW_MODE="opaque"
fi

# Regenerate alpha-dependent live files (rofi/waybar/swayosd + alacritty opacity)
apply_opacity

# Hyprland blur toggle
HYPR_BLUR="true"; [ "$MODE_ARG" == "off" ] && HYPR_BLUR="false"
sed -i -E "/^[[:space:]]*blur = \{/,/^[[:space:]]*\},/ s/^([[:space:]]*enabled = )[a-zA-Z]+,?/\1${HYPR_BLUR},/" "$LOOKS_FILE"

write_current

hyprctl reload
pkill dunst 2>/dev/null

echo "Switched to $NEW_MODE"
