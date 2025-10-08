#!/bin/bash

# File containing the current wallpaper path
WALLPAPER_FILE="$HOME/wallpaper_list.txt"

# Function to set wallpaper
set_wallpaper() {
    local path="$1"
    if [[ -f "$path" ]]; then
        # Using feh to set wallpaper
       caelestia wallpaper -f "$path"
        echo "Wallpaper set to: $path"
    else
        echo "File does not exist: $path"
    fi
}

# Initial set
if [[ -f "$WALLPAPER_FILE" ]]; then
    wallpaper=$(<"$WALLPAPER_FILE")
    set_wallpaper "$wallpaper"
fi

# Watch the file for changes
echo "Watching $WALLPAPER_FILE for updates..."
while inotifywait -e modify "$WALLPAPER_FILE" >/dev/null 2>&1; do
    wallpaper=$(<"$WALLPAPER_FILE")
    set_wallpaper "$wallpaper"
done
