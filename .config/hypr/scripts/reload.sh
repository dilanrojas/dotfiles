#!/bin/sh
hyprctl reload

pkill waybar
waybar &

pkill hyprpaper
hyprpaper &

pkill swaync
swaync &

systemctl stop --user hypridle
systemctl start --user hypridle
