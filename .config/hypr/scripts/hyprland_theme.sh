#!/bin/bash
# Usage: hyprland_theme.sh <theme-name>
# Example: hyprland_theme.sh solarized-osaka

CONF="$HOME/.config/hypr/settings/look.conf"

if [ -z "$1" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME="$1"

# Replace the theme name in the 'source' line
sed -i "s|\(source = ../themes/\)[^/]*\(/hyprland\.conf\)|\1${THEME}\2|" "$CONF"

echo "✅ Hyprland theme changed to: $THEME"

# Optional: reload Hyprland if needed (only works if you have a reload command or hotkey)
# echo "🔄 Remember to reload Hyprland to apply changes."
