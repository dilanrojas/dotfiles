#!/bin/sh

pkill waybar
waybar &

hyprctl reload

pkill swayosd-server
swayosd-server &

pkill dunst

pkill hyprpaper
hyprpaper &
