#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [on|off]" >&2
  echo "  on   - enable transparency, blur and animations"
  echo "  off  - disable transparency, blur and animations"
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

# ------------------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------------------

JSON_FILE="$HOME/.config/hypr/themes.json"
CURRENT_THEME_FILE="$HOME/.config/hypr/current_theme"

ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
WAYBAR_THEME="$HOME/.config/waybar/theme.css"
# SWAYOSD_THEME="$HOME/.config/swayosd/theme.css"
ROFI_THEME="$HOME/.config/rofi/theme.rasi"
DUNST_CONF="$HOME/.config/dunst/dunstrc"
HYPRLAND_CONF="$HOME/.config/hypr/config/looks.lua"

for f in \
  "$JSON_FILE" \
  "$ALACRITTY_CONF" \
  "$WAYBAR_THEME" \
  "$ROFI_THEME" \
  "$DUNST_CONF" \
  "$HYPRLAND_CONF"; do
  [[ -f "$f" ]] || {
    echo "Missing file: $f" >&2
    exit 1
  }
done

# ------------------------------------------------------------------------------
# Read current theme
# ------------------------------------------------------------------------------

CURRENT_THEME="catppuccin"
SYSTEM_THEME="dark"
BASE_COLOR="1e1e2e"
THEME_OPACITY="0.9"
EFFECTS="OFF"

if [[ -f "$CURRENT_THEME_FILE" ]]; then
  source "$CURRENT_THEME_FILE"

  CURRENT_THEME="${THEME:-$CURRENT_THEME}"
  SYSTEM_THEME="${SYSTEM_THEME:-$SYSTEM_THEME}"
  BASE_COLOR="${BG:-$BASE_COLOR}"
  THEME_OPACITY="${OPACITY:-$THEME_OPACITY}"
  EFFECTS="${EFFECTS:-$EFFECTS}"
fi

# ------------------------------------------------------------------------------
# Detect current state
# ------------------------------------------------------------------------------

if [[ -z "$MODE_ARG" ]]; then
  case "$EFFECTS" in
  ON)
    MODE_ARG="off"
    ;;
  OFF)
    MODE_ARG="on"
    ;;
  *)
    # Fallback for older current_theme files without EFFECTS
    CURRENT_OPACITY=$(
      awk -F'= *' \
        '/^opacity[[:space:]]*=/{print $2}' \
        "$ALACRITTY_CONF"
    )

    if [[ "$CURRENT_OPACITY" == "1" || "$CURRENT_OPACITY" == "1.0" ]]; then
      MODE_ARG="on"
    else
      MODE_ARG="off"
    fi
    ;;
  esac
fi

# ------------------------------------------------------------------------------
# Target values
# ------------------------------------------------------------------------------

if [[ "$MODE_ARG" == "on" ]]; then

  OPACITY="$THEME_OPACITY"
  ALPHA="$THEME_OPACITY"

  HEXALPHA=$(
    awk -v o="$OPACITY" \
      'BEGIN { printf "%02x", int(o * 255 + 0.5) }'
  )

  HYPR_BLUR="true"
  HYPR_ANIMATIONS="true"

  NEW_MODE="transparent"
  EFFECTS="ON"

else

  OPACITY="1.0"
  ALPHA="1.0"
  HEXALPHA="ff"

  HYPR_BLUR="false"
  HYPR_ANIMATIONS="false"

  NEW_MODE="opaque"
  EFFECTS="OFF"

fi

echo "Switching to $NEW_MODE"
echo "  opacity    = $OPACITY"
echo "  blur       = $HYPR_BLUR"
echo "  animations = $HYPR_ANIMATIONS"

# ------------------------------------------------------------------------------
# Alacritty
# ------------------------------------------------------------------------------

sed -i \
  "s/^opacity = .*/opacity = $OPACITY/" \
  "$ALACRITTY_CONF"

# ------------------------------------------------------------------------------
# Waybar
# ------------------------------------------------------------------------------

sed -i -E \
  "s/(alpha\\(#${BASE_COLOR}, )[0-9.]+(\\))/\\1${ALPHA}\\2/" \
  "$WAYBAR_THEME"

# ------------------------------------------------------------------------------
# SwayOSD
# ------------------------------------------------------------------------------

# sed -i -E \
#   "s/(alpha\\(#${BASE_COLOR}, )[0-9.]+(\\))/\\1${ALPHA}\\2/" \
#   "$SWAYOSD_THEME"

# ------------------------------------------------------------------------------
# Rofi
# ------------------------------------------------------------------------------

sed -i \
  "s/\\(bg-primary-opacity:[[:space:]]*\\).*/\\1#${BASE_COLOR}${HEXALPHA};/" \
  "$ROFI_THEME"

# ------------------------------------------------------------------------------
# Dunst
# ------------------------------------------------------------------------------

sed -i -E \
  "s/(background = \"#${BASE_COLOR})[0-9a-fA-F]{2}(\")/\\1${HEXALPHA}\\2/" \
  "$DUNST_CONF"

# ------------------------------------------------------------------------------
# Hyprland blur
# ------------------------------------------------------------------------------

sed -i -E \
  "/^[[:space:]]*blur = \{/,/^[[:space:]]*\},/ s/^([[:space:]]*enabled = )[a-zA-Z]+,?/\1${HYPR_BLUR},/" \
  "$HYPRLAND_CONF"

# ------------------------------------------------------------------------------
# Hyprland animations
# ------------------------------------------------------------------------------

# sed -i -E \
#   "/^[[:space:]]*animations = \{/,/^[[:space:]]*\},/ s/^([[:space:]]*enabled = )[a-zA-Z]+,?/\1${HYPR_ANIMATIONS},/" \
#   "$HYPRLAND_CONF"

# ------------------------------------------------------------------------------
# Persist effects state so the theme changer respects it on next switch
# ------------------------------------------------------------------------------

cat >"$CURRENT_THEME_FILE" <<EOF
THEME=$CURRENT_THEME
SYSTEM_THEME=$SYSTEM_THEME
BG=$BASE_COLOR
OPACITY=$THEME_OPACITY
EFFECTS=$EFFECTS
EOF

# ------------------------------------------------------------------------------
# Reload Hyprland
# ------------------------------------------------------------------------------

hyprctl reload

# ------------------------------------------------------------------------------
# Reload Dunst
# ------------------------------------------------------------------------------

pkill dunst || true

# pkill -x swayosd-server
# wait
# /usr/bin/swayosd-server &

echo "Done."
