#!/bin/bash

INPUT="$1"
TIMESTAMP="${2:-3}"
OUTPUT_DIR="${HOME}/Pictures/wallpapersmpvpaper"
OUTPUT_FILE="${OUTPUT_DIR}/wallpaper_$(date +%Y%m%d_%H%M%S).png"

mkdir -p "$OUTPUT_DIR"

# Check if input is a YouTube playlist
if [[ "$INPUT" == *"youtube.com"* ]] || [[ "$INPUT" == *"youtu.be"* ]]; then
    echo "Fetching playlist videos..."
    CACHE_DIR="${HOME}/.cache/mpvpaper"
    # Create unique cache file per playlist using hash
    PLAYLIST_HASH=$(echo -n "$INPUT" | md5sum | cut -d' ' -f1)
    CACHE_FILE="${CACHE_DIR}/playlist_${PLAYLIST_HASH}"
    mkdir -p "$CACHE_DIR"
    
    # Get all video IDs
    VIDEO_IDS=($(yt-dlp --flat-playlist --get-id "$INPUT"))
    TOTAL_VIDEOS=${#VIDEO_IDS[@]}
    
    # Read current pointer, default to 0
    POINTER=0
    if [[ -f "$CACHE_FILE" ]]; then
        POINTER=$(cat "$CACHE_FILE")
    fi
    
    # Get video at current pointer
    VIDEO_ID="${VIDEO_IDS[$POINTER]}"
    VIDEO_URL="https://www.youtube.com/watch?v=${VIDEO_ID}"
    echo "Playing video $((POINTER + 1))/$TOTAL_VIDEOS: $VIDEO_URL"
    
    # Increment pointer and wrap around
    POINTER=$(( (POINTER + 1) % TOTAL_VIDEOS ))
    echo "$POINTER" > "$CACHE_FILE"
else
    VIDEO_URL="$INPUT"
fi

echo "Extracting frame at ${TIMESTAMP} seconds..."

mpv --no-audio \
    --start="$TIMESTAMP" \
    --frames=1 \
    --vo=image \
    --vo-image-format=png \
    --vo-image-outdir="$OUTPUT_DIR" \
    "$VIDEO_URL" 2>/dev/null

SCREENSHOT=$(ls -t "$OUTPUT_DIR"/*.png 2>/dev/null | head -n1)
mv "$SCREENSHOT" "$OUTPUT_FILE"

# Check if mpvpaper is already running with IPC socket
if [[ -S /tmp/mpv-socket ]]; then
    echo "mpvpaper already running, changing video..."
    echo "loadfile \"$VIDEO_URL\" replace" | socat - /tmp/mpv-socket
else
    echo "Starting mpvpaper..."
    mpvpaper -o "video-aspect-override=16:10 --panscan=1.0 --loop --no-audio --input-ipc-server=/tmp/mpv-socket" eDP-1 "$VIDEO_URL" &
fi


echo "Setting wallpaper with caelestia..."
caelestia wallpaper -f "$OUTPUT_FILE"
sleep 2
hyprctl dispatch exec  pkill awww-daemon