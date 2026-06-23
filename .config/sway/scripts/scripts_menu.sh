#!/usr/bin/env bash

# 1. Define the directory containing your scripts
SCRIPT_DIR="$HOME/.config/sway/scripts"

# 2. Get the list of scripts (filenames only)
# We find files, take only the basename, and exclude this menu script itself to avoid infinite loops
SCRIPT_LIST=$(find "$SCRIPT_DIR" -maxdepth 1 -type f -executable -not -name "$(basename "$0")" -printf "%f\n")

# 3. Pass the list to Rofi and capture the user's choice
CHOICE=$(echo "$SCRIPT_LIST" | rofi -no-show-icons -dmenu -i -p "Run Script:")

# 4. If the user made a choice, execute it
if [ -n "$CHOICE" ]; then
  exec "$SCRIPT_DIR/$CHOICE"
fi
