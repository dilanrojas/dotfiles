#!/bin/bash
# Usage: waybar_theme.sh <theme-name>
# Example: waybar_theme.sh kanagawa-wave

CONF="$HOME/.config/waybar/style.css"

if [ -z "$1" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME="$1"

# Replace the theme name in the @import line
sed -i "s|\(@import url('../hypr/themes/\)\([^/]*\)\(/waybar\.css');\)|\1${THEME}\3|" "$CONF"

echo "✅ Waybar theme changed to: $THEME"

# Optionally reload Waybar automatically
if pgrep -x "waybar" >/dev/null; then
    pkill -SIGUSR2 waybar
    echo "🔄 Waybar reloaded."
fi
