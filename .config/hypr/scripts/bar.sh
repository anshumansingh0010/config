#!/usr/bin/env bash

TAGS=$(hyprctl -j activewindow | jq -r '.tags[]?')

if echo "$TAGS" | grep -qx "nobar"; then
    hyprctl dispatch tagwindow -- -nobar
else
    hyprctl dispatch tagwindow +nobar
fi
