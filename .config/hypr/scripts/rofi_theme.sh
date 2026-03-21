#!/bin/bash
# Usage: rofi_theme.sh <theme-name>
# Example: rofi_theme.sh solarized-osaka

CONF="$HOME/.config/rofi/config.rasi"

if [ -z "$1" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME="$1"

# Replace the theme name in the @import line
sed -i "s|\(@import \"../hypr/themes/\)[^/]*\(/rofi\.rasi\"\)|\1${THEME}\2|" "$CONF"

echo "✅ Rofi theme changed to: $THEME"

# Optional: reload Rofi if needed (usually requires closing and reopening)
# echo "🔄 Restart Rofi to apply the new theme."
