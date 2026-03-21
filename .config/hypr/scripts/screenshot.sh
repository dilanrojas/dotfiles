#!/bin/bash

# Define the screenshot filename
FILENAME="screenshot-$(date +%F-%T)"

# Check if the directory exists, and create it only if it doesn't
if [ ! -d ~/Pictures/Screenshots ]; then
    mkdir ~/Pictures/Screenshots
fi

# Capture the screenshot
grim ~/Pictures/Screenshots/$FILENAME.png && \
wl-copy < ~/Pictures/Screenshots/$FILENAME.png && \
notify-send 'Screenshot' 'Copied to clipboard' -a GRIM -i ~/Pictures/Screenshots/$FILENAME.png
