#!/bin/bash
VIDEO_FILE="$1"
TIMESTAMP="${2:-3}"
OUTPUT_DIR="${HOME}/Pictures/wallpapersmpvpaper"
OUTPUT_FILE="${OUTPUT_DIR}/wallpaper_$(date +%Y%m%d_%H%M%S).png"

mkdir -p "$OUTPUT_DIR"

echo "Extracting frame at ${TIMESTAMP} seconds..."

mpv --no-audio \
    --start="$TIMESTAMP" \
    --frames=1 \
    --vo=image \
    --vo-image-format=png \
    --vo-image-outdir="$OUTPUT_DIR" \
    "$VIDEO_FILE" 2>/dev/null

SCREENSHOT=$(ls -t "$OUTPUT_DIR"/*.png 2>/dev/null | head -n1)
mv "$SCREENSHOT" "$OUTPUT_FILE"

if [[ -S /tmp/mpv-socket ]]; then
    echo "mpvpaper already running, changing video..."
    echo "loadfile \"$VIDEO_FILE\" replace" | socat - /tmp/mpv-socket
else
    echo "Starting mpvpaper..."
    mpvpaper -o "video-aspect-override=16:10 --panscan=1.0 --loop --no-audio --input-ipc-server=/tmp/mpv-socket" eDP-1 "$VIDEO_FILE" &
fi    
fiecho "Setting wallpaper with celestia..."
caelestia wallpaper -f "$OUTPUT_FILE"
sleep 2
hyprctl dispatch exec  pkill awww-daemon
SOCKET_PATH="/tmp/mpv-socket"

# Check if mpvpaper is already running with IPC socket
if ss -xln | grep -q "$SOCKET_PATH"; then
    echo "mpvpaper already running, changing video..."
else
    pkill mpvpaper
    echo "Starting mpvpaper..."
    mpvpaper -o "video-aspect-override=16:10 --panscan=1.0 --loop --no-audio --input-ipc-server=$SOCKET_PATH" eDP-1 "$OUTPUT_FILE" &
fi


echo "loadfile \"$VIDEO_FILE\" replace" | socat - $SOCKET_PATH
echo "Setting wallpaper with caelestia..."
caelestia wallpaper -f "$OUTPUT_FILE"
sleep 2
hyprctl dispatch exec  pkill awww-daemon