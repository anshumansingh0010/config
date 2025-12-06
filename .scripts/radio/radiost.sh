#!/bin/bash

# Check if youtuberadio.sh is running
if pgrep -f "youtuberadio.sh" >/dev/null; then
    notify-send "Radio " "Radio will be stop"
    ~/.scripts/radio/kill.sh
else
    notify-send "Radio " "Radio is not running → starting it"
   hyprctl dispatch exec  ~/.scripts/radio/youtuberadio.sh $1 &
fi
