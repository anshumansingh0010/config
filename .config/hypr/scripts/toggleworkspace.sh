#!/usr/bin/env bash
# toggleworkspace.sh — move the active window to/from special:todo workspace.
# Uses hyprctl eval (hl.dsp.*) since hyprctl dispatch no longer accepts plain text args
# in hyprland-luajit builds.

ws="$(hyprctl -j activewindow | python3 -c "import sys,json; print(json.load(sys.stdin)['workspace']['name'])")"

if [[ "$ws" == special* ]]; then
    hyprctl eval 'hl.dispatch(hl.dsp.window.move({ workspace = "e+0" }))'
else
    hyprctl eval 'hl.dispatch(hl.dsp.window.move({ workspace = "special:todo", follow = false }))'
fi
