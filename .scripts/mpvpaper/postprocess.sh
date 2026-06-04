#!/bin/bash
WALLPAPER_PATH=$1
echo "$WALLPAPER_PATH" 
OUTPUT_DIR="${HOME}/Pictures/wallpapersmpvpaper"

if [[ "$WALLPAPER_PATH" = "$OUTPUT_DIR"* ]]; then
   echo "Using mpvpaper"
else
   # Rotate paths cleanly
   rm -f ~/.config/wallengine/last.path
   [ -f ~/.config/wallengine/current.path ] && mv ~/.config/wallengine/current.path ~/.config/wallengine/last.path
   echo -n "$WALLPAPER_PATH" > ~/.config/wallengine/current.path
   
   hyprctl dispatch exec "${HOME}/.scripts/app.fish"
   hyprctl dispatch exec awww-daemon
   matugen image "$WALLPAPER_PATH"
   awww img "$WALLPAPER_PATH" --transition-type random --transition-step 100 --transition-duration 3 --transition-fps 60
   
   # Wait for the transition to finish
   sleep 2
   
   # Run system commands directly (No hyprctl wrapping needed)
   echo 'quit' | socat - /tmp/mpv-socket 2>/dev/null
   pkill -f mpvpaper
   pkill -f wallhell-daemon
fi
