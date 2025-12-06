#!/bin/bash

INPUT="$1"
TIMESTAMP="${2:-3}"
OUTPUT_DIR="${HOME}/Pictures/wallpapersmpvpaper"
OUTPUT_FILE="${OUTPUT_DIR}/wallpaper_$(date +%Y%m%d_%H%M%S).png"

mkdir -p "$OUTPUT_DIR"

# Check if input is a YouTube playlist
if [[ "$INPUT" == *"youtube.com"* ]] || [[ "$INPUT" == *"youtu.be"* ]]; then
    echo "Fetching random video from playlist..."
    VIDEO_URL=$(yt-dlp --flat-playlist --get-id "$INPUT" | shuf -n 1 | xargs -I {} echo "https://www.youtube.com/watch?v={}")
    echo "Selected: $VIDEO_URL"
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

echo "Setting wallpaper with caelestia..."
caelestia wallpaper -f "$OUTPUT_FILE"

echo "Starting mpvpaper..."
mpvpaper -o "video-aspect-override=16:10 --panscan=1.0 --loop --no-audio" eDP-1 "$VIDEO_URL" &
