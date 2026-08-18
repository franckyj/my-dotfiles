#!/usr/bin/env bash
img=(`find ~/.config/wallpapers/ -name '*' -exec file {} \; | grep -o -P '^.+: \w+ image' | cut -d':' -f1`)
while true
do
   feh --bg-scale "${img[$RANDOM % ${#img[@]} ]}"
sleep 10m
done