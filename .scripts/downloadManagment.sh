#!/bin/bash

DOWNLOADS_DIR="$HOME/Downloads"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Create required directories
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$DOWNLOADS_DIR/Documents" "$DOWNLOADS_DIR/Videos" "$DOWNLOADS_DIR/Music"
mkdir -p "$DOWNLOADS_DIR/Archives" "$DOWNLOADS_DIR/Scripts" "$DOWNLOADS_DIR/Others"

command -v inotifywait >/dev/null 2>&1 || { 
    echo "inotify-tools not installed. Run: sudo apt install inotify-tools"
    exit 1
}

echo "Watching $DOWNLOADS_DIR for new files..."

# Function to check if download is complete
wait_for_complete() {
    local FILEPATH="$1"
    local LASTSIZE=-1
    local CURSIZE=0

    while true; do
        if [[ ! -f "$FILEPATH" ]]; then
            return 1  # File disappeared
        fi

        CURSIZE=$(stat -c%s "$FILEPATH" 2>/dev/null)
        if [[ "$CURSIZE" -eq "$LASTSIZE" ]]; then
            break  # size has stabilized
        fi

        LASTSIZE=$CURSIZE
        sleep 3
    done
    return 0
}

inotifywait -m -e close_write -e moved_to --format '%f' "$DOWNLOADS_DIR" | while read FILE
do
    SRC_PATH="$DOWNLOADS_DIR/$FILE"
    EXT="${FILE##*.}"
    EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

    # Skip if directory
    [[ -d "$SRC_PATH" ]] && continue

    # Wait for file to finish writing
    echo "Detected $FILE, waiting for download to finish..."
    wait_for_complete "$SRC_PATH"

    case "$EXT_LOWER" in
        jpg|jpeg|png)
            echo "Moving image: $FILE → $WALLPAPER_DIR"
            mv "$SRC_PATH" "$WALLPAPER_DIR/"
            ;;
        pdf|doc|docx|txt|ppt|pptx|xls|xlsx|odt|odp)
            echo "Moving document: $FILE → Documents"
            mv "$SRC_PATH" "$DOWNLOADS_DIR/Documents/"
            ;;
        mp4|mkv|avi|mov|flv|webm)
            echo "Moving video: $FILE → Videos"
            mv "$SRC_PATH" "$DOWNLOADS_DIR/Videos/"
            ;;
        mp3|wav|ogg|flac|m4a)
            echo "Moving audio: $FILE → Music"
            mv "$SRC_PATH" "$DOWNLOADS_DIR/Music/"
            ;;
        zip|tar|gz|bz2|xz|7z|rar)
            echo "Moving archive: $FILE → Archives"
            mv "$SRC_PATH" "$DOWNLOADS_DIR/Archives/"
            ;;
        sh|py|js|go|rb|pl|php|c|cpp|java|rs|out)
            echo "Moving script/code: $FILE → Scripts"
            mv "$SRC_PATH" "$DOWNLOADS_DIR/Scripts/"
            ;;
        *)
            echo "Moving other file: $FILE → Others"
            mv "$SRC_PATH" "$DOWNLOADS_DIR/Others/"
            ;;
    esac
done
