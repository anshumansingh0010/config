#!/bin/bash

# Check if youtuberadio.sh is running
if pgrep -f "youtuberadio.sh" >/dev/null; then
    echo "Radio is running → stopping it"
    ~/.scripts/radio/kill.sh
else
    echo "Radio is not running → starting it"
   hyprctl dispatch exec  ~/.scripts/radio/youtuberadio.sh $1 &
fi
