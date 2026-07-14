#!/bin/sh

pkill waybar

swaymsg reload

pkill swayosd-server
swayosd-server &

dunstctl reload
