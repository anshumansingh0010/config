#!/bin/bash

# Set your city
CITY=$(cat "./city.txt")
echo "$CITY"
cat "./city.txt"
# Default wallpaper folder (fallback)
DEFAULT_FOLDER="$HOME/Pictures/Wallpapers"

# Fetch current weather description from wttr.in
WEATHER=$(curl -s "wttr.in/$CITY?format=%C" | tr '[:upper:]' '[:lower:]')

# Map weather to wallpaper folder
if [[ "$WEATHER" == *"clear"* || "$WEATHER" == *"sunny"* ]]; then
    FOLDER="$HOME/Wallpapers/Clear"
elif [[ "$WEATHER" == *"cloud"* || "$WEATHER" == *"overcast"* ]]; then
    FOLDER="$HOME/Wallpapers/Cloudy"
elif [[ "$WEATHER" == *"mist"* || "$WEATHER" == *"fog"* || "$WEATHER" == *"haze"* ]]; then
    FOLDER="$HOME/Wallpapers/Fog"
elif [[ "$WEATHER" == *"rain"* || "$WEATHER" == *"shower"* ]]; then
    FOLDER="$HOME/Wallpapers/Rain"
elif [[ "$WEATHER" == *"thunder"* || "$WEATHER" == *"storm"* ]]; then
    FOLDER="$HOME/Wallpapers/Thunderstorm"
else
    # Default folder if weather not recognized
    FOLDER="$HOME/Wallpapers/Default"
fi

# Pick a random image from the folder, fallback to default if empty
IMAGE=$(find "$FOLDER" -type f | shuf -n 1)

if [[ -z "$IMAGE" ]]; then
    echo "No images found in $FOLDER. Using default folder."
    IMAGE=$(find "$DEFAULT_FOLDER" -type f | shuf -n 1)
fi

# Show selected image path
echo "Selected wallpaper: $IMAGE"

# Set the wallpaper using caelestia
caelestia wallpaper -f "$IMAGE"
