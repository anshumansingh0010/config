#!/bin/bash
echo $$ > ~/.cache/auto-music.pid
if [ -z "$1" ]; then
    echo "Usage: ./auto-music.sh <category>" | xargs -I {} notify-send --hint=string:x-c-repl-id:radio "Radio""{}"

    exit 1
fi

| xargs -I {} notify-send --hint=string:x-c-repl-id:wallpaper "wallpaper""{}"

CATEGORY="$1"
CACHE_DIR="$HOME/.cache/auto-music"
mkdir -p "$CACHE_DIR"
HISTORY="$CACHE_DIR/${CATEGORY}.history"
touch "$HISTORY"
 
echo "Starting fast music for category: $CATEGORY"| xargs -I {} notify-send --hint=string:x-c-repl-id:radio "Radio""{}"

# Function to fetch new IDs (fast mode: only 5 results)
fetch_ids() {
    yt-dlp "ytsearch5:$CATEGORY music" --get-id 2>/dev/null
}

# Load initial list
RAW=$(fetch_ids)

while true; do
    # Filter out already-played IDs
    NEW_IDS=""
    for ID in $RAW; do
        if ! grep -qx "$ID" "$HISTORY"; then
            NEW_IDS="$NEW_IDS $ID"
        fi
    done

    # If empty → fetch again
    if [ -z "$NEW_IDS" ]; then
        RAW=$(fetch_ids)
        continue
    fi

    # Shuffle
    IDS=$(echo "$NEW_IDS" | tr ' ' '\n' | shuf)

    # Play one by one
    for ID in $IDS; do
        echo "Playing: https://youtube.com/watch?v=$ID"| xargs -I {} notify-send --hint=string:x-c-repl-id:radio "Radio" "{}"
        echo "$ID" >> "$HISTORY"
        mpv --no-video "https://youtube.com/watch?v=$ID"
    done

    # After finishing this batch, fetch again
    RAW=$(fetch_ids)
done
