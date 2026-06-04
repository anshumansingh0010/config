#!/bin/bash

CATEGORY="$1"
CACHE_DIR="$HOME/.cache/auto-music"
PID_FILE="$CACHE_DIR/auto-music.pid"
mkdir -p "$CACHE_DIR"

# 1. Kill old instances before running a new one
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        notify-send --hint=string:x-c-repl-id:radio "Radio" "Stopping existing music process..."
        kill "$OLD_PID"
        sleep 0.5
    fi
fi
echo $$ > "$PID_FILE"

# 2. Check Arguments
if [ -z "$CATEGORY" ]; then
    notify-send --hint=string:x-c-repl-id:radio "Radio" "Usage: auto-music <category>"
    exit 1
fi

HISTORY="$CACHE_DIR/${CATEGORY}.history"
touch "$HISTORY"

notify-send --hint=string:x-c-repl-id:radio "Radio" "Starting music loop: $CATEGORY"

# Normalise history file
sed -i 's/\r//g; s/[ \t]*$//; /^$/d;' "$HISTORY"

# Helper function to randomize searches slightly to fetch fresh IDs
fetch_ids() {
    # Variations keep ytsearch results dynamic so the loop never stalls
    local modifiers=("music" "playlist" "mix" "audio" "live" "song")
    local rand_mod=${modifiers[$RANDOM % ${#modifiers[@]}]}
    yt-dlp "ytsearch10:${CATEGORY} ${rand_mod}" --get-id 2>/dev/null | tr -d '\r'
}

while true; do
    RAW="$(fetch_ids)"
    NEW_IDS=()

    # Filter out already played IDs
    while read -r ID; do
        [ -z "$ID" ] && continue
        if ! grep -Fxq "$ID" "$HISTORY"; then
            NEW_IDS+=("$ID")
        fi
    done <<< "$RAW"

    # If all items in this batch were already played, clear history to reset or try again
    if [ ${#NEW_IDS[@]} -eq 0 ]; then
        echo "All current results already played. Clearing history partition for $CATEGORY..."
        > "$HISTORY" 
        continue
    fi

    # Shuffle the unique batch
    SHUFFLED=$(printf '%s\n' "${NEW_IDS[@]}" | shuf)

    # Play through the current unique shuffle
    while read -r ID; do
        [ -z "$ID" ] && continue
        
        # Get actual video title instead of printing the cryptic ID string
        TITLE=$(yt-dlp --get-title "https://www.youtube.com/watch?v=$ID" 2>/dev/null)
        [ -z "$TITLE" ] && TITLE="ID: $ID"

        notify-send --hint=string:x-c-repl-id:radio "Radio" "Playing: $TITLE"
        echo "$ID" >> "$HISTORY"
        
        # Play via mpv without popping up a window
        mpv --no-video "https://www.youtube.com/watch?v=$ID"
    done <<< "$SHUFFLED"
done
