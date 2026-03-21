#!/bin/bash
# Usage: wlogout_theme.sh <theme-name>
# Example: wlogout_theme.sh kanagawa-wave

CONF="$HOME/.config/wlogout/style.css"

if [ -z "$1" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME="$1"

# Replace the theme name in the @import line
sed -i "s|\(@import url('../hypr/themes/\)\([^/]*\)\(/waybar\.css');\)|\1${THEME}\3|" "$CONF"

echo "✅ Wlogout theme changed to: $THEME"
