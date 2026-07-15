#!/bin/sh

pkill waybar
waybar &

swaymsg reload

pkill swayosd-server
swayosd-server &

dunstctl reload
