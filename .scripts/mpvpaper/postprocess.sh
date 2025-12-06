#!/bin/bash
WALLPAPER_PATH=$1

OUTPUT_DIR="${HOME}/Pictures/wallpapersmpvpaper"
if [[ "$WALLPAPER_PATH" = "$OUTPUT_DIR"* ]]; then
   echo "Using mpvpaper, killing swww..."
   pkill swww-daemon
else
   echo "Using swww for static wallpaper..."
   awww img "$WALLPAPER_PATH" --transition-type random --transition-step 100 --transition-duration 3 --transition-fps 60
fi