#!/bin/bash

echo $$ > ~/.cache/auto-music.pid

if [ -z "$1" ]; then
    notify-send --hint=string:x-c-repl-id:radio "Radio" "Usage: ./auto-music.sh <category>"
    exit 1
fi

CATEGORY="$1"
CACHE_DIR="$HOME/.cache/auto-music"
mkdir -p "$CACHE_DIR"

HISTORY="$CACHE_DIR/${CATEGORY}.history"
touch "$HISTORY"

notify-send --hint=string:x-c-repl-id:radio "Radio" "Starting fast music: $CATEGORY"

# Normalise history (remove blank lines, whitespace)
sed -i 's/\r//g; s/[ \t]*$//; /^$/d;' "$HISTORY"

fetch_ids() {
    yt-dlp "ytsearch5:$CATEGORY " --get-id 2>/dev/null | tr -d '\r'
}

RAW="$(fetch_ids)"

while true; do
    NEW_IDS=()

    # Filter only new IDs
    for ID in $RAW; do
        if ! grep -Fxq "$ID" "$HISTORY"; then
            NEW_IDS+=("$ID")
        fi
    done

    # If empty, fetch again
    if [ ${#NEW_IDS[@]} -eq 0 ]; then
        RAW="$(fetch_ids)"
        continue
    fi

    # Shuffle IDs
    SHUFFLED=$(printf '%s\n' "${NEW_IDS[@]}" | shuf)

    # Play in order
    while read -r ID; do
        [ -z "$ID" ] && continue
        notify-send --hint=string:x-c-repl-id:radio "Radio" "Playing: $ID"
        echo "$ID" >> "$HISTORY"
        mpv --no-video "https://www.youtube.com/watch?v=$ID"
    done <<< "$SHUFFLED"

    RAW="$(fetch_ids)"
done
