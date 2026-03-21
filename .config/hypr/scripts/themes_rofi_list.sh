#!/bin/bash

THEMES_DIR="$HOME/.config/hypr/themes"

# Get a list of theme folders (ignore hidden files)
themes=$(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n")

# Launch Rofi in dmenu mode to select a theme
selected=$(echo "$themes" | rofi -dmenu -p "Select theme" -no-show-icons)

# If a theme was selected
if [ -n "$selected" ]; then
    theme_script="$THEMES_DIR/$selected/theme.sh"
    
    if [ -x "$theme_script" ]; then
        # Run the theme script
        "$theme_script"
        echo "✅ Theme '$selected' applied."
    else
        echo "❌ Theme script not found or not executable: $theme_script"
    fi
fi
