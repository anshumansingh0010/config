#!/bin/bash
WALLPAPER_PATH=$1
echo $WALLPAPER_PATH 
OUTPUT_DIR="${HOME}/Pictures/wallpapersmpvpaper"
if [[ "$WALLPAPER_PATH" = "$OUTPUT_DIR"* ]]; then
   echo "Using mpvpaper"
   
else
   rm ~/.config/wallengine/last.path
   mv ~/.config/wallengine/current.path ~/.config/wallengine/last.path
   echo  -n "$WALLPAPER_PATH" > ~/.config/wallengine/current.path
   hyprctl dispatch exec awww-daemon
   matugen image $WALLPAPER_PATH
   awww img $WALLPAPER_PATH --transition-type random --transition-step 100 --transition-duration 3 --transition-fps 60
   sleep 2
   hyprctl dispatch exec bash -c "echo 'quit' | socat - /tmp/mpv-socket"
   hyprctl dispatch exec pkill mpvpaper
   hyprctl dispatch exec pkill wallhell-daemon
fi
