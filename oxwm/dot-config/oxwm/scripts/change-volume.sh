#!/usr/bin/env bash

function send_notification() {
  volume=$(pamixer --get-volume)

  # if the volume is between 0 and 33, use the low volume icon
  if [ "$volume" -le 33 ]; then
    icon="audio-volume-low"
  # if the volume is between 34 and 66, use the medium volume icon
  elif [ "$volume" -le 66 ]; then
    icon="audio-volume-medium"
  # if the volume is between 67 and 100, use the high volume icon
  else
    icon="audio-volume-high"
  fi

  dunstify -a "changevolume" -u low -r "9993" -h int:value:"$volume" -i $icon "Volume: ${volume}%" -t 2000
}

case $1 in
up)
  # Set the volume on (if it was muted)
  pamixer -u
  pamixer -i 2 --allow-boost --set-limit 120
  send_notification
  ;;
down)
  pamixer -u
  pamixer -d 2 --allow-boost --set-limit 120
  send_notification
  ;;
mute)
  pamixer -t
  if $(pamixer --get-mute); then
    dunstify -i audio-volume-muted -a "changevolume" -t 2000 -r 9993 -u low "Muted"
  else
    send_notification
  fi
  ;;
esac
