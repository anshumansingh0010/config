#!/bin/bash
Target_dirs=(
    "/home/jay/tmptasks/imgCache"
    "~/.config/variety/Downloaded/"
)

for TARGET_DIR in "${Target_dirs[@]}"; do
# Safety check
if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory not found: $TARGET_DIR"
    exit 1
fi

# Delete items older than 5 days
find "$TARGET_DIR" -mindepth 1 -mtime +5 -exec rm -rf {} \;

done