#!/bin/bash

DOWNLOADS_DIR="$HOME/Downloads"
WALLPAPER_DIR="$HOME/Downloads/Pictures"

# Create required directories
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$DOWNLOADS_DIR/Documents" "$DOWNLOADS_DIR/Videos" "$DOWNLOADS_DIR/Music"
mkdir -p "$DOWNLOADS_DIR/Archives" "$DOWNLOADS_DIR/Scripts" "$DOWNLOADS_DIR/Others"

# Ensure inotify-tools is installed
command -v inotifywait >/dev/null 2>&1 || { 
    echo "inotify-tools not installed. Run: yay -S inotify-tools"
    exit 1
}

echo "Watching $DOWNLOADS_DIR for new files..."

# Monitor directory (ignoring subdirectories and browser temp files)
inotifywait -m -e close_write -e moved_to --format '%f' "$DOWNLOADS_DIR" | while read -r FILE
do
    SRC_PATH="$DOWNLOADS_DIR/$FILE"

    # 1. Skip if the path is a directory (prevents loop on subfolders)
    [[ -d "$SRC_PATH" ]] && continue

    # 2. Skip active browser downloads
    [[ "$FILE" =~ \.(part|crdownload|tmp)$ ]] && continue

    EXT="${FILE##*.}"
    EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

    case "$EXT_LOWER" in
        jpg|jpeg|png|gif|svg)
            echo "Moving image: $FILE → $WALLPAPER_DIR"
            mv "$SRC_PATH" "$WALLPAPER_DIR/"
            ;;
        pdf|doc|docx|txt|ppt|pptx|xls|xlsx|odt|odp|csv)
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
