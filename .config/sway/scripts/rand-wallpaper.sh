#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SWAY_CONFIG="$HOME/.config/sway/config"

# 1. Grab a random file from the directory
NEXT_WALL=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# 2. Use sed to replace the wallpaper path in the Sway config
# This looks for the line starting with "output * bg" and replaces everything
# between "bg " and " fill" with the new wallpaper path.
sed -i "s|^\(output \* bg \).*\( fill\)$|\1$NEXT_WALL\2|" "$SWAY_CONFIG"

# 3. Tell Sway to reload its configuration to apply it instantly
swaymsg "output * bg '$NEXT_WALL' fill"
