#!/bin/sh

pkill waybar

swaymsg reload

pkill swayosd-server
swayosd-server &

pkill dunst

dunstctl reload
