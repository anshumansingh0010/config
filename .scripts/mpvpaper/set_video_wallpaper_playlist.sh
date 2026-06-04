#!/bin/bash

INPUT="$1"
TIMESTAMP="${2:-3}"
OUTPUT_DIR="${HOME}/.cache/wallpapersmpvpaper"
OUTPUT_FILE="${OUTPUT_DIR}/wallpaper_$(date +%Y%m%d_%H%M%S).png"
SOCKET_PATH="/tmp/mpv-socket"

mkdir -p "$OUTPUT_DIR"

# 1. Handle Playlist Tracking & Streaming Resolution
if [[ "$INPUT" == *"youtube.com"* ]] || [[ "$INPUT" == *"youtu.be"* ]]; then
    echo "Processing YouTube input source..."
    CACHE_DIR="${HOME}/.cache/mpvpaper"
    mkdir -p "$CACHE_DIR"
    
    PLAYLIST_HASH=$(echo -n "$INPUT" | md5sum | cut -d' ' -f1)
    CACHE_FILE="${CACHE_DIR}/playlist_${PLAYLIST_HASH}"
    
    # Safely extract stream list into an array
    mapfile -t VIDEO_IDS < <(yt-dlp --flat-playlist --get-id "$INPUT" 2>/dev/null)
    TOTAL_VIDEOS=${#VIDEO_IDS[@]}
    
    if [ "$TOTAL_VIDEOS" -eq 0 ]; then
        echo "Error: Failed to fetch online video markers."
        exit 1
    fi
    
    POINTER=0
    [[ -f "$CACHE_FILE" ]] && POINTER=$(cat "$CACHE_FILE")
    [[ "$POINTER" -ge "$TOTAL_VIDEOS" ]] && POINTER=0
    
    VIDEO_ID="${VIDEO_IDS[$POINTER]}"
    VIDEO_URL="https://www.youtube.com/watch?v=${VIDEO_ID}"
    echo "Target Video: $((POINTER + 1))/$TOTAL_VIDEOS"
    
    # Advance state marker cleanly
    echo "$(( (POINTER + 1) % TOTAL_VIDEOS ))" > "$CACHE_FILE"
else
    VIDEO_URL="$INPUT"
fi

# 2. Lightning Fast Thumbnail Extraction (No Network Latency)
echo "Extracting snapshot frame at ${TIMESTAMP}s..."
if [[ "$VIDEO_URL" == *"youtube.com"* || "$VIDEO_URL" == *"youtu.be"* ]]; then
    # Grab the small web-preview image instead of pulling raw stream data through mpv
    THUMB_URL=$(yt-dlp --get-thumbnail "$VIDEO_URL" 2>/dev/null)
    curl -s -o "$OUTPUT_FILE" "$THUMB_URL"
else
    # Only use mpv for local disk video files
    mpv --no-audio --start="$TIMESTAMP" --frames=1 --vo=image \
        --vo-image-format=png --vo-image-outdir="$OUTPUT_DIR" "$VIDEO_URL" &>/dev/null
    SCREENSHOT=$(ls -t "$OUTPUT_DIR"/*.png 2>/dev/null | head -n1)
    if [ -n "$SCREENSHOT" ]; then
        mv "$SCREENSHOT" "$OUTPUT_FILE"
    else
        cp "${HOME}/Pictures/default_wallpaper.png" "$OUTPUT_FILE" 2>/dev/null
    fi
fi

# 3. Dynamic Process Lifecycle Management
if ss -xln | grep -q "$SOCKET_PATH"; then
    echo "mpvpaper already running, shifting video streams..."
else
    echo "Initializing new mpvpaper canvas pipeline..."
    pkill -f mpvpaper
    rm -f "$SOCKET_PATH"
    
    # FIX: Initialize using the actual streaming video layout, not the flat PNG asset
    mpvpaper -o "video-aspect-override=16:10 --panscan=1.0 --vo=v --hwdec=auto --loop --no-audio --input-ipc-server=$SOCKET_PATH" eDP-1 "$VIDEO_URL" &
    sleep 1.5
fi

# 4. Global Interface Updates
echo "loadfile \"$VIDEO_URL\" replace" | socat - "$SOCKET_PATH" 2>/dev/null
echo "Syncing system theme layers with caelestia..."
caelestia wallpaper -f "$OUTPUT_FILE"

sleep 1
pkill -f awww-daemon
