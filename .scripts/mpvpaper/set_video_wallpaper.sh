#!/bin/bash
VIDEO_FILE="$1"
TIMESTAMP="${2:-3}"
OUTPUT_DIR="${HOME}/.cache/wallpapersmpvpaper"
OUTPUT_FILE="${OUTPUT_DIR}/wallpaper_$(date +%Y%m%d_%H%M%S).png"
SOCKET_PATH="/tmp/mpv-socket"

# Create cache directory if missing
mkdir -p "$OUTPUT_DIR"

# 1. Extract a static thumbnail frame for Caelestia
echo "Extracting frame at ${TIMESTAMP} seconds..."
mpv --no-audio \
    --start="$TIMESTAMP" \
    --frames=1 \
    --vo=image \
    --vo-image-format=png \
    --vo-image-outdir="$OUTPUT_DIR" \
    "$VIDEO_FILE" &>/dev/null

SCREENSHOT=$(ls -t "$OUTPUT_DIR"/*.png 2>/dev/null | head -n1)
if [ -n "$SCREENSHOT" ]; then
    mv "$SCREENSHOT" "$OUTPUT_FILE"
else
    echo "Error: Failed to extract frame from video."
    exit 1
fi

# 2. Handle mpvpaper Video Process Lifecycle
# Using 'ss' check as it is more accurate for bound IPC sockets than '-S'
if ss -xln | grep -q "$SOCKET_PATH"; then
    echo "mpvpaper already running, changing video via IPC..."
    echo "loadfile \"$VIDEO_FILE\" replace" | socat - "$SOCKET_PATH" 2>/dev/null
else
    echo "mpvpaper not running. Cleaning up dead instances and starting fresh..."
    pkill -f mpvpaper
    rm -f "$SOCKET_PATH"
    
    # Start mpvpaper in the background playing your video
    mpvpaper -o "video-aspect-override=16:10 --panscan=1.0 --loop --vo=v --hwdec=auto --no-audio --input-ipc-server=$SOCKET_PATH" eDP-1 "$VIDEO_FILE" &
    sleep 1
fi    

# 3. Apply Theme Engine Changes
echo "Setting wallpaper theme with caelestia..."
caelestia wallpaper -f "$OUTPUT_FILE"

# 4. Clean up competing daemons natively (No hyprctl wrapping needed)
sleep 2
pkill -f awww-daemon
