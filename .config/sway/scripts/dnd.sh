#!/bin/bash

if [ "$(makoctl mode)" == "dnd" ]; then
  makoctl mode -r dnd
  notify-send "Notifications Enabled" "Do Not Disturb is off."
else
  makoctl mode -s dnd
fi
