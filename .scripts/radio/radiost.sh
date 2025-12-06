#!/bin/bash

# Check if youtuberadio.sh is running
if pgrep -f "youtuberadio.sh" >/dev/null; then
        echo "Radio will be stop"| xargs -I {} notify-send --hint=string:x-c-repl-id:radio "Radio" "{}"

    ~/.scripts/radio/kill.sh
else
    echo "Radio is not running → starting it"| xargs -I {} notify-send --hint=string:x-c-repl-id:radio "Radio" "{}"
   hyprctl dispatch exec  ~/.scripts/radio/youtuberadio.sh $1 &
fi
