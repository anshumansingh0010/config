#!/usr/bin/env bash
# resizetocenter.sh — resize and center the active floating window within screen bounds.
# Uses hyprctl eval (hl.dsp.*) since hyprctl dispatch no longer accepts plain text args
# in hyprland-luajit builds.

win_json=$(hyprctl activewindow -j)
if [[ -z "$win_json" || "$win_json" == "null" ]]; then
    exit 0
fi

width=$(echo "$win_json"  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['size'][0])")
height=$(echo "$win_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['size'][1])")
addr=$(echo "$win_json"   | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['address'])")

mxheight=976
mxwidth=1523
ymove=0
xmove=0

if (( height > mxheight && width > mxwidth )); then
    hyprctl eval "hl.dispatch(hl.dsp.window.resize({ x = $mxwidth, y = $mxheight, relative = false, window = 'address:$addr' }))"
    hyprctl eval "hl.dispatch(hl.dsp.window.center({ window = 'address:$addr' }))"
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ x = $xmove, y = $ymove, relative = true, window = 'address:$addr' }))"
elif (( height > mxheight )); then
    hyprctl eval "hl.dispatch(hl.dsp.window.resize({ x = $width, y = $mxheight, relative = false, window = 'address:$addr' }))"
    # Re-fetch position after resize
    current_x=$(hyprctl activewindow -j | python3 -c "import sys,json; print(json.load(sys.stdin)['at'][0])")
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ x = $current_x, y = 12, relative = false, window = 'address:$addr' }))"
elif (( width > mxwidth )); then
    hyprctl eval "hl.dispatch(hl.dsp.window.resize({ x = $mxwidth, y = $height, relative = false, window = 'address:$addr' }))"
    # Re-fetch position after resize
    current_y=$(hyprctl activewindow -j | python3 -c "import sys,json; print(json.load(sys.stdin)['at'][1])")
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ x = 65, y = $current_y, relative = false, window = 'address:$addr' }))"
else
    hyprctl eval "hl.dispatch(hl.dsp.window.center({ window = 'address:$addr' }))"
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ x = $xmove, y = $ymove, relative = true, window = 'address:$addr' }))"
fi
