#!/bin/bash
# Usage: wallpaper_change.sh <laptop_wallpaper> <other_wallpaper>

# === Config ===
CONF="$HOME/.config/hypr/hyprpaper.conf"
LOCK_CONF="$HOME/.config/hypr/hyprlock.conf"
WALLDIR="$HOME/Pictures/wallpapers"
MON1="eDP-1" # laptop screen

# === Input validation ===
if [ $# -lt 2 ]; then
  echo "Usage: $0 <first_monitor_wall> <other_monitor_wall>"
  exit 1
fi

WALL1="$1"
WALL2="$2"

FULL1="$WALLDIR/$WALL1"
FULL2="$WALLDIR/$WALL2"

# === Update hyprpaper.conf ===
# We use [[:blank:]]* in the sub() to consume existing indentation
awk -v mon="$MON1" -v wall1="$FULL1" -v wall2="$FULL2" '
BEGIN { in_block=0; is_primary=0 }

/^wallpaper[[:space:]]*{/ {
    in_block=1
    is_primary=0
}

/monitor[[:space:]]*=/ {
    if ($0 ~ mon) is_primary=1
}

/path[[:space:]]*=/ {
    if (in_block) {
        if (is_primary)
            sub(/^[[:blank:]]*path[[:space:]]*=.*/, "    path = " wall1)
        else
            sub(/^[[:blank:]]*path[[:space:]]*=.*/, "    path = " wall2)
    }
}

/^}/ {
    in_block=0
    is_primary=0
}

{ print }
' "$CONF" >"$CONF.tmp" && mv "$CONF.tmp" "$CONF"

# === Update hyprlock wallpaper ===
# Use ^[[:blank:]]* to capture any existing space and replace the whole line
sed -i "s|^[[:blank:]]*path[[:space:]]*=.*|    path = ${FULL1}|" "$LOCK_CONF"

echo "✅ Wallpapers updated:"
echo "    • $MON1 → $WALL1"
echo "    • Others → $WALL2"
echo "    • Hyprlock → $WALL1"
