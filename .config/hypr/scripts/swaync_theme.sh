#!/bin/bash
# Usage: swaync_theme.sh <theme-name>
# Example: swaync_theme.sh kanagawa-wave

CONF="$HOME/.config/swaync/style.css"

if [ -z "$1" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME="$1"

# Replace the theme name in the @import line
sed -i "s|\(@import url('../hypr/themes/\)\([^/]*\)\(/swaync\.css');\)|\1${THEME}\3|" "$CONF"

echo "✅ SwayNC theme changed to: $THEME"

# Optional reload if swaync is running
if pgrep -x "swaync" >/dev/null; then
    swaync-client --reload > /dev/null 2>&1
    echo "🔄 SwayNC reloaded."
fi
