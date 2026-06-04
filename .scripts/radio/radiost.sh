#!/bin/bash

SCRIPT_NAME="youtuberadio.sh"
SCRIPT_PATH="${HOME}/.scripts/radio/youtuberadio.sh"
KILL_SCRIPT="${HOME}/.scripts/radio/kill.sh"

# Check if the radio script is currently running
if pgrep -f "$SCRIPT_NAME" >/dev/null; then
    notify-send --hint=string:x-c-repl-id:radio "Radio" "Radio will be stopped"
    
    # Run your custom kill script natively
    bash "$KILL_SCRIPT"
else
    notify-send --hint=string:x-c-repl-id:radio "Radio" "Radio is starting: ${1:-Default}"
    
    # Launch natively in the background so pgrep can track the process name cleanly
    bash "$SCRIPT_PATH" "$1" &
fi
