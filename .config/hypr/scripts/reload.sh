#!/bin/sh
hyprctl reload

pkill waybar
waybar &

pkill hyprpaper
hyprpaper &

pkill swaync
swaync &

pkill swayosd-server
swayosd-server &

pkill hypridle
hypridle &

pkill hyprsunset
sleep 1
hyprsunset &
