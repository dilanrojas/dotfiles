#!/bin/sh

swaymsg reload

pkill waybar
waybar &

pkill swaync
swaync &

pkill swayosd-server
swayosd-server &
